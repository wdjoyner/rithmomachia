# tile.gd
extends ColorRect


# This function will be called by the board to place a piece on this tile.
func place_piece(piece_scene: PackedScene, piece_id: String, piece_data: Dictionary):
	var piece = piece_scene.instantiate()
	add_child(piece)  # Add to tree FIRST
	piece.position = size / 2.0
	piece.initialize(piece_id, piece_data)  # THEN initialize
