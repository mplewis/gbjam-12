class_name Game
extends Node2D

var frame = 0

@onready var player: CharacterBody2D = $Player


func _process(delta):
	# for x in range(delta * 60):  # HACK
	frame += 1
	player.position.x += 1
