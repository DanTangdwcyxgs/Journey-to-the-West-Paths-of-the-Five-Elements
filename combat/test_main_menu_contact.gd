extends RefCounted

## Regression coverage for the developer credit and investor contact entry.
static func run_all() -> Dictionary:
	var scene := load("res://ui/main_menu.tscn") as PackedScene
	assert(scene != null, "main menu scene should load")
	var instance := scene.instantiate()
	assert(instance is MainMenu, "main menu should instantiate MainMenu")
	instance.call("_build_ui")

	var credit := _find_label_with_text(instance, "开发者：蛋汤")
	assert(credit != null, "developer credit should be visible")

	var contact := _find_button_with_text(instance, "投资合作 / 联系开发者")
	assert(contact != null, "investor contact button should be visible")
	assert(contact.tooltip_text.find("DanTangdwcyxgs") >= 0, "contact tooltip should contain WeChat id")

	var dialog := instance.call("_create_contact_dialog") as AcceptDialog
	assert(dialog != null, "contact dialog should be created")
	assert(dialog.title == "投资合作 / 联系开发者", "contact dialog title should be correct")
	assert(dialog.dialog_text.find("蛋汤") >= 0, "contact dialog should show developer name")
	assert(dialog.dialog_text.find("DanTangdwcyxgs") >= 0, "contact dialog should show WeChat id")
	assert(dialog.ok_button_text == "复制微信号", "contact dialog should offer clipboard action")

	return {
		"passed": true,
		"developer_credit_verified": true,
		"investor_contact_verified": true,
	}

static func _find_button_with_text(root_node: Node, text: String) -> Button:
	for child in root_node.find_children("", "Button", true, false):
		var button := child as Button
		if button != null and button.text == text:
			return button
	return null

static func _find_label_with_text(root_node: Node, text: String) -> Label:
	for child in root_node.find_children("", "Label", true, false):
		var label := child as Label
		if label != null and label.text == text:
			return label
	return null
