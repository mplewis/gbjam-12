extends Node

@warning_ignore("UNUSED_SIGNAL")
signal on_health_drain
@warning_ignore("UNUSED_SIGNAL")
signal on_health_reset

@onready var health_max = 100
@onready var health_drain := 10
var difficult_scale = 1
var health = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = health_max
	pass # Replace with function body.

func _process(delta: float) -> void:
	health_drain /= difficult_scale
