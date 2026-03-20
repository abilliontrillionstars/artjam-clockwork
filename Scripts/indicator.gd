extends Node2D

@onready var sprite: Sprite2D = get_node("Sprite")
@onready var gear: Node2D = get_node("rg_center")

var orbit_radius: float = 100.0
var orbit_speed: float = 2.0
var current_angle: float = 0.0

func _ready() -> void:
	current_angle = 0.0
	var offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	position = gear.position + offset

func _process(delta: float) -> void:
	current_angle += orbit_speed * delta
	
	var offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	position = gear.position + offset
