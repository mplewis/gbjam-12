class_name Menu
extends Control

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

var menu_items := {
	"dance": "Dance Dance",
	"drum_kit": "Spider",
	"calibrate": "Audio Calibration",
	"options": "Options",
	"dialogue": "Show dialogue box",
	"credits": "Credits",
}
var selected := 0

@onready var menu_items_label: Label = %MenuItems


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
	UiSounds.up()
	selected = (selected - 1) % menu_items.size()
	update_menu()


func down():
	UiSounds.down()
	selected = (selected + 1) % menu_items.size()
	update_menu()


func select():
	UiSounds.select()
	var item = menu_items.keys()[selected]
	safe_call("_on_menu_%s" % item)


func _on_menu_roadtrip():
	SceneMgr.open("roadtrip")


func _on_menu_drum_kit():
	SceneMgr.open("drum_kit")


func _on_menu_dance():
	SceneMgr.open("dance")


func _on_menu_calibrate():
	SceneMgr.open("calibrate")


func _on_menu_options():
	SceneMgr.open("options")


func _on_menu_dialogue():
	DialogueMgr.show("Welcome to the main menu! I'm a dummy dialogue box with some text.")


func _on_menu_credits():
	SceneMgr.open("credits")
