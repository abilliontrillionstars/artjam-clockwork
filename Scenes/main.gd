extends Node2D

var BPM = 130 # aid in music syncing
var BEAT = -1
@onready var timer: Timer = self.find_child("Timer")
var elapsed = 0.0

@onready var placeholder_music = preload("res://Assets/music/start-loop-placeholder.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(1.0/(BPM/60.0))
	timer.timeout.connect(_on_timeout)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta

func _on_timeout():
	BEAT += 1
	# play metronome
	if BEAT%4 == 0: $AudioStreamPlayer.volume_db = -15
	else: $AudioStreamPlayer.volume_db = -30
	$AudioStreamPlayer.play()
	# play music loop
	if BEAT%32 == 0:
		$MusicPlayer.stop()
		$MusicPlayer.play()
