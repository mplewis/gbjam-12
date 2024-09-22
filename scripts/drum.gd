extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


@onready var player_objects = [$kick, $snare, $high_tom, $tom, $low_tom]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func tom() -> void:
	$tom.position.y = -20


func high_tom() -> void:
	$high_tom.position.y = -20


func low_tom() -> void:
	$low_tom.position.y = -20


func kick() -> void:
	$kick.scale = Vector2(1.2, 1.2)


func snare() -> void:
	$snare.position.y = -20


func crash() -> void:
	$crash.position.y = -20


func splash() -> void:
	$splash.position.y = -40


var shake_time_start = 0
var shake_time_wait = 5.0 / 60.0
var is_shake_wait = false
var shake_vector = Vector2.LEFT
var shake_length = 1.0


func shake_object(index) -> void:
	var shooken = player_objects[index]
	if !is_shake_wait:  #singleton
		shake_time_wait = Time.get_ticks_msec()
		is_shake_wait = true

	if is_shake_wait && shake_time_start + shake_time_wait < Time.get_ticks_msec():
		shake_vector *= -1
		is_shake_wait = false
	shooken.position += shake_vector * shake_length


func _process(delta) -> void:
	$kick.scale = lerp($kick.scale, Vector2(1, 1), delta * 10.0)
	$crash.position.y = lerp($crash.position.y, 0.0, delta * 10.0)
	$snare.position.y = lerp($snare.position.y, 0.0, delta * 10.0)
	$tom.position.y = lerp($tom.position.y, 0.0, delta * 10.0)

	$high_tom.position.y = lerp($high_tom.position.y, 0.0, delta * 10.0)
	$low_tom.position.y = lerp($low_tom.position.y, 0.0, delta * 10.0)
	$splash.position.y = lerp($splash.position.y, 0.0, delta * 10.0)

	$kick.position.x = lerp($kick.position.x, 0.0, delta * 10.0)

	$snare.position.x = lerp($snare.position.x, 0.0, delta * 10.0)
	$tom.position.x = lerp($tom.position.x, 0.0, delta * 10.0)

	$high_tom.position.x = lerp($high_tom.position.x, 0.0, delta * 10.0)
	$low_tom.position.x = lerp($low_tom.position.x, 0.0, delta * 10.0)
