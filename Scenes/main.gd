extends Node2D

var BPM = 130 # aid in music syncing
var BEAT = -1
@onready var timer: Timer = self.find_child("Timer")
var elapsed = 0.0
var last_beat = -1

var song_position: float = -1.0

# Map of when to hit which key
var track_actions: Dictionary[int, String] = {
	16 : "left",
	17 : "left",
	18 : "right",
	
	24 : "right",
	25 : "left",
	26 : "right"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(1.0/(BPM/60.0))
	timer.timeout.connect(_on_beat)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta
	
	var seconds_per_beat = 60.0 / BPM
	var time_since_beat = elapsed - last_beat
	song_position = BEAT + (time_since_beat / seconds_per_beat)
	
	handle_input()

func _on_beat():
	BEAT += 1
	last_beat = elapsed
	# play metronome
	if BEAT%4 == 0: $AudioStreamPlayer.volume_db = -15
	else: $AudioStreamPlayer.volume_db = -30
	$AudioStreamPlayer.play()
	# play music loop
	if BEAT%32 == 0:
		$MusicPlayer.stop()
		$MusicPlayer.play()
		# track looping
		if BEAT == 32: BEAT = 0
	
	# check for track actions

func handle_input():
	if Input.is_action_just_pressed("Left Hammer"):
		$HammerSounds.pitch_scale = 0.8 + randf()/20
		$HammerSounds.play(0.28)
		print("left: ", elapsed - last_beat + BEAT)
		print("Song Position (in beats): ", song_position)
	if Input.is_action_just_pressed("Right Hammer"):
		$HammerSounds.pitch_scale = 1.2 + randf()/20
		$HammerSounds.play(0.28)
		print("right: ", elapsed - last_beat + BEAT)
		print("Song Position (in beats): ", song_position)
