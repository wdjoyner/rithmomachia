"""Sage-independent contract tests for the position-analysis module."""
import io
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import position_analysis as pa


class Poly:
    def __init__(self, letter, value, parts=None):
        self.letter, self.value = letter, value
        self.parts = tuple(parts) if parts is not None else None

    def variables(self):
        if self.letter in ("P", "p"):
            return (self.letter, "S" if self.letter == "P" else "s")
        return (self.letter,)

    def degree(self):
        return self.value

    def __str__(self):
        return "%s^%d" % (self.letter, self.value)


class Board:
    def __init__(self, cells=None):
        self.cells = dict(cells or {})

    def __eq__(self, other):
        return isinstance(other, Board) and self.cells == other.cells


class Engine:
    def __init__(self):
        self.initial = Board({
            (0, 0): Poly("C", 2), (0, 1): Poly("C", 4),
            (0, 2): Poly("C", 6), (1, 1): Poly("P", 91, (1, 4, 9, 16, 25, 36)),
            (7, 15): Poly("c", 3), (7, 14): Poly("t", 12),
            (7, 13): Poly("s", 28), (6, 14): Poly("p", 190, (16, 25, 36, 49, 64))
        })
        self.patterns = {
            "white": {"arithmetical": [(2, 4, 6)], "geometrical": [], "musical": []},
            "black": {"arithmetical": [(3, 12, 21)], "geometrical": [], "musical": []}
        }
        self.completed = {}
        self.capture_counts = {}
        self.moves = {"white": [], "black": []}

    def board_initial_matrix(self, pyramid_decomposition=True):
        assert pyramid_decomposition is True
        return self.initial

    def positions_w(self, board):
        return [(pos, p) for pos, p in board.cells.items() if p.letter.isupper()]

    def positions_b(self, board):
        return [(pos, p) for pos, p in board.cells.items() if p.letter.islower()]

    def value_of_piece(self, board, row, col):
        p = board.cells[(row, col)]
        return list(p.parts) + [p.value] if p.parts is not None else [p.value]

    def _pyramid_data(self, p):
        if p.letter not in ("P", "p"):
            return None
        return ("white" if p.letter == "P" else "black", p.value, list(p.parts))

    def is_valid_move(self, board, src, dst, side):
        return (src, dst) in self.moves[side]

    def move_piece(self, board, src, dst):
        result = Board(board.cells)
        result.cells[dst] = result.cells.pop(src)
        return result

    def __getattr__(self, name):
        for side in pa.SIDES:
            for kind in ("arithmetical", "geometrical", "musical"):
                if name == "is_%s_pattern_%s" % (kind, side):
                    return lambda board, side=side, kind=kind: self.completed.get((side, kind), (False, None))
                if name == "list_%s_patterns_%s" % (kind, side):
                    return lambda side=side, kind=kind: self.patterns[side][kind]
            for method in pa.CAPTURE_METHODS:
                if name == "valid_captures_by_%s_%s" % (method, side):
                    return lambda board, side=side, method=method: [object()] * self.capture_counts.get((side, method), 0)
            for shape in ("circle", "triangle", "square", "pyramid"):
                if name == "moves_%s_%s" % (shape, side):
                    return lambda board, verbose=False, side=side, shape=shape: (self.moves[side] if shape == "circle" else [])
        raise AttributeError(name)


class EvaluationTests(unittest.TestCase):
    def setUp(self):
        self.engine = Engine()
        self.board = Board(self.engine.initial.cells)

    def test_initial_score_is_zero_despite_unequal_piece_values(self):
        report = pa.analyze_game_state(self.board, engine=self.engine)
        self.assertNotEqual(report["white_material"]["total"], report["black_material"]["total"])
        self.assertEqual(report["advantage"]["score"], 0)
        self.assertEqual(report["white_pieces"]["total"], 4)

    def test_pyramid_partial_capture_and_piece_count(self):
        self.board.cells.pop((0, 0))
        self.board.cells[(1, 1)] = Poly("P", 66, (1, 4, 9, 16, 36))
        self.assertEqual(pa.calculate_material(self.board, "white", engine=self.engine)["total"], 4 + 6 + 66)
        self.assertEqual(pa.count_pieces(self.board, "white", engine=self.engine)["total"], 3)
        self.assertLess(pa.calculate_advantage(self.board, engine=self.engine)["material_component"], 0)

    def test_territory_uses_second_coordinate(self):
        self.board.cells[(0, 8)] = self.board.cells.pop((0, 0))
        self.board.cells[(7, 7)] = self.board.cells.pop((7, 15))
        self.assertEqual(pa.territory_control(self.board, "white", engine=self.engine)["pieces_in_enemy_territory"], 1)
        self.assertEqual(pa.territory_control(self.board, "black", engine=self.engine)["pieces_in_enemy_territory"], 1)

    def test_false_tuple_is_not_treated_as_win(self):
        h = pa.check_harmony_potential(self.board, "white", engine=self.engine)
        self.assertFalse(h["complete"])
        self.assertEqual(h["potential_score"], 0)

    def test_partial_requires_two_distinct_invaders_and_remaining_piece(self):
        self.board.cells[(0, 8)] = self.board.cells.pop((0, 0))
        self.board.cells[(0, 9)] = self.board.cells.pop((0, 1))
        self.assertEqual(pa.check_harmony_potential(self.board, "white", engine=self.engine)["potential_score"], 25)
        self.board.cells.pop((0, 2))
        self.assertEqual(pa.check_harmony_potential(self.board, "white", engine=self.engine)["potential_score"], 0)

    def test_complete_pattern_is_100_not_95(self):
        self.engine.completed[("white", "arithmetical")] = ("arithmetical", ["C^2", "C^4", "C^6"])
        self.assertEqual(pa.check_harmony_potential(self.board, "white", engine=self.engine)["potential_score"], 100)

    def test_pyramid_counts_as_one_piece_in_pattern(self):
        self.board.cells[(1, 8)] = self.board.cells.pop((1, 1))
        self.engine.patterns["white"]["arithmetical"] = [(1, 4, 6)]
        self.assertEqual(pa.check_harmony_potential(self.board, "white", engine=self.engine)["potential_score"], 0)

    def test_capture_records_are_by_method_not_unique_victims(self):
        self.engine.capture_counts[("white", "numbering")] = 2
        self.engine.capture_counts[("white", "division")] = 1
        cap = pa.count_capture_opportunities(self.board, "white", engine=self.engine)
        self.assertEqual(cap["total"], 3)
        self.assertEqual(cap["by_method"]["division"], 1)
        self.assertGreater(pa.calculate_advantage(self.board, engine=self.engine)["capture_component"], 0)

    def test_rank_moves_for_both_sides(self):
        self.engine.moves["white"] = [((0, 0), (0, 8)), ((0, 1), (0, 8))]
        moves = pa.rank_moves(self.board, "white", engine=self.engine,
                              top_n=None, include_captures=False)
        self.assertEqual(len(moves), 2)
        self.assertGreater(moves[0]["score_change_for_player"], 0)
        self.engine.moves["black"] = [((7, 15), (7, 7))]
        bmoves = pa.rank_moves(self.board, "black", engine=self.engine,
                               include_captures=False)
        self.assertEqual(len(bmoves), 1)
        self.assertGreater(bmoves[0]["score_change_for_player"], 0)
        self.assertLess(bmoves[0]["score_after_white_positive"], 0)

    def test_display_and_fast_mode(self):
        stream = io.StringIO()
        report = pa.display_analysis(self.board, engine=self.engine,
                                     include_captures=False, file=stream)
        self.assertIn("POSITION ANALYSIS", stream.getvalue())
        self.assertIn("not evaluated", stream.getvalue())
        self.assertFalse(report["advantage"]["capture_score_included"])

    def test_bad_color_and_candidate_limit(self):
        with self.assertRaises(ValueError):
            pa.count_pieces(self.board, "green", engine=self.engine)
        self.engine.moves["white"] = [((0, 0), (0, 8)), ((0, 1), (0, 9))]
        self.assertEqual(len(pa.rank_moves(self.board, "white", engine=self.engine,
                                          top_n=None, max_candidates=1,
                                          include_captures=False)), 1)


if __name__ == "__main__":
    unittest.main()
