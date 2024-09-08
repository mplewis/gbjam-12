@tool
class_name Goal
extends Node2D

enum SCORE { GREAT, GOOD, OK, MISS }

signal on_miss(body: Node2D)

@export var sprite_rotation_deg: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var score_great: Area2D = $ScoreGreat
@onready var score_good: Area2D = $ScoreGood
@onready var score_ok: Area2D = $ScoreOK
@onready var catch_miss: Area2D = $CatchMiss


func _ready():
	sprite.rotation_degrees = sprite_rotation_deg
	catch_miss.body_entered.connect(_on_miss)


func _on_miss(body: Node2D):
	on_miss.emit(body)


func score() -> SCORE:
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
