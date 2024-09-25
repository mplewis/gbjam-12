## Cheats menu that allows everyone to see all the endings.

class_name Cheats
extends Control

var menu_items := {
	"bad_end": "Play Bad Ending",
	"good_end": "Play Good Ending",
	"true_end": "Play True Ending",
}
var selected := 0

@onready var menu_items_label: Label = %MenuItems


func _ready():
	GBtn.on_up.connect(up)
	GBtn.on_down.connect(down)
	GBtn.on_a.connect(select)
	GBtn.on_b.connect(back)
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


func back():
	CampaignMgr.reset_game()


func _on_menu_bad_end():
	SceneMgr.open("cinematics/bad_ending")


func _on_menu_good_end():
	SceneMgr.open("cinematics/good_ending")


func _on_menu_true_end():
	SceneMgr.open("cinematics/true_ending")
