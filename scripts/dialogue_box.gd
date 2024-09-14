class_name DialogueBox
extends Control

const FPS = 60  # just for calculating frames.
const MAX_LINES = 3  # size of dialogue box
const FRAMES_PER_ARROW_TICK = 8  # higher = slower movement
const ARROW_TICK_DIST = 4  # 1 px/frame
const FRAMES_PER_CHAR = 2  # higher = slower typing
const SCREEN_BOTTOM = 144  # Y coordinate of bottom of screen, where our dialog aligns

@onready var box: NinePatchRect = $Box
@onready var arrow: TextureRect = $Arrow
@onready var body: Label = %Text
@onready var orig_x: float = arrow.position.x

var start_idx := 0
var now := 0.0
var last_goal_chars := 0

const demo_text = "Some text goes in this box to show what text looks like when typed. Type more text until the box is full! The text will keep typing."


func _ready():
	_position_bottom()
	body.text = ""
	arrow.hide()


func _process(delta):
	now += delta
	_show_text()
	_move_arrow()


func _position_bottom():
	position.y = SCREEN_BOTTOM - box.size.y


func _tick(f_now: float, frames_per_tick: int) -> int:
	return int(floor(f_now * FPS / frames_per_tick))


func _show_text():
	var goal_chars = _tick(now, FRAMES_PER_CHAR)
	if goal_chars <= last_goal_chars:
		return

	body.text = demo_text.substr(start_idx, goal_chars)


func _move_arrow():
	if body.text.length() < demo_text.length():
		return
	arrow.show()
	arrow.position.x = orig_x + _tick(now, FRAMES_PER_ARROW_TICK) % ARROW_TICK_DIST
