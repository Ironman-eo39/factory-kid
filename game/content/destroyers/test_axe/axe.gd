extends AnimatableBody3D
## test_axe — giant battle axe destroyer.
## trigger(): 0.6s wind-up (rise + whistle) -> 0.12s slam -> 0.5s hold -> 1.0s rise.
## Procedural audio: fast rising whistle + sharp metallic boom.
## Content interface: trigger / apply_params / get_spawn_transforms / get_tags.

enum AxeState { IDLE, WIND, SLAM, HOLD, RETURN }

const H_REST := 7.0
const H_WIND := 9.0
const H_LOW := 0.9
const T_WIND := 0.6
const T_SLAM := 0.12
const T_HOLD := 0.5
const T_RETURN := 1.0

var h_state: int = AxeState.IDLE
var h_t := 0.0
var shake := 0.0


func _ready() -> void:
	add_to_group("destroyer")
	sync_to_physics = true
	# collision: blade span
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.6, 1.8, 0.7)
	cs.shape = box
	add_child(cs)
	# handle
	var handle := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.14
	cyl.bottom_radius = 0.14
	cyl.height = 8.0
	cyl.radial_segments = 10
	handle.mesh = cyl
	handle.material_override = _mat(Color(0.45, 0.28, 0.15))
	handle.position = Vector3(0, 4.0, 0)
	add_child(handle)
	# central head block
	var block := MeshInstance3D.new()
	var bb := BoxMesh.new()
	bb.size = Vector3(0.6, 1.7, 0.5)
	block.mesh = bb
	block.material_override = _mat(Color(0.55, 0.58, 0.62))
	add_child(block)
	# twin blades
	for sx in [-1.0, 1.0]:
		var blade := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.5, 1.5, 0.28)
		blade.mesh = bm
		blade.material_override = _mat(Color(0.75, 0.78, 0.82))
		blade.position = Vector3(sx * 1.0, -0.1, 0)
		blade.rotation_degrees = Vector3(0, 0, sx * -18.0)
		add_child(blade)
	# pommel
	var pommel := MeshInstance3D.new()
	var pm := SphereMesh.new()
	pm.radius = 0.25
	pm.height = 0.5
	pommel.mesh = pm
	pommel.material_override = _mat(Color(0.8, 0.6, 0.2))
	pommel.position = Vector3(0, 8.1, 0)
	add_child(pommel)


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
	return ["destroyer", "axe"]


func trigger() -> void:
	if h_state == AxeState.IDLE:
		h_state = AxeState.WIND
		h_t = 0.0
		_whistle()


func _physics_process(delta: float) -> void:
	if h_state == AxeState.IDLE:
		return
	h_t += delta
	var y := position.y
	match h_state:
		AxeState.WIND:
			var k := clampf(h_t / T_WIND, 0.0, 1.0)
			y = lerpf(H_REST, H_WIND, k * k)
			if h_t >= T_WIND:
				h_state = AxeState.SLAM
				h_t = 0.0
		AxeState.SLAM:
			var k := clampf(h_t / T_SLAM, 0.0, 1.0)
			y = lerpf(H_WIND, H_LOW, k * k * k)
			if h_t >= T_SLAM:
				h_state = AxeState.HOLD
				h_t = 0.0
				shake = 0.5
				_boom()
		AxeState.HOLD:
			y = H_LOW
			if h_t >= T_HOLD:
				h_state = AxeState.RETURN
				h_t = 0.0
		AxeState.RETURN:
			var k := clampf(h_t / T_RETURN, 0.0, 1.0)
			y = lerpf(H_LOW, H_REST, k * k * (3.0 - 2.0 * k))
			if h_t >= T_RETURN:
				h_state = AxeState.IDLE
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
		var f := lerpf(700.0, 2100.0, t)
		var s := sin(TAU * f * float(i) / sr) * 0.25 * (1.0 - t * 0.4)
		var v := int(clampf(s, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	_play(data, sr)


func _boom() -> void:
	var sr := 22050
	var dur := 0.5
	var n := int(sr * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / float(n)
		var f := lerpf(300.0, 45.0, t)
		var s := sin(TAU * f * float(i) / sr) * 0.8 * (1.0 - t) ** 2.0
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
