extends RigidBody3D
## test_ball — candy rigid ball with cartoon face. Squashes on destroyer hit.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const BALL_R := 0.6

var _tint := Color(1, 0.2, 0.3)


func _ready() -> void:
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 2
	linear_damp = 0.2
	angular_damp = 1.0
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.35
	pm.friction = 0.6
	physics_material_override = pm
	var cs := CollisionShape3D.new()
	var shp := SphereShape3D.new()
	shp.radius = BALL_R
	cs.shape = shp
	add_child(cs)
	_build_face(_tint)
	body_entered.connect(_on_body_entered)


func apply_params(params: Dictionary) -> void:
	# NOTE: called by ContentRegistry BEFORE the node enters the tree,
	# so only stash values here; _ready() builds visuals from them.
	if params.has("position"):
		position = params["position"]
	if params.has("tint"):
		_tint = params["tint"]


func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]


func get_tags() -> Array:
	return ["test", "ball"]


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _build_face(tint: Color) -> void:
	var old := get_node_or_null("Vis")
	if old != null:
		old.queue_free()
	var vis := Node3D.new()
	vis.name = "Vis"
	add_child(vis)
	var body_mi := MeshInstance3D.new()
	var body_mesh := SphereMesh.new()
	body_mesh.radius = BALL_R
	body_mesh.height = BALL_R * 2.0
	body_mesh.radial_segments = 16
	body_mesh.rings = 8
	body_mi.mesh = body_mesh
	body_mi.material_override = _mat(tint)
	vis.add_child(body_mi)
	var white := _mat(Color.WHITE)
	var black := _mat(Color(0.05, 0.05, 0.05))
	var eye_mesh := SphereMesh.new()
	eye_mesh.radius = 0.14
	eye_mesh.height = 0.28
	eye_mesh.radial_segments = 8
	eye_mesh.rings = 4
	var pupil_mesh := SphereMesh.new()
	pupil_mesh.radius = 0.07
	pupil_mesh.height = 0.14
	pupil_mesh.radial_segments = 6
	pupil_mesh.rings = 3
	var mouth_mesh := BoxMesh.new()
	mouth_mesh.size = Vector3(0.5, 0.1, 0.06)
	for sx in [-1.0, 1.0]:
		var eye := MeshInstance3D.new()
		eye.mesh = eye_mesh
		eye.material_override = white
		eye.position = Vector3(sx * 0.2, 0.18, BALL_R * 0.82)
		vis.add_child(eye)
		var pupil := MeshInstance3D.new()
		pupil.mesh = pupil_mesh
		pupil.material_override = black
		pupil.position = Vector3(sx * 0.2, 0.18, BALL_R * 0.82 + 0.1)
		vis.add_child(pupil)
	var mouth := MeshInstance3D.new()
	mouth.mesh = mouth_mesh
	mouth.material_override = black
	mouth.position = Vector3(0, -0.18, BALL_R * 0.93)
	vis.add_child(mouth)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("destroyer"):
		return
	var vis := get_node_or_null("Vis") as Node3D
	if vis == null or vis.has_meta("squashing"):
		return
	vis.set_meta("squashing", true)
	var tw := vis.create_tween()
	tw.tween_property(vis, "scale", Vector3(1.5, 0.35, 1.5), 0.06)
	tw.tween_property(vis, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(vis.remove_meta.bind("squashing"))
