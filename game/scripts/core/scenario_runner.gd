extends Node3D
## ScenarioRunner — main scene. Reads a preset JSON, assembles content
## modules via ContentRegistry, fires timeline beats, quits at the end.
## Usage: godot --path game -- --preset=res://presets/quick_test.json
## A new video = a new JSON file. No code changes (RULES #6, ADR-004).
## Schema v2: adds "version", "seed", "camera.path", "overlays".

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
var _first_cast: Node3D = null


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
	if _preset.has("seed"):
		seed(int(_preset["seed"]))
		print("[runner] seed=%d" % int(_preset["seed"]))
	_assemble()
	_wire_camera()
	_wire_music()
	_setup_overlays()
	_beats = _preset.get("beats", [])
	print("[runner] preset=%s duration=%.1f beats=%d" % [preset_path, _duration, _beats.size()])

var _overlays: Array = []
var _overlay_layer: CanvasLayer = null

func _setup_overlays() -> void:
	_overlays = _preset.get("overlays", [])
	if _overlays.is_empty():
		return
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 10
	add_child(_overlay_layer)
	for ov in _overlays:
		var o: Dictionary = ov
		var lbl := Label.new()
		lbl.text = str(o.get("text", ""))
		lbl.visible = false
		# 1080x1920 portrait: big bold centered text
		lbl.add_theme_font_size_override("font_size", int(o.get("size", 72)))
		lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		lbl.add_theme_constant_override("outline_size", 12)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.position = Vector2(0, float(o.get("y", 400)))
		lbl.size = Vector2(1080, 200)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_overlay_layer.add_child(lbl)
		o["_node"] = lbl

func _update_overlays() -> void:
	for ov in _overlays:
		var o: Dictionary = ov
		var lbl: Label = o.get("_node")
		if lbl == null:
			continue
		var t0 := float(o.get("t", 0.0))
		var dur := float(o.get("duration", 2.0))
		lbl.visible = _t >= t0 and _t < t0 + dur

func _wire_music() -> void:
	var m: Dictionary = _preset.get("music", {})
	if m.has("chant"):
		AudioSynth.play_chant(str(m["chant"]), float(m.get("volume_db", -10.0)))


func _wire_camera() -> void:
	var dir := get_tree().get_first_node_in_group("camera_director")
	if dir != null and dir.has_method("configure"):
		dir.configure(_preset.get("camera", {}), {"destroyer": _destroyer, "cast": _first_cast})


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
	for oi in _preset.get("obstacles", []).size():
		var ob: Dictionary = _preset["obstacles"][oi]
		var ob_params: Dictionary = _normalize_params((ob.get("params", {}) as Dictionary).duplicate())
		var ob_node := ContentRegistry.spawn(str(ob.get("id", "")), ob_params, self)
		if ob_node != null:
			ob_node.name = "Obstacle%d" % oi
	for roster in _preset.get("rosters", []):
		var count := int(roster.get("count", 0))
		var positions := _grid_positions(count)
		if str(roster.get("layout", "")) == "procession":
			positions = _procession_positions(count, roster)
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
				if _first_cast == null:
					_first_cast = b


## Preset JSON carries Vector3s as [x, y, z] arrays — normalize once here
## so content modules never deal with raw JSON types.
func _normalize_params(p: Dictionary) -> Dictionary:
	if p.has("position"):
		var v: Variant = p["position"]
		if v is Array and (v as Array).size() == 3:
			var a: Array = v
			p["position"] = Vector3(float(a[0]), float(a[1]), float(a[2]))
	return p


func _procession_positions(count: int, roster: Dictionary) -> Array:
	# staggered along the road (Z axis), one after another
	var out: Array = []
	var spacing := float(roster.get("spacing", 4.0))
	var x := float(roster.get("lane_x", 0.0))
	var start_z := float(roster.get("start_z", -14.0))
	for i in count:
		out.append(Vector3(x + randf_range(-0.5, 0.5), 0.65, start_z - i * spacing))
	return out


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
	_update_overlays()
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
