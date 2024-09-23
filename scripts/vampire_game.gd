class_name VampireGame
extends Node2D

const DAMAGED_FLASH_RATE = 0.12  # sec period
const ANIM_FADE_DURATION = 1.5  # sec

@export var intro_text: String
@export var win_text: String
@export var lose_text: String
@export var jump_canceling: bool = false
@export var spawn_to_hit_sec: float = 0.8
@export var damage_invuln_sec: float = 1.0
@export var press_on_beat_offset_sec: float = 0.0
@export var send_to_scoring_area_sec: float = 0.2
@export var threshold: int = 10
@export var skip_to_song_end: bool = false

var start_playing_music_at_ms = null
var last_spawned_item: Node = null
var damage_remain_s := 0.0
var score := 0

@onready var spawners_bg: Array[Node] = $ItemsBG.get_children()
@onready var spawners_fg: Array[Node] = $ItemsFG.get_children()
@onready var despawner: Area2D = $Despawner
@onready var nice_trigger: Area2D = $NiceTrigger
@onready var spawned_items_bg: Node2D = $SpawnedItemsBG
@onready var spawned_items_fg: Node2D = $SpawnedItemsFG
@onready var pc: Area2D = $PC
@onready var nice_anim: AnimatedSprite2D = $Nice
@onready var you_suck_anim: AnimatedSprite2D = $YouSuck
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

@onready var score_area: Area2D = $ScoreArea
@onready var splash_ring: AnimatedSprite2D = $ScoreArea/SplashRing

@onready var progress_fg: Sprite2D = $ProgressContainer/ProgressFG
@onready var progress_fg_full: Sprite2D = $ProgressContainer/ProgressFGFull
@onready var progress_fg_empty_pos_x: float = progress_fg.position.x
@onready var progress_fg_full_pos_x: float = progress_fg_full.position.x
@onready var progress_fg_empty_scale_x: float = progress_fg.scale.x
@onready var progress_fg_full_scale_x: float = progress_fg_full.scale.x


func _ready():
	GBtn.on_up.connect(_on_up)
	GBtn.on_up_release.connect(_on_up_release)
	GBtn.on_down.connect(_on_down)
	GBtn.on_down_release.connect(_on_down_release)

	audio_music.finished.connect(_on_music_end)
	notes.midi_event.connect(_on_midi_event)

	despawner.body_entered.connect(_despawn)
	nice_trigger.body_entered.connect(_on_entered_nice_area)
	score_area.body_entered.connect(_on_score)
	pc.body_entered.connect(_on_hit)

	nice_anim.modulate.a = 0.0
	you_suck_anim.modulate.a = 0.0

	_start_intro()


func _start_intro():
	fader.fade_in()
	await get_tree().create_timer(1.0).timeout

	DialogueMgr.show(intro_text)
	await DialogueMgr.on_close

	# HACK: Gappy transition into game music
	audio_intro["parameters/looping"] = false
	while audio_intro.playing:
		await get_tree().create_timer(0.1).timeout

	_start_game()


func _start_game():
	notes.play()
	var offset := spawn_to_hit_sec - AudioCal.total_audio_offset() - press_on_beat_offset_sec
	start_playing_music_at_ms = (Time.get_ticks_msec() + int(offset * 1000))


func _process(delta: float):
	var fade_amt := delta / ANIM_FADE_DURATION
	nice_anim.modulate.a -= fade_amt
	you_suck_anim.modulate.a -= fade_amt

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
	if jump_canceling:
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
	if event.note == 36:
		_spawn_item(true)
	elif event.note == 40:
		_spawn_item(false)
	else:
		return
	dr_anim_sm.travel("toss")


## Spawn an item. true = fg = foreground (top), false = bg = background (bottom)
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
	if body.scoring:
		return

	_trash_throwable(body)
	body.hit_player = true
	you_suck_anim.modulate.a = 1.0
	damage_remain_s = damage_invuln_sec
	if not audio_miss.playing:
		audio_miss.play()


func _on_entered_nice_area(body: Node):
	if body.hit_player:
		return

	body.modulate.a = 0.5
	_show_nice()
	_send_to_scoring_area(body)


func _send_to_scoring_area(body: RigidBody2D):
	body.scoring = true
	body.gravity_scale = 0.0
	var curr := body.global_position
	var tgt := score_area.global_position
	body.linear_velocity = (tgt - curr) / send_to_scoring_area_sec


func _on_score(body: Node):
	_incr_score()
	if splash_ring.is_playing():
		splash_ring.stop()
	splash_ring.play()
	body.queue_free()


func _incr_score():
	score += 1
	_update_progress_bar()


func _update_progress_bar():
	var pct: float = clamp(score / float(threshold), 0, 100)
	var pos_x = progress_fg_empty_pos_x + pct * (progress_fg_full_pos_x - progress_fg_empty_pos_x)
	var scale_x = (
		progress_fg_empty_scale_x + pct * (progress_fg_full_scale_x - progress_fg_empty_scale_x)
	)
	progress_fg.position.x = min(progress_fg_full_pos_x, pos_x)
	progress_fg.scale.x = min(progress_fg_full_scale_x, scale_x)


func _show_nice():
	if nice_anim.modulate.a > 0:
		return
	if damage_remain_s > 0:
		return
	nice_anim.modulate.a = 1.0


func _despawn(body: Node):
	body.queue_free()


func _on_music_end():
	notes.stop()
	var win = score >= threshold

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

	var result = CampaignMgr.GameResult.WIN if win else CampaignMgr.GameResult.LOSE
	CampaignMgr.game_over.emit(result)
	CampaignMgr.scene_complete.emit()


func fmod(a: float, b: float) -> float:
	return a - b * floor(a / b)
