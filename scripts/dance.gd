class_name Dance
extends Node2D

@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var ArrowL: Arrow = $ArrowL
@onready var ArrowC: Arrow = $ArrowC
@onready var ArrowR: Arrow = $ArrowR

@onready var arrows = [ArrowL, ArrowC, ArrowR]


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)

	midi_player.midi_event.connect(_on_midi_event)
	midi_player.seek(2050.0)


func _physics_process(_delta):
	pass


func _on_start():
	SceneMgr.close()


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	var tmpl = arrows[event.note % len(arrows)]
	var arrow = tmpl.duplicate()
	add_child(arrow)
	arrow.active = true
