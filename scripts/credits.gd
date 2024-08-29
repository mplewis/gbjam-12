class_name Credits
extends Control

@onready var sfx_left: AudioStreamPlayer = $SFX/Left
@onready var sfx_right: AudioStreamPlayer = $SFX/Right
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
var pressed = {
	"left": false,
	"right": false,
	"a": false,
}


func _ready():
	SceneMgr.set_appropriate_window_size()
	update_page()

	pressed["left"] = Input.is_action_pressed("ui_left")
	pressed["right"] = Input.is_action_pressed("ui_right")
	pressed["a"] = Input.is_action_pressed("ui_gameboy_a")


func _process(_delta):
	if Input.is_action_pressed("ui_gameboy_b"):
		SceneMgr.close()

	if Input.is_action_pressed("ui_left"):
		if !pressed["left"]:
			pressed["left"] = true
			sfx_left.play()
			page = max(0, page - 1)
			update_page()
	else:
		pressed["left"] = false

	if Input.is_action_pressed("ui_right"):
		if !pressed["right"]:
			pressed["right"] = true
			sfx_right.play()
			page = min(pages.size() - 1, page + 1)
			update_page()
	else:
		pressed["right"] = false

	if Input.is_action_pressed("ui_gameboy_a"):
		if !pressed["a"]:
			pressed["a"] = true
			var link = pages[page][1]
			if !link:
				return
			var url: String = link[1]
			OS.shell_open(url)
	else:
		pressed["a"] = false


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
