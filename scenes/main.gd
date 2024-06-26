extends Node

@onready var coin_manager = %CoinManager
#preload obstacles
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var coin_scene = preload("res://scenes/coin.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var coins : Array
var bird_heights := [200, 390]

#game variables
const DINO_START_POS := Vector2i(150, 485);
const CAM_START_POS := Vector2i(576, 324);
var difficulty : int;
const MAX_DIFFICULTY : int = 3;
var score : float;
const SCORE_MODIFIER : int = 10;
var high_score : float;
var speed : float;
const START_SPEED : float = 10.0 / (1.0/60.0);
const MAX_SPEED : float = 100.0 / (1.0/60.0);
const SPEED_MODIFIER : int = 100;
const DIFFICULTY_MODIFIER : int = 3000 * 10;
const OBS_FALLOF_X : int = 0.3;
var screen_size : Vector2i;
var ground_height : int;
var game_running : bool;
var last_obs;
var TotalCoins = 0;
var obs_x_coin
var max_lives:int
var lives:int

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size;
	ground_height = $Ground.get_node("Sprite2D").texture.get_height();
	$GameOver.get_node("Button").pressed.connect(new_game);
	new_game();


func new_game():
	#reset variables
	score = 0;
	coin_manager.coins = 0;
	max_lives = $Hearts.max_lives
	lives = max_lives
	$Hearts.update_hearts_display(max_lives)
	$Hearts.heartFull.show()
	show_score();
	check_high_score();
	show_coins();
	game_running = false;
	get_tree().paused = false;
	difficulty = 0;
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free();
	obstacles.clear();
	#reset the nodes
	$Dino.position = DINO_START_POS;
	$Dino.velocity = Vector2i(0, 0);
	$Camera2D.position = CAM_START_POS;
	$Ground.position = Vector2i(0, 0);
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show();
	$GameOver.hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER;
		if speed > MAX_SPEED:
			speed = MAX_SPEED;
		speed *= delta;
		adjust_difficulty();
		
		#generate obstacles
		generate_obs();
		
		#move dino and camera
		$Dino.position.x += speed;
		$Camera2D.position.x += speed;
		
		#update score
		score += speed
		show_score()
		
		#update coins
		show_coins()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x;
			
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)

		for coin in coins:
			if is_instance_valid(coin) and coin.position.x < ($Camera2D.position.x - screen_size.x):
				remove_coin(coin)
	else:
		if Input.is_action_pressed("game_up"):
			game_running = true;
			$HUD.get_node("StartLabel").hide();

func generate_obs():
	# Generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			obs_x_coin = obs_x
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

		#coin generation
		var num_coins = randi_range(0, 5)
		var spacing = 50
		var start_x = obs_x_coin + 300
		for x in range(num_coins):
			var coin_instance = coin_scene.instantiate()
			var coin = coin_instance as Node2D
			var coin_x : int = start_x + x * spacing
			var coin_y : int = screen_size.y - ground_height - 50
			coin.position = Vector2(coin_x, coin_y)
			add_child(coin)
			coins.append(coin)
			
		# Additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if randi() % 2 == 0:
				# Generate bird obstacles
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)


func add_obs(obs, x, y):
	obs.position = Vector2i(x, y);
	obs.body_entered.connect(hit_obs);
	add_child(obs);
	obstacles.append(obs);

func remove_obs(obs):
	obs.queue_free();
	obstacles.erase(obs);
	
func hit_obs(body):
	if body.name == "Dino":
		lives -= 1
		$Hearts.update_hearts_display(lives)
		if lives <= 0:
			game_over()
		
func remove_coin(coin):
	coin.queue_free()
	coins.erase(coin)
		

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(int(score / SCORE_MODIFIER));
	
func show_coins():
	$HUD.get_node("CoinLabel").text = "COINS: " + str(coin_manager.coins);

func check_high_score():
	if score > high_score:
		high_score = score;
	$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(int(high_score / SCORE_MODIFIER));
	
	
func adjust_difficulty():
	difficulty = score / DIFFICULTY_MODIFIER;
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY;
	print(difficulty, " ", score, " ", DIFFICULTY_MODIFIER)

func game_over():
	get_tree().paused = true;
	game_running = false;
	$GameOver.show();
