extends SceneTree

## 单个测试文件的隔离执行器（辅助工具，不是测试用例，因此故意不命名为 test_*.gd，
## 避免被 runtime_suite.gd 的自动扫描当成测试收录）。
##
## 由 tests/runtime_suite.gd 通过子进程调用：
##   godot --headless --path . --script res://tests/case_runner.gd -- res://combat/test_x.gd
##
## 为什么要隔离执行：
##   suite 进程内直接跑遗留测试风险很高——任何一个 assert 失败、空引用或未捕获的
##   运行时错误都可能中断整个 suite，导致其余测试根本没机会执行。
##   放进子进程后，单个测试的崩溃只会让这一个文件失败。
##
## 输出机器可读标记：CASE_RUNNER_RESULT ok=<0|1> target=<path> detail=<...>
## 退出码：0 通过 / 1 失败。

const MAX_FRAMES := 30
## suite 会把目标测试路径同时写进这个文件；命令行参数解析失败时用它兜底。
const TARGET_FILE := "user://case_runner_target.txt"

var _target := ""
var _target_source := "none"
var _ok := false
var _detail := ""
var _finished := false
var _frames := 0


# 用于在运行期自校准「静态函数」的标志位，避免硬编码 Godot 内部 MethodFlags 数值。
static func _flag_probe_static() -> void:
	pass


func _flag_probe_instance() -> void:
	pass


func _initialize() -> void:
	_target = _find_target()
	if _target.is_empty():
		_detail = "未收到目标测试路径（命令行参数解析失败）"
		_finish()
		return
	var scr = load(_target)
	if scr == null:
		_detail = "目标脚本加载失败：" + _target
		_finish()
		return
	var outcome: Array = _invoke(scr)
	_ok = bool(outcome[0])
	_detail = str(outcome[1])
	_finish()


func _process(_delta: float) -> bool:
	_frames += 1
	# 兜底：如果 _initialize 因运行时错误中途中断（此时 _finish 没被调用），
	# 也要在 MAX_FRAMES 帧内退出，不能让子进程挂死把 CI 拖到超时。
	if _finished or _frames >= MAX_FRAMES:
		_finish()
		return true
	return false


func _finish() -> void:
	if _finished:
		return
	_finished = true
	print("CASE_RUNNER_RESULT ok=%d target=%s source=%s detail=%s" % [
		1 if _ok else 0, _target, _target_source, _detail,
	])
	quit(0 if _ok else 1)


func _find_target() -> String:
	var candidates: Array = []
	for value in OS.get_cmdline_args():
		candidates.append(str(value))
	for value in OS.get_cmdline_user_args():
		candidates.append(str(value))
	for value in candidates:
		if _looks_like_test_path(value):
			_target_source = "cmdline"
			return value
	# 兜底：命令行参数若被 Godot 吞掉，改读 suite 写下的目标文件
	var fallback := FileAccess.get_file_as_string(TARGET_FILE)
	if not fallback.is_empty() and _looks_like_test_path(fallback):
		_target_source = "file"
		return fallback
	_target_source = "none"
	return ""


func _looks_like_test_path(value: String) -> bool:
	return value.begins_with("res://") and value.ends_with(".gd") and value.find("case_runner.gd") == -1


func _invoke(scr) -> Array:
	var entry := ""
	for candidate in ["run_all", "test_all", "run"]:
		if scr.has_method(candidate):
			entry = candidate
			break
	if entry.is_empty():
		return [false, "未找到可执行入口（run_all / test_all / run）"]

	var result: Variant = null
	if _is_static_method(scr, entry):
		result = scr.call(entry)
	else:
		var inst = scr.new()
		if inst == null:
			return [false, "无法实例化，基类=%s" % str(scr.get_instance_base_type())]
		result = inst.call(entry)
	return _judge(result)


func _judge(result: Variant) -> Array:
	if result is Dictionary:
		var table := result as Dictionary
		if table.has("passed"):
			return [bool(table["passed"]), str(table)]
		# 没有 passed 字段时，把返回字典里的 bool 值当作逐项检查结论
		var bad: Array[String] = []
		for key in table.keys():
			if table[key] is bool and not bool(table[key]):
				bad.append(str(key))
		if not bad.is_empty():
			return [false, "以下检查项为 false: %s | %s" % [str(bad), str(table)]]
		return [true, str(table)]
	if result == null:
		return [true, "ok（断言式测试，无返回值）"]
	return [true, str(result)]


func _is_static_method(scr, method: String) -> bool:
	var mask := _static_flag_mask()
	for entry in scr.get_script_method_list():
		if str(entry.get("name", "")) == method:
			return (int(entry.get("flags", 0)) & mask) != 0
	return false


func _static_flag_mask() -> int:
	var static_flags := 0
	var instance_flags := 0
	for entry in get_script().get_script_method_list():
		var name := str(entry.get("name", ""))
		if name == "_flag_probe_static":
			static_flags = int(entry.get("flags", 0))
		elif name == "_flag_probe_instance":
			instance_flags = int(entry.get("flags", 0))
	var mask := static_flags & ~instance_flags
	if mask == 0:
		# 自校准失败时的兜底值（Godot 4 MethodFlags.METHOD_FLAG_STATIC）
		mask = 256
	return mask
