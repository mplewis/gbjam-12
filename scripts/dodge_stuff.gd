class_name DodgeStuff
extends Node2D

const DAMAGED_FLASH_RATE = 0.12  # sec period
const DAMAGED_DURATION = 1.5  # sec
const ANIM_FADE_DURATION = 1.5  # sec

@onready var spawners: Array[Node] = $Items.get_children()
@onready var despawner: Area2D = $Despawner
@onready var nice_trigger: Area2D = $NiceTrigger
@onready var spawned_items_bg: Node2D = $SpawnedItemsBG
@onready var spawned_items_fg: Node2D = $SpawnedItemsFG
@onready var pc: Area2D = $PC
@onready var nice_anim: AnimatedSprite2D = $Nice
@onready var you_suck_anim: AnimatedSprite2D = $YouSuck
@onready var hearts_row: HeartsRow = $HeartsRow

@onready var pc_anim_tree: AnimationTree = $PC/AnimationTree
@onready var pc_anim_sm: AnimationNodeStateMachinePlayback = pc_anim_tree.get("parameters/playback")
@onready var dr_anim_tree: AnimationTree = $Dracula/AnimationTree
@onready var dr_anim_sm: AnimationNodeStateMachinePlayback = dr_anim_tree.get("parameters/playback")

@onready var floor_items = [$Items/Barrel, $Items/Chomper, $Items/Brick, $Items/Banana]

const MAX_HEALTH := 10
var health := 10

var last_spawned_item: Node = null
var damage_remain_s := 0.0


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_down.connect(_on_down)
	GBtn.on_down_release.connect(_on_down_release)

	despawner.body_entered.connect(_despawn)
	nice_trigger.body_entered.connect(_on_dodged)
	pc.body_entered.connect(_on_hit)

	hearts_row.total = MAX_HEALTH
	nice_anim.modulate.a = 0.0
	you_suck_anim.modulate.a = 0.0

	_new_timer()


func _process(delta: float):
	var fade_amt := delta / ANIM_FADE_DURATION
	nice_anim.modulate.a -= fade_amt
	you_suck_anim.modulate.a -= fade_amt
	hearts_row.health = health

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


func _new_timer():
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(_on_timeout)


func _on_timeout():
	_new_timer()
	_spawn_item()


func _on_up():
	pc_anim_sm.travel("jump")


func _on_down():
	pc_anim_sm.travel("crouch")


func _on_down_release():
	pc_anim_sm.travel("uncrouch")


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
	item.position.y += randi_range(-3, 3)

	if spawner in floor_items:
		spawned_items_bg.add_child(item)
	else:
		spawned_items_fg.add_child(item)


func _start_anim(item: Node):
	for child in item.get_children():
		if child.has_method("play"):
			child.play()


func _trash_throwable(item: CollisionObject2D):
	item.gravity_scale = 1.0
	for child in item.get_children():
		if child is CollisionObject2D:
			child.collision_layer -= 1


func _on_hit(body: Node):
	_trash_throwable(body)
	you_suck_anim.modulate.a = 1.0
	health = max(0, health - 1)
	damage_remain_s = DAMAGED_DURATION


func _on_dodged(_body: Node):
	if nice_anim.modulate.a > 0:
		return
	if damage_remain_s > 0:
		return
	nice_anim.modulate.a = 1.0


func _despawn(body: Node):
	body.queue_free()


func fmod(a: float, b: float) -> float:
	return a - b * floor(a / b)
