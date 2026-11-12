from __future__ import annotations

import hashlib
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

from prepare_character_turnaround import PreparationError, prepare_turnaround


class PrepareTurnaroundTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / "generated_sheet.png"

    def tearDown(self) -> None:
        self.temp.cleanup()

    def make_valid_sheet(self) -> None:
        sheet = Image.new("RGBA", (400, 400), (0, 0, 0, 0))
        draw = ImageDraw.Draw(sheet)
        draw.rectangle((40, 30, 119, 189), fill=(210, 40, 30, 255))
        draw.rectangle((130, 12, 135, 190), fill=(240, 190, 30, 255))
        draw.rectangle((230, 30, 319, 189), fill=(20, 180, 40, 255))
        draw.rectangle((40, 230, 119, 389), fill=(20, 40, 210, 255))
        draw.rectangle((230, 230, 319, 389), fill=(180, 20, 180, 255))
        sheet.save(self.source)

    def test_archives_original_and_extracts_only_top_left(self) -> None:
        self.make_valid_sheet()
        original = self.source.read_bytes()
        digest = hashlib.sha256(original).hexdigest()
        result = prepare_turnaround(self.source, "wukong", self.root)

        archive = self.root / result.source_sheet
        crop_path = self.root / result.gameplay_crop
        self.assertEqual(archive.read_bytes(), original)
        self.assertEqual(result.source_sha256, digest)
        self.assertEqual(
            set(result.quadrant_visible_bounds),
            {"front_3q", "right_profile", "rear_3q", "left_profile"},
        )
        self.assertTrue(all(ratio >= 0.05 for ratio in result.quadrant_transparent_ratios.values()))
        self.assertTrue(crop_path.is_file())

        with Image.open(crop_path) as crop:
            self.assertEqual(crop.mode, "RGBA")
            self.assertEqual(crop.size, (128, 192))
            self.assertIsNotNone(crop.getchannel("A").getbbox())
            colors = crop.getcolors(maxcolors=1_000_000) or []
            visible_colors = [color for _count, color in colors if color[3] > 0]
            self.assertTrue(visible_colors)
            self.assertFalse(
                any(r < 100 and g < 100 and b > 100 for r, g, b, _a in visible_colors),
                "blue/purple rear views leaked into crop",
            )
            self.assertFalse(
                any(r < 100 and g > 100 and b < 100 for r, g, b, _a in visible_colors),
                "green right-side view leaked into crop",
            )

    def test_preserves_aspect_ratio_and_bottom_alignment(self) -> None:
        self.make_valid_sheet()
        result = prepare_turnaround(self.source, "wukong", self.root)
        width, height = result.placed_sprite_size
        self.assertAlmostEqual(width / height, 96 / 179, delta=0.02)
        self.assertEqual(result.output_alpha_bounds[3], 188)
        self.assertGreaterEqual(result.output_alpha_bounds[0], 4)
        self.assertLessEqual(result.output_alpha_bounds[2], 124)

    def test_rejects_flattened_rgb_source(self) -> None:
        Image.new("RGB", (400, 400), "white").save(self.source)
        with self.assertRaisesRegex(PreparationError, "real alpha channel"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_rejects_opaque_top_left_panel(self) -> None:
        Image.new("RGBA", (400, 400), (255, 255, 255, 255)).save(self.source)
        with self.assertRaisesRegex(PreparationError, "too little fully transparent"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_rejects_odd_sheet_dimensions(self) -> None:
        Image.new("RGBA", (401, 400), (0, 0, 0, 0)).save(self.source)
        with self.assertRaisesRegex(PreparationError, "even width and height"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_rejects_unknown_character(self) -> None:
        self.make_valid_sheet()
        with self.assertRaisesRegex(PreparationError, "Unknown character"):
            prepare_turnaround(self.source, "not_a_character", self.root)

    def test_refuses_overwrite_by_default(self) -> None:
        self.make_valid_sheet()
        prepare_turnaround(self.source, "wukong", self.root)
        with self.assertRaisesRegex(PreparationError, "Refusing to overwrite"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_longma_uses_horizontal_runtime_canvas(self) -> None:
        self.make_valid_sheet()
        result = prepare_turnaround(self.source, "longma", self.root)
        with Image.open(self.root / result.gameplay_crop) as crop:
            self.assertEqual(crop.size, (160, 128))

    def test_rejects_view_touching_quadrant_edge(self) -> None:
        sheet = Image.new("RGBA", (400, 400), (0, 0, 0, 0))
        ImageDraw.Draw(sheet).rectangle((0, 30, 80, 180), fill=(200, 30, 30, 255))
        sheet.save(self.source)
        with self.assertRaisesRegex(PreparationError, "touches a quadrant edge"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_rejects_empty_non_primary_view(self) -> None:
        self.make_valid_sheet()
        with Image.open(self.source) as opened:
            sheet = opened.convert("RGBA")
        ImageDraw.Draw(sheet).rectangle((200, 200, 399, 399), fill=(0, 0, 0, 0))
        sheet.save(self.source)
        with self.assertRaisesRegex(PreparationError, "rear_3q.*contains no visible character"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_rejects_non_primary_view_touching_quadrant_edge(self) -> None:
        self.make_valid_sheet()
        with Image.open(self.source) as opened:
            sheet = opened.convert("RGBA")
        ImageDraw.Draw(sheet).rectangle((390, 60, 399, 170), fill=(250, 240, 10, 255))
        sheet.save(self.source)
        with self.assertRaisesRegex(PreparationError, "right_profile.*touches a quadrant edge"):
            prepare_turnaround(self.source, "wukong", self.root)

    def test_rejects_transparent_but_empty_top_left_quadrant(self) -> None:
        sheet = Image.new("RGBA", (400, 400), (0, 0, 0, 0))
        ImageDraw.Draw(sheet).rectangle((230, 30, 319, 189), fill=(20, 180, 40, 255))
        sheet.save(self.source)
        with self.assertRaisesRegex(PreparationError, "contains no visible character"):
            prepare_turnaround(self.source, "wukong", self.root)


if __name__ == "__main__":
    unittest.main(verbosity=2)
