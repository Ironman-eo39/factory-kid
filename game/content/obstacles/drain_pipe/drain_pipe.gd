extends StaticBody3D
## drain_pipe — a vertical green pipe. Bodies falling in get popped out
## the top with a spin (kid-friendly teleport gag).

var _t := 0.0

func _ready() -> void:
	_build()
	var area := Area3D.new()
	area.position = Vector3(0, 2.2, 0)
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 1.0
	cyl.height = 1.0
	cs.shape = cyl
	area.add_child(cs)
	add_child(area)
	area.body_entered.connect(_on_body_entered)

func apply_params(params: Dictionary) -> void:
	if params.has("position"):
		position = params["position"]

func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]

func get_tags() -> Array:
	return ["obstacle", "pipe"]

func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.6
	return m

func _build() -> void:
	# pipe body: green cylinder
	var pipe := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 1.3
	pm.bottom_radius = 1.4
	pm.height = 3.0
	pipe.mesh = pm
	pipe.material_override = _mat(Color(0.15, 0.6, 0.2))
	pipe.position = Vector3(0, 1.5, 0)
	add_child(pipe)
	var pcs := CollisionShape3D.new()
	var pshp := CylinderShape3D.new()
	pshp.radius = 1.4
	pshp.height = 3.0
	pcs.shape = pshp
	pcs.position = Vector3(0, 1.5, 0)
	add_child(pcs)
	# rim
	var rim := MeshInstance3D.new()
	var rm := TorusMesh.new()
	rm.inner_radius = 1.1
	rm.outer_radius = 1.5
	rim.mesh = rm
	rim.material_override = _mat(Color(0.1, 0.45, 0.15))
	rim.position = Vector3(0, 3.0, 0)
	add_child(rim)

func _process(delta: float) -> void:
	_t += delta

func _on_body_entered(body: Node) -> void:
	if body is RigidBody3D:
		var rb := body as RigidBody3D
		# pop out the top with random horizontal fling
		var out_pos := global_position + Vector3(0, 4.0, 0)
		rb.global_position = out_pos
		rb.linear_velocity = Vector3(randf_range(-6, 6), 8.0, randf_range(-6, 6))
		rb.angular_velocity = Vector3(randf_range(-8, 8), randf_range(-8, 8), 0)
		print("[drain_pipe] popped ", body.name)
