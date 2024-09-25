@tool
class_name HeartsRow
extends Control

@export var health: int = 7
@export var total: int = 10

var heart_nodes: Array[TextureRect] = []

@onready var container: HBoxContainer = $Container
@onready var heart_empty: TextureRect = $HeartEmpty
@onready var heart_full: TextureRect = $HeartFull


func _process(_delta):
	if len(container.get_children()) != total:
		_resize_container()

	for i in range(total):
		var heart: TextureRect = heart_nodes[i]
		if i < health:
			heart.texture = heart_full.texture
		else:
			heart.texture = heart_empty.texture


func _resize_container():
	for child in container.get_children():
		child.queue_free()

	for i in range(total):
		var heart: TextureRect = heart_full.duplicate()
		heart_nodes.append(heart)
		container.add_child(heart)
		heart.show()
