extends Node

const sfxLoPath := "res://assets/demo/sfx/3g.wav"
const sfxHiPath := "res://assets/demo/sfx/4c.wav"
const sfxUpPath := "res://assets/demo/sfx/4c-4f.wav"
const sfxDownPath := "res://assets/demo/sfx/4c-3g.wav"

var sfxLo := AudioStreamPlayer.new()
var sfxHi := AudioStreamPlayer.new()
var sfxUp := AudioStreamPlayer.new()
var sfxDown := AudioStreamPlayer.new()


func _ready():
	sfxLo.bus = "SFX"
	sfxHi.bus = "SFX"
	sfxUp.bus = "SFX"
	sfxDown.bus = "SFX"
	sfxLo.stream = load(sfxLoPath)
	sfxHi.stream = load(sfxHiPath)
	sfxUp.stream = load(sfxUpPath)
	sfxDown.stream = load(sfxDownPath)
	add_child(sfxLo)
	add_child(sfxHi)
	add_child(sfxUp)
	add_child(sfxDown)


func up():
	sfxLo.play()


func down():
	sfxHi.play()


func select():
	sfxUp.play()


func cancel():
	sfxDown.play()
