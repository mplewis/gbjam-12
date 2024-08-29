class_name Menu
extends Control

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

var menu_items := {
	"roadtrip": "Road Trip",
	"danceoff": "Dance-Off",
	"options": "Options",
	"credits": "Credits",
}
var selected := 0

@onready var menu_items_label: Label = %MenuItems
@onready var sfx_up: AudioStreamPlayer = $SFX/Up
@onready var sfx_down: AudioStreamPlayer = $SFX/Down
@onready var sfx_select: AudioStreamPlayer = $SFX/Select
@onready var sfx_back: AudioStreamPlayer = $SFX/Back


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_up.connect(up)
	GBtn.on_down.connect(down)
	GBtn.on_a.connect(select)
	update_menu()


func safe_call(f: String) -> void:
	if has_method(f):
		call(f)


func update_menu():
	var items = menu_items.values()
	items[selected] = "> %s <" % items[selected]
	menu_items_label.text = "\n".join(items)


func up():
	sfx_up.play()
	selected = (selected - 1) % menu_items.size()
	update_menu()


func down():
	sfx_down.play()
	selected = (selected + 1) % menu_items.size()
	update_menu()


func select():
	sfx_select.play()
	var item = menu_items.keys()[selected]
	safe_call("_on_menu_%s" % item)


func _on_menu_roadtrip():
	SceneMgr.open("roadtrip")


func _on_menu_danceoff():
	SceneMgr.open("danceoff")


func _on_menu_options():
	print("Not implemented")


func _on_menu_credits():
	SceneMgr.open("credits")
