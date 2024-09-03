@tool
class_name Goal
extends Node2D

enum SCORE { GREAT, GOOD, OK, MISS }

@export var sprite_rotation_deg: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var score_great: Area2D = $ScoreGreat
@onready var score_good: Area2D = $ScoreGood
@onready var score_ok: Area2D = $ScoreOK


func _process(_delta):
	sprite.rotation_degrees = sprite_rotation_deg


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
