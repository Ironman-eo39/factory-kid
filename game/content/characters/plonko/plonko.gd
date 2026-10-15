extends RigidBody3D
## plonko — original brainrot-archetype character (wooden log + paddle club).
## Own name, own geometry; see DIFFERENCE_LOG.md in this module folder.
## Idle bob animation via looping tween; squash on destroyer hit.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const WOOD := Color(0.72, 0.5, 0.3)
const WOOD_DARK := Color(0.55, 0.36, 0.2)
const TEAL := Color(0.2, 0.75, 0.7)

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _visual: Node3D


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = WOOD
	contact_monitor = true
	max_contacts_reported = 4
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.35
	pm.friction = 0.7
	physics_material_override = pm
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.6
	cap.height = 1.9
	cs.shape = cap
	cs.position = Vector3(0, 0.15, 0)
	add_child(cs)
	_visual = Node3D.new()
	_visual.name = "Vis"
	add_child(_visual)
	_build_visual()
	_start_bob()
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
	return ["character", "brainrot-archetype", "plonko"]


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _build_visual() -> void:
	# log body
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.55
	cyl.bottom_radius = 0.58
	cyl.height = 1.6
	cyl.radial_segments = 14
	body.mesh = cyl
	body.material_override = _mat(_tint)
	body.position = Vector3(0, 0.15, 0)
	_visual.add_child(body)
	# cut-wood end rings
	for ey in [-0.62, 0.92]:
		var ring := MeshInstance3D.new()
		var rm := CylinderMesh.new()
		rm.top_radius = 0.56
		rm.bottom_radius = 0.56
		rm.height = 0.1
		rm.radial_segments = 14
		ring.mesh = rm
		ring.material_override = _mat(WOOD_DARK)
		ring.position = Vector3(0, ey, 0)
		_visual.add_child(ring)
	# 3 decorative teal bands (original detail)
	for by in [-0.25, 0.15, 0.55]:
		var band := MeshInstance3D.new()
		var bm := CylinderMesh.new()
		bm.top_radius = 0.585
		bm.bottom_radius = 0.585
		bm.height = 0.09
		bm.radial_segments = 14
		band.mesh = bm
		band.material_override = _mat(TEAL)
		band.position = Vector3(0, by, 0)
		_visual.add_child(band)
	# stubby arms
	for sx in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var am := CylinderMesh.new()
		am.top_radius = 0.12
		am.bottom_radius = 0.14
		am.height = 0.55
		am.radial_segments = 8
		arm.mesh = am
		arm.material_override = _mat(WOOD_DARK)
		arm.position = Vector3(sx * 0.72, 0.25, 0)
		arm.rotation_degrees = Vector3(0, 0, sx * -35.0)
		_visual.add_child(arm)
	# feet
	for sx in [-1.0, 1.0]:
		var foot := MeshInstance3D.new()
		var fm := SphereMesh.new()
		fm.radius = 0.2
		fm.height = 0.4
		foot.mesh = fm
		foot.material_override = _mat(WOOD_DARK)
		foot.position = Vector3(sx * 0.28, -0.72, 0.1)
		_visual.add_child(foot)
	# paddle club (original: flat paddle, not a plain bat)
	var club := Node3D.new()
	club.position = Vector3(0.95, 0.35, 0)
	club.rotation_degrees = Vector3(0, 0, -20)
	_visual.add_child(club)
	var grip := MeshInstance3D.new()
	var gm := CylinderMesh.new()
	gm.top_radius = 0.09
	gm.bottom_radius = 0.09
	gm.height = 0.9
	gm.radial_segments = 8
	grip.mesh = gm
	grip.material_override = _mat(WOOD_DARK)
	grip.position = Vector3(0, -0.35, 0)
	club.add_child(grip)
	var paddle := MeshInstance3D.new()
	var pm2 := BoxMesh.new()
	pm2.size = Vector3(0.55, 0.75, 0.14)
	paddle.mesh = pm2
	paddle.material_override = _mat(TEAL)
	paddle.position = Vector3(0, 0.45, 0)
	club.add_child(paddle)
	# face decal (house style: happy)
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.85, 0.85)
	face.mesh = quad
	var fmat := StandardMaterial3D.new()
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.albedo_texture = FaceDecal.make_texture("happy")
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	fmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	face.material_override = fmat
	face.position = Vector3(0, 0.35, 0.585)
	_visual.add_child(face)


func _start_bob() -> void:
	var tw := _visual.create_tween()
	tw.set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(_visual, "position:y", 0.14, 0.55).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_visual, "position:y", 0.0, 0.55).set_ease(Tween.EASE_IN_OUT)
	var tw2 := _visual.create_tween()
	tw2.set_loops()
	tw2.set_trans(Tween.TRANS_SINE)
	tw2.tween_property(_visual, "rotation:z", 0.08, 0.8).set_ease(Tween.EASE_IN_OUT)
	tw2.tween_property(_visual, "rotation:z", -0.08, 0.8).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("destroyer"):
		return
	if _visual.has_meta("squashing"):
		return
	_visual.set_meta("squashing", true)
	var tw := _visual.create_tween()
	tw.tween_property(_visual, "scale", Vector3(1.35, 0.45, 1.35), 0.08)
	tw.tween_property(_visual, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_visual.remove_meta.bind("squashing"))
