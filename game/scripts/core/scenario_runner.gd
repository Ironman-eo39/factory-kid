extends Node3D
## ScenarioRunner — main scene. Reads a preset JSON, assembles content
## modules via ContentRegistry, fires timeline beats, quits at the end.
## Usage: godot --path game -- --preset=res://presets/quick_test.json
## A new video = a new JSON file. No code changes (RULES #6, ADR-004).

const PALETTE: Array[Color] = [
	Color(1, 0.2, 0.3), Color(0.2, 0.8, 0.3), Color(0.2, 0.4, 1.0), Color(1, 0.85, 0.1),
	Color(0.8, 0.3, 1.0), Color(0.1, 0.85, 0.9), Color(1, 0.5, 0.1), Color(1, 0.5, 0.8),
]

var _preset: Dictionary = {}
var _t := 0.0
var _beats: Array = []
var _fired: Array = []
var _duration := 8.0
var _destroyer: Node = null


func _ready() -> void:
	var preset_path := "res://presets/quick_test.json"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--preset="):
			preset_path = a.get_slice("=", 1)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(preset_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("ScenarioRunner: bad preset JSON: %s" % preset_path)
		get_tree().quit(1)
		return
	_preset = parsed
	_duration = float(_preset.get("duration", 8.0))
	_assemble()
	_beats = _preset.get("beats", [])
	print("[runner] preset=%s duration=%.1f beats=%d" % [preset_path, _duration, _beats.size()])


func _assemble() -> void:
	var arena: Dictionary = _preset.get("arena", {})
	var arena_params: Dictionary = _normalize_params((arena.get("params", {}) as Dictionary).duplicate())
	var arena_node := ContentRegistry.spawn(str(arena.get("id", "")), arena_params, self)
	if arena_node != null:
		arena_node.name = "Arena"
	var d: Dictionary = _preset.get("destroyer", {})
	var d_params: Dictionary = _normalize_params((d.get("params", {}) as Dictionary).duplicate())
	_destroyer = ContentRegistry.spawn(str(d.get("id", "")), d_params, self)
	if _destroyer != null:
		_destroyer.name = "Destroyer"
	for roster in _preset.get("rosters", []):
		var count := int(roster.get("count", 0))
		var positions := _grid_positions(count)
		var offset := Vector3.ZERO
		if roster.has("offset"):
			var o: Variant = roster["offset"]
			if o is Array and (o as Array).size() == 3:
				var a: Array = o
				offset = Vector3(float(a[0]), float(a[1]), float(a[2]))
		for i in positions.size():
			var p: Dictionary = _normalize_params((roster.get("params", {}) as Dictionary).duplicate())
			if not p.has("tint") and str(roster.get("id", "")) == "test_ball":
				p["tint"] = PALETTE[i % PALETTE.size()]
			var b := ContentRegistry.spawn(str(roster.get("id", "")), p, self)
			if b != null:
				b.position = positions[i] + offset


## Preset JSON carries Vector3s as [x, y, z] arrays — normalize once here
## so content modules never deal with raw JSON types.
func _normalize_params(p: Dictionary) -> Dictionary:
	if p.has("position"):
		var v: Variant = p["position"]
		if v is Array and (v as Array).size() == 3:
			var a: Array = v
			p["position"] = Vector3(float(a[0]), float(a[1]), float(a[2]))
	return p


func _grid_positions(count: int) -> Array:
	var out: Array = []
	var cols := 6
	for i in count:
		var col := i % cols
		var row := floori(float(i) / float(cols))
		out.append(Vector3((col - (cols - 1) * 0.5) * 1.3, 0.65, 2.0 - row * 1.4))
	return out


func _physics_process(delta: float) -> void:
	_t += delta
	for bi in _beats.size():
		if _fired.has(bi):
			continue
		var beat: Dictionary = _beats[bi]
		if _t >= float(beat.get("t", 0.0)):
			_fired.append(bi)
			_fire_beat(beat)
	if _t >= _duration:
		get_tree().quit()


func _fire_beat(beat: Dictionary) -> void:
	var target_name := str(beat.get("target", ""))
	var action := str(beat.get("action", ""))
	var target: Node = null
	if target_name == "destroyer":
		target = _destroyer
	else:
		target = get_node_or_null(target_name)
	if target != null and target.has_method(action):
		target.call(action)
		print("[runner] beat t=%.1f %s.%s()" % [_t, target_name, action])
	else:
		push_warning("[runner] beat missed: %s.%s" % [target_name, action])
