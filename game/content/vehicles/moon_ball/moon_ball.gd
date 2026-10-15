extends RigidBody3D
## moon_ball — sphere-body car with 4 wheels and a cartoon face.
## Hard hits (>7 m/s) swap the face to dizzy for 2 s + squash.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const BODY_R := 0.8
const HARD_HIT_SPEED := 7.0
const DIZZY_TIME := 2.0

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _default_tint := Color(1.0, 0.55, 0.15)
var _visual: Node3D
var _face_mat: StandardMaterial3D
var _wheels: Array[MeshInstance3D] = []
var _prev_vel := Vector3.ZERO
var _dizzy := false


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = _default_tint
	contact_monitor = true
	max_contacts_reported = 4
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.45
	pm.friction = 0.5
	physics_material_override = pm
	var cs := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = BODY_R
	cs.shape = sph
	add_child(cs)
	_visual = Node3D.new()
	_visual.name = "Vis"
	add_child(_visual)
	_build_visual()
	body_entered.connect(_on_body_entered)


func apply_params(params: Dictionary) -> void:
	# NOTE: called by ContentRegistry BEFORE the node enters the tree.
	if params.has("position"):
		position = params["position"]
	if params.has("tint"):
		_tint = params["tint"]


func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]


func get_tags() -> Array:
	return ["vehicle", "moon-ball"]


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _build_visual() -> void:
	var body_mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = BODY_R
	sm.height = BODY_R * 2.0
	sm.radial_segments = 20
	sm.rings = 10
	body_mi.mesh = sm
	body_mi.material_override = _mat(_tint)
	_visual.add_child(body_mi)
	# 4 wheels
	var wm := CylinderMesh.new()
	wm.top_radius = 0.28
	wm.bottom_radius = 0.28
	wm.height = 0.22
	wm.radial_segments = 12
	var hub_m := CylinderMesh.new()
	hub_m.top_radius = 0.12
	hub_m.bottom_radius = 0.12
	hub_m.height = 0.24
	hub_m.radial_segments = 8
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			wheel.mesh = wm
			wheel.material_override = _mat(Color(0.12, 0.12, 0.14))
			wheel.position = Vector3(sx * 0.62, -0.5, sz * 0.55)
			wheel.rotation_degrees = Vector3(0, 0, 90)
			_visual.add_child(wheel)
			_wheels.append(wheel)
			var hub := MeshInstance3D.new()
			hub.mesh = hub_m
			hub.material_override = _mat(Color(0.85, 0.85, 0.88))
			hub.position = Vector3.ZERO  # child of wheel: centered, not re-offset
			wheel.add_child(hub)
	# face decal
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1.0, 1.0)
	face.mesh = quad
	_face_mat = StandardMaterial3D.new()
	_face_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_face_mat.albedo_texture = FaceDecal.make_texture("happy")
	_face_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_face_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_face_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	face.material_override = _face_mat
	face.position = Vector3(0, 0.12, BODY_R - 0.02)
	_visual.add_child(face)


func _physics_process(delta: float) -> void:
	# spin wheels with rolling speed
	var planar := Vector2(linear_velocity.x, linear_velocity.z).length()
	for w in _wheels:
		w.rotation.x += planar / 0.28 * delta
	_prev_vel = linear_velocity


func _on_body_entered(body: Node) -> void:
	var hard := _prev_vel.length() >= HARD_HIT_SPEED
	if body.is_in_group("destroyer") or hard:
		_squash()
	if hard and not _dizzy:
		_go_dizzy()


func _squash() -> void:
	if _visual.has_meta("squashing"):
		return
	_visual.set_meta("squashing", true)
	var tw := _visual.create_tween()
	tw.tween_property(_visual, "scale", Vector3(1.35, 0.45, 1.35), 0.08)
	tw.tween_property(_visual, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_visual.remove_meta.bind("squashing"))


func _go_dizzy() -> void:
	_dizzy = true
	_face_mat.albedo_texture = FaceDecal.make_texture("dizzy")
	await get_tree().create_timer(DIZZY_TIME).timeout
	_face_mat.albedo_texture = FaceDecal.make_texture("happy")
	_dizzy = false
