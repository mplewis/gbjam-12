class_name CandyArrowFollower
extends PathFollow2D

@onready var hitbox: CollisionShape2D = $Body/Hitbox
@onready var up_sprite: AnimatedSprite2D = $Up
@onready var down_sprite: AnimatedSprite2D = $Down
@onready var left_sprite: AnimatedSprite2D = $Left
@onready var right_sprite: AnimatedSprite2D = $Right

var dirs = ["U", "D", "L", "R"]
@onready var sprites = [up_sprite, down_sprite, left_sprite, right_sprite]

## Goal position is based on the spawner's `progress` position
@onready var goal_progress_ratio := progress_ratio
## The target path onto which to spawn candies
@export var path: Path2D

var template := true
var rate_per_sec := 0.0  # how much to add to goal_pos per second
var dir_str := "?"


func _ready():
	assert(path, "Path to spawn onto must be set")
	progress = 0.0

	if template:
		return

	for s in sprites:
		if s.visible:
			s.play()


func _process(delta):
	if template:
		return

	progress_ratio = min(progress_ratio + rate_per_sec * delta, 1.0)
	if progress_ratio >= 1.0:
		queue_free()

	# HACK: For some reason the hitbox does not follow this node correctly.
	hitbox.global_position = global_position


func spawn(dir: int, to_hit_sec: float) -> CandyArrowFollower:
	var sprite: AnimatedSprite2D = sprites[dir]
	assert(sprite, "Invalid direction: %d" % dir)
	for s in sprites:
		if s == sprite:
			s.show()
		else:
			s.hide()

	var x = duplicate()
	x.template = false
	x.dir_str = dirs[dir]
	x.name = "CandyArrow"

	x.global_position = global_position
	x.rate_per_sec = goal_progress_ratio / to_hit_sec

	path.add_child(x)
	x.show()

	return x


func spawn_puntable() -> CandyArrowPuntable:
	var active_sprite: AnimatedSprite2D
	for s in sprites:
		if s.visible:
			active_sprite = s
			break
	assert(active_sprite, "No active sprite found to spawn puntable candy")

	var puntable: CandyArrowPuntable = active_sprite.get_child(0).duplicate()
	puntable.gravity_scale = 1.0
	puntable.global_position = global_position
	puntable.show()
	return puntable
