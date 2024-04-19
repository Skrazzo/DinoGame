extends CharacterBody2D

const GRAVITY : int = 2800
const JUMP_SPEED : int = -1200

# Particle variables
var running_part = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta;
	var is_up := Input.is_action_pressed("game_up") and not Input.is_action_pressed("game_down");
	var is_down := Input.is_action_pressed("game_down") and not Input.is_action_pressed("game_up");
	
	if not get_parent().game_running:
		$AnimatedSprite2D/GrassPart.emitting = false
	else:
		$AnimatedSprite2D/GrassPart.emitting = running_part
	
	if is_on_floor():
		running_part = true
		
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle");
		else:
			$RunCol.disabled = false
			if is_up:
				velocity.y = JUMP_SPEED;
			
				#$JumpSound.play()
			elif is_down:
				$AnimatedSprite2D.play("duck");
				$RunCol.disabled = true;
			else:
				$AnimatedSprite2D.play("run");
	else:
		running_part = false
		
		if is_down:
			velocity.y = -JUMP_SPEED * 1.5;
		$AnimatedSprite2D.play("jump");
		
	move_and_slide()
