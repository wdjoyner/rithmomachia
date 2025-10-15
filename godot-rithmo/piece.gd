# Piece.gd
extends Node2D

# --- Piece Properties ---
var piece_id: String
var piece_color: String
var piece_shape: String
var piece_label: Array[int]

@onready var sprite: Sprite2D = $Sprite2D
@onready var value_label: Label = $ValueLabel

func initialize(id_string: String, data: Dictionary):
	"""
	Sets up the piece immediately. No deferred initialization needed.
	This should be called AFTER the piece is added to the scene tree.
	"""
	print("Initializing piece: ", id_string)
	
	self.piece_id = id_string
	self.piece_color = data.color
	self.piece_shape = data.shape
	self.piece_label.clear()
	for value in data.label:
		self.piece_label.append(value)
	
	z_index = 1

	# --- Load and Apply Texture ---
	var texture_path = "res://rithmo-pieces/%s-%s-blue-border.jpg" % [piece_color, piece_id]
	if ResourceLoader.exists(texture_path):
		if sprite:
			sprite.texture = load(texture_path)
			sprite.visible = true
	else:
		print("ERROR: Texture file not found at: ", texture_path)

	update_label_display()

func update_label_display():
	"""Updates the visual display of the piece's values."""
	if not value_label:
		print("WARNING: value_label not ready yet")
		return
		
	if piece_label.size() > 0:
		if piece_shape == "P":
			value_label.text = ", ".join(piece_label.map(func(v): return str(v)))
		else:
			value_label.text = str(piece_label[0])
		value_label.visible = true
	else:
		value_label.visible = false

func remove_subpiece(value_to_remove: int):
	"""Call this function when a sub-piece is captured."""
	if piece_shape != "P":
		return
	
	var index = piece_label.find(value_to_remove)
	if index != -1:
		piece_label.remove_at(index)
		update_label_display()
