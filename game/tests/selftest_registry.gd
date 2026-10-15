extends SceneTree
## TASK-101 acceptance test: registry validates an empty tree, flags bad
## modules, registers good ones, and spawns with params.
## Run: godot --headless --path game -s res://tests/selftest_registry.gd

var _failures := 0


func _check(cond: bool, label: String) -> void:
	if cond:
		print("  PASS: ", label)
	else:
		_failures += 1
		print("  FAIL: ", label)


func _initialize() -> void:
	var reg_script := load("res://scripts/core/content_registry.gd")

	print("[selftest] 1. empty content tree validates clean")
	var r1: Node = reg_script.new()
	var e1: Array = r1.validate_all("res://tests/fixtures/empty_content")
	_check(e1.is_empty(), "empty tree: no errors")
	_check(r1.module_count() == 0, "empty tree: 0 modules")
	r1.free()

	print("[selftest] 2. mixed fixtures: good registered, bad flagged")
	var r2: Node = reg_script.new()
	var e2: Array = r2.validate_all("res://tests/fixtures/mods")
	_check(not e2.is_empty(), "bad module produced errors")
	_check(r2.module_count() == 1, "exactly 1 good module registered")
	_check(r2.list_modules() == ["good_arena"], "good_arena listed")
	_check(r2.list_modules("arenas") == ["good_arena"], "type filter works")
	_check(r2.list_modules("vehicles").is_empty(), "bad_car not registered")

	print("[selftest] 3. spawn with params")
	var spawned: Node = r2.spawn("good_arena", {"tint": Color.RED}, root)
	_check(spawned != null, "spawn returned a node")
	_check(spawned.get_meta("tint") == Color.RED, "apply_params received params")
	var missing: Node = r2.spawn("nope_missing")
	_check(missing == null, "unknown module -> null + error")
	r2.free()

	if _failures == 0:
		print("[selftest] ALL PASS")
	else:
		print("[selftest] %d FAILURES" % _failures)
	quit(_failures)
