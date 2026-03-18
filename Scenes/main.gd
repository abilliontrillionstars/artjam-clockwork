extends Node2D

var BPM = 30
var BEAT = 0
@onready var timer: Timer = self.find_child("Timer")

var elapsed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(1.0/(BPM/60.0))
	timer.timeout.connect(_on_timeout)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta

func _on_timeout():
	print("tick ", elapsed)
	BEAT += 1
	$AudioStreamPlayer.play()
	
