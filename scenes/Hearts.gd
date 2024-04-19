extends CanvasLayer

# Member variables to store references to TextureRect nodes
var heartsFull : TextureRect
var heartsEmpty : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get references to the TextureRect nodes
	heartsFull = $HeartsFull
	heartsEmpty = $HeartsEmpty
	
	# Initialize hearts display
	update_hearts_display(3) # Assuming starting with 3 lives

# Function to update hearts display based on the current number of lives
func update_hearts_display(lives):
	# Number of full hearts = current lives
	var remaining_lives = max(0, lives)
	heartsFull.size.x = remaining_lives * heartsFull.texture.get_width()
	
	# Number of empty hearts = total hearts - remaining lives
	var empty_hearts = max(0, 3 - remaining_lives)
	heartsEmpty.size.x = (3 - remaining_lives) * heartsEmpty.texture.get_width()


