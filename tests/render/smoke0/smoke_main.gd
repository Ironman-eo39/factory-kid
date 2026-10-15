extends SceneTree

var frames := 0

func _initialize() -> void:
	var cam := Camera3D.new()
	cam.position = Vector3(0, 2.5, 6.0)
	cam.look_at_from_position(Vector3(0, 2.5, 6.0), Vector3.ZERO, Vector3.UP)
	root.add_child(cam)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, 30, 0)
	root.add_child(light)
	var box := CSGBox3D.new()
	box.size = Vector3(1.5, 1.5, 1.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.2, 0.2)
	mat.roughness = 1.0
	box.material = mat
	root.add_child(box)
	var ground := CSGBox3D.new()
	ground.size = Vector3(10, 0.2, 10)
	ground.position = Vector3(0, -1.0, 0)
	root.add_child(ground)
	process_frame.connect(_on_frame)

func _on_frame() -> void:
	frames += 1
	if frames == 90:
		var img := root.get_texture().get_image()
		var path := OS.get_environment("RENDER_OUT_PNG")
		if path == "":
			path = "/home/urbish/kid-toy-factory/tests/render/smoke0.png"
		var err := img.save_png(path)
		print("SMOKE saved png err=", err, " size=", img.get_size())
		quit()
