class_name Game
extends Node2D

const RATE = 120
const WINDOW_SCALE = 8

@onready var player: CharacterBody2D = $Player


func _ready():
	if OS.get_name() != "Web":
		get_window().size *= Vector2i(WINDOW_SCALE, WINDOW_SCALE)


func _process(delta):
	player.position.x += RATE * delta
