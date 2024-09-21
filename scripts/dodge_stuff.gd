class_name DodgeStuff
extends Node2D

@onready var spawners: Array[Node] = $Items.get_children()
@onready var despawner: Area2D = $Despawner
@onready var spawned_items: Node2D = $SpawnedItems
@onready var standing: Sprite2D = $Standing
@onready var jumping: Sprite2D = $Jumping
@onready var crouching: Sprite2D = $Crouching
@onready var score_label: Label = $Score

@onready var positions: Array[Sprite2D] = [standing, jumping, crouching]

var score := 0
var items_hit_player: Array[Node] = []


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_up_release.connect(_on_up_release)
	GBtn.on_down.connect(_on_down)
	GBtn.on_down_release.connect(_on_down_release)

	despawner.body_entered.connect(_despawn)

	for p in positions:
		var a: Area2D = p.get_child(0)
		a.body_entered.connect(_on_hit)

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
	item.linear_velocity = Vector2(-150, 0)
	spawned_items.add_child(item)


func _on_up():
	_show_pos(jumping)


func _on_up_release():
	_show_pos(standing)


func _on_down():
	_show_pos(crouching)


func _on_down_release():
	_show_pos(standing)


func _show_pos(pos: Sprite2D):
	for p in positions:
		var a: Area2D = p.get_child(0)
		if p == pos:
			p.show()
			a.monitoring = true
		else:
			p.hide()
			a.monitoring = false


func _on_hit(body: Node):
	if body not in items_hit_player:
		body.modulate.a = 0.5
		items_hit_player.append(body)


func _despawn(body: Node):
	if body in items_hit_player:
		items_hit_player.erase(body)
	else:
		score += 1
		score_label.text = "Score: %d" % score
	body.queue_free()
