@tool
class_name CandyArrowPuntable
extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite
@export var texture: Texture2D


func _ready():
	sprite.texture = texture
	linear_velocity = Vector2(200, -100)


func _physics_process(_delta: float):
	pass
