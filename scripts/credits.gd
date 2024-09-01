class_name Credits
extends Control

@onready var title_label: Label = %Title
@onready var body_label: Label = %Body
@onready var arrow_left: TextureRect = %ArrowLeft
@onready var arrow_right: TextureRect = %ArrowRight
@onready var hint_right: Label = %HintRight

var page = 0
var pages = [
	["Matt Lewis", ["mplewis.com", "https://mplewis.com"], ["Game Design", "Programming"]],
	["Poopsy", null, ["Art Design", "Music"]],
	[
		"Moopsy",
		null,
		[
			"Moral Support",
			"Cheerleading",
			"Impromptu Therapy",
			"Grocery Getting",
			"Ranked Smurfing",
			"General Pranks"
		]
	],
]


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_left.connect(_on_left)
	GBtn.on_right.connect(_on_right)
	GBtn.on_a.connect(_on_a)
	GBtn.on_b.connect(_on_b)
	update_page()


func _on_left():
	if page > 0:
		UiSounds.up()
		page -= 1
		update_page()


func _on_right():
	if page < pages.size() - 1:
		UiSounds.down()
		page += 1
		update_page()


func _on_a():
	var link = pages[page][1]
	if !link:
		return
	var url: String = link[1]
	OS.shell_open(url)


func _on_b():
	SceneMgr.close()


func update_page():
	var p = pages[page]
	var link = p[1]

	if link:
		title_label.text = "\n".join([p[0], link[0]])
	else:
		title_label.text = p[0]

	body_label.text = "\n".join(p[2])
	hint_right.visible = !!link
	arrow_left.visible = page > 0
	arrow_right.visible = page < pages.size() - 1
