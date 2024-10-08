## Options menu which allows the user to set Music and SFX volume.

class_name Options
extends Control

var index := 0

@onready var indicator_music: Label = %IndicatorMusic
@onready var indicator_sfx: Label = %IndicatorSFX
@onready var bar_music: TextureRect = %BarMusic
@onready var bar_sfx: TextureRect = %BarSFX
@onready var demo_music: AudioStreamPlayer = $DemoMusic
@onready var demo_sfx: AudioStreamPlayer = $DemoSFX

@onready var indicators = [indicator_music, indicator_sfx]
@onready var bars = [bar_music, bar_sfx]


func _ready():
	GBtn.on_b.connect(_on_b)
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	GBtn.on_left.connect(_on_left)
	GBtn.on_right.connect(_on_right)

	update()


func _on_b():
	SceneMgr.close()


func _on_up():
	UiSounds.up()
	index = (index - 1 + indicators.size()) % indicators.size()
	update()


func _on_down():
	UiSounds.down()
	index = (index + 1) % indicators.size()
	update()


func _on_left():
	if index == 0:
		Volume.music -= 1
	else:
		Volume.sfx -= 1
	update()
	if index == 1:
		demo_sfx.play()


func _on_right():
	if index == 0:
		Volume.music += 1
	else:
		Volume.sfx += 1
	update()
	if index == 1:
		demo_sfx.play()


func update():
	if index == 0:
		if !demo_music.playing:
			demo_music.play()
	else:
		demo_music.stop()

	for i in range(indicators.size()):
		var s := " "
		if i == index:
			s = ">"
		indicators[i].text = s

	bar_music.scale.x = Volume.music / 10.0
	bar_sfx.scale.x = Volume.sfx / 10.0
