extends CanvasLayer

var heartFull : TextureRect
var heartEmpty : TextureRect
var max_lives = 3
var lives : int

func _ready():
	heartFull = $HeartsFull
	heartEmpty = $HeartsEmpty

func update_hearts_display(lives):
	if heartFull != null:
		if lives >= 0:
			heartFull.size.x = lives * 11
			heartEmpty.size.x = max_lives * 11
	if lives <= 0:
		heartFull.hide()
