class_name DrumKit
extends Node2D

@onready var circles_parent: Control = $Circles

var circles: Array[RadialProgress] = []


func _ready():
	for circle in circles_parent.get_children():
		circles.append(circle)


func _process(delta: float) -> void:
	for circle in circles:
		var new_progress = circle.progress + delta * 20
		while new_progress > 100:
			new_progress -= 100
		circle.progress = new_progress
