extends AnimatableBody3D
## test_hammer — kinematic giant hammer: wind-up pause, slam, squash shake.
## Content interface: apply_params / get_spawn_transforms / get_tags.
## Action interface (beats): trigger().

enum HammerState { IDLE, WIND, SLAM, HOLD, RETURN }

const H_REST := 7.0
const H_TOP := 9.5
const H_LOW := 0.9

var h_state: HammerState = HammerState.IDLE
var h_t := 0.0
var _swing_mode := false
var _swing_t := 0.0
var _swing_speed := 2.0  # oscillations per second (sine)
var sfx_boom: AudioStreamPlayer
var sfx_whistle: AudioStreamPlayer


func _ready() -> void:
	add_to_group("destroyer")
	sync_to_physics = true
	var cs := CollisionShape3D.new()
	var shp := BoxShape3D.new()
	shp.size = Vector3(4.0, 1.6, 2.0)
	cs.shape = shp
	add_child(cs)
	var head := MeshInstance3D.new()
	var hm := BoxMesh.new()
	hm.size = shp.size
	head.mesh = hm
	head.material_override = _mat(Color(0.6, 0.6, 0.65))
	add_child(head)
	var handle := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.18
	cm.bottom_radius = 0.18
	cm.height = 6.0
	cm.radial_segments = 12
	handle.mesh = cm
	handle.material_override = _mat(Color(0.55, 0.35, 0.18))
	handle.position = Vector3(0, 3.8, 0)
	add_child(handle)
	sfx_boom = AudioStreamPlayer.new()
	sfx_boom.bus = "SFX"
	sfx_boom.stream = _make_boom()
	add_child(sfx_boom)
	sfx_whistle = AudioStreamPlayer.new()
	sfx_whistle.bus = "SFX"
	sfx_whistle.stream = _make_whistle()
	add_child(sfx_whistle)


func apply_params(params: Dictionary) -> void:
	if params.has("position"):
		position = params["position"]
	if str(params.get("mode", "")) == "swing":
		_swing_mode = true
		_setup_swing()


func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]


func get_tags() -> Array:
	return ["test", "hammer"]


func trigger() -> void:
	if h_state != HammerState.IDLE:
		return
	h_state = HammerState.WIND
	h_t = 0.0
	sfx_whistle.play()


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


var _base_y := 3.5

func _setup_swing() -> void:
	# piston mode: hammer bobs up/down on a sine wave
	# characters walking under get smashed when it's down
	_base_y = position.y

func _physics_process(delta: float) -> void:
	if _swing_mode:
		_swing_t += delta
		# sine piston: y oscillates between base-amp and base+amp
		# at bottom, head hits characters; at top, they pass under
		var y := _base_y + sin(_swing_t * _swing_speed) * 2.5
		position.y = y
		# thump when reaching bottom
		var prev_sin := sin((_swing_t - delta) * _swing_speed)
		var cur_sin := sin(_swing_t * _swing_speed)
		if prev_sin > -0.95 and cur_sin <= -0.95:
			_cam_shake(0.4)
			sfx_boom.play()
		return
	var y := position.y
	match h_state:
		HammerState.WIND:
			h_t += delta
			var k := clampf(h_t / 0.6, 0.0, 1.0)
			y = lerpf(H_REST, H_TOP, smoothstep(0.0, 1.0, k))
			if k >= 1.0:
				h_state = HammerState.SLAM
				h_t = 0.0
		HammerState.SLAM:
			h_t += delta
			var k := clampf(h_t / 0.16, 0.0, 1.0)
			y = lerpf(H_TOP, H_LOW, k * k)
			if k >= 1.0:
				h_state = HammerState.HOLD
				h_t = 0.0
				sfx_boom.play()
				_cam_shake(0.55)
		HammerState.HOLD:
			h_t += delta
			if h_t >= 0.5:
				h_state = HammerState.RETURN
				h_t = 0.0
		HammerState.RETURN:
			h_t += delta
			var k := clampf(h_t / 1.2, 0.0, 1.0)
			y = lerpf(H_LOW, H_REST, smoothstep(0.0, 1.0, k))
			if k >= 1.0:
				h_state = HammerState.IDLE
	position.y = y
# ---------- procedural audio ----------

func _wav(data: PackedByteArray, rate: int) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = data
	return w


func _make_boom() -> AudioStreamWAV:
	var rate := 44100
	var n := int(rate * 0.7)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var t := float(i) / float(n)
		var f := lerpf(160.0, 30.0, sqrt(t))
		phase += TAU * f / float(rate)
		var s := (sin(phase) * 0.8 + randf_range(-1.0, 1.0) * 0.5 * exp(-25.0 * t)) * exp(-6.0 * t)
		data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 30000.0))
	return _wav(data, rate)


func _make_whistle() -> AudioStreamWAV:
	var rate := 44100
	var n := int(rate * 0.6)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var t := float(i) / float(n)
		var f := lerpf(500.0, 1500.0, t)
		phase += TAU * f / float(rate)
		var s := sin(phase) * sin(PI * t) * 0.4
		data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 30000.0))
	return _wav(data, rate)

func _cam_shake(amount: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam != null and cam.has_method("add_shake"):
		cam.add_shake(amount)
