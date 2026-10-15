extends Node3D
## Fixture: minimal content-interface implementation.


func apply_params(params: Dictionary) -> void:
	for k in params:
		set_meta(k, params[k])


func get_spawn_transforms() -> Array:
	return []


func get_tags() -> Array:
	return ["test"]
