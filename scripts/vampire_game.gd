class_name VampireGame
extends Node2D

const DAMAGED_FLASH_RATE = 0.12  # sec period
const DAMAGED_DURATION = 1.5  # sec
const ANIM_FADE_DURATION = 1.5  # sec

@onready var spawners_bg: Array[Node] = $ItemsBG.get_children()
@onready var spawners_fg: Array[Node] = $ItemsFG.get_children()
@onready var despawner: Area2D = $Despawner
@onready var nice_trigger: Area2D = $NiceTrigger
@onready var spawned_items_bg: Node2D = $SpawnedItemsBG
@onready var spawned_items_fg: Node2D = $SpawnedItemsFG
@onready var pc: Area2D = $PC
@onready var nice_anim: AnimatedSprite2D = $Nice
@onready var you_suck_anim: AnimatedSprite2D = $YouSuck
@onready var hearts_row: HeartsRow = $HeartsRow
@onready var fader: Fader = $Fader

@onready var notes: MidiPlayer = $Notes
@onready var audio_intro: AudioStreamPlayer = $Audio/Intro
@onready var audio_music: AudioStreamPlayer = $Audio/Music
@onready var audio_win: AudioStreamPlayer = $Audio/Win
@onready var audio_lose: AudioStreamPlayer = $Audio/Lose
@onready var audio_duck: AudioStreamPlayer = $Audio/Duck
@onready var audio_jump: AudioStreamPlayer = $Audio/Jump
@onready var audio_miss: AudioStreamPlayer = $Audio/Miss

@onready var pc_anim_tree: AnimationTree = $PC/AnimationTree
@onready var pc_anim_sm: AnimationNodeStateMachinePlayback = pc_anim_tree.get("parameters/playback")
@onready var dr_anim_tree: AnimationTree = $Dracula/AnimationTree
@onready var dr_anim_sm: AnimationNodeStateMachinePlayback = dr_anim_tree.get("parameters/playback")

@export var intro_text: String
@export var win_text: String
@export var lose_text: String
@export var spawn_to_hit_sec: float = 0.8
@export var swap_high_and_low_spawns: bool = false
@export var skip_to_song_end: bool = false

const max_health := 10
@onready var health := max_health

var start_playing_music_at_ms = null

var last_spawned_item: Node = null
var damage_remain_s := 0.0


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_up_release.connect(_on_up_release)
	GBtn.on_down.connect(_on_down)
	GBtn.on_down_release.connect(_on_down_release)

	audio_music.finished.connect(_on_music_end)

	fader.fade_in()
	hearts_row.total = max_health
	nice_anim.modulate.a = 0.0
	you_suck_anim.modulate.a = 0.0

	await get_tree().create_timer(1.0).timeout
	DialogueMgr.show(intro_text)
	await DialogueMgr.on_close

	# HACK: Gappy transition into game music
	audio_intro["parameters/looping"] = false
	while audio_intro.playing:
		await get_tree().create_timer(0.1).timeout

	_start_game()


func _start_game():
	despawner.body_entered.connect(_despawn)
	nice_trigger.body_entered.connect(_on_dodged)
	pc.body_entered.connect(_on_hit)

	notes.midi_event.connect(_on_midi_event)
	notes.play()
	start_playing_music_at_ms = (
		Time.get_ticks_msec() + int((spawn_to_hit_sec - AudioCal.total_audio_offset()) * 1000)
	)


func _process(delta: float):
	var fade_amt := delta / ANIM_FADE_DURATION
	nice_anim.modulate.a -= fade_amt
	you_suck_anim.modulate.a -= fade_amt
	hearts_row.health = health

	_ensure_start_music()
	_handle_damage(delta)


func _ensure_start_music():
	if (
		start_playing_music_at_ms
		and Time.get_ticks_msec() >= start_playing_music_at_ms
		and not audio_music.playing
	):
		audio_music.play()

		if skip_to_song_end:
			audio_music.seek(audio_music.stream.get_length() - 10.0)

		start_playing_music_at_ms = null


func _handle_damage(delta: float):
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


func _on_up():
	pc_anim_sm.travel("jump")
	if not audio_jump.playing:
		audio_jump.play()


func _on_up_release():
	pc_anim_sm.start("unjump")


func _on_down():
	pc_anim_sm.travel("crouch")
	if not audio_duck.playing:
		audio_duck.play()


func _on_down_release():
	pc_anim_sm.travel("uncrouch")


func _on_midi_event(_channel, event):
	if event.type != SMF.MIDIEventType.note_on:
		return
	_spawn_item(event.note == 36)


func _spawn_item(fg: bool):
	var spawner := _pick_spawner(fg)
	var item: RigidBody2D = spawner.duplicate()
	_start_anim(item)

	item.position.y += randi_range(-3, 3)
	item.global_position = spawner.global_position

	var dist_to_travel = pc.global_position.x - item.global_position.x
	var left_velocity = abs(dist_to_travel / spawn_to_hit_sec)
	item.linear_velocity = Vector2(-left_velocity, 0)

	var target = spawned_items_bg
	if fg:
		target = spawned_items_fg
	target.add_child(item)


func _pick_spawner(fg: bool) -> RigidBody2D:
	if swap_high_and_low_spawns:
		fg = not fg

	dr_anim_sm.travel("toss")

	var spawners = spawners_bg
	if fg:
		spawners = spawners_fg
	var spawner = spawners[randi() % len(spawners)]
	while last_spawned_item == spawner:
		spawner = spawners[randi() % len(spawners)]
	last_spawned_item = spawner

	return spawner


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
	if not audio_miss.playing:
		audio_miss.play()


func _on_dodged(_body: Node):
	if nice_anim.modulate.a > 0:
		return
	if damage_remain_s > 0:
		return
	nice_anim.modulate.a = 1.0


func _despawn(body: Node):
	body.queue_free()


func _on_music_end():
	_play_finale(health > 0)


func _play_finale(win: bool):
	notes.stop()

	if win:
		DialogueMgr.show(win_text)
		audio_win.play()
		await audio_win.finished
	else:
		DialogueMgr.show(lose_text)
		audio_lose.play()
		await audio_lose.finished

	if DialogueMgr.current:
		await DialogueMgr.on_close

	fader.fade_out()
	await fader.fade_complete
	CampaignMgr.game_complete.emit()


func fmod(a: float, b: float) -> float:
	return a - b * floor(a / b)
