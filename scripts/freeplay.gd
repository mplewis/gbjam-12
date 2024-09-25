## Menu to select a game to play in freeplay mode, outside of the campaign.

class_name Freeplay
extends Control

var menu_items := {"trex": "T-Rex Candy", "vampire": "Vampire Dodge", "spider": "Spider Drum Solo"}
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
	SceneMgr.close()


func _on_menu_trex():
	CampaignMgr.start_freeplay(CampaignMgr.Game.T_REX)


func _on_menu_vampire():
	CampaignMgr.start_freeplay(CampaignMgr.Game.VAMPIRE)


func _on_menu_spider():
	CampaignMgr.start_freeplay(CampaignMgr.Game.SPIDER)
