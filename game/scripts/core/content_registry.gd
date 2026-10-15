extends Node
## ContentRegistry — autoload singleton.
## Scans res://content/<type>/<id>/ modules, validates their manifests,
## and spawns module scenes. Adding content = adding a folder; this file
## never changes per content (RULES #5, ADR-004).
##
## Module contract (ARCHITECTURE.md):
##   content/<type>/<id>/module.json  {id, type, display_name, version, root_scene, ...}
##   content/<type>/<id>/<root_scene> implements the content interface:
##     apply_params(params: Dictionary), get_spawn_transforms(), get_tags()

const KNOWN_TYPES: Array[String] = ["vehicles", "destroyers", "characters", "obstacles", "arenas"]
const REQUIRED_KEYS: Array[String] = ["id", "type", "display_name", "version", "root_scene"]

var _modules: Dictionary = {}  # id -> {"manifest": Dictionary, "dir": String}


func _ready() -> void:
	for e in scan("res://content"):
		push_warning(e)


func scan(content_path: String) -> Array:
	_modules.clear()
	var errors: Array = []
	if not DirAccess.dir_exists_absolute(content_path):
		return errors  # empty/missing tree is valid
	for type in KNOWN_TYPES:
		var type_dir := content_path.path_join(type)
		if not DirAccess.dir_exists_absolute(type_dir):
			continue
		for mod_id in DirAccess.get_directories_at(type_dir):
			var mod_dir := type_dir.path_join(mod_id)
			var mf_path := mod_dir.path_join("module.json")
			if not FileAccess.file_exists(mf_path):
				errors.append("%s: missing module.json" % mod_dir)
				continue
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(mf_path))
			if typeof(parsed) != TYPE_DICTIONARY:
				errors.append("%s: invalid JSON" % mf_path)
				continue
			var merrs := _validate_manifest(mod_dir, mod_id, type, parsed)
			if not merrs.is_empty():
				errors.append_array(merrs)
				continue
			_modules[parsed["id"]] = {"manifest": parsed, "dir": mod_dir}
	return errors


func _validate_manifest(mod_dir: String, folder_id: String, folder_type: String, m: Dictionary) -> Array:
	var errs: Array = []
	for k in REQUIRED_KEYS:
		if not m.has(k):
			errs.append("%s: missing key '%s'" % [mod_dir, k])
	if str(m.get("id", "")) != folder_id:
		errs.append("%s: id '%s' != folder '%s'" % [mod_dir, m.get("id"), folder_id])
	if str(m.get("type", "")) != folder_type:
		errs.append("%s: type '%s' != folder '%s'" % [mod_dir, m.get("type"), folder_type])
	if not _valid_version(str(m.get("version", ""))):
		errs.append("%s: bad version '%s'" % [mod_dir, m.get("version")])
	var rs := str(m.get("root_scene", ""))
	if rs != "" and not FileAccess.file_exists(mod_dir.path_join(rs)):
		errs.append("%s: root_scene '%s' not found" % [mod_dir, rs])
	return errs


func _valid_version(v: String) -> bool:
	var re := RegEx.new()
	re.compile("^\\d+\\.\\d+(\\.\\d+)?$")
	return re.search(v) != null


func validate_all(content_path: String = "res://content") -> Array:
	return scan(content_path)


func module_count() -> int:
	return _modules.size()


func list_modules(type_filter: String = "") -> Array:
	var out: Array = []
	for id in _modules:
		if type_filter == "" or str(_modules[id]["manifest"]["type"]) == type_filter:
			out.append(id)
	return out


func get_manifest(id: String) -> Dictionary:
	if not _modules.has(id):
		return {}
	return _modules[id]["manifest"]


func spawn(id: String, params: Dictionary = {}, parent: Node = null) -> Node:
	if not _modules.has(id):
		push_error("ContentRegistry.spawn: unknown module '%s'" % id)
		return null
	var entry: Dictionary = _modules[id]
	var scene_path: String = (entry["dir"] as String).path_join(str(entry["manifest"]["root_scene"]))
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("ContentRegistry.spawn: cannot load '%s'" % scene_path)
		return null
	var node := packed.instantiate()
	if node.has_method("apply_params"):
		node.call("apply_params", params)
	if parent != null:
		parent.add_child(node)
	return node
