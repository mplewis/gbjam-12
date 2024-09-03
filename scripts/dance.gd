class_name Dance
extends Node2D

@onready var midi_player: MidiPlayer = $MidiPlayer


func _ready():
	SceneMgr.set_appropriate_window_size()
	GBtn.on_start.connect(_on_start)

	midi_player.midi_event.connect(_on_midi_event)
	midi_player.seek(2050.0)


func _on_start():
	SceneMgr.close()


func _on_midi_event(channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return

	if channel.number != 2:
		return

	var arrow_lcr = event.note % 3
	print(arrow_lcr)
