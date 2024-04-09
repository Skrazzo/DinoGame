extends CharacterBody2D

const GRAVITY : int = 2800
const JUMP_SPEED : int = -1200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("game_up"):
				velocity.y = JUMP_SPEED
			
				#$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("run")
	else:
		if Input.is_action_pressed("game_down"):
			velocity.y = -JUMP_SPEED * 1.5;
		$AnimatedSprite2D.play("jump")
		
	move_and_slide()
