# move_validator.gd
# Handles all move and capture validation for Rithmomachia
extends Node

# Reference to the board (will be set by board.gd)
var board = null

func _init(board_ref):
	board = board_ref

# ===== MOVE VALIDATION =====

func is_within_capture_range(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	"""Check if target is within capture range (reachable distance with clear path, but destination can be occupied)."""
	# Must be orthogonally aligned
	if from_pos.x != to_pos.x and from_pos.y != to_pos.y:
		return false
	
	var shape = piece.piece_shape
	var distance = abs(to_pos.x - from_pos.x) + abs(to_pos.y - from_pos.y)
	
	# Check if distance matches piece's movement range
	var expected_distance = 0
	match shape:
		"C": expected_distance = 1
		"T": expected_distance = 2
		"S", "P": expected_distance = 3
	
	if distance != expected_distance:
		return false
	
	# Verify path is clear (intermediate squares empty, but destination can be occupied)
	return is_path_clear_for_capture(piece, from_pos, to_pos)

func is_path_clear_for_capture(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	"""Check if intermediate squares are empty (destination can be occupied for captures)."""
	var shape = piece.piece_shape
	
	match shape:
		"C":  # Circle: 1 step, no intermediate checks needed
			return true
		
		"T":  # Triangle: 2 steps, check 1 intermediate square
			var step1 = from_pos + (to_pos - from_pos) / 2
			return is_square_empty(step1)
		
		"S", "P":  # Square/Pyramid: 3 steps, check 2 intermediate squares
			var direction = (to_pos - from_pos) / 3
			var step1 = from_pos + direction
			var step2 = from_pos + direction * 2
			return is_square_empty(step1) and is_square_empty(step2)
	
	return false
	
func get_valid_moves(piece: Node2D, from_pos: Vector2i) -> Array[Vector2i]:
	"""Returns array of valid destination positions for a piece."""
	var valid_moves: Array[Vector2i] = []
	var potential_moves = get_potential_moves(piece, from_pos)
	
	for move in potential_moves:
		if is_move_valid(piece, from_pos, move):
			valid_moves.append(move)
	
	return valid_moves

func get_potential_moves(piece: Node2D, pos: Vector2i) -> Array[Vector2i]:
	"""Returns squares a piece could potentially move to (ignoring obstacles)."""
	var moves: Array[Vector2i] = []
	var shape = piece.piece_shape
	
	# Directions: up, down, left, right
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	
	match shape:
		"C":  # Circle moves 1 step
			for dir in directions:
				var dest = pos + dir
				if is_in_bounds(dest):
					moves.append(dest)
		
		"T":  # Triangle moves 2 steps
			for dir in directions:
				var dest = pos + dir * 2
				if is_in_bounds(dest):
					moves.append(dest)
		
		"S", "P":  # Square and Pyramid move 3 steps
			for dir in directions:
				var dest = pos + dir * 3
				if is_in_bounds(dest):
					moves.append(dest)
	
	return moves

func is_move_valid(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	"""Checks if a move to an empty square is valid (no pieces blocking path)."""
	# Destination must be empty
	var dest_tile = board.get_tile_at_coords(to_pos.x, to_pos.y)
	if dest_tile == null or dest_tile.get_child_count() > 0:
		return false
	
	var shape = piece.piece_shape
	
	match shape:
		"C":  # Circle: 1 step, no intermediate checks needed
			return true
		
		"T":  # Triangle: 2 steps, check 1 intermediate square
			var step1 = from_pos + (to_pos - from_pos) / 2
			return is_square_empty(step1)
		
		"S", "P":  # Square/Pyramid: 3 steps, check 2 intermediate squares
			var direction = (to_pos - from_pos) / 3
			var step1 = from_pos + direction
			var step2 = from_pos + direction * 2
			return is_square_empty(step1) and is_square_empty(step2)
	
	return false

# ===== CAPTURE VALIDATION =====

func get_all_possible_captures(captor_pos: Vector2i, captor_piece: Node2D) -> Array:
	"""Returns all possible captures for a piece at a given position.
	Returns array of dictionaries with keys: target_pos, captor_value, capture_types"""
	var all_captures = []
	
	# Check all enemy pieces on the board
	for y in range(8):
		for x in range(16):
			var target_tile = board.get_tile_at_coords(x, y)
			if target_tile == null or target_tile.get_child_count() == 0:
				continue
			
			var target_piece = target_tile.get_child(0)
			if target_piece.piece_color == captor_piece.piece_color:
				continue  # Can't capture own pieces
			
			var target_pos = Vector2i(x, y)
			
			# Get all possible captor values
			var captor_values = []
			if captor_piece.piece_shape == "P":
				# Pyramid can capture using any of its sub-values
				for sub_val in captor_piece.piece_label:
					captor_values.append(sub_val)
			else:
				if captor_piece.piece_label.size() > 0:
					captor_values = [captor_piece.piece_label[0]]
			
			# Check each captor value against target
			for captor_val in captor_values:
				var captures = []
				
				# If target is a pyramid, check captures against each sub-value
				if target_piece.piece_shape == "P":
					for target_sub_val in target_piece.piece_label:
						var sub_captures = get_possible_captures_for_value(
							captor_pos, captor_val, target_pos, captor_piece, target_sub_val, true
						)
						captures.append_array(sub_captures)
				else:
					# Regular piece - check against its value
					if target_piece.piece_label.size() > 0:
						captures = get_possible_captures_for_value(
							captor_pos, captor_val, target_pos, captor_piece, 
							target_piece.piece_label[0], false
						)
				
				if captures.size() > 0:
					all_captures.append({
						"target_pos": target_pos,
						"captor_value": captor_val,
						"capture_types": captures
					})
	
	return all_captures

func get_possible_captures_for_value(captor_pos: Vector2i, captor_val: int, target_pos: Vector2i, 
									  captor_piece: Node2D, target_val: int, is_pyramid_subpiece: bool) -> Array:
	"""Returns array of valid capture types for specific attacker value vs target value.
	Each element is a dict: {type: String, value: int, helper_pos: Vector2i or null}"""
	var captures = []
	
	var target_tile = board.get_tile_at_coords(target_pos.x, target_pos.y)
	if target_tile == null or target_tile.get_child_count() == 0:
		return captures
	
	var target_piece = target_tile.get_child(0)
	
	# Determine capture type prefix
	var type_prefix = "subpiece " if is_pyramid_subpiece else ""
	
	# 1. BLOCKADE - only for full pieces, not sub-pieces
	if not is_pyramid_subpiece and is_blockaded(target_pos):
		captures.append({"type": "blockade", "value": target_val, "helper_pos": null})
	
	# 2. EQUALITY (NUMBER) - same value, within ONE MOVE distance
	if is_within_capture_range(captor_piece, captor_pos, target_pos) and captor_val == target_val:
		captures.append({"type": type_prefix + "equality", "value": target_val, "helper_pos": null})
	
	# 3. MULTIPLE - target = captor * distance
	var path_data = get_path_clear_and_distance(captor_pos, target_pos)
	if path_data.clear and path_data.distance > 0:
		if captor_val > 0 and target_val > 0:
			if target_val % captor_val == 0:
				if target_val / captor_val == path_data.distance:
					captures.append({"type": type_prefix + "multiple", "value": target_val, "helper_pos": null})
	
	# 4. DIVISOR - captor = target * distance
	if path_data.clear and path_data.distance > 0:
		if target_val > 0 and captor_val > 0:
			if captor_val % target_val == 0:
				if captor_val / target_val == path_data.distance:
					captures.append({"type": type_prefix + "divisor", "value": target_val, "helper_pos": null})
	
	# 5. SUM and DIFFERENCE - requires helper piece within one move
	if is_within_capture_range(captor_piece, captor_pos, target_pos):
		var helper_captures = check_sum_and_difference(captor_pos, captor_val, target_pos, target_val)
		for cap in helper_captures:
			cap.type = type_prefix + cap.type
		captures.append_array(helper_captures)
	
	return captures

func is_within_one_move(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	"""Check if target is exactly one move away (reachable in one turn with path clear)."""
	# Must be orthogonally aligned
	if from_pos.x != to_pos.x and from_pos.y != to_pos.y:
		return false
	
	var shape = piece.piece_shape
	var distance = abs(to_pos.x - from_pos.x) + abs(to_pos.y - from_pos.y)
	
	# Check if distance matches piece's movement range
	var expected_distance = 0
	match shape:
		"C": expected_distance = 1
		"T": expected_distance = 2
		"S", "P": expected_distance = 3
	
	if distance != expected_distance:
		return false
	
	# Verify path is clear (all intermediate squares are empty)
	return is_move_valid(piece, from_pos, to_pos)

func check_sum_and_difference(captor_pos: Vector2i, captor_val: int, target_pos: Vector2i, target_val: int) -> Array:
	"""Check for sum and difference captures with helper pieces."""
	var captures = []
	
	# Get captor piece safely
	var captor_tile = board.get_tile_at_coords(captor_pos.x, captor_pos.y)
	if captor_tile == null or captor_tile.get_child_count() == 0:
		return captures
	
	var captor_piece = captor_tile.get_child(0)
	
	# Find all friendly pieces that can also reach the target in one move
	for y in range(8):
		for x in range(16):
			var helper_tile = board.get_tile_at_coords(x, y)
			if helper_tile == null or helper_tile.get_child_count() == 0:
				continue
			
			var helper_piece = helper_tile.get_child(0)
			var helper_pos = Vector2i(x, y)
			
			# Skip if same as captor
			if helper_pos == captor_pos:
				continue
			
			# Must be same color
			if helper_piece.piece_color != captor_piece.piece_color:
				continue
			
			# Check if helper can reach target in one move
			if not is_within_capture_range(helper_piece, helper_pos, target_pos):
				continue
			
			# Get helper value safely
			var helper_val = 0
			if helper_piece.piece_label.size() > 0:
				helper_val = helper_piece.piece_label[0]
			else:
				continue
			
			# Sum: captor + helper = target
			if captor_val + helper_val == target_val:
				captures.append({"type": "sum", "value": target_val, "helper_pos": helper_pos})
			
			# Difference: |captor - helper| = target
			if abs(captor_val - helper_val) == target_val:
				captures.append({"type": "difference", "value": target_val, "helper_pos": helper_pos})
	
	return captures

func is_blockaded(pos: Vector2i) -> bool:
	"""Returns true if piece at pos has no valid moves."""
	var tile = board.get_tile_at_coords(pos.x, pos.y)
	if tile == null or tile.get_child_count() == 0:
		return false
	
	var piece = tile.get_child(0)
	var valid_moves = get_valid_moves(piece, pos)
	return valid_moves.size() == 0

# ===== HELPER FUNCTIONS =====

func get_path_clear_and_distance(start_pos: Vector2i, end_pos: Vector2i) -> Dictionary:
	"""Returns {clear: bool, distance: int}. Distance is number of empty squares between."""
	# Must be orthogonal
	if start_pos.x != end_pos.x and start_pos.y != end_pos.y:
		return {"clear": false, "distance": -1}
	
	var direction = Vector2i(0, 0)
	var distance = 0
	
	if start_pos.x != end_pos.x:
		direction.x = 1 if end_pos.x > start_pos.x else -1
		distance = abs(end_pos.x - start_pos.x) - 1
	else:
		direction.y = 1 if end_pos.y > start_pos.y else -1
		distance = abs(end_pos.y - start_pos.y) - 1
	
	# Check each square in between
	var current = start_pos + direction
	while current != end_pos:
		if not is_square_empty(current):
			return {"clear": false, "distance": -1}
		current += direction
	
	return {"clear": true, "distance": distance}

func is_square_empty(pos: Vector2i) -> bool:
	"""Returns true if square is in bounds and has no piece."""
	if not is_in_bounds(pos):
		return false
	
	var tile = board.get_tile_at_coords(pos.x, pos.y)
	return tile != null and tile.get_child_count() == 0

func is_in_bounds(pos: Vector2i) -> bool:
	"""Returns true if position is on the board."""
	return pos.x >= 0 and pos.x < 16 and pos.y >= 0 and pos.y < 8

func get_all_possible_moves(color: String) -> Array:
	"""Returns all valid moves for a given color."""
	var all_moves = []
	for y in range(8):
		for x in range(16):
			var tile = board.get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			var piece = tile.get_child(0)
			if piece.piece_color == color:
				var pos = Vector2i(x, y)
				var moves = get_valid_moves(piece, pos)
				for move in moves:
					all_moves.append({"from": pos, "to": move})
	return all_moves

# Add this function inside your move_validator.gd script

# --- NEW: Get all captures for a piece based on simulated board state ---
func get_all_possible_captures_from_state(piece_id: String, start_pos: Vector2i, board_state: Array) -> Array:
	"""
	Calculates all possible captures for a given piece (identified by ID and position)
	based *only* on the provided board_state array.

	Args:
		piece_id (String): The ID of the attacking piece (e.g., "T072_1", "p190_1").
		start_pos (Vector2i): The position of the attacking piece in the board_state.
		board_state (Array): The 2D array representing the simulated board.

	Returns:
		Array: A list of captures. The exact format depends on how you store capture info.
			   It should be consistent with what _get_all_captures_for_player_from_state expects.
			   Example format: [{"attacker_pos": Vector2i, "victim_pos": Vector2i, "type": String, "value": int}, ...]
	"""
	var captures = []
	if piece_id == "": return [] # No piece, no captures

	# --- You need to adapt your existing capture logic here ---
	# Example: Replicating Capture by Numbering check for a Triangle (T)

	var piece_data = board. _parse_piece_data(piece_id) # Need access to board's helper or replicate it
	var attacker_values = piece_data.label
	var piece_color = piece_data.color
	var opponent_color = "black" if piece_color == "white" else "white"

	# 1. Determine which squares the piece *could* land on based on its type
	var potential_landing_spots = []
	match piece_data.shape:
		"C": # Circle
			var increments = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
			for inc in increments:
				var dest = start_pos + inc
				# Check bounds directly using board_state dimensions
				if dest.y >= 0 and dest.y < board_state.size() and dest.x >= 0 and dest.x < board_state[0].size():
					potential_landing_spots.append(dest)
		"T": # Triangle
			var increments = [Vector2i(0, 2), Vector2i(0, -2), Vector2i(2, 0), Vector2i(-2, 0)]
			var path_incs = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
			for i in range(increments.size()):
				var dest = start_pos + increments[i]
				var hop1 = start_pos + path_incs[i]
				# Check bounds and path clearance using board_state
				if dest.y >= 0 and dest.y < board_state.size() and dest.x >= 0 and dest.x < board_state[0].size() and \
				   hop1.y >= 0 and hop1.y < board_state.size() and hop1.x >= 0 and hop1.x < board_state[0].size() and \
				   board_state[hop1.y][hop1.x] == "":
					potential_landing_spots.append(dest)
		"S", "P": # Square, Pyramid
			var increments = [Vector2i(0, 3), Vector2i(0, -3), Vector2i(3, 0), Vector2i(-3, 0)]
			var path1_incs = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
			var path2_incs = [Vector2i(0, 2), Vector2i(0, -2), Vector2i(2, 0), Vector2i(-2, 0)]
			for i in range(increments.size()):
				var dest = start_pos + increments[i]
				var hop1 = start_pos + path1_incs[i]
				var hop2 = start_pos + path2_incs[i]
				# Check bounds and path clearance using board_state
				if dest.y >= 0 and dest.y < board_state.size() and dest.x >= 0 and dest.x < board_state[0].size() and \
				   hop1.y >= 0 and hop1.y < board_state.size() and hop1.x >= 0 and hop1.x < board_state[0].size() and \
				   hop2.y >= 0 and hop2.y < board_state.size() and hop2.x >= 0 and hop2.x < board_state[0].size() and \
				   board_state[hop1.y][hop1.x] == "" and board_state[hop2.y][hop2.x] == "":
					potential_landing_spots.append(dest)

	# 2. Check each potential landing spot for an opponent piece
	for dest_pos in potential_landing_spots:
		var victim_id = board_state[dest_pos.y][dest_pos.x]
		if victim_id != "":
			var victim_color = "white" if victim_id[0] == victim_id[0].to_upper() else "black"
			if victim_color == opponent_color:
				var victim_data = board._parse_piece_data(victim_id) # Need helper access
				var victim_values = victim_data.label

				# 3. Check capture condition (e.g., Numbering)
				if not attacker_values.is_empty() and not victim_values.is_empty():
					# Check if any attacker value matches any victim value
					var common_value = -1
					for av in attacker_values:
						if av in victim_values:
							common_value = av
							break
					if common_value != -1:
						captures.append({
							"attacker_pos": start_pos,
							"victim_pos": dest_pos,
							"type": "numbering",
							"value": common_value # The specific value used for capture
						})

	# --- TODO: Add similar logic for ALL OTHER CAPTURE TYPES ---
	# (Addition, Subtraction, Multiplication, Division, Siege)
	# Each will need to be adapted to read from the board_state array.
	# This will involve getting piece IDs, parsing data, checking distances/paths,
	# comparing values based only on the array content.

	# Example for Multiplication (conceptual):
	# for y_vic in range(board_state.size()):
	#     for x_vic in range(board_state[y_vic].size()):
	#         var victim_id = board_state[y_vic][x_vic]
	#         # ... check if it's opponent ...
	#         var victim_pos = Vector2i(x_vic, y_vic)
	#         var dist = _calculate_distance_in_line(start_pos, victim_pos, board_state) # Need this helper
	#         if dist > 0:
	#             # ... get victim_values ...
	#             for v_att in attacker_values:
	#                 for v_vic in victim_values:
	#                     if v_att * dist == v_vic:
	#                         captures.append({... type: "multiplication" ...})


	return captures

func get_valid_moves_from_state(piece_id: String, start_pos: Vector2i, board_state: Array) -> Array:
	"""
	Get valid move destinations for a piece based on a board state array.
	
	Args:
		piece_id: The piece identifier (e.g., "T072_1")
		start_pos: Current position of the piece
		board_state: 2D array representing the board
	
	Returns:
		Array of Vector2i positions the piece can move to
	"""
	var valid_moves = []
	var piece_data = board._parse_piece_data(piece_id)
	
	# Define movement patterns based on piece shape
	var potential_moves = []
	match piece_data.shape:
		"C": # Circle - moves 1 square orthogonally
			potential_moves = [
				Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 0), Vector2i(-1, 0)
			]
		"T": # Triangle - moves 2 squares orthogonally (must hop over empty square)
			var increments = [Vector2i(0, 2), Vector2i(0, -2), Vector2i(2, 0), Vector2i(-2, 0)]
			var hops = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
			for i in range(increments.size()):
				var dest = start_pos + increments[i]
				var hop_pos = start_pos + hops[i]
				# Check bounds and that hop square is empty
				if _is_valid_pos(dest, board_state) and _is_valid_pos(hop_pos, board_state):
					if board_state[hop_pos.y][hop_pos.x] == "":
						potential_moves.append(increments[i])
		"S", "P": # Square/Pyramid - moves 3 squares orthogonally (hops over 2 empty squares)
			var increments = [Vector2i(0, 3), Vector2i(0, -3), Vector2i(3, 0), Vector2i(-3, 0)]
			var hop1s = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
			var hop2s = [Vector2i(0, 2), Vector2i(0, -2), Vector2i(2, 0), Vector2i(-2, 0)]
			for i in range(increments.size()):
				var dest = start_pos + increments[i]
				var hop1_pos = start_pos + hop1s[i]
				var hop2_pos = start_pos + hop2s[i]
				# Check bounds and that both hop squares are empty
				if _is_valid_pos(dest, board_state) and _is_valid_pos(hop1_pos, board_state) and _is_valid_pos(hop2_pos, board_state):
					if board_state[hop1_pos.y][hop1_pos.x] == "" and board_state[hop2_pos.y][hop2_pos.x] == "":
						potential_moves.append(increments[i])
	
	# Check each potential move
	for move_offset in potential_moves:
		var dest_pos = start_pos + move_offset
		if _is_valid_pos(dest_pos, board_state):
			# Destination must be empty
			if board_state[dest_pos.y][dest_pos.x] == "":
				valid_moves.append(dest_pos)
	
	return valid_moves

func _is_valid_pos(pos: Vector2i, board_state: Array) -> bool:
	"""Helper to check if position is within board bounds"""
	return pos.y >= 0 and pos.y < board_state.size() and \
		   pos.x >= 0 and pos.x < board_state[pos.y].size()
