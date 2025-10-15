# victory_checker.gd
# Handles all victory condition checking for Rithmomachia
extends Node

# Reference to the board (will be set by board.gd)
var board = null

# Victory thresholds
var n0: int = 12  # Victory by body (number of pieces)
var n1: int = 500  # Victory by goods (total value)

func _init(board_ref, body_threshold: int = 12, goods_threshold: int = 500):
	board = board_ref
	n0 = body_threshold
	n1 = goods_threshold

# ===== MAIN VICTORY CHECK =====

func check_for_win(current_color: String, captured_pieces: Array) -> Dictionary:
	"""
	Checks all victory conditions for the current player.
	Returns: {won: bool, reason: String, details: Array}
	"""
	print("\n=== Checking victory conditions for %s ===" % current_color.capitalize())
	
	# Check arithmetical progression victory
	var arith_result = check_arithmetical_victory(current_color)
	if arith_result.won:
		var piece_values = []
		for p in arith_result.pieces:
			piece_values.append(get_piece_value(p))
		print("Checking for victory by arithmetical progression: VICTORY! Values: %s" % str(piece_values))
		return {
			"won": true,
			"reason": "arithmetical progression",
			"details": arith_result.pieces
		}
	else:
		print("Checking for victory by arithmetical progression: None")
	
	# Check geometrical progression victory
	var geom_result = check_geometrical_victory(current_color)
	if geom_result.won:
		var piece_values = []
		for p in geom_result.pieces:
			piece_values.append(get_piece_value(p))
		print("Checking for victory by geometrical progression: VICTORY! Values: %s" % str(piece_values))
		return {
			"won": true,
			"reason": "geometrical progression",
			"details": geom_result.pieces
		}
	else:
		print("Checking for victory by geometrical progression: None")
	
	# Check harmonic progression victory
	var harm_result = check_harmonic_victory(current_color)
	if harm_result.won:
		var piece_values = []
		for p in harm_result.pieces:
			piece_values.append(get_piece_value(p))
		print("Checking for victory by harmonic progression: VICTORY! Values: %s" % str(piece_values))
		return {
			"won": true,
			"reason": "harmonic progression",
			"details": harm_result.pieces
		}
	else:
		print("Checking for victory by harmonic progression: None")
	
	# Check victory by body (number of captured pieces)
	var captured_count = captured_pieces.size()
	if captured_count >= n0:
		print("Checking for victory by body: VICTORY! (%d >= %d pieces)" % [captured_count, n0])
		return {
			"won": true,
			"reason": "body",
			"details": [captured_count, n0]
		}
	else:
		print("Checking for victory by body: None (%d / %d pieces)" % [captured_count, n0])
	
	# Check victory by goods (total value of captured pieces)
	var total_value = 0
	for piece_data in captured_pieces:
		# Handle both integer values and objects with .value property
		if typeof(piece_data) == TYPE_INT:
			total_value += piece_data
		else:
			total_value += piece_data.value
	
	if total_value >= n1:
		print("Checking for victory by goods: VICTORY! (%d >= %d value)" % [total_value, n1])
		return {
			"won": true,
			"reason": "goods",
			"details": [total_value, n1]
		}
	else:
		print("Checking for victory by goods: None (%d / %d value)" % [total_value, n1])
	
	# No victory condition met
	print("=== No victory conditions met ===\n")
	return {"won": false, "reason": "", "details": []}

# ===== ARITHMETICAL PROGRESSION =====

func check_arithmetical_victory(color: String) -> Dictionary:
	"""
	Check if player has 3 pieces in enemy territory forming an arithmetic progression.
	An arithmetic progression: v1, v2, v3 where v2 - v1 = v3 - v2
	Returns: {won: bool, pieces: Array}
	"""
	var pieces_in_territory = get_pieces_in_enemy_territory(color)
	
	print("  - Found %d pieces in enemy territory for arithmetical check" % pieces_in_territory.size())
	
	if pieces_in_territory.size() < 3:
		return {"won": false, "pieces": []}
	
	# Check all combinations of 3 pieces
	for i in range(pieces_in_territory.size()):
		for j in range(i + 1, pieces_in_territory.size()):
			for k in range(j + 1, pieces_in_territory.size()):
				var p1 = pieces_in_territory[i]
				var p2 = pieces_in_territory[j]
				var p3 = pieces_in_territory[k]
				
				# Get values
				var values = [
					get_piece_value(p1),
					get_piece_value(p2),
					get_piece_value(p3)
				]
				values.sort()
				
				# Check for arithmetic progression
				if values[1] - values[0] == values[2] - values[1] and values[1] - values[0] > 0:
					# Sort pieces by value for display
					var sorted_pieces = [p1, p2, p3]
					sorted_pieces.sort_custom(func(a, b): return get_piece_value(a) < get_piece_value(b))
					return {"won": true, "pieces": sorted_pieces}
	
	return {"won": false, "pieces": []}

# ===== GEOMETRICAL PROGRESSION =====

func check_geometrical_victory(color: String) -> Dictionary:
	"""
	Check if player has 3 pieces in enemy territory forming a geometric progression.
	A geometric progression: v1, v2, v3 where v2/v1 = v3/v2
	Or equivalently: v2 * v2 = v1 * v3
	Returns: {won: bool, pieces: Array}
	"""
	var pieces_in_territory = get_pieces_in_enemy_territory(color)
	
	print("  - Found %d pieces in enemy territory for geometrical check" % pieces_in_territory.size())
	
	if pieces_in_territory.size() < 3:
		return {"won": false, "pieces": []}
	
	# Check all combinations of 3 pieces
	for i in range(pieces_in_territory.size()):
		for j in range(i + 1, pieces_in_territory.size()):
			for k in range(j + 1, pieces_in_territory.size()):
				var p1 = pieces_in_territory[i]
				var p2 = pieces_in_territory[j]
				var p3 = pieces_in_territory[k]
				
				# Get values
				var values = [
					get_piece_value(p1),
					get_piece_value(p2),
					get_piece_value(p3)
				]
				values.sort()
				
				# Check for geometric progression: v2² = v1 * v3
				if values[0] > 0 and values[1] > values[0]:
					if values[2] * values[0] == values[1] * values[1]:
						# Sort pieces by value for display
						var sorted_pieces = [p1, p2, p3]
						sorted_pieces.sort_custom(func(a, b): return get_piece_value(a) < get_piece_value(b))
						return {"won": true, "pieces": sorted_pieces}
	
	return {"won": false, "pieces": []}

# ===== HARMONIC PROGRESSION =====

func check_harmonic_victory(color: String) -> Dictionary:
	"""
	Check if player has 3 pieces in enemy territory forming a harmonic progression.
	A harmonic progression: 1/v1, 1/v2, 1/v3 form an arithmetic progression
	Or equivalently: v2 * (v1 + v3) = 2 * v1 * v3
	Returns: {won: bool, pieces: Array}
	"""
	var pieces_in_territory = get_pieces_in_enemy_territory(color)
	
	print("  - Found %d pieces in enemy territory for harmonic check" % pieces_in_territory.size())
	
	if pieces_in_territory.size() < 3:
		return {"won": false, "pieces": []}
	
	# Check all combinations of 3 pieces
	for i in range(pieces_in_territory.size()):
		for j in range(i + 1, pieces_in_territory.size()):
			for k in range(j + 1, pieces_in_territory.size()):
				var p1 = pieces_in_territory[i]
				var p2 = pieces_in_territory[j]
				var p3 = pieces_in_territory[k]
				
				# Get values
				var values = [
					get_piece_value(p1),
					get_piece_value(p2),
					get_piece_value(p3)
				]
				values.sort()
				
				var v1 = values[0]
				var v2 = values[1]
				var v3 = values[2]
				
				# Skip if any value is 0 or if values aren't distinct
				if v1 <= 0 or v1 == v2 or v2 == v3:
					continue
				
				# Check for harmonic progression: v2 * (v1 + v3) = 2 * v1 * v3
				if v2 * (v1 + v3) == 2 * v1 * v3:
					# Sort pieces by value for display
					var sorted_pieces = [p1, p2, p3]
					sorted_pieces.sort_custom(func(a, b): return get_piece_value(a) < get_piece_value(b))
					return {"won": true, "pieces": sorted_pieces}
	
	return {"won": false, "pieces": []}

# ===== HELPER FUNCTIONS =====

func get_pieces_in_enemy_territory(color: String) -> Array:
	"""
	Returns array of pieces of the given color in enemy territory.
	White's enemy territory: columns 8-15 (right half)
	Black's enemy territory: columns 0-7 (left half)
	"""
	var pieces = []
	var enemy_cols = range(8, 16) if color == "white" else range(0, 8)
	
	for y in range(8):
		for x in enemy_cols:
			var tile = board.get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			
			var piece = tile.get_child(0)
			if piece.piece_color == color:
				pieces.append(piece)
	
	return pieces

func get_piece_value(piece: Node2D) -> int:
	"""Returns the total value of a piece."""
	if piece.piece_label.size() > 0:
		# For pyramids, this is the sum; for others, it's the single value
		return piece.piece_label[0] if piece.piece_shape != "P" else piece.piece_label.reduce(func(acc, val): return acc + val, 0)
	return 0
