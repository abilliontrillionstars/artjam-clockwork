extends Node2D

var BPM = 130 # aid in music syncing
var BEAT = -1
@onready var timer: Timer = self.find_child("Timer")
var elapsed = 0.0
var last_beat = -1
var score: int = 0

var song_position: float = 0.0
var hit_notes = [] # notes that have already been hit

# Map of when to hit which key
var track_actions: Dictionary[int, String] = {
	16 : "left",
	17 : "left",
	18 : "right",
	
	20 : "swap",
	23 : "swap",
	
	24 : "right",
	25 : "left",
	26 : "right",
	
	28 : "swap",
	31 : "swap",
}

# Dictionary mapping closeness thresholds
var closeness_threshold: Dictionary[String, float] = {	
	"Perfect": 0.15, 
	"Good": 0.25,
	"OK": 0.35
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(1.0/(BPM/60.0))
	timer.timeout.connect(_on_beat)
		
func _process(delta: float) -> void:
	elapsed += delta
	
	 # Calculate the elapsed beat time and beat position in song
	var seconds_per_beat = 60.0 / BPM
	var time_since_beat = elapsed - last_beat
	song_position = BEAT + (time_since_beat / seconds_per_beat)
	
	handle_input()
	
	$backdropIndoor/gear4.rotate(delta*2)
	$backdropIndoor/gear4_2.rotate(delta*-2)
	$backdropIndoor/spur8.rotate(delta*1.5)
	$backdropIndoor/spur8_2.rotate(delta*-1.5)
	
	if Input.is_action_just_pressed("mouse_click"):
		print(get_global_mouse_position())

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
	if track_actions.get(BEAT) == "swap":
		if $backdropIndoor.visible:
			$backdropTower.visible = true
			$backdropIndoor.visible = false
		else:
			$backdropTower.visible = false
			$backdropIndoor.visible = true
	
func handle_input():
	if Input.is_action_just_pressed("Left Hammer"):
		$HammerSounds.pitch_scale = 0.8 + randf()/20
		$HammerSounds.play(0.28)
		print("Song Position (in beats): ", snappedf(song_position, 0.001))
		check_hit("left")
			
	if Input.is_action_just_pressed("Right Hammer"):
		$HammerSounds.pitch_scale = 1.2 + randf()/20
		$HammerSounds.play(0.28)
		print("Song Position (in beats): ", snappedf(song_position, 0.001))
		check_hit("right")
			
# Calculate how close player is to the beat
func check_hit(side):
	var current_beat = round(song_position)
	var prev_beat = current_beat - 1
	var next_beat = current_beat + 1
	
	var hit = false
	
	# Check current beat
	if current_beat in track_actions and track_actions[current_beat] == side:
		if current_beat in hit_notes:
			return
		var closeness = abs(song_position - current_beat)
		if closeness <= closeness_threshold["OK"]:
			score_hit(closeness, side, current_beat)
			hit = true
			
	# If late
	if not hit and prev_beat in track_actions and track_actions[prev_beat] == side:
		if prev_beat in hit_notes:
			return
		var closeness = abs(song_position - prev_beat)
		if closeness <= closeness_threshold["OK"]:
			score_hit(closeness, side, prev_beat)
			hit = true
			
	# If early
	if not hit and next_beat in track_actions and track_actions[next_beat] == side:
		if next_beat in hit_notes:
			return
		var closeness = abs(song_position - next_beat)
		if closeness <= closeness_threshold["OK"]:
			score_hit(snappedf(closeness, 0.001), side, next_beat)
			hit = true
	
	# No note nearby
	if not hit:
		score -= 50
		print("Score: ", score)
		
# Apply scores based on hit closeness	
func score_hit(closeness, side, beat_hit):
	hit_notes.append(beat_hit)
	
	if closeness <= closeness_threshold["Perfect"]:
		score += 500
		print("Perfect: ", snappedf(closeness, 0.001), " from the time. On the ", side.to_upper(), " side")
	elif closeness <= closeness_threshold["Good"]:
		score += 250
		print("Good: ", snappedf(closeness, 0.001), " from the time. On the ", side.to_upper(), " side")
	elif closeness <= closeness_threshold["OK"]:
		score += 100
		print("OK: ", snappedf(closeness, 0.001), " from the time. On the ", side.to_upper(), " side")

# TODO: Have a node that will move around the gear at a constant speed
# 	Change colors (red to gold) when it reaches a certain spot
#	Radius for right gear: ~200
#	Radius for left gear: ~100

# TODO: Maybe make it where they can't hit the hammer multiple times per beat
