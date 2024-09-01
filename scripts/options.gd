class_name Options
extends Control

var index := 0

@onready var indicator_music: Label = %IndicatorMusic
@onready var indicator_sfx: Label = %IndicatorSFX
@onready var bar_music: TextureRect = %BarMusic
@onready var bar_sfx: TextureRect = %BarSFX
@onready var demo_sfx: AudioStreamPlayer = $DemoSFX

@onready var indicators = [indicator_music, indicator_sfx]
@onready var bars = [bar_music, bar_sfx]
@onready var demo = [demo_sfx, demo_sfx]


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	GBtn.on_left.connect(_on_left)
	GBtn.on_right.connect(_on_right)

	update()


func _on_up():
	UiSounds.up()
	index = (index - 1 + indicators.size()) % indicators.size()
	print(index)
	update()


func _on_down():
	UiSounds.down()
	index = (index + 1) % indicators.size()
	print(index)
	update()


func _on_left():
	if index == 0:
		Settings.volume_music -= 1
	else:
		Settings.volume_sfx -= 1
	update()
	demo[index].play()


func _on_right():
	if index == 0:
		Settings.volume_music += 1
	else:
		Settings.volume_sfx += 1
	update()
	demo[index].play()


func update():
	for i in range(indicators.size()):
		var s := " "
		if i == index:
			s = ">"
		indicators[i].text = s

	bar_music.scale.x = Settings.volume_music / 10.0
	bar_sfx.scale.x = Settings.volume_sfx / 10.0
