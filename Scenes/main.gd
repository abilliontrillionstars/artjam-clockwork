extends Node2D

var BPM = 130 # aid in music syncing
var BEAT = -1
@onready var timer: Timer = self.find_child("Timer")
var elapsed = 0.0
var last_beat = -1
var score: int = 0

var song_position: float = 0.0

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
	"OK": 0.49, 
	"Good": 0.25,
	"Perfect": 0.15
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
	
	$backdropIndoor/gear4.rotate(delta*2)
	$backdropIndoor/gear4_2.rotate(delta*-2)
	$backdropIndoor/spur8.rotate(delta*1.5)
	$backdropIndoor/spur8_2.rotate(delta*-1.5)

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
		print("Song Position (in beats): ", song_position)
		if round(song_position) in track_actions.keys():
			var closeness = abs(song_position - round(song_position))
			check_hit(closeness, "left")
			
	if Input.is_action_just_pressed("Right Hammer"):
		$HammerSounds.pitch_scale = 1.2 + randf()/20
		$HammerSounds.play(0.28)
		print("Song Position (in beats): ", song_position)
		if round(song_position) in track_actions.keys():
			var closeness = abs(song_position - round(song_position))
			check_hit(closeness, "right")
			
# Calculate how close player is to the beat
func check_hit(closeness, side):
		# Round to closest whole number beat
			# Check which threshold it is between
			# Logic:
				# 	If less than OK, but not less than Good, then it is OK
				#	If less than Good, but not less than Perfect, then it is Good
				#	If less than Perfect, then Perfect
				
			# TODO: What if they miss? More than 0.49 seconds but then it would go to next, potential bug? 
			# Maybe track the most recent one they needed to hit, if that one is not hit, don't check it as round(song_position)???
			# Red forman
			if closeness <= closeness_threshold["OK"] && not closeness <= closeness_threshold["Good"]:
				score += 100
				print("OK: ", closeness, " from the time. On the ", side.to_upper(), " side")
				print(score)
			elif closeness <= closeness_threshold["Good"] && not closeness <= closeness_threshold["Perfect"]:
				score += 250
				print("Good: ", closeness, " from the time. On the ", side.to_upper(), " side")
				print(score)
			elif closeness <= closeness_threshold["Perfect"]:
				score += 500
				print("Perfect: ", closeness, "from the time. On the ", side.to_upper(), " side")
				print(score)
