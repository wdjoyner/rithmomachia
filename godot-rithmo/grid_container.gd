extends Node2D

# Get a reference to the GridContainer node in the scene tree.
# The '$' is a shortcut for get_node().
@onready var grid_container = $GridContainer

# Preload the Tile scene we created. This is more efficient than loading it later.
const TileScene = preload("res://Tile.tscn")

# Define the colors for our checkerboard pattern.
var color_one = Color("e5cda8") # A light beige
var color_two = Color("b58863") # A wood brown

# The _ready() function is called automatically by Godot when the node enters the scene.
func _ready():
	generate_board()

# This is our custom function to create the board.
func generate_board():
	# Rithmomachia is 8 columns by 16 rows.
	var columns = 8
	var rows = 16

	# Loop through every single tile position.
	for i in range(columns * rows):
		# Create a new instance of our Tile scene.
		var tile = TileScene.instantiate()

		# Calculate the tile's position in the grid.
		var col = i % columns
		var row = i / columns

		# Use math to determine if it should be light or dark for a checkerboard pattern.
		if (col + row) % 2 == 0:
			tile.color = color_one
		else:
			tile.color = color_two
		
		# Add the newly created and colored tile as a child of the GridContainer.
		# The container will automatically place it in the next available grid spot.
		grid_container.add_child(tile)
