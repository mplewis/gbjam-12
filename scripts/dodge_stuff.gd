class_name DodgeStuff
extends Node2D

@onready var spawners: Array[Node] = $Items.get_children()
@onready var spawned_items: Node2D = $SpawnedItems
@onready var standing: Sprite2D = $Standing
@onready var jumping: Sprite2D = $Jumping
@onready var crouching: Sprite2D = $Crouching


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	_new_timer()


func _new_timer():
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(_on_timeout)


func _on_timeout():
	_new_timer()
	_spawn_item()


func _spawn_item():
	var spawner = spawners[randi() % len(spawners)]
	var item: RigidBody2D = spawner.duplicate()
	item.global_position = spawner.global_position
	item.linear_velocity = Vector2(-100, 0)
	spawned_items.add_child(item)
	print("Spawned %s" % item)


func _on_up():
	pass


func _on_down():
	pass


func fmod(a: float, b: float) -> float:
	return a - b * floor(a / b)
