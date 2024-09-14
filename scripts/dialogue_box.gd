class_name DialogueBox
extends Control

const FPS = 60  # just for calculating frames.
const FRAMES_PER_ARROW_TICK = 8  # higher = slower movement
const ARROW_TICK_DIST = 5  # 1 px/frame

@onready var arrow: TextureRect = $Arrow
@onready var orig_x: float = arrow.position.x

var now := 0.0


func _process(delta):
	now += delta
	arrow.position.x = orig_x + int(floor(now * FPS / FRAMES_PER_ARROW_TICK)) % ARROW_TICK_DIST
