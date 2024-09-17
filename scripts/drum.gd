extends Node2D



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func tom() -> void:
	$tom.position.y = -20

func kick() -> void:
	$kick.scale = Vector2(1.2, 1.2)

func snare() -> void:
	$snare.position.y = -20
	
func crash() -> void:
	$crash.position.y = -20
	
func hat_closed() -> void:
	$hat.position.y = -20

func splash() -> void:
	$splash.position.y = -40

func _process(delta) -> void:
	$kick.scale = lerp($kick.scale, Vector2(1, 1), delta * 10.0)
	$snare.position.y = lerp($snare.position.y, 0.0, delta * 10.0)
	$tom.position.y = lerp($tom.position.y, 0.0, delta * 10.0)
	$crash.position.y = lerp($crash.position.y, 0.0, delta * 10.0)
	
	$hat.position.y = lerp($hat.position.y, 0.0, delta * 10.0)
	$splash.position.y = lerp($splash.position.y, 0.0, delta * 10.0)
