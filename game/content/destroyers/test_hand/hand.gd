extends AnimatableBody3D
## test_hand — giant slap-hand destroyer.
## trigger(): 0.6s wind-up (rise + whistle) -> 0.14s slap -> 0.8s squish-hold
## -> 1.0s rise. Procedural audio: whistle + deep fleshy thud.
## Content interface: trigger / apply_params / get_spawn_transforms / get_tags.

enum HandState { IDLE, WIND, SLAM, HOLD, RETURN }

const H_REST := 7.0
const H_WIND := 8.5
const H_LOW := 0.75
const T_WIND := 0.6
const T_SLAM := 0.14
const T_HOLD := 0.8
const T_RETURN := 1.0

const SKIN := Color(1.0, 0.78, 0.6)
const SKIN_DARK := Color(0.92, 0.68, 0.5)

var h_state: int = HandState.IDLE
var h_t := 0.0
var shake := 0.0


func _ready() -> void:
	add_to_group("destroyer")
	sync_to_physics = true
	# collision: palm + fingers
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.4, 1.0, 4.4)
	cs.shape = box
	add_child(cs)
	# palm
	var palm := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(3.2, 0.7, 2.6)
	palm.mesh = pm
	palm.material_override = _mat(SKIN)
	palm.position = Vector3(0, 0, -0.6)
	add_child(palm)
	# 4 fingers
	for i in 4:
		var f := MeshInstance3D.new()
		var fm := BoxMesh.new()
		fm.size = Vector3(0.6, 0.55, 1.5)
		f.mesh = fm
		f.material_override = _mat(SKIN)
		f.position = Vector3(-1.2 + float(i) * 0.8, -0.05, 1.45)
		add_child(f)
	# thumb
	var th := MeshInstance3D.new()
	var tm := BoxMesh.new()
	tm.size = Vector3(1.1, 0.5, 0.55)
	th.mesh = tm
	th.material_override = _mat(SKIN_DARK)
	th.position = Vector3(2.0, -0.05, -0.3)
	th.rotation_degrees = Vector3(0, 25, 0)
	add_child(th)
	# wrist
	var wrist := MeshInstance3D.new()
	var wm := CylinderMesh.new()
	wm.top_radius = 0.75
	wm.bottom_radius = 0.9
	wm.height = 5.0
	wm.radial_segments = 10
	wrist.mesh = wm
	wrist.material_override = _mat(SKIN_DARK)
	wrist.position = Vector3(0, 3.2, -1.2)
	add_child(wrist)


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func apply_params(params: Dictionary) -> void:
	if params.has("position"):
		position = params["position"]


func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]


func get_tags() -> Array:
	return ["destroyer", "hand"]


func trigger() -> void:
	if h_state == HandState.IDLE:
		h_state = HandState.WIND
		h_t = 0.0
		_whistle()


func _physics_process(delta: float) -> void:
	if h_state == HandState.IDLE:
		return
	h_t += delta
	var y := position.y
	match h_state:
		HandState.WIND:
			var k := clampf(h_t / T_WIND, 0.0, 1.0)
			y = lerpf(H_REST, H_WIND, k * k)
			if h_t >= T_WIND:
				h_state = HandState.SLAM
				h_t = 0.0
		HandState.SLAM:
			var k := clampf(h_t / T_SLAM, 0.0, 1.0)
			y = lerpf(H_WIND, H_LOW, k * k * k)
			if h_t >= T_SLAM:
				h_state = HandState.HOLD
				h_t = 0.0
				shake = 0.5
				_thud()
		HandState.HOLD:
			y = H_LOW
			if h_t >= T_HOLD:
				h_state = HandState.RETURN
				h_t = 0.0
		HandState.RETURN:
			var k := clampf(h_t / T_RETURN, 0.0, 1.0)
			y = lerpf(H_LOW, H_REST, k * k * (3.0 - 2.0 * k))
			if h_t >= T_RETURN:
				h_state = HandState.IDLE
				y = H_REST
	position.y = y
	if shake > 0.0:
		shake = maxf(0.0, shake - delta * 1.4)
		var cam := get_viewport().get_camera_3d()
		if cam != null:
			cam.h_offset = randf_range(-1.0, 1.0) * shake * 12.0
			cam.v_offset = randf_range(-1.0, 1.0) * shake * 12.0
			if shake <= 0.0:
				cam.h_offset = 0.0
				cam.v_offset = 0.0


func _whistle() -> void:
	var sr := 22050
	var n := int(sr * T_WIND)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / float(n)
		var f := lerpf(500.0, 1500.0, t)
		var s := sin(TAU * f * float(i) / sr) * 0.25 * (1.0 - t * 0.4)
		var v := int(clampf(s, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	_play(data, sr)


func _thud() -> void:
	var sr := 22050
	var dur := 0.6
	var n := int(sr * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / float(n)
		var f := lerpf(130.0, 28.0, t)
		var s := sin(TAU * f * float(i) / sr) * 0.85 * (1.0 - t) ** 2.0
		var v := int(clampf(s, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	_play(data, sr)


func _play(data: PackedByteArray, sr: int) -> void:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	stream.data = data
	var p := AudioStreamPlayer3D.new()
	p.stream = stream
	p.unit_size = 6.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
