# board.gd - Complete with Turn Phase System, Button, and Game Logging
# for rithmo4
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
@onready var log_window = $CanvasLayer/LogWindowPanel

# Direct references to labels for easier access
@onready var turn_label = $CanvasLayer/CenterPanel/MarginContainer/VBoxContainer/TurnLabel
@onready var action_label = $CanvasLayer/CenterPanel/MarginContainer/VBoxContainer/ActionLabel
@onready var white_captured_label = $CanvasLayer/LeftPanel/MarginContainer/VBoxContainer/WhiteCapturedLabel
@onready var white_pyramid_label = $CanvasLayer/LeftPanel/MarginContainer/VBoxContainer/WhitePyramidLabel
@onready var black_captured_label = $CanvasLayer/RightPanel/MarginContainer/VBoxContainer/BlackCapturedLabel
@onready var black_pyramid_label = $CanvasLayer/RightPanel/MarginContainer/VBoxContainer/BlackPyramidLabel

@onready var white_score_label = null
@onready var black_score_label = null
@onready var victory_label = null  # Dedicated victory announcement label

# --- Scene and Style Variables ---
var tile_color = Color("#ADD8E6")

#  For computer vs computer with logging
var ai_vs_ai_mode: bool = false # NEW: Flag for AI vs. AI simulation
signal simulation_game_complete

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


# Valid 3-piece arithmetical progressions
const WHITE_ARITHMETICAL = [
	[2, 4, 6], [2, 9, 16], [4, 6, 8], [4, 20, 36], [8, 25, 42], 
	[8, 36, 64], [9, 45, 81], [9, 81, 153], [15, 20, 25], 
	[20, 42, 64], [49, 169, 289]
]

const BLACK_ARITHMETICAL = [
	[3, 5, 7], [5, 7, 9], [7, 16, 25], [7, 28, 49], [7, 64, 121], 
	[12, 56, 100], [12, 66, 120], [16, 36, 56], [28, 64, 100]
]

# Valid 3-piece geometric progressions
const WHITE_GEOMETRIC = [
	[2, 4, 8], [4, 6, 9], [4, 8, 16], [4, 16, 64], [9, 15, 25], 
	[16, 20, 25], [16, 36, 81], [25, 45, 81], [36, 42, 49], 
	[64, 72, 81], [81, 153, 289]
]

const BLACK_GEOMETRIC = [
	[9, 12, 16], [9, 30, 100], [16, 28, 49], [16, 36, 81], 
	[25, 30, 36], [36, 66, 121], [36, 90, 225], [49, 56, 64], 
	[64, 120, 225], [81, 90, 100]
]

# Valid 3-piece harmonic progressions
const WHITE_HARMONIC = [
	[9, 15, 45], [9, 16, 72]
]

const BLACK_HARMONIC = []  # Black has no harmonic patterns


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

var current_player: String = "white"
var demo_mode: bool = false  # NEW: Controls whether AI plays as Black
var move_made_this_turn: bool = false  # NEW: Track if move was made this turn
var ai_turn_in_progress: bool = false  # Prevents concurrent AI turns

# --- Turn Phase System ---
enum TurnPhase { PRE_MOVE_CAPTURE, MOVE, POST_MOVE_CAPTURE }
var current_phase: TurnPhase = TurnPhase.PRE_MOVE_CAPTURE

# --- UI Elements ---
var phase_button: Button = null

# --- Game Log System ---
var game_log: Array = []
var current_turn_log: Dictionary = {}
var log_already_exported: bool = false  # Add this variable at the top

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
var victory_checker = null

# UI References
var help_button: Button
var help_window: Panel
var hint_label: Label = null # --- NEW: Reference for the hint label ---
var demo_checkbox: CheckBox = null # <-- ADD THIS
var ai_vs_ai_checkbox: CheckBox = null # <-- ADD THIS

# Game Setup Window
var setup_window: Panel
var victory_n0: int = 10  # Default: Common Victory by Body
var victory_n1: int = 400  # Default: Common Victory by Goods
var setup_difficulty: String = "Medium"  # Track chosen difficulty
var turns_completed: int = 0  # Track turns to auto-close setup window

# Status panel reference (you may already have this)
var status_label: Label  # Reference to your center status panel

# Add score tracking variables
var white_score: float = 0.0
var black_score: float = 0.0

# ========================================
# Add button creation to _ready() in board.gd
# ========================================

func _ready():
	add_to_group("board")
	$MainLayout/BoardAndColumnLabels.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	
	var MoveValidator = load("res://move_validator.gd")
	move_validator = MoveValidator.new(self)
	
	var VictoryChecker = load("res://victory_checker.gd")
	victory_checker = VictoryChecker.new(self, victory_n0, victory_n1)
	
	generate_board()
	generate_labels()
	setup_pieces()
	setup_capture_containers()
	setup_ui_overlay()           # Set up UI overlays
	create_log_window_programmatically()  # Create the log window
	create_victory_label()        # Create the victory announcement label
	setup_score_labels()  # Add this line after setup_ui_overlay()
	
	# === FIX: Only make captured piece containers ignore mouse ===
	# These containers are positioned over the board and block input
	#if captured_white_container:
	#	make_container_pass_through(captured_white_container)
	#if captured_black_container:
	#	make_container_pass_through(captured_black_container)
	
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
	
	update_all_scores()

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

# --- NEW: Helper to convert coordinates to algebraic notation ---
func coordinate_to_algebraic_gd(col: int, row: int) -> String:
	"""
	Converts board coordinates (column, row) to algebraic notation (e.g., a1, p8).
	Godot uses x for column, y for row. Algebraic uses letter for column, number for row.

	Args:
		col (int): The column index (0-15).
		row (int): The row index (0-7).

	Returns:
		String: The algebraic notation (e.g., "a1", "p8").
	"""
	if col < 0 or col >= 16 or row < 0 or row >= 8:
		printerr("Invalid coordinates for algebraic conversion: (%d, %d)" % [col, row])
		return "??" # Return placeholder for invalid input

	# Map column index (0-15) to letter (a-p)
	var column_letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
	var letter = column_letters[col]

	# Map row index (0-7) to number (1-8)
	var number = str(row + 1)

	return letter + number
	
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
	"""Position captured piece containers on RIGHT side of screen"""
	
	if not captured_white_container or not captured_black_container:
		printerr("ERROR: Capture containers not found!")
		return
	
	# CRITICAL: Clear all anchors and use absolute positioning
	
	# WHITE - RIGHT SIDE, TOP HALF
	captured_white_container.columns = 3
	captured_white_container.custom_minimum_size = Vector2(190, 250)
	
	# Clear anchors (this is the critical fix!)
	captured_white_container.anchor_left = 0.0
	captured_white_container.anchor_top = 0.0
	captured_white_container.anchor_right = 0.0
	captured_white_container.anchor_bottom = 0.0
	
	# Clear offsets
	captured_white_container.offset_left = 0
	captured_white_container.offset_top = 0
	captured_white_container.offset_right = 0
	captured_white_container.offset_bottom = 0
	
	# Set absolute position
	captured_white_container.position = Vector2(1660, 100)
	captured_white_container.size = Vector2(190, 250)
	
	# Disable layout modes that might interfere
	captured_white_container.grow_horizontal = Control.GROW_DIRECTION_END
	captured_white_container.grow_vertical = Control.GROW_DIRECTION_END
	
	captured_white_container.z_index = 10
	captured_white_container.visible = true
	
	# --- START OF FIX 1 (WHITE) ---
	# Add visible background for debugging
	var white_bg = ColorRect.new()
	white_bg.color = Color(0.9, 0.9, 0.9, 0.1)
	white_bg.custom_minimum_size = Vector2(190, 250)
	white_bg.size = Vector2(190, 250) # Fixed size mismatch from 200 to 190
	white_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Add background to the CONTAINER'S PARENT
	captured_white_container.get_parent().add_child(white_bg)
	
	# Position it exactly where the container is
	white_bg.position = captured_white_container.position
	
	# Set its Z-index to be *behind* the container (10 - 1 = 9)
	white_bg.z_index = 9
	
	# Move it in the scene tree to be right before the container (for clean rendering)
	captured_white_container.get_parent().move_child(white_bg, captured_white_container.get_index())
	# --- END OF FIX 1 ---
	
	# BLACK - RIGHT SIDE, BOTTOM HALF
	captured_black_container.columns = 3
	captured_black_container.custom_minimum_size = Vector2(190, 250)
	
	# Clear anchors (this is the critical fix!)
	captured_black_container.anchor_left = 0.0
	captured_black_container.anchor_top = 0.0
	captured_black_container.anchor_right = 0.0
	captured_black_container.anchor_bottom = 0.0
	
	# Clear offsets
	captured_black_container.offset_left = 0
	captured_black_container.offset_top = 0
	captured_black_container.offset_right = 0
	captured_black_container.offset_bottom = 0
	
	# Set absolute position
	captured_black_container.position = Vector2(1660, 370)
	captured_black_container.size = Vector2(190, 250)
	
	# Disable layout modes that might interfere
	captured_black_container.grow_horizontal = Control.GROW_DIRECTION_END
	captured_black_container.grow_vertical = Control.GROW_DIRECTION_END
	
	captured_black_container.z_index = 10
	captured_black_container.visible = true
	
	# --- START OF FIX 2 (BLACK) ---
	# Add visible background for debugging
	var black_bg = ColorRect.new()
	black_bg.color = Color(0.1, 0.1, 0.1, 0.1)
	black_bg.custom_minimum_size = Vector2(190, 250)
	black_bg.size = Vector2(190, 250)
	black_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add background to the CONTAINER'S PARENT
	captured_black_container.get_parent().add_child(black_bg)
	
	# Position it exactly where the container is
	black_bg.position = captured_black_container.position
	
	# Set its Z-index to be *behind* the container (10 - 1 = 9)
	black_bg.z_index = 9
	
	# Move it in the scene tree to be right before the container
	captured_black_container.get_parent().move_child(black_bg, captured_black_container.get_index())
	# --- END OF FIX 2 ---
	
	print("Capture containers positioned: BOTH on RIGHT side (White=top, Black=bottom)")
	print("  White at: ", captured_white_container.position)
	print("  Black at: ", captured_black_container.position)

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
			# Show different text if no move made
			if not move_made_this_turn:
				phase_button.text = "Must Make a Move First"
				phase_button.disabled = true  # Disable button
			else:
				phase_button.text = "End Turn"
				phase_button.disabled = false

func _on_phase_button_pressed():
	"""Handle phase button press with complete safeguards."""
	
	# Guard 1: Don't allow interrupting AI turns
	if ai_turn_in_progress:
		print("BLOCKED: AI turn in progress, ignoring button press")
		return
	
	# Guard 2: During Human vs AI mode, only the human player can use the button
	if current_player == "black" and not demo_mode and not ai_vs_ai_mode:
		print("BLOCKED: Cannot manually control AI player")
		return
	
	match current_phase:
		TurnPhase.PRE_MOVE_CAPTURE:
			# Moving from pre-capture to move phase is OK without a capture
			advance_to_move_phase()
			
		TurnPhase.MOVE:
			# Should NOT be able to skip move phase!
			# This case shouldn't happen since moves auto-advance
			print("ERROR: Cannot skip MOVE phase - you must move a piece!")
			if action_label:
				action_label.text = "Error: You must move a piece!"
			return
			
		TurnPhase.POST_MOVE_CAPTURE:
			# CRITICAL CHECK: Ensure a move was actually made
			if not move_made_this_turn:
				print("ERROR: Cannot end turn - no move was made!")
				if action_label:
					action_label.text = "Action: Must make a move before ending turn!"
				return
			
			# Only advance if all checks passed
			advance_to_next_player()
		
		_:
			# Unknown phase - safety fallback
			print("ERROR: Unknown phase in button press handler: ", current_phase)


# ============================================
# SCORE CALCULATION SYSTEM
# ============================================

func calculate_position_score(color: String) -> Dictionary:
	"""
	Calculate positional score for a player.
	Formula: captures_count + (captures_value / 50) + invader_pairs
	
	Returns: {
		"total_score": float,
		"captures_component": int,
		"value_component": float,
		"invader_pairs_component": int
	}
	"""
	var captured_count = 0
	var captured_value = 0
	
	# Get capture stats
	if color == "white":
		captured_count = black_pieces_captured
		captured_value = black_value_captured
	else:
		captured_count = white_pieces_captured
		captured_value = white_value_captured
	
	# Get invader pairs (2 pieces from a fireteam, both in enemy territory)
	var invader_data = count_invader_pairs_for_color(color)
	var invader_pairs = invader_data.total
	
	# Calculate components
	var value_component = float(captured_value) / 50.0
	
	# Total score
	var total = float(captured_count) + value_component + float(invader_pairs)
	
	return {
		"total_score": total,
		"captures_component": captured_count,
		"value_component": value_component,
		"invader_pairs_component": invader_pairs  # Changed from fireteams_component
	}


func update_all_scores():
	"""
	Update scores for both players and refresh displays.
	Call this after captures, moves, or any board state change.
	"""
	var white_data = calculate_position_score("white")
	var black_data = calculate_position_score("black")
	
	white_score = white_data.total_score
	black_score = black_data.total_score
	
	# Update displays
	update_score_display("white", white_data)
	update_score_display("black", black_data)
	
	# Print to console for debugging
	print_score_summary(white_data, black_data)


func update_score_display(color: String, score_data: Dictionary):
	"""Update the score label for a specific color."""
	var label = white_score_label if color == "white" else black_score_label
	
	if label:
		# Determine if this player is winning
		var other_score = black_score if color == "white" else white_score
		var is_winning = score_data.total_score > other_score
		var is_tied = abs(score_data.total_score - other_score) < 0.1
		
		# Add visual indicator
		var indicator = ""
		if is_winning and not is_tied:
			indicator = " 📈"
		elif is_tied:
			indicator = " ⚖️"
		else:
			indicator = " 📉"
		
		var text = "%s Score: %.1f%s\n" % [color.capitalize(), score_data.total_score, indicator]
		text += "  Captures: %d pts\n" % score_data.captures_component
		text += "  Value: %.1f pts\n" % score_data.value_component
		text += "  Inv. Pairs: %d pts" % score_data.invader_pairs_component  # Changed label
		
		# Color the label based on advantage
		if is_winning:
			label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))  # Green
		elif is_tied:
			label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.5))  # Yellow
		else:
			label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.6))  # Light red
		
		label.text = text


func print_score_summary(white_data: Dictionary, black_data: Dictionary):
	"""Print score breakdown to console."""
	print("\n=== POSITION SCORES ===")
	print("White: %.1f (Captures: %d, Value: %.1f, Inv.Pairs: %d)" % [
		white_data.total_score,
		white_data.captures_component,
		white_data.value_component,
		white_data.invader_pairs_component
	])
	print("Black: %.1f (Captures: %d, Value: %.1f, Inv.Pairs: %d)" % [
		black_data.total_score,
		black_data.captures_component,
		black_data.value_component,
		black_data.invader_pairs_component
	])
	
	var advantage = white_data.total_score - black_data.total_score
	var leader = "White" if advantage > 0 else "Black"
	print("Advantage: %s leads by %.1f points" % [leader, abs(advantage)])
	print("======================\n")


# ============================================
# UI SETUP - Add score labels to panels
# ============================================

func setup_score_labels():
	"""Create and add score labels to the side panels."""
	
	# Add to LEFT panel (White)
	var left_vbox = $CanvasLayer/LeftPanel/MarginContainer/VBoxContainer
	if left_vbox:
		# Add separator
		var separator1 = HSeparator.new()
		separator1.add_theme_constant_override("separation", 10)
		left_vbox.add_child(separator1)
		
		# Add score label
		white_score_label = Label.new()
		white_score_label.name = "WhiteScoreLabel"
		white_score_label.add_theme_font_size_override("font_size", 14)
		white_score_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		white_score_label.text = "White Score: 0.0"
		left_vbox.add_child(white_score_label)
	
	# Add to RIGHT panel (Black)
	var right_vbox = $CanvasLayer/RightPanel/MarginContainer/VBoxContainer
	if right_vbox:
		# Add separator
		var separator2 = HSeparator.new()
		separator2.add_theme_constant_override("separation", 10)
		right_vbox.add_child(separator2)
		
		# Add score label
		black_score_label = Label.new()
		black_score_label.name = "BlackScoreLabel"
		black_score_label.add_theme_font_size_override("font_size", 14)
		black_score_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		black_score_label.text = "Black Score: 0.0"
		right_vbox.add_child(black_score_label)
	
	print("Score labels created successfully!")


# ============================================
# OPTIONAL: Add score advantage to center panel
# ============================================

func update_score_advantage_display():
	"""
	Optional: Show score advantage in the center panel.
	You can call this from update_all_scores() if desired.
	"""
	if status_label:
		var advantage = white_score - black_score
		var leader = "White" if advantage > 0 else "Black"
		var advantage_text = ""
		
		if abs(advantage) < 0.1:
			advantage_text = " (Scores tied)"
		else:
			advantage_text = " (%s leads by %.1f)" % [leader, abs(advantage)]
		
		# Append to existing status label
		var base_text = "Victory: %s (Body: %d pieces, Goods: %d points)" % [
			setup_difficulty, victory_n0, victory_n1
		]
		status_label.text = base_text + advantage_text


func update_turn_display():
	"""Updates the turn label."""
	if turn_label:
		turn_label.text = "Current Turn: %s" % current_player.capitalize()

func update_action_display():
	"""
		Updates the action/phase label in blue game status panel located to
		the left of the game board.
		"""
	if action_label:
		var phase_text = ""
		match current_phase:
			TurnPhase.PRE_MOVE_CAPTURE:
				phase_text = "pre-move capture"
			TurnPhase.MOVE:
				phase_text = "move"
			TurnPhase.POST_MOVE_CAPTURE:
				phase_text = "post-move capture"
		
		var base_text = "Action: %s" % phase_text
		
		# NEW: Add demo mode indicator
		if demo_mode:
			action_label.text = base_text + " [Demo Mode]"
		else:
			action_label.text = base_text

func update_captured_display(color: String, values: Array[int]):
	"""
		Updates the captured pieces display for the color of the captured piece.
		"""
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
	move_made_this_turn = false  # Reset for new turn
	start_new_turn_log()
	deselect_piece()
	update_phase_display()
	check_if_player_can_move()
	update_all_scores()
	
	# Check for progression victories at end of turn
	if not game_ended:
		check_all_victory_conditions("white")
		# --- FIX: Add this check ---
		# If White won, stop all further turn processing.
		if game_ended:
			return

		check_all_victory_conditions("black")
		# --- FIX: Add this check ---
		# If Black won, stop all further turn processing.
		if game_ended:
			return
	
	# NEW REPLACEMENT CODE
	# Check if the AI should take this turn
	var is_ai_turn = false
	if ai_vs_ai_mode:
		is_ai_turn = true # In simulation mode, AI always plays
	elif current_player == "black" and not demo_mode:
		is_ai_turn = true # Your original Human vs. AI logic

	if is_ai_turn and not game_ended:
		# We remove the 0.5s timer for simulation speed
		# Using call_deferred() prevents errors if this is called during _ready
		call_deferred("execute_ai_turn")

func execute_ai_turn():
	"""Execute a complete turn for Professor Pyramid (Black AI)."""
	
	# CRITICAL FIX: Prevent concurrent execution
	if ai_turn_in_progress:
		print("AI turn already in progress, skipping duplicate call")
		return
	
	if demo_mode:
		return # Still need to check for demo_mode
	
	if game_ended:
		print("Game already ended, skipping AI turn")
		return
	
	# Set the flag to prevent re-entry
	ai_turn_in_progress = true
	
	print("\n=== %s'S TURN (AI) ===" % current_player.to_upper())
	
	# Phase 1: Pre-move captures (MANDATORY if available)
	print("Phase 1: Checking for pre-move captures...")
	var available_captures = _get_all_captures_for_player_from_state(current_player, initial_board_state)
	
	if available_captures.size() > 0:
		print("Professor Pyramid found %d possible captures - executing them..." % available_captures.size())
		
		# Execute all available captures (in Rithmomachia, you can capture multiple pieces in pre-move phase)
		for capture_info in available_captures:
			# The structure from get_all_possible_captures_from_state is flat:
			# { "attacker_pos": Vector2i, "victim_pos"/"target_pos": Vector2i, "type": String, "value": int, "helper_pos": Vector2i or null }
			
			# Validate capture structure
			if not capture_info.has("attacker_pos"):
				continue
			if not (capture_info.has("victim_pos") or capture_info.has("target_pos")):
				continue
			if not capture_info.has("type") or not capture_info.has("value"):
				continue
			
			var attacker_pos = capture_info.attacker_pos
			var victim_pos = capture_info.get("victim_pos", capture_info.get("target_pos", null))
			
			if victim_pos == null:
				continue
			
			# Get the tiles
			var attacker_tile = get_tile_at_coords(attacker_pos.x, attacker_pos.y)
			var victim_tile = get_tile_at_coords(victim_pos.x, victim_pos.y)
			
			if attacker_tile and victim_tile and attacker_tile.get_child_count() > 0 and victim_tile.get_child_count() > 0:
				print("  AI capturing at position %s with piece at %s (type: %s)" % [victim_pos, attacker_pos, capture_info.type])
				attempt_capture(attacker_tile, victim_tile)
				await get_tree().create_timer(0.5).timeout  # Visual delay between captures
		
		print("Pre-move captures complete!")
	else:
		print("No pre-move captures available.")
	
	# Phase 2: Make the AI move
	print("Phase 2: Selecting best move...")
	current_phase = TurnPhase.MOVE
	update_phase_display()
	
	var best_move = select_best_move(current_player)
	
	if best_move == null:
		print("Professor Pyramid has no legal moves - game over!")
		ai_turn_in_progress = false  # Reset flag before returning
		show_game_over("White wins! Professor Pyramid has no legal moves.")
		return
	
	# Execute the move
	var start_pos = best_move[0]
	var end_pos = best_move[1]
	
	var from_tile = get_tile_at_coords(start_pos.x, start_pos.y)
	var to_tile = get_tile_at_coords(end_pos.x, end_pos.y)
	
	if from_tile and to_tile and from_tile.get_child_count() > 0:
		execute_move(from_tile, to_tile)
		print("Professor Pyramid moved from %s to %s" % [start_pos, end_pos])
	else:
		print("ERROR: AI move failed - invalid tiles")
		ai_turn_in_progress = false  # Reset flag before returning
		return
	
	# Phase 3: Post-move captures (MANDATORY if available)
	print("Phase 3: Checking for post-move captures...")
	current_phase = TurnPhase.POST_MOVE_CAPTURE
	update_phase_display()
	
	var post_captures = _get_all_captures_for_player_from_state(current_player, initial_board_state)
	
	if post_captures.size() > 0:
		print("Professor Pyramid found %d post-move captures - executing them..." % post_captures.size())
		
		# Execute all available post-move captures
		for capture_info in post_captures:
			# The structure from get_all_possible_captures_from_state is flat:
			# { "attacker_pos": Vector2i, "victim_pos"/"target_pos": Vector2i, "type": String, "value": int, "helper_pos": Vector2i or null }
			
			# Validate capture structure
			if not capture_info.has("attacker_pos"):
				continue
			if not (capture_info.has("victim_pos") or capture_info.has("target_pos")):
				continue
			if not capture_info.has("type") or not capture_info.has("value"):
				continue
			
			var attacker_pos = capture_info.attacker_pos
			var victim_pos = capture_info.get("victim_pos", capture_info.get("target_pos", null))
			
			if victim_pos == null:
				continue
			
			# Get the tiles
			var attacker_tile = get_tile_at_coords(attacker_pos.x, attacker_pos.y)
			var victim_tile = get_tile_at_coords(victim_pos.x, victim_pos.y)
			
			if attacker_tile and victim_tile and attacker_tile.get_child_count() > 0 and victim_tile.get_child_count() > 0:
				print("  AI post-move capturing at position %s with piece at %s (type: %s)" % [victim_pos, attacker_pos, capture_info.type])
				attempt_capture(attacker_tile, victim_tile)
				await get_tree().create_timer(0.5).timeout  # Visual delay between captures
		
		print("Post-move captures complete!")
	else:
		print("No post-move captures available.")
	
	# Small delay before advancing to White's turn
	await get_tree().create_timer(0.5).timeout
	
	# CRITICAL FIX: Reset flag before calling advance_to_next_player
	ai_turn_in_progress = false
	
	# Auto-advance to next player (White)
	await get_tree().create_timer(0.3).timeout
	advance_to_next_player()

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
	
	# Show in victory label if it exists
	if victory_label:
		victory_label.text = "🏆 " + message + " 🏆"
		victory_label.visible = true
	
	# Update action label to show game over
	if action_label:
		action_label.text = "🏆 GAME OVER 🏆"
	
	# Update turn label with the win message
	if turn_label:
		turn_label.text = message
	
	# Disable the phase button
	if phase_button:
		phase_button.text = message
		phase_button.disabled = true
	
	# Set game_ended flag
	game_ended = true
	simulation_game_complete.emit() 


# Add this new function to board.gd (for computer vs computer)
func set_victory_conditions(n0_pieces: int, n1_value: int, difficulty_name: String):
	victory_n0 = n0_pieces
	victory_n1 = n1_value
	setup_difficulty = difficulty_name
	
	# This is the most important part:
	# Re-create the victory_checker with the new values
	if is_instance_valid(victory_checker):
		victory_checker.queue_free() # Free the old one
	
	var VictoryChecker = load("res://victory_checker.gd")
	victory_checker = VictoryChecker.new(self, victory_n0, victory_n1)
	
	print("Simulation: Victory conditions set to N0=%d, N1=%d" % [victory_n0, victory_n1])


# --- Game Log System ---

func log_capture(attacker_piece: Node2D, attacker_pos: Vector2i, victim_piece: Node2D, 
				 victim_pos: Vector2i, capture_type: String, captured_value: int, 
				 is_subpiece: bool, helper_piece: Node2D = null):
	"""
	Record a capture in the current turn log.
	"""
	# === START: ADDED SAFETY CHECK (from board1.gd) ===
	# Ensures current_turn_log is properly initialized
	if not current_turn_log.has("pre_move_captures"):
		print("WARNING: current_turn_log not initialized, initializing now...")
		current_turn_log = {
			"turn_number": game_log.size() + 1,
			"player": current_player,
			"phase": current_phase,
			"pre_move_captures": [],
			"move": null,
			"post_move_captures": [],
			"board_state_snapshot": capture_board_state(),
			"captured_white_before": captured_white_piece_values.duplicate(),
			"captured_black_before": captured_black_piece_values.duplicate()
		}
	# === END: ADDED SAFETY CHECK ===
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
		current_turn_log["pre_move_captures"].append(capture_entry)
	else:
		current_turn_log["post_move_captures"].append(capture_entry)
	
	print_capture_to_console(capture_entry)

func log_move(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i):
	"""Record a move in the current turn log."""
	current_turn_log["move"] = {
		"piece": {
			"id": piece.piece_id,
			"value": piece.piece_label[0] if piece.piece_label.size() > 0 else 0,
			"color": piece.piece_color,
			"shape": piece.piece_shape
		},
		"from_pos": from_pos,
		"to_pos": to_pos
	}
	print_move_to_console(current_turn_log["move"])

func finalize_turn_log():
	"""
		Save current turn log and print summary. Tracks fireteam counts.
		"""
	game_log.append(current_turn_log.duplicate(true))
	print_turn_summary(current_turn_log)
	current_turn_log = {}
	
	# NEW: Update progression tracking
	update_progression_tracking()

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
	print("\n========== TURN %d SUMMARY (%s) ==========" % [turn_log["turn_number"], turn_log["player"].to_upper()])
	print("Pre-move captures: %d" % turn_log["pre_move_captures"].size())
	if turn_log["move"]:
		print("Move: %s from %s to %s" % [turn_log["move"]["piece"]["id"], turn_log["move"]["from_pos"], turn_log["move"]["to_pos"]])
	print("Post-move captures: %d" % turn_log["post_move_captures"].size())
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
		text += "Turn %d - %s\n" % [turn["turn_number"], turn["player"].capitalize()]
		text += "-".repeat(40) + "\n"
		
		if turn["pre_move_captures"].size() > 0:
			text += "Pre-move captures:\n"
			for cap in turn["pre_move_captures"]:
				text += format_capture_for_log(cap)
		
		if turn["move"]:
			var from_alg = coordinate_to_algebraic_gd(turn["move"]["from_pos"].x, turn["move"]["from_pos"].y)
			var to_alg = coordinate_to_algebraic_gd(turn["move"]["to_pos"].x, turn["move"]["to_pos"].y)
			text += "Move: %s from %s to %s\n" % [
					 turn["move"]["piece"]["id"],
					 from_alg,
					 to_alg
			]
		
		if turn["post_move_captures"].size() > 0:
			text += "Post-move captures:\n"
			for cap in turn["post_move_captures"]:
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
	var attacker_names = []
	for attacker in cap.capturing_pieces:
		attacker_names.append(attacker.id)
	
	var attackers_str = " + ".join(attacker_names)
	
	return "  - %s captured by %s (%s)\n" % [
		cap.captured_piece.id,
		attackers_str,
		cap.capture_type
	]

# --- Player Input Handling ---
func _on_tile_clicked(event: InputEvent, clicked_tile: ColorRect):
	# NEW: Ignore input during AI's turn (unless in demo mode)
	if current_player == "black" and not demo_mode:
		return  # AI is thinking, don't allow manual input
	
	if not event is InputEventMouseButton:
		return
	# end NEW
	
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

# --- Capture Logic (New and Improved) ---# 

# Add to board.gd

func get_all_capturable_enemy_pieces(attacking_color: String) -> Array:
	"""
	Returns all enemy pieces that can currently be captured.
	Game-winning captures are sorted first, then by value.
	Returns: Array of dictionaries with format:
	[{
		"piece": Node2D,
		"pos": Vector2i,
		"value": int,
		"is_winning_capture": bool,
		"win_type": String,  # "body", "goods", or ""
		"threatened_by": Array of attacking piece data
	}, ...]
	"""
	var capturable_pieces = {}  # Use dict to avoid duplicates
	var enemy_color = "black" if attacking_color == "white" else "white"
	
	# Get current capture stats for the attacking player
	var current_pieces_captured = 0
	var current_value_captured = 0
	
	if attacking_color == "white":
		current_pieces_captured = black_pieces_captured
		current_value_captured = black_value_captured
	else:
		current_pieces_captured = white_pieces_captured
		current_value_captured = white_value_captured
	
	# Check each of our pieces to see what they can capture
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			
			var attacker = tile.get_child(0)
			if attacker.piece_color != attacking_color:
				continue
			
			# Get all possible captures for this piece
			var attacker_pos = Vector2i(x, y)
			var captures = move_validator.get_all_possible_captures(attacker_pos, attacker)
			
			# Process each potential capture
			for capture_data in captures:
				var target_pos = capture_data.target_pos
				var target_tile = get_tile_at_coords(target_pos.x, target_pos.y)
				
				if target_tile == null or target_tile.get_child_count() == 0:
					continue
				
				var victim = target_tile.get_child(0)
				if victim.piece_color != enemy_color:
					continue
				
				# Validate capture_data structure
				if not capture_data.has("capture_types"):
					printerr("get_capturable_pieces: capture_data missing capture_types key")
					continue
				
				# Create unique key for this victim
				var pos_key = "%d,%d" % [target_pos.x, target_pos.y]
				
				# Get victim value
				var victim_value = 0
				var victim_piece_count = 1  # Default for non-pyramids
				
				if victim.piece_shape == "P":
					# For pyramids, sum all subpieces
					for sub_val in victim.piece_label:
						victim_value += sub_val
					# Pyramids count as multiple pieces (one per subpiece)
					victim_piece_count = victim.piece_label.size()
				else:
					victim_value = victim.piece_label[0] if victim.piece_label.size() > 0 else 0
				
				# Check if this capture would win the game
				var is_winning = false
				var win_type = ""
				
				# Check Victory by Goods (N1)
				if current_value_captured + victim_value >= victory_n1:
					is_winning = true
					win_type = "goods"
				
				# Check Victory by Body (N0)
				if current_pieces_captured + victim_piece_count >= victory_n0:
					is_winning = true
					# If both conditions met, prefer to report goods victory
					if win_type == "":
						win_type = "body"
				
				# Add or update entry
				if pos_key not in capturable_pieces:
					capturable_pieces[pos_key] = {
						"piece": victim,
						"pos": target_pos,
						"value": victim_value,
						"piece_count": victim_piece_count,
						"is_winning_capture": is_winning,
						"win_type": win_type,
						"threatened_by": []
					}
				
				# Add attacker info
				capturable_pieces[pos_key].threatened_by.append({
					"piece": attacker,
					"pos": attacker_pos,
					"capture_types": capture_data.capture_types
				})
	
	# Convert dict to array
	var result = []
	for key in capturable_pieces:
		result.append(capturable_pieces[key])
	
	# Sort by: 1) winning captures first, 2) then by value (highest first)
	result.sort_custom(func(a, b):
		# Winning captures always come first
		if a.is_winning_capture and not b.is_winning_capture:
			return true
		if not a.is_winning_capture and b.is_winning_capture:
			return false
		# If both winning or both not winning, sort by value
		return a.value > b.value
	)
	
	return result


func print_hanging_pieces_analysis():
	"""
		Debug function to print hanging pieces for both sides.
		"""
	print("\n=== HANGING PIECES ANALYSIS ===")
	
	for color in ["white", "black"]:
		var summary = get_hanging_pieces_summary(color)
		print("\n%s's perspective:" % color.capitalize())
		print("  My pieces at risk: %d (value: %d)" % [
			summary.my_hanging_count,
			summary.my_hanging_value
		])
		
		if summary.my_hanging_count > 0:
			print("  Threatened pieces:")
			for piece_data in summary.my_hanging_pieces:
				var warning = ""
				if piece_data.is_winning_capture:
					warning = " ⚠️ GAME-WINNING CAPTURE (%s)!" % piece_data.win_type.to_upper()
				print("    - %s at %s (value: %d) threatened by %d piece(s)%s" % [
					piece_data.piece.piece_id,
					piece_data.pos,
					piece_data.value,
					piece_data.threatened_by.size(),
					warning
				])
		
		print("  Enemy pieces I can capture: %d (value: %d)" % [
			summary.enemy_hanging_count,
			summary.enemy_hanging_value
		])
		
		if summary.enemy_hanging_count > 0:
			print("  Capturable enemy pieces:")
			for piece_data in summary.enemy_hanging_pieces:
				var winning_notice = ""
				if piece_data.is_winning_capture:
					winning_notice = " 🏆 WINS THE GAME! (%s)" % piece_data.win_type.to_upper()
				print("    - %s at %s (value: %d)%s" % [
					piece_data.piece.piece_id,
					piece_data.pos,
					piece_data.value,
					winning_notice
				])
		
		print("  Material advantage: %d" % summary.material_advantage)
	
	print("\n===============================\n")


func get_winning_captures(attacking_color: String) -> Array:
	"""
	Convenience function to get only captures that would win the game.
	Returns empty array if no winning captures available.
	"""
	var all_captures = get_all_capturable_enemy_pieces(attacking_color)
	return all_captures.filter(func(c): return c.is_winning_capture)


func has_winning_capture_available(attacking_color: String) -> bool:
	"""
	Quick check if the player has a game-winning capture available.
	"""
	var winning = get_winning_captures(attacking_color)
	return winning.size() > 0


func get_hanging_pieces_summary(color: String) -> Dictionary:
	"""
	Get a summary of all hanging pieces for both players.
	Useful for strategic analysis.

		This function could be useful in a "tutorial mode" playing against
		the computer: if the player wants a hint they could get that by adding this 
		code to the advance_to_next_player function:

		 # Or get specific info:
		 var summary = get_hanging_pieces_summary(current_player)
		 if summary.my_hanging_count > 0:
		 	print("WARNING: You have %d pieces at risk!" % summary.my_hanging_count)

	"""
	var my_color = color
	var enemy_color = "black" if color == "white" else "white"
	
	var my_hanging = get_all_capturable_enemy_pieces(enemy_color)  # Pieces I could lose
	var enemy_hanging = get_all_capturable_enemy_pieces(my_color)  # Pieces I could capture
	
	var my_hanging_value = 0
	for piece_data in my_hanging:
		my_hanging_value += piece_data.value
	
	var enemy_hanging_value = 0
	for piece_data in enemy_hanging:
		enemy_hanging_value += piece_data.value
	
	return {
		"my_hanging_pieces": my_hanging,
		"my_hanging_count": my_hanging.size(),
		"my_hanging_value": my_hanging_value,
		"enemy_hanging_pieces": enemy_hanging,
		"enemy_hanging_count": enemy_hanging.size(),
		"enemy_hanging_value": enemy_hanging_value,
		"material_advantage": enemy_hanging_value - my_hanging_value
	}
	

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

	if valid_capture_options == null:
		print("ERROR: Clicked on a valid target, but no capture option was found.")
		return
	
	if not valid_capture_options.has("capture_types") or valid_capture_options.capture_types.size() == 0:
		print("ERROR: Capture option found but no capture_types available.")
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

func _get_all_captures_for_player_from_state(player_color: String, board_state: Array) -> Array:
	"""
	Gets all possible captures for all pieces of a given color from a board state array.
	Returns: Array of capture info dictionaries
	"""
	var all_captures = []
	
	# Iterate through the board state to find all pieces of the player's color
	for y in range(board_state.size()):
		for x in range(board_state[y].size()):
			var piece_id = board_state[y][x]
			if piece_id != "":
				# Check if this piece belongs to the player
				var piece_color = "white" if piece_id[0] == piece_id[0].to_upper() else "black"
				if piece_color == player_color:
					# Get all captures for this piece using the move_validator function
					var piece_pos = Vector2i(x, y)
					var piece_captures = move_validator.get_all_possible_captures_from_state(piece_id, piece_pos, board_state)
					
					# Add each capture to the list
					for capture in piece_captures:
						all_captures.append(capture)
	
	return all_captures
	
	
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
	
	move_made_this_turn = true  # Track that move was made
	
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
	print("Undoing turn %d by %s" % [last_turn["turn_number"], last_turn["player"]])
	
	# Restore board state
	restore_board_state(last_turn["board_state_snapshot"])
	
	# Restore captured pieces
	captured_white_piece_values = last_turn["captured_white_before"].duplicate()
	captured_black_piece_values = last_turn["captured_black_before"].duplicate()
	
	# Restore turn/phase
	current_player = last_turn["player"]
	current_phase = last_turn["phase"]
	
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

func _on_export_pressed():
	"""
	Display game log in popup window AND auto-save on desktop.
	"""
	if game_log.size() == 0:
		print("No game log to export - no turns have been played yet!")
		if action_label:
			var old_text = action_label.text
			action_label.text = "No log to export!"
			await get_tree().create_timer(2.0).timeout
			action_label.text = old_text
		return
	
	# Generate the log text
	var log_text = export_game_log_to_text()
	
	# Check if the log window exists
	if log_window == null:
		printerr("Log window not found. Cannot display log.")
		return
	
	# Find the TextEdit node inside the log window
	var text_display = log_window.find_child("LogTextDisplay", true, false)
	
	if text_display and text_display is TextEdit:
		text_display.text = log_text
		log_window.show()
		print("Game log displayed in window")
	else:
		printerr("LogTextDisplay node (TextEdit) not found inside log_window.")
		return
	
	# DESKTOP ONLY: Also auto-save to file (keeping your original behavior)
	if not OS.has_feature("web"):
		# Prevent double export
		if log_already_exported:
			print("Log already exported, skipping auto-save...")
			return
		
		log_already_exported = true
		
		# Create filename with timestamp
		var datetime = Time.get_datetime_dict_from_system()
		var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [
			datetime.year, datetime.month, datetime.day,
			datetime.hour, datetime.minute, datetime.second
		]
		var filename = "rithmomachia_game_%s.txt" % timestamp
		
		# Ensure game_logs directory exists
		var dir = DirAccess.open("res://")
		if dir and not dir.dir_exists("game_logs"):
			dir.make_dir("game_logs")
		
		# Save to file
		var file = FileAccess.open("res://game_logs/%s" % filename, FileAccess.WRITE)
		if file:
			file.store_string(log_text)
			file.flush()
			file.close()
			
			await get_tree().process_frame
			
			print("Game log auto-saved to: ", ProjectSettings.globalize_path("res://game_logs/%s" % filename))
		else:
			print("ERROR: Failed to auto-save file!")

func create_undo_button():
	"""Creates a button to undo the last turn."""
	var undo_button = Button.new()
	undo_button.text = "Undo Last Turn"
	undo_button.custom_minimum_size = Vector2(200, 50)
	
	# Anchor to top-right corner so it stays on the right side regardless of window size
	undo_button.anchor_left = 1.0
	undo_button.anchor_right = 1.0
	undo_button.offset_left = -440.0  # 220px for capture window + 20px margin + 200px button width = 440px from right
	undo_button.offset_right = -240.0  # 240px from right edge (20px margin + 220px capture window)
	undo_button.offset_top = 20.0
	undo_button.offset_bottom = 70.0
	
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
			
			# Check ALL victory conditions for Black
			check_all_victory_conditions("black")
		
		# If a BLACK piece was captured, WHITE did the capturing
		elif piece_color == "black":
			white_pieces_captured += 1
			white_value_captured += piece_value  # Changed from piece.value
			print("White total: %d pieces, %d value" % [white_pieces_captured, white_value_captured])
			
			# Check ALL victory conditions for White
			check_all_victory_conditions("white")
	
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
		var temp_label = Label.new()
		temp_label.name = "VictoryLabel"
		temp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		temp_label.add_theme_font_size_override("font_size", 20)  # Increased for visibility
		temp_label.add_theme_color_override("font_color", Color.GOLD)  # Gold for prominence
		temp_label.text = ""  # Start empty, will be filled by update_status_display()
		temp_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		temp_label.visible = true  # Visible by default
		
		center_vbox.add_child(temp_label)
		center_vbox.move_child(temp_label, 0)
		
		# Assign to both class variables
		status_label = temp_label
		victory_label = temp_label  # Use same label for both purposes
		print("Victory label created at: ", temp_label.get_path())
		
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
	tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_container.custom_minimum_size = Vector2(700, 400)
	vbox.add_child(tab_container)

	# Create tabs with content
	create_help_tab(tab_container, "Moves", get_move_rules_text())
	create_help_tab(tab_container, "Captures", get_capture_rules_text())
	create_help_tab(tab_container, "Victory", get_victory_rules_text())
	# --- MODIFIED: Store the VBox returned by create_help_tab for "Other" ---
	var other_tab_vbox = create_help_tab(tab_container, "Other", get_other_rules_text())

	# --- NEW: Add Hint Button and Label to the "Other" tab's VBox ---
	# Add a separator
	other_tab_vbox.add_child(HSeparator.new())

	# --- NEW CODE (checkbox in separate row below) ---
	var hint_hbox = HBoxContainer.new()
	hint_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hint_hbox.add_theme_constant_override("separation", 15)
	other_tab_vbox.add_child(hint_hbox)

	var hint_button = Button.new()
	hint_button.text = "Get Hint"
	hint_button.custom_minimum_size = Vector2(120, 40)
	hint_button.pressed.connect(_on_hint_button_pressed)
	hint_hbox.add_child(hint_button)

	hint_label = Label.new()
	hint_label.text = "(Hint will appear here)"
	hint_label.custom_minimum_size = Vector2(400, 100)
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Add a background so it's visible
	var label_style = StyleBoxFlat.new()
	label_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # Dark semi-transparent background
	label_style.border_width_left = 1
	label_style.border_width_top = 1
	label_style.border_width_right = 1
	label_style.border_width_bottom = 1
	label_style.border_color = Color(0.5, 0.5, 0.5)
	hint_label.add_theme_stylebox_override("normal", label_style)

	hint_hbox.add_child(hint_label)
	hint_label.add_child(hint_label)

	# --- NEW: Demo Mode checkbox in its own row below ---
	var demo_hbox = HBoxContainer.new()
	demo_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	demo_hbox.add_theme_constant_override("separation", 10)
	other_tab_vbox.add_child(demo_hbox)

	# --- END NEW ---

	# Add Demo Mode checkbox
	demo_checkbox = CheckBox.new()
	demo_checkbox.text = "Demo Mode (Play Both Sides)"
	demo_checkbox.button_pressed = demo_mode
	demo_checkbox.toggled.connect(_on_demo_mode_toggled)
	demo_hbox.add_child(demo_checkbox)

	# --- ADD THIS NEW CHECKBOX ---
	ai_vs_ai_checkbox = CheckBox.new()
	ai_vs_ai_checkbox.text = "AI vs. AI (Watch Mode)"
	ai_vs_ai_checkbox.button_pressed = ai_vs_ai_mode
	ai_vs_ai_checkbox.toggled.connect(_on_ai_vs_ai_toggled)
	demo_hbox.add_child(ai_vs_ai_checkbox)
	# --- END OF NEW CODE ---

	return panel
	
# Add this function after create_help_window() (around line 2531)
func create_log_window() -> Panel:
	"""Create the game log window programmatically with scrollable text display"""
	
	# Main panel
	var panel = Panel.new()
	panel.name = "LogWindowPanel"
	panel.custom_minimum_size = Vector2(800, 600)
	
	# Center it on screen
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -400  # Half of width
	panel.offset_top = -300   # Half of height
	panel.offset_right = 400
	panel.offset_bottom = 300
	
	# Initially hidden
	panel.visible = false
	
	# Style the panel - match help window style
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
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	# Top bar with title and close button
	var top_bar = HBoxContainer.new()
	vbox.add_child(top_bar)
	
	var title = Label.new()
	title.text = "Game Log"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.831, 0.686, 0.216))  # Gold
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "×"
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.add_theme_font_size_override("font_size", 28)
	close_btn.pressed.connect(_on_log_window_close_pressed)
	top_bar.add_child(close_btn)
	
	# TextEdit for scrollable log display
	var text_edit = TextEdit.new()
	text_edit.name = "LogTextDisplay"
	text_edit.editable = false  # Read-only
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY  # Wrap long lines
	text_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.custom_minimum_size = Vector2(770, 450)
	
	# Style the TextEdit
	text_edit.add_theme_color_override("background_color", Color(0.1, 0.1, 0.1, 0.95))
	text_edit.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	text_edit.add_theme_font_size_override("font_size", 14)
	
	vbox.add_child(text_edit)
	
	# Bottom button bar
	var button_bar = HBoxContainer.new()
	button_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	button_bar.add_theme_constant_override("separation", 15)
	vbox.add_child(button_bar)
	
	# Copy to Clipboard button
	#var copy_btn = Button.new()
	#copy_btn.text = "Copy to Clipboard"
	#copy_btn.custom_minimum_size = Vector2(180, 40)
	#copy_btn.pressed.connect(_on_copy_log_to_clipboard)
	#style_log_button(copy_btn)
	#button_bar.add_child(copy_btn)
	
	# Save to File button (desktop only)
	if not OS.has_feature("web"):
		var save_btn = Button.new()
		save_btn.text = "Save to File"
		save_btn.custom_minimum_size = Vector2(180, 40)
		save_btn.pressed.connect(_on_save_log_to_file)
		style_log_button(save_btn)
		button_bar.add_child(save_btn)
	
	return panel


func style_log_button(button: Button):
	"""Apply consistent styling to log window buttons"""
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.545, 0.451, 0.333)  # Brown
	style_normal.border_color = Color(0.831, 0.686, 0.216)  # Gold
	style_normal.border_width_left = 2
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.645, 0.551, 0.433)  # Lighter brown
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.445, 0.351, 0.233)  # Darker brown
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_color_override("font_color", Color.WHITE)


# ============================================
# CALLBACK FUNCTIONS
# ============================================

func _on_log_window_close_pressed():
	"""Close the log window"""
	if log_window:
		log_window.hide()


func _on_copy_log_to_clipboard():
	"""Copy the game log to clipboard"""
	var text_display = log_window.find_child("LogTextDisplay")
	if text_display and text_display is TextEdit:
		DisplayServer.clipboard_set(text_display.text)
		print("Game log copied to clipboard!")
		
		# Show brief feedback
		if action_label:
			var old_text = action_label.text
			action_label.text = "Log copied to clipboard!"
			await get_tree().create_timer(1.5).timeout
			action_label.text = old_text


func _on_save_log_to_file():
	"""Save the game log to a file (desktop only)"""
	if OS.has_feature("web"):
		return  # Should never happen, but safety check
	
	# Create filename with timestamp
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]
	var filename = "rithmomachia_game_%s.txt" % timestamp
	
	# Ensure game_logs directory exists
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("game_logs"):
		dir.make_dir("game_logs")
	
	# Get the text from the display
	var text_display = log_window.find_child("LogTextDisplay")
	if not text_display or not text_display is TextEdit:
		print("ERROR: Cannot find log text to save!")
		return
	
	# Save to file
	var file = FileAccess.open("res://game_logs/%s" % filename, FileAccess.WRITE)
	if file:
		file.store_string(text_display.text)
		file.flush()
		file.close()
		
		print("Game log saved successfully!")
		print("Location: ", ProjectSettings.globalize_path("res://game_logs/%s" % filename))
		
		# Show feedback
		if action_label:
			var old_text = action_label.text
			action_label.text = "Log saved to file!"
			await get_tree().create_timer(1.5).timeout
			action_label.text = old_text
	else:
		print("ERROR: Failed to save file!")
		if action_label:
			var old_text = action_label.text
			action_label.text = "Save failed!"
			await get_tree().create_timer(1.5).timeout
			action_label.text = old_text


func create_help_tab(tab_container: TabContainer, tab_name: String, content: String) -> VBoxContainer: # --- MODIFIED: Return VBoxContainer ---
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

	# --- NEW: Add VBox inside Scroll for more flexible layout ---
	var internal_vbox = VBoxContainer.new()
	internal_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	internal_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL # Make VBox expand
	scroll.add_child(internal_vbox)

	var rich_text = RichTextLabel.new()
	rich_text.bbcode_enabled = true
	rich_text.text = content
	rich_text.fit_content = true # Let text determine height initially
	rich_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Make RichTextLabel expand vertically within VBox IF NEEDED, but prioritize content height
	rich_text.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_BEGIN
	rich_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rich_text.add_theme_color_override("default_color", Color(0.878, 0.878, 0.878))  # Light gray
	internal_vbox.add_child(rich_text) # --- MODIFIED: Add to internal_vbox ---

	tab_container.add_child(margin)

	return internal_vbox # --- MODIFIED: Return the VBox ---

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

func _on_hint_button_pressed():
	""" Handle hint button press in the help menu. """
	print("=== HINT BUTTON PRESSED ===")
	print("hint_label is null: ", hint_label == null)
	print("current_phase: ", current_phase)
	print("current_player: ", current_player)
	
	if hint_label == null:
		printerr("Hint label is not assigned.")
		return
	
	print("DEBUG: Passed null check")
	
	# Only allow hints at the very start of the turn (pre-capture phase)
	if current_phase != TurnPhase.PRE_MOVE_CAPTURE:
		print("DEBUG: Wrong phase, setting unavailable message")
		hint_label.text = "Hint unavailable.\n(Only works at the start of your turn, before moving or capturing)."
		print("DEBUG: Label text after setting: ", hint_label.text)
		return
	
	print("DEBUG: Phase is correct, getting best move...")
	
	# Call the AI function to get the best move
	var best_move = select_best_move(current_player)
	
	print("DEBUG: best_move returned: ", best_move)
	print("DEBUG: best_move type: ", typeof(best_move))
	print("DEBUG: best_move is null: ", best_move == null)
	
	if best_move == null:
		print("DEBUG: No legal moves, setting message")
		hint_label.text = "No legal moves found for %s." % current_player.capitalize()
		print("DEBUG: Label text after setting: ", hint_label.text)
	elif best_move is Array and best_move.size() == 2:
		print("DEBUG: Valid move array, formatting hint...")
		var start_pos = best_move[0]
		var end_pos = best_move[1]
		
		print("DEBUG: start_pos: ", start_pos, " end_pos: ", end_pos)
		
		# Format the hint nicely
		var piece_id = initial_board_state[start_pos.y][start_pos.x]
		print("DEBUG: piece_id: ", piece_id)
		
		var piece_data = _parse_piece_data(piece_id)
		var piece_value_str = ""
		if not piece_data.label.is_empty(): 
			piece_value_str = str(piece_data.label[0])
		
		var start_alg = coordinate_to_algebraic_gd(start_pos.x, start_pos.y)
		var end_alg = coordinate_to_algebraic_gd(end_pos.x, end_pos.y)
		
		print("DEBUG: About to set hint text...")
		hint_label.text = "Suggested Move:\nPiece %s (Value %s)\nFrom %s (%s) to %s (%s)" % [
			piece_id, piece_value_str,
			start_alg, str(start_pos),
			end_alg, str(end_pos)
		]
		print("DEBUG: Hint text set to: ", hint_label.text)
		print("DEBUG: Label visible: ", hint_label.visible)
	else:
		print("DEBUG: Unexpected return format")
		hint_label.text = "Error receiving hint data."
		printerr("Unexpected return value from select_best_move: %s" % str(best_move))
	
	print("=== HINT BUTTON DONE ===")
		
func pulse_help_button():
	"""Make the help button pulse to draw attention"""
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(help_button, "modulate:a", 0.5, 0.6)
	tween.tween_property(help_button, "modulate:a", 1.0, 0.6)

func _on_demo_mode_toggled(is_pressed: bool):
	"""Handle demo mode checkbox toggle."""
	demo_mode = is_pressed

	# --- ADD THIS BLOCK ---
	# Make checkboxes mutually exclusive
	if demo_mode and ai_vs_ai_mode:
		ai_vs_ai_mode = false
		if is_instance_valid(ai_vs_ai_checkbox):
			ai_vs_ai_checkbox.button_pressed = false
	# --- END OF BLOCK ---
	
	# Update the action label to show demo mode status
	if action_label:
		if demo_mode:
			var base_text = get_action_text()
			action_label.text = base_text + " [Demo Mode]"
		else:
			update_action_display()  # Reset to normal display
	
	print("Demo mode %s" % ("enabled" if demo_mode else "disabled"))

func get_action_text() -> String:
	"""Helper to get current action text without demo mode indicator."""
	match current_phase:
		TurnPhase.PRE_MOVE_CAPTURE:
			return "Action: pre-move capture"
		TurnPhase.MOVE:
			return "Action: move"
		TurnPhase.POST_MOVE_CAPTURE:
			return "Action: post-move capture"
		_:
			return "Action: unknown"

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


func check_all_victory_conditions(player_color: String):
	"""Check all victory conditions including progressions"""
	if game_ended or not victory_checker:
		return
	
	# Get captured pieces for this player
	var captured_pieces = []
	if player_color == "black":
		captured_pieces = captured_white_piece_values
	else:
		captured_pieces = captured_black_piece_values
	
	# Use victory_checker to check all conditions
	var result = victory_checker.check_for_win(player_color, captured_pieces)
	
	if result.won:
		# Map the reason to a display name
		var victory_type_display = ""
		match result.reason:
			"arithmetical progression":
				victory_type_display = "Arithmetical Progression"
			"geometrical progression":
				victory_type_display = "Geometrical Progression"
			"harmonic progression":
				victory_type_display = "Harmonic Progression"
			"body":
				victory_type_display = "Body"
			"goods":
				victory_type_display = "Goods"
		
		declare_victory(player_color.capitalize(), victory_type_display)
	
func declare_victory(winner: String, victory_type: String):
	"""Handle game victory"""
	if game_ended:
		return
	
	# Store winner info for the game log
	game_winner = winner
	game_victory_type = victory_type
	
	var victory_message = ""
	
	# Handle different victory types
	match victory_type:
		"Body":
			var pieces_captured = black_pieces_captured if winner == "Black" else white_pieces_captured
			victory_message = "%s WINS by Common Victory by Body! (%d pieces captured, needed %d)" % [
				winner, pieces_captured, victory_n0
			]
		"Goods":
			var value_captured = black_value_captured if winner == "Black" else white_value_captured
			victory_message = "%s WINS by Common Victory by Goods! (%d points captured, needed %d)" % [
				winner, value_captured, victory_n1
			]
		"Arithmetical Progression":
			victory_message = "%s WINS by Arithmetical Progression! (Three pieces in enemy territory forming arithmetic sequence)" % winner
		"Geometrical Progression":
			victory_message = "%s WINS by Geometrical Progression! (Three pieces in enemy territory forming geometric sequence)" % winner
		"Harmonic Progression":
			victory_message = "%s WINS by Harmonic Progression! (Three pieces in enemy territory forming harmonic sequence)" % winner
		_:
			victory_message = "%s WINS by %s!" % [winner, victory_type]
	
	print("\n" + "=".repeat(60))
	print("🏆 VICTORY! 🏆")
	print(victory_message)
	print("=".repeat(60) + "\n")
	
	# Update BOTH labels for maximum visibility
	if victory_label:
		victory_label.text = "🏆 " + victory_message + " 🏆"
		victory_label.visible = true
	
	if action_label:
		action_label.text = "🏆 GAME OVER 🏆"
	
	if turn_label:
		turn_label.text = victory_message
	
	# Also update status_label if it's different
	if status_label and status_label != action_label:
		status_label.text = "🏆 " + victory_message
	
	# Disable the phase button
	if phase_button:
		phase_button.text = "GAME OVER - " + winner + " WINS!"
		phase_button.disabled = true
	
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
	simulation_game_complete.emit() 
	
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


# ============================================
# SECTION: Victory Pattern Tracking
# ============================================


# ============================================
# Helper Functions for Pattern Detection
# ============================================

func get_all_piece_positions_with_values(color: String) -> Array:
	"""
	Returns array of dictionaries with piece positions and their values.
	Format: [{"pos": Vector2i(x, y), "value": int}, ...]
	Handles pyramids by treating them as their total value.
	"""
	var pieces = []
	
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile and tile.get_child_count() > 0:
				var piece = tile.get_child(0)
				if piece.piece_color == color:
					# Get piece value
					var value = 0
					if piece.piece_shape == "P":
						# Pyramid: sum all subpieces
						for sub_val in piece.piece_label:
							value += sub_val
					else:
						# Regular piece: first value
						if piece.piece_label.size() > 0:
							value = piece.piece_label[0]
					
					if value > 0:
						pieces.append({
							"pos": Vector2i(x, y),
							"value": value,
							"piece": piece
						})
	
	return pieces

func is_in_enemy_territory(pos: Vector2i, color: String) -> bool:
	"""Check if a position is in enemy territory."""
	if color == "white":
		# White's enemy territory is black's home (col 8-15)
		return pos.x >= 8
	else:
		# Black's enemy territory is white's home (col 0-7)
		return pos.x <= 7

func find_progression_on_board(pattern: Array, color: String) -> Array:
	"""
	Find all instances of a specific progression pattern currently on the board.
	Returns array of arrays, each containing 3 piece dictionaries that form the pattern.
	"""
	var pieces = get_all_piece_positions_with_values(color)
	var found_progressions = []
	
	# Look for pieces matching the three values in the pattern
	var pieces_v0 = pieces.filter(func(p): return p.value == pattern[0])
	var pieces_v1 = pieces.filter(func(p): return p.value == pattern[1])
	var pieces_v2 = pieces.filter(func(p): return p.value == pattern[2])
	
	# Find all combinations that form this pattern
	for p0 in pieces_v0:
		for p1 in pieces_v1:
			for p2 in pieces_v2:
				# Ensure they're different pieces
				if p0.pos != p1.pos and p1.pos != p2.pos and p0.pos != p2.pos:
					found_progressions.append([p0, p1, p2])
	
	return found_progressions

# ============================================
# Main Counting Functions
# ============================================

func count_progressions_for_color(color: String) -> Dictionary:
	"""
	Count all valid progressions for a given color currently on the board.
	Returns: {
		"arithmetical": int,
		"geometric": int,
		"harmonic": int,
		"total": int
	}
	"""
	var counts = {
		"arithmetical": 0,
		"geometric": 0,
		"harmonic": 0,
		"total": 0
	}
	
	# Select appropriate pattern lists
	var arithmetical_patterns = WHITE_ARITHMETICAL if color == "white" else BLACK_ARITHMETICAL
	var geometric_patterns = WHITE_GEOMETRIC if color == "white" else BLACK_GEOMETRIC
	var harmonic_patterns = WHITE_HARMONIC if color == "white" else BLACK_HARMONIC
	
	# Count arithmetical progressions
	for pattern in arithmetical_patterns:
		var found = find_progression_on_board(pattern, color)
		counts.arithmetical += found.size()
	
	# Count geometric progressions
	for pattern in geometric_patterns:
		var found = find_progression_on_board(pattern, color)
		counts.geometric += found.size()
	
	# Count harmonic progressions
	for pattern in harmonic_patterns:
		var found = find_progression_on_board(pattern, color)
		counts.harmonic += found.size()
	
	counts.total = counts.arithmetical + counts.geometric + counts.harmonic
	
	return counts

# Replace the count_progressions_for_color_invaders function with this:

func count_invader_pairs_for_color(color: String) -> Dictionary:
	"""
	Count pairs of pieces (from valid fireteams) that are BOTH in enemy territory.
	This measures progress toward Proper Victory (De Lite).
	
	An invader pair is: 2 pieces from a valid 3-piece progression, both in enemy territory.
	(The 3rd piece may be anywhere or not exist yet)
	
	Returns: {
		"arithmetical": int,
		"geometric": int,
		"harmonic": int,
		"total": int
	}
	"""
	var counts = {
		"arithmetical": 0,
		"geometric": 0,
		"harmonic": 0,
		"total": 0
	}
	
	# Get all friendly pieces in enemy territory with their values
	var invaders = []
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			
			var piece = tile.get_child(0)
			if piece.piece_color != color:
				continue
			
			var pos = Vector2i(x, y)
			if is_in_enemy_territory(pos, color):
				var value = get_piece_value(piece)
				if value > 0:
					invaders.append({
						"piece": piece,
						"pos": pos,
						"value": value
					})
	
	# Need at least 2 invaders to form a pair
	if invaders.size() < 2:
		return counts
	
	# Select appropriate pattern lists
	var arithmetical_patterns = WHITE_ARITHMETICAL if color == "white" else BLACK_ARITHMETICAL
	var geometric_patterns = WHITE_GEOMETRIC if color == "white" else BLACK_GEOMETRIC
	var harmonic_patterns = WHITE_HARMONIC if color == "white" else BLACK_HARMONIC
	
	# Check arithmetical patterns
	for pattern in arithmetical_patterns:
		counts.arithmetical += count_pairs_matching_pattern(invaders, pattern)
	
	# Check geometric patterns
	for pattern in geometric_patterns:
		counts.geometric += count_pairs_matching_pattern(invaders, pattern)
	
	# Check harmonic patterns
	for pattern in harmonic_patterns:
		counts.harmonic += count_pairs_matching_pattern(invaders, pattern)
	
	counts.total = counts.arithmetical + counts.geometric + counts.harmonic
	
	return counts


func count_pairs_matching_pattern(invaders: Array, pattern: Array) -> int:
	"""
	Count how many pairs from 'invaders' match 2 values from 'pattern'.
	For pattern [v1, v2, v3], we check for pairs: (v1,v2), (v1,v3), (v2,v3)
	"""
	var pair_count = 0
	
	# Get invaders matching each value in the pattern
	var matches_v1 = invaders.filter(func(inv): return inv.value == pattern[0])
	var matches_v2 = invaders.filter(func(inv): return inv.value == pattern[1])
	var matches_v3 = invaders.filter(func(inv): return inv.value == pattern[2])
	
	# Count pair (v1, v2)
	for inv1 in matches_v1:
		for inv2 in matches_v2:
			if inv1.pos != inv2.pos:  # Different pieces
				pair_count += 1
	
	# Count pair (v1, v3)
	for inv1 in matches_v1:
		for inv3 in matches_v3:
			if inv1.pos != inv3.pos:
				pair_count += 1
	
	# Count pair (v2, v3)
	for inv2 in matches_v2:
		for inv3 in matches_v3:
			if inv2.pos != inv3.pos:
				pair_count += 1
	
	# Each valid pair is counted twice (once in each direction), so divide by 2
	return pair_count 


# ============================================
# Wrapper Function for Both Colors
# ============================================

func count_all_progressions() -> Dictionary:
	"""
	Count progressions for both colors at once.
	Returns: {
		"white": {counts},
		"black": {counts},
		"white_invaders": {counts},
		"black_invaders": {counts}
	}
	"""
	return {
		"white": count_progressions_for_color("white"),
		"black": count_progressions_for_color("black"),
		"white_invaders": count_invader_pairs_for_color("white"),
		"black_invaders": count_invader_pairs_for_color("black")
	}

# ============================================
# Optional: Update progression tracking after each move
# ============================================

func update_progression_tracking():
	"""
	Call this after each capture or move to update progression counts.
	You can display these in the UI or check for victory conditions.
	"""
	var progressions = count_all_progressions()
	
	# Print to console for debugging
	print("\n=== PROGRESSION STATUS ===")
	print("White: %d total (%d arithmetical, %d geometric, %d harmonic)" % [
		progressions.white.total,
		progressions.white.arithmetical,
		progressions.white.geometric,
		progressions.white.harmonic
	])
	print("White invaders (2 in enemy territory): %d total" % progressions.white_invaders.total)
	print("Black: %d total (%d arithmetical, %d geometric, %d harmonic)" % [
		progressions.black.total,
		progressions.black.arithmetical,
		progressions.black.geometric,
		progressions.black.harmonic
	])
	print("Black invaders (2 in enemy territory): %d total" % progressions.black_invaders.total)
	print("=========================\n")
	
	# NEW: Add detailed debug info when invader pairs > 0
	if progressions.white_invaders.total > 0:
		debug_invader_pairs("white")
	if progressions.black_invaders.total > 0:
		debug_invader_pairs("black")
	
	return progressions

func debug_invader_pairs(color: String):
	"""Debug function to see which pieces are being counted as invader pairs."""
	print("\n=== DEBUG: INVADER PAIRS FOR %s ===" % color.to_upper())
	
	# Get all pieces in enemy territory
	var invaders = []
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			
			var piece = tile.get_child(0)
			if piece.piece_color != color:
				continue
			
			var pos = Vector2i(x, y)
			if is_in_enemy_territory(pos, color):
				var value = get_piece_value(piece)
				if value > 0:
					invaders.append({
						"id": piece.piece_id,
						"pos": pos,
						"value": value
					})
					print("  Invader: %s at %s with value %d" % [piece.piece_id, pos, value])
	
	print("Total invaders in enemy territory: %d" % invaders.size())
	
	# Now check which patterns they match
	var arithmetical_patterns = WHITE_ARITHMETICAL if color == "white" else BLACK_ARITHMETICAL
	var geometric_patterns = WHITE_GEOMETRIC if color == "white" else BLACK_GEOMETRIC
	var harmonic_patterns = WHITE_HARMONIC if color == "white" else BLACK_HARMONIC
	
	print("\nChecking against patterns:")
	for pattern in arithmetical_patterns:
		var count = count_pairs_matching_pattern(invaders, pattern)
		if count > 0:
			print("  Arithmetical %s: %d pairs" % [str(pattern), count])
	
	for pattern in geometric_patterns:
		var count = count_pairs_matching_pattern(invaders, pattern)
		if count > 0:
			print("  Geometric %s: %d pairs" % [str(pattern), count])
	
	for pattern in harmonic_patterns:
		var count = count_pairs_matching_pattern(invaders, pattern)
		if count > 0:
			print("  Harmonic %s: %d pairs" % [str(pattern), count])
	
	print("================================\n")
	
# ============================================
# AI HELPER: Get best move based on priorities
# ============================================

func get_best_move_suggestion(color: String) -> Dictionary:
	"""
	Suggest the best move based on priorities:
	1. Fireteam-completing moves
	2. Moves into enemy territory
	3. Other moves
	"""
	var moves = get_all_legal_moves_prioritized(color)
	
	if moves.size() == 0:
		return {}
	
	# First move is already the best (fireteam-completing if available)
	return moves[0]

# Add to board.gd or move_validator.gd

# ============================================
# STRATEGIC MOVE ORDERING - Fireteam Completion
# ============================================

# --- Function to get prioritized legal moves ---
func get_all_legal_moves_prioritized(color: String, board_state: Array = []) -> Array:
	"""
	Returns all legal moves for a color, with fireteam-completing moves first.
	Uses the provided board_state array if given, otherwise uses the live board.

	Returns: Array of dictionaries:
	[{
		"start_pos": Vector2i,
		"end_pos": Vector2i,
		"completes_fireteam": bool,
		"fireteam_type": String,  # "arithmetical", "geometrical", "harmonic", or ""
		"fireteam_values": Array  # The three values forming the progression, sorted
	}, ...]
	"""
	var all_moves_data = []
	var use_override = board_state.size() > 0

	# Iterate through the board to find pieces of the specified color
	for y in range(8):
		for x in range(16):
			var piece_node = null # Used for live board check
			var piece_id = "" # Used for override check
			var piece_color_on_tile = ""
			var start_pos = Vector2i(x, y)

			# --- Get piece info (either from live board or override) ---
			if use_override:
				if y < board_state.size() and x < board_state[y].size():
					piece_id = board_state[y][x]
					if piece_id != "":
						piece_color_on_tile = "white" if piece_id[0] == piece_id[0].to_upper() else "black"
			else:
				var tile = get_tile_at_coords(x, y)
				if tile and tile.get_child_count() > 0:
					piece_node = tile.get_child(0)
					if is_instance_valid(piece_node): # Check if piece node is valid
						piece_color_on_tile = piece_node.piece_color
						piece_id = piece_node.piece_id # Get ID for fireteam check consistency
					else:
						# Handle cases where tile has child but it's not a valid piece node
						# print("Warning: Invalid node found on tile at %s" % str(start_pos))
						continue


			# --- Process piece if color matches ---
			if piece_color_on_tile == color:
				# Get valid moves using the appropriate board state
				var valid_destinations = move_validator.get_valid_moves_from_state(piece_id, start_pos, board_state if use_override else initial_board_state)

				# Check each valid destination
				for end_pos in valid_destinations:
					var move_data = {
						"start_pos": start_pos,
						"end_pos": end_pos,
						"completes_fireteam": false,
						"fireteam_type": "",
						"fireteam_values": []
					}

					# --- Check if this move completes a fireteam (needs piece node info) ---
					# We need the piece node or equivalent data to pass to the check function.
					var piece_for_check = piece_node # Might be null if use_override is true
					if piece_for_check == null and not use_override and piece_id != "":
						# If using live board, try to get the node again just in case
						var tile_check = get_tile_at_coords(x, y)
						if tile_check and tile_check.get_child_count() > 0:
							var potential_node = tile_check.get_child(0)
							# Double check it's the right piece ID if needed, though position should be enough
							if is_instance_valid(potential_node) and potential_node.has_method("get") and potential_node.get("piece_id") == piece_id:
								piece_for_check = potential_node


					if piece_for_check != null and is_instance_valid(piece_for_check): # Check instance validity
						var fireteam_check = does_move_complete_invader_fireteam(piece_for_check, start_pos, end_pos, color)
						if fireteam_check.completes:
							move_data.completes_fireteam = true
							move_data.fireteam_type = fireteam_check.type
							move_data.fireteam_values = fireteam_check.values
					elif use_override:
						# TODO: Implement fireteam check based ONLY on simulated board state and piece ID/data
						# This requires does_move_complete_invader_fireteam_from_state
						# var fireteam_check_sim = does_move_complete_invader_fireteam_from_state(piece_id, start_pos, end_pos, color, board_state)
						# if fireteam_check_sim.completes: # Assuming function exists and returns same dict structure
						#	move_data.completes_fireteam = true
						#	move_data.fireteam_type = fireteam_check_sim.type
						#	move_data.fireteam_values = fireteam_check_sim.values
						pass # Placeholder - fireteam check from state not yet implemented


					all_moves_data.append(move_data)

	# Sort: fireteam-completing moves first
	all_moves_data.sort_custom(func(a, b):
		if a.completes_fireteam and not b.completes_fireteam:
			return true
		if not a.completes_fireteam and b.completes_fireteam:
			return false
		# Both equal in fireteam status, maintain relative order (or add secondary sort criteria)
		return false # GDScript sort: false means keep order or use next criteria
	)

	return all_moves_data


func does_move_complete_invader_fireteam(piece: Node2D, from_pos: Vector2i, to_pos: Vector2i, color: String) -> Dictionary:
	"""
	Check if moving a piece from from_pos to to_pos would complete an invader fireteam.
	An invader fireteam is 3 pieces in enemy territory forming a progression.
	
	Returns: {
		completes: bool,
		type: String,  # "arithmetical", "geometric", "harmonic"
		values: Array  # [v1, v2, v3] of the progression
	}
	"""
	# Only count if moving INTO enemy territory (not already in it)
	var from_in_enemy = is_in_enemy_territory(from_pos, color)
	var to_in_enemy = is_in_enemy_territory(to_pos, color)
	
	if from_in_enemy or not to_in_enemy:
		# Either already in enemy territory, or not moving to enemy territory
		return {"completes": false, "type": "", "values": []}
	
	# Get the value of the moving piece
	var moving_value = get_piece_value(piece)
	if moving_value <= 0:
		return {"completes": false, "type": "", "values": []}
	
	# Get all friendly pieces already in enemy territory
	var pieces_in_enemy = get_pieces_in_enemy_territory(color)
	
	# Need at least 2 other pieces there to form a 3-piece progression
	if pieces_in_enemy.size() < 2:
		return {"completes": false, "type": "", "values": []}
	
	# Check all pairs of existing pieces in enemy territory
	for i in range(pieces_in_enemy.size()):
		for j in range(i + 1, pieces_in_enemy.size()):
			var p1 = pieces_in_enemy[i]
			var p2 = pieces_in_enemy[j]
			
			# Skip if either is the moving piece (shouldn't happen, but safety check)
			var p1_pos = find_piece_position(p1)
			var p2_pos = find_piece_position(p2)
			if p1_pos == from_pos or p2_pos == from_pos:
				continue
			
			var v1 = get_piece_value(p1)
			var v2 = get_piece_value(p2)
			var v3 = moving_value
			
			if v1 <= 0 or v2 <= 0:
				continue
			
			# Check if these three values form a valid progression
			var progression_result = check_if_values_form_progression(v1, v2, v3, color)
			if progression_result.is_valid:
				return {
					"completes": true,
					"type": progression_result.type,
					"values": progression_result.values
				}
	
	return {"completes": false, "type": "", "values": []}


func check_if_values_form_progression(v1: int, v2: int, v3: int, color: String) -> Dictionary:
	"""
	Check if three values form any valid progression for this color.
	Returns: {is_valid: bool, type: String, values: Array}
	"""
	# Get the valid patterns for this color
	var arithmetical_patterns = WHITE_ARITHMETICAL if color == "white" else BLACK_ARITHMETICAL
	var geometric_patterns = WHITE_GEOMETRIC if color == "white" else BLACK_GEOMETRIC
	var harmonic_patterns = WHITE_HARMONIC if color == "white" else BLACK_HARMONIC
	
	# Sort the values
	var values = [v1, v2, v3]
	values.sort()
	
	# Check arithmetical patterns
	for pattern in arithmetical_patterns:
		if values[0] == pattern[0] and values[1] == pattern[1] and values[2] == pattern[2]:
			return {
				"is_valid": true,
				"type": "arithmetical",
				"values": values
			}
	
	# Check geometric patterns
	for pattern in geometric_patterns:
		if values[0] == pattern[0] and values[1] == pattern[1] and values[2] == pattern[2]:
			return {
				"is_valid": true,
				"type": "geometric",
				"values": values
			}
	
	# Check harmonic patterns
	for pattern in harmonic_patterns:
		if values[0] == pattern[0] and values[1] == pattern[1] and values[2] == pattern[2]:
			return {
				"is_valid": true,
				"type": "harmonic",
				"values": values
			}
	
	return {"is_valid": false, "type": "", "values": []}


func get_piece_value(piece: Node2D) -> int:
	"""Helper to get a piece's total value."""
	if piece.piece_shape == "P":
		# Pyramid: sum all subpieces
		var total = 0
		for val in piece.piece_label:
			total += val
		return total
	else:
		# Regular piece
		return piece.piece_label[0] if piece.piece_label.size() > 0 else 0


func get_pieces_in_enemy_territory(color: String) -> Array:
	"""Get all pieces of a color currently in enemy territory."""
	var pieces = []
	
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			
			var piece = tile.get_child(0)
			if piece.piece_color != color:
				continue
			
			var pos = Vector2i(x, y)
			if is_in_enemy_territory(pos, color):
				pieces.append(piece)
	
	return pieces


# ============================================
# USAGE EXAMPLES & UI FEEDBACK
# ============================================

func print_prioritized_moves_analysis(color: String):
	"""Debug function to show fireteam-completing moves."""
	var moves = get_all_legal_moves_prioritized(color)
	
	print("\n=== MOVE ANALYSIS FOR %s ===" % color.to_upper())
	print("Total legal moves: %d" % moves.size())
	
	var fireteam_moves = moves.filter(func(m): return m.completes_fireteam)
	if fireteam_moves.size() > 0:
		print("\n🎯 FIRETEAM-COMPLETING MOVES: %d" % fireteam_moves.size())
		for move in fireteam_moves:
			print("  → %s: %s to %s completes %s progression %s" % [
				move.piece.piece_id,
				move.from_pos,
				move.to_pos,
				move.fireteam_type,
				str(move.fireteam_values)
			])
	else:
		print("\nNo fireteam-completing moves available")
	
	print("==============================\n")


func highlight_fireteam_completing_moves():
	"""
	Visual helper: when a piece is selected, highlight destinations
	that would complete fireteams differently.
	Call this from select_piece_for_move().
	"""
	if selected_piece == null or selected_tile == null:
		return
	
	var from_pos = get_tile_coords(selected_tile)
	var valid_moves = move_validator.get_valid_moves(selected_piece, from_pos)
	
	for to_pos in valid_moves:
		var tile = get_tile_at_coords(to_pos.x, to_pos.y)
		if tile == null:
			continue
		
		# Check if this move completes a fireteam
		var fireteam_check = does_move_complete_invader_fireteam(
			selected_piece, from_pos, to_pos, selected_piece.piece_color
		)
		
		if fireteam_check.completes:
			# Use a special highlight color for fireteam moves
			tile.color = Color(1.0, 0.84, 0.0)  # Gold
		else:
			# Normal move highlight
			tile.color = valid_move_highlight


# ============================================
# OPTIONAL: Detailed invader pair analysis
# ============================================

func print_invader_pairs_analysis(color: String):
	"""Debug function to show detailed invader pair information."""
	var pairs_data = count_invader_pairs_for_color(color)
	
	print("\n=== INVADER PAIRS FOR %s ===" % color.to_upper())
	print("Total invader pairs: %d" % pairs_data.total)
	print("  Arithmetical pairs: %d" % pairs_data.arithmetical)
	print("  Geometric pairs: %d" % pairs_data.geometric)
	print("  Harmonic pairs: %d" % pairs_data.harmonic)
	
	# Show which pieces are in enemy territory
	var invaders = []
	for y in range(8):
		for x in range(16):
			var tile = get_tile_at_coords(x, y)
			if tile == null or tile.get_child_count() == 0:
				continue
			
			var piece = tile.get_child(0)
			if piece.piece_color != color:
				continue
			
			var pos = Vector2i(x, y)
			if is_in_enemy_territory(pos, color):
				var value = get_piece_value(piece)
				invaders.append("%s(v=%d)" % [piece.piece_id, value])
	
	if invaders.size() > 0:
		print("Pieces in enemy territory: %s" % ", ".join(invaders))
	else:
		print("No pieces in enemy territory yet")
	
	print("==============================\n")


# --- Center of Gravity Calculation (Modified) ---
func calculate_center_of_gravity(piece_color: String, by_rank: bool = false, board_state_override: Array = []) -> Vector2:
	"""
	Calculates the center of gravity (average position) of pieces for a given color.
	Can optionally use a provided board state array instead of the live board.

	Args:
		piece_color (String): The color to calculate for ("white" or "black").
		by_rank (bool): If true, only considers pieces near the enemy territory.
		board_state_override (Array): Optional. A 2D array representing the board state to use for calculation.

	Returns:
		Vector2: The calculated center of gravity (average row, average col),
				 or Vector2(-1, -1) if no pieces are found.
	"""
	var target_color = piece_color.to_lower()
	if target_color != "white" and target_color != "black":
		printerr("Invalid color '%s' passed to calculate_center_of_gravity. Use 'white' or 'black'." % piece_color)
		return Vector2(-1, -1)

	var relevant_piece_positions: Array[Vector2i] = []
	var use_override = board_state_override.size() > 0

	# Iterate through board state (either live tiles or override array)
	for y in range(8):
		for x in range(16):
			var piece_data = null
			var piece_color_on_tile = ""

			if use_override:
				# --- Logic for reading from board_state_override ---
				if y < board_state_override.size() and x < board_state_override[y].size():
					var piece_id = board_state_override[y][x]
					if piece_id != "":
						# Determine color from the ID's first character case
						piece_color_on_tile = "white" if piece_id[0] == piece_id[0].to_upper() else "black"
						# Store position if color matches
						if piece_color_on_tile == target_color:
							piece_data = {"pos": Vector2i(x, y)} # Store position
			else:
				# --- Logic for reading from live board tiles ---
				var tile = get_tile_at_coords(x, y)
				if tile and tile.get_child_count() > 0:
					var piece = tile.get_child(0)
					piece_color_on_tile = piece.piece_color
					# Store position if color matches
					if piece_color_on_tile == target_color:
						piece_data = {"pos": Vector2i(x, y)} # Store position

			# If a piece of the target color was found (either way)
			if piece_data != null:
				var current_pos = piece_data.pos # Vector2i(x=col, y=row)

				# Apply by_rank filter if enabled
				if by_rank:
					if target_color == "black":
						# Black pieces near White territory (columns 0-9)
						if current_pos.x < 10:
							relevant_piece_positions.append(current_pos)
					else: # target_color == "white"
						# White pieces near Black territory (columns 6-15)
						if current_pos.x > 5:
							relevant_piece_positions.append(current_pos)
				else:
					# No filter, add all pieces of the target color
					relevant_piece_positions.append(current_pos)

	# Calculate the average position
	var piece_count = relevant_piece_positions.size()
	if piece_count == 0:
		# print("No pieces found for color '%s' with by_rank=%s using %s" % [target_color, str(by_rank), "override array" if use_override else "live board"])
		return Vector2(-1, -1)

	var sum_pos = Vector2.ZERO
	for pos in relevant_piece_positions:
		sum_pos.x += pos.x # Sum columns
		sum_pos.y += pos.y # Sum rows

	# Calculate average, returning (average_row, average_col)
	var avg_pos = Vector2(sum_pos.y / piece_count, sum_pos.x / piece_count)
	
	# print("Center of Gravity for %s (by_rank=%s, using %s): %s" % [target_color.capitalize(), str(by_rank), "override array" if use_override else "live board", str(avg_pos)])
	return avg_pos


# --- NEW: Function to check if a move is an advance ---
func is_an_advance(start_pos: Vector2i, end_pos: Vector2i, player_color: String) -> bool:
	"""
	Checks if a given move brings the player's center of gravity closer to the enemy territory.

	Args:
		start_pos (Vector2i): The starting position (x=col, y=row) of the move.
		end_pos (Vector2i): The ending position (x=col, y=row) of the move.
		player_color (String): The color of the player making the move ("white" or "black").

	Returns:
		bool: True if the move results in an advance towards enemy territory, False otherwise.
	"""
	var target_color = player_color.to_lower()
	if target_color != "white" and target_color != "black":
		printerr("Invalid color '%s' passed to is_an_advance." % player_color)
		return false

	# 1. Calculate COG before the move (using live board state)
	var cog_before = calculate_center_of_gravity(target_color, false) # Don't use by_rank here
	if cog_before == Vector2(-1, -1):
		printerr("Could not calculate COG before move for %s." % target_color)
		return false # Cannot determine advance if initial COG is invalid

	# 2. Simulate the move in a temporary board state array
	var temp_board_state = []
	for row in initial_board_state:
		temp_board_state.append(row.duplicate())

	# Check if start position is valid before accessing
	if start_pos.y >= 0 and start_pos.y < temp_board_state.size() and \
	   start_pos.x >= 0 and start_pos.x < temp_board_state[start_pos.y].size():
		var piece_id = temp_board_state[start_pos.y][start_pos.x]
		temp_board_state[start_pos.y][start_pos.x] = "" # Clear start position

		# Check if end position is valid before placing piece
		if end_pos.y >= 0 and end_pos.y < temp_board_state.size() and \
		   end_pos.x >= 0 and end_pos.x < temp_board_state[end_pos.y].size():
			temp_board_state[end_pos.y][end_pos.x] = piece_id # Place piece at end position
		else:
			printerr("Invalid end position %s provided to is_an_advance." % str(end_pos))
			return false
	else:
		printerr("Invalid start position %s provided to is_an_advance." % str(start_pos))
		return false

	# 3. Calculate COG after the simulated move (using the temporary array)
	var cog_after = calculate_center_of_gravity(target_color, false, temp_board_state)
	if cog_after == Vector2(-1, -1):
		printerr("Could not calculate COG after simulated move for %s." % target_color)
		return false # Cannot determine advance if simulated COG is invalid

	# 4. Compare COG column values based on player color
	var cog_before_col = cog_before.y # Remember COG is (row, col)
	var cog_after_col = cog_after.y

	if target_color == "white":
		# White advances if COG column increases (moves right, towards higher columns)
		# print("White COG change: %.2f -> %.2f" % [cog_before_col, cog_after_col])
		return cog_after_col > cog_before_col
	else: # target_color == "black"
		# Black advances if COG column decreases (moves left, towards lower columns)
		# print("Black COG change: %.2f -> %.2f" % [cog_before_col, cog_after_col])
		return cog_after_col < cog_before_col

# --- NEW: AI Move Selection Logic ---

# --- NEW: Helper for Fireteam Victory Check ---


func select_best_move(player_color: String) -> Variant:
	"""
	Selects the best move for the given player based on a one-turn lookahead score.

	Args:
		player_color (String): "white" or "black".

	Returns:
		Array[Vector2i]: The best move found [start_pos, end_pos], or null if no moves are available.
	"""
	print("\nSelecting best move for %s..." % player_color.capitalize())
	var best_score = -INF # Initialize with a very low score
	var best_moves = [] # Store moves with the best score found so far

	# --- 1. Simulate Pre-move Captures (on a temporary board state) ---
	var temp_board_state_pre_cap = []
	for row in initial_board_state: temp_board_state_pre_cap.append(row.duplicate())
	temp_board_state_pre_cap = _simulate_captures(player_color, temp_board_state_pre_cap)
	
	# --- 2. Get all legal moves from the state *after* pre-captures ---
	# Get moves as dictionaries with board state support
	var legal_moves_data = get_all_legal_moves_prioritized(player_color, temp_board_state_pre_cap)

	# --- 3. Evaluate each legal move ---
	for move_data in legal_moves_data:
		var start_pos = move_data.start_pos   # Dictionary access
		var end_pos = move_data.end_pos       # Dictionary access

		# --- a. Simulate the move ---
		var temp_board_state_after_move = _simulate_move(start_pos, end_pos, temp_board_state_pre_cap)
		if temp_board_state_after_move == null: # Should not happen if move is legal
			printerr("Error simulating move %s -> %s" % [str(start_pos), str(end_pos)])
			continue

		# --- b. Simulate Post-move Captures ---
		var final_board_state = _simulate_captures(player_color, temp_board_state_after_move)

		# --- c. Score the final state ---
		var score = _calculate_position_score(final_board_state, player_color)
		#print("  Move %s -> %s results in score: %f" % [str(start_pos), str(end_pos), score])

		# --- d. Update best score and best moves ---
		if score > best_score:
			best_score = score
			best_moves = [[start_pos, end_pos]] # Start a new list with this better move
		elif score == best_score:
			best_moves.append([start_pos, end_pos]) # Add to list of equally good moves

	print("Found %d moves with the best score: %f" % [best_moves.size(), best_score])

	# --- 4. Tie-breaking using is_an_advance ---
	if best_moves.size() > 1:
		var advancing_moves = []
		for move in best_moves:
			# Pass the original start/end pos and color to is_an_advance
			# is_an_advance uses the *current* live board state (initial_board_state)
			# to calculate the COG before the move, which is correct.
			if is_an_advance(move[0], move[1], player_color):
				advancing_moves.append(move)
		
		if advancing_moves.size() > 0:
			print("Selecting randomly from %d advancing best moves." % advancing_moves.size())
			randomize()
			return advancing_moves.pick_random()
		else:
			print("No best moves are advancing. Selecting randomly from all best moves.")
			# Fall through to random selection from all best moves
	elif best_moves.is_empty():
		# This case should theoretically not be reached if legal_moves was not empty
		printerr("Error: No best moves found, although legal moves existed.")
		return null


	# --- 5. Final Selection (Randomly if tie-broken list still has multiples, or if only one best move) ---
	randomize()
	var selected_move = best_moves.pick_random()
	print("Selected move: %s -> %s" % [str(selected_move[0]), str(selected_move[1])])
	return selected_move


func _simulate_captures(player_color: String, board_state: Array) -> Array:
	"""
	Simulates all possible captures for a player on a given board state array.
	Does NOT modify the input array, returns a new array.
	NOTE: This is a simplified simulation. It assumes captures don't enable
		  new captures within the same phase (chain captures).
	"""
	var sim_board = []
	for row in board_state: sim_board.append(row.duplicate())

	var possible_captures = _get_all_captures_for_player_from_state(player_color, sim_board)

	var captured_coords = [] # Keep track of captured piece locations to avoid double captures etc.

	for capture_info in possible_captures:
		# capture_info structure from get_all_possible_captures_from_state is FLAT:
		# { attacker_pos: Vector2i, victim_pos/target_pos: Vector2i, type: String, value: int, helper_pos: Vector2i or null }
		# NOT the nested structure with capture_types array!

		# Validate that capture_info has the expected structure
		if not capture_info.has("attacker_pos"):
			printerr("Simulate capture: Invalid capture_info structure - missing attacker_pos: %s" % str(capture_info))
			continue
		
		if not (capture_info.has("victim_pos") or capture_info.has("target_pos")):
			printerr("Simulate capture: Invalid capture_info structure - missing victim/target position: %s" % str(capture_info))
			continue
		
		if not capture_info.has("type") or not capture_info.has("value"):
			printerr("Simulate capture: Invalid capture_info structure - missing type or value: %s" % str(capture_info))
			continue
		
		var attacker_pos = capture_info.attacker_pos
		# Handle both 'victim_pos' and 'target_pos' for compatibility
		var victim_pos = capture_info.get("victim_pos", capture_info.get("target_pos", null))
		
		if victim_pos == null:
			printerr("Simulate capture: Could not find victim position in capture_info")
			continue
		
		# Skip if victim already captured in this simulation step
		if victim_pos in captured_coords:
			continue

		# Get capture data directly from the flat structure
		var captured_value = capture_info.value

		# Simulate the piece removal/modification on sim_board
		if victim_pos.y >= 0 and victim_pos.y < sim_board.size() and \
		   victim_pos.x >= 0 and victim_pos.x < sim_board[victim_pos.y].size():
			
			var piece_id = sim_board[victim_pos.y][victim_pos.x]
			if piece_id != "":
				var piece_data = _parse_piece_data(piece_id) # Need color/shape
				
				if piece_data.shape == "P":
					# --- Simulate Pyramid Sub-piece Removal ---
					# Reconstruct the pyramid ID to update its label
					# Note: This simulation doesn't perfectly replicate the live Piece node's state.
					# It assumes the label can be inferred/updated based on captured_value.
					# A more robust simulation might need to store full piece data, not just IDs.
					var current_label = piece_data.label.duplicate() # Get current label
					if captured_value in current_label:
						current_label.erase(captured_value)
						# If label is empty, remove the pyramid entirely
						if current_label.is_empty():
							sim_board[victim_pos.y][victim_pos.x] = ""
							captured_coords.append(victim_pos)
						else:
							# How to update the ID based on new label? This is complex.
							# Simplification: Just mark as captured for scoring, don't update ID string.
							# For scoring purposes, we mostly care if the square is empty or not.
							# A better scoring might need the remaining value.
							# Let's assume removing any subpiece counts as a capture event,
							# but we don't fully remove the pyramid from the board array unless empty.
							pass # Keep pyramid ID, assume label is internally reduced
					else:
						# Value not found - indicates potential issue with simulation state or capture data
						printerr("Simulate capture: Pyramid sub-piece %d not found in label %s for %s" % [captured_value, str(piece_data.label), piece_id])
				else:
					# --- Simulate Full Piece Removal ---
					sim_board[victim_pos.y][victim_pos.x] = ""
					captured_coords.append(victim_pos) # Mark square as captured

	return sim_board


func _simulate_move(start_pos: Vector2i, end_pos: Vector2i, board_state: Array) -> Array:
	"""
	Simulates a single move on a given board state array.
	Does NOT modify the input array, returns a new array.
	Returns the original board_state if the move is invalid in the simulation context.
	"""
	var sim_board = []
	for row in board_state: sim_board.append(row.duplicate(true)) # Deep duplicate

	# Check bounds and validity before modifying
	if start_pos.y >= 0 and start_pos.y < sim_board.size() and \
	   start_pos.x >= 0 and start_pos.x < sim_board[start_pos.y].size() and \
	   end_pos.y >= 0 and end_pos.y < sim_board.size() and \
	   end_pos.x >= 0 and end_pos.x < sim_board[end_pos.y].size():

		var piece_id = sim_board[start_pos.y][start_pos.x]
		if piece_id == "":
			# This might happen if pre-captures removed the piece
			# printerr("Simulate move warning: No piece at start position %s" % str(start_pos))
			return board_state # Return original state if piece is gone
		if sim_board[end_pos.y][end_pos.x] != "":
			# This should ideally be caught by legal move check, but double-check
			printerr("Simulate move error: End position %s is occupied by %s" % [str(end_pos), sim_board[end_pos.y][end_pos.x]])
			return board_state # Return original state if move is invalid
			
		sim_board[start_pos.y][start_pos.x] = ""
		sim_board[end_pos.y][end_pos.x] = piece_id
		return sim_board # Return the new simulated board state
	else:
		printerr("Simulate move error: Invalid position(s) %s -> %s" % [str(start_pos), str(end_pos)])
		return board_state # Return original state if positions are invalid



func _calculate_position_score(board_state: Array, player_color: String) -> float:
	"""
	Calculates score based on prioritized moves (fireteams weighted higher).
	Score = (My Fireteam Moves * 10 + My Regular Moves) - (Opponent Fireteam Moves * 10 + Opponent Regular Moves)
	Uses the provided board_state array for calculations.
	"""
	var opponent_color = "black" if player_color == "white" else "white"

	# Get prioritized moves for the player
	var player_moves_prioritized = get_all_legal_moves_prioritized(player_color, board_state)
	# Get prioritized moves for the opponent
	var opponent_moves_prioritized = get_all_legal_moves_prioritized(opponent_color, board_state)

	# --- Calculate Player Score Part ---
	var player_fireteam_moves = 0
	var player_regular_moves = 0
	for move_data in player_moves_prioritized:
		if move_data.completes_fireteam:
			player_fireteam_moves += 1
		else:
			player_regular_moves += 1
	# Simple capture count for now - could be refined to use capture value or type
	var player_captures = _get_all_captures_for_player_from_state(player_color, board_state)
	var player_score_part = (player_fireteam_moves * 10.0) + player_regular_moves + (player_captures.size() * 5.0)


	# --- Calculate Opponent Score Part ---
	var opponent_fireteam_moves = 0
	var opponent_regular_moves = 0
	for move_data in opponent_moves_prioritized:
		if move_data.completes_fireteam:
			opponent_fireteam_moves += 1
		else:
			opponent_regular_moves += 1
	var opponent_captures = _get_all_captures_for_player_from_state(opponent_color, board_state)
	var opponent_score_part = (opponent_fireteam_moves * 10.0) + opponent_regular_moves + (opponent_captures.size() * 5.0)

	return player_score_part - opponent_score_part

func _on_ai_vs_ai_toggled(is_pressed: bool):
	"""Handle AI vs. AI checkbox toggle."""
	ai_vs_ai_mode = is_pressed

	# Make checkboxes mutually exclusive
	if ai_vs_ai_mode and demo_mode:
		demo_mode = false
		if is_instance_valid(demo_checkbox):
			demo_checkbox.button_pressed = false

	print("AI vs. AI mode %s" % ("enabled" if ai_vs_ai_mode else "disabled"))
	update_action_display() # Update UI

	# --- START OF FIX ---
	# Check if the AI should take a turn *right now*
	var is_ai_turn = false
	if ai_vs_ai_mode:
		is_ai_turn = true # AI vs AI mode, AI always plays
	elif current_player == "black" and not demo_mode:
		is_ai_turn = true # Human vs AI mode, it's Black's turn

	if is_ai_turn and not game_ended:
		call_deferred("execute_ai_turn")
	# --- END OF FIX ---

func create_log_window_programmatically():
	"""Helper to create and add the log window to the scene"""
	var window = create_log_window()
	
	# Add to a high-layer CanvasLayer so it appears on top
	var log_layer = CanvasLayer.new()
	log_layer.name = "LogLayer"
	log_layer.layer = 105  # Higher than help layer (110 might be too high)
	add_child(log_layer)
	log_layer.add_child(window)
	
	# Update the reference
	log_window = window
	print("Log window created successfully!")
