"""
This is a very basic but complete implementation of rithmomachia in python, 
using tkinter for the GUI. It comtains a standalone function 

launch_rithmomachia_gui()

(run on the command line) to start a game. A few windows pop up,
including the game board, and you make various choices. For example, 
in one window to select between playing against another person 
or playing against the computer). There is a help button with the 
rules. Moving a piece is by clicking on its current position and then on 
the destination square. Similarly, captures are performed by 
clicking on your (or one of your) attacking piece and then clicking 
on the enemy piece you want to capture. The computer checks for 
all possible ways to capture. If your choice is a valid capture 
and there is no ambiguity, the enemy piece disappears and a 
record is printed in the log. If there is a choice to be made, a 
window pops up with and you make the capture more specific.

This module is an object-oriented version of python fcns in 
my python/sagemath module rithmomachia.sage, which completely 
implements a command line version of rithmomachia to be run in sage. 
There is also a version which run in in a sagemath jupyter 
notebook. It's about 8000 lines, including all the commented out 
lines of documentation.

The conversion/refactoring here follows chatGPT and Gemini's suggestions.
In fact, the vast majority of the lines of code below are from
either Gemini or chatGPT directly, following very detailed 
prompts on my part based on my above-mentioned working code.
This rewritten code is under 1000 lines.

Classes:

* Piece
   Each of these subclasses have get_potential_moves and valid_moves methods:
** Circle(Piece)
** Triangle(Piece)
** Square(Piece)
** Pyramid(Piece)  (this also has a lose_subpiece method)

* Player
  This has a record_capture method

* Board 
  This has a get_piece, move_piece, remove_piece, all_positions.
  The init method uses a stand-alone function 
  standard_rithmomachia_setup(board).

* RithmomachiaGame 
  This has too many methods to mention. 

* RithmomachiaGUI
  This class uses a number of tkinter classes, such as the class
  GameSetupDialog(tk.Toplevel), for displaying and communicating 
  with the user.

To work with this file: Save this file as 
 
rithmo.py 

in a directory. In that directory, on the command line, start Python:

$ python

Then load the module and start the game application:

>>> import rithmo 
>>> rithmo.launch_rithmomachia_gui()

Have fun! Report bugs to wdjoyner@gmail.com please.



last modified by wdj on 2025-06-14
"""

import itertools
import tkinter as tk
from tkinter import simpledialog, messagebox, scrolledtext
import random

class Piece:
    """Base class for all game pieces."""
    def __init__(self, shape, value, color):
        self.shape = shape
        self.value = value
        self.color = color

    def __repr__(self):
        return f"{self.color[0].upper()}{self.shape}{self.value}"

    def get_potential_moves(self, pos):
        """Returns squares a piece could move to, ignoring occupation."""
        raise NotImplementedError # Subclasses must implement this if needed for captures

    def valid_moves(self, board, pos):
        """Returns a list of valid moves to EMPTY squares."""
        raise NotImplementedError # Each subclass must implement this

class Circle(Piece):
    """A Circle piece, moves one step orthogonally."""
    def __init__(self, value, color):
        super().__init__('C', value, color)

    def get_potential_moves(self, pos):
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            r2, c2 = r + dr, c + dc
            if 0 <= r2 < 8 and 0 <= c2 < 16:
                moves.append((r2, c2))
        return moves

    def valid_moves(self, board, pos):
        potential_moves = self.get_potential_moves(pos)
        return [move for move in potential_moves if board.get_piece(move) is None]

class Triangle(Piece):
    """A Triangle piece, moves two steps orthogonally."""
    def __init__(self, value, color):
        super().__init__('T', value, color)

    def get_potential_moves(self, pos):
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            moves.append((r + 2*dr, c + 2*dc))
        return moves

    def valid_moves(self, board, pos):
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            step1 = (r + dr, c + dc)
            dest = (r + 2*dr, c + 2*dc)
            if 0 <= dest[0] < 8 and 0 <= dest[1] < 16:
                if board.get_piece(step1) is None and board.get_piece(dest) is None:
                    moves.append(dest)
        return moves

class Square(Piece):
    """A Square piece, moves three steps orthogonally."""
    def __init__(self, value, color):
        super().__init__('S', value, color)

    def get_potential_moves(self, pos):
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            moves.append((r + 3*dr, c + 3*dc))
        return moves

    def valid_moves(self, board, pos):
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            step1 = (r + dr, c + dc)
            step2 = (r + 2*dr, c + 2*dc)
            dest = (r + 3*dr, c + 3*dc)
            if 0 <= dest[0] < 8 and 0 <= dest[1] < 16:
                if board.get_piece(step1) is None and board.get_piece(step2) is None and board.get_piece(dest) is None:
                    moves.append(dest)
        return moves

class Pyramid(Piece):
    """A special Pyramid piece, composed of other pieces."""
    def __init__(self, value, color, subvalues):
        super().__init__('P', value, color)
        self.subvalues = subvalues

    def get_potential_moves(self, pos):
        # Behaves like a Square for capture distance checks
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            moves.append((r + 3*dr, c + 3*dc))
        return moves

    def valid_moves(self, board, pos):
        r, c = pos
        moves = []
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            step1 = (r + dr, c + dc)
            step2 = (r + 2*dr, c + 2*dc)
            dest = (r + 3*dr, c + 3*dc)
            if 0 <= dest[0] < 8 and 0 <= dest[1] < 16:
                if board.get_piece(step1) is None and board.get_piece(step2) is None and board.get_piece(dest) is None:
                    moves.append(dest)
        return moves
    
    def lose_subpiece(self, val):
        if val in self.subvalues:
            self.subvalues.remove(val)
            self.value -= val
            return not self.subvalues
        return False

class Player:
    def __init__(self, color):
        self.color = color
        self.captures = []

    def record_capture(self, piece, capture_type):
        self.captures.append((piece, capture_type))

class Board:
    def __init__(self):
        self.matrix = [[None for _ in range(16)] for _ in range(8)]

    def get_piece(self, pos):
        if not pos: return None
        r, c = pos
        return self.matrix[r][c] if 0 <= r < 8 and 0 <= c < 16 else None

    def move_piece(self, start, end):
        sr, sc = start
        er, ec = end
        self.matrix[er][ec] = self.matrix[sr][sc]
        self.matrix[sr][sc] = None

    def remove_piece(self, pos):
        r, c = pos
        self.matrix[r][c] = None

    def all_positions(self):
        for r in range(8):
            for c in range(16):
                yield (r, c), self.matrix[r][c]

def standard_rithmomachia_setup(board):
    board.matrix = [[None for _ in range(16)] for _ in range(8)]
    white_pyramid_subvalues = [1, 4, 9, 16, 25, 36]
    white_pieces_data = [
        (Circle, 2, (5, 3)), (Circle, 4, (4, 3)), (Circle, 6, (3, 3)), (Circle, 8, (2, 3)),
        (Circle, 4, (5, 2)), (Circle, 16, (4, 2)), (Circle, 36, (3, 2)), (Circle, 64, (2, 2)),
        (Triangle, 6, (6, 2)), (Triangle, 9, (7, 2)), (Triangle, 20, (4, 1)), (Triangle, 25, (5, 1)),
        (Triangle, 42, (3, 1)), (Triangle, 49, (2, 1)), (Triangle, 72, (1, 2)), (Triangle, 81, (0, 2)),
        (Square, 15, (7, 1)), (Square, 25, (7, 0)), (Square, 45, (6, 1)), (Square, 81, (6, 0)),
        (Square, 153, (0, 1)), (Square, 169, (1, 0)), (Square, 289, (0, 0)),
        (Pyramid, sum(white_pyramid_subvalues), (1, 1), white_pyramid_subvalues)
    ]
    black_pyramid_subvalues = [16, 25, 36, 49, 64]
    black_pieces_data = [
        (Circle, 3, (2, 12)), (Circle, 5, (3, 12)), (Circle, 7, (4, 12)), (Circle, 9, (5, 12)),
        (Circle, 9, (2, 13)), (Circle, 25, (3, 13)), (Circle, 49, (4, 13)), (Circle, 81, (5, 13)),
        (Triangle, 12, (1, 13)), (Triangle, 16, (0, 13)), (Triangle, 30, (3, 14)), (Triangle, 36, (2, 14)),
        (Triangle, 56, (4, 14)), (Triangle, 64, (5, 14)), (Triangle, 90, (6, 13)), (Triangle, 100, (7, 13)),
        (Square, 28, (0, 14)), (Square, 49, (0, 15)), (Square, 66, (1, 14)), (Square, 120, (6, 14)),
        (Square, 121, (1, 15)), (Square, 225, (6, 15)), (Square, 361, (7, 15)),
        (Pyramid, sum(black_pyramid_subvalues), (7, 14), black_pyramid_subvalues)
    ]
    for PieceClass, value, pos, *extra in white_pieces_data:
        r, c = pos
        board.matrix[r][c] = PieceClass(value, 'white', *extra)
    for PieceClass, value, pos, *extra in black_pieces_data:
        r, c = pos
        board.matrix[r][c] = PieceClass(value, 'black', *extra)


class RithmomachiaGame:
    def __init__(self, ai_player_color=None, n0=12, n1=500):
        self.board = Board()
        self.players = {'white': Player('white'), 'black': Player('black')}
        self.turn_order = itertools.cycle(['white', 'black'])
        self.current_turn = next(self.turn_order)
        self.ai_player_color = ai_player_color
        self.n0 = n0
        self.n1 = n1
        standard_rithmomachia_setup(self.board)

    def advance_turn(self):
        self.current_turn = next(self.turn_order)

    def get_opponent_color(self):
        return "black" if self.current_turn == "white" else "white"

    def get_piece(self, pos):
        return self.board.get_piece(pos)

    def get_possible_captures(self, captor_pos, captor_val, target_pos):
        captures = []
        captor_piece = self.get_piece(captor_pos)
        target_piece = self.get_piece(target_pos)
        if not all([captor_piece, target_piece]): return []

        if isinstance(target_piece, Pyramid):
            for sub_val in target_piece.subvalues:
                if captor_val == sub_val and target_pos in captor_piece.get_potential_moves(pos):
                    captures.append(('subpiece equality', sub_val, None))
                path_clear, dist = self._is_path_clear_and_get_dist(captor_pos, target_pos)
                if path_clear:
                    if captor_val > 0 and sub_val > 0 and sub_val % captor_val == 0 and sub_val // captor_val == dist:
                        captures.append(('subpiece multiple', sub_val, None))
                    if sub_val > 0 and captor_val > 0 and captor_val % sub_val == 0 and captor_val // sub_val == dist:
                        captures.append(('subpiece divisor', sub_val, None))
                if target_pos in captor_piece.get_potential_moves(captor_pos):
                    for p2_pos, p2 in self.board.all_positions():
                        if p2 and p2.color == self.current_turn and p2_pos != captor_pos and target_pos in p2.get_potential_moves(p2_pos):
                            if captor_val + p2.value == sub_val:
                                captures.append(('subpiece sum', sub_val, p2_pos))
                            if abs(captor_val - p2.value) == sub_val:
                                captures.append(('subpiece difference', sub_val, p2_pos))
            if captures:
                return list(set(captures))

        if self.is_blockaded(target_pos):
            captures.append(('blockade', target_piece.value, None))
        if target_pos in captor_piece.get_potential_moves(captor_pos) and captor_val == target_piece.value:
            captures.append(('number', target_piece.value, None))
        path_clear, dist = self._is_path_clear_and_get_dist(captor_pos, target_pos)
        if path_clear:
            if captor_val > 0 and target_piece.value > 0 and target_piece.value % captor_val == 0 and target_piece.value // captor_val == dist:
                captures.append(('multiple', target_piece.value, None))
            if target_piece.value > 0 and captor_val > 0 and captor_val % target_piece.value == 0 and captor_val // target_piece.value == dist:
                captures.append(('divisor', target_piece.value, None))
        if target_pos in captor_piece.get_potential_moves(captor_pos):
            for p2_pos, p2 in self.board.all_positions():
                if p2 and p2.color == self.current_turn and p2_pos != captor_pos and target_pos in p2.get_potential_moves(p2_pos):
                    if captor_val + p2.value == target_piece.value:
                        captures.append(('sum', target_piece.value, p2_pos))
                    if abs(captor_val - p2.value) == target_piece.value:
                        captures.append(('difference', target_piece.value, p2_pos))
        return list(set(captures))
        
    def is_blockaded(self, piece_pos):
        piece = self.board.get_piece(piece_pos)
        return piece and not piece.valid_moves(self.board, piece_pos)

    def _is_path_clear_and_get_dist(self, start_pos, end_pos):
        r1, c1 = start_pos; r2, c2 = end_pos
        if r1 != r2 and c1 != c2: return False, -1
        dr = (r2 - r1) // max(1, abs(r2 - r1))
        dc = (c2 - c1) // max(1, abs(c2 - c1))
        dist = 0
        current_pos = (r1 + dr, c1 + dc)
        while current_pos != end_pos:
            if self.board.get_piece(current_pos):
                return False, -1
            dist += 1
            current_pos = (current_pos[0] + dr, current_pos[1] + dc)
        return True, dist
    
    def check_for_win(self):
        victory, details = self.check_arithmetical_victory(self.current_turn)
        if victory:
            return f"victory by arithmetical progression with {details[0]}, {details[1]}, {details[2]}!"

        victory, details = self.check_geometrical_victory(self.current_turn)
        if victory:
            return f"victory by geometrical progression with {details[0]}, {details[1]}, {details[2]}!"

        victory, details = self.check_harmonic_victory(self.current_turn)
        if victory:
            return f"victory by harmonic progression with {details[0]}, {details[1]}, {details[2]}!"

        player = self.players[self.current_turn]
        if len(player.captures) >= self.n0:
            return f"victory by body ({len(player.captures)} >= {self.n0} pieces)"
        
        total_value = sum(p.value for p, t in player.captures)
        if total_value >= self.n1:
            return f"victory by goods ({total_value} >= {self.n1} value)"
            
        return None

    def check_arithmetical_victory(self, color):
        enemy_territory_cols = range(8, 16) if color == 'white' else range(0, 8)
        
        pieces_in_territory = []
        for r in range(8):
            for c in enemy_territory_cols:
                piece = self.board.get_piece((r, c))
                if piece and piece.color == color:
                    pieces_in_territory.append(piece)

        if len(pieces_in_territory) < 3:
            return False, None

        for p1, p2, p3 in itertools.combinations(pieces_in_territory, 3):
            values = sorted([p1.value, p2.value, p3.value])
            if values[1] - values[0] == values[2] - values[1] and values[1] - values[0] > 0:
                winning_pieces = sorted([p1, p2, p3], key=lambda p: p.value)
                return True, winning_pieces

        return False, None
    
    def check_geometrical_victory(self, color):
        enemy_territory_cols = range(8, 16) if color == 'white' else range(0, 8)
        pieces_in_territory = []
        for r in range(8):
            for c in enemy_territory_cols:
                piece = self.board.get_piece((r, c))
                if piece and piece.color == color:
                    pieces_in_territory.append(piece)

        if len(pieces_in_territory) < 3:
            return False, None

        for p1, p2, p3 in itertools.combinations(pieces_in_territory, 3):
            values = sorted([p1.value, p2.value, p3.value])
            if values[0] > 0 and values[1] > values[0] and values[2] * values[0] == values[1] * values[1]:
                 winning_pieces = sorted([p1, p2, p3], key=lambda p: p.value)
                 return True, winning_pieces

        return False, None

    def check_harmonic_victory(self, color):
        enemy_territory_cols = range(8, 16) if color == 'white' else range(0, 8)
        pieces_in_territory = []
        for r in range(8):
            for c in enemy_territory_cols:
                piece = self.board.get_piece((r, c))
                if piece and piece.color == color:
                    pieces_in_territory.append(piece)

        if len(pieces_in_territory) < 3:
            return False, None

        for p1, p2, p3 in itertools.combinations(pieces_in_territory, 3):
            values = sorted([p1.value, p2.value, p3.value])
            v1, v2, v3 = values[0], values[1], values[2]
            
            if v1 <= 0 or v1 == v2 or v2 == v3:
                continue

            if v2 * (v1 + v3) == 2 * v1 * v3:
                 winning_pieces = sorted([p1, p2, p3], key=lambda p: p.value)
                 return True, winning_pieces

        return False, None

    def can_player_move(self, color):
        for pos, piece in self.board.all_positions():
            if piece and piece.color == color:
                if piece.valid_moves(self.board, pos):
                    return True
        return False

    def get_all_possible_moves(self, color):
        all_moves = []
        for pos, piece in self.board.all_positions():
            if piece and piece.color == color:
                valid_moves = piece.valid_moves(self.board, pos)
                for move in valid_moves:
                    all_moves.append((pos, move))
        return all_moves

    def process_move(self, start_pos, end_pos):
        self.board.move_piece(start_pos, end_pos)

    def process_capture(self, captor_pos, target_pos, capture_type):
        target_piece = self.board.get_piece(target_pos)
        self.players[self.current_turn].record_capture(target_piece, capture_type)
        self.board.remove_piece(target_pos)

    def process_pyramid_subpiece_capture(self, captor_pos, target_pos, value_to_remove, capture_type):
        pyramid = self.board.get_piece(target_pos)
        subpiece_as_piece = Piece('X', value_to_remove, pyramid.color)
        self.players[self.current_turn].record_capture(subpiece_as_piece, capture_type)
        if pyramid.lose_subpiece(value_to_remove):
            self.board.remove_piece(target_pos)

# --- DIALOG WINDOWS ---
class GameSetupDialog(tk.Toplevel):
    def __init__(self, parent):
        super().__init__(parent)
        self.title("Game Setup")
        self.transient(parent)
        self.grab_set()
        self.result = None
        
        mode_frame = tk.Frame(self, padx=10, pady=5)
        mode_frame.pack()
        tk.Label(mode_frame, text="Game Mode:").pack(side=tk.LEFT)
        self.mode_var = tk.StringVar(value="hvh")
        tk.Radiobutton(mode_frame, text="Human vs Human", variable=self.mode_var, value="hvh", command=self.toggle_color_choice).pack(side=tk.LEFT)
        tk.Radiobutton(mode_frame, text="Human vs Computer", variable=self.mode_var, value="hvc", command=self.toggle_color_choice).pack(side=tk.LEFT)
        
        self.color_frame = tk.Frame(self, padx=10, pady=5)
        tk.Label(self.color_frame, text="Play as:").pack(side=tk.LEFT)
        self.color_var = tk.StringVar(value="white")
        self.white_rb = tk.Radiobutton(self.color_frame, text="White", variable=self.color_var, value="white")
        self.white_rb.pack(side=tk.LEFT)
        self.black_rb = tk.Radiobutton(self.color_frame, text="Black", variable=self.color_var, value="black")
        self.black_rb.pack(side=tk.LEFT)
        self.color_frame.pack()

        victory_frame = tk.Frame(self, padx=10, pady=5)
        victory_frame.pack()
        tk.Label(victory_frame, text="Victory by Body (count):").grid(row=0, column=0, sticky='w')
        self.n0_entry = tk.Entry(victory_frame, width=5)
        self.n0_entry.insert(0, "12")
        self.n0_entry.grid(row=0, column=1)
        
        tk.Label(victory_frame, text="Victory by Goods (value):").grid(row=1, column=0, sticky='w')
        self.n1_entry = tk.Entry(victory_frame, width=5)
        self.n1_entry.insert(0, "500")
        self.n1_entry.grid(row=1, column=1)

        ok_button = tk.Button(self, text="Start Game", command=self.on_ok)
        ok_button.pack(pady=10)
        
        self.toggle_color_choice() # Set initial state
        self.wait_window(self)

    def toggle_color_choice(self):
        if self.mode_var.get() == "hvc":
            for child in self.color_frame.winfo_children():
                child.config(state=tk.NORMAL)
        else:
            for child in self.color_frame.winfo_children():
                child.config(state=tk.DISABLED)

    def on_ok(self):
        try:
            n0 = int(self.n0_entry.get())
            n1 = int(self.n1_entry.get())
        except ValueError:
            messagebox.showerror("Invalid Input", "Victory conditions must be integers.", parent=self)
            return

        self.result = {'mode': self.mode_var.get(), 'n0': n0, 'n1': n1}
        
        if self.result['mode'] == 'hvc':
            human_color = self.color_var.get()
            self.result['ai_player_color'] = 'black' if human_color == 'white' else 'white'
        else:
            self.result['ai_player_color'] = None

        self.destroy()

class SubpieceSelectDialog(tk.Toplevel):
    def __init__(self, parent, pyramid_piece):
        super().__init__(parent)
        self.title("Select Attacker")
        self.transient(parent)
        self.grab_set()
        self.result = None
        self.value_map = {}
        tk.Label(self, text="Choose which piece/value to act with:").pack(pady=10)
        self.listbox = tk.Listbox(self)
        self.listbox.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)
        whole_text = f"Whole Pyramid (Value: {pyramid_piece.value})"
        self.listbox.insert(tk.END, whole_text)
        self.value_map[whole_text] = pyramid_piece.value
        for sub_val in sorted(pyramid_piece.subvalues):
            sub_text = f"Subpiece (Value: {sub_val})"
            self.listbox.insert(tk.END, sub_text)
            self.value_map[sub_text] = sub_val
        self.listbox.selection_set(0)
        self.listbox.activate(0)
        btn_frame = tk.Frame(self)
        btn_frame.pack(pady=5)
        ok_btn = tk.Button(btn_frame, text="OK", command=self.on_ok)
        ok_btn.pack(side=tk.LEFT, padx=5)
        cancel_btn = tk.Button(btn_frame, text="Cancel", command=self.on_cancel)
        cancel_btn.pack(side=tk.LEFT, padx=5)
        self.wait_window(self)

    def on_ok(self):
        try:
            active_index = self.listbox.index(tk.ACTIVE)
            selected_text = self.listbox.get(active_index)
            self.result = self.value_map.get(selected_text)
        except (tk.TclError, IndexError):
            self.result = None
        self.destroy()

    def on_cancel(self):
        self.result = None
        self.destroy()

class CaptureChoiceDialog(tk.Toplevel):
    def __init__(self, parent, options, game):
        super().__init__(parent)
        self.title("Choose Capture")
        self.transient(parent)
        self.grab_set()
        self.result = None
        self.game = game
        self.listbox = tk.Listbox(self)
        self.listbox.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)
        for i, option in enumerate(options):
            capture_type, value, captor2_pos = option
            text = f"Capture value {value} by {capture_type}"
            if captor2_pos:
                text += f" (with {self.game.get_piece(captor2_pos)})"
            self.listbox.insert(tk.END, text)
        self.listbox.selection_set(0)
        self.listbox.activate(0)
        btn_frame = tk.Frame(self)
        btn_frame.pack(pady=5)
        ok_btn = tk.Button(btn_frame, text="OK", command=self.on_ok)
        ok_btn.pack(side=tk.LEFT, padx=5)
        cancel_btn = tk.Button(btn_frame, text="Cancel", command=self.on_cancel)
        cancel_btn.pack(side=tk.LEFT, padx=5)
        self.wait_window(self)

    def on_ok(self):
        try:
            self.result = self.listbox.index(tk.ACTIVE)
        except (tk.TclError, IndexError):
            self.result = None
        self.destroy()

    def on_cancel(self):
        self.result = None
        self.destroy()

class LogAndCaptureWindow(tk.Toplevel):
    def __init__(self, master, game):
        super().__init__(master)
        self.title("Game Log")
        self.geometry("400x600")
        self.game = game
        captures_frame = tk.Frame(self, relief=tk.GROOVE, borderwidth=2)
        captures_frame.pack(fill=tk.X, padx=5, pady=5)
        self.white_cap_label = tk.Label(captures_frame, text="White's Captures (Total: 0)")
        self.white_cap_label.pack()
        self.white_cap_list = tk.Listbox(captures_frame, height=5)
        self.white_cap_list.pack(fill=tk.X, expand=True)
        self.black_cap_label = tk.Label(captures_frame, text="Black's Captures (Total: 0)")
        self.black_cap_label.pack()
        self.black_cap_list = tk.Listbox(captures_frame, height=5)
        self.black_cap_list.pack(fill=tk.X, expand=True)
        log_frame = tk.Frame(self, relief=tk.GROOVE, borderwidth=2)
        log_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        log_label = tk.Label(log_frame, text="Game Log")
        log_label.pack()
        self.log_text = scrolledtext.ScrolledText(log_frame, state='disabled', wrap=tk.WORD)
        self.log_text.pack(fill=tk.BOTH, expand=True)

    def log_event(self, message):
        self.log_text.config(state='normal')
        self.log_text.insert(tk.END, message + '\n')
        self.log_text.config(state='disabled')
        self.log_text.see(tk.END)

    def update_captures(self):
        self.white_cap_list.delete(0, tk.END)
        white_total = 0
        for piece, cap_type in self.game.players['white'].captures:
            self.white_cap_list.insert(tk.END, f"{piece} (by {cap_type})")
            white_total += piece.value
        self.white_cap_label.config(text=f"White's Captures (Total: {white_total})")
        self.black_cap_list.delete(0, tk.END)
        black_total = 0
        for piece, cap_type in self.game.players['black'].captures:
            self.black_cap_list.insert(tk.END, f"{piece} (by {cap_type})")
            black_total += piece.value
        self.black_cap_label.config(text=f"Black's Captures (Total: {black_total})")

class HelpWindow(tk.Toplevel):
    def __init__(self, master):
        super().__init__(master)
        self.title("Rithmomachia Rules")
        self.geometry("600x600")
        rules_text = """... (rules text) ..."""
        help_text_widget = scrolledtext.ScrolledText(self, state='normal', wrap=tk.WORD, padx=10, pady=10)
        help_text_widget.insert(tk.END, rules_text)
        help_text_widget.config(state='disabled')
        help_text_widget.pack(fill=tk.BOTH, expand=True)

class RithmomachiaGUI:
    def __init__(self, root):
        self.root = root
        self.game = None
        self.selected_pos = None
        self.game_over = False
        self.turn_phase = "PRE_MOVE"

        board_frame = tk.Frame(root)
        board_frame.grid(row=0, column=0, columnspan=16)
        self._create_board_buttons(board_frame)
        self.status_label = tk.Label(root, text="", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.status_label.grid(row=1, column=0, columnspan=16, sticky='ew')
        button_frame = tk.Frame(root)
        button_frame.grid(row=2, column=0, columnspan=16, sticky='ew', pady=5)
        self.new_game_button = tk.Button(button_frame, text="New Game", command=self.setup_new_game)
        self.new_game_button.pack(side=tk.LEFT, expand=True, fill=tk.X)
        self.move_button = tk.Button(button_frame, text="Commit to Move", command=self.enter_move_phase)
        self.move_button.pack(side=tk.LEFT, expand=True, fill=tk.X)
        self.end_turn_button = tk.Button(button_frame, text="End Turn", command=self.end_turn, state=tk.DISABLED)
        self.end_turn_button.pack(side=tk.LEFT, expand=True, fill=tk.X)
        self.help_button = tk.Button(button_frame, text="Help", command=self.show_help)
        self.help_button.pack(side=tk.LEFT, expand=True, fill=tk.X)
        
        self.log_window = None # Will be created in setup_new_game
        self.root.after(100, self.setup_new_game) # Call setup on initial launch
        
    def _create_board_buttons(self, parent_frame):
        self.buttons = {}
        for r in range(8):
            for c in range(16):
                btn = tk.Button(parent_frame, text="", width=6, height=3,
                                command=lambda r=r, c=c: self.on_square_click((r, c)))
                btn.grid(row=r, column=c)
                self.buttons[(r, c)] = btn

    def update_board_display(self):
        for pos, btn in self.buttons.items():
            piece = self.game.get_piece(pos) if self.game else None
            if piece:
                text = f"{piece.shape}\n{piece.value}"
                if isinstance(piece, Pyramid):
                    text += f"\n[{','.join(map(str, sorted(piece.subvalues)))}]"
                btn.config(text=text, fg='green' if piece.color == 'white' else 'black',
                           bg='lightgrey' if piece.color == 'white' else 'gray')
            else:
                btn.config(text="", bg='#f0f0f0', fg='black')
            btn.config(relief=tk.RAISED)

    def log_event(self, message):
        if self.log_window: self.log_window.log_event(message)

    def reset_selection(self):
        self.selected_pos = None
        self.update_board_display()

    def show_help(self):
        HelpWindow(self.root)

    def on_square_click(self, clicked_pos):
        if self.game_over or not self.game or (self.game.ai_player_color and self.game.current_turn == self.game.ai_player_color):
            return

        if self.turn_phase in ["PRE_MOVE", "POST_MOVE"]:
            self.handle_capture_phase_click(clicked_pos)
        elif self.turn_phase == "MOVE":
            self.handle_move_phase_click(clicked_pos)

    def handle_capture_phase_click(self, clicked_pos):
        if not self.selected_pos:
            piece = self.game.get_piece(clicked_pos)
            if piece and piece.color == self.game.current_turn:
                self.selected_pos = clicked_pos
                self.buttons[clicked_pos].config(relief=tk.SUNKEN)
                self.status_label.config(text=f"Selected {piece}. Click an enemy piece to capture.")
            return

        start_pos = self.selected_pos
        target_piece = self.game.get_piece(clicked_pos)
        if start_pos == clicked_pos:
            self.reset_selection()
            self.status_label.config(text=f"Selection cleared. Current phase: {self.turn_phase}")
            return

        if target_piece and target_piece.color == self.game.get_opponent_color():
            if self.attempt_capture(start_pos, clicked_pos):
                self.status_label.config(text="Capture successful! You may capture another piece.")
            self.reset_selection()
        else:
            self.status_label.config(text="Invalid target. Must select an enemy piece.")
            self.reset_selection()

    def handle_move_phase_click(self, clicked_pos):
        if not self.selected_pos:
            piece = self.game.get_piece(clicked_pos)
            if piece and piece.color == self.game.current_turn:
                self.selected_pos = clicked_pos
                self.buttons[clicked_pos].config(relief=tk.SUNKEN)
                self.status_label.config(text=f"Selected {piece}. Click a valid empty square to move.")
            return
        
        start_pos = self.selected_pos
        if start_pos == clicked_pos:
             self.reset_selection()
             self.status_label.config(text="Selection cleared. You must make a move.")
             return

        target_piece = self.game.get_piece(clicked_pos)
        if not target_piece:
            moving_piece = self.game.get_piece(start_pos)
            if clicked_pos in moving_piece.valid_moves(self.game.board, start_pos):
                self.log_event(f"MOVE: {self.game.current_turn.capitalize()} moves {moving_piece} from {start_pos} to {clicked_pos}.")
                self.game.process_move(start_pos, clicked_pos)
                self.check_for_win_and_continue()
            else:
                self.status_label.config(text="Invalid move for this piece.")
        else:
            self.status_label.config(text="Invalid move. Must move to an empty square.")
            self.reset_selection()

    def attempt_capture(self, start_pos, target_pos):
        captor_piece = self.game.get_piece(start_pos)
        captor_val = captor_piece.value
        
        if isinstance(captor_piece, Pyramid):
             dialog = SubpieceSelectDialog(self.root, captor_piece)
             chosen_value = dialog.result
             if chosen_value is None: return False
             captor_val = chosen_value

        possible_captures = self.game.get_possible_captures(start_pos, captor_val, target_pos)
        
        if not possible_captures:
            self.status_label.config(text="Cannot capture. No valid capture method applies.")
            return False

        chosen_capture = None
        if len(possible_captures) > 1:
            dialog = CaptureChoiceDialog(self.root, possible_captures, self.game)
            choice_index = dialog.result
            if choice_index is not None:
                chosen_capture = possible_captures[choice_index]
            else:
                return False
        else:
            chosen_capture = possible_captures[0]

        capture_type, value, captor2_pos = chosen_capture
        is_subpiece = 'subpiece' in capture_type

        log_str = f"CAPTURE: {self.game.current_turn.capitalize()}'s {captor_piece}"
        if captor_val != captor_piece.value: log_str += f" (using subpiece {captor_val})"
        if captor2_pos: log_str += f" & {self.game.get_piece(captor2_pos)}"
        target_str = f"subpiece {value}" if is_subpiece else str(self.game.get_piece(target_pos))
        log_str += f" captures {target_str} by {capture_type}."
        self.log_event(log_str)

        if is_subpiece:
            self.game.process_pyramid_subpiece_capture(start_pos, target_pos, value, capture_type)
        else:
            self.game.process_capture(start_pos, target_pos, capture_type)
            
        self.log_window.update_captures()
        self.update_board_display()
        
        win_reason = self.game.check_for_win()
        if win_reason:
            self.handle_win(win_reason)

        return True

    def enter_move_phase(self):
        self.turn_phase = "MOVE"
        self.reset_selection()
        self.move_button.config(state=tk.DISABLED)
        self.status_label.config(text="Move Phase: Select a piece and a destination.")

    def end_turn(self):
        self.game.advance_turn()
        if not self.game.can_player_move(self.game.current_turn):
            self.handle_win(f"blockade by {self.game.get_opponent_color().capitalize()}")
        else:
            self.reset_turn_state()
            if self.game.ai_player_color and self.game.current_turn == self.game.ai_player_color:
                self.root.after(500, self.trigger_ai_move)

    def handle_win(self, reason):
        self.game_over = True
        winner = self.game.current_turn.capitalize()
        end_message = f"GAME OVER! {winner} wins by {reason}"
        self.status_label.config(text=end_message)
        self.log_event(end_message)
        messagebox.showinfo("Game Over", end_message)
        self.move_button.config(state=tk.DISABLED)
        self.end_turn_button.config(state=tk.DISABLED)

    def check_for_win_and_continue(self):
        win_reason = self.game.check_for_win()
        if win_reason:
            self.handle_win(win_reason)
            return

        self.turn_phase = "POST_MOVE"
        self.reset_selection()
        self.end_turn_button.config(state=tk.NORMAL)
        self.status_label.config(text="Move complete. You can capture more pieces now. When finished, click 'End Turn'.")

    def reset_turn_state(self):
        self.turn_phase = "PRE_MOVE"
        self.reset_selection()
        player = self.game.current_turn.capitalize()
        self.log_event(f"--- It's now {player}'s turn. ---")
        self.status_label.config(text=f"{player}'s turn. You can capture pieces now. When ready to move, click 'Commit to Move'.")
        self.move_button.config(state=tk.NORMAL)
        self.end_turn_button.config(state=tk.DISABLED)
        if self.game.ai_player_color and self.game.current_turn == self.game.ai_player_color:
            self.move_button.config(state=tk.DISABLED)

    def trigger_ai_move(self):
        all_moves = self.game.get_all_possible_moves(self.game.ai_player_color)
        if all_moves:
            start_pos, end_pos = random.choice(all_moves)
            moving_piece = self.game.get_piece(start_pos)
            self.log_event(f"AI MOVE: {self.game.current_turn.capitalize()} moves {moving_piece} from {start_pos} to {end_pos}.")
            self.game.process_move(start_pos, end_pos)
            self.update_board_display()
            
            win_reason = self.game.check_for_win()
            if win_reason:
                self.handle_win(win_reason)
                return
        
        self.end_turn()

    def setup_new_game(self):
        """Handles the logic for starting a new game."""
        setup_info = GameSetupDialog(self.root).result
        if not setup_info:
            if not self.game: # If first-time setup is cancelled, exit
                self.root.destroy()
            return

        self.game = RithmomachiaGame(
            ai_player_color=setup_info.get('ai_player_color'),
            n0=setup_info.get('n0', 12),
            n1=setup_info.get('n1', 500)
        )
        if not self.log_window:
            self.log_window = LogAndCaptureWindow(self.root, self.game)
        else:
            self.log_window.game = self.game
        
        self.log_window.update_captures()
        self.game_over = False
        
        if setup_info['mode'] == 'hvc':
            human_color = 'white' if setup_info['ai_player_color'] == 'black' else 'black'
            self.log_event(f"New Game: Human ({human_color}) vs. Computer ({setup_info['ai_player_color']}).")
        else:
            self.log_event("New Game: Human vs. Human.")
        self.log_event(f"Victory conditions: Body (n0) = {self.game.n0}, Goods (n1) = {self.game.n1}.")

        self.reset_turn_state()

        if self.game.ai_player_color == 'white':
            self.root.after(500, self.trigger_ai_move)

def launch_rithmomachia_gui():
    # FIXED: This new startup sequence prevents the GUI from hanging.
    root = tk.Tk()
    root.title("Rithmomachia")
    
    # The GUI will handle setup from this point on via the "New Game" button
    gui = RithmomachiaGUI(root)
    
    # Properly handle the window closing
    def on_closing():
        if gui.log_window and gui.log_window.winfo_exists():
            gui.log_window.destroy()
        root.destroy()
    
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()
