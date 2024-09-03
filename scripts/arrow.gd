class_name Arrow
extends RigidBody2D

const TIME_AFTER_GOAL_SEC = 0.5

@export var goal: Node2D
@export var duration_to_goal_sec: float = 1.0
@export var active: bool = false

var alive_sec: float = 0.0
var lifetime_sec: float = duration_to_goal_sec + TIME_AFTER_GOAL_SEC

var velocity: Vector2


func _to_string():
	return "<Arrow -> %s>" % goal.name


func _physics_process(delta):
	if !active:
		return

	if alive_sec >= lifetime_sec:
		queue_free()
		return

	alive_sec += delta
	var dist = global_position.distance_to(goal.global_position)
	if dist > 1.0:  # Allow arrows to fly past the goal
		var remain_sec = duration_to_goal_sec - alive_sec
		var speed = dist / remain_sec * delta
		var dir = (goal.global_position - global_position).normalized()
		velocity = dir * speed
	move_and_collide(velocity)
