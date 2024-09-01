extends Node

const DB_LOWER = -30
const DB_UPPER = 0

## The volume (from 0-10) of the music bus.
@onready var music := _get_bus_volume("Music"):
	set(vol):
		music = clamp(vol, 0, 10)
		_set_bus_volume("Music", music)

## The volume (from 0-10) of the SFX bus.
@onready var sfx := _get_bus_volume("SFX"):
	set(vol):
		sfx = clamp(vol, 0, 10)
		_set_bus_volume("SFX", sfx)


func remap_range(lo1: float, hi1: float, lo2: float, hi2: float, x: float) -> float:
	return lo2 + (x - lo1) * (hi2 - lo2) / (hi1 - lo1)


func _set_bus_volume(bus_name: String, vol: int):
	var bus_i = AudioServer.get_bus_index(bus_name)
	assert(bus_i != -1)

	var db = -INF
	if vol > 0:
		db = remap_range(1, 10, DB_LOWER, DB_UPPER, vol)
	AudioServer.set_bus_volume_db(bus_i, db)


func _get_bus_volume(bus_name: String) -> int:
	var bus_i = AudioServer.get_bus_index(bus_name)
	assert(bus_i != -1)

	var db = AudioServer.get_bus_volume_db(bus_i)
	if db == -INF:
		return 0
	return int(remap_range(DB_LOWER, DB_UPPER, 1, 10, db))
