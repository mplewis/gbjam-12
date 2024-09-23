extends Node

## Call `CampaignMgr.scene_complete.emit()` when your scene
## is done and you're ready to move onto the next one -
## ending dialogue is complete, fadeout is done, etc.
@warning_ignore("UNUSED_SIGNAL")
signal scene_complete

## Call `CampaignMgr.scene_complete.emit()` when your music minigame
## is done and you've determined if the player has won or lost.
@warning_ignore("UNUSED_SIGNAL")
signal game_over(GameResult)

enum CampaignAction {
	TRANSITION,
	RUN_SCENE,
	SHOW_ENDING,
	RESET_GAME,
}

enum GameResult {
	WIN,
	LOSE,
}

enum Game {
	T_REX,
	VAMPIRE,
	SPIDER,
}

const SCENE_TXN = "cinematics/scene_transition"

var game_scenes = {
	Game.T_REX: "games/t_rex/t_rex_game",
	Game.VAMPIRE: "games/vampire/vampire_game",
	Game.SPIDER: "games/spider/spider_intro"
}

var current_campaign = null
var current_campaign_results: Array[GameResult] = []
var step := 0
var busy := false
var freeplay_active := false


func start_campaign():
	current_campaign = []
	current_campaign_results = []

	current_campaign.push_back([CampaignAction.TRANSITION, false, false, true])
	current_campaign.push_back([CampaignAction.RUN_SCENE, "cinematics/intro"])

	var scenes := game_scenes.values().duplicate()
	scenes.shuffle()
	for scene in scenes:
		current_campaign.push_back([CampaignAction.TRANSITION, true, true, true])
		current_campaign.push_back([CampaignAction.RUN_SCENE, scene])

	current_campaign.push_back([CampaignAction.TRANSITION, true, true, false])
	current_campaign.push_back([CampaignAction.SHOW_ENDING])
	current_campaign.push_back([CampaignAction.RESET_GAME])

	print(current_campaign)


func start_freeplay(game: Game):
	freeplay_active = true
	var scene_name = game_scenes[game]
	_inst_and_replace_scene(scene_name)


func _ready():
	scene_complete.connect(_on_scene_complete)
	game_over.connect(_on_game_over)


func _process(_delta):
	if not current_campaign:
		return

	if step >= len(current_campaign):
		current_campaign = null
		return

	if busy:
		return

	print(
		(
			"Running campaign step %d of %d: %s"
			% [step + 1, len(current_campaign), current_campaign[step]]
		)
	)
	match current_campaign[step]:
		[CampaignAction.TRANSITION, var open, var footsteps, var close]:
			busy = true
			_run_transition(open, footsteps, close)
			await scene_complete
			_next()

		[CampaignAction.RUN_SCENE, var scene_name]:
			busy = true
			_inst_and_replace_scene(scene_name)
			await scene_complete
			_next()

		[CampaignAction.SHOW_ENDING]:
			busy = true
			_inst_and_replace_scene(_select_ending_scene())
			await scene_complete
			_next()

		[CampaignAction.RESET_GAME]:
			print("Executing RESET_GAME as campaign step")
			_reset_game()

		_:
			assert(false, "Unknown action: %s" % step)


func _next():
	step += 1
	busy = false


func _on_scene_complete():
	print("Scene complete")
	if current_campaign:
		print("Current campaign:")
		print(current_campaign)
	else:
		print("No current campaign")

	if freeplay_active:
		print("Freeplay ended, resetting game")
		freeplay_active = false
		_reset_game()
		return

	# HACK: Rescue the game from orphaned scenes
	if not current_campaign:
		print("Current campaign does not exist, resetting game")
		_reset_game()


func _reset_game():
	current_campaign = null
	current_campaign_results = []
	step = 0
	busy = false
	freeplay_active = false
	SceneMgr.reset()


func _on_game_over(result: GameResult):
	current_campaign_results.push_back(result)
	var r = "Win" if result == GameResult.WIN else "Lose"
	print("Game result submitted: %s" % r)


func _inst_scene(scene_name: String) -> Node:
	return load("res://scenes/%s.tscn" % scene_name).instantiate()


func _replace_scene(scene: Node):
	var s = get_tree().current_scene
	if s:
		s.queue_free()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene  # HACK, maybe?


func _inst_and_replace_scene(scene_name: String):
	var scene := _inst_scene(scene_name)
	_replace_scene(scene)


func _run_transition(open: bool, footsteps: bool, close: bool):
	var transition: SceneTransition = _inst_scene(SCENE_TXN)
	transition.door_open = open
	transition.footsteps = footsteps
	transition.door_close = close
	_replace_scene(transition)


func _select_ending_scene() -> String:
	var total := len(current_campaign_results)
	if total == 0:
		return "cinematics/true_ending"

	var losses := 0
	for r in current_campaign_results:
		if r == GameResult.LOSE:
			losses += 1

	if losses == 0:
		return "cinematics/true_ending"
	if losses == total:
		return "cinematics/bad_ending"
	return "cinematics/good_ending"
