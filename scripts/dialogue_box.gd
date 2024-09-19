@tool
class_name DialogueBox
extends Control

const FPS = 60  # just for calculating frames.
const MAX_LINES = 3  # size of dialogue box
const FRAMES_PER_ARROW_TICK = 8  # higher = slower movement
const ARROW_TICK_DIST = 4  # 1 px/frame
const FRAMES_PER_CHAR = 2  # higher = slower typing
const SCREEN_BOTTOM = 144  # Y coordinate of bottom of screen, where our dialog aligns

@export var height := 64  # height in px of dialogue box

## The text to display in the dialogue box.
@export var text: String = ""

@onready var bg: TextureRect = %BG
@onready var pos: Control = %Pos
@onready var box: NinePatchRect = %Box
@onready var arrow: TextureRect = %Arrow
@onready var body: Label = %Text

@onready var orig_x: float = arrow.position.x

var start_idx := 0
var now := 0.0
var last_goal_chars := 0
var complete := false


func _ready():
	body.text = ""
	arrow.hide()
	DialogueMgr.on_advance.connect(_on_advance)


func _process(delta):
	now += delta

	_position_bottom()
	bg.size.y = height
	box.size.y = height

	_show_text()
	_move_arrow()


func _position_bottom():
	pos.position.y = SCREEN_BOTTOM - box.size.y


func _tick(f_now: float, frames_per_tick: int) -> int:
	return int(floor(f_now * FPS / frames_per_tick))


func _show_text():
	if complete:
		if body.text.length() < text.length():
			body.text = text
		return

	var goal_chars = _tick(now, FRAMES_PER_CHAR)
	if goal_chars <= last_goal_chars:
		return
	body.text = text.substr(start_idx, goal_chars)


func _move_arrow():
	if body.text.length() < text.length():
		return
	arrow.show()
	arrow.position.x = (
		orig_x + _tick(now, FRAMES_PER_ARROW_TICK) % ARROW_TICK_DIST - ARROW_TICK_DIST
	)


func _on_advance() -> bool:
	if not complete:
		complete = true
		return false

	DialogueMgr.on_close.emit()
	queue_free()
	return true
