@tool
class_name Goal
extends Node2D

signal on_miss(body: Node2D)

enum SCORE { GREAT, GOOD, OK, MISS }
const BLINK_DURATION = 0.05

@export var sprite_rotation_deg: float = 0.0

var blink_until = null

@onready var sprite: Sprite2D = $Sprite
@onready var score_great: Area2D = $ScoreGreat
@onready var score_good: Area2D = $ScoreGood
@onready var score_ok: Area2D = $ScoreOK
@onready var catch_miss: Area2D = $CatchMiss
@onready var blink: ColorRect = $Blink


func _ready():
	sprite.rotation_degrees = sprite_rotation_deg
	catch_miss.body_entered.connect(_on_miss)


func _process(_delta):
	if blink_until and Time.get_ticks_msec() / 1000.0 > blink_until:
		blink_until = null
		blink.hide()


func _on_miss(body: Node2D):
	on_miss.emit(body)


func score() -> SCORE:
	blink_until = Time.get_ticks_msec() / 1000.0 + BLINK_DURATION
	blink.show()

	var great: Array[Node2D] = score_great.get_overlapping_bodies()
	var good: Array[Node2D] = score_good.get_overlapping_bodies()
	var ok: Array[Node2D] = score_ok.get_overlapping_bodies()

	var bodies: Array[Node2D] = []
	var s: SCORE = SCORE.MISS
	if great.size() > 0:
		s = SCORE.GREAT
		bodies = great
	elif good.size() > 0:
		s = SCORE.GOOD
		bodies = good
	elif ok.size() > 0:
		s = SCORE.OK
		bodies = ok

	for body in bodies:
		body.queue_free()

	return s
