class_name Roadtrip
extends Node2D

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

var player_fwd_vel: float = BASE_SPEED
var player_up_vel := 0.0

@onready var player: CharacterBody2D = $Player
@onready var jump_sfx: AudioStreamPlayer2D = $Player/JumpSFX
@onready var turbo_sfx: AudioStreamPlayer2D = $Player/TurboSFX

@onready var floor_y := player.position.y


func _process(delta):
	GBtn.on_a.connect(jump)
	GBtn.on_b.connect(turbo)
	GBtn.on_start.connect(close)

	player_up_vel -= GRAVITY_STR * delta
	player.position.y = min(floor_y, player.position.y - player_up_vel * delta)

	player.position.x += player_fwd_vel * delta
	player_fwd_vel = max(BASE_SPEED, player_fwd_vel - DECEL_STR * delta)


func jump():
	if player.position.y != floor_y:
		return
	jump_sfx.play()
	player_up_vel = JUMP_STR


func turbo():
	if player_fwd_vel > BASE_SPEED:
		return
	turbo_sfx.play()
	player_fwd_vel *= TURBO_MULT


func close():
	SceneMgr.close()
