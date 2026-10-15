extends Node
## AudioSynth — autoload. Owns the mixer bus layout and the music/chant
## channel. Destroyers route their procedural SFX to the "SFX" bus;
## the scenario runner triggers the chant via play_chant().
##
## Buses: Master (default) -> SFX (impacts, whooshes), Music (chant loop).
## The chant WAV is a Suno export dropped into game/audio/ by Urbish;
## game/audio/chant_placeholder.wav is a procedural stand-in.

const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

var _chant_player: AudioStreamPlayer


func _ready() -> void:
	_ensure_bus(SFX_BUS)
	_ensure_bus(MUSIC_BUS)
	print("[audiosynth] buses: ", _bus_list())


func _ensure_bus(name: String) -> void:
	if AudioServer.get_bus_index(name) < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, name)


func _bus_list() -> Array:
	var out: Array = []
	for i in AudioServer.bus_count:
		out.append(AudioServer.get_bus_name(i))
	return out


func sfx_bus() -> String:
	return SFX_BUS


func play_chant(path: String, volume_db: float = -10.0) -> void:
	var stream := load(path) as AudioStreamWAV
	if stream == null:
		push_warning("[audiosynth] chant not found: %s" % path)
		return
	if _chant_player == null:
		_chant_player = AudioStreamPlayer.new()
		_chant_player.bus = MUSIC_BUS
		add_child(_chant_player)
	_chant_player.stream = stream
	_chant_player.volume_db = volume_db
	_chant_player.play()
	print("[audiosynth] chant playing: %s" % path)


func stop_chant() -> void:
	if _chant_player != null:
		_chant_player.stop()
