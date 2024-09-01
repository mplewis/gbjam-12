extends Node

@onready var volume_music := _get_bus_volume("Music"):
	set(vol):
		volume_music = clamp(vol, 0, 10)
		_set_bus_volume("Music", volume_music)

@onready var volume_sfx := _get_bus_volume("SFX"):
	set(vol):
		volume_sfx = clamp(vol, 0, 10)
		_set_bus_volume("SFX", volume_sfx)


func remap_range(lo1: float, hi1: float, lo2: float, hi2: float, x: float) -> float:
	return lo2 + (x - lo1) * (hi2 - lo2) / (hi1 - lo1)


func _set_bus_volume(bus_name: String, vol: int):
	var bus_i = AudioServer.get_bus_index(bus_name)
	assert(bus_i != -1)

	var db = -INF
	if vol > 0:
		db = remap_range(1, 10, -60, 0, vol)

	print("Setting %s bus (%d) to %f dB" % [bus_name, bus_i, db])
	AudioServer.set_bus_volume_db(bus_i, db)
	print(AudioServer.get_bus_volume_db(bus_i))


func _get_bus_volume(bus_name: String) -> int:
	var bus_i = AudioServer.get_bus_index(bus_name)
	assert(bus_i != -1)

	var db = AudioServer.get_bus_volume_db(bus_i)
	print("Getting %s bus (%d) volume: %f dB" % [bus_name, bus_i, db])
	if db == -INF:
		return 0
	return int(remap_range(-60, 0, 1, 10, db))
