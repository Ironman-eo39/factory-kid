class_name CameraDirector
extends Camera3D
## CameraDirector — preset camera angles + timed cuts + impulse shake.
## Modes: "wide" (default overview), "low" (dramatic low angle),
## "follow" (tracks a target node, e.g. the destroyer).
## Configured from the preset's "camera" dict:
##   {"mode": "wide", "cuts": [{"t": 3.0, "mode": "low"},
##                            {"t": 6.0, "mode": "follow", "target": "destroyer"}]}
## Destroyers call add_shake(amount) on slam; trauma decays exponentially.

const WIDE_POS := Vector3(0, 8.5, 10.0)
const WIDE_LOOK := Vector3(0, 0.5, -3.5)
const LOW_POS := Vector3(0, 1.6, 9.0)
const LOW_LOOK := Vector3(0, 2.5, -6.0)
const FOLLOW_OFFSET := Vector3(5.5, 4.5, 8.5)

var mode := "wide"
var _target: Node3D = null
var _targets: Dictionary = {}
var _cuts: Array = []
var _cut_idx := 0
var _elapsed := 0.0
var _trauma := 0.0
var _look := Vector3(0, 1, -2)


func configure(cam_cfg: Dictionary, targets: Dictionary) -> void:
	_targets = targets
	_cuts = cam_cfg.get("cuts", [])
	_cut_idx = 0
	_elapsed = 0.0
	_trauma = 0.0
	set_mode(str(cam_cfg.get("mode", "wide")), str(cam_cfg.get("target", "")))
	# snap immediately on first configure
	position = _desired_pos()
	_look = _desired_look()
	_apply()


func set_mode(m: String, target_name: String = "") -> void:
	mode = m
	if target_name != "" and _targets.has(target_name):
		_target = _targets[target_name] as Node3D
	elif mode != "follow":
		_target = null
	if mode == "follow" and _target == null and _targets.has("destroyer"):
		_target = _targets["destroyer"] as Node3D


func add_shake(amount: float) -> void:
	_trauma = minf(1.0, _trauma + amount)


func _process(delta: float) -> void:
	_elapsed += delta
	while _cut_idx < _cuts.size() and _elapsed >= float((_cuts[_cut_idx] as Dictionary).get("t", 0.0)):
		var c: Dictionary = _cuts[_cut_idx]
		set_mode(str(c.get("mode", "wide")), str(c.get("target", "")))
		_cut_idx += 1
	var k := 1.0 - exp(-4.5 * delta)
	position = position.lerp(_desired_pos(), k)
	_look = _look.lerp(_desired_look(), k)
	_apply()
	if _trauma > 0.0:
		_trauma = maxf(0.0, _trauma - delta * 1.6)
		var s := _trauma * _trauma * 22.0
		h_offset = randf_range(-s, s)
		v_offset = randf_range(-s, s)
	else:
		h_offset = 0.0
		v_offset = 0.0


func _desired_pos() -> Vector3:
	match mode:
		"low":
			return LOW_POS
		"follow":
			if is_instance_valid(_target):
				return _target.global_position + FOLLOW_OFFSET
			return WIDE_POS
	return WIDE_POS


func _desired_look() -> Vector3:
	match mode:
		"low":
			return LOW_LOOK
		"follow":
			if is_instance_valid(_target):
				return _target.global_position + Vector3(0, 1.0, 0)
			return WIDE_LOOK
	return WIDE_LOOK


func _apply() -> void:
	if (position - _look).length() > 0.01:
		look_at(_look)
