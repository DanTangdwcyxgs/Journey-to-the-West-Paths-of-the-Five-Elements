extends SceneTree

## Font loading must be safe both with the CI-downloaded CJK font and without it.
func _initialize() -> void:
	var fallback: Font = PixelUI.load_ui_font("res://fonts/__intentionally_missing_for_test__.otf")
	_assert(fallback != null, "a missing optional font should fall back to the engine font")

	var theme: Theme = PixelUI.build_theme()
	_assert(theme != null and theme.default_font != null, "PixelUI should always build a usable default font")

	var hud := PixelHUD.new()
	root.add_child(hud)
	await process_frame
	_assert(hud.font != null, "PixelHUD should resolve a font without throwing when the bundled font is absent")
	hud.queue_free()
	await process_frame
	print("ALL PIXEL UI FONT CONTRACT TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
