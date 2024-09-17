class_name CandyArrowFollower
extends PathFollow2D

@onready var up_sprite: AnimatedSprite2D = $Up
@onready var down_sprite: AnimatedSprite2D = $Down
@onready var left_sprite: AnimatedSprite2D = $Left
@onready var right_sprite: AnimatedSprite2D = $Right

@onready var sprites = [up_sprite, down_sprite, left_sprite, right_sprite]
@export var path: Path2D

var template = true
var rate_per_sec := 0.0  # how much to add to goal_pos per second


func _ready():
	assert(path, "Path to spawn onto must be set")

	if template:
		return

	progress = 0.0


func spawn(dir: int, to_hit_sec: float) -> CandyArrowFollower:
	print(dir)
	var sprite: AnimatedSprite2D = sprites[dir]
	assert(sprite, "Invalid direction: %d" % dir)
	for s in sprites:
		if s == sprite:
			s.show()
		else:
			s.hide()

	var x = duplicate()
	x.template = false

	x.global_position = global_position
	# Goal position is based on the spawner's `progress` position
	x.rate_per_sec = progress_ratio / to_hit_sec

	path.add_child(x)
	x.show()

	return x


func _process(delta):
	if template:
		return

	progress_ratio = min(progress_ratio + rate_per_sec * delta, 1.0)
	if progress_ratio >= 1.0:
		queue_free()
