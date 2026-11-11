#!/usr/bin/env python3
"""Archive a 2x2 character turnaround sheet and extract its top-left runtime view."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Final

from PIL import Image


CHARACTER_SIZES: Final[dict[str, tuple[int, int]]] = {
    "wukong": (128, 192),
    "tang": (128, 192),
    "bajie": (128, 192),
    "wujing": (128, 192),
    "longma": (160, 128),
    "yellow_wind": (144, 192),
}
SOURCE_DIR: Final[Path] = Path("assets/art/source_sheets/characters")
FINAL_DIR: Final[Path] = Path("assets/art/characters/final")
DEFAULT_PADDING: Final[int] = 4
MIN_TRANSPARENT_RATIO: Final[float] = 0.05


class PreparationError(ValueError):
    """Raised when a source sheet cannot safely become a runtime sprite."""


@dataclass(frozen=True)
class PreparationResult:
    character: str
    source_sheet: str
    gameplay_crop: str
    source_sheet_size: tuple[int, int]
    quadrant_size: tuple[int, int]
    visible_bounds_in_quadrant: tuple[int, int, int, int]
    output_size: tuple[int, int]
    placed_sprite_size: tuple[int, int]
    output_alpha_bounds: tuple[int, int, int, int]
    source_sha256: str


def _has_alpha_channel(image: Image.Image) -> bool:
    return "A" in image.getbands() or (
        image.mode == "P" and "transparency" in image.info
    )


def _stage_copy(source: Path, destination: Path) -> Path:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        prefix=f".{destination.name}.", suffix=".tmp", dir=destination.parent, delete=False
    ) as temporary:
        temporary_path = Path(temporary.name)
        try:
            with source.open("rb") as handle:
                shutil.copyfileobj(handle, temporary)
        except Exception:
            temporary_path.unlink(missing_ok=True)
            raise
    return temporary_path


def _stage_png(image: Image.Image, destination: Path) -> Path:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        prefix=f".{destination.name}.", suffix=".tmp", dir=destination.parent, delete=False
    ) as temporary:
        temporary_path = Path(temporary.name)
    try:
        image.save(temporary_path, format="PNG", optimize=True)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise
    return temporary_path


def prepare_turnaround(
    input_path: Path,
    character: str,
    repo_root: Path,
    *,
    padding: int = DEFAULT_PADDING,
    overwrite: bool = False,
) -> PreparationResult:
    """Archive the original sheet and create the canonical top-left view crop."""

    character = character.lower().strip()
    if character not in CHARACTER_SIZES:
        raise PreparationError(
            f"Unknown character {character!r}; choose one of: {', '.join(CHARACTER_SIZES)}"
        )
    if padding < 0:
        raise PreparationError("Padding cannot be negative")

    source = input_path.expanduser().resolve()
    root = repo_root.expanduser().resolve()
    if not source.is_file():
        raise PreparationError(f"Input image does not exist: {source}")

    source_destination = root / SOURCE_DIR / f"{character}_turnaround.png"
    final_destination = root / FINAL_DIR / f"{character}.png"
    if source == source_destination.resolve():
        raise PreparationError("Input and archive paths must be different")
    if (source_destination.exists() or final_destination.exists()) and not overwrite:
        existing = [str(p) for p in (source_destination, final_destination) if p.exists()]
        raise PreparationError(
            "Refusing to overwrite existing art; pass --overwrite only after reviewing it: "
            + ", ".join(existing)
        )

    try:
        with Image.open(source) as opened:
            opened.load()
            if opened.format != "PNG":
                raise PreparationError("Source must be a PNG file")
            if not _has_alpha_channel(opened):
                raise PreparationError(
                    "Source must contain a real alpha channel; flattened backgrounds/checkerboards are rejected"
                )
            sheet = opened.convert("RGBA")
    except OSError as error:
        raise PreparationError(f"Could not read source PNG: {error}") from error

    sheet_width, sheet_height = sheet.size
    if sheet_width < 8 or sheet_height < 8:
        raise PreparationError(f"Source sheet is too small: {sheet_width}x{sheet_height}")
    if sheet_width % 2 or sheet_height % 2:
        raise PreparationError(
            f"2x2 source sheet must have even width and height; got {sheet_width}x{sheet_height}"
        )

    quadrant_width, quadrant_height = sheet_width // 2, sheet_height // 2
    front = sheet.crop((0, 0, quadrant_width, quadrant_height))
    alpha = front.getchannel("A")
    alpha_histogram = alpha.histogram()
    transparent_ratio = alpha_histogram[0] / float(quadrant_width * quadrant_height)
    if transparent_ratio < MIN_TRANSPARENT_RATIO:
        raise PreparationError(
            "Top-left quadrant has too little fully transparent background "
            f"({transparent_ratio:.1%}); reject flattened background or panel frame"
        )

    visible_bounds = alpha.getbbox()
    if visible_bounds is None:
        raise PreparationError("Top-left quadrant contains no visible character pixels")
    left, top, right, bottom = visible_bounds
    if left == 0 or top == 0 or right == quadrant_width or bottom == quadrant_height:
        raise PreparationError(
            "Top-left view touches a quadrant edge; the figure or a prop may be cropped. "
            "Reject it and revise the next scheduled generation brief."
        )
    visible = front.crop(visible_bounds)
    visible_width, visible_height = visible.size

    target_width, target_height = CHARACTER_SIZES[character]
    available_width = target_width - padding * 2
    available_height = target_height - padding * 2
    if available_width <= 0 or available_height <= 0:
        raise PreparationError(
            f"Padding {padding}px leaves no room on the {target_width}x{target_height} canvas"
        )

    scale = min(available_width / visible_width, available_height / visible_height)
    resized_width = max(1, min(available_width, round(visible_width * scale)))
    resized_height = max(1, min(available_height, round(visible_height * scale)))
    resized = visible.resize((resized_width, resized_height), Image.Resampling.NEAREST)

    output = Image.new("RGBA", (target_width, target_height), (0, 0, 0, 0))
    offset_x = (target_width - resized_width) // 2
    offset_y = target_height - padding - resized_height
    output.alpha_composite(resized, (offset_x, offset_y))
    output_bounds = output.getchannel("A").getbbox()
    if output_bounds is None:
        raise PreparationError("Unexpected empty output after resizing")

    staged_source: Path | None = None
    staged_crop: Path | None = None
    try:
        staged_source = _stage_copy(source, source_destination)
        staged_crop = _stage_png(output, final_destination)
        os.replace(staged_source, source_destination)
        staged_source = None
        os.replace(staged_crop, final_destination)
        staged_crop = None
    finally:
        if staged_source is not None:
            staged_source.unlink(missing_ok=True)
        if staged_crop is not None:
            staged_crop.unlink(missing_ok=True)

    digest_builder = hashlib.sha256()
    with source.open("rb") as source_handle:
        for chunk in iter(lambda: source_handle.read(1024 * 1024), b""):
            digest_builder.update(chunk)
    return PreparationResult(
        character=character,
        source_sheet=str(source_destination.relative_to(root)),
        gameplay_crop=str(final_destination.relative_to(root)),
        source_sheet_size=(sheet_width, sheet_height),
        quadrant_size=(quadrant_width, quadrant_height),
        visible_bounds_in_quadrant=visible_bounds,
        output_size=(target_width, target_height),
        placed_sprite_size=(resized_width, resized_height),
        output_alpha_bounds=output_bounds,
        source_sha256=digest_builder.hexdigest(),
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Archive a 2x2 character turnaround and crop its top-left primary view."
    )
    parser.add_argument("--input", required=True, type=Path, help="Generated transparent PNG sheet")
    parser.add_argument("--character", required=True, choices=sorted(CHARACTER_SIZES))
    parser.add_argument(
        "--repo-root", type=Path, default=Path(__file__).resolve().parents[2],
        help="Repository root (defaults to the parent of tools/)",
    )
    parser.add_argument("--padding", type=int, default=DEFAULT_PADDING, help="Transparent margin in runtime pixels")
    parser.add_argument(
        "--overwrite", action="store_true",
        help="Replace existing source/crop only after the caller has reviewed the old files",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        result = prepare_turnaround(
            args.input, args.character, args.repo_root,
            padding=args.padding, overwrite=args.overwrite,
        )
    except (PreparationError, OSError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    print(json.dumps(asdict(result), indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
