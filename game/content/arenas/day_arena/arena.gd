extends Node3D
## day_arena — flat green field + road + invisible walls + light + camera.
## Content interface: apply_params / get_spawn_transforms / get_tags.


func _ready() -> void:
	_build_env()
	_build_ground()
	_build_camera()


func apply_params(params: Dictionary) -> void:
	if params.has("position"):
		position = params["position"]


func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]


func get_tags() -> Array:
	return ["test", "flat"]


func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _build_env() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.53, 0.78, 0.95)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1, 1, 1)
	env.ambient_light_energy = 0.55
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 30, 0)
	sun.light_energy = 0.9
	sun.shadow_enabled = false
	add_child(sun)


func _static_box(pos: Vector3, size: Vector3) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.position = pos
	var cs := CollisionShape3D.new()
	var shp := BoxShape3D.new()
	shp.size = size
	cs.shape = shp
	b.add_child(cs)
	add_child(b)
	return b


func _build_ground() -> void:
	var g := _static_box(Vector3(0, -0.5, -5), Vector3(40, 1, 60))
	var gmi := MeshInstance3D.new()
	var gm := BoxMesh.new()
	gm.size = Vector3(40, 1, 60)
	gmi.mesh = gm
	gmi.material_override = _mat(Color(0.35, 0.75, 0.25))
	g.add_child(gmi)
	var road := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(10, 0.04, 60)
	road.mesh = rm
	road.material_override = _mat(Color(0.35, 0.35, 0.38))
	road.position = Vector3(0, 0.02, -5)
	add_child(road)
	# invisible walls keep scattered bodies in frame
	_static_box(Vector3(-5.5, 2, -5), Vector3(1, 4, 60))
	_static_box(Vector3(5.5, 2, -5), Vector3(1, 4, 60))
	_static_box(Vector3(0, 2, -18), Vector3(12, 4, 1))
	_static_box(Vector3(0, 2, 6), Vector3(12, 4, 1))


func _build_camera() -> void:
	var cam := Camera3D.new()
	cam.name = "ArenaCam"
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.fov = 60.0
	cam.position = Vector3(0, 8.5, 10.0)
	add_child(cam)
	cam.look_at(Vector3(0, 0.5, -3.5))
	cam.current = true
