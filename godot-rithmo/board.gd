# board.gd - Complete with Turn Phase System, Button, and Game Logging
extends CenterContainer

# --- Node References ---
@onready var grid_container = $MainLayout/BoardAndColumnLabels/GridContainer
@onready var row_labels_container = $MainLayout/RowLabels
@onready var column_labels_container = $MainLayout/BoardAndColumnLabels/ColumnLabels
@onready var piece_layer = $PieceLayer
@onready var captured_white_container = $CanvasLayer/CapturedWhitePieces
@onready var captured_black_container = $CanvasLayer/CapturedBlackPieces

# --- New Panel References ---
@onready var left_panel = $CanvasLayer/LeftPanel
@onready var center_panel = $CanvasLayer/CenterPanel
@onready var right_panel = $CanvasLayer/RightPanel

# Direct references to labels for easier access
@onready var turn_label = $CanvasLayer/CenterPanel/MarginContainer/VBoxContainer/TurnLabel
@onready var action_label = $CanvasLayer/CenterPanel/MarginContainer/VBoxContainer/ActionLabel
@onready var white_captured_label = $CanvasLayer/LeftPanel/MarginContainer/VBoxContainer/WhiteCapturedLabel
@onready var white_pyramid_label = $CanvasLayer/LeftPanel/MarginContainer/VBoxContainer/WhitePyramidLabel
@onready var black_captured_label = $CanvasLayer/RightPanel/MarginContainer/VBoxContainer/BlackCapturedLabel
@onready var black_pyramid_label = $CanvasLayer/RightPanel/MarginContainer/VBoxContainer/BlackPyramidLabel

# --- Scene and Style Variables ---
var tile_color = Color("#ADD8E6")

# --- Piece Setup Variables ---
@export var piece_scene: PackedScene
const INITIAL_PYRAMID_LABELS = {
	"P091_1": [1, 4, 9, 16, 25, 36],
	"p190_1": [16, 25, 36, 49, 64]
}

var initial_board_state = [
	['S289_1', 'S153_1', 'T081_1', '', '', '', '', '', '', '', '', '', '', 't016_1', 's028_1', 's049_1'],
	['S169_1', 'P091_1', 'T072_1', '', '', '', '', '', '', '', '', '', '', 't012_1', 's066_1', 's121_1'],
	['', 'T049_1', 'C064_1', 'C008_1', '', '', '', '', '', '', '', '', 'c003_1', 'c009_1', 't036_1', ''],
	['', 'T042_1', 'C036_1', 'C006_1', '', '', '', '', '', '', '', '', 'c005_1', 'c025_1', 't030_1', ''],
	['', 'T020_1', 'C016_1', 'C004_1', '', '', '', '', '', '', '', '', 'c007_1', 'c049_1', 't056_1', ''],
	['', 'T025_1', 'C004_2', 'C002_1', '', '', '', '', '', '', '', '', 'c009_2', 'c081_1', 't064_1', ''],
	['S081_1', 'S045_1', 'T006_1', '', '', '', '', '', '', '', '', '', '', 't090_1', 's120_1', 's225_1'],
	['S025_1', 'S015_1', 'T009_1', '', '', '', '', '', '', '', '', '', '', 't100_1', 'p190_1', 's361_1']
]

var game_winner: String = ""  # "Black", "White", or ""
var game_victory_type: String = ""  # "Body", "Goods", or ""

# --- Game State Variables ---
var selected_tile: ColorRect = null
var selected_piece: Node2D = null
var original_tile_color: Color = Color("#ADD8E6")
var highlight_color: Color = Color("#FFFF99")
var valid_move_highlight: Color = Color("#90EE90")
var valid_capture_highlight: Color = Color("#FFB6C6")
var selected_piece_tween: Tween = null

# --- Turn Phase System ---
enum TurnPhase { PRE_MOVE_CAPTURE, MOVE, POST_MOVE_CAPTURE }
var current_phase: TurnPhase = TurnPhase.PRE_MOVE_CAPTURE
var current_player: String = "white"

# --- UI Elements ---
var phase_button: Button = null

# --- Game Log System ---
var game_log: Array = []
var current_turn_log: Dictionary = {}

# --- Captured Pieces Tracking ---
var captured_white_piece_values: Array[int] = []
var captured_black_piece_values: Array[int] = []
# Victory tracking
var black_pieces_captured: int = 0
var black_value_captured: int = 0
var white_pieces_captured: int = 0
var white_value_captured: int = 0
var game_ended: bool = false

# --- Move Validator ---
var move_validator = null

# UI References
var help_button: Button
var help_window: Panel

# Game Setup Window
var setup_window: Panel
var victory_n0: int = 10  # Default: Common Victory by Body
var victory_n1: int = 400  # Default: Common Victory by Goods
var setup_difficulty: String = "Medium"  # Track chosen difficulty
var turns_completed: int = 0  # Track turns to auto-close setup window

# Status panel reference (you may already have this)
var status_label: Label  # Reference to your center status panel


# ========================================
# Add button creation to _ready() in board.gd
# ========================================

func _ready():
	add_to_group("board")
	$MainLayout/BoardAndColumnLabels.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	
	var MoveValidator = load("res://move_validator.gd")
	move_validator = MoveValidator.new(self)
	
	generate_board()
	generate_labels()
	setup_pieces()
	setup_capture_containers()
	setup_ui_overlay()           # Set up UI overlays
	
	# === FIX: Only make captured piece containers ignore mouse ===
	# These containers are positioned over the board and block input
	if captured_white_container:
		make_container_pass_through(captured_white_container)
	if captured_black_container:
		make_container_pass_through(captured_black_container)
	
	# FIND YOUR STATUS LABEL - try one of these:
	status_label = $CanvasLayer/CenterPanel/MarginContainer/VBoxContainer/ActionLabel
	# If you can't find it, use the debug helper:
	find_all_labels(self)  # This will print all Label paths
	create_game_setup_window()   # Create and show the game setup window
	setup_window.show()
	create_phase_button()
	create_undo_button()
	create_export_button()
	
	# Initialize all panel displays
	if turn_label != null and action_label != null:
		sync_pyramid_values_to_panel()
		update_phase_display()
		update_captured_display("white", captured_white_piece_values)
		update_captured_display("black", captured_black_piece_values)
	else:
		print("WARNING: Panel labels not found!")
	
	start_new_turn_log()

# --- Piece Generation Logic ---
func setup_pieces():
	print("=== Starting setup_pieces ===")
	if piece_scene == null:
		print("ERROR: piece_scene is null!")
		return
	
	var pieces_created = 0
	for y in range(initial_board_state.size()):
		for x in range(initial_board_state[y].size()):
			var piece_id = initial_board_state[y][x]
			if piece_id == "":
				continue
			pieces_created += 1
			var tile_index = y * 16 + x
			var tile = grid_container.get_child(tile_index)
			var piece_data = _parse_piece_data(piece_id)
			tile.place_piece(piece_scene, piece_id, piece_data)
	
	print("=== Finished setup_pieces. Total pieces created: ", pieces_created, " ===")

func find_all_labels(node: Node, depth: int = 0):
	"""Debug helper to find all Label nodes"""
	var indent = "  ".repeat(depth)
	if node is Label:
		print(indent, "LABEL FOUND:", node.get_path())
	for child in node.get_children():
		find_all_labels(child, depth + 1)
		
func _parse_piece_data(id_string: String) -> Dictionary:
	var first_char = id_string[0]
	var data = {
		"color": "white" if first_char == first_char.to_upper() else "black",
		"shape": first_char.to_upper(),
		"label": []
	}
	if (data.shape == "P"):
		data.label = INITIAL_PYRAMID_LABELS[id_string].duplicate()
	else:
		data.label = [int(id_string.substr(1, 3))]
	return data

# --- Board and Label Generation ---
func generate_board():
	for i in range(16 * 8):
		var tile = ColorRect.new()
		tile.color = tile_color
		tile.custom_minimum_size = Vector2(80, 80)
		tile.set_script(load("res://tile.gd"))
		tile.clip_contents = false
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.gui_input.connect(_on_tile_clicked.bind(tile))
		grid_container.add_child(tile)

func generate_labels():
	var corner_spacer = Control.new()
	corner_spacer.custom_minimum_size = Vector2(40, 40)
	row_labels_container.add_child(corner_spacer)
	
	for i in range(8):
		var label = Label.new()
		label.text = str(i + 1)
		label.custom_minimum_size = Vector2(40, 80)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_labels_container.add_child(label)
	
	var column_letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
	for letter in column_letters:
		var label = Label.new()
		label.text = letter
		label.custom_minimum_size = Vector2(80, 40)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column_labels_container.add_child(label)

func setup_capture_containers():
	if captured_white_container:
		# Position on left side for debugging
		captured_white_container.position = Vector2(20, 20)
		captured_white_container.size = Vector2(220, 350)
		captured_white_container.columns = 4  # 4 columns
		captured_white_container.add_theme_constant_override("separation", 10)
		
		# DON'T ADD A COLORRECT AS A CHILD!
		# Instead, create a Panel parent to hold the GridContainer
		var white_panel = Panel.new()
		white_panel.position = Vector2(get_viewport_rect().size.x - 250, 20)  # Top right
		white_panel.size = Vector2(220, 350)
		
		var white_style = StyleBoxFlat.new()
		white_style.bg_color = Color(0.95, 0.95, 0.95, 0.8)
		white_style.border_width_left = 2
		white_style.border_width_right = 2
		white_style.border_width_top = 2
		white_style.border_width_bottom = 2
		white_style.border_color = Color.WHITE
		white_panel.add_theme_stylebox_override("panel", white_style)
		
		# Reparent the GridContainer
		get_node("CanvasLayer").add_child(white_panel)
		captured_white_container.get_parent().remove_child(captured_white_container)
		white_panel.add_child(captured_white_container)
		captured_white_container.position = Vector2.ZERO
		captured_white_container.size = Vector2(220, 350)
		captured_white_container.anchor_right = 1.0
		captured_white_container.anchor_bottom = 1.0
		
		print("White capture container setup")
	
	if captured_black_container:
		captured_black_container.position = Vector2(20, 390)
		captured_black_container.size = Vector2(220, 350)
		captured_black_container.columns = 4
		captured_black_container.add_theme_constant_override("separation", 10)
		
		var black_panel = Panel.new()
		black_panel.position = Vector2(get_viewport_rect().size.x - 250, 390) # Below white
		black_panel.size = Vector2(220, 350)
		
		var black_style = StyleBoxFlat.new()
		black_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		black_style.border_width_left = 2
		black_style.border_width_right = 2
		black_style.border_width_top = 2
		black_style.border_width_bottom = 2
		black_style.border_color = Color.BLACK
		black_panel.add_theme_stylebox_override("panel", black_style)
		
		get_node("CanvasLayer").add_child(black_panel)
		captured_black_container.get_parent().remove_child(captured_black_container)
		black_panel.add_child(captured_black_container)
		captured_black_container.position = Vector2.ZERO
		captured_black_container.size = Vector2(220, 350)
		captured_black_container.anchor_right = 1.0
		captured_black_container.anchor_bottom = 1.0
		
		print("Black capture container setup")

func create_phase_button():
	"""Creates a button for advancing phases."""
	phase_button = Button.new()
	phase_button.custom_minimum_size = Vector2(250, 60)
	phase_button.position = Vector2(350, 20)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.6, 0.9)
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color.WHITE
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	phase_button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.3, 0.7, 1.0)
	style_hover.border_width_left = 2
	style_hover.border_width_right = 2
	style_hover.border_width_top = 2
	style_hover.border_width_bottom = 2
	style_hover.border_color = Color.WHITE
	style_hover.corner_radius_top_left = 5
	style_hover.corner_radius_top_right = 5
	style_hover.corner_radius_bottom_left = 5
	style_hover.corner_radius_bottom_right = 5
	phase_button.add_theme_stylebox_override("hover", style_hover)
	
	var style_disabled = StyleBoxFlat.new()
	style_disabled.bg_color = Color(0.5, 0.5, 0.5)
	style_disabled.border_width_left = 2
	style_disabled.border_width_right = 2
	style_disabled.border_width_top = 2
	style_disabled.border_width_bottom = 2
	style_disabled.border_color = Color(0.3, 0.3, 0.3)
	style_disabled.corner_radius_top_left = 5
	style_disabled.corner_radius_top_right = 5
	style_disabled.corner_radius_bottom_left = 5
	style_disabled.corner_radius_bottom_right = 5
	phase_button.add_theme_stylebox_override("disabled", style_disabled)
	
	$CanvasLayer.add_child(phase_button)
	phase_button.pressed.connect(_on_phase_button_pressed)
	
	update_phase_button_text()

func update_phase_button_text():
	"""Updates button text based on current phase."""
	if phase_button == null:
		return
	
	match current_phase:
		TurnPhase.PRE_MOVE_CAPTURE:
			phase_button.text = "Done Capturing - Ready to Move"
			phase_button.disabled = false
		TurnPhase.MOVE:
			phase_button.text = "Waiting for Move..."
			phase_button.disabled = true
		TurnPhase.POST_MOVE_CAPTURE:
			phase_button.text = "End Turn"
			phase_button.disabled = false

func _on_phase_button_pressed():
	"""Handle phase button press."""
	match current_phase:
		TurnPhase.PRE_MOVE_CAPTURE:
			advance_to_move_phase()
		TurnPhase.POST_MOVE_CAPTURE:
			advance_to_next_player()

# --- New Panel Update Functions ---
func update_turn_display():
	"""Updates the turn label."""
	if turn_label:
		turn_label.text = "Current Turn: %s" % current_player.capitalize()

func update_action_display():
	"""Updates the action/phase label."""
	if action_label:
		var phase_text = ""
		match current_phase:
			TurnPhase.PRE_MOVE_CAPTURE:
				phase_text = "pre-move capture"
			TurnPhase.MOVE:
				phase_text = "move"
			TurnPhase.POST_MOVE_CAPTURE:
				phase_text = "post-move capture"
		action_label.text = "Action: %s" % phase_text

func update_captured_display(color: String, values: Array[int]):
	"""Updates the captured pieces display for a color."""
	var sum = values.reduce(func(acc, v): return acc + v, 0)
	var text = "%s Captured (%d): %s" % [color.capitalize(), sum, str(values)]
	
	if color == "white":
		if white_captured_label:
			white_captured_label.text = text
	else:
		if black_captured_label:
			black_captured_label.text = text

func update_pyramid_display(color: String, values: Array):
	"""Updates the pyramid values display for a color."""
	var text = "%s Pyramid: %s" % [color.capitalize(), str(values)]
	
	if color == "white":
		if white_pyramid_label:
			white_pyramid_label.text = text
	else:
		if black_pyramid_label:
			black_pyramid_label.text = text

# --- Turn Phase Management ---
func update_phase_display():
	update_action_display()
	update_turn_display()
	update_phase_button_text()

func advance_to_move_phase():
	print("Advancing to MOVE phase")
	current_phase = TurnPhase.MOVE
	deselect_piece()
	update_phase_display()

func advance_to_post_capture_phase():
	print("Advancing to POST_MOVE_CAPTURE phase")
	current_phase = TurnPhase.POST_MOVE_CAPTURE
	deselect_piece()
	update_phase_display()

func advance_to_next_player():
	print("Advancing to next player's turn")
	finalize_turn_log()
	current_player = "black" if current_player == "white" else "white"
	current_phase = TurnPhase.PRE_MOVE_CAPTURE
	start_new_turn_log()
	deselect_piece()
	update_phase_display()
	check_if_player_can_move()

func check_if_player_can_move() -> bool:
	"""Check if current player has any legal moves. If not, game over."""
	var valid_moves = move_validator.get_all_possible_moves(current_player)
	if valid_moves.size() == 0:
		var winner = "black" if current_player == "white" else "white"
		show_game_over(winner.capitalize() + " wins! " + current_player.capitalize() + " has no legal moves.")
		return false
	return true

func show_game_over(message: String):
	print("GAME OVER: ", message)
	
	# Update action label to show game over
	if action_label:
		action_label.text = "GAME OVER"
	
	# Update turn label with the win message
	if turn_label:
		turn_label.text = message
	
	# Disable the phase button
	if phase_button:
		phase_button.text = message
		phase_button.disabled = true

# --- Game Log System ---


func log_capture(attacker_piece: Node2D, attacker_pos: Vector2i, victim_piece: Node2D, 
				 victim_pos: Vector2i, capture_type: String, captured_value: int, 
				 is_subpiece: bool, helper_piece: Node2D = null):
	"""
	Record a capture in the current turn log.
	"""
	var capture_entry = {
		"captured_piece": {
			"id": victim_piece.piece_id,
			"value": captured_value,
			"color": victim_piece.piece_color,
			"shape": victim_piece.piece_shape
		},
		"capturing_pieces": [
			{
				"id": attacker_piece.piece_id,
				"value": attacker_piece.piece_label[0] if attacker_piece.piece_label.size() > 0 else 0,
				"color": attacker_piece.piece_color,
				"shape": attacker_piece.piece_shape,
				"pos": attacker_pos
			}
		],
		"captured_pos": victim_pos,
		"capture_type": capture_type,
		"is_subpiece": is_subpiece,
		# NEW: Add subpiece details for better logging
		"subpiece_value": captured_value if is_subpiece else 0,
		"parent_pyramid_id": victim_piece.piece_id if is_subpiece else ""
	}
	
	if helper_piece:
		var helper_pos = find_piece_position(helper_piece)
		capture_entry.capturing_pieces.append({
			"id": helper_piece.piece_id,
			"value": helper_piece.piece_label[0] if helper_piece.piece_label.size() > 0 else 0,
			"color": helper_piece.piece_color,
			"shape": helper_piece.piece_shape,
			"pos": helper_pos
		})
	
	if current_phase == TurnPhase.PRE_MOVE_CAPTURE:
		current_turn_log.pre_move_captures.append(capture_entry)
	else:
		current_turn_log.post_move_captures.append(capture_entry)
	
	print_capture_to_console(capture_entry)

func log_move(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i):
	"""Record a move in the current turn log."""
	current_turn_log.move = {
		"piece": {
			"id": piece.piece_id,
			"value": piece.piece_label[0] if piece.piece_label.size() > 0 else 0,
			"color": piece.piece_color,
			"shape": piece.piece_shape
		},
		"from_pos": from_pos,
		"to_pos": to_pos
	}
	print_move_to_console(current_turn_log.move)

func finalize_turn_log():
	"""Save current turn log and print summary."""
	game_log.append(current_turn_log.duplicate(true))
	print_turn_summary(current_turn_log)
	current_turn_log = {}

func print_capture_to_console(capture: Dictionary):
	"""Pretty print a capture event."""
	var msg = "CAPTURE: "
	
	if capture.capturing_pieces.size() == 1:
		var cap = capture.capturing_pieces[0]
		msg += "%s (value %d) at %s" % [cap.id, cap.value, cap.pos]
	else:
		msg += "["
		for i in range(capture.capturing_pieces.size()):
			var cap = capture.capturing_pieces[i]
			msg += "%s (value %d)" % [cap.id, cap.value]
			if i < capture.capturing_pieces.size() - 1:
				msg += " + "
		msg += "]"
	
	msg += " captures by %s" % capture.capture_type
	
	if capture.is_subpiece:
		msg += " -> subpiece value %d from %s at %s" % [
			capture.captured_piece.value,
			capture.captured_piece.id,
			capture.captured_pos
		]
	else:
		msg += " -> %s (value %d) at %s" % [
			capture.captured_piece.id,
			capture.captured_piece.value,
			capture.captured_pos
		]
	
	print(msg)

func print_move_to_console(move: Dictionary):
	"""Pretty print a move event."""
	print("MOVE: %s moves from %s to %s" % [
		move.piece.id,
		move.from_pos,
		move.to_pos
	])

func print_turn_summary(turn_log: Dictionary):
	"""Print summary of entire turn."""
	print("\n========== TURN %d SUMMARY (%s) ==========" % [turn_log.turn_number, turn_log.player.to_upper()])
	print("Pre-move captures: %d" % turn_log.pre_move_captures.size())
	if turn_log.move:
		print("Move: %s from %s to %s" % [turn_log.move.piece.id, turn_log.move.from_pos, turn_log.move.to_pos])
	print("Post-move captures: %d" % turn_log.post_move_captures.size())
	print("=".repeat(50) + "\n")

func find_piece_position(piece: Node2D) -> Vector2i:
	"""Find the current position of a piece on the board."""
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile and tile.get_child_count() > 0:
				if tile.get_child(0) == piece:
					return Vector2i(x, y)
	return Vector2i(-1, -1)

func export_game_log_to_text() -> String:
	"""Export entire game log as readable text."""
	var text = "RITHMOMACHIA GAME LOG\n"
	text += "=".repeat(60) + "\n"
	text += "Victory Conditions: %s\n" % setup_difficulty
	text += "  Common Victory by Body (N0): %d pieces\n" % victory_n0
	text += "  Common Victory by Goods (N1): %d points\n" % victory_n1
	text += "=".repeat(60) + "\n\n"
	
	for turn in game_log:
		text += "Turn %d - %s\n" % [turn.turn_number, turn.player.capitalize()]
		text += "-".repeat(40) + "\n"
		
		if turn.pre_move_captures.size() > 0:
			text += "Pre-move captures:\n"
			for cap in turn.pre_move_captures:
				text += format_capture_for_log(cap)
		
		if turn.move:
			text += "Move: %s from %s to %s\n" % [
				turn.move.piece.id,
				turn.move.from_pos,
				turn.move.to_pos
			]
		
		if turn.post_move_captures.size() > 0:
			text += "Post-move captures:\n"
			for cap in turn.post_move_captures:
				text += format_capture_for_log(cap)
		
		text += "\n"
	
	# Add victory declaration at the end
	if game_winner != "":
		text += "=".repeat(60) + "\n"
		text += "🏆 GAME OVER - %s WINS! 🏆\n" % game_winner.to_upper()
		text += "=".repeat(60) + "\n\n"
		
		if game_victory_type == "Body":
			var pieces_captured = black_pieces_captured if game_winner == "Black" else white_pieces_captured
			text += "Victory Method: Common Victory by Body (De Corpore)\n"
			text += "%s captured %d pieces (needed %d)\n\n" % [game_winner, pieces_captured, victory_n0]
		elif game_victory_type == "Goods":
			var value_captured = black_value_captured if game_winner == "Black" else white_value_captured
			text += "Victory Method: Common Victory by Goods (De Bonis)\n"
			text += "%s captured %d points worth of pieces (needed %d)\n\n" % [game_winner, value_captured, victory_n1]
		
		text += "Total Captures:\n"
		text += "  Black: %d pieces (%d points)\n" % [black_pieces_captured, black_value_captured]
		text += "  White: %d pieces (%d points)\n\n" % [white_pieces_captured, white_value_captured]
		
		text += "-".repeat(60) + "\n"
		text += "Thank you for playing Rithmomachia!\n"
		text += "This ancient game of numbers has challenged minds for centuries.\n"
		text += "Ready for another battle? May your strategy be sharp and\n"
		text += "your calculations be true!\n"
		text += "-".repeat(60) + "\n"
	
	return text

func format_capture_for_log(cap: Dictionary) -> String:
	"""Format a capture entry with proper details for the log"""
	
	# Check if it's a subpiece capture
	if cap.is_subpiece and cap.has("subpiece_value") and cap.has("parent_pyramid_id"):
		# Generate subpiece ID
		var color_prefix = "S" if cap.captured_piece.color == "white" else "s"
		var subpiece_id = "%s%03d_1" % [color_prefix, cap.subpiece_value]
		
		# Get capturing piece info
		var capturing_id = cap.capturing_pieces[0].id if cap.capturing_pieces.size() > 0 else "unknown"
		
		# Extract method and calculate operator
		var method = "equality"
		var operator_str = ""
		
		if "divisor" in cap.capture_type:
			method = "divisor"
			# Calculate divisor: attacker_value / subpiece_value
			if cap.capturing_pieces.size() > 0:
				var attacker_val = cap.capturing_pieces[0].value
				var divisor = attacker_val / cap.subpiece_value if cap.subpiece_value > 0 else 0
				operator_str = ", d = %d" % divisor
				
		elif "multiple" in cap.capture_type or "product" in cap.capture_type:
			method = "multiple"
			# Calculate multiplier: subpiece_value / attacker_value
			if cap.capturing_pieces.size() > 0:
				var attacker_val = cap.capturing_pieces[0].value
				var multiplier = cap.subpiece_value / attacker_val if attacker_val > 0 else 0
				operator_str = ", m = %d" % multiplier
		
		return "  - Subpiece %s of %s captured by %s%s by %s\n" % [
			subpiece_id,
			cap.parent_pyramid_id,
			method,
			operator_str,
			capturing_id
		]
	
	# Regular full piece capture
	return "  - %s by %s\n" % [cap.captured_piece.id, cap.capture_type]

# --- Player Input Handling ---
func _on_tile_clicked(event: InputEvent, clicked_tile: ColorRect):
	if not event is InputEventMouseButton:
		return
	
	if not event.pressed:
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		if current_phase == TurnPhase.MOVE:
			handle_move_phase_click(clicked_tile)
		else:
			handle_capture_phase_click(clicked_tile)

func handle_capture_phase_click(clicked_tile: ColorRect):
	"""Handle clicks during capture phases."""
	if selected_tile == null:
		if clicked_tile.get_child_count() > 0:
			var piece = clicked_tile.get_child(0)
			if piece.piece_color == current_player:
				select_piece_for_capture(clicked_tile, piece)
			else:
				print("Cannot select enemy piece as attacker")
		return
	
	if clicked_tile == selected_tile:
		deselect_piece()
		return
	
	if clicked_tile.get_child_count() > 0:
		var piece = clicked_tile.get_child(0)
		if piece.piece_color == current_player:
			deselect_piece()
			select_piece_for_capture(clicked_tile, piece)
			return
	
	if clicked_tile.get_child_count() > 0:
		var target_piece = clicked_tile.get_child(0)
		if target_piece.piece_color != current_player:
			attempt_capture(selected_tile, clicked_tile)
		else:
			print("Cannot capture friendly piece")
	else:
		print("Cannot capture empty square")
	
	deselect_piece()

func handle_move_phase_click(clicked_tile: ColorRect):
	"""Handle clicks during move phase."""
	if selected_tile == null:
		if clicked_tile.get_child_count() > 0:
			var piece = clicked_tile.get_child(0)
			if piece.piece_color == current_player:
				select_piece_for_move(clicked_tile, piece)
		return
	
	if clicked_tile == selected_tile:
		deselect_piece()
		return
	
	if clicked_tile.get_child_count() > 0:
		var piece = clicked_tile.get_child(0)
		if piece.piece_color == current_player:
			deselect_piece()
			select_piece_for_move(clicked_tile, piece)
			return
	
	if clicked_tile.get_child_count() == 0:
		attempt_move(selected_tile, clicked_tile)
	else:
		print("Cannot move to occupied square")
	
	deselect_piece()

func select_piece_for_capture(tile: ColorRect, piece: Node2D):
	"""Select piece and show valid capture targets with animated feedback."""
	print("Selecting piece for capture: ", piece.piece_id)
	selected_tile = tile
	selected_piece = piece
	original_tile_color = tile.color
	
	animate_selected_piece(piece)
	
	var piece_pos = get_tile_coords(tile)
	var all_captures = move_validator.get_all_possible_captures(piece_pos, piece)
	
	var unique_targets = {}
	for capture_data in all_captures:
		var pos_key = str(capture_data.target_pos)
		if pos_key not in unique_targets:
			unique_targets[pos_key] = capture_data.target_pos
	
	print("Possible captures: ", unique_targets.size())
	for pos_key in unique_targets:
		var target_pos = unique_targets[pos_key]
		var target_tile = get_tile_at_coords(target_pos.x, target_pos.y)
		if target_tile and target_tile != tile:
			target_tile.color = valid_capture_highlight

func select_piece_for_move(tile: ColorRect, piece: Node2D):
	"""Select piece and show valid move destinations with animated feedback."""
	print("Selecting piece for move: ", piece.piece_id)
	selected_tile = tile
	selected_piece = piece
	original_tile_color = tile.color
	
	animate_selected_piece(piece)
	
	var piece_pos = get_tile_coords(tile)
	var valid_moves = move_validator.get_valid_moves(piece, piece_pos)
	
	print("Valid moves: ", valid_moves.size())
	for move_pos in valid_moves:
		var move_tile = get_tile_at_coords(move_pos.x, move_pos.y)
		if move_tile and move_tile != tile:
			move_tile.color = valid_move_highlight

func animate_selected_piece(piece: Node2D):
	"""Add pulsing animation to selected piece."""
	if selected_piece_tween:
		selected_piece_tween.kill()
	
	selected_piece_tween = create_tween()
	selected_piece_tween.set_loops()
	selected_piece_tween.tween_property(piece, "scale", Vector2(1.15, 1.15), 0.5)
	selected_piece_tween.tween_property(piece, "scale", Vector2(1.0, 1.0), 0.5)
	
	piece.modulate = Color(1.5, 1.5, 1.0)

func deselect_piece():
	if selected_tile != null:
		if selected_piece_tween:
			selected_piece_tween.kill()
			selected_piece_tween = null
		
		if selected_piece:
			selected_piece.scale = Vector2(1.0, 1.0)
			selected_piece.modulate = Color(1.0, 1.0, 1.0)
		
		for pos in range(8 * 16):
			var tile = grid_container.get_child(pos)
			tile.color = tile_color
		
		selected_tile = null
		selected_piece = null


# /=====================================================\
# |          START OF NEW/UPDATED CODE SECTION          |
# \=====================================================/

# --- Capture Logic (New and Improved) ---

func attempt_capture(attacker_tile: ColorRect, victim_tile: ColorRect):
	"""
	Determines the valid capture type and executes it.
	This is the new "controller" that connects the validator's rules to the board's actions.
	"""
	# 1. Get all necessary pieces and board coordinates
	var from_coords = get_tile_coords(attacker_tile)
	var to_coords = get_tile_coords(victim_tile)
	var attacker_piece = attacker_tile.get_child(0)
	var victim_piece = victim_tile.get_child(0)

	# 2. Ask the validator for ALL possible captures the attacker can make
	var all_captures_from_attacker = move_validator.get_all_possible_captures(from_coords, attacker_piece)
	
	# 3. Find the specific capture data that matches the clicked victim
	var valid_capture_options = null
	for capture_option in all_captures_from_attacker:
		if capture_option.target_pos == to_coords:
			valid_capture_options = capture_option
			break

	if valid_capture_options == null or valid_capture_options.capture_types.size() == 0:
		print("ERROR: Clicked on a valid target, but no capture type was found.")
		return

	# 4. For simplicity, we execute the FIRST valid capture type found.
	# A more advanced game could show a UI to let the user choose if there are multiple options.
	var capture_to_execute = valid_capture_options.capture_types[0]
	var capture_type_str = capture_to_execute.type
	var captured_value = capture_to_execute.value
	var helper_pos = capture_to_execute.helper_pos

	print("Executing capture! Type: '%s', Value: %d" % [capture_type_str, captured_value])

	# 5. Find the helper piece on the board, if one is required for the capture
	var helper_piece = null
	if helper_pos != null:
		var helper_tile = get_tile_at_coords(helper_pos.x, helper_pos.y)
		if helper_tile and helper_tile.get_child_count() > 0:
			helper_piece = helper_tile.get_child(0)

	# 6. Log the capture with all details (attacker, victim, type, helper)
	var is_subpiece_capture = capture_type_str.begins_with("subpiece") or victim_piece.piece_shape == "P"
	log_capture(attacker_piece, from_coords, victim_piece, to_coords, capture_type_str, captured_value, is_subpiece_capture, helper_piece)

	# 7. Execute the capture by removing the correct piece or sub-piece from the board
	if victim_piece.piece_shape == "P":
		# The victim is a pyramid, so we only remove a sub-piece
		execute_pyramid_subpiece_removal(victim_piece, captured_value, to_coords)
	else:
		# The victim is a regular piece, so we remove the whole thing
		execute_full_piece_removal(victim_tile)


func execute_full_piece_removal(victim_tile: ColorRect):
	"""
	Handles the removal of an entire piece from the board.
	Used by any capture type that targets a non-pyramid piece.
	"""
	var victim_piece = victim_tile.get_child(0)
	var victim_pos = get_tile_coords(victim_tile)
	
	# If the captured piece is a pyramid, we must log every sub-value as captured.
	if victim_piece.piece_shape == "P":
		# Use .duplicate() to avoid modifying the array while iterating
		for sub_val in victim_piece.piece_label.duplicate():
			on_piece_captured(victim_piece.piece_color, sub_val)
	else:
		var victim_value = victim_piece.piece_label[0] if victim_piece.piece_label.size() > 0 else 0
		on_piece_captured(victim_piece.piece_color, victim_value)
	
	# Remove the piece from the game board and move it to the captured area
	victim_tile.remove_child(victim_piece)
	move_to_capture_zone(victim_piece)
	initial_board_state[victim_pos.y][victim_pos.x] = ""
	print("Full piece %s removed from board." % victim_piece.piece_id)


func execute_pyramid_subpiece_removal(pyramid_piece: Node2D, captured_value: int, pyramid_pos: Vector2i):
	"""
	Handles the removal of a single value (sub-piece) from a pyramid.
	Used by any capture type that targets a pyramid.
	"""
	# Create a visual representation of the captured sub-piece for the side panel
	var subpiece_display = await create_subpiece_for_capture_display(
		pyramid_piece.piece_id,
		captured_value,
		pyramid_piece.piece_color
	)
	
	# Update game state: remove value from the pyramid's data and add it to captured list
	pyramid_piece.remove_subpiece(captured_value)
	on_piece_captured(pyramid_piece.piece_color, captured_value)

	# Move the visual representation to the captured area
	if subpiece_display != null:
		move_to_capture_zone(subpiece_display)
	
	# If the pyramid has no values left, remove it from the board entirely
	if pyramid_piece.piece_label.size() == 0:
		print("Pyramid %s is now empty and is being removed." % pyramid_piece.piece_id)
		var pyramid_tile = get_tile_at_coords(pyramid_pos.x, pyramid_pos.y)
		if pyramid_tile and pyramid_tile.has_node(pyramid_piece.get_path()):
			pyramid_tile.remove_child(pyramid_piece)
			pyramid_piece.queue_free()
		initial_board_state[pyramid_pos.y][pyramid_pos.x] = ""
		update_pyramid_display(pyramid_piece.piece_color, [])
	else:
		update_pyramid_display(pyramid_piece.piece_color, pyramid_piece.piece_label)
	
	print("Pyramid sub-piece with value %d removed." % captured_value)

func create_subpiece_for_capture_display(pyramid_id: String, subpiece_value: int, color: String) -> Node2D:
	"""Creates a visual representation of a captured pyramid sub-piece for the capture panel.
	Uses Square piece graphics since pyramid sub-pieces are square values."""
	if piece_scene == null:
		print("ERROR: piece_scene is null, cannot create sub-piece display")
		return null
	
	var display_piece = piece_scene.instantiate()
	
	# Use Square piece ID format - pyramid sub-pieces are represented as Squares
	var display_id = ""
	if color == "white":
		display_id = "S%03d_1" % [subpiece_value]
	else:
		display_id = "s%03d_1" % [subpiece_value]
	
	var display_data = {
		"color": color,
		"shape": "S",
		"label": [subpiece_value]
	}
	
	# CRITICAL: Add to scene tree FIRST so _ready() is called
	add_child(display_piece)
	
	# Wait for the next frame to ensure initialization
	await get_tree().process_frame
	
	# NOW initialize it (after it's in the tree)
	display_piece.initialize(display_id, display_data)
	
	# Wait another frame for the initialization to complete
	await get_tree().process_frame
	
	# Remove from temporary parent (will be added to capture zone)
	remove_child(display_piece)
	
	return display_piece


# /=====================================================\
# |           END OF NEW/UPDATED CODE SECTION           |
# \=====================================================/


func attempt_move(from_tile: ColorRect, to_tile: ColorRect):
	"""Attempt to move piece to empty square."""
	var from_coords = get_tile_coords(from_tile)
	var to_coords = get_tile_coords(to_tile)
	
	if to_tile.get_child_count() > 0:
		print("Cannot move to occupied square")
		return
	
	var valid_moves = move_validator.get_valid_moves(selected_piece, from_coords)
	if to_coords not in valid_moves:
		print("Invalid move")
		return
	
	execute_move(from_tile, to_tile)
	advance_to_post_capture_phase()

func execute_move(from_tile: ColorRect, to_tile: ColorRect):
	var from_coords = get_tile_coords(from_tile)
	var to_coords = get_tile_coords(to_tile)
	print("Moving piece from ", from_coords, " to ", to_coords)
	
	var piece = from_tile.get_child(0)
	log_move(piece, from_coords, to_coords)
	
	from_tile.remove_child(piece)
	to_tile.add_child(piece)
	piece.position = to_tile.size / 2.0
	update_board_state_array(from_tile, to_tile, false)
	print("Move complete!")

func move_to_capture_zone(piece: Node2D):
	var capture_container = captured_white_container if piece.piece_color == "white" else captured_black_container
	
	print("\n=== MOVING TO CAPTURE ZONE ===")
	print("Piece: ", piece.piece_id)
	print("Container children before: ", capture_container.get_child_count())
	
	# Create a Control wrapper for the GridContainer to layout
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(60, 60)  # Size for grid cell
	wrapper.clip_contents = false  # Allow piece to be visible
	
	# Scale and add the piece to the wrapper
	piece.scale = Vector2(0.4, 0.4)
	wrapper.add_child(piece)
	
	# Center the piece in the wrapper
	piece.position = wrapper.custom_minimum_size / 2.0
	
	# Add the wrapper to the GridContainer (NOT the piece directly!)
	capture_container.add_child(wrapper)
	
	print("Container children after: ", capture_container.get_child_count())
	print("Wrapper position: ", wrapper.position)
	print("Piece position in wrapper: ", piece.position)
	print("==============================\n")


# ========================================
# PART 1: Add these new functions to board.gd
# ========================================

# --- State Capture and Restoration ---

func capture_board_state() -> Dictionary:
	"""Captures current board state for undo."""
	var state = {
		"piece_positions": {},
		"pyramid_values": {},
		"initial_board_state": []
	}
	
	# Deep copy initial_board_state array
	for row in initial_board_state:
		state.initial_board_state.append(row.duplicate())
	
	# Capture all pieces on board
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile and tile.get_child_count() > 0:
				var piece = tile.get_child(0)
				var pos_key = "%d,%d" % [x, y]
				state.piece_positions[pos_key] = {
					"id": piece.piece_id,
					"color": piece.piece_color,
					"shape": piece.piece_shape,
					"label": piece.piece_label.duplicate()
				}
				
				# Track pyramid values separately for easy restoration
				if piece.piece_shape == "P":
					state.pyramid_values[piece.piece_id] = piece.piece_label.duplicate()
	
	return state

func restore_board_state(state: Dictionary):
	"""Restores board to a previous state."""
	print("\n=== RESTORING BOARD STATE ===")
	
	# Clear current board
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile:
				# Remove all pieces from tiles
				for child in tile.get_children():
					tile.remove_child(child)
					child.queue_free()
	
	# Clear capture zones
	for child in captured_white_container.get_children():
		captured_white_container.remove_child(child)
		child.queue_free()
	for child in captured_black_container.get_children():
		captured_black_container.remove_child(child)
		child.queue_free()
	
	# Restore initial_board_state array
	initial_board_state.clear()
	for row in state.initial_board_state:
		initial_board_state.append(row.duplicate())
	
	# Restore pieces from state
	for pos_key in state.piece_positions:
		var coords = pos_key.split(",")
		var x = int(coords[0])
		var y = int(coords[1])
		var piece_data = state.piece_positions[pos_key]
		
		var tile = get_tile_at_coords(x, y)
		if tile:
			tile.place_piece(piece_scene, piece_data.id, {
				"color": piece_data.color,
				"shape": piece_data.shape,
				"label": piece_data.label.duplicate()
			})
	
	print("=== BOARD STATE RESTORED ===\n")

# --- Undo Functionality ---

func undo_last_turn():
	"""Undo the entire most recent turn."""
	if game_log.size() == 0:
		print("Nothing to undo - no turns have been played yet!")
		# Optional: Show message to user
		if action_label:
			var old_text = action_label.text
			action_label.text = "Nothing to undo!"
			await get_tree().create_timer(1.5).timeout
			action_label.text = old_text
		return
	
	print("\n=== UNDOING LAST TURN ===")
	var last_turn = game_log.pop_back()
	print("Undoing turn %d by %s" % [last_turn.turn_number, last_turn.player])
	
	# Restore board state
	restore_board_state(last_turn.board_state_snapshot)
	
	# Restore captured pieces
	captured_white_piece_values = last_turn.captured_white_before.duplicate()
	captured_black_piece_values = last_turn.captured_black_before.duplicate()
	
	# Restore turn/phase
	current_player = last_turn.player
	current_phase = last_turn.phase
	
	# Update all displays
	update_captured_display("white", captured_white_piece_values)
	update_captured_display("black", captured_black_piece_values)
	sync_pyramid_values_to_panel()
	update_phase_display()
	
	# Clear any selection
	deselect_piece()
	
	# Re-enable phase button if it was disabled (from game over)
	if phase_button:
		phase_button.disabled = false
		update_phase_button_text()
	
	print("=== UNDO COMPLETE ===\n")

# --- Export Functionality ---

func create_export_button():
	"""Creates a button to export game log to text file."""
	var export_button = Button.new()
	export_button.text = "Export Game Log"
	export_button.custom_minimum_size = Vector2(200, 50)
	export_button.position = Vector2(650, 20)
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.7, 0.2)
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color.WHITE
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	export_button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.3, 0.8, 0.3)
	style_hover.border_width_left = 2
	style_hover.border_width_right = 2
	style_hover.border_width_top = 2
	style_hover.border_width_bottom = 2
	style_hover.border_color = Color.WHITE
	style_hover.corner_radius_top_left = 5
	style_hover.corner_radius_top_right = 5
	style_hover.corner_radius_bottom_left = 5
	style_hover.corner_radius_bottom_right = 5
	export_button.add_theme_stylebox_override("hover", style_hover)
	
	$CanvasLayer.add_child(export_button)
	export_button.pressed.connect(_on_export_pressed)

var log_already_exported: bool = false  # Add this variable at the top

func _on_export_pressed():
	"""
	Export game log to file.
	"""
	# Skip export on web builds
	if OS.has_feature("web"):
		print("Game log export not available in web version")
		if action_label:
			action_label.text = "Log export unavailable on web"
			await get_tree().create_timer(2.0).timeout
		return
		
	if game_log.size() == 0:
		print("No game log to export - no turns have been played yet!")
		return
	
	# Prevent double export
	if log_already_exported:
		print("Log already exported, skipping...")
		return
	
	log_already_exported = true
	
	var log_text = export_game_log_to_text()
	
	# Create filename with timestamp
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]
	var filename = "rithmomachia_game_%s.txt" % timestamp
	
	# Ensure game_logs directory exists in PROJECT folder
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("game_logs"):
		dir.make_dir("game_logs")
	
	# Save to PROJECT's game_logs subdirectory
	var file = FileAccess.open("res://game_logs/%s" % filename, FileAccess.WRITE)
	if file:
		file.store_string(log_text)
		file.flush()  # IMPORTANT: Force write to disk
		file.close()
		
		# Wait a moment to ensure write completes
		await get_tree().process_frame
		
		print("Game log exported successfully!")
		print("Location: ", ProjectSettings.globalize_path("res://game_logs/%s" % filename))
		
		# Show feedback to user
		if action_label:
			var old_text = action_label.text
			action_label.text = "Game log exported!"
			await get_tree().create_timer(2.0).timeout
			action_label.text = old_text
	else:
		print("ERROR: Failed to save file!")
		if action_label:
			var old_text = action_label.text
			action_label.text = "Export failed!"
			await get_tree().create_timer(2.0).timeout
			action_label.text = old_text

func create_undo_button():
	"""Creates a button to undo the last turn."""
	var undo_button = Button.new()
	undo_button.text = "Undo Last Turn"
	undo_button.custom_minimum_size = Vector2(200, 50)
	undo_button.position = Vector2(900, 20)
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.8, 0.4, 0.2)
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color.WHITE
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	undo_button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.9, 0.5, 0.3)
	style_hover.border_width_left = 2
	style_hover.border_width_right = 2
	style_hover.border_width_top = 2
	style_hover.border_width_bottom = 2
	style_hover.border_color = Color.WHITE
	style_hover.corner_radius_top_left = 5
	style_hover.corner_radius_top_right = 5
	style_hover.corner_radius_bottom_left = 5
	style_hover.corner_radius_bottom_right = 5
	undo_button.add_theme_stylebox_override("hover", style_hover)
	
	var style_disabled = StyleBoxFlat.new()
	style_disabled.bg_color = Color(0.5, 0.5, 0.5)
	style_disabled.border_width_left = 2
	style_disabled.border_width_right = 2
	style_disabled.border_width_top = 2
	style_disabled.border_width_bottom = 2
	style_disabled.border_color = Color(0.3, 0.3, 0.3)
	style_disabled.corner_radius_top_left = 5
	style_disabled.corner_radius_top_right = 5
	style_disabled.corner_radius_bottom_left = 5
	style_disabled.corner_radius_bottom_right = 5
	undo_button.add_theme_stylebox_override("disabled", style_disabled)
	
	$CanvasLayer.add_child(undo_button)
	undo_button.pressed.connect(_on_undo_pressed)

func _on_undo_pressed():
	"""Handle undo button press."""
	undo_last_turn()

# ========================================
# PART 2: Modify start_new_turn_log() in board.gd
# ========================================

# REPLACE the existing start_new_turn_log() function with this:

func start_new_turn_log():
	"""Initialize log entry for new turn with full state snapshot."""
	current_turn_log = {
		"turn_number": game_log.size() + 1,
		"player": current_player,
		"phase": current_phase,
		"pre_move_captures": [],
		"move": null,
		"post_move_captures": [],
		# NEW: Capture state for undo
		"board_state_snapshot": capture_board_state(),
		"captured_white_before": captured_white_piece_values.duplicate(),
		"captured_black_before": captured_black_piece_values.duplicate()
	}



# --- Helper Functions ---
func get_tile_coords(tile: ColorRect) -> Vector2i:
	var index = tile.get_index()
	return Vector2i(index % 16, index / 16)

func get_tile_at_coords(x: int, y: int) -> ColorRect:
	if x < 0 or x >= 16 or y < 0 or y >= 8:
		return null
	return grid_container.get_child(y * 16 + x)

func update_board_state_array(from_tile: ColorRect, to_tile: ColorRect, was_capture: bool):
	var from_coords = get_tile_coords(from_tile)
	var to_coords = get_tile_coords(to_tile)
	var piece_id = initial_board_state[from_coords.y][from_coords.x]
	initial_board_state[to_coords.y][to_coords.x] = piece_id
	initial_board_state[from_coords.y][from_coords.x] = ""

# --- Game State Management ---
func sync_pyramid_values_to_panel():
	for y in range(initial_board_state.size()):
		for x in range(initial_board_state[y].size()):
			var piece_id = initial_board_state[y][x]
			if piece_id == "":
				continue
			var first_char = piece_id[0]
			if first_char.to_upper() == "P":
				var tile_index = y * 16 + x
				var tile = grid_container.get_child(tile_index)
				if tile.get_child_count() > 0:
					var piece = tile.get_child(0)
					var color = "white" if first_char == first_char.to_upper() else "black"
					update_pyramid_display(color, piece.piece_label)

func on_piece_captured(piece_color: String, piece_value: int):
	print("!!! CAPTURE: ", piece_color, " piece with value ", piece_value, " captured!")
	
	if not game_ended:
		# If a WHITE piece was captured, BLACK did the capturing
		if piece_color == "white":
			black_pieces_captured += 1
			black_value_captured += piece_value  # Changed from piece.value
			print("Black total: %d pieces, %d value" % [black_pieces_captured, black_value_captured])
			
			if check_victory_by_body("Black", black_pieces_captured):
				declare_victory("Black", "Body")
			elif check_victory_by_goods("Black", black_value_captured):
				declare_victory("Black", "Goods")
		
		# If a BLACK piece was captured, WHITE did the capturing
		elif piece_color == "black":
			white_pieces_captured += 1
			white_value_captured += piece_value  # Changed from piece.value
			print("White total: %d pieces, %d value" % [white_pieces_captured, white_value_captured])
			
			if check_victory_by_body("White", white_pieces_captured):
				declare_victory("White", "Body")
			elif check_victory_by_goods("White", white_value_captured):
				declare_victory("White", "Goods")
	
	# Add to the appropriate captured list
	if piece_color == "white":
		captured_white_piece_values.append(piece_value)
		update_captured_display("white", captured_white_piece_values)
	else:
		captured_black_piece_values.append(piece_value)
		update_captured_display("black", captured_black_piece_values)

# ============================================
# SECTION 3: New function to create UI overlay
# ============================================

func setup_ui_overlay():
	"""Create and add UI elements as overlays to the game"""
	
	# Create a CanvasLayer for UI (renders on top of everything)
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 100  # High layer number = renders on top
	add_child(ui_layer)
	
	# === CREATE HELP BUTTON ===
	help_button = Button.new()
	help_button.name = "HelpButton"
	help_button.text = "?"
	help_button.custom_minimum_size = Vector2(50, 50)
	
	# Position in top-right corner
	help_button.anchor_left = 1.0
	help_button.anchor_top = 0.0
	help_button.anchor_right = 1.0
	help_button.anchor_bottom = 0.0
	help_button.offset_left = -70
	help_button.offset_top = 20
	help_button.offset_right = -20
	help_button.offset_bottom = 70
	
	# Style the button
	style_help_button(help_button)
	
	# Connect the button
	help_button.pressed.connect(_on_help_button_pressed)
	
	# === CREATE SEPARATE LAYER FOR HELP (HIGHER THAN SETUP WINDOW) ===
	var help_layer = CanvasLayer.new()
	help_layer.name = "HelpLayer"
	help_layer.layer = 110  # HIGHER than UILayer, so it renders on top!
	add_child(help_layer)
	
	# Add help button and window to the HIGHER layer
	help_layer.add_child(help_button)
	
	# === CREATE HELP WINDOW ===
	help_window = create_help_window()
	help_window.hide()  # Start hidden
	
	help_layer.add_child(help_window)  # Add to higher layer!
	
	# Optional: Make button pulse on first turn
	pulse_help_button()
	
	# Create Victory Conditions label for center panel
	create_victory_label()

func create_victory_label():
	"""Add a victory conditions label to the center panel"""
	var center_vbox = $CanvasLayer/CenterPanel/MarginContainer/VBoxContainer
	
	if center_vbox:
		# REMOVE any existing VictoryLabel duplicates
		for child in center_vbox.get_children():
			if child.name == "VictoryLabel":
				print("Removing duplicate VictoryLabel")
				child.queue_free()
		
		# Wait a frame for removal to complete
		await get_tree().process_frame
		
		# Create new label for victory conditions
		var victory_label = Label.new()
		victory_label.name = "VictoryLabel"
		victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		victory_label.add_theme_font_size_override("font_size", 14)
		victory_label.add_theme_color_override("font_color", Color(0.831, 0.686, 0.216))
		victory_label.text = ""  # Start empty, will be filled by update_status_display()
		victory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		center_vbox.add_child(victory_label)
		center_vbox.move_child(victory_label, 0)
		
		status_label = victory_label
		print("Victory label created at: ", victory_label.get_path())
		
# ============================================
# SECTION 4: Helper functions for UI creation
# ============================================

func style_help_button(button: Button):
	"""Apply custom styling to the help button"""
	# Create a custom style
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.545, 0.451, 0.333)  # Brown
	style_normal.border_color = Color(0.831, 0.686, 0.216)  # Gold
	style_normal.border_width_left = 3
	style_normal.border_width_top = 3
	style_normal.border_width_right = 3
	style_normal.border_width_bottom = 3
	style_normal.corner_radius_top_left = 25
	style_normal.corner_radius_top_right = 25
	style_normal.corner_radius_bottom_left = 25
	style_normal.corner_radius_bottom_right = 25
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.645, 0.551, 0.433)  # Lighter brown
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.445, 0.351, 0.233)  # Darker brown
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	
	# Font styling
	button.add_theme_font_size_override("font_size", 28)
	button.add_theme_color_override("font_color", Color.WHITE)

func create_help_window() -> Panel:
	"""Create the help window programmatically"""
	
	# Main panel
	var panel = Panel.new()
	panel.name = "HelpWindow"
	panel.custom_minimum_size = Vector2(700, 550)
	
	# Center it on screen
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -350  # Half of width
	panel.offset_top = -275   # Half of height
	panel.offset_right = 350
	panel.offset_bottom = 275
	
	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.165, 0.137, 0.118, 0.98)  # Dark brown, almost opaque
	panel_style.border_color = Color(0.545, 0.451, 0.333)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add margin container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)
	
	# VBox for layout
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Top bar with title and close button
	var top_bar = HBoxContainer.new()
	vbox.add_child(top_bar)
	
	var title = Label.new()
	title.text = "Rithmomachia Help and Historical Facts"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.831, 0.686, 0.216))  # Gold
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "×"
	close_btn.custom_minimum_size = Vector2(32, 32)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.pressed.connect(_on_help_close_pressed)
	top_bar.add_child(close_btn)
	
	# Tab container
	var tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # NEW
	tab_container.custom_minimum_size = Vector2(700, 400)  # NEW
	vbox.add_child(tab_container)
	
	# Create tabs with content
	create_help_tab(tab_container, "Moves", get_move_rules_text())
	create_help_tab(tab_container, "Captures", get_capture_rules_text())
	create_help_tab(tab_container, "Victory", get_victory_rules_text())
	create_help_tab(tab_container, "Other", get_other_rules_text())
	
	return panel

func create_help_tab(tab_container: TabContainer, tab_name: String, content: String):
	"""Helper to create a single help tab"""
	var margin = MarginContainer.new()
	margin.name = tab_name
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)
	
	var rich_text = RichTextLabel.new()
	rich_text.bbcode_enabled = true
	rich_text.text = content
	rich_text.fit_content = true
	rich_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rich_text.add_theme_color_override("default_color", Color(0.878, 0.878, 0.878))  # Light gray
	scroll.add_child(rich_text)
	
	tab_container.add_child(margin)

# ============================================
# SECTION 5: Button callbacks
# ============================================

func _on_help_button_pressed():
	"""Toggle help window visibility"""
	help_window.visible = !help_window.visible
	
	# Optional: pause game when help is open
	if help_window.visible:
		# get_tree().paused = true  # Uncomment if you want to pause
		pass

func _on_help_close_pressed():
	"""Close the help window"""
	help_window.hide()
	# get_tree().paused = false  # Uncomment if you paused

func pulse_help_button():
	"""Make the help button pulse to draw attention"""
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(help_button, "modulate:a", 0.5, 0.6)
	tween.tween_property(help_button, "modulate:a", 1.0, 0.6)

# ============================================
# SECTION 6: Content text functions
# (You can edit these easily later!)
# ============================================

func get_move_rules_text() -> String:
	return """[center][b]PIECE MOVEMENT RULES[/b][/center]

[b]CIRCLES (Rounds)[/b]
Values: 2, 4, 6, 8, 4 (again), 16, 36, 64 (white)/3, 5, 7, 9, 9 (again), 25, 49, 81 (black)
Movement: ONE square in any orthogonal direction (up, down, left, right) to an empty position.
No diagonal movement.

[b]TRIANGLES[/b]
Values: 6, 9, 20, 25, 42, 49, 72, 81 (white)/12, 16, 30, 36, 56, 64, 90, 100 (black)
Movement: TWO squares orthogonally.
No jumping. No diagonal movement.

[b]SQUARES[/b]
Values: 15, 25, 45, 81, 91, 153, 169, 289, subpieces: 1, 4, 9, 16, 25, 36 (white)/28, 49, 66, 120, 121, 190, 225, 361, subpieces: 16, 25, 36, 49, 64 (black) 
Movement: THREE squares orthogonally.
No jumping. No diagonal movement.

[b]PYRAMIDS[/b]
A pyramid is a stack of squares (subpieces)
Movement: Moves like a square.
Value: SUM of all subpieces in the pyramid -- initially they are: 1, 4, 9, 16, 25, 36 (white)/16, 25, 36, 49, 64 (black)
Can be captured as a unit or as a subpiece. Can capture as a unit or as a subpiece.
"""

func get_capture_rules_text() -> String:
	return """[center][b]CAPTURE METHODS[/b][/center]

You can capture an opponent's piece using mathematical relationships:

[b]1. EQUALITY (Number)[/b]
Capture a piece with the SAME value, if exactly one move separates each attacking piece from the target piece.
Example: Your 6 can capture their 6

[b]2. ADDITION (Sum)[/b]
Capture a piece whose value equals the SUM of 2 of your pieces, provided each attacking piece can legally land on the target piece in one move.
Example: If they are 1 coordinate away, C8 and C4 can work together to capture t12.
Note: No attacking piece has to move to the now empty coordinate after the capture (unlike chess).

[b]3. SUBTRACTION (Difference)[/b]
Capture a piece whose value equals the DIFFERENCE of 2 of your pieces, provided each capturing piece can legally land on the target piece.
Example: Your 3 and 7 can work together to capture their 4.
Note: All attacking pieces must be able to reach the target square,
but need not move to that square after the capture.

[b]4. MULTIPLICATION (Product)[/b]
Capture a piece whose value equals the PRODUCT of the "distance" with the value of your piece.
Example: If there are 3 empty spaces between C4 and t12 then C4 can capture t12.
Note: The "distance" between two pieces (when it exists) is defined to be the number of empty spaces in a horizontal or vertical line between them. 

[b]5. DIVISION (Divisor)[/b]
Capture a piece whose value equals the DIVISOR of the value of your piece by the "distance". 
Example: If there are 3 empty spaces between C4 and t12 then C4 can capture t12.
Note: The "distance" between two pieces is the number of empty spaces between them.

[b]5. SIEGE (Surround)[/b]
Capture a piece if your pieces SURROUND that target piece in such a way that the target piece has no legal moves.
Example: Any enemy piece surrounded by 4 friendly circles can be captured.
Note: If the target piece is against the edge of the board, you only need to surround it by 3 friendly pieces.

[b]IMPORTANT:[/b]
* Players alternate turns, starting with White.
* A turn consists of 3 parts: pre-move captures (optional), a move of exactly one of your pieces (mandatory), post-move captures (optional). If you cannot move you lose immediately.
* If possible, more that one enemy piece can be captured in the same turn.
* Captured pieces are removed from the board immediately until the game is over.
"""

func get_victory_rules_text() -> String:
	return """[center][b]VICTORY CONDITIONS[/b][/center]

There are FOUR ways to win Rithmomachia:

[b]1. COMMON VICTORY BY BODY (De Corpore)[/b]
Capture a specific NUMBER of opponent pieces.
Default: N0 = 10 pieces
First player to capture 10 enemy pieces wins!

[b]2. COMMON VICTORY BY GOODS (De Bonis)[/b]
Capture pieces with a total VALUE exceeding a threshold.
Default: N1 = 400 points
Add up the values of all captured pieces - first to 400+ wins!

[b]3. PROPER VICTORY (De Lite)[/b]
Arrange THREE of your pieces in the opponent's home area forming:
* Arithmetic progression (e.g., 3, 5, 7 -- of the form a, a+b, a+2b, for some integers a, b)
* Geometric progression (e.g., 2, 4, 8 -- of the form a, a*b, a*b^2)
* Harmonic progression (e.g., 9, 15, 45 -- of the form 1/(a+2b), 1/(a+b), 1/a)
This is like an elegant checkmate in chess - a nice mathematical pattern.

[b]4. GREAT VICTORY (De Honore)[/b]
Like Proper Victory, but form FOUR pieces in progression.
The most prestigious way to win!

[b]NOTE:[/b] Players should agree on N0 and N1 before the game, so they know which common victory conditions are active.
"""

func get_other_rules_text() -> String:
	return """[center][b]OTHER RULES & FACTS[/b][/center]

[b]TURN STRUCTURE[/b]
* Players alternate turns, starting with White.
* A turn consists of 3 parts:
  (a) pre-move captures (optional),
  (b) a move of exactly one of your pieces (mandatory),
  (c) post-move captures (optional).
  If you cannot move you lose immediately.

[b]PYRAMID RULES[/b]
* Pyramids must move with all their subpieces.
* No subpiece can move independently of the pyramid.
* Each subpiece can capture or be captured just like any other piece.
* When a subpiece of the pyramid is captured then the total value of the pyramid is deducted accordingly.

[b]SPECIAL MOVES[/b]
* No "passing" - you must move if it is your turn.
* Pieces cannot move on or through other pieces.
* Pieces cannot move diagonally or jump.

[b]HISTORICAL NOTE[/b]
Rithmomachia (Battle of Numbers) was played in medieval Europe as an educational tool for mathematics. Invented around 1050 by two German monks, it was popular among scholars and nobility from the 11th-15th centuries.

[b]STRATEGY TIPS[/b]
* Low-value circles are versatile but weak
* Squares are useful for tactics requiring speed.
* Pyramids are valuable - protect them!
* Plan multi-piece captures in advance
* Control the flow of enemy pieces into your territory.

[b]NUMBER VALUES[/b]
Each piece's number represents its value. The values and how they are placed follows mathematical patterns.
* Circles: x, x^2 (x = 2, 4, 6, 8 for white/3, 5, 7, 9 for black)
* Triangles: x+x^2, (x+1)^2 (x = 2, 4, 6, 8 for white/3, 5, 7, 9 for black)
* Squares: (x+1)(2x+1), (2x+1)^2 (x = 2, 4, 6, 8 for white/3, 5, 7, 9 for black)
"""

# ============================================
# SECTION 7: Optional - Show help on first launch
# ============================================

func show_help_on_first_launch():
	"""Call this from _ready() if you want to show help automatically"""
	# Check if this is first time (you'd need to save this preference)
	# For now, just show it
	help_window.show()

# ============================================
# SECTION 3: Create the Game Setup Window
# ============================================

func create_game_setup_window():
	"""Create the game setup window for victory condition selection"""
	
	# Main panel
	var panel = Panel.new()
	panel.name = "GameSetupWindow"
	panel.custom_minimum_size = Vector2(500, 350)
	
	# Center it on screen
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250  # Half of width
	panel.offset_top = -175   # Half of height
	panel.offset_right = 250
	panel.offset_bottom = 175
	
	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.15, 0.25, 0.98)  # Dark blue
	panel_style.border_color = Color(0.831, 0.686, 0.216)  # Gold border
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add to UI layer (assuming you have one from help system)
	var ui_layer = get_node("UILayer")
	if ui_layer:
		ui_layer.add_child(panel)
	else:
		add_child(panel)  # Fallback
	
	# Create content
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Game Setup - Victory Conditions"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.831, 0.686, 0.216))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Explanation text
	var info = RichTextLabel.new()
	info.bbcode_enabled = true
	info.fit_content = true
	info.custom_minimum_size = Vector2(0, 80)
	info.text = """[center]Choose your victory condition thresholds:

[b]Common Victory by Body (N0):[/b] Capture this many pieces
[b]Common Victory by Goods (N1):[/b] Capture pieces totaling this value[/center]"""
	info.add_theme_color_override("default_color", Color(0.878, 0.878, 0.878))
	vbox.add_child(info)
	
	# Difficulty buttons container
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	vbox.add_child(button_container)
	
	# Short difficulty button
	var short_btn = create_difficulty_button("Short", "N0 = 4\nN1 = 100")
	short_btn.pressed.connect(_on_difficulty_selected.bind("Short", 4, 100))
	button_container.add_child(short_btn)
	
	# Medium difficulty button (default)
	var medium_btn = create_difficulty_button("Medium", "N0 = 10\nN1 = 400")
	medium_btn.pressed.connect(_on_difficulty_selected.bind("Medium", 10, 400))
	button_container.add_child(medium_btn)
	
	# Long difficulty button
	var long_btn = create_difficulty_button("Long", "N0 = 20\nN1 = 1000")
	long_btn.pressed.connect(_on_difficulty_selected.bind("Long", 20, 1000))
	button_container.add_child(long_btn)
	
	# Bottom note
	var note = Label.new()
	note.text = "This window will close after both players' first turns"
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(note)
	
	setup_window = panel
	setup_window.hide()  # Start hidden, show in _ready()

func create_difficulty_button(difficulty: String, values: String) -> Button:
	"""Helper to create a styled difficulty selection button"""
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(120, 80)
	
	# Create label with difficulty and values
	var label_text = "[center][b]%s[/b]\n\n%s[/center]" % [difficulty, values]
	btn.text = difficulty + "\n" + values
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.345, 0.251, 0.133)
	style_normal.border_color = Color(0.545, 0.451, 0.333)
	style_normal.border_width_left = 2
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.corner_radius_top_left = 8
	style_normal.corner_radius_top_right = 8
	style_normal.corner_radius_bottom_left = 8
	style_normal.corner_radius_bottom_right = 8
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.445, 0.351, 0.233)
	style_hover.border_color = Color(0.831, 0.686, 0.216)  # Gold on hover
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.245, 0.151, 0.033)
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	
	return btn

# ============================================
# SECTION 4: Button handlers and logic
# ============================================

func _on_difficulty_selected(difficulty: String, n0: int, n1: int):
	"""Handle difficulty selection"""
	victory_n0 = n0
	victory_n1 = n1
	setup_difficulty = difficulty
	
	print("Game setup: %s difficulty selected (N0=%d, N1=%d)" % [difficulty, n0, n1])
	
	# Update status display
	update_status_display()
	
	# Close the setup window
	setup_window.hide()

func update_status_display():
	"""Update the center game status panel with victory conditions"""
	if status_label:
		var status_text = "Victory: %s (Body: %d pieces, Goods: %d points)" % [
			setup_difficulty, victory_n0, victory_n1
		]
		status_label.text = status_text
		print("Status label updated to: ", status_text)
	else:
		print("ERROR: status_label is null!")

# ============================================
# SECTION 5: Turn tracking (optional auto-close)
# ============================================

func on_turn_completed():
	"""Call this function whenever a turn is completed"""
	turns_completed += 1
	
	# After both players have moved once (2 turns), hide setup window
	if turns_completed >= 2 and setup_window.visible:
		setup_window.hide()
		print("Setup window auto-closed after first turn cycle")

# ============================================
# SECTION 6: Victory checking functions
# ============================================

func check_victory_by_body(player: String, captured_count: int) -> bool:
	"""Check if player has won by capturing enough pieces"""
	if captured_count >= victory_n0:
		print("%s wins by Common Victory by Body! (%d pieces captured)" % [player, captured_count])
		return true
	return false

func check_victory_by_goods(player: String, captured_value: int) -> bool:
	"""Check if player has won by capturing enough value"""
	if captured_value >= victory_n1:
		print("%s wins by Common Victory by Goods! (%d points captured)" % [player, captured_value])
		return true
	return false
	
func declare_victory(winner: String, victory_type: String):
	"""Handle game victory"""
	if game_ended:
		return
	
	# Store winner info for the game log
	game_winner = winner
	game_victory_type = victory_type
	
	var victory_message = ""
	if victory_type == "Body":
		var pieces_captured = black_pieces_captured if winner == "Black" else white_pieces_captured
		victory_message = "%s WINS by Common Victory by Body! (%d pieces captured, needed %d)" % [
			winner, pieces_captured, victory_n0
		]
	elif victory_type == "Goods":
		var value_captured = black_value_captured if winner == "Black" else white_value_captured
		victory_message = "%s WINS by Common Victory by Goods! (%d points captured, needed %d)" % [
			winner, value_captured, victory_n1
		]
	
	print("\n" + "=".repeat(60))
	print("🏆 VICTORY! 🏆")
	print(victory_message)
	print("=".repeat(60) + "\n")
	
	# Update status display
	if status_label:
		status_label.text = "🏆 " + victory_message
	
	# CRITICAL: Finalize the current turn so it gets logged!
	if current_turn_log.size() > 0:
		finalize_turn_log()
	
	# NOW set game_ended
	game_ended = true
	
	# Save game log
	print("Exporting game log from declare_victory...")
	await _on_export_pressed()
	
	# Add delay to ensure file operations complete
	await get_tree().create_timer(0.5).timeout
	
	print("Game log saved. Victory processing complete.")
	
# ============================================
# SECTION 7: Optional - Create/reference status label
# ============================================

func create_status_label():
	"""Create a status label for the center panel if you don't have one"""
	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.831, 0.686, 0.216))
	
	# Position it (adjust based on your board layout)
	status_label.position = Vector2(300, 10)  # Top center area
	status_label.custom_minimum_size = Vector2(400, 30)
	
	# Add to UI layer
	var ui_layer = get_node("UILayer")
	if ui_layer:
		ui_layer.add_child(status_label)
	
	return status_label

# Helper function
func make_container_pass_through(container: Control):
	"""
	Makes a container and its children pass mouse events through to the board
	"""
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Also make all children pass-through
	for child in container.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
