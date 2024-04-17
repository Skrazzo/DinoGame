extends Area2D

@onready var coin_manager = $/root/Main/CoinManager
@onready var audio_stream_player_2d = $PickUpSound


func _on_body_entered(body):
	if body.name == "Dino":
		queue_free()
		audio_stream_player_2d.play()
		
		
		if coin_manager:
			coin_manager.add_coin()
	else:
		queue_free()
