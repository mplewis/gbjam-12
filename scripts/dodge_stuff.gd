class_name DodgeStuff
extends Node2D

@onready var spawners: Array[Node] = $Items.get_children()
@onready var despawner: Area2D = $Despawner
@onready var spawned_items: Node2D = $SpawnedItems
@onready var standing: Sprite2D = $Standing
@onready var jumping: Sprite2D = $Jumping
@onready var crouching: Sprite2D = $Crouching
@onready var pc: Area2D = $PC

@onready var pc_anim_tree: AnimationTree = $PC/AnimationTree
@onready var pc_anim_sm: AnimationNodeStateMachinePlayback = pc_anim_tree.get("parameters/playback")
@onready var dr_anim_tree: AnimationTree = $Dracula/AnimationTree
@onready var dr_anim_sm: AnimationNodeStateMachinePlayback = dr_anim_tree.get("parameters/playback")

@onready var positions: Array[Sprite2D] = [standing, jumping, crouching]


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	GBtn.on_down_release.connect(_on_down_release)

	despawner.body_entered.connect(_despawn)

	pc.body_entered.connect(_on_hit)

	_new_timer()


func _new_timer():
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(_on_timeout)


func _on_timeout():
	_new_timer()
	_spawn_item()


func _spawn_item():
	pass
	# var spawner = spawners[randi() % len(spawners)]
	# var item: RigidBody2D = spawner.duplicate()
	# item.global_position = spawner.global_position
	# item.linear_velocity = Vector2(-150, 0)
	# spawned_items.add_child(item)


func _on_up():
	pc_anim_sm.travel("jump")


func _on_down():
	pc_anim_sm.travel("crouch")


func _on_down_release():
	pc_anim_sm.travel("uncrouch")


func _on_hit(body: Node):
	body.modulate.a = 0.5


func _despawn(body: Node):
	body.queue_free()
