extends Node2D

@export var scene_path = ""

var is_skipping = false
var is_backing

@onready var fader: Fader = $Fader
@onready var circle_skip := $Circles/Progress1
@onready var circle_back := $Circles/Progress2


func _ready() -> void:
	GBtn.on_a_hold.connect(_on_a_hold)
	GBtn.on_a_release.connect(_on_a_release)
	#GBtn.on_b_hold.connect(_on_b_hold)
	#GBtn.on_b_release.connect(_on_b_release)

	fade_in()


func _process(delta: float) -> void:
	is_skipping_to_next(delta)
	back_to_menu(delta)


func set_next_scence():
	SceneMgr.open(scene_path)


func exit_intro():
	SceneMgr.close()


func fade_in(timer = 1.0):
	fader.fade_in()
	await get_tree().create_timer(timer).timeout


func fade_out():
	fader.fade_out()
	await fader.fade_complete


func _on_a_hold():
	is_skipping = true


func _on_a_release():
	is_skipping = false


func _on_b_hold():
	is_backing = true


func _on_b_release():
	is_backing = false


func is_skipping_to_next(delta):
	circle_progression(delta, $A_button, circle_skip, is_skipping)

	if circle_skip.progress >= 100:
		#fade_out()
		fader.fade_out()
		await get_tree().create_timer(1.0).timeout
		set_next_scence()


func back_to_menu(delta):
	circle_progression(delta, $B_button, circle_back, is_backing)
	if circle_back.progress >= 100:
		fader.fade_out()
		await get_tree().create_timer(1.0).timeout
		exit_intro()


func circle_progression(delta: float, button, circle, is_progress):
	if is_progress:
		circle.visible = true
		button.visible = true
		circle.progress += delta * 50 if circle.progress < 100 else 0
	else:
		circle.visible = false
		button.visible = false
		circle.progress -= delta * 50 if circle.progress > 0 else 0
