extends RigidBody3D
## plonko — brainrot-style log warrior (~90% reference similarity, ADR-007b).
## Copyright handled by Urbish (his explicit call). See REFERENCE_NOTE.md.
## Idle bob animation via looping tween; squash on destroyer hit.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const BARK := Color(0.55, 0.38, 0.22)
const BARK_DARK := Color(0.4, 0.27, 0.15)
const WOOD_LIGHT := Color(0.8, 0.62, 0.38)

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _visual: Node3D


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = BARK
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
	return ["character", "brainrot-style", "plonko"]


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _build_visual() -> void:
	# log body — tapered bark cylinder
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.52
	cyl.bottom_radius = 0.6
	cyl.height = 1.7
	cyl.radial_segments = 14
	body.mesh = cyl
	body.material_override = _mat(_tint)
	body.position = Vector3(0, 0.15, 0)
	_visual.add_child(body)
	# cut-wood top (growth-ring cap)
	var cap_top := MeshInstance3D.new()
	var ctm := CylinderMesh.new()
	ctm.top_radius = 0.53
	ctm.bottom_radius = 0.53
	ctm.height = 0.08
	ctm.radial_segments = 14
	cap_top.mesh = ctm
	cap_top.material_override = _mat(WOOD_LIGHT)
	cap_top.position = Vector3(0, 1.02, 0)
	_visual.add_child(cap_top)
	# dark base ring
	var base := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.6
	bm.bottom_radius = 0.6
	bm.height = 0.1
	bm.radial_segments = 14
	base.mesh = bm
	base.material_override = _mat(BARK_DARK)
	base.position = Vector3(0, -0.72, 0)
	_visual.add_child(base)
	# arms angled inward to grip the bat
	for sx in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var am := CylinderMesh.new()
		am.top_radius = 0.12
		am.bottom_radius = 0.14
		am.height = 0.6
		am.radial_segments = 8
		arm.mesh = am
		arm.material_override = _mat(BARK_DARK)
		arm.position = Vector3(sx * 0.62, 0.35, 0.2)
		arm.rotation_degrees = Vector3(0, 0, sx * -50.0)
		_visual.add_child(arm)
	# feet
	for sx in [-1.0, 1.0]:
		var foot := MeshInstance3D.new()
		var fm := SphereMesh.new()
		fm.radius = 0.2
		fm.height = 0.4
		foot.mesh = fm
		foot.material_override = _mat(BARK_DARK)
		foot.position = Vector3(sx * 0.28, -0.78, 0.12)
		_visual.add_child(foot)
	# baseball bat — tapered, held diagonal across the body
	var club := Node3D.new()
	club.position = Vector3(0.5, 0.05, 0.3)
	club.rotation_degrees = Vector3(0, 0, -45)
	_visual.add_child(club)
	var handle := MeshInstance3D.new()
	var hm := CylinderMesh.new()
	hm.top_radius = 0.075
	hm.bottom_radius = 0.075
	hm.height = 0.6
	hm.radial_segments = 8
	handle.mesh = hm
	handle.material_override = _mat(BARK_DARK)
	handle.position = Vector3(0, -0.15, 0)
	club.add_child(handle)
	var knob := MeshInstance3D.new()
	var km := SphereMesh.new()
	km.radius = 0.1
	km.height = 0.2
	knob.mesh = km
	knob.material_override = _mat(BARK_DARK)
	knob.position = Vector3(0, -0.48, 0)
	club.add_child(knob)
	var barrel := MeshInstance3D.new()
	var brm := CylinderMesh.new()
	brm.top_radius = 0.18
	brm.bottom_radius = 0.08
	brm.height = 1.0
	brm.radial_segments = 10
	barrel.mesh = brm
	barrel.material_override = _mat(WOOD_LIGHT)
	barrel.position = Vector3(0, 0.6, 0)
	club.add_child(barrel)
	# stern face decal (reference look)
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.9, 0.9)
	face.mesh = quad
	var fmat := StandardMaterial3D.new()
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.albedo_texture = FaceDecal.make_texture("angry")
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	fmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	face.material_override = fmat
	face.position = Vector3(0, 0.45, 0.56)
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
