class_name CameraDirector
extends Camera3D
## CameraDirector — preset camera angles + timed cuts + impulse shake.
## Modes: "wide" (overview), "low" (dramatic low), "follow" (tracks target),
## "closeup" (near character), "topdown" (bird's eye), "side" (profile),
## "orbit" (circles around target).
## Configured from the preset's "camera" dict (schema v2):
##   {"mode": "wide", "path": [{"t": 0.0, "pos": [...], "look": [...]},
##                            {"t": 5.0, "pos": [...], "look": [...]}],
##    "cuts": [...]}
##   {"mode": "wide", "cuts": [{"t": 3.0, "mode": "low"},
##                            {"t": 6.0, "mode": "follow", "target": "destroyer"}]}
## Destroyers call add_shake(amount) on slam; trauma decays exponentially.

const WIDE_POS := Vector3(0, 8.5, 10.0)
const WIDE_LOOK := Vector3(0, 0.5, -3.5)
const LOW_POS := Vector3(0, 1.6, 9.0)
const LOW_LOOK := Vector3(0, 2.5, -6.0)
const FOLLOW_OFFSET := Vector3(5.5, 4.5, 8.5)
const CLOSEUP_POS := Vector3(0, 2.0, 5.0)
const CLOSEUP_LOOK := Vector3(0, 1.5, 0)
const TOPDOWN_POS := Vector3(0, 18.0, 2.0)
const TOPDOWN_LOOK := Vector3(0, 0, -2.0)
const SIDE_POS := Vector3(10.0, 3.0, 0)
const SIDE_LOOK := Vector3(0, 1.5, 0)

var mode := "wide"
var _target: Node3D = null
var _targets: Dictionary = {}
var _cuts: Array = []
var _cut_idx := 0
var _elapsed := 0.0
var _trauma := 0.0
var _look := Vector3(0, 1, -2)
var _orbiting := false
var _orbit_speed := 0.5
var _orbit_radius := 10.0
var _orbit_height := 5.0
var _path: Array = []
var _path_idx := 0


func configure(cam_cfg: Dictionary, targets: Dictionary) -> void:
	_targets = targets
	_cuts = cam_cfg.get("cuts", [])
	_cut_idx = 0
	_path = cam_cfg.get("path", [])
	_path_idx = 0
	_elapsed = 0.0
	_trauma = 0.0
	set_mode(str(cam_cfg.get("mode", "wide")), str(cam_cfg.get("target", "")))
	# snap immediately on first configure
	position = _desired_pos()
	_look = _desired_look()
	_apply()


func set_mode(m: String, target_name: String = "") -> void:
	mode = m
	_orbiting = (m == "orbit")
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
	_update_path()
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


func _update_path() -> void:
	if _path.is_empty():
		return
	# advance to current segment
	while _path_idx < _path.size() - 1:
		var nxt: Dictionary = _path[_path_idx + 1]
		if _elapsed >= float(nxt.get("t", 0.0)):
			_path_idx += 1
		else:
			break
	# interpolate within segment
	if _path_idx < _path.size() - 1:
		var a: Dictionary = _path[_path_idx]
		var b: Dictionary = _path[_path_idx + 1]
		var t0 := float(a.get("t", 0.0))
		var t1 := float(b.get("t", 1.0))
		var f := clampf((_elapsed - t0) / maxf(t1 - t0, 0.001), 0.0, 1.0)
		var pa := _vec(a.get("pos", [0, 8.5, 10.0]))
		var pb := _vec(b.get("pos", [0, 8.5, 10.0]))
		var la := _vec(a.get("look", [0, 0.5, -3.5]))
		var lb := _vec(b.get("look", [0, 0.5, -3.5]))
		position = pa.lerp(pb, f)
		_look = la.lerp(lb, f)


func _vec(v) -> Vector3:
	if v is Array and (v as Array).size() == 3:
		var a: Array = v
		return Vector3(float(a[0]), float(a[1]), float(a[2]))
	return Vector3.ZERO


func _desired_pos() -> Vector3:
	match mode:
		"low":
			return LOW_POS
		"closeup":
			if is_instance_valid(_target):
				return _target.global_position + Vector3(0, 1.0, 4.0)
			return CLOSEUP_POS
		"topdown":
			return TOPDOWN_POS
		"side":
			return SIDE_POS
		"orbit":
			var a := _elapsed * _orbit_speed
			var cx := 0.0
			var cz := -2.0
			if is_instance_valid(_target):
				cx = _target.global_position.x
				cz = _target.global_position.z
			return Vector3(cx + cos(a) * _orbit_radius, _orbit_height, cz + sin(a) * _orbit_radius)
		"follow":
			if is_instance_valid(_target):
				return _target.global_position + FOLLOW_OFFSET
			return WIDE_POS
	return WIDE_POS


func _desired_look() -> Vector3:
	match mode:
		"low":
			return LOW_LOOK
		"closeup":
			if is_instance_valid(_target):
				return _target.global_position + Vector3(0, 1.2, 0)
			return CLOSEUP_LOOK
		"topdown":
			return TOPDOWN_LOOK
		"side":
			return SIDE_LOOK
		"orbit":
			if is_instance_valid(_target):
				return _target.global_position + Vector3(0, 1.0, 0)
			return Vector3(0, 1, -2)
		"follow":
			if is_instance_valid(_target):
				return _target.global_position + Vector3(0, 1.0, 0)
			return WIDE_LOOK
	return WIDE_LOOK


func _apply() -> void:
	if (position - _look).length() > 0.01:
		look_at(_look)
