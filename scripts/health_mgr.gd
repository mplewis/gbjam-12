extends Node
@warning_ignore("UNUSED_SIGNAL")
signal on_health_drain
@warning_ignore("UNUSED_SIGNAL")
signal on_health_reset

@onready var health_max = 100.0
@onready var health = health_max
@onready var health_drain = 10.0
