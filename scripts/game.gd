class_name Game
extends Node2D

const FWD_RATE = 120
const JUMP_RATE = 120
const GRAVITY_RATE = 480
const WINDOW_SCALE = 8

var button_states = {
	"jump": false,
}

var player_up_vel := 0.0

@onready var player: CharacterBody2D = $Player
@onready var jump_sfx: AudioStreamPlayer2D = $Player/JumpSFX

@onready var floor_y := player.position.y


func _ready():
	if OS.get_name() != "Web":
		get_window().size *= Vector2i(WINDOW_SCALE, WINDOW_SCALE)


func _process(delta):
	player.position.x += FWD_RATE * delta
	if Input.is_action_pressed("ui_gameboy_a"):
		jump()
	else:
		button_states["jump"] = false

	player_up_vel -= GRAVITY_RATE * delta
	player.position.y -= player_up_vel * delta
	if player.position.y > floor_y:
		player.position.y = floor_y


func jump():
	if button_states["jump"]:
		return
	button_states["jump"] = true

	if player.position.y != floor_y:
		return

	jump_sfx.play()
	player_up_vel = JUMP_RATE
