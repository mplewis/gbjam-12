@tool
class_name CandyArrow
extends RigidBody2D

const OLD_AGE = 5.0
const DIR_SPRITES = ["L", "R", "U", "D"]

@export var label := "?"
@export var goal: Node2D = null
@export var duration_to_goal_sec: float = 0.0
@export var active := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label_node: Label = $Label

var punted := false
var alive_sec := 0.0
var reached_goal := false
var vel: Vector2 = Vector2.ZERO


func _ready():
	assert(label in DIR_SPRITES)
	assert(duration_to_goal_sec > 0.0)
	sprite.frame = DIR_SPRITES.find(label)
	label_node.text = label


func _process(delta: float):
	if not active:
		return

	if punted:
		move_and_collide(vel)
		# apply gravity
		vel += Vector2(0, 1) * 9.8 * delta
		return

	alive_sec += delta
	if alive_sec > OLD_AGE:
		queue_free()
		return

	if not reached_goal:
		var remain_to_goal_sec = duration_to_goal_sec - alive_sec
		var speed = (global_position.x - goal.global_position.x) / remain_to_goal_sec * delta
		var dir = (goal.global_position - global_position).normalized()
		vel = dir * speed

	move_and_collide(vel)

	if not reached_goal:
		reached_goal = global_position.distance_to(goal.global_position) < 2.0


func punt():
	punted = true
	gravity_scale = 1.0
	vel = Vector2(2, -2)
