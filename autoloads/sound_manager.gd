extends Node
## Autoload: SoundManager
## Reproducción centralizada de música y SFX.
## Requiere buses de audio "Music" y "SFX" (Audio > Bus Layout) para el mezclado por categoría.

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	music_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	add_child(music_player)
	sfx_player.bus = "SFX"
	music_player.bus = "Music"

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()

func play_music(stream: AudioStream) -> void:
	if stream == null or music_player.stream == stream:
		return
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()
