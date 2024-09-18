@tool
class_name CandyArrowPuntable
extends RigidBody2D

const UP_STR = 300
const RIGHT_STR = 120

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox

@export var texture: Texture2D


func _ready():
	hitbox.global_position = global_position
	sprite.texture = texture
	linear_velocity = Vector2(randf_range(RIGHT_STR * 0.9, RIGHT_STR * 1.1), -UP_STR)


func _physics_process(_delta: float):
	pass
