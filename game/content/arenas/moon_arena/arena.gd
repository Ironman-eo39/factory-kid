extends Node3D
## moon_arena — dark lunar surface, starry sky, Earth on the horizon.
## Same layout as day_arena so presets are interchangeable.

func _ready() -> void:
	_build_env()
	_build_ground()
	_build_stars()
	_build_earth()
	_build_camera()

func apply_params(params: Dictionary) -> void:
	if params.has("position"):
		position = params["position"]

func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]

func get_tags() -> Array:
	return ["moon", "night"]

func _mat(c: Color, emission: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emission
	return m

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

func _build_env() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.08)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.6, 0.9)
	env.ambient_light_energy = 0.4
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, 30, 0)
	sun.light_color = Color(0.85, 0.9, 1.0)
	sun.light_energy = 0.7
	sun.shadow_enabled = false
	add_child(sun)

func _build_ground() -> void:
	var g := _static_box(Vector3(0, -0.5, -5), Vector3(40, 1, 60))
	var gmi := MeshInstance3D.new()
	var gm := BoxMesh.new()
	gm.size = Vector3(40, 1, 60)
	gmi.mesh = gm
	gmi.material_override = _mat(Color(0.55, 0.55, 0.6))
	g.add_child(gmi)
	# craters: shallow dark discs
	for i in 5:
		var c := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 1.2 + i * 0.3
		cm.bottom_radius = 1.2 + i * 0.3
		cm.height = 0.06
		c.mesh = cm
		c.material_override = _mat(Color(0.35, 0.35, 0.4))
		c.position = Vector3(-8 + i * 4.0, 0.03, -12 + (i % 2) * 8.0)
		add_child(c)
	var road := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(10, 0.04, 60)
	road.mesh = rm
	road.material_override = _mat(Color(0.4, 0.4, 0.45))
	road.position = Vector3(0, 0.02, -5)
	add_child(road)
	_static_box(Vector3(-5.5, 2, -5), Vector3(1, 4, 60))
	_static_box(Vector3(5.5, 2, -5), Vector3(1, 4, 60))
	_static_box(Vector3(0, 2, -18), Vector3(12, 4, 1))
	_static_box(Vector3(0, 2, 6), Vector3(12, 4, 1))

func _build_stars() -> void:
	for i in 120:
		var s := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.08
		sm.height = 0.16
		s.mesh = sm
		s.material_override = _mat(Color(1, 1, 1), 2.0)
		var a := randf() * TAU
		var r := randf_range(30.0, 60.0)
		s.position = Vector3(cos(a) * r, randf_range(8.0, 40.0), sin(a) * r - 10)
		add_child(s)

func _build_earth() -> void:
	var e := MeshInstance3D.new()
	var em := SphereMesh.new()
	em.radius = 3.0
	em.height = 6.0
	e.mesh = em
	e.material_override = _mat(Color(0.3, 0.5, 1.0), 0.6)
	e.position = Vector3(18, 16, -45)
	add_child(e)

func _build_camera() -> void:
	var cam := CameraDirector.new()
	cam.name = "ArenaCam"
	cam.add_to_group("camera_director")
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.fov = 60.0
	cam.position = Vector3(0, 8.5, 10.0)
	add_child(cam)
	cam.look_at(Vector3(0, 0.5, -3.5))
	cam.current = true
