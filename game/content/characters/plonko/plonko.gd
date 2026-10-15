extends RigidBody3D
## plonko — brainrot-style log character (~90% reference similarity, ADR-007b).
## Warm wood-brown plank body, bulging close-set eyes, long nose, wide smile,
## bat held DOWN in the right hand. Rebuilt v4 against the actual reference.
## Copyright handled by Urbish (his explicit call). See REFERENCE_NOTE.md.
## Idle bob animation via looping tween; squash on destroyer hit.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const WOOD := Color(0.66, 0.44, 0.20)
const WOOD_DARK := Color(0.50, 0.32, 0.13)
const WOOD_LIGHT := Color(0.76, 0.55, 0.28)
const EYE_WHITE := Color(0.96, 0.96, 0.94)
const PUPIL := Color(0.04, 0.04, 0.04)
const SMILE_C := Color(0.30, 0.18, 0.08)

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _visual: Node3D


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = WOOD
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


func _sphere(r: float, c: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 16
	sm.rings = 12
	mi.mesh = sm
	mi.material_override = _mat(c)
	return mi


func _build_visual() -> void:
	# plank body — tall rounded-feeling rectangle, warm wood brown
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.9, 1.8, 0.6)
	body.mesh = bm
	body.material_override = _mat(_tint)
	body.position = Vector3(0, 0.15, 0)
	_visual.add_child(body)
	# cut-wood top cap (lighter)
	var cap_top := MeshInstance3D.new()
	var ctm := BoxMesh.new()
	ctm.size = Vector3(0.92, 0.08, 0.62)
	cap_top.mesh = ctm
	cap_top.material_override = _mat(WOOD_LIGHT)
	cap_top.position = Vector3(0, 1.06, 0)
	_visual.add_child(cap_top)
	# ---- FACE (3D, the likeness lives here) ----
	var fz := 0.30  # body front plane
	# bulging close-set eyes
	for sx in [-1.0, 1.0]:
		var eye := _sphere(0.13, EYE_WHITE)
		eye.position = Vector3(sx * 0.15, 0.72, fz - 0.02)
		eye.scale = Vector3(1.0, 1.15, 0.9)
		_visual.add_child(eye)
		var pup := _sphere(0.06, PUPIL)
		pup.position = Vector3(sx * 0.15, 0.72, fz + 0.09)
		_visual.add_child(pup)
	# heavy brow ridges
	for sx in [-1.0, 1.0]:
		var brow := MeshInstance3D.new()
		var brm := BoxMesh.new()
		brm.size = Vector3(0.30, 0.07, 0.10)
		brow.mesh = brm
		brow.material_override = _mat(WOOD_DARK)
		brow.position = Vector3(sx * 0.15, 0.90, fz + 0.01)
		brow.rotation_degrees = Vector3(-8, 0, sx * -10.0)
		_visual.add_child(brow)
	# long nose — the signature feature
	var nose := MeshInstance3D.new()
	var nm := CylinderMesh.new()
	nm.top_radius = 0.085
	nm.bottom_radius = 0.055
	nm.height = 0.38
	nm.radial_segments = 10
	nose.mesh = nm
	nose.material_override = _mat(_tint)
	nose.position = Vector3(0, 0.48, fz + 0.10)
	nose.rotation_degrees = Vector3(12, 0, 0)
	_visual.add_child(nose)
	var nosetip := _sphere(0.055, _tint)
	nosetip.position = Vector3(0, 0.28, fz + 0.14)
	_visual.add_child(nosetip)
	# wide cheerful smile (flat decal tucked under the nose)
	var smile := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.52, 0.20)
	smile.mesh = quad
	var smat := StandardMaterial3D.new()
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smat.albedo_texture = FaceDecal.make_texture("smile")
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	smat.cull_mode = BaseMaterial3D.CULL_DISABLED
	smile.material_override = smat
	smile.position = Vector3(0, 0.12, fz + 0.02)
	_visual.add_child(smile)
	# ear nubs
	for sx in [-1.0, 1.0]:
		var ear := _sphere(0.10, WOOD_DARK)
		ear.scale = Vector3(0.6, 1.0, 0.8)
		ear.position = Vector3(sx * 0.47, 0.68, 0)
		_visual.add_child(ear)
	# thin arms + mitten hands
	for sx in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var am := CylinderMesh.new()
		am.top_radius = 0.075
		am.bottom_radius = 0.085
		am.height = 0.95
		am.radial_segments = 8
		arm.mesh = am
		arm.material_override = _mat(_tint)
		arm.position = Vector3(sx * 0.52, -0.18, 0)
		arm.rotation_degrees = Vector3(0, 0, sx * -6.0)
		_visual.add_child(arm)
		var hand := _sphere(0.12, _tint)
		hand.scale = Vector3(1.0, 1.25, 0.9)
		hand.position = Vector3(sx * 0.56, -0.70, 0.02)
		_visual.add_child(hand)
	# thin legs + flat feet
	for sx in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var lm := CylinderMesh.new()
		lm.top_radius = 0.09
		lm.bottom_radius = 0.09
		lm.height = 0.45
		lm.radial_segments = 8
		leg.mesh = lm
		leg.material_override = _mat(_tint)
		leg.position = Vector3(sx * 0.20, -0.95, 0)
		_visual.add_child(leg)
		var foot := MeshInstance3D.new()
		var fm := BoxMesh.new()
		fm.size = Vector3(0.20, 0.10, 0.42)
		foot.mesh = fm
		foot.material_override = _mat(WOOD_DARK)
		foot.position = Vector3(sx * 0.20, -1.20, 0.10)
		_visual.add_child(foot)
	# baseball bat held DOWN in the right hand (screen-left when facing camera)
	var bat := Node3D.new()
	bat.position = Vector3(-0.58, -0.55, 0.05)
	_visual.add_child(bat)
	var grip := MeshInstance3D.new()
	var gm := CylinderMesh.new()
	gm.top_radius = 0.055
	gm.bottom_radius = 0.055
	gm.height = 0.45
	gm.radial_segments = 8
	grip.mesh = gm
	grip.material_override = _mat(WOOD_DARK)
	grip.position = Vector3(0, -0.10, 0)
	bat.add_child(grip)
	var barrel := MeshInstance3D.new()
	var brm2 := CylinderMesh.new()
	brm2.top_radius = 0.06
	brm2.bottom_radius = 0.14
	brm2.height = 0.85
	brm2.radial_segments = 10
	barrel.mesh = brm2
	barrel.material_override = _mat(WOOD_LIGHT)
	barrel.position = Vector3(0, -0.75, 0)
	bat.add_child(barrel)


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
