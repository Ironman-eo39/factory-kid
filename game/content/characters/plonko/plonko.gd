extends RigidBody3D
## plonko — brainrot-style log character (~90% reference similarity, ADR-007b).
## v5: real Tung Tung Sahur GLB model (Sketchfab, via three.js toy repo).
## Copyright handled by Urbish (his explicit call). See REFERENCE_NOTE.md.
## Idle bob animation via looping tween; squash on destroyer hit.
## Content interface: apply_params / get_spawn_transforms / get_tags.

const MODEL_PATH := "res://content/characters/plonko/model_src/tung.glb"
const MODEL_SCALE := 0.30  # raw model ~7.6u -> ~2.3m tall in game

var _tint: Color = Color(-1, -1, -1, -1)  # sentinel: apply_params may set before _ready
var _visual: Node3D


func _ready() -> void:
	if _tint.r < 0.0:
		_tint = Color(0.66, 0.44, 0.20)
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


func _build_visual() -> void:
	var packed := load(MODEL_PATH) as PackedScene
	if packed == null:
		push_error("plonko: failed to load " + MODEL_PATH)
		return
	var inst := packed.instantiate() as Node3D
	inst.scale = Vector3.ONE * MODEL_SCALE
	# center the model on the body origin: shift so feet sit at y=-1.3
	inst.position = Vector3(0, -1.15, 0)
	_visual.add_child(inst)
	# golden-wood tint to match the reference (model is too dark/red)
	_golden_texture(inst)


const GOLDEN_TEX := preload("res://content/characters/plonko/model_src/tung_golden.png")

func _golden_texture(n: Node) -> void:
	# Swap the dark-brown texture for the golden-processed one (keeps face UVs).
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var m := mi.get_active_material(0)
		if m is StandardMaterial3D:
			var sm := (m as StandardMaterial3D).duplicate() as StandardMaterial3D
			sm.albedo_texture = GOLDEN_TEX
			sm.albedo_color = Color(1, 1, 1)
			mi.material_override = sm
	for c in n.get_children():
		_golden_texture(c)

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
	# squash pivots around the feet: scale Y down AND shift down so the
	# head compresses under the hammer instead of poking through it
	tw.set_parallel(true)
	tw.tween_property(_visual, "scale", Vector3(1.4, 0.32, 1.4), 0.08)
	tw.tween_property(_visual, "position:y", -0.75, 0.08)
	tw.set_parallel(false)
	tw.tween_property(_visual, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_visual, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_visual.remove_meta.bind("squashing"))
