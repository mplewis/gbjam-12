class_name DialogueBox
extends Control

const FPS = 60  # just for calculating frames.

const FRAMES_PER_ARROW_TICK = 8  # higher = slower movement
const ARROW_TICK_DIST = 5  # 1 px/frame

const FRAMES_PER_CHAR = 3  # higher = slower typing

@onready var arrow: TextureRect = $Arrow
@onready var body: Label = %Text
@onready var orig_x: float = arrow.position.x

var now := 0.0
var last_goal_chars := 0

var last_body_height := 0.0
var last_line_split := 0
var line_splits: Array[int] = []  # which substr chars form newlines?

const demo_text = "This is some text for the dialogue box. Let's type together to fill it. This is a lot of text and it will take a lot of space to render!"


func _process(delta):
	now += delta
	_show_text()
	_move_arrow()


func _tick(f_now: float, frames_per_tick: int) -> int:
	return int(floor(f_now * FPS / frames_per_tick))


func _show_text():
	var goal_chars = _tick(now, FRAMES_PER_CHAR)
	if goal_chars <= last_goal_chars:
		return
	body.text = demo_text.substr(0, goal_chars)
	print(goal_chars, body.size)


func _move_arrow():
	arrow.position.x = orig_x + _tick(now, FRAMES_PER_ARROW_TICK) % ARROW_TICK_DIST
