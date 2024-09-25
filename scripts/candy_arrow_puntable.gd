## When the candy arrow is punched by the player, we create a copy of the candy with
## the no-arrow sprite, then apply gravity and kick it toward the dinosaur's mouth.

@tool
class_name CandyArrowPuntable
extends RigidBody2D

const UP_STR = 300
const RIGHT_STR = 100

@export var texture: Texture2D

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox


func _ready():
	hitbox.global_position = global_position
	sprite.texture = texture
	linear_velocity = Vector2(_rand_str(RIGHT_STR), _rand_str(-UP_STR))


func _physics_process(_delta: float):
	pass


func _rand_str(base: float) -> float:
	return randf_range(base * 0.9, base * 1.1)
