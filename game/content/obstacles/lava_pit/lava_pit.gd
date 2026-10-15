extends StaticBody3D
## lava_pit — a pit of glowing lava. Bodies that touch it get launched
## upward with a squash (kid-friendly: bouncy, not deadly).

var _lava_mi: MeshInstance3D
var _t := 0.0

func _ready() -> void:
	_build()
	body_entered.connect(_on_body_entered)

func apply_params(params: Dictionary) -> void:
	if params.has("position"):
		position = params["position"]

func get_spawn_transforms() -> Array:
	return [Transform3D.IDENTITY]

func get_tags() -> Array:
	return ["obstacle", "lava"]

func _mat(c: Color, emission: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emission
	return m

func _build() -> void:
	# rim: 4 walls forming a 6x6 pit
	for x in [-3.2, 3.2]:
		_add_box(Vector3(x, 0.5, 0), Vector3(0.8, 1.0, 6.4), Color(0.3, 0.28, 0.3))
	for z in [-3.2, 3.2]:
		_add_box(Vector3(0, 0.5, z), Vector3(6.4, 1.0, 0.8), Color(0.3, 0.28, 0.3))
	# lava surface
	_lava_mi = MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(5.6, 0.2, 5.6)
	_lava_mi.mesh = lm
	_lava_mi.material_override = _mat(Color(1.0, 0.35, 0.05), 1.5)
	_lava_mi.position = Vector3(0, 0.15, 0)
	add_child(_lava_mi)
	# trigger volume just above lava
	var area := Area3D.new()
	area.position = Vector3(0, 0.6, 0)
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(5.6, 1.0, 5.6)
	cs.shape = box
	area.add_child(cs)
	add_child(area)
	area.body_entered.connect(_on_body_entered)

func _add_box(pos: Vector3, size: Vector3, c: Color) -> void:
	var b := StaticBody3D.new()
	b.position = pos
	var cs := CollisionShape3D.new()
	var shp := BoxShape3D.new()
	shp.size = size
	cs.shape = shp
	b.add_child(cs)
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = size
	mi.mesh = m
	mi.material_override = _mat(c)
	b.add_child(mi)
	add_child(b)

func _process(delta: float) -> void:
	_t += delta
	# bubbling lava: pulse emission
	var mat := _lava_mi.material_override as StandardMaterial3D
	mat.emission_energy_multiplier = 1.3 + sin(_t * 3.0) * 0.4

func _on_body_entered(body: Node) -> void:
	if body is RigidBody3D:
		var rb := body as RigidBody3D
		rb.linear_velocity = Vector3(randf_range(-3, 3), 12.0, randf_range(-3, 3))
		rb.angular_velocity = Vector3(randf_range(-4, 4), randf_range(-4, 4), 0)
		if body.has_method("squash"):
			body.squash()
		print("[lava_pit] launched ", body.name)
