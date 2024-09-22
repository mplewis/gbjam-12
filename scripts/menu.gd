class_name Menu
extends Control

const BASE_SPEED = 120
const TURBO_MULT = 3.0
const DECEL_STR = 240
const JUMP_STR = 120
const GRAVITY_STR = 480

var menu_items := {
	"campaign": "New Game",
	"calibrate": "Audio Calibration",
	"options": "Options",
	"credits": "Credits",
}
var selected := 0

@onready var menu_items_label: Label = %MenuItems


func _ready():
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


func _on_menu_campaign():
	CampaignMgr.start_campaign()


func _on_menu_calibrate():
	SceneMgr.open("ui/calibrate")


func _on_menu_options():
	SceneMgr.open("ui/options")


func _on_menu_credits():
	SceneMgr.open("ui/credits")
