"""Sage-independent regression probes for the Rithmomachia module.

Run: python -m unittest discover -s tests -v
These isolate the revised functions with mocks; they are not full Sage tests.
"""
from pathlib import Path
from copy import copy
import ast
import io
import itertools
import tokenize
import unittest

SOURCE = Path(__file__).resolve().parents[1] / "rithmomachia.py"
MODULE = ast.parse(SOURCE.read_text(encoding="utf-8"))


def extract(name, deps):
    fn = next(x for x in MODULE.body if isinstance(x, ast.FunctionDef) and x.name == name)
    env = dict(deps)
    exec(compile(ast.Module(body=[fn], type_ignores=[]), str(SOURCE), "exec"), env)
    return env[name]


def in_bounds(x):
    return isinstance(x, (tuple,list)) and len(x) == 2 and 0 <= x[0] < 8 and 0 <= x[1] < 16


class Board:
    def __init__(self, slots=None):
        self.slots = dict(slots or {})
    def __getitem__(self, pos):
        if not in_bounds(pos):
            raise IndexError(pos)
        return self.slots.get(tuple(pos), 0)
    def __setitem__(self, pos, value):
        self.slots[tuple(pos)] = value
    def __copy__(self):
        return Board(self.slots)
    def __eq__(self, other):
        return isinstance(other, Board) and self.slots == other.slots


class Piece:
    def __init__(self, symbol, number=1):
        self.symbol, self.number = symbol, number
    def variables(self):
        return [self.symbol]
    def degree(self):
        return self.number


class CorrectnessProbes(unittest.TestCase):
    def test_python_syntax(self):
        data = SOURCE.read_text(encoding="utf-8")
        self.assertIn("from sage.all import *", data)
        operators = [t.string for t in tokenize.generate_tokens(io.StringIO(data).readline)
                     if t.type == tokenize.OP]
        self.assertNotIn("^", operators)

    def test_move_checks_exact_source(self):
        board = Board({(7, 7): Piece("C"), (2, 2): Piece("C")})
        deps = {"in_bounds": in_bounds}
        for side in ("white", "black"):
            for kind in ("circle", "triangle", "square", "pyramid"):
                deps["moves_%s_%s" % (kind, side)] = lambda *args, **kwargs: []
        deps["moves_circle_white"] = lambda *args, **kwargs: [((2, 2), (2, 3))]
        fn = extract("is_valid_move", deps)
        self.assertFalse(fn(board, (7, 7), (2, 3), "white"))
        self.assertTrue(fn(board, (2, 2), (2, 3), "white"))
        self.assertFalse(fn(board, (2, 2), (16, 3), "white"))

    def test_obstructed_triangle(self):
        board = Board({(0, 0): Piece("T"), (0, 1): Piece("c")})
        fn = extract("lands_on", {
            "in_bounds": in_bounds, "positions_w": lambda gs: [[(0, 0), gs[0, 0]]],
            "positions_b": lambda gs: [[(0, 1), gs[0, 1]]],
            "C": "C", "c": "c", "T": "T", "t": "t",
            "S": "S", "s": "s", "P": "P", "p": "p",
        })
        self.assertNotIn(((0, 0), (0, 2)), fn(board, (0, 0)))

    def test_capture_record_coordinates(self):
        fn = extract("_capture_event_from_record", {"in_bounds": in_bounds})
        self.assertEqual(fn("number", (((2, 2), [6]), ((2, 3), [6])), "white"),
                         ((2, 2), (2, 3), [6]))
        self.assertEqual(fn("sum", [((2, 2), [5]), ((3, 3), [7]), ((4, 4), [12])], "white"),
                         ((2, 2), (4, 4), [12]))
        self.assertEqual(fn("siege", ((2, 3), [6]), "white"), (None, (2, 3), None))

    def test_goods_uses_numeric_values(self):
        fn = extract("is_goods_common_victory_white",
                     {"captured_piece_values": lambda *args: [36, 64]})
        self.assertTrue(fn(object(), 100))
        self.assertFalse(fn(object(), 101))

    def test_invalid_move_rejected_before_board_indexing(self):
        board = Board({(1, 1): Piece("C")})
        fn = extract("move_piece", {
            "in_bounds": in_bounds, "copy": copy, "_piece_side": lambda p: "white",
            "is_valid_move": lambda *args: True,
            "coordinate_to_algebraic": lambda *args: "a1",
        })
        self.assertEqual(fn(board, (8, 0), (2, 2)), board)
        self.assertEqual(fn(board, (1, 1), (1, 1)), board)
        self.assertEqual(fn(board, (1, 1), (1, 2))[1, 2].symbol, "C")
        self.assertEqual(board[1, 2], 0)

    def test_black_musical_pattern_detector(self):
        board = Board({(0, 0): Piece("c", 3),
                       (0, 1): Piece("t", 5),
                       (0, 2): Piece("s", 15)})
        fn = extract("is_musical_pattern_black", {
            "positions_b": lambda gs: [((0, col), gs[0, col]) for col in range(3)],
            "list_musical_patterns_black": lambda: [(3, 5, 15)],
            "value_of_piece": lambda gs, r, c: [gs[r, c].degree()],
            "itertools": itertools,
        })
        self.assertEqual(fn(board)[0], "musical")


if __name__ == "__main__":
    unittest.main()
