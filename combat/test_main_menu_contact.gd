extends SceneTree

## Regression coverage for the developer credit and investor contact entry.
func _initialize() -> void:
	var scene := load("res://ui/main_menu.tscn") as PackedScene
	_assert(scene != null, "main menu scene should load")
	var instance := scene.instantiate()
	_assert(instance is MainMenu, "main menu should instantiate MainMenu")
	root.add_child(instance)

	var credit := _find_label_with_text(instance, "开发者：蛋汤")
	_assert(credit != null, "developer credit should be visible")

	var contact := _find_button_with_text(instance, "投资合作 / 联系开发者")
	_assert(contact != null, "investor contact button should be visible")
	_assert(contact.tooltip_text.find("DanTangdwcyxgs") >= 0, "contact tooltip should contain WeChat id")

	var dialog := instance.call("_create_contact_dialog") as AcceptDialog
	_assert(dialog != null, "contact dialog should be created")
	_assert(dialog.title == "投资合作 / 联系开发者", "contact dialog title should be correct")
	_assert(dialog.dialog_text.find("蛋汤") >= 0, "contact dialog should show developer name")
	_assert(dialog.dialog_text.find("DanTangdwcyxgs") >= 0, "contact dialog should show WeChat id")
	_assert(dialog.ok_button_text == "复制微信号", "contact dialog should offer clipboard action")
	dialog.queue_free()

	instance.queue_free()
	print("ALL MAIN MENU CONTACT TESTS PASSED")
	quit(0)

func _find_button_with_text(root_node: Node, text: String) -> Button:
	for child in root_node.find_children("", "Button", true, false):
		var button := child as Button
		if button != null and button.text == text:
			return button
	return null

func _find_label_with_text(root_node: Node, text: String) -> Label:
	for child in root_node.find_children("", "Label", true, false):
		var label := child as Label
		if label != null and label.text == text:
			return label
	return null

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
