class_name DodgeStuff
extends Node2D

const DAMAGED_FLASH_RATE = 0.12  # sec period
const DAMAGED_DURATION = 1.5  # sec

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

var last_spawned_item: Node = null
var damage_remain_s := 0.0


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	GBtn.on_down_release.connect(_on_down_release)

	despawner.body_entered.connect(_despawn)

	pc.body_entered.connect(_on_hit)

	_new_timer()


func _process(delta: float):
	if damage_remain_s <= 0:
		pc.modulate.a = 1
		pc.monitoring = true
		return

	pc.monitoring = false
	damage_remain_s -= delta
	var dim: bool = fmod(damage_remain_s / DAMAGED_FLASH_RATE, 2) < 1
	if dim:
		pc.modulate.a = 0.75
	else:
		pc.modulate.a = 0.3


func fmod(a: float, b: float) -> float:
	return a - b * floor(a / b)


func _new_timer():
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(_on_timeout)


func _on_timeout():
	_new_timer()
	_spawn_item()


func _spawn_item():
	dr_anim_sm.travel("toss")
	var spawner = spawners[randi() % len(spawners)]
	while last_spawned_item == spawner:
		spawner = spawners[randi() % len(spawners)]
	last_spawned_item = spawner

	var item: RigidBody2D = spawner.duplicate()
	_start_anim(item)
	item.global_position = spawner.global_position
	item.linear_velocity = Vector2(-175, 0)

	spawned_items.add_child(item)


func _start_anim(item: Node):
	for child in item.get_children():
		if child.has_method("play"):
			child.play()


func _on_up():
	pc_anim_sm.travel("jump")


func _on_down():
	pc_anim_sm.travel("crouch")


func _on_down_release():
	pc_anim_sm.travel("uncrouch")


func _on_hit(body: Node):
	body.gravity_scale = 1.0
	damage_remain_s = DAMAGED_DURATION


func _despawn(body: Node):
	body.queue_free()
