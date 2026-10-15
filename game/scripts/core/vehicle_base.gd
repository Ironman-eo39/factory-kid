extends RigidBody3D
## vehicle_base — shared root script for Kenney car modules.
## Each car module's main.tscn sets the @export params (model, tint, face).
## Content interface: apply_params / get_spawn_transforms / get_tags.

@export var model_path: String = ""
@export var default_tint: Color = Color(1, 0.3, 0.3)
@export var face_offset: Vector3 = Vector3(0, 0.55, 1.3)
@export var face_size: Vector2 = Vector2(1.1, 1.1)
@export var collider_center: Vector3 = Vector3(0, 0.5, 0)
@export var collider_size: Vector3 = Vector3(1.5, 1.1, 2.55)

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _expression: String = "happy"
var _visual: Node3D


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = default_tint
	contact_monitor = true
	max_contacts_reported = 4
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.3
	pm.friction = 0.7
	physics_material_override = pm
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = collider_size
	cs.shape = box
	cs.position = collider_center
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
	if params.has("expression"):
		_expression = str(params["expression"])


func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]


func get_tags() -> Array:
	return ["vehicle", "kenney"]


func _build_visual() -> void:
	var packed := load(model_path) as PackedScene
	if packed == null:
		push_error("vehicle_base: cannot load model: %s" % model_path)
		return
	var inst := packed.instantiate()
	_apply_candy(inst)
	_visual.add_child(inst)
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = face_size
	face.mesh = quad
	face.material_override = _face_material(_expression)
	face.position = face_offset
	_visual.add_child(face)


func _apply_candy(node: Node) -> void:
	var mi := node as MeshInstance3D
	if mi != null:
		mi.material_override = _mat(_tint)
	for c in node.get_children():
		_apply_candy(c)


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _face_material(expression: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_texture = FaceDecal.make_texture(expression)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("destroyer"):
		return
	if _visual.has_meta("squashing"):
		return
	_visual.set_meta("squashing", true)
	var tw := _visual.create_tween()
	tw.tween_property(_visual, "scale", Vector3(1.3, 0.5, 1.3), 0.08)
	tw.tween_property(_visual, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_visual.remove_meta.bind("squashing"))
