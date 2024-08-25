class_name Game
extends Node2D

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

const WINDOW_SCALE = 8

var button_states = {
	"jump": false,
	"turbo": false,
}

var player_fwd_vel: float = BASE_SPEED
var player_up_vel := 0.0

@onready var player: CharacterBody2D = $Player
@onready var jump_sfx: AudioStreamPlayer2D = $Player/JumpSFX
@onready var turbo_sfx: AudioStreamPlayer2D = $Player/TurboSFX

@onready var floor_y := player.position.y


func _ready():
	if OS.get_name() != "Web":
		get_window().size *= Vector2i(WINDOW_SCALE, WINDOW_SCALE)


func _process(delta):
	if Input.is_action_pressed("ui_gameboy_a"):
		jump()
	else:
		button_states["jump"] = false

	if Input.is_action_pressed("ui_gameboy_b"):
		turbo()
	else:
		button_states["turbo"] = false

	player_up_vel -= GRAVITY_STR * delta
	# player.position.y -= player_up_vel * delta
	# if player.position.y > floor_y:
	# 	player.position.y = floor_y
	player.position.y = min(floor_y, player.position.y - player_up_vel * delta)

	player.position.x += player_fwd_vel * delta
	if player_fwd_vel > BASE_SPEED:
		player_fwd_vel = max(BASE_SPEED, player_fwd_vel - DECEL_STR * delta)


func jump():
	if player.position.y != floor_y:
		return

	if button_states["jump"]:
		return
	button_states["jump"] = true

	jump_sfx.play()
	player_up_vel = JUMP_STR


func turbo():
	if player_fwd_vel > BASE_SPEED:
		return

	if button_states["turbo"]:
		return
	button_states["turbo"] = true

	turbo_sfx.play()
	player_fwd_vel *= TURBO_MULT
