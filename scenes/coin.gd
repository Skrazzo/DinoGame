extends Area2D
@onready var coin_manager = %CoinManager

func _on_body_entered(body):
	if(body.name == "Dino"):
		queue_free()
		coin_manager.add_coin()
		
