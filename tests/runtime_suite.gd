extends SceneTree

## Godot 4.5 headless 测试总入口 —— 目录自动扫描，不再手工注册。
##
## 为什么改成自动扫描：
##   旧版本用 const TEST_SCRIPTS 手工罗列测试路径，任何新增测试都必须记得回来改这个文件。
##   结果就是仓库里累积了 36 个从未在 CI 中执行过的 test_*.gd。
##   现在只要把文件放进 SCAN_ROOTS 下的任意目录并命名为 test_*.gd，就会自动接入 CI。
##
## 执行方式（按优先级）：
##   1) static run_all() -> Dictionary                 : 在 suite 进程内直接调用（沿用旧约定）
##   2) 基类是 SceneTree / MainLoop                     : 子进程 godot --script <path>
##   3) 其它（RefCounted 等，static run() / test_all()）: 子进程 godot --script case_runner.gd -- <path>
##
## 退出约定（沿用旧版）：
##   全部通过 -> 打印 RUNTIME_SUITE_PASS 并 quit(0)
##   存在失败 -> 逐条 push_error 并打印 RUNTIME_SUITE_FAIL 并 quit(1)
##   扫描不到测试文件 -> 直接失败，绝不允许「0 个测试也算通过」

const SCAN_ROOTS := ["res://tests", "res://combat", "res://scripts"]
const SKIP_DIRS := [".godot", ".git", "addons", "bin", "build", "export", "docs", "assets"]
const TEST_PREFIX := "test_"
const TEST_SUFFIX := ".gd"
const CASE_RUNNER := "res://tests/case_runner.gd"
const TARGET_FILE := "user://case_runner_target.txt"

## 扫描下限：旧版本手工注册了 31 个测试。若某次扫描结果明显少于这个数，
## 说明扫描目录或命名约定被改坏了，必须让 CI 失败而不是静默少跑测试。
const MIN_EXPECTED_FILES := 31

## 子进程输出里出现这些字符串，即使退出码为 0 也判定为失败。
## 断言式测试（static run() 里写 assert()）失败时 Godot 不一定返回非零退出码，
## 但一定会在 stderr 留下这些痕迹。
const ERROR_MARKERS := ["ASSERTION FAILED", "Assertion failed", "SCRIPT ERROR", "Parse Error"]

const MAX_DETAIL := 260

## 排除名单：被自动扫描抓到、但无法在 headless CI 中安全执行的文件。
## 每个条目必须写明原因，不允许无理由静默跳过。
const EXCLUDED := {
	# 暂无
}

## 隔离名单：会照常执行并在日志里打印结果，但失败不计入退出码。
## 用途：已知失败的遗留测试先接入 CI 取得可见性，再由对应负责人修复并迁移到正式名单。
## 一旦某个文件被修复，请从这里删除，让它变成强制通过的测试。
const QUARANTINE := {
	"res://combat/test_character_mechanics.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_character_resources.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_combat.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_combat_party_builder_recruitment.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_combatant_status.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_encounter_manager.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_enemy_ai.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_enemy_skill_effects.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_longma_forms.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_longma_skill_runtime.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_narrative_battle_ui.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_origin_choice_combat.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_origin_choice_effects.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_origin_encounters.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_origin_route_content.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_party_formation.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_shared_chronology_all_routes.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_skill_runtime.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_skill_runtime_modifiers.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://combat/test_yellow_wind_boss.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/items/test_item_and_loadout_persistence.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_narrative_flow.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_narrative_state.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_origin_event_manager.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_origin_handoff.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_origin_route_manager.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_origin_routes.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_shared_events.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/narrative/test_shared_journey_data.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_bounty_encounter_state.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_bounty_manager.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_combat_encounter_handoff.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_origin_battle_handoff.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_world_map_manager.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_yellow_wind_cave_progress.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
	"res://scripts/world/test_yellow_wind_ridge.gd": "待评估：本批次新纳入，先在隔离态收集真实结果",
}


func _init() -> void:
	print("[scan] roots=%s" % str(SCAN_ROOTS))
	var files := _discover()
	var excluded_count := _count_listed(EXCLUDED, files)
	var quarantine_count := _count_listed(QUARANTINE, files)
	print("[scan] discovered=%d excluded=%d quarantine=%d" % [files.size(), excluded_count, quarantine_count])

	if files.is_empty():
		push_error("自动扫描未发现任何测试文件：扫描机制/目录/命名约定可能已失效")
		print("RUNTIME_SUITE_FAIL reason=no_test_files_discovered roots=%s" % str(SCAN_ROOTS))
		quit(1)
		return

	if files.size() < MIN_EXPECTED_FILES:
		push_error("扫描到的测试文件数 %d 少于下限 %d：扫描目录或命名约定可能被改动" % [files.size(), MIN_EXPECTED_FILES])
		print("RUNTIME_SUITE_FAIL reason=too_few_tests discovered=%d min=%d" % [files.size(), MIN_EXPECTED_FILES])
		quit(1)
		return

	if excluded_count > 0:
		print("[scan] 排除名单（不执行，原因已登记在 EXCLUDED）：%d 个" % excluded_count)

	var passed := 0
	var failed := 0
	var quarantined := 0
	var total_checks := 0
	var failures: Array[String] = []

	for path in files:
		if EXCLUDED.has(path):
			print("SKIP  %s reason=%s" % [path, str(EXCLUDED[path])])
			continue

		var in_quarantine: bool = QUARANTINE.has(path)
		print("RUN   %s" % path)
		var result := _run_file(path)
		total_checks += int(result.get("checks", 0))
		var ok: bool = bool(result.get("ok", false))
		var checks: int = int(result.get("checks", 0))
		var detail := _clip(str(result.get("detail", "")))

		if ok:
			passed += 1
			var tag := " (quarantine)" if in_quarantine else ""
			print("PASS  %s checks=%d%s" % [path, checks, tag])
			continue

		var line := "FAIL  %s checks=%d detail=%s" % [path, checks, detail]
		if in_quarantine:
			quarantined += 1
			print("QUARANTINE_FAIL %s reason=%s" % [line, str(QUARANTINE[path])])
		else:
			failed += 1
			failures.append(line)
			print(line)

	var summary := "files=%d passed=%d failed=%d quarantined=%d excluded=%d checks=%d" % [
		files.size(), passed, failed, quarantined, excluded_count, total_checks
	]
	if failed == 0:
		print("RUNTIME_SUITE_PASS %s" % summary)
		quit(0)
	else:
		for line in failures:
			push_error(line)
		print("RUNTIME_SUITE_FAIL %s" % summary)
		quit(1)


# ---------------------------------------------------------------- 扫描

func _discover() -> Array[String]:
	var found: Array[String] = []
	for root in SCAN_ROOTS:
		_walk(root, found)
	found.sort()
	return found


func _walk(dir_path: String, found: Array[String]) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		push_warning("[scan] 扫描目录不存在，已跳过：%s" % dir_path)
		return
	for file_name in DirAccess.get_files_at(dir_path):
		if not file_name.begins_with(TEST_PREFIX):
			continue
		if not file_name.ends_with(TEST_SUFFIX):
			continue
		found.append(dir_path.path_join(file_name))
	for dir_name in DirAccess.get_directories_at(dir_path):
		if dir_name.begins_with(".") or SKIP_DIRS.has(dir_name):
			continue
		_walk(dir_path.path_join(dir_name), found)


func _count_listed(table: Dictionary, files: Array[String]) -> int:
	var count := 0
	for path in files:
		if table.has(path):
			count += 1
	return count


# ---------------------------------------------------------------- 执行

func _run_file(path: String) -> Dictionary:
	var checks := _count_checks(path)
	var scr = load(path)
	if scr == null:
		return {"ok": false, "checks": checks, "detail": "脚本加载失败（语法错误或依赖缺失）"}

	if scr.has_method("run_all"):
		var result: Variant = scr.run_all()
		var ok: bool = result is Dictionary and bool((result as Dictionary).get("passed", false))
		return {"ok": ok, "checks": checks, "detail": "" if ok else str(result)}

	return _run_isolated(path, checks, scr)


func _run_isolated(path: String, checks: int, scr) -> Dictionary:
	var base := str(scr.get_instance_base_type())
	var is_main_loop_script: bool = (base == "SceneTree" or base == "MainLoop")

	var args := PackedStringArray([
		"--headless",
		# 兜底：子进程最多跑 300 次主循环迭代后自行退出。
		# 遗留测试里有些文件既不 quit() 也没有退出路径，没有它就会把 CI 挂到超时。
		"--quit-after", "300",
		"--path", ProjectSettings.globalize_path("res://"),
		"--script", path if is_main_loop_script else CASE_RUNNER,
	])
	if not is_main_loop_script:
		args.append("--")
		args.append(path)
		# 同时写入目标文件，供 case_runner 在命令行参数被吞掉时兜底使用
		var handle := FileAccess.open(TARGET_FILE, FileAccess.WRITE)
		if handle != null:
			handle.store_string(path)
			handle.close()

	var output: Array = []
	var exit_code := OS.execute(OS.get_executable_path(), args, output, true)
	var text := ""
	for chunk in output:
		text += str(chunk)

	var ok := exit_code == 0
	if ok:
		# 只看退出码不够：若子进程被 --quit-after 强制结束（测试挂死或提前退出），
		# 退出码同样可能是 0。因此 SceneTree 测试要求输出里有 PASSED（仓库既有约定），
		# 其它测试要求 case_runner 打印的机器可读标记。
		if is_main_loop_script:
			ok = text.find("PASSED") != -1
		else:
			ok = text.find("CASE_RUNNER_RESULT ok=1") != -1
	if ok:
		for marker in ERROR_MARKERS:
			if text.find(str(marker)) != -1:
				ok = false
				break

	return {"ok": ok, "checks": checks, "detail": "exit=%d base=%s %s" % [exit_code, base, _clip(text.strip_edges())]}


## 统计一个测试文件里的检查项数量：assert( / _assert( / _assert_equal( 的调用次数。
## 这是统一口径——仓库里存在 run_all / static run / SceneTree 三种测试写法，
## 只有用源码里的断言数才能给出可比的「用例数」。
func _count_checks(path: String) -> int:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		return 0
	return text.count("assert(") + text.count("_assert_equal(")


func _clip(text: String) -> String:
	var flat := text.replace("\n", " ").replace("\r", " ")
	if flat.length() <= MAX_DETAIL:
		return flat
	return flat.substr(0, MAX_DETAIL) + " ..."
