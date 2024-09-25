## CampaignMgr is a global singleton that manages the state of the "campaign"
## in which the player plays through the intro cinematic, three minigames,
## and an ending cinematic. It also handles freeplay mode, where the player
## can play any minigame on-demand.

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

## The possible actions that the CampaignMgr is responsible for executing.
enum CampaignAction {
	TRANSITION,
	RUN_SCENE,
	SHOW_ENDING,
	RESET_GAME,
}

## Returned from a minigame on completion. Used to determine which ending the player gets.
enum GameResult {
	WIN,
	LOSE,
}

## The games registered with the campaign.
enum Game {
	T_REX,
	VAMPIRE,
	SPIDER,
}

## The scene to use to transition between games. This one plays door noises and footsteps.
const SCENE_TXN = "cinematics/scene_transition"

## The scenes for each game in the campaign.
var game_scenes = {
	Game.T_REX: "games/t_rex/t_rex_game",
	Game.VAMPIRE: "games/vampire/vampire_game",
	Game.SPIDER: "games/spider/spider_intro"
}
## The order in which scenes are presented in the campaign.
var scene_order = [Game.T_REX, Game.VAMPIRE, Game.SPIDER]

## The current campaign being played. If null, no campaign is active.
var current_campaign = null
## The results of each game in the current campaign.
var current_campaign_results: Array[GameResult] = []
## The current index of the campaign step being executed.
var step := 0
## Whether the campaign is currently busy executing a step.
var busy := false
## Whether the player is in the middle of freeplay mode.
var freeplay_active := false


## Start a new campaign.
func start_campaign():
	current_campaign = []
	current_campaign_results = []

	current_campaign.push_back([CampaignAction.TRANSITION, false, false, true])
	current_campaign.push_back([CampaignAction.RUN_SCENE, "cinematics/intro"])

	for game in scene_order:
		current_campaign.push_back([CampaignAction.TRANSITION, true, true, true])
		current_campaign.push_back([CampaignAction.RUN_SCENE, game_scenes[game]])

	current_campaign.push_back([CampaignAction.TRANSITION, true, true, false])
	current_campaign.push_back([CampaignAction.SHOW_ENDING])
	current_campaign.push_back([CampaignAction.RESET_GAME])

	print(current_campaign)


## Start freeplay mode for a specific game.
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
		# We've executed all steps in this campaign
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
			reset_game()

		_:
			assert(false, "Unknown action: %s" % step)


## This campaign step is done. Move to the next one.
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
		reset_game()
		return

	# HACK: Rescue the game from orphaned scenes
	if not current_campaign:
		print("Current campaign does not exist, resetting game")
		reset_game()


## Reset the game to its initial state.
func reset_game():
	print("Resetting game")
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


## Replace the current scene with a new one.
func _replace_scene(scene: Node):
	var s = get_tree().current_scene
	if s:
		s.queue_free()
	get_tree().root.add_child(scene)
	# HACK, maybe? current_scene is unset otherwise.
	# I think Godot is not expecting us to mess with the tree like this.
	get_tree().current_scene = scene


## Instantiate a scene and replace the current scene with it.
func _inst_and_replace_scene(scene_name: String):
	var scene := _inst_scene(scene_name)
	_replace_scene(scene)


## Run the transition scene with the given parameters for sfx.
func _run_transition(open: bool, footsteps: bool, close: bool):
	var transition: SceneTransition = _inst_scene(SCENE_TXN)
	transition.door_open = open
	transition.footsteps = footsteps
	transition.door_close = close
	_replace_scene(transition)


## Select the ending scene based on the player's performance in the minigames.
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
