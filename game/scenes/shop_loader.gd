extends Node2D;


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(1, 8):
		var item_window := get_node("item window" + str(i));
		var buy_button := item_window.get_node("buy button");
		
