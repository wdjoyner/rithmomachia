"""Integration tests of the actual CPython Rithmomachia engine.

All tests use the real board, polynomial labels, move generators, capture
functions, and evaluator. SageMath is not installed or imported.
Run with: python3 -m unittest discover -s tests -v
"""
from copy import copy
import unittest
import rithmomachia as r
import position_analysis as pa


class PurePythonIntegration(unittest.TestCase):
    def setUp(self):
        self.board = r.board_initial_matrix(pyramid_decomposition=True)

    def test_opening_board_and_score(self):
        self.assertEqual((self.board.nrows(), self.board.ncols()), (8, 16))
        self.assertEqual((len(r.positions_w(self.board)), len(r.positions_b(self.board))),
                         (24, 24))
        self.assertEqual(pa.calculate_material(self.board, "white")["total"], 1312)
        self.assertEqual(pa.calculate_advantage(self.board)["score"], 0.0)

    def test_symbolic_piece_arithmetic(self):
        self.assertEqual(r.S**36 + r.S**25, r.S**25 + r.S**36)
        poly = r.S**36 + r.P**91
        self.assertEqual(set(poly.variables()), {r.S, r.P})
        self.assertEqual(poly.degree(r.P), 91)
        self.assertEqual(poly.degree(), 91)
        self.assertTrue(all(len(powers) == 8 for powers in poly.exponents()))

    def test_pyramid_values(self):
        self.assertEqual(r.value_of_piece(self.board, 1, 1),
                         [1, 4, 9, 16, 25, 36])
        self.assertEqual(r.value_of_piece(r.board_initial_matrix(), 1, 1), [91])
        self.assertEqual(r._pyramid_data(self.board[1, 1]),
                         ("white", 91, [1, 4, 9, 16, 25, 36]))

    def test_legal_opening_move_does_not_mutate_source(self):
        self.assertTrue(r.is_valid_move(self.board, (6, 0), (3, 0), "white"))
        self.assertFalse(r.is_valid_move(self.board, (6, 0), (6, 5), "white"))
        moved = r.move_piece(self.board, (6, 0), (3, 0))
        self.assertNotEqual(moved, self.board)
        self.assertEqual(moved[3, 0], r.S**81)
        self.assertEqual(self.board[3, 0], 0)
        self.assertEqual(self.board[6, 0], r.S**81)
        self.assertEqual(len(r.legal_moves_captures_white(self.board)[0]), 12)
        self.assertEqual(len(r.legal_moves_captures_black(self.board)[0]), 12)

    def test_arithmetic_catalog_excludes_spurious_pyramid_marker(self):
        catalog = r.list_arithmetical_patterns_white()
        self.assertEqual(len(catalog), 11)
        self.assertNotIn((1, 8, 15), catalog)

    def test_arithmetic_progression_white(self):
        board = copy(self.board)
        board[5, 3] = board[4, 3] = board[3, 3] = 0
        board[0, 8], board[3, 8], board[6, 8] = r.C**2, r.C**4, r.C**6
        self.assertEqual(r.is_arithmetical_pattern_white(board)[0], "arithmetical")
        self.assertEqual(pa.check_harmony_potential(board, "white")["potential_score"], 100)

    def test_numbering_capture_white(self):
        board = copy(self.board)
        board[3, 2] = 0
        board[2, 15] = r.C**36
        self.assertEqual(len(r.valid_captures_by_numbering_white(board)), 1)
        after = r.take_all_captures_white(board)
        self.assertEqual(after[2, 14], 0)
        self.assertEqual(board[2, 14], r.t**36)
        self.assertIn(36, r.captured_piece_values(after, "black"))

    def test_partial_pyramid_capture(self):
        board = copy(self.board)
        board[1, 2] = r.c**25
        after = r.capture_piece(board, (1, 2), (1, 1),
                                captured_value=25, capture_type="number")
        self.assertEqual(r._pyramid_data(after[1, 1]),
                         ("white", 66, [1, 4, 9, 16, 36]))
        self.assertIn(25, r.captured_piece_values(after, "white"))
        self.assertEqual(r._pyramid_data(board[1, 1])[1], 91)

    def test_full_position_analysis_and_ranked_moves(self):
        report = pa.analyze_game_state(self.board)
        self.assertEqual(report["white_pieces"]["total"], 24)
        self.assertEqual(report["black_pieces"]["total"], 24)
        ranked = pa.rank_moves(self.board, "white", top_n=3,
                               include_captures=False)
        self.assertEqual(len(ranked), 3)
        self.assertTrue(all("score_change_for_player" in entry for entry in ranked))

    def test_board_graphics_available_without_sage(self):
        self.assertGreater(len(r.board_plot(self.board).primitives), 100)


if __name__ == "__main__":
    unittest.main()
