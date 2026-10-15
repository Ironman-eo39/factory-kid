extends RigidBody3D
## plonko — brainrot-style log character (~90% reference similarity, ADR-007b).
## Golden plank body, big-eyed smile, bat held down at his side.
## Copyright handled by Urbish (his explicit call). See REFERENCE_NOTE.md.
## Idle bob animation via looping tween; squash on destroyer hit.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const GOLD := Color(0.79, 0.60, 0.20)
const GOLD_DARK := Color(0.62, 0.45, 0.14)
const WOOD_LIGHT := Color(0.88, 0.72, 0.38)

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _visual: Node3D


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = GOLD
	contact_monitor = true
	max_contacts_reported = 4
	angular_damp = 1.0
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.35
	pm.friction = 0.7
	physics_material_override = pm
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.62
	cap.height = 2.6
	cs.shape = cap
	cs.position = Vector3(0, -0.1, 0)
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
	# plank body — wider than deep
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.95, 1.75, 0.62)
	body.mesh = bm
	body.material_override = _mat(_tint)
	body.position = Vector3(0, 0.15, 0)
	_visual.add_child(body)
	# cut-wood top cap
	var cap_top := MeshInstance3D.new()
	var ctm := BoxMesh.new()
	ctm.size = Vector3(0.97, 0.08, 0.64)
	cap_top.mesh = ctm
	cap_top.material_override = _mat(WOOD_LIGHT)
	cap_top.position = Vector3(0, 1.05, 0)
	_visual.add_child(cap_top)
	# ear nubs
	for sx in [-1.0, 1.0]:
		var ear := MeshInstance3D.new()
		var em := SphereMesh.new()
		em.radius = 0.12
		em.height = 0.24
		ear.mesh = em
		ear.material_override = _mat(GOLD_DARK)
		ear.position = Vector3(sx * 0.5, 0.75, 0)
		_visual.add_child(ear)
	# long thin arms hanging at the sides
	for sx in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var am := CylinderMesh.new()
		am.top_radius = 0.09
		am.bottom_radius = 0.11
		am.height = 1.0
		am.radial_segments = 8
		arm.mesh = am
		arm.material_override = _mat(_tint)
		arm.position = Vector3(sx * 0.58, -0.15, 0)
		arm.rotation_degrees = Vector3(0, 0, sx * -8.0)
		_visual.add_child(arm)
		var hand := MeshInstance3D.new()
		var hm := SphereMesh.new()
		hm.radius = 0.13
		hm.height = 0.26
		hand.mesh = hm
		hand.material_override = _mat(_tint)
		hand.position = Vector3(sx * 0.64, -0.68, 0)
		_visual.add_child(hand)
	# thin legs + feet
	for sx in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var lm := CylinderMesh.new()
		lm.top_radius = 0.1
		lm.bottom_radius = 0.1
		lm.height = 0.5
		lm.radial_segments = 8
		leg.mesh = lm
		leg.material_override = _mat(_tint)
		leg.position = Vector3(sx * 0.22, -0.95, 0)
		_visual.add_child(leg)
		var foot := MeshInstance3D.new()
		var fm := SphereMesh.new()
		fm.radius = 0.16
		fm.height = 0.2
		foot.mesh = fm
		foot.material_override = _mat(GOLD_DARK)
		foot.position = Vector3(sx * 0.22, -1.22, 0.05)
		foot.scale = Vector3(1.0, 0.6, 1.2)
		_visual.add_child(foot)
	# baseball bat held DOWN in the right hand
	var club := Node3D.new()
	club.position = Vector3(0.5, 0.05, 0.3)
	club.rotation_degrees = Vector3(0, 0, -45)
	_visual.add_child(club)
	var handle := MeshInstance3D.new()
	var ham := CylinderMesh.new()
	ham.top_radius = 0.07
	ham.bottom_radius = 0.07
	ham.height = 0.6
	ham.radial_segments = 8
	handle.mesh = ham
	handle.material_override = _mat(GOLD_DARK)
	handle.position = Vector3(0, -0.15, 0)
	club.add_child(handle)
	var knob := MeshInstance3D.new()
	var km := SphereMesh.new()
	km.radius = 0.1
	km.height = 0.2
	knob.mesh = km
	knob.material_override = _mat(GOLD_DARK)
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
	# big-eyed smile face decal
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.85, 0.85)
	face.mesh = quad
	var fmat := StandardMaterial3D.new()
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.albedo_texture = FaceDecal.make_texture("tung")
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	fmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	face.material_override = fmat
	face.position = Vector3(0, 0.55, 0.42)
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
