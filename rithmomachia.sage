"""
Programs to play and visualize Rithmomachia according to the rules descriibed by
Claude de Boissiere (1556).

The defaults here are:
(1)  for the circles to move orthogonally,
(2) for the pyramids to be decomposed using only squares.


On (1): The case where the players have decided to allow circles to 
        move diagonally is included as well, but may require some 
        tweeking with the programs: the functions
        moves_circle_white2/black2 have t0 be swapped with
        moves_circle_white/black.
        CIRCLE_MOVE_ORTHOGONAL = True

On (2): We follow de Boissitre's treatement here for the pyramid pieces
        (as explained in Richards, 1946).
        PYRAMID_DECOMPOSITION_SQUARES_ONLY = True

Notation for captures:
* captures (except for siege) = [list/tuples of triples of friendly pieces attacking an enemy piece, 
  triple for enemy captured piece]
* each triple in this list has the form [(pc_x, pc_y), val_pc, poly_pc], where 
  pc_x    -- the x-coordinate of the coordinate position of the piece on the game board (0 <= pc_x <= 7), 
  pc_y    -- the y-coordinate of the coordinate position of the piece on the game board (0 <= pc_y <= 15), 
  val_pc  -- the value of the piece
  poly_pc -- the polynomial rep of the piece (including the pyramid)
* two examples: 
                 (loc_pc, val_pc, poly_pc) = ((3, 3), 6, C^6)
                 (loc_pc, val_pc, poly_pc) = ((1, 1), 91, P+S^1+S^4+S^9+S^(16)+S^{25)+S^(36))
* One option:
   ** the first (friendlies) list is empty for siege, a singleton for captures by numbering, otherwise, 
      they could be lists of length 2.
   ** the first list could be the data for any (friendly) attacking piece involved in the capture,
      for example, it could be the attacking piece that was moved last.
* See c1, c2, c3, c4, c5, c6 in take_all_captures_black (below) for details on the format of 
  the capture notation.
  
ANOTHER NOTATION for captures:
 * The pieces can be dictionaries:
    piece = {"color": "even"/"odd",
             "shape": "circle"/"triangle","square"/"pyramid",
             "value": v,
	     "algebraic": "C^2"/"c^3"/.../"P+<subpieces>",
	     "position": (x,y)}
    Of course, a piece can also be represented as a 5-list, where each component is represented as above.
 * The capture dictionary is similar:  
    capture = {"friendly_piece": piece1, ######## this is the capturing/attacking piece (or one of them)
               "enemy_piece": piece2, ######## this is the captured/attacked piece (one per capture)
	       "capture_type": "number"/"sum"/"difference"/"product"/"divisor"/"siege",
	       "pre_move_capture":True/False,
	       "post_move_capture":True/False}
    where the dictionary structure for piece1, piece2 are as described above (but of opposite "color,"
    of course).

YET Another Notation for captures:
* a capture is a quintuple/5-element list of the form 

                          [(pc_x, pc_y), val_pc, poly_pc, type, pre_or_post], 

  where 

  pc_x         -- the x-coordinate of the coordinate position of the piece on the game board (0 <= pc_x <= 7), 
  pc_y         -- the y-coordinate of the coordinate position of the piece on the game board (0 <= pc_y <= 15), 
  val_pc       -- the value of the piece
  poly_pc      -- the polynomial rep of the piece (including the pyramid)
  type         -- the (string representing the) type of capture, so one of 
                  "number"/"sum"/"difference"/"product"/"divisor"/"siege"
                  (if more precision is needed, they can be combined, such as 
                   "number/product" is reasonable in some cases)
  pre_or_post  -- the (string representing the) time of capture, 
                  = "pre" if the capture was performed before the move, 
                  = "post" if the capture was performed after the move (default).



Current programs:


****** plotting
* triangle_b(pt, s)
* triangle_w(pt, s)
* square_w(pt, s)
* square_w(pt, s) 
* board_initial_plot(vertical=False)   ###### use board_plot or board_plot2 instead
* pyramid_b_simple(pt, s)
* pyramid_w_simple(pt, s)
* board_plot(game_state, pyramid=True)      ## best in general
* board_plot2(game_state, vertical=False)   ## original, older code
* display_board_matplotlib(game_state_sage_matrix)
* capture_list_to_animation(game_state, capture_list) ## not the best name, as it doesn't produce an animation
* turn_to_animation(game_state, precapture_list, move, postcapture_list, color="even", turn_number=1, frame_counter=0)

****** game states
* board_initial_matrix(pyramid_decomposition = False)
* random_board_state(verbose=False)
* captured_pieces_black(game_state, pyramid_decomposition=True)
* captured_pieces_white(game_state, pyramid_decomposition=True)
* capture_piece(game_state, capturing_pc_value, captured_pos, verbose=False)     ## changes game state
* take_all_captures_black(game_state, verbose = False)                    ## changes game state
* take_all_captures_white(game_state, verbose = False)                    ## changes game state
* move_piece(game_state, start_pos, end_pos, verbose = False)            ## changes game state
* circle_positions_white(GS, verbose = False)
* circle_positions_black(GS, verbose = False)
* triangle_positions_white(GS, verbose = False)
* triangle_positions_black(GS, verbose = False)
* square_positions_white(GS, verbose = False)
* square_positions_black(GS, verbose = False)
* pyramid_positions_white(GS, verbose = False)
* positions_b(GS)
* positions_w(GS)
* value_of_piece(GS, i, j)
* piece_values_list_white()
* piece_values_list_black()
* piece_values_matrix_white()
* piece_values_matrix_black()
* rank_state_black(GS)
* rank_state_white(GS)
* order_moves_state_black(game_state, verbose = False)
* order_moves_state_white(game_state, verbose = False)
* black_pieces()
* white_pieces()
* rithmomachia_command_line()   ################## play a game

+++++ moves
* moves_circle_white(GS, verbose = False)
* moves_circle_black(GS, verbose = False)
* moves_circle_white2(GS, verbose = False)   ## only use if CIRCLE_MOVE_DIAGONAL = True
* moves_circle_black2(GS, verbose = False)   ## only use if CIRCLE_MOVE_DIAGONAL = True
* moves_triangle_white(GS, verbose = False)
* moves_triangle_black(GS, verbose = False)
* moves_square_white(GS, verbose = False)
* moves_square_black(GS, verbose = False)
* moves_pyramid_white(GS, verbose = False)   ## modified so that PYRAMID_DECOMPOSITION_SQUARES_ONLY = True
* moves_pyramid_black(GS, verbose = False)   ## modified so that PYRAMID_DECOMPOSITION_SQUARES_ONLY = True
* moves_pyramid_white2(GS, verbose = False)   ## only use if PYRAMID_DECOMPOSITION_SQUARES_ONLY = False
* moves_pyramid_black2(GS, verbose = False)   ## only use if PYRAMID_DECOMPOSITION_SQUARES_ONLY = False
* is_valid_move(game_state, start_pos, end_pos, player_turn)
* lands_on(game_state, pc, verbose=False)
* find_best_move_black(GS)
* find_best_move_white(GS)
* play_a_game(game_state, my_color, verbose = False)   
* play_human_vs_computer_round(gs_before_human_action, history_list, human_action_algebraic, verbose = False)
* blacks_turn(game_state, method_best = Tru)                                           ## changes game state
* whites_turn(game_state, method_best = True)                                      ## changes game state
* good_move_white(game_state, verbose = False)
* good_move_black(game_state, verbose = False)
* make_good_move_black(game_state, verbose = False)
* make_good_move_white(game_state, verbose = False)

+++++ captures
################################################ chain captures are not tested or performed ############
* valid_captures_by_numbering_white(game_state)
** captures_circle_white(GS, verbose = False)   
** captures_triangle_white(GS, verbose = False)
** captures_square_white(GS, verbose = False)
** captures_pyramid_white(GS, verbose = False) ###  PYRAMID_DECOMPOSITION_SQUARES_ONLY = True
* valid_captures_by_numbering_black(game_state)
** captures_circle_black(GS, verbose = False)   
** captures_triangle_black(GS, verbose = False)
** captures_square_black(GS, verbose = False)
** captures_pyramid_black(GS, verbose = False) ###  PYRAMID_DECOMPOSITION_SQUARES_ONLY = True
* valid_captures_by_addition_white(game_state, verbose = False)
* valid_captures_by_addition_black(game_state, verbose = False)
* valid_captures_by_subtraction_white(game_state, verbose = False)
* valid_captures_by_subtraction_black(game_state, verbose = False)
* valid_captures_by_multiplication_white(game_state, verbose = False) ## gemini's improved version
* valid_captures_by_multiplication_black(game_state, verbose = False)
* valid_captures_by_division_white(game_state, verbose = False)
* valid_captures_by_division_black(game_state, verbose = False)
* valid_captures_by_siege_white(game_state, verbose = False)
* valid_captures_by_siege_black(game_state, verbose = False)
* legal_moves_captures_white(GS)
* legal_moves_captures_black(GS)
* black_takes_white_by_numbering()
* white_takes_black_by_numbering()
* white_takes_black_by_addition()
* black_takes_white_by_addition()
* white_takes_black_by_subtraction()
* black_takes_white_by_subtraction()
* black_takes_white_by_multiplication()
* white_takes_black_by_multiplication()
* black_takes_white_by_division()
* white_takes_black_by_division()

+++++ victory
* is_body_common_victory_black(game_state, N0 = 4)              
* is_body_common_victory_white(game_state, N0 = 4)  
* is_goods_common_victory_black(game_state, N1 = 100)       
* is_goods_common_victory_white(game_state, N1 = 100)                
* list_arithmetical_patterns_white0()                           ### initializes, for faster play
* list_geometrical_patterns_white0()                           ### initializes, for faster play
* list_musical_patterns_white0()                                ### initializes, for faster play
* list_arithmetical_patterns_white()
* list_geometrical_patterns_white()
* list_musical_patterns_white()
* list_arithmetical_patterns_black0()                        ### initializes, for faster play
* list_geometrical_patterns_black0()                        ### initializes, for faster play
* list_musical_patterns_black0()                            ### initializes, for faster play
* list_arithmetical_patterns_black()
* list_geometrical_patterns_black()
* list_musical_patterns_black()
* is_arithmetical_pattern_white(GS, verbose = False)         ## works
* is_arithmetical_pattern_black(GS, verbose = False)
* is_geometrical_pattern_white(GS, verbose = False)
* is_geometrical_pattern_black(GS, verbose = False)
* is_musical_pattern_white(GS, verbose = False)                                ### rarely True
* is_harmonic_pattern_white(GS, verbose = False)                                ### rarely True
* is_musical_pattern_black(game_state, in_a_line = False, verbose = False)     ### never True
* is_harmonic_pattern_black(game_state, in_a_line = False, verbose = False)     ### never True
* is_small_proper_victory_black(game_state)                                 
* is_small_proper_victory_white(game_state)

+++++ utilities
* in_bounds(x)
* select_from_a_list_random(L, n)
* common_elements(list1, list2)  ## not needed?
* is_in_a_line(pc0, pc1, pc2)
* game_state_to_latex_board(GS)
* parity_check(wpc, wpc_pos, bpc, bpc_pos)
* piece_list_to_latex(pc_list, verbose = False)
** piece_list_to_game_state(pc_list, verbose = False)
** shape_value(game_state, i, j, fancy = False)
* algebraic_to_coordinate(alg_coord)
* coordinate_to_algebraic(x, y)
* get_algebraic_move_string(game_state, start_pos, end_pos)
* get_piece_details_from_poly(poly_piece, default_color_w='green', default_color_b='red')
* game_state_to_piece_list(game_state)
* pieces_in_a_line(game_state, pc1, pc2)
* draw_big_square(piece_value = "49", piece_color = "black")
* draw_big_triangle(piece_value = "49", piece_color = "black")
* draw_big_circle(piece_value = "49", piece_color = "black")
* create_styled_shape(word, cntr=(0,0), scl=1, type="square", color_scheme="white", brdr_color="blue", font_size = 50)
** black_triangles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** black_triangles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** white_triangles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** white_triangles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** black_circles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** black_circles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** white_circles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** white_circles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** black_squares_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** black_squares_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** white_squares_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
** white_squares_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50)
* move_capture_lists_to_latex_table(even_moves, even_captures, odd_moves, odd_captures)
* center_of_gravity(game_state, piece_color = "Odd", by_rank = False)
* coordinating_progression_count(v, color="white")
** coordinating_progression_count_odd(v)
** coordinating_progression_count_even(v)
* even_piece_values()
* odd_piece_values()
* coordinating_progression_pair_count(v1, v2, color="white")
** coordinating_progression_pair_count_even(v1, v2)
** coordinating_progression_pair_count_odd(v1, v2)
* captures_as_dict(game_state, verbose = False)
* reformat_capture_for_animation(capture_data, gs)    ## helper function for turn_to_animation, animate_full_game
* format_capture_for_log(capture_data, gs)            ## helper function for animate_full_game

REFERENCES:
 [Ri46] J.F.C. Richards, Boissiere’s Pythagorean game, Scripta Mathematica 12(1946)177-217.

last modified by wdj on 2025-07-06
"""

from collections import Counter
import itertools
import string
import random 
import matplotlib.pyplot as plt
import matplotlib.patches as patches
#from sage.all import var, ZZ, Integer
import numpy as np
import sys

############### unused global constants #############
CIRCLE_MOVE_DIAGONAL = False
CIRCLE_MOVE_ORTHOGONAL = True
PYRAMID_DECOMPOSITION_SQUARES_ONLY = True
#####################################################

if sys.platform=="darwin":
    SAGE_DIR = "/Users/davidjoyner/sagefiles/"        ###############   on a mac
else:
    SAGE_DIR = "/home/wdjoyner/sagefiles/"             ###############  on linux
    
numpy_pi = 3.14159265358979          #######  replaces the call to numpy.pi

######################## plots ######################


def circle_w(pt, s, textcolor="green"):
    """
    Plots circle or radius 1/2 centered at pt = (a,b) with 
    string s printed inside

    EXAMPLES:
        sage: circle_w((0,0), "81")
         Launched png viewer for Graphics object consisting of 2 graphics primitives


    """
    mysize = "large" ### or = 'xx-large'
    T = text(s, pt, fontsize = mysize, fontweight='bold', color = textcolor, axes=False)
    C = circle(pt, 1/2, fill = True, thickness=2, edgecolor="black", facecolor="white", alpha = 0.3, axes = False)
    return T+C

def triangle_w(pt, s, textcolor="green"):
    """
    Plots equilateral triangle centered at pt = (a,b) of
     "radius" 1/2 with string s printed inside

    EXAMPLES:
        sage: triangle_w((0,0), "81", textcolor="red")
         Launched png viewer for Graphics object consisting of 2 graphics primitives

    """
    mysize = "large" ### or = 'xx-large'
    a = QQ(pt[0])
    b = QQ(pt[1])
    T = text(s, (a,b), fontsize = mysize, fontweight='bold', color = textcolor, axes=False)
    P = polygon([(a-1/2,b-1/2), (a+1/2, b-1/2), (a, b+1/2)], fill=True, edgecolor="black", rgbcolor="white", alpha = 0.5, axes=False)
    return P+T
    
def square_w(pt, s, textcolor="green"):
    """
    Plots unit square centered at pt = (a,b) of
     "radius" 1/2 with string s printed inside              ############# edit starting here 

    """
    mysize = "large" ### or = 'xx-large'
    a = QQ(pt[0])
    b = QQ(pt[1])
    T = text(s, (a,b), fontsize = mysize, fontweight='bold', color = textcolor, axes=False)
    P = polygon([(a-1/2,b-1/2), (a+1/2, b-1/2), (a+1/2, b+1/2), (a-1/2, b+1/2)], thickness=2, fill=True, edgecolor="black", rgbcolor="white", alpha = 0.5, axes=False)
    return T+P
    
def circle_b(pt, s, textcolor="red"):
    """
    Plots circle or radius 1/2 centered at pt = (a,b) with 
    string s printed inside

    EXAMPLES:
        sage: circle_b((0,0), "81")
         Launched png viewer for Graphics object consisting of 2 graphics primitives


    """
    mysize = "large" ### or = 'xx-large'
    T = text(s, pt, fontsize = mysize, fontweight='bold', color = textcolor, axes=False)
    C = circle(pt, 1/2, fill = True, thickness=2, edgecolor="black", rgbcolor="gray", alpha = 0.3, axes = False)
    return T+C
    
def triangle_b(pt, s, textcolor="red"):
    """
    Plots gray equilateral triangle centered at pt = (a,b) of
     "radius" 1/2 with string s printed inside

    """
    mysize = "large" ### or = 'xx-large'
    a = QQ(pt[0])
    b = QQ(pt[1])
    T = text(s, (a,b), fontsize = mysize, fontweight='bold', color = textcolor, axes=False)
    return T+polygon([(a-1/2,b-1/2), (a+1/2, b-1/2), (a, b+1/2)], fill=True, edgecolor="black", rgbcolor="gray", alpha = 0.5, axes=False)
    
def square_b(pt, s, textcolor="red"):
    """
    Plots gray unit square centered at pt = (a,b) of
     "radius" 1/2 with string s printed inside

    """
    mysize = "large" ### or = 'xx-large'
    a = QQ(pt[0])
    b = QQ(pt[1])
    T = text(s, (a,b), fontsize = mysize, fontweight='bold', color = textcolor, axes=False)
    return T+polygon([(a-1/2,b-1/2), (a+1/2, b-1/2), (a+1/2, b+1/2), (a-1/2, b+1/2)], fill=True, thickness=2, edgecolor="black", rgbcolor="gray", alpha = 0.5, axes=False)
    
def board_initial_plot(vertical=False):
    """
    returns the plot of the 8x16 board and the pieces in their intial position.

    EXAMPLES:
        sage: board_initial_plot(vertical=False)
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        sage: board_initial_plot(vertical=True)
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        
    """
    if not(vertical):
        plot_verlist = [line([(i + 0.5, -0.5), (i + 0.5, 7.5)], color="black", axes=False) for i in range(-1,16)]
        plot_horlist = [line([(-0.5, j+ 0.5), (15.5, j + 0.5)], color="black", axes=False) for j in range(-1,8)]
        ver_lines  = sum(plot_verlist)
        hor_lines  = sum(plot_horlist)
        white_pieces_init_pos_circles = [["C", 2, (3, 2)], ["C", 4, (3, 3)], ["C", 6, (3, 4)], ["C", 8, (3, 5)],["C", 4, (2, 2)], ["C", 16, (2, 3)], ["C", 36, (2, 4)], ["C", 64, (2, 5)]]
        white_pieces_init_pos_triangles = [["T", 25, (1, 2)], ["T", 20, (1, 3)], ["T", 42, (1, 4)], ["T", 49, (1, 5)], ["T", 9, (2, 0)], ["T", 6, (2, 1)], ["T", 72, (2, 6)], ["T", 81, (2, 7)]]
        white_pieces_init_pos_squares = [["S", 15, (1, 0)], ["S", 45, (1, 1)], ["S", 91, (1, 6)], ["S", 153, (1, 7)], ["S", 25, (0, 0)], ["S", 81, (0, 1)], ["S", 169, (0, 6)], ["S", 289, (0, 7)]]
        white_pieces_init_pos_pyramid = [["P", 91, (1, 6)]]
        black_pieces_init_pos_circles = [["c", 3, (12, 5)], ["c", 5, (12, 4)], ["c", 7, (12, 3)], ["c", 9, (12, 2)],["c", 9, (13, 5)], ["c", 25, (13, 4)], ["c", 49, (13, 3)], ["c", 81, (13, 2)]]
        black_pieces_init_pos_triangles = [["t", 36, (14, 5)], ["t", 30, (14, 4)], ["t", 56, (14, 3)], ["t", 64, (14, 2)], ["t", 16, (13, 7)], ["t", 12, (13, 6)], ["t", 90, (13, 1)], ["t", 100, (13, 0)]]
        black_pieces_init_pos_squares = [["s", 28, (14, 7)], ["s", 66, (14, 6)], ["s", 120, (14, 1)], ["s", 190, (14, 0)], ["s", 49, (15, 7)], ["s", 121, (15, 6)], ["s", 225, (15, 1)], ["s", 361, (15, 0)]]
        black_pieces_init_pos_pyramid = [["p", 190, (14, 0)]]
        white_pieces_init_pos = white_pieces_init_pos_circles + white_pieces_init_pos_triangles + white_pieces_init_pos_squares
        black_pieces_init_pos = black_pieces_init_pos_circles + black_pieces_init_pos_triangles + black_pieces_init_pos_squares
        white_pieces = sum([circle_w(x[2], str(x[1])) for x in white_pieces_init_pos_circles]) + sum([triangle_w(x[2], str(x[1]))+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_triangles]) + sum([square_w(x[2], str(x[1]))+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_squares])
        black_pieces = sum([circle(x[2], 1/2, edgecolor="black", fill=true, rgbcolor="gray", alpha = 0.5, axes = False)+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_circles]) + sum([triangle_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_triangles]) + sum([square_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_squares])
        return (white_pieces+black_pieces+ver_lines+hor_lines)
    else: # if vertical=True
        plot_verlist2 = [line([(-0.5, i + 0.5), (7.5, i + 0.5)], color="black", axes=False) for i in range(-1,16)]
        plot_horlist2 = [line([(j+ 0.5, -0.5), (j + 0.5, 15.5)], color="black", axes=False) for j in range(-1,8)]
        ver_lines2  = sum(plot_verlist2)
        hor_lines2  = sum(plot_horlist2)
        white_pieces_init_pos_circles2 = [["C", 2, (2, 3)], ["C", 4, (3, 3)], ["C", 6, (4, 3)], ["C", 8, (5, 3)],["C", 4, (2, 2)], ["C", 16, (3, 2)], ["C", 36, (4, 2)], ["C", 64, (5, 2)]]
        white_pieces_init_pos_triangles2 = [["T", 25, (2, 1)], ["T", 20, (3, 1)], ["T", 42, (4, 1)], ["T", 49, (5, 1)], ["T", 9, (0, 2)], ["T", 6, (1, 2)], ["T", 72, (6, 2)], ["T", 81, (7, 2)]]
        white_pieces_init_pos_squares2 = [["S", 15, (1, 0)], ["S", 45, (1, 1)], ["S", 91, (6, 1)], ["S", 153, (7, 1)], ["S", 25, (0, 0)], ["S", 81, (0, 1)], ["S", 169, (6, 0)], ["S", 289, (7, 0)]]
        black_pieces_init_pos_circles2 = [["c", 3, (5, 12)], ["c", 5, (4, 12)], ["c", 7, (3, 12)], ["c", 9, (2, 12)], ["c", 9, (5, 13)], ["c", 25, (4, 13)], ["c", 49, (3, 13)], ["c", 81, (2, 13)]]
        black_pieces_init_pos_triangles2 = [["t", 36, (5, 14)], ["t", 30, (4, 14)], ["t", 56, (3, 14)], ["t", 64, (2, 14)], ["t", 16, (7, 13)], ["t", 12, (6, 13)], ["t", 90, (1, 13)], ["t", 100, (0, 13)]]
        black_pieces_init_pos_squares2 = [["s", 28, (7, 14)], ["s", 66, (6, 14)], ["s", 120, (1, 14)], ["s", 190, (0, 14)], ["s", 49, (7, 15)], ["s", 121, (6, 15)], ["s", 225, (1, 15)], ["s", 361, (0, 15)]]
        white_pieces_init_pos2 = white_pieces_init_pos_circles2 + white_pieces_init_pos_triangles2 + white_pieces_init_pos_squares2
        black_pieces_init_pos2 = black_pieces_init_pos_circles2 + black_pieces_init_pos_triangles2 + black_pieces_init_pos_squares2
        white_pieces2 = sum([circle(x[2], 1/2, color="black", axes = False) + text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_circles2]) + sum([triangle_w(x[2], str(x[1])) + text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_triangles2]) + sum([square_w(x[2], str(x[1])) + text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_squares2])
        black_pieces2 = sum([circle(x[2], 1/2, edgecolor="black", fill=True, rgbcolor="gray", alpha = 0.5, axes = False) + text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_circles2]) + sum([triangle_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_triangles2]) + sum([square_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_squares2])
        return (white_pieces2+black_pieces2+ver_lines2+hor_lines2)

def board_plot2(game_state, vertical=False): ################################### older version of code - board_plot is better
    """
    returns the plot of the 8x16 board and the pieces in the game_state.

    EXAMPLES:
        sage: GS = board_initial_matrix()
         <8x16 matrix game state omitted>
        sage: is_valid_move(GS, (6, 0), (3, 0), "white")
        Valid move of a white square.
        True
        sage: board_plot(GS)          ## initial game state
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        sage: GS = move_piece(GS, (6, 0), (3, 0))
        sage: board_plot(GS)         ## resulting game state after S15:(6, 0)-(3, 0)
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        sage: GS = board_initial_matrix()
        sage: board_plot(GS, vertical=True)
        Launched png viewer for Graphics object consisting of 154 graphics primitives

    """
    GS = copy(game_state)
    if not(vertical):
        plot_verlist = [line([(i + 0.5, -0.5), (i + 0.5, 7.5)], color="black", axes=False) for i in range(-1,16)]
        plot_horlist = [line([(-0.5, j+ 0.5), (15.5, j + 0.5)], color="black", axes=False) for j in range(-1,8)]
        ver_lines  = sum(plot_verlist)
        hor_lines  = sum(plot_horlist)
        pos_w = positions_w(GS, verbose = True)
        pos_b = positions_b(GS, verbose = True)
        white_pieces_init_pos_circles = [["C", x[1].degree(), (x[0][2], x[0][1])] for x in pos_w if (x[1] != 0) and (C in x[1].variables())]
        white_pieces_init_pos_triangles = [["T", x[1].degree(), (x[0][2], x[0][1])] for x in pos_w if (x[1] != 0) and (T in x[1].variables())]
        white_pieces_init_pos_squares = [["S", x[1].degree(), (x[0][2], x[0][1])] for x in pos_w if (x[1] != 0) and (S in x[1].variables())]
        black_pieces_init_pos_circles = [["c", x[1].degree(), (x[0][2], x[0][1])] for x in pos_b if (x[1] != 0) and (c in x[1].variables())]
        black_pieces_init_pos_triangles = [["t", x[1].degree(), (x[0][2], x[0][1])] for x in pos_b if (x[1] != 0) and (t in x[1].variables())]
        black_pieces_init_pos_squares = [["s", x[1].degree(), (x[0][2], x[0][1])] for x in pos_b if (x[1] != 0) and (s in x[1].variables())]
        white_pieces_init_pos = white_pieces_init_pos_circles + white_pieces_init_pos_triangles + white_pieces_init_pos_squares
        black_pieces_init_pos = black_pieces_init_pos_circles + black_pieces_init_pos_triangles + black_pieces_init_pos_squares
        white_pieces = sum([circle_w(x[2], str(x[1])) for x in white_pieces_init_pos_circles]) + sum([triangle_w(x[2], str(x[1]))+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_triangles]) + sum([square_w(x[2], str(x[1]))+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_squares])
        black_pieces = sum([circle_b(x[2], str(x[1])) for x in black_pieces_init_pos_circles]) + sum([triangle_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_triangles]) + sum([square_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_squares])
        return (white_pieces + black_pieces + ver_lines + hor_lines)
    else: # if vertical = True
        plot_verlist2 = [line([(-0.5, i + 0.5), (7.5, i + 0.5)], color="black", axes=False) for i in range(-1,16)]
        plot_horlist2 = [line([(j+ 0.5, -0.5), (j + 0.5, 15.5)], color="black", axes=False) for j in range(-1,8)]
        ver_lines2  = sum(plot_verlist2)
        hor_lines2  = sum(plot_horlist2)
        pos_w = positions_w(GS, verbose = True)
        pos_b = positions_b(GS, verbose = True)
        white_pieces_init_pos_circles2 = [["C", x[1].degree(), (x[0][1], x[0][2])] for x in pos_w if (x[1] != 0) and (C in x[1].variables())]
        white_pieces_init_pos_triangles2 = [["T", x[1].degree(), (x[0][1], x[0][2])] for x in pos_w if (x[1] != 0) and (T in x[1].variables())]
        white_pieces_init_pos_squares2 = [["S", x[1].degree(), (x[0][1], x[0][2])] for x in pos_w if (x[1] != 0) and (S in x[1].variables())]
        black_pieces_init_pos_circles2 = [["c", x[1].degree(), (x[0][1], x[0][2])] for x in pos_b if (x[1] != 0) and (c in x[1].variables())]
        black_pieces_init_pos_triangles2 = [["t", x[1].degree(), (x[0][1], x[0][2])] for x in pos_b if (x[1] != 0) and (t in x[1].variables())]
        black_pieces_init_pos_squares2 = [["s", x[1].degree(), (x[0][1], x[0][2])] for x in pos_b if (x[1] != 0) and (s in x[1].variables())]
        white_pieces_init_pos2 = white_pieces_init_pos_circles2 + white_pieces_init_pos_triangles2 + white_pieces_init_pos_squares2
        black_pieces_init_pos2 = black_pieces_init_pos_circles2 + black_pieces_init_pos_triangles2 + black_pieces_init_pos_squares2
        white_pieces2 = sum([circle(x[2], 1/2, color="black", axes = False)+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_circles2]) + sum([triangle_w(x[2], str(x[1]))+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_triangles2]) + sum([square_w(x[2], str(x[1]))+text(str(x[1]), x[2], color="blue", axes=False) for x in white_pieces_init_pos_squares2])
        black_pieces2 = sum([circle(x[2], 1/2, edgecolor="black", fill=true, rgbcolor="gray", alpha = 0.5, axes = False)+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_circles2]) + sum([triangle_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_triangles2]) + sum([square_b(x[2], str(x[1]))+text(str(x[1]), x[2], color="red", axes=False) for x in black_pieces_init_pos_squares2])
        return (white_pieces2 + black_pieces2 + ver_lines2 + hor_lines2)


def pyramid_b_simple(pt, s):
    """

    This was written by gemini, based on some (omitted) code of my own.


    EXAMPLES:

    """
    a = QQ(pt[0])
    b = QQ(pt[1])
    # Draw a distinct background, e.g., a blue diamond
    bg = polygon([(a, b+0.5), (a+0.5, b), (a, b-0.5), (a-0.5, b)], fill=True, rgbcolor= "blue", alpha=0.5, axes=False, zorder=2, edgecolor='black')
    # Add text indicating it's a pyramid and its value
    txt = text("p"+s, (a,b), color="white", fontsize=8, zorder=3, axes=False)
    return bg + txt
    
def pyramid_w_simple(pt, s):
    """

    This was written by gemini, based on some (omitted) code of my own.


    EXAMPLES:

    """
    a = QQ(pt[0])
    b = QQ(pt[1])
    # Draw a distinct background, e.g., a yellow diamond
    bg = polygon([(a, b+0.5), (a+0.5, b), (a, b-0.5), (a-0.5, b)], fill=True, rgbcolor= "yellow", alpha=0.5, axes=False, zorder=2, edgecolor='black')
    # Add text indicating it's a pyramid and its value
    txt = text("P"+s, (a,b), color="blue", fontsize=8, zorder=3, axes=False)
    return bg + txt


def board_plot(game_state, pyramid=True):
    """
    returns the plot of the 8x16 board and the pieces in the game_state.

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: is_valid_move(GS, (6, 0), (3, 0), "white")
        Valid move of a white square.
        True
        sage: board_plot(GS)          ## initial game state
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        sage: GS = move_piece(GS, (6, 0), (3, 0))
        sage: board_plot(GS)         ## resulting game state after S15:(6, 0)-(3, 0)
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        sage: GS = board_initial_matrix()
        sage: board_plot(GS, vertical=True)
        Launched png viewer for Graphics object consisting of 154 graphics primitives
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GSp = move_piece(GSp, (6, 0), (3, 0))
        sage: board_plot2(GSp, pyramid=True)
        Launched png viewer for Graphics object consisting of 152 graphics primitives

    """
    lowercase_alphabet = string.ascii_lowercase
    GS = copy(game_state)
    PR, (c,C,p,P,t,T,s,S) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    if pyramid:
        # --- Draw Board Grid and Labels ---
        plot_verlist = [line([(i + 0.5, -0.5), (i + 0.5, 7.5)], color="black", axes=False) for i in range(-1,16)]
        plot_xaxislist = [text(str(lowercase_alphabet[i]), (i + 0.5, -1), color="black", axes=False) for i in range(16)]
        plot_horlist = [line([(-0.5, j+ 0.5), (15.5, j + 0.5)], color="black", axes=False) for j in range(-1,8)]
        plot_yaxislist = [text(str(8-j), (-1, j+0.5), color="black", axes=False) for j in range(8)]
        ver_lines  = sum(plot_verlist) + sum(plot_xaxislist)
        hor_lines  = sum(plot_horlist) + sum(plot_yaxislist)
        
        # --- Get Piece Data ---
        # FIX: Removed verbose=True argument from calls
        pos_w = positions_w(GS)
        pos_b = positions_b(GS)

        # --- Format Piece Data for Plotting ---
        white_circles =   [["C", item[1].degree(), (item[0][1], 7-item[0][0])] for item in pos_w if C in item[1].variables() and not P in item[1].variables()]
        white_triangles = [["T", item[1].degree(), (item[0][1], 7-item[0][0])] for item in pos_w if T in item[1].variables() and not P in item[1].variables()]
        white_squares =   [["S", item[1].degree(), (item[0][1], 7-item[0][0])] for item in pos_w if S in item[1].variables() and not P in item[1].variables()]
        white_pyramid =   [["P", item[1].degree(P), (item[0][1], 7-item[0][0])] for item in pos_w if P in item[1].variables()]

        black_circles =   [["c", item[1].degree(), (item[0][1], 7-item[0][0])] for item in pos_b if c in item[1].variables() and not p in item[1].variables()]
        black_triangles = [["t", item[1].degree(), (item[0][1], 7-item[0][0])] for item in pos_b if t in item[1].variables() and not p in item[1].variables()]
        black_squares =   [["s", item[1].degree(), (item[0][1], 7-item[0][0])] for item in pos_b if s in item[1].variables() and not p in item[1].variables()]
        black_pyramid =   [["p", item[1].degree(p), (item[0][1], 7-item[0][0])] for item in pos_b if p in item[1].variables()]

        # --- Generate Piece Graphics ---
        white_plots = sum([circle_w(pc[2], str(pc[1])) for pc in white_circles]) + \
                      sum([triangle_w(pc[2], str(pc[1])) for pc in white_triangles]) + \
                      sum([square_w(pc[2], str(pc[1])) for pc in white_squares])
        
        black_plots = sum([circle_b(pc[2], str(pc[1])) for pc in black_circles]) + \
                      sum([triangle_b(pc[2], str(pc[1])) for pc in black_triangles]) + \
                      sum([square_b(pc[2], str(pc[1])) for pc in black_squares])

        if white_pyramid:
            wp_data = white_pyramid[0]
            white_plots += pyramid_w_simple(wp_data[2], str(wp_data[1]))
            
        if black_pyramid:
            bp_data = black_pyramid[0]
            black_plots += pyramid_b_simple(bp_data[2], str(bp_data[1]))

        final_plot = white_plots + black_plots + ver_lines + hor_lines
        return final_plot 
    else:
        # Fallback to the older board_plot2 if pyramid is False
        return board_plot2(GS, vertical=False)

""" old code begin
    lowercase_alphabet = string.ascii_lowercase
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = PolynomialRing(ZZ, 8, order='invlex', names=('c', 'C', 'p', 'P', 't', 'T', 's', 'S'))
    M = Mat(PR, 8, 16)
    alphab = lowercase_alphabet
    if pyramid:
        plot_verlist = [line([(i + 0.5, -0.5), (i + 0.5, 7.5)], color="black", axes=False) for i in range(-1,16)]
        plot_xaxislist = [text(str(alphab[i+1]), (i + 0.75, -2), color="black", axes=False) for i in range(-1,15)]
        plot_xaxislist2 = [text(str(i+1), (i + 0.75, 9), color="blue", axes=False) for i in range(-1,15)]
        plot_horlist = [line([(-0.5, j+ 0.5), (15.5, j + 0.5)], color="black", axes=False) for j in range(-1,8)]
        plot_yaxislist = [text(str(7-j), (-2, j+0.75), color="black", axes=False) for j in range(-1,7)]
        plot_yaxislist2 = [text(str(6-j), (18, j+0.75), color="blue", axes=False) for j in range(-1,7)]
        ver_lines  = sum(plot_verlist) + sum(plot_xaxislist) + sum(plot_xaxislist2)
        hor_lines  = sum(plot_horlist) + sum(plot_yaxislist) + sum(plot_yaxislist2)
        pos_w = positions_w(GS, verbose = True)
        pos_b = positions_b(GS, verbose = True)
        white_pieces_init_pos_circles =   [["C", xx[1].degree(), (xx[0][1], 7-xx[0][0])] for xx in pos_w if (xx[1] != 0) and (C in xx[1].variables()) and not(P in xx[1].variables())]
        white_pieces_init_pos_triangles = [["T", xx[1].degree(), (xx[0][1], 7-xx[0][0])] for xx in pos_w if (xx[1] != 0) and (T in xx[1].variables()) and not(P in xx[1].variables())]
        white_pieces_init_pos_squares =   [["S", xx[1].degree(), (xx[0][1], 7-xx[0][0])] for xx in pos_w if (xx[1] != 0) and (S in xx[1].variables()) and not(P in xx[1].variables())]
        white_pieces_init_pos_pyramid =   [["P", PR(xx[1]).degree(PR(P)), (xx[0][1], 7-xx[0][0])] for xx in pos_w if ((xx[1] != 0) and (P in xx[1].variables()))]
        black_pieces_init_pos_circles =  [["c", xx[1].degree(), (xx[0][1], 7-xx[0][0])] for xx in pos_b if (xx[1] != 0) and (c in xx[1].variables()) and not(p in xx[1].variables())]
        black_pieces_init_pos_triangles = [["t", xx[1].degree(), (xx[0][1], 7-xx[0][0])] for xx in pos_b if (xx[1] != 0) and (t in xx[1].variables()) and not(p in xx[1].variables())]
        black_pieces_init_pos_squares =  [["s", xx[1].degree(), (xx[0][1], 7-xx[0][0])] for xx in pos_b if (xx[1] != 0) and (s in xx[1].variables()) and not(p in xx[1].variables())]
        black_pieces_init_pos_pyramid =  [["p", PR(xx[1]).degree(PR(p)), (xx[0][1], 7-xx[0][0])] for xx in pos_b if (xx[1] != 0) and (p in xx[1].variables())]
        white_pieces_init_pos = white_pieces_init_pos_circles + white_pieces_init_pos_triangles + white_pieces_init_pos_squares + white_pieces_init_pos_pyramid 
        black_pieces_init_pos = black_pieces_init_pos_circles + black_pieces_init_pos_triangles + black_pieces_init_pos_squares + black_pieces_init_pos_pyramid
        #print(white_pieces_init_pos_pyramid, [(PR(xx[1]).degree(PR(P)), xx, xx[1].variables()) for xx in pos_w if (xx[1] != 0)])
        #y = white_pieces_init_pos_pyramid[0]     ### replace by gemini-suggested code block:
        white_pyramid_plot = None
        if white_pieces_init_pos_pyramid: # Check if list is not empty
            y = white_pieces_init_pos_pyramid[0]
            white_pyramid_plot = pyramid_w_simple(y[2], str(y[1]))
        #white_pieces = sum([circle(xx[2], 1/2, color="black", axes = False)+text(str(xx[1]), xx[2], color="blue", axes=False) for xx in white_pieces_init_pos_circles]) + sum([triangle_w(xx[2], xx[1])+text(str(xx[1]), xx[2], color = "blue", axes = False) for xx in white_pieces_init_pos_triangles]) + sum([square_w(xx[2], str(xx[1]))+text(str(xx[1]), xx[2], color="blue", axes=False) for xx in white_pieces_init_pos_squares]) + pyramid_w_simple(y[2], str(y[1]))
        white_plots = sum([circle_w(xx[2], str(xx[1])) for xx in white_pieces_init_pos_circles]) + sum([triangle_w(xx[2], str(xx[1])) for xx in white_pieces_init_pos_triangles]) + sum([square_w(xx[2], str(xx[1])) for xx in white_pieces_init_pos_squares])
        #z = black_pieces_init_pos_pyramid[0]     ### replace by gemini-suggested code block:
        black_pyramid_plot = None
        if black_pieces_init_pos_pyramid: # Check if list is not empty
            z = black_pieces_init_pos_pyramid[0]
            black_pyramid_plot = pyramid_b_simple(z[2], str(z[1]))
        #black_pieces = sum([circle(xx[2], 1/2, edgecolor="black", fill=true, rgbcolor="gray", alpha = 0.5, axes = False)+text(str(xx[1]), xx[2], color="red", axes=False) for xx in black_pieces_init_pos_circles]) + sum([triangle_b(xx[2], str(xx[1]))+text(str(xx[1]), xx[2], color="red", axes=False) for xx in black_pieces_init_pos_triangles]) + sum([square_b(xx[2], str(xx[1]))+text(str(xx[1]), xx[2], color="red", axes=False) for xx in black_pieces_init_pos_squares]) + pyramid_b_simple(z[2], str(z[1]))
        black_plots = sum([circle_b(xx[2], str(xx[1])) for xx in black_pieces_init_pos_circles]) + sum([triangle_b(xx[2], str(xx[1]))+text(str(xx[1]), xx[2], color="red", axes=False) for xx in black_pieces_init_pos_triangles]) + sum([square_b(xx[2], str(xx[1]))+text(str(xx[1]), xx[2], color="red", axes=False) for xx in black_pieces_init_pos_squares])
        final_plot = white_plots + black_plots + ver_lines + hor_lines
        if white_pyramid_plot:
            final_plot += white_pyramid_plot
        if black_pyramid_plot:
            final_plot += black_pyramid_plot
        return final_plot 
    else:
        return board_plot(GS, vertical=False)
old code end """ 


def display_board_matplotlib(game_state_sage_matrix, dpi=300, highlight_pieces=None):
    """
    Displays the Rithmomachia board using Matplotlib, based on a SageMath game state matrix.

    :param game_state_sage_matrix: The SageMath matrix representing the game state.
    :param dpi: The resolution in dots per inch for the output image.
    :param highlight_pieces: A list of up to 3 piece coordinates (e.g., ['a1', 'h8', 'c2'])
                             to be highlighted with a dotted circle.

    EXAMPLES:
         sage: initial_game_state = board_initial_matrix(pyramid_decomposition=True)  # 1. Get the initial game state
         sage: pieces_to_circle = ['a1', 'a8', 'p1']                                  # 2. Define pieces to highlight (optional), 
                                                                                      #    coords in algebraic notation (e.g., 'a1', 'h8').
                                                                                      # 3. Display the board with a DPI of 300 and highlighted pieces
         # The function will now save the board as a PNG file and also display it.
         sage: display_board_matplotlib(game_state_sage_matrix = initial_game_state, dpi=300, highlight_pieces=pieces_to_circle)

    """
    # *** FIX: Define the ring and its generators simultaneously ***
    # This ensures P_var and p_var are the correct type for comparisons and methods.
    PR, (c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    rows, cols = 8, 16
    fig, ax = plt.subplots(figsize=(16, 8))
    font_size = 10

    # --- 1. Draw Grid and Labels ---
    for x in range(cols):
        for y in range(rows):
            ax.add_patch(patches.Rectangle((x, rows - y - 1), 1, 1, fill=False, edgecolor='black'))
    for x in range(cols):
        ax.text(x + 0.5, rows + 0.2, chr(97 + x), ha='center', va='center', fontsize=10, color='purple')
    for y in range(rows):
        ax.text(-0.5, rows - y - 0.5, str(y + 1), ha='center', va='center', fontsize=10, color='purple')
    for x in range(cols):
        ax.text(x + 0.5, -0.8, str(x), ha='center', va='center', fontsize=10, color='blue')
    for y in range(rows):
        ax.text(cols + 0.5, rows - y - 0.5, str(y), ha='center', va='center', fontsize=10, color='blue')

    # --- 2. Extract and Prepare Piece Data ---
    pieces_to_draw = []
    all_positions = positions_w(game_state_sage_matrix, verbose=True) + positions_b(game_state_sage_matrix, verbose=True)

    for item in all_positions:
        pos_tuple, poly_piece_raw = item[0], item[1]
        poly_piece = PR(poly_piece_raw)
        r_sage, c_sage = pos_tuple[0], pos_tuple[1]
        shape_mpl, color_mpl = get_piece_details_from_poly(poly_piece, 'green', 'red')
        
        display_val_num = 0
        if P_var in poly_piece.variables():
            display_val_num = poly_piece.degree(P_var)
        elif p_var in poly_piece.variables():
            display_val_num = poly_piece.degree(p_var)
        else:
            val_list = value_of_piece(game_state_sage_matrix, r_sage, c_sage)
            display_val_num = sum(v for v in val_list if isinstance(v, (int, Integer)))

        value_str = str(display_val_num)
        if shape_mpl != "unknown":
            y_mpl_row_origin = rows - 1 - r_sage
            pieces_to_draw.append((c_sage, y_mpl_row_origin, color_mpl, shape_mpl, value_str))

    # --- 3. Draw Pieces ---
    for x_col, y_row_mpl, color, shape, value in pieces_to_draw:
        x_center = x_col + 0.5
        y_center = y_row_mpl + 0.5
        patch_to_add = None

        if shape == 'circle':
            patch_to_add = patches.Circle((x_center, y_center), 0.4, facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'square':
            patch_to_add = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'triangle':
            patch_to_add = patches.RegularPolygon((x_center, y_center - 0.1), numVertices=3, radius=0.45, orientation=2 * numpy_pi / 3, facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'diamond':
            base_color = "green" if color == "lime" else "red"
            big_square = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, facecolor=base_color, edgecolor='black', linewidth=0.5)
            little_square = patches.RegularPolygon((x_center, y_center), numVertices=4, radius=0.45, orientation=numpy_pi/4, facecolor=color, edgecolor='black', linewidth=0.5)
            ax.add_patch(big_square)
            ax.add_patch(little_square)

        if patch_to_add:
            ax.add_patch(patch_to_add)

        text_color = 'black' if color in ['green', 'lime'] else 'white'

        if shape == 'diamond':
            ax.text(x_center, y_center, value, ha='center', va='center', color=text_color, fontsize=font_size, weight='bold')
            all_vals = value_of_piece(game_state_sage_matrix, 7 - y_row_mpl, x_col)
            main_val = int(value)
            sub_values = [v for v in all_vals if v != main_val and v > 0]
            if sub_values:
                sub_values_str = ','.join(map(str, sorted(sub_values, reverse=True)))
                ax.text(x_center, y_center + 0.25, sub_values_str, ha='center', va='center', color=text_color, fontsize=6, weight='bold')
        else:
            ax.text(x_center, y_center - 0.1, value, ha='center', va='center', color=text_color, fontsize=font_size, weight='bold')

    # --- 4. & 5. Highlighting and Display ---
    if highlight_pieces:
        for piece_coord in highlight_pieces[:3]:
            if len(piece_coord) >= 2:
                col_char = piece_coord[0].lower()
                row_str = piece_coord[1:]
                if 'a' <= col_char <= 'p' and row_str.isdigit():
                    x_col = ord(col_char) - ord('a')
                    y_row = int(row_str) - 1
                    y_row_mpl = rows - 1 - y_row
                    x_center = x_col + 0.5
                    y_center = y_row_mpl + 0.5
                    highlight_circle = patches.Circle((x_center, y_center), 0.45, fill=False, edgecolor='lightblue', linestyle='solid', linewidth=5.5)
                    ax.add_patch(highlight_circle)

    ax.set_xlim(-1, cols + 1)
    ax.set_ylim(-1, rows + 1)
    ax.set_aspect('equal', adjustable='box')
    ax.axis('off')
    fig.tight_layout()
    plt.savefig(filename, dpi=dpi)
    plt.close(fig)
    print(f"Board image saved to {filename} with a DPI of {dpi}")

    return fig


def display_board_matplotlib_enhanced(game_state_sage_matrix, dpi=300, highlight_pieces=None, filename="rithmomachia_board.png"):
    """
    Displays the Rithmomachia board using Matplotlib and saves it to a specified file.
    (This is a modified version of the original function to be more suitable for automation)
    """
    # --- SETUP: Define Polynomial Ring and variables correctly ---
    PR, (c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    rows, cols = 8, 16
    fig, ax = plt.subplots(figsize=(16, 8))
    font_size = 10

    # --- 1. Draw Grid and Labels ---
    for x in range(cols):
        for y in range(rows):
            ax.add_patch(patches.Rectangle((x, rows - y - 1), 1, 1, fill=False, edgecolor='black'))
    for x in range(cols):
        ax.text(x + 0.5, rows + 0.2, chr(97 + x), ha='center', va='center', fontsize=10, color='purple')
    for y in range(rows):
        ax.text(-0.5, rows - y - 0.5, str(y + 1), ha='center', va='center', fontsize=10, color='purple')
    for x in range(cols):
        ax.text(x + 0.5, -0.8, str(x), ha='center', va='center', fontsize=10, color='blue')
    for y in range(rows):
        ax.text(cols + 0.5, rows - y - 0.5, str(y), ha='center', va='center', fontsize=10, color='blue')

    # --- 2. Extract and Prepare Piece Data with Correct Logic ---
    pieces_to_draw = []
    all_positions = positions_w(game_state_sage_matrix, verbose=True) + positions_b(game_state_sage_matrix, verbose=True)

    for item in all_positions:
        pos_tuple, poly_piece_raw = item[0], item[1]
        poly_piece = PR(poly_piece_raw) # Ensure correct type
        r_sage, c_sage = pos_tuple[0], pos_tuple[1]
        shape_mpl, color_mpl = get_piece_details_from_poly(poly_piece, 'green', 'red')
        
        display_val_num = 0
        # Correctly get the main value for pyramids
        if P_var in poly_piece.variables():
            display_val_num = poly_piece.degree(P_var)
        elif p_var in poly_piece.variables():
            display_val_num = poly_piece.degree(p_var)
        else: # For regular pieces, sum is fine (as there's only one value)
            val_list = value_of_piece(game_state_sage_matrix, r_sage, c_sage)
            display_val_num = sum(v for v in val_list if isinstance(v, (int, Integer)))

        value_str = str(display_val_num)
        if shape_mpl != "unknown":
            y_mpl_row_origin = rows - 1 - r_sage
            pieces_to_draw.append((c_sage, y_mpl_row_origin, color_mpl, shape_mpl, value_str))

    # --- 3. Draw Pieces with Enhanced Pyramid Text ---
    for x_col, y_row_mpl, color, shape, value in pieces_to_draw:
        x_center = x_col + 0.5
        y_center = y_row_mpl + 0.5
        patch_to_add = None

        if shape == 'circle':
            patch_to_add = patches.Circle((x_center, y_center), 0.4, facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'square':
            patch_to_add = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'triangle':
            patch_to_add = patches.RegularPolygon((x_center, y_center - 0.1), numVertices=3, radius=0.45, orientation=2 * numpy_pi / 3, facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'diamond':
            base_color = "green" if color == "lime" else "red"
            big_square = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, facecolor=base_color, edgecolor='black', linewidth=0.5)
            little_square = patches.RegularPolygon((x_center, y_center), numVertices=4, radius=0.45, orientation=numpy_pi/4, facecolor=color, edgecolor='black', linewidth=0.5)
            ax.add_patch(big_square)
            ax.add_patch(little_square)

        if patch_to_add:
            ax.add_patch(patch_to_add)

        # New, corrected logic for drawing all text
        text_color = 'black' if color in ['green', 'lime', 'white'] else 'white'

        if shape == 'diamond':
            # Draw the main value (e.g., 91)
            ax.text(x_center, y_center, value, ha='center', va='center', color=text_color, fontsize=font_size, weight='bold')
            
            # Get and draw the sub-piece values
            all_vals = value_of_piece(game_state_sage_matrix, 7 - y_row_mpl, x_col)
            main_val = int(value)
            sub_values = [v for v in all_vals if v != main_val and v > 0]
            
            if sub_values:
                sub_values_str = ','.join(map(str, sorted(sub_values, reverse=True)))
                # Draw sub-piece string above the main value in a tiny font
                ax.text(x_center, y_center + 0.25, sub_values_str, ha='center', va='center', color=text_color, fontsize=6, weight='bold')
        else:
            # For regular pieces, draw text as before
            ax.text(x_center, y_center, value, ha='center', va='center', color=text_color, fontsize=font_size, weight='bold')

    # --- 4. & 5. Highlighting and Display ---
    if highlight_pieces:
        for piece_coord in highlight_pieces[:3]:
            if len(piece_coord) >= 2:
                col_char = piece_coord[0].lower()
                row_str = piece_coord[1:]
                if 'a' <= col_char <= 'p' and row_str.isdigit():
                    x_col = ord(col_char) - ord('a')
                    y_row = int(row_str) - 1
                    y_row_mpl = rows - 1 - y_row
                    x_center = x_col + 0.5
                    y_center = y_row_mpl + 0.5
                    highlight_circle = patches.Circle((x_center, y_center), 0.45, fill=False, edgecolor='lightblue', linestyle='solid', linewidth=5.5)
                    ax.add_patch(highlight_circle)

    ax.set_xlim(-1, cols + 1)
    ax.set_ylim(-1, rows + 1)
    ax.set_aspect('equal', adjustable='box')
    ax.axis('off')
    fig.tight_layout()
    plt.savefig(filename, dpi=dpi)
    plt.close(fig)
    print(f"Board image saved to {filename} with a DPI of {dpi}")

    return fig
    

#########################################################################################
######################## pieces ######################


def board_initial_matrix(pyramid_decomposition = False):
    """
    returns the initial game state as a 8x16 matrix with entries in
    PR = ZZ[c,C,t,T,s,S,p,P], representing the pieces in their intial position.

    If pyramid_decomposition = True then:
         S91 = S36 + S25 + S16 + S9 + S4 + S1 is used, and 
         s190 = s64 + s49 + s36 + s25 + s16 is used. 
  
    The pyramid positions are the only ones where these matrices differ.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: GS[1, 1]
         S^91 + P
        sage: GS[7, 14]
         s^190 + p
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GSp[1, 1]
         P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S
        sage: GSp[7, 14]
         p^190 + s^64 + s^49 + s^36 + s^25 + s^16

    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(0)
    white_pieces_init_pos_circles = [["C", 2, (3, 2)], ["C", 4, (3, 3)], ["C", 6, (3, 4)], ["C", 8, (3, 5)],["C", 4, (2, 2)], ["C", 16, (2, 3)], ["C", 36, (2, 4)], ["C", 64, (2, 5)]]
    white_pieces_init_pos_triangles = [["T", 25, (1, 2)], ["T", 20, (1, 3)], ["T", 42, (1, 4)], ["T", 49, (1, 5)], ["T", 9, (2, 0)], ["T", 6, (2, 1)], ["T", 72, (2, 6)], ["T", 81, (2, 7)]]
    white_pieces_init_pos_squares = [["S", 15, (1, 0)], ["S", 45, (1, 1)], ["S", 91, (1, 6)], ["S", 153, (1, 7)], ["S", 25, (0, 0)], ["S", 81, (0, 1)], ["S", 169, (0, 6)], ["S", 289, (0, 7)]]
    white_pieces_init_pos_pyramid = [["P", 91, (1, 6)]]
    black_pieces_init_pos_circles = [["c", 3, (12, 5)], ["c", 5, (12, 4)], ["c", 7, (12, 3)], ["c", 9, (12, 2)],["c", 9, (13, 5)], ["c", 25, (13, 4)], ["c", 49, (13, 3)], ["c", 81, (13, 2)]]
    black_pieces_init_pos_triangles = [["t", 36, (14, 5)], ["t", 30, (14, 4)], ["t", 56, (14, 3)], ["t", 64, (14, 2)], ["t", 16, (13, 7)], ["t", 12, (13, 6)], ["t", 90, (13, 1)], ["t", 100, (13, 0)]]
    black_pieces_init_pos_squares = [["s", 28, (14, 7)], ["s", 66, (14, 6)], ["s", 120, (14, 1)], ["s", 190, (14, 0)], ["s", 49, (15, 7)], ["s", 121, (15, 6)], ["s", 225, (15, 1)], ["s", 361, (15, 0)]]
    black_pieces_init_pos_pyramid = [["p", 190, (14, 0)]]
    for x in white_pieces_init_pos_circles:
        i = x[2][1]
        j = x[2][0]
        #print(C, i, j, x, type(C), type(x[1]))
        A[8-i-1, j] = C^(x[1])
    for x in white_pieces_init_pos_triangles:
        i = x[2][1]
        j = x[2][0]
        A[8-i-1, j] = T^(x[1])
    for x in white_pieces_init_pos_squares:
        i = x[2][1]
        j = x[2][0]
        if not(x[1] == 91):
            A[8-i-1, j] = S^(x[1])
    x = white_pieces_init_pos_pyramid[0]
    i = x[2][1]
    j = x[2][0]
    if (x[1] == 91) and not(pyramid_decomposition):
        A[8-i-1, j] = S^(91) + P
    elif (x[1] == 91) and (pyramid_decomposition):
        A[8-i-1, j] = S^(36) + S^(25) + S^(16) + S^9 + S^4 + S^1 + P^(91)  ### these terms can now be distinguished
    for x in black_pieces_init_pos_circles:
        i = x[2][1]
        j = x[2][0]
        #print("00",c, i, j, x)
        A[8-i-1, j] = c^(x[1])
    for x in black_pieces_init_pos_triangles:
        i = x[2][1]
        j = x[2][0]
        A[8-i-1, j] = t^(x[1])
    for x in black_pieces_init_pos_squares:
        i = x[2][1]
        j = x[2][0]
        #print("01a",i,j,x[1])
        if not(x[1] == 190):
            A[8-i-1, j] = s^(x[1])
            #print("01b",i,j,A[8-i-1, j])
    x = black_pieces_init_pos_pyramid[0]
    i = x[2][1]
    j = x[2][0]
    #print("02",x,A[8-i-1, j])
    if (x[1] == 190) and not(pyramid_decomposition):
        A[8-i-1, j] = s^(190) + p
    elif (x[1] == 190) and (pyramid_decomposition):
        A[8-i-1, j] = s^(64) + s^(49) + s^(36) + s^(25) + s^(16) + p^(190)  ### these terms can now be distinguished  
        #print("03",x, A[8-i-1, j])
    return A


def random_board_state(verbose=False):
    """
    returns a random game state as an element of Mat(8, 16, ZZ[c,C,t,T,s,S,p,P]

    EXAMPLES:
        sage: RS = random_board_state(); RS
        [    0     0  S^25     0   c^5  T^72   C^6     0     0     0  T^20     0  t^56   c^9     0     0]
        [    0   C^8     0 S^153     0 s^225     0  S^15     0  t^90   C^4     0 s^190     0     0     0]
        [    0     0     0  t^16     0  T^42     0  C^36  S^45     0     0     0     0     0     0 s^121]
        [    0   C^4     0   C^2 S^289   T^6     0     0  c^49     0     0     0     0     0     0 s^120]
        [    0     0     0   T^9     0     0     0     0     0     0     0     0  s^66  s^28     0     0]
        [    0 t^100     0  t^64     0     0     0     0  T^49     0  S^91  S^81  C^64     0   c^3  t^12]
        [    0  T^25   c^9  t^36  T^81     0     0  c^25     0  C^16     0     0     0     0     0     0]
        [    0     0     0     0  s^49     0     0   c^7     0 S^169 s^361     0  c^81  t^30     0     0]
        sage: RS = random_board_state(verbose=True) ## random coordinates, list of pieces and values
        [[0, 7], [3, 4], [0, 12], [2, 11], [2, 10], [6, 0], [4, 7], [1, 7], [4, 0], [6, 8], [6, 13], [7, 11],
          [0, 4], [7, 5], [7, 13], [6, 3], [2, 13], [4, 9], [0, 3], [5, 4], [4, 11], [2, 1], [7, 6], [1, 3],
          [7, 10], [3, 12], [0, 5], [3, 7], [2, 2], [6, 6], [1, 13], [2, 15], [5, 11], [0, 0], [1, 4], [0, 2],
          [2, 12], [4, 5], [1, 8], [7, 8], [4, 14], [7, 0], [5, 14], [5, 3], [3, 9], [0, 8], [0, 14], [1, 10]] 
        [['C', 2], ['C', 4], ['C', 6], ['C', 8], ['C', 4], ['C', 16], ['C', 36], ['C', 64], ['T', 25], ['T', 20],
         ['T', 42], ['T', 49], ['T', 9], ['T', 6], ['T', 72], ['T', 81], ['S', 15], ['S', 45], ['S', 91],
         ['S', 153], ['S', 25], ['S', 81], ['S', 169], ['S', 289], ['c', 3], ['c', 5], ['c', 7], ['c', 9], ['c', 9],
         ['c', 25], ['c', 49], ['c', 81], ['t', 36], ['t', 30], ['t', 56], ['t', 64], ['t', 16], ['t', 12], ['t', 90],
         ['t', 100], ['s', 28], ['s', 66], ['s', 120], ['s', 190], ['s', 49], ['s', 121], ['s', 225], ['s', 361]]

    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = copy(M(0))
    white_pieces_circles = [["C", 2], ["C", 4], ["C", 6], ["C", 8],["C", 4], ["C", 16], ["C", 36], ["C", 64]]
    white_pieces_triangles = [["T", 25], ["T", 20], ["T", 42], ["T", 49], ["T", 9], ["T", 6], ["T", 72], ["T", 81]]
    white_pieces_squares = [["S", 15], ["S", 45], ["S", 153], ["S", 25], ["S", 81], ["S", 169], ["S", 289]]
    white_pieces_pyramid = [["P", 91]]
    black_pieces_circles = [["c", 3], ["c", 5], ["c", 7], ["c", 9],["c", 9], ["c", 25], ["c", 49], ["c", 81]]
    black_pieces_triangles = [["t", 36], ["t", 30], ["t", 56], ["t", 64], ["t", 16], ["t", 12], ["t", 90], ["t", 100]]
    black_pieces_squares = [["s", 28], ["s", 66], ["s", 120], ["s", 49], ["s", 121], ["s", 225], ["s", 361]]
    black_pieces_pyramid = [["p", 190]]
    board = [[i,j] for i in range(8) for j in range(16)]
    coords = select_from_a_list_random(board, 48)
    pieces = white_pieces_circles + white_pieces_triangles + white_pieces_squares + white_pieces_pyramid + black_pieces_circles + black_pieces_triangles + black_pieces_squares + black_pieces_pyramid
    if verbose:
        print(coords, "\n", pieces)
    for k in range(48):
        x = pieces[k]
        d = x[1]
        i = coords[k][0]
        j = coords[k][1]
        if x[0]=="C":
            A[i,j] = C^d
        elif x[0]=="T":
            A[i,j] = T^d
        elif x[0]=="S":
            A[i,j] = S^d
        elif x[0]=="P":
            A[i,j] = P^d
        elif x[0]=="c":
            A[i,j] = c^d
        elif x[0]=="t":
            A[i,j] = t^d
        elif x[0]=="s":
            A[i,j] = s^d
        elif x[0]=="p":
            A[i,j] = p^d
    return A


def value_of_piece(GS, i, j):
    """
    Returns the value(s) of the piece at (i,j) in the game state matrix.
    If the position is empty, it returns [0].
    If the piece is a pyramid, it returns a flat list of all its component values.

    EXAMPLE:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: value_of_piece(GS, 2, 3)
         [8]
        sage: value_of_piece(GSp, 1, 1)
         [36, 25, 16, 9, 4, 1]

    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    
    poly_piece = GS[i, j]

    if poly_piece == 0:
        return [0]

    # For non-pyramid pieces, the value is simply the degree.
    if not (p in poly_piece.variables() or P in poly_piece.variables()):
        return [poly_piece.degree()]
        
    # For pyramids, collect the value of every component.
    else:
        values = []
        f = PR(poly_piece)
        exponents = f.exponents()
        
        for exp_tuple in exponents:
            # Indices: p=2, P=3, s=6, S=7
            if exp_tuple[2] > 0: # Black pyramid main value
                values.append(exp_tuple[2])
            if exp_tuple[3] > 0: # White pyramid main value
                values.append(exp_tuple[3])
            if exp_tuple[6] > 0: # Black square sub-piece value
                values.append(exp_tuple[6])
            if exp_tuple[7] > 0: # White square sub-piece value
                values.append(exp_tuple[7])
        
        # This handles the legacy format where the pyramid value was stored
        # as a degree, in case the polynomial is just 'P' or 'p'.
        if not values:
            if p in poly_piece.variables():
                values.append(poly_piece.degree(p))
            elif P in poly_piece.variables():
                values.append(poly_piece.degree(P))
             
        return sorted(list(set(values)))


def captured_pieces_white(game_state, pyramid_decomposition=True): 
    """
    Returns the list of White's pieces that have been captured by Black,
    computed by comparing the current game state to the initial state.

    Args:
        game_state: The current game state matrix.
        pyramid_decomposition: Boolean flag matching the setting used
                               to initialize the board state. (Default: True)

    Returns:
        List of tuples [(initial_position, piece_symbol)], representing
        the white pieces present initially but not currently on the board.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition=True)
        sage: GS = copy(GSp)
        sage: GS[1,1] = 0; GS[2,1] = 0; GS[3,1] = 0; GS[4,1] = 0
        sage: captured_pieces_white(GS, pyramid_decomposition=True)
         [P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S, T^49, T^42, T^20]


    """
    GS = copy(game_state)
    initial_GS = board_initial_matrix(pyramid_decomposition=pyramid_decomposition)
    captured_list_str = []
    
    # Define Polynomial Ring to ensure type consistency
    PR, (_,_,_,P,_,_,S,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # 1. Handle regular (non-pyramid) pieces
    initial_regular = [p[1] for p in positions_w(initial_GS, verbose=True) if not P in p[1].variables()]
    current_regular = [p[1] for p in positions_w(GS, verbose=True) if not P in p[1].variables()]
    
    initial_counts = Counter(initial_regular)
    initial_counts.subtract(Counter(current_regular))
    
    for piece, count in initial_counts.items():
        if count > 0:
            captured_list_str.extend([str(piece)] * count)

    # 2. Handle the Pyramid sub-pieces separately
    initial_pyramid_pos = pyramid_positions_white(initial_GS)
    current_pyramid_pos = pyramid_positions_white(GS)

    if initial_pyramid_pos:
        initial_pyramid_poly = initial_GS[initial_pyramid_pos[0][0], initial_pyramid_pos[0][1]]
        
        # If the pyramid is missing entirely from the board
        if not current_pyramid_pos:
            captured_list_str.append(f"Entire pyramid {initial_pyramid_poly}")
        # If it's still on the board, check for missing sub-piece values
        else:
            initial_sub_values = set(v for v in value_of_piece(initial_GS, initial_pyramid_pos[0][0], initial_pyramid_pos[0][1]) if v != initial_pyramid_poly.degree(P))
            current_sub_values = set(v for v in value_of_piece(GS, current_pyramid_pos[0][0], current_pyramid_pos[0][1]) if v != PR(GS[current_pyramid_pos[0][0], current_pyramid_pos[0][1]]).degree(P))
            
            captured_sub_values = initial_sub_values - current_sub_values
            
            for val in sorted(list(captured_sub_values), reverse=True):
                captured_list_str.append(f"S^{val} of {initial_pyramid_poly}")
                
    return captured_list_str


def captured_pieces_black(game_state, pyramid_decomposition=True):
    """
    Computes the list of Black's pieces that have been captured by comparing
    the current game state to the initial state.

    Args:
        game_state: The current game state matrix.
        pyramid_decomposition: Boolean flag matching the setting used
                               to initialize the board state. (Default: True)

    Returns:
        List of tuples [(initial_position, piece_symbol)], representing
        the white pieces present initially but not currently on the board.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,13] = 0
        sage: captured_pieces_black(GS, pyramid_decomposition=True)
         [c^9]
        sage: GS[5,12] = 0
        sage: captured_pieces_black(GS, pyramid_decomposition=True)
         [c^9, c^9]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[1,13] = 0; GS[2,13] = 0; GS[3,13] = 0; GS[4,13] = 0
        sage: captured_pieces_black(GS, pyramid_decomposition=True)
         [t^12, c^9, c^25, c^49]

    """
    GS = copy(game_state)
    initial_GS = board_initial_matrix(pyramid_decomposition=pyramid_decomposition)
    captured_list_str = []
    
    PR, (_,_,p,_,_,_,s,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    # 1. Handle regular (non-pyramid) pieces
    initial_regular = [pc[1] for pc in positions_b(initial_GS, verbose=True) if not p in pc[1].variables()]
    current_regular = [pc[1] for pc in positions_b(GS, verbose=True) if not p in pc[1].variables()]
    
    initial_counts = Counter(initial_regular)
    initial_counts.subtract(Counter(current_regular))
    
    for piece, count in initial_counts.items():
        if count > 0:
            captured_list_str.extend([str(piece)] * count)

    # 2. Handle the Pyramid sub-pieces separately
    initial_pyramid_pos = pyramid_positions_black(initial_GS)
    current_pyramid_pos = pyramid_positions_black(GS)

    if initial_pyramid_pos:
        initial_pyramid_poly = initial_GS[initial_pyramid_pos[0][0], initial_pyramid_pos[0][1]]
        if not current_pyramid_pos:
            captured_list_str.append(f"Entire pyramid {initial_pyramid_poly}")
        else:
            initial_sub_values = set(v for v in value_of_piece(initial_GS, initial_pyramid_pos[0][0], initial_pyramid_pos[0][1]) if v != initial_pyramid_poly.degree(p))
            current_sub_values = set(v for v in value_of_piece(GS, current_pyramid_pos[0][0], current_pyramid_pos[0][1]) if v != PR(GS[current_pyramid_pos[0][0], current_pyramid_pos[0][1]]).degree(p))

            captured_sub_values = initial_sub_values - current_sub_values

            for val in sorted(list(captured_sub_values), reverse=True):
                captured_list_str.append(f"s^{val} of {initial_pyramid_poly}")
                
    return captured_list_str



def capture_piece(game_state, attacker_pos, captured_pos, verbose=False):
    """
    Identifies a piece at a given position and removes it from the game board.
    If the captured piece is a pyramid, it finds all possible ways the attacker
    at attacker_pos captures it and removes all corresponding sub-pieces.


    ###### new code suggested by gemini was added


    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    
    i0, j0 = captured_pos

    if not in_bounds((i0, j0)):
        if verbose: print(f"Coordinate {captured_pos} out of bounds, no capture.")
        return GS

    victim_poly = PR(GS[i0, j0])
    if victim_poly == 0:
        if verbose: print(f"No piece at {captured_pos}, no capture.")
        return GS

    vars_pc = victim_poly.variables()
    
    # If the captured piece is a regular piece, remove it completely.
    if not (p in vars_pc or P in vars_pc):
        if verbose: print(f"Removing piece {victim_poly} at {captured_pos}.")
        GS[i0, j0] = 0
        return GS

    # --- Robust Logic for Pyramid Captures ---
    else:
        # Find all captures between the specific attacker and victim
        all_possible_captures = get_captures_by_piece(GS, attacker_pos, verbose=False)
        relevant_captures = [cap for cap in all_possible_captures if cap and len(cap) > 1 and cap[1][0] == captured_pos]

        if not relevant_captures:
            if verbose: print(f"No valid capture method found from {attacker_pos} to {captured_pos}.")
            return GS

        # For numbering, the value is a list; for others, it's an int. This handles both.
        values_to_remove = set()
        for cap in relevant_captures:
            val = cap[1][1]
            if isinstance(val, list):
                values_to_remove.add(val[0]) # Add the integer from the list
            else:
                values_to_remove.add(val) # Add the integer directly

        if verbose:
            print(f"Attacker at {attacker_pos} is capturing sub-piece(s) with values {list(values_to_remove)} from pyramid at {captured_pos}.")

        # 1. Start with a clean, correctly-typed version of the polynomial
        temp_poly = PR(victim_poly)
        
        # 2. Get the initial main value ONCE before any modifications
        initial_main_value = 0
        if P in vars_pc:
            #print("0000", temp_poly, type(temp_poly), "\n", victim_poly, type(victim_poly), "\n", values_to_remove)
            initial_main_value = SR(temp_poly).degree(P)
        elif p in vars_pc:
            #print("0001", temp_poly, type(temp_poly), "\n", victim_poly, type(victim_poly), "\n", values_to_remove)
            initial_main_value = SR(temp_poly).degree(p)

        # 3. Modify the polynomial based on all calculations
        total_value_removed = sum(values_to_remove)
        new_main_value = initial_main_value - total_value_removed

        # Remove sub-piece terms
        for val in values_to_remove:
            if P in vars_pc: temp_poly = temp_poly - S^val
            elif p in vars_pc: temp_poly = temp_poly - s^val

        # Remove old main value term
        if initial_main_value > 0:
            if P in vars_pc: temp_poly = temp_poly - P^initial_main_value
            elif p in vars_pc: temp_poly = temp_poly - p^initial_main_value
        
        # Add new main value term, if it's still greater than zero
        if new_main_value > 0:
            if P in vars_pc: temp_poly = temp_poly + P^new_main_value
            elif p in vars_pc: temp_poly = temp_poly + p^new_main_value
        
        # 4. Assign the final, correctly-typed polynomial back to the game state
        GS[i0, j0] = PR(temp_poly)
                
        return GS


def get_captures_by_piece(game_state, piece_coords, verbose=False):
    """
    Finds all possible captures originating from a single piece at a given coordinate.

    This function checks for captures that can be executed by one piece alone:
    - Capture by Numbering (Encounter)
    - Capture by Multiplication
    - Capture by Division

    It does NOT check for captures requiring multiple friendly pieces, such as
    Sum, Difference, or Siege.

    This function helps implement chain captures, *except* for sum, difference, and siege.
    Args:
        game_state: The current board state matrix.
        piece_coords: The (row, col) tuple of the piece to check.
        verbose (bool): If True, prints details of any captures found.

    Returns:
        A list of all valid capture data initiated by the specified piece.

    EXAMPLES:


    """
    GS = copy(game_state)
    r_attacker, c_attacker = piece_coords
    attacker_poly = GS[r_attacker, c_attacker]

    if attacker_poly == 0:
        return []

    found_captures = []
    attacker_values = value_of_piece(GS, r_attacker, c_attacker)
    attacker_is_white = (P in attacker_poly.variables() or S in attacker_poly.variables() or T in attacker_poly.variables() or C in attacker_poly.variables())

    # Determine the list of potential enemy pieces
    enemy_positions_func = positions_b if attacker_is_white else positions_w

    # --- 1. Check for Capture by Numbering ---
    # Get all squares the attacker can land on
    possible_landing_spots = [move[1] for move in lands_on(GS, piece_coords)]
    for spot in possible_landing_spots:
        r_victim, c_victim = spot
        victim_poly = GS[r_victim, c_victim]
        if victim_poly != 0:
            victim_values = value_of_piece(GS, r_victim, c_victim)
            # Check if any attacker value matches any victim value
            if not set(attacker_values).isdisjoint(victim_values):
                # Format is based on valid_captures_by_numbering_*
                capture_record = [(piece_coords, attacker_values, attacker_poly), (spot, victim_values, victim_poly)]
                found_captures.append(capture_record)
                if verbose:
                    print(f"Capture Found: {attacker_poly} at {piece_coords} can capture {victim_poly} at {spot} by Numbering.")

    # --- 2. Check for Capture by Multiplication and Division ---
    enemy_pieces = enemy_positions_func(GS, verbose=True)
    for victim_data in enemy_pieces:
        victim_coords, victim_poly = victim_data
        r_victim, c_victim = victim_coords
        
        # Calculate distance (number of empty spaces)
        dist_spaces = pieces_in_a_line(GS, piece_coords, victim_coords)
        if dist_spaces < 1: # Requires at least one space between them
            continue

        victim_values = value_of_piece(GS, r_victim, c_victim)
        # Check all value combinations
        for v_attacker in attacker_values:
            for v_victim in victim_values:
                # Multiplication Check
                if v_attacker * dist_spaces == v_victim:
                    capture_record = [(piece_coords, v_attacker, attacker_poly), (victim_coords, v_victim, victim_poly)]
                    found_captures.append(capture_record)
                    if verbose:
                        print(f"Capture Found: {attacker_poly} (value {v_attacker}) at {piece_coords} can capture {victim_poly} (value {v_victim}) at {victim_coords} by Multiplication (separation {dist_spaces}).")
                
                # Division Check
                if v_attacker > 0 and v_victim > 0 and v_attacker % v_victim == 0:
                    if v_attacker / v_victim == dist_spaces:
                        capture_record = [(piece_coords, v_attacker, attacker_poly), (victim_coords, v_victim, victim_poly)]
                        found_captures.append(capture_record)
                        if verbose:
                            print(f"Capture Found: {attacker_poly} (value {v_attacker}) at {piece_coords} can capture {victim_poly} (value {v_victim}) at {victim_coords} by Division (separation {dist_spaces}).")

    return found_captures


##########################################################################################


def circle_positions_white(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of White's circles.
    Does not return circles in the pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: circle_positions_white(GS)
        [(2, 2), (2, 3), (3, 2), (3, 3), (4, 2), (4, 3), (5, 2), (5, 3)]
        sage: circle_positions_white(GS, verbose = True)
        [(C^64, 2, 2), (C^8, 2, 3), (C^36, 3, 2), (C^6, 3, 3),
         (C^16, 4, 2), (C^4, 4, 3), (C^4, 5, 2), (C^2, 5, 3)]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: circle_positions_white(GSp, verbose = False)
        [(1, 1), (2, 2), (2, 3), (3, 2), (3, 3), (4, 2), (4, 3), (5, 2), (5, 3)]
        sage: circle_positions_white(GSp, verbose = True)
        [(S^36 + S^25 + T^16 + T^9 + C^4 + C^2 + 91*P, 1, 1),
         (C^64, 2, 2),
         (C^8, 2, 3),
         (C^36, 3, 2),
         (C^6, 3, 3),
         (C^16, 4, 2),
         (C^4, 4, 3),
         (C^4, 5, 2),
         (C^2, 5, 3)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            #print(g)
            vars = g.variables()
            if (C in vars):
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos

def circle_positions_black(GS, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of Black's circles.
    Does not return circles in the pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: circle_positions_black(GS)
        [(2, 12), (2, 13), (3, 12), (3, 13), (4, 12), (4, 13), (5, 12), (5, 13)]
        sage: circle_positions_black(GS, verbose = True)
        [(c^3, 2, 12), (c^9, 2, 13), (c^5, 3, 12), (c^25, 3, 13),
         (c^7, 4, 12), (c^49, 4, 13), (c^9, 5, 12), (c^81, 5, 13)]

    """
    #c,C,p,P,t,T,s,S,C1,t1,T1,s1,S1 = var("c,C,p,P,t,T,s,S,C1,t1,T1,s1,S1") ####  s1, S1, t1, T1, C1 are pieces "inside" the pyramid and aren't independent
    #PR = ZZ[c,C,p,P,t,T,s,S,C1,t1,T1,s1,S1]
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            #print(g)
            vars = g.variables()
            if c in vars:
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos
    
def triangle_positions_white(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of white triangles.
    Does not return triangles in the pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: triangle_positions_white(GS)
        [(0, 2), (1, 2), (2, 1), (3, 1), (4, 1), (5, 1), (6, 2), (7, 2)]
        sage: triangle_positions_white(GS, verbose = True)
        [(T^81, 0, 2), (T^72, 1, 2), (T^49, 2, 1), (T^42, 3, 1),
         (T^20, 4, 1), (T^25, 5, 1), (T^6, 6, 2), (T^9, 7, 2)]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: triangle_positions_white(GSp, verbose=True)
        [(T^81, 0, 2),
         (S^36 + S^25 + T^16 + T^9 + C^4 + C^2 + 91*P, 1, 1),
         (T^72, 1, 2),
         (T^49, 2, 1),
         (T^42, 3, 1),
         (T^20, 4, 1),
         (T^25, 5, 1),
         (T^6, 6, 2),
         (T^9, 7, 2)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            #print(g)
            vars = g.variables()
            if (T in vars):
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos
    
def triangle_positions_black(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of Black's triangles.
    Does not return triangles in the pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: triangle_positions_black(GS, verbose = True)
        [(t^16, 0, 13), (t^12, 1, 13), (t^36, 2, 14), (t^30, 3, 14),
         (t^56, 4, 14), (t^64, 5, 14), (t^90, 6, 13), (t^100, 7, 13)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            #print(g)
            vars = g.variables()
            if (t in vars):
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos

def square_positions_white(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of white squares.
    Does not return square sub-pieces in the pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: square_positions_white(GS)
        [(0, 0), (0, 1), (1, 0), (1, 1), (6, 0), (6, 1), (7, 0), (7, 1)]
        sage: square_positions_white(GS, verbose = True)
        [(S^289, 0, 0), (S^153, 0, 1), (S^169, 1, 0), (S^91 + P, 1, 1),
         (S^15, 6, 0), (S^45, 6, 1), (S^25, 7, 0), (S^81, 7, 1)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            #print(g)
            vars = g.variables()
            if (S in vars):
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos
    
def square_positions_black(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of black squares.
    Does not return square sub-pieces in the pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: square_positions_black(GS, verbose = True)
        [(s^28, 0, 14), (s^49, 0, 15), (s^66, 1, 14), (s^121, 1, 15),
         (s^120, 6, 14), (s^225, 6, 15), (s^190 + p, 7, 14), (s^361, 7, 15)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            #print(g)
            vars = g.variables()
            if (s in vars):
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos
    
def pyramid_positions_white(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of white pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: pyramid_positions_white(GS)
        [(1, 1)]
        sage: pyramid_positions_white(GS, verbose = True)
        [(S^91 + P, 1, 1)]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: pyramid_positions_white(GSp, verbose = True)
        [(S^36 + S^25 + T^16 + T^9 + C^4 + C^2 + 91*P, 1, 1)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            if g == 0:
                continue
            #print(g)
            vars = g.variables()
            if P in vars:
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos

def pyramid_positions_black(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of the black pyramid.
    
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: pyramid_positions_black(GS, verbose = True)
        [(s^190 + p, 7, 14)]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: pyramid_positions_black(GSp, verbose = True)
        [(s^64 + s^49 + t^36 + t^25 + c^16 + 190*p, 7, 14)]


    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = A[i,j]
            if g == 0:
                continue
            vars = g.variables()
            #print(i,j, g, vars)
            if p in vars:
                if verbose:
                    pos = pos + [[(i, j), g]]
                else:
                    pos = pos + [(i, j)]
    return pos
    
def positions_w(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of white pieces.
    
    The verbose option has no effect (on purpose, to be consistent with earlier code...).

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: positions_w(GS)
         [[(0, 0), S^289], [(0, 1), S^153], [(0, 2), T^81], [(1, 0), S^169], 
          [(1, 1), P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S], [(1, 2), T^72], [(2, 1), T^49], 
          [(2, 2), C^64], [(2, 3), C^8], [(3, 1), T^42], [(3, 2), C^36], 
          [(3, 3), C^6], [(4, 1), T^20], [(4, 2), C^16], [(4, 3), C^4], 
          [(5, 1), T^25], [(5, 2), C^4], [(5, 3), C^2], [(6, 0), S^81], 
          [(6, 1), S^45], [(6, 2), T^6], [(7, 0), S^25], [(7, 1), S^15], [(7, 2), T^9]]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: positions_w(GSp, verbose=True)
         [[(0, 0), S^289], [(0, 1), S^153], [(0, 2), T^81], [(1, 0), S^169],
          [(1, 1), P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S], [(1, 2), T^72], [(2, 1), T^49],
          [(2, 2), C^64], [(2, 3), C^8], [(3, 1), T^42], [(3, 2), C^36],
          [(3, 3), C^6], [(4, 1), T^20], [(4, 2), C^16], [(4, 3), C^4],
          [(5, 1), T^25], [(5, 2), C^4], [(5, 3), C^2], [(6, 0), S^81],
          [(6, 1), S^45], [(6, 2), T^6], [(7, 0), S^25], [(7, 1), S^15], [(7, 2), T^9]]

    """
    GS = copy(game_state)
    PR, (_,C,_,P,_,T,_,S) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    A = Mat(PR, 8, 16)(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = PR(A[i,j])
            if g == 0:
                continue
            vars_g = g.variables()
            if (C in vars_g) or (T in vars_g) or (S in vars_g) or (P in vars_g):
                    pos.append([(i, j), g])
    return pos


def positions_b(game_state, verbose=False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of black pieces.

    The verbose option has no effect (on purpose, to be consistent with earlier code...).

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: pos_b = positions_b(GS); len(pos_b)
        24
        sage: positions_b(GS, verbose = True)
         [[(0, 13), t^16], [(0, 14), s^28], [(0, 15), s^49], [(1, 13), t^12],
          [(1, 14), s^66], [(1, 15), s^121], [(2, 12), c^3], [(2, 13), c^9],
          [(2, 14), t^36], [(3, 12), c^5], [(3, 13), c^25], [(3, 14), t^30],
          [(4, 12), c^7], [(4, 13), c^49], [(4, 14), t^56], [(5, 12), c^9],
          [(5, 13), c^81], [(5, 14), t^64], [(6, 13), t^90], [(6, 14), s^120],
          [(6, 15), s^225], [(7, 13), t^100], [(7, 14), s^190 + p], [(7, 15), s^361]]
    """
    GS = copy(game_state)
    PR, (c,_,p,_,t,_,s,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    A = Mat(PR, 8, 16)(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = PR(A[i,j])
            if g == 0:
                continue
            vars_g = g.variables()
            if (c in vars_g) or (t in vars_g) or (s in vars_g) or (p in vars_g):
                    pos.append([(i, j), g])
    return pos


########################################################################################
## The default is MOVES_CIRCLE_DIAGONAL = False.
## If MOVES_CIRCLE_DIAGONAL = True:
## rename moves_circle_white and moves_circle_black as
## moves_circle_white2 and moves_circle_black2, and then
## With this name change, the circle moves are diagonal
#######################################################################################

def moves_circle_white(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which white has a legal circle move.

    CIRCLE_MOVE_ORTHOGONAL = True

    EXAMPLES:

        sage: GS = board_initial_matrix()
        sage: moves_circle_white(GS, verbose = True)
        [(C^8, (2, 3), (1, 3)), (C^8, (2, 3), (2, 4)),
         (C^6, (3, 3), (3, 4)), (C^4, (4, 3), (4, 4)),
         (C^2, (5, 3), (6, 3)), (C^2, (5, 3), (5, 4))]

    """
    GS = copy(game_state)
    PR, (_,C,_,_,_,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the White Circle(s)
    cpw_coords = [item[0] for item in positions_w(GS) if C in item[1].variables()]

    # Define the possible move patterns for a circle (orthogonal)
    circle_move_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    mvs = []
    for start_pos in cpw_coords:
        for inc in circle_move_increments:
            dest = (start_pos[0] + inc[0], start_pos[1] + inc[1])
            
            if in_bounds(dest):
                # A circle only needs to check if the destination is empty.
                if dest not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs


def moves_circle_black(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which black has a legal circle move.

    CIRCLE_MOVE_ORTHOGONAL = True

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_circle_black(GS, verbose = True)
         [(c^3, (2, 12), (2, 11)), (c^3, (2, 12), (1, 12)),
          (c^5, (3, 12), (3, 11)), (c^7, (4, 12), (4, 11)),
          (c^9, (5, 12), (5, 11)), (c^9, (5, 12), (6, 12))]
        
    """
    GS = copy(game_state)
    PR, (c,_,_,_,_,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the Black Circle(s)
    cpb_coords = [item[0] for item in positions_b(GS) if c in item[1].variables()]
    
    # Define the possible move patterns for a circle (orthogonal)
    circle_move_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    mvs = []
    for start_pos in cpb_coords:
        for inc in circle_move_increments:
            dest = (start_pos[0] + inc[0], start_pos[1] + inc[1])
            
            if in_bounds(dest):
                # A circle only needs to check if the destination is empty.
                if dest not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs



def moves_circle_black2(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which black has a legal circle move.

    MOVES_CIRCLE_DIAGONAL = True

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_circle_black2(GS, verbose = True)
        [(c^3, (2, 12), (1, 11)), (c^3, (2, 12), (3, 11)),
         (c^9, (2, 13), (1, 12)), (c^5, (3, 12), (2, 11)),
         (c^5, (3, 12), (4, 11)), (c^7, (4, 12), (3, 11)),
         (c^7, (4, 12), (5, 11)), (c^9, (5, 12), (4, 11)),
         (c^9, (5, 12), (6, 11)), (c^81, (5, 13), (6, 12))]

    """
    GS = copy(game_state)
    cpb = circle_positions_black(GS, verbose = False)
    cpb0 = circle_positions_black(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    circle_move_increments = [[1, 1], [-1, 1], [1, -1], [-1, -1]]  ## MOVES_CIRCLE_DIAGONAL = True
    mvs = []
    for x in cpb:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in circle_move_increments]
        for x0 in x_new:
            #print(x, x0, x in pos, x0 in pos)
            if not(x0 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                ii = cpb.index(x)
                mvs = mvs + [(cpb0[ii][0], x, x0)]
    return mvs

def moves_circle_white2(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which white has a legal circle move.

    MOVES_CIRCLE_DIAGONAL = True

    EXAMPLES:

        sage: GS = board_initial_matrix()
        sage: moves_circle_white2(GS, verbose = True)
        [(C^64, (2, 2), (1, 3)), (C^8, (2, 3), (3, 4)),
         (C^8, (2, 3), (1, 4)), (C^6, (3, 3), (4, 4)),
         (C^6, (3, 3), (2, 4)), (C^4, (4, 3), (5, 4)),
         (C^4, (4, 3), (3, 4)), (C^4, (5, 2), (6, 3)),
         (C^2, (5, 3), (6, 4)), (C^2, (5, 3), (4, 4))]

    """
    GS = copy(game_state)
    cpw = circle_positions_white(GS, verbose = False)
    cpw0 = circle_positions_white(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    circle_move_increments = [[1, 1], [-1, 1], [1, -1], [-1, -1]]  ## MOVES_CIRCLE_DIAGONAL = True
    #print(pos)
    mvs = []
    for x in cpw:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in circle_move_increments]
        for x0 in x_new:
            #print(c, c0, c in pos, c0 in pos)
            if not(x0 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                ii = cpw.index(x)
                mvs = mvs + [(cpw0[ii][0], x, x0)]
    return mvs



def moves_triangle_white(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which white has a legal triangle move.
    These pieces always move orthogonally.

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_triangle_white(GS, verbose = True)
        [(T^81, (0, 2), (0, 4)), (T^72, (1, 2), (1, 4)),
         (T^6, (6, 2), (6, 4)), (T^9, (7, 2), (7, 4))]

    """
    GS = copy(game_state)
    PR, (_,_,_,_,_,T,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the White Triangle(s)
    tpw_coords = [item[0] for item in positions_w(GS) if T in item[1].variables()]

    # Define the possible move patterns for a triangle
    triangle_move_increments = [(0, 2), (0, -2), (2, 0), (-2, 0)]
    path_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    mvs = []
    for start_pos in tpw_coords:
        for i in range(len(triangle_move_increments)):
            dest = (start_pos[0] + triangle_move_increments[i][0], start_pos[1] + triangle_move_increments[i][1])
            
            if in_bounds(dest):
                # Check the intermediate square
                hop1 = (start_pos[0] + path_increments[i][0], start_pos[1] + path_increments[i][1])

                if dest not in pos_coords and hop1 not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs

    
def moves_triangle_black(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which Black has a legal triangle move.
    These pieces always move orthogonally.


    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_triangle_black(GS, verbose = True)
        [(t^16, (0, 13), (0, 11)), (t^12, (1, 13), (1, 11)),
         (t^90, (6, 13), (6, 11)), (t^100, (7, 13), (7, 11))]


    """
    GS = copy(game_state)
    PR, (_,_,_,_,t,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the Black Triangle(s)
    tpb_coords = [item[0] for item in positions_b(GS) if t in item[1].variables()]

    # Define the possible move patterns for a triangle
    triangle_move_increments = [(0, 2), (0, -2), (2, 0), (-2, 0)]
    path_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    mvs = []
    for start_pos in tpb_coords:
        for i in range(len(triangle_move_increments)):
            dest = (start_pos[0] + triangle_move_increments[i][0], start_pos[1] + triangle_move_increments[i][1])
            
            if in_bounds(dest):
                # Check the intermediate square
                hop1 = (start_pos[0] + path_increments[i][0], start_pos[1] + path_increments[i][1])

                if dest not in pos_coords and hop1 not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs

    
def moves_square_white(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which White has a legal square move.
    These pieces always move orthogonally.


    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_square_white(GS, verbose = True)
        [(S^169, (1, 0), (4, 0)), (S^15, (6, 0), (3, 0))]

    """
    GS = copy(game_state)
    PR, (_,_,_,P,_,_,_,S) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the White Square(s), excluding the pyramid
    spw_coords = [item[0] for item in positions_w(GS) if S in item[1].variables() and not P in item[1].variables()]

    # Define the possible move patterns for a square
    square_move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]

    mvs = []
    for start_pos in spw_coords:
        for i in range(len(square_move_increments)):
            dest = (start_pos[0] + square_move_increments[i][0], start_pos[1] + square_move_increments[i][1])
            
            if in_bounds(dest):
                # Check the two intermediate squares
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])

                if dest not in pos_coords and hop1 not in pos_coords and hop2 not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs

    
def moves_square_black(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which Black has a legal square move.
    These pieces always move orthogonally.


    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_square_black(GS, verbose = True)
         [(s^121, (1, 15), (4, 15)), (s^225, (6, 15), (3, 15))]

    """
    GS = copy(game_state)
    PR, (_,_,p,_,_,_,s,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the Black Square(s)
    spb_coords = [item[0] for item in positions_b(GS) if s in item[1].variables() and not p in item[1].variables()]

    # Define the possible move patterns for a square
    square_move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]

    mvs = []
    for start_pos in spb_coords:
        for i in range(len(square_move_increments)):
            dest = (start_pos[0] + square_move_increments[i][0], start_pos[1] + square_move_increments[i][1])
            
            if in_bounds(dest):
                # Check the two intermediate squares
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])

                if dest not in pos_coords and hop1 not in pos_coords and hop2 not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs


def moves_pyramid_black(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which Black has a legal pyramid move.

    PYRAMID_DECOMPOSITION_SQUARES_ONLY = True

    EXAMPLES:
	sage: GSp = board_initial_matrix(pyramid_decomposition = True)   
        sage: moves_pyramid_black(GSp, verbose = True)                 
        []

    """
    GS = copy(game_state)
    PR, (_,_,p,_,_,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the Black Pyramid(s)
    ppb_coords = [item[0] for item in positions_b(GS) if p in item[1].variables()]

    # Define the possible move patterns for a square/pyramid
    square_move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]

    mvs = []
    for start_pos in ppb_coords:
        for i in range(len(square_move_increments)):
            dest = (start_pos[0] + square_move_increments[i][0], start_pos[1] + square_move_increments[i][1])
            
            if in_bounds(dest):
                # Check the two intermediate squares
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])

                if dest not in pos_coords and hop1 not in pos_coords and hop2 not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs



def moves_pyramid_white(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which White has a legal pyramid move.
    This version correctly checks for blocking pieces.

    PYRAMID_DECOMPOSITION_SQUARES_ONLY = True

    EXAMPLES:
	sage: GSp = board_initial_matrix(pyramid_decomposition = True)   
        sage: moves_pyramid_white(GSp, verbose = True)                 
        []

    """
    GS = copy(game_state)
    
    # Get detailed data for all pieces and extract just the coordinates for blocker checking.
    pos_data = positions_w(GS) + positions_b(GS)
    pos_coords = {item[0] for item in pos_data} # Use a set for faster lookups

    # Get just the coordinates of the White Pyramid(s)
    ppw_coords = [item[0] for item in positions_w(GS) if P in item[1].variables()]

    # Define the possible move patterns for a square/pyramid
    square_move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]

    mvs = []
    for start_pos in ppw_coords:
        for i in range(len(square_move_increments)):
            dest = (start_pos[0] + square_move_increments[i][0], start_pos[1] + square_move_increments[i][1])
            
            if in_bounds(dest):
                # Check the two intermediate squares
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])

                if dest not in pos_coords and hop1 not in pos_coords and hop2 not in pos_coords:
                    if verbose:
                        attacker_poly = next((item[1] for item in pos_data if item[0] == start_pos), None)
                        if attacker_poly:
                            mvs.append((attacker_poly, start_pos, dest))
                    else:
                        mvs.append((start_pos, dest))
    return mvs
    
def moves_pyramid_black2(game_state, verbose = False):
    """
    Given the game state matrix, game_state, this function returns all 
    coordinates for which Black has a legal pyramid move.

    ### Assumes pyramid decomposes as squares, triangles and circles.
    ### PYRAMID_DECOMPOSITION_SQUARES_ONLY = False

    EXAMPLES:
	sage: GS1 = board_initial_matrix(pyramid_decomposition = True)   ##### modified initial game state matrix
        sage: moves_pyramid_black2(GS1, verbose = True)                   ##### the Black pyramid is surrounded and can't move
        []

    """
    GS = copy(game_state)
    ppb  = pyramid_positions_black(GS, verbose = False)
    ppb0 = pyramid_positions_black(GS, verbose = True)
    #print(ppb,ppb0)
    i = ppb[0][0]
    j = ppb[0][1]
    g = GS[i,j]
    #print(g)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    vars = g.variables()
    #####circle_move_increments = [[1, 1], [-1, 1], [1, -1], [-1, -1]]  ## MOVES_CIRCLE_DIAGONAL = True
    circle_move_increments = [[1, 0], [-1, 0], [0, 1], [0, -1]]  ## MOVES_CIRCLE_ORTHOGONAL = True
    #print(vars)
    mvs = []
    for x in ppb:
        if (s in vars):
            x_new = [(x[0]+3, x[1]), (x[0]-3, x[1]), (x[0], x[1]-3), (x[0], x[1]+3)]
            x_no1 = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a square
            x_no2 = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)] ## can't jump over a piece using a square
            x_no = x_no1 + x_no2
            for x0 in x_new:
                ii = x_new.index(x0)
                x1 = x_no1[ii] 
                x2 = x_no2[ii]
                if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    mvs = mvs + [(x, x0)]
                if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    jj = ppb.index(x)
                    mvs = mvs + [(ppb0[jj][0], x, x0)]
        if (t in vars):
            x_new = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)]
            x_no = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## xan't jump over a piece using a triangle
            for x0 in x_new:
                ii = x_new.index(x0)
                x1 = x_no[ii]
                #print(x, x0, x in pos, x0 in pos)
                if not(x0 in pos) and not(x1 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    mvs = mvs + [(x, x0)]
                if not(x0 in pos) and not(x1 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    jj = ppb.index(x)
                    mvs = mvs + [(ppb0[jj][0], x, x0)]
        if (c in vars):
            x_new = [(x[0]+a[0], x[1]+a[1]) for a in circle_move_increments]
            for x0 in x_new:
                #print(x, x0, x1, x0 in pos, x1 in pos)
                if not(x0 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    mvs = mvs + [(x, x0)]
                if not(x0 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    jj = ppb.index(x)
                    mvs = mvs + [(ppb0[jj][0], x, x0)]
    return mvs

def moves_pyramid_white2(GS, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which White has a legal pyramid move.

    ### Assumes pyramid decomposes as squares, triangles and circles.
    ### PYRAMID_DECOMPOSITION_SQUARES_ONLY = False

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_pyramid_white(GS, verbose = True) ##### this returns a "false" answer because
	                                              ##### the game state was not setup correctly
        []
	sage: GS1 = board_initial_matrix(pyramid_decomposition = True)   ##### modified initial game state matrix
        sage: moves_pyramid_white(GS1, verbose = True)                   ##### this returns a "true" answer 
        [(S^36 + S^25 + T^16 + T^9 + C^4 + C^2 + 91*P, (1, 1), (2, 0))]


    """
    ppw  = pyramid_positions_white(GS, verbose = False)
    ppw0 = pyramid_positions_white(GS, verbose = True)
    i = ppw[0][0]
    j = ppw[0][1]
    g = GS[i,j]
    #print(g)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    vars = g.variables()
    #print(vars)
    #####circle_move_increments = [[1, 1], [-1, 1], [1, -1], [-1, -1]]  ## MOVES_CIRCLE_DIAGONAL = True
    circle_move_increments = [[1, 0], [-1, 0], [0, 1], [0, -1]]  ## MOVES_CIRCLE_ORTHOGONAL = True
    mvs = []
    for x in ppw:
        if (S in vars):
            x_new = [(x[0]+3, x[1]), (x[0]-3, x[1]), (x[0], x[1]-3), (x[0], x[1]+3)]
            x_no1 = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a square
            x_no2 = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)] ## can't jump over a piece using a square
            x_no = x_no1 + x_no2
            for x0 in x_new:
                ii = x_new.index(x0)
                x1 = x_no1[ii]
                x2 = x_no2[ii]
                if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    mvs = mvs + [(x, x0)]
                if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    jj = ppw.index(x)
                    mvs = mvs + [(ppw0[jj][0], x, x0)]
        if (T in vars):
            x_new = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)]
            x_no = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## xan't jump over a piece using a triangle
            for x0 in x_new:
                ii = x_new.index(x0)
                x1 = x_no[ii]
                #print(x, x0, x in pos, x0 in pos)
                if not(x0 in pos) and not(x1 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    mvs = mvs + [(x, x0)]
                if not(x0 in pos) and not(x1 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    jj = ppw.index(x)
                    mvs = mvs + [(ppw0[jj][0], x, x0)]
        if (C in vars):
            x_new = [(x[0]+a[0], x[1]+a[1]) for a in circle_move_increments]
            #x_no = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a triangle
            #print(x, x in pos, x_new)
            for x0 in x_new:
                #ii = x_new.index(x0)
                #x1 = x_no[ii]
                #print(x, x0, x1, x0 in pos, x1 in pos)
                if not(x0 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    mvs = mvs + [(x, x0)]
                if not(x0 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                    jj = ppw.index(x)
                    mvs = mvs + [(ppw0[jj][0], x, x0)]
    return mvs
    
def is_valid_move(game_state, start_pos, end_pos, player_turn):
    """ 
    Checks if a move is valid according to Rithmomachia rules. 
 
    Args: 
      game_state: The 8x16 matrix representing the board. 
      start_pos: (a0,b0), where a0 = row of the starting position (0-indexed). 
                                b0 = column of the starting position. 
      end_pos: (a1, b1), where a1 = row of the ending position. 
                               b1 = column of the ending position. 
      player_turn: 'white' or 'black' 
 
    Returns: 
      True if the move is valid, False otherwise. Prints a name
      of a movable piece if any.
 
    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: is_valid_move(GS, (6, 0), (3, 0), "white")
        Valid move of a white square.
        True
        sage: is_valid_move(GS, (13, 0), (11, 0), "black")
        False
        sage: is_valid_move(GS, (0, 13), (0, 11), "black")
        Valid move of a black triangle.
        True


    """
    GS = game_state
    if player_turn == "white":
        moves_w = [x[1] for x in moves_pyramid_white(GS, verbose = False)]
        if end_pos in moves_w:
            print("Valid move of White's pyramid.")
            return True
        moves_w = [x[1] for x in moves_circle_white(GS, verbose = False)]
        if end_pos in moves_w:
            print("Valid move of a white circle.")
            return True
        moves_w = [x[1] for x in moves_triangle_white(GS, verbose = False)]
        if end_pos in moves_w:
            print("Valid move of a white triangle.")
            return True
        moves_w = [x[1] for x in moves_square_white(GS, verbose = False)]
        if end_pos in moves_w:
            print("Valid move of a white square.")
            return True
    if player_turn == "black":
        moves_b = [x[1] for x in moves_pyramid_black(GS, verbose = False)]
        if end_pos in moves_b:
            print("Valid move of Black's pyramid.")
            return True
        moves_b = [x[1] for x in moves_circle_black(GS, verbose = False)]
        if end_pos in moves_b:
            print("Valid move of a black circle.")
            return True
        moves_b = [x[1] for x in moves_triangle_black(GS, verbose = False)]
        if end_pos in moves_b:
            print("Valid move of a black triangle.")
            return True
        moves_b = [x[1] for x in moves_square_black(GS, verbose = False)]
        if end_pos in moves_b:
            print("Valid move of a black square.")
            return True
    return False

def move_piece(game_state, start_pos, end_pos, verbose = False):
    """ 
    Moves (*does not capture*) a piece on the game board. 

    Assume: the move is valid. 
    
    Args: 
      game_state: The 8x16 matrix representing the board. 
      start_pos: (a0,b0), where a0 = row of the starting position (0-indexed). 
                                b0 = column of the starting position. 
      end_pos: (a1, b1), where a1 = row of the ending position. 
                               b1 = column of the ending position. 
      player_turn: 'white' or 'black' 
 
    Returns: 
      The updated game_state matrix. 
 
    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: move_piece(GS, (6, 0), (3, 0))
	 <8x16 matrix omitted)
        sage: move_piece(GS, (6, 0), (3, 0), verbose=True)
        White made this move:  S081a7a4
	 <8x16 matrix omitted)
        sage: GS = move_piece(GS, (7, 2), (7, 4))
        sage: GS = move_piece(GS, (5, 12), (6, 11))
        sage: GS = move_piece(GS, (7, 4), (7, 6))
        sage: GS = move_piece(GS, (6, 11), (7, 10))
        sage: GS = move_piece(GS, (7, 6), (7, 8))
        sage: captures_triangle_white(GS, verbose = False)
        [((7, 8), (7, 10))]


    """
    GS = copy(game_state)
    a0 = start_pos[0]
    b0 = start_pos[1]
    x = copy(GS[a0, b0])
    if not(in_bounds(start_pos) and in_bounds(end_pos)):
        print("given coordinates are not in bounds ... ", start_pos, end_pos)
        return GS
    if x==0:
        print("Sorry, piece at ", start_pos, " doesn't exist. There is no move to make!")
        return GS
    a1 = end_pos[0]
    b1 = end_pos[1]
    if not(GS[a1, b1]==0):
        print("Sorry, position/coordinate at ", end_pos, " is occupied by ", GS[a1, b1], ". There is no legal move there!")
        return GS
    ### replace (a0, b0) entry of GS by 0,
    ### replace (a1, b1) entry of GS by previous entry in (a0,b0).
    if verbose:
        pc_letter = str(GS[a0, b0])[0]
        if pc_letter in ["c", "p", "s", "t"]:
            my_color = "Odd"
        else:
            my_color = "Even"
        pc_value = str(sum(value_of_piece(GS, a0, b0)))
        if len(pc_value) == 1:
            pc_value = "00" + pc_value
        if len(pc_value) == 2:
            pc_value = "0" + pc_value
        alg_mv =  coordinate_to_algebraic(a0, b0) +  coordinate_to_algebraic(a1, b1)
        if my_color == "Even":
            print(" White made this move: ",  pc_letter + pc_value + alg_mv)
        else:
            print(" Black made this move: ",  pc_letter + pc_value + alg_mv)
    GS[a1, b1] = x
    GS[a0, b0] = 0
    return GS

    

############ a program that randomly generates a move (quickly),
############ displays the game board position and asks for the next move.
############ does it play better inside jupiter notebook ??
# Start with a call to either
# (1) take_all_captures_black(game_state, verbose = False)                
# or
# (2) take_all_captures_white(game_state, verbose = False)
# as well as (this has redundancies)
# (3) legal_moves_captures_black(GS)
# or
# (4) legal_moves_captures_white(GS)
# Now, pick a legal move at random (if the move goes "backwards"
# then pick first one that goes "forward")
# End by displaying the game state and asking for the next move.

def play_a_game(current_game_state, my_color, verbose = False):
    """
    input 
    * the current game state <current_game_state> (an 8x16 matrix for the game state after I make
    my move and take captures),
    * my color (my_color = "Even" or "Odd")
   
    From this the computer
    * calls take_all_captures_black/white
    * makes a random legal move
    * returns that move and (optionally, if verbose = True) the resulting game state)
    * then prints information (displays the next game state, says "make your next move", ... )

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS = move_piece(GS, (1, 2), (1, 4))
        sage: mv, GSmv = play_a_game(GS, my_color = "Even", verbose = True)
        There were  0  captures of Black's pieces by White.
        Computer's move is:  ((6, 15), (3, 15))  (captures not listed)
        It's your turn now.  
         Make your next move! 
         (To continue playing, take your next turn and reinput that game state.)
        Launched png viewer for Graphics object consisting of 185 graphics primitives
        sage: GS1 = copy(GSmv)
        sage: GS1 = take_all_captures_white(GS1, verbose=True)
        There were  0  captures of Black's pieces by White.
        sage: GS1 = move_piece(GS1, (1, 4), (1, 6))
        sage: GS2 = take_all_captures_white(GS1, verbose=True)
        Capture by multiplication/division on  (1, 13)
        There were  1  captures of Black's pieces by White.
        sage: board_plot(GS2)
        Launched png viewer for Graphics object consisting of 182 graphics primitives
        sage: GS2 = move_piece(GS2, (7, 2), (7, 4))
        sage: mv, GSmv = play_a_game(GS2, my_color = "Even", verbose = True)
        There were  0  captures of Black's pieces by White.
        Computer's move is:  ((6, 13), (6, 11))  (captures not listed)
        It's your turn now.  
         Make your next move! 
         (To continue playing, take your next turn and reinput that game state.)
        Launched png viewer for Graphics object consisting of 182 graphics primitives

    """
    GS = copy(current_game_state)
    if my_color == "Even":
        GSc = take_all_captures_black(GS)
        leg_mvs = legal_moves_captures_black(GSc)[0]
        num_mvs = len(leg_mvs)
        ran_ind = random.randint(0, num_mvs-1)
        ran_mv = leg_mvs[ran_ind]
        pc_letter = str(GSc[ran_mv[0][0], ran_mv[0][1]])[0]
        pc_value = str(sum(value_of_piece(GSc, ran_mv[0][0], ran_mv[0][1])))
        if len(pc_value) == 1:
            pc_value = "00" + pc_value
        if len(pc_value) == 2:
            pc_value = "0" + pc_value
        GScm = move_piece(GSc, ran_mv[0], ran_mv[1], verbose = True)
        GScmc = take_all_captures_black(GScm, verbose=True)
        alg_mv =  coordinate_to_algebraic(ran_mv[0][0], ran_mv[0][1]) +  coordinate_to_algebraic(ran_mv[1][0], ran_mv[1][1])
        print("Computer's move is: ", ran_mv, " that is, ", pc_letter + pc_value + alg_mv, ". (captures not listed)")
        print("It's your turn now.  \n Make your next move! \n (To continue playing, take your next turn and reinput that game state.)")
        show(board_plot(GScmc))
        if verbose:
            return ran_mv, GScmc
        return ran_mv
    else:
        GSc = take_all_captures_white(GS)
        leg_mvs = legal_moves_captures_white(GSc)[0]
        num_mvs = len(leg_mvs)
        ran_ind = random.randint(0, num_mvs-1)
        ran_mv = leg_mvs[ran_ind]
        pc_letter = str(GSc[ran_mv[0][0], ran_mv[0][1]])[0]
        pc_value = str(sum(value_of_piece(GSc, ran_mv[0][0], ran_mv[0][1])))
        if len(pc_value) == 1:
            pc_value = "00" + pc_value
        if len(pc_value) == 2:
            pc_value = "0" + pc_value
        GScm = move_piece(GSc, ran_mv[0], ran_mv[1], verbose = True)
        GScmc = take_all_captures_white(GScm, verbose=True)
        alg_mv =  coordinate_to_algebraic(ran_mv[0][0], ran_mv[0][1]) +  coordinate_to_algebraic(ran_mv[1][0], ran_mv[1][1])
        print("Computer's move is: ", ran_mv, " that is, ", pc_letter + pc_value + alg_mv, ". (captures not listed)")
        print("It's your turn now.  \n Make your next move! \n (To continue playing, take your next turn and reinput that game state.)")
        show(board_plot(GScmc))
        if verbose:
            return ran_mv, GScmc
        return ran_mv


def play_human_vs_computer_round(gs_before_human_action, history_list, human_action_algebraic, verbose = False):
    """
    Processes one full round: human's move + computer's response.
    Updates and returns the game state, history list, and LaTeX outputs.

    Args:
        gs_before_human_action: Current game state matrix before human's move.
        history_list: List of past completed rounds. Each round is 
                [even_mvs_list, odd_mvs_list, even_cap_list, odd_cap_list].
        human_action_algebraic: Algebraic string for the human's current move (e.g., "C036c4c8").
                                This is the move made after White's first round of captures
                                but before the 2nd round of captures.

    ##################### Note: even_cap_list, odd_cap_list keep track of move numbers
    ##################### by adding an empty list when there is no capture, so all have the same length
    
    Returns:
        new_gs_after_computer: Game state after computer's full turn.
        updated_history_list: The history_list including the round just played.
        latex_diagram_str: LaTeX string for the board diagram of new_gs_after_computer.
        latex_moves_table_str: LaTeX string for the table of moves from updated_history_list.

    ####### the computer plays faster because it picks the (legal) move randomly.

    EXAMPLES:
         sage: GSp = board_initial_matrix(pyramid_decomposition = True)
         sage: even_mvs = []; odd_mvs = []; even_caps = []; odd_caps = []
         sage: history_list = [even_mvs, odd_mvs, even_caps, odd_caps]
         sage: human_move_alg = "C002d6e6"
         sage: phvcr1 = play_human_vs_computer_round(GSp, history_list, human_move_alg)
         There were  0  captures of White pieces by Black.
         Computer's move is:  ((3, 12), (3, 11))  that is,  c005m4l4 . Captures:  []
         It's your turn now, human.  
          Make your next move, weakling!
         sage: phvcr1[0]
         ((3, 12), (3, 11))
         sage: phvcr1[1]
         [['C002d6e6'], ['c005m4l4'], [], []]


    """
    current_gs = copy(gs_before_human_action)
    human_move_alg = human_action_algebraic # Already in algebraic
    mv_coords = [ algebraic_to_coordinate(human_move_alg[-4:-2]), algebraic_to_coordinate(human_move_alg[-2:])]
    computer_move_alg = ""
    hist_lst1 = copy(history_list)
    even_mvs = hist_lst1[0]
    odd_mvs = hist_lst1[1]
    even_caps = hist_lst1[2]
    odd_caps = hist_lst1[3]
    gs_cap1 = take_all_captures_white(current_gs, verbose=True)
    leg_caps1 = legal_moves_captures_white(current_gs)[1] ## all captures but not in algebraic notation
    #even_caps = even_caps + leg_caps1
    ## add caps to history
    #print(mv_coords, gs_cap1[mv_coords[0][0], mv_coords[0][1]], gs_cap1[mv_coords[1][0], mv_coords[1][1]])
    gs_cap1m = move_piece(gs_cap1, mv_coords[0], mv_coords[1], verbose)
    even_mvs = even_mvs + [human_move_alg]
    ## add mv to history
    gs_cap2 = take_all_captures_white(gs_cap1m, verbose=True)
    leg_caps2 = legal_moves_captures_white(gs_cap1m)[1] ## all captures but not in algebraic notation
    even_caps = even_caps + [leg_caps1 + leg_caps2]
    ## add caps to history
    ############################### now make odd/black/computers move:
    gs_cap3 = take_all_captures_black(gs_cap2, verbose=True)
    leg_mvs = legal_moves_captures_black(gs_cap3)[0]
    leg_caps3 = legal_moves_captures_black(gs_cap2)[1]
    #odd_caps = odd_caps + leg_caps3
    num_mvs = len(leg_mvs)
    ran_ind = random.randint(0, num_mvs-1)
    ran_mv = leg_mvs[ran_ind]
    odd_mv_alg = get_algebraic_move_string(gs_cap3, ran_mv[0], ran_mv[1])
    odd_mvs = odd_mvs + [odd_mv_alg]
    pc_letter = str(gs_cap3[ran_mv[0][0], ran_mv[0][1]])[0]
    pc_value = str(sum(value_of_piece(gs_cap3, ran_mv[0][0], ran_mv[0][1])))
    if len(pc_value) == 1:
        pc_value = "00" + pc_value
    if len(pc_value) == 2:
        pc_value = "0" + pc_value
    gs_cap3m = move_piece(gs_cap3, ran_mv[0], ran_mv[1], verbose)
    gs_cap4 = take_all_captures_black(gs_cap3m, verbose=True)
    leg_caps4 = legal_moves_captures_black(gs_cap3m)[1]
    odd_caps = odd_caps + [leg_caps3 + leg_caps4]
    alg_mv =  coordinate_to_algebraic(ran_mv[0][0], ran_mv[0][1]) +  coordinate_to_algebraic(ran_mv[1][0], ran_mv[1][1])
    print("Computer's move is: ", ran_mv, " that is, ", pc_letter + pc_value + alg_mv, ". Captures: ", leg_caps3+leg_caps4)
    print("Now, you weakling, resign or ...  \n ... make your next move!")
    if verbose:
        show(board_plot(gs_cap4))
    hist_lst2 = [even_mvs, odd_mvs, even_caps, odd_caps]
    pc_list = game_state_to_piece_list(gs_cap4)
    latex_str = piece_list_to_latex(pc_list, verbose)
    return ran_mv, hist_lst2, latex_str, gs_cap4


def blacks_turn(game_state, method_best = True):
    """
    Executes Black's turn according to the specified logic:
    1. Perform all possible initial captures.
    2. Find and execute the best move/action (move or capture).
    3. Perform all possible captures available after the best action.

    If method_best = False then the algorithm will look for a
    good (but randomly selected) move using good_move_black.

    Assumes the game state was initialized with pyramid_decomposition=True,
    as required by find_best_move_white.

    Args:
        game_state: The current game state matrix (SageMath Matrix).

    Returns:
        The updated game state matrix after White's turn is complete.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3,13] = 0; GS[5,0] = c^(25)
        sage: time blacks_turn(GS)
         Capture by numbering on  (5, 1)
         There were  1  captures of White pieces by Black.
         White's best move: move piece at  (2, 13)  to  (3, 13)
         There were  0  captures of White pieces by Black.
         CPU times: user 2min 39s, sys: 276 ms, total: 2min 40s
         Wall time: 2min 40s
         <8x16 game state matrix omitted>

    """
    current_GS = copy(game_state)
    state_after_initial_captures = take_all_captures_black(current_GS, verbose = True)
    # Ensure pyramid_decomposition=True is used implicitly or explicitly if needed by find_best_move
    if not(method_best):
        best_action_data = good_move_black(state_after_initial_captures, verbose = True)
    else:
        best_action_data = find_best_move_black(state_after_initial_captures, verbose = True)
    state_after_move = move_piece(state_after_initial_captures, best_action_data[0], best_action_data[1])
    final_state = take_all_captures_black(state_after_move, verbose = True)
    return final_state, best_action_data


def whites_turn(game_state, method_best = True):
    """
    Executes White's turn according to the specified logic:
    1. Perform all possible initial captures.
    2. Find and execute the best move/action (move or capture).
    3. Perform all possible captures available after the best action.
    4. Returns a pair game_state, mv, where game_state is the
       game state after the move and mv is the move selected.

    If method_best = False then the algorithm will look for a
    good (but randomly selected) move using good_move_white. # Corrected comment

    Assumes the game state was initialized with pyramid_decomposition=True,
    as required by find_best_move_white.

    Args:
        game_state: The current game state matrix (SageMath Matrix).
        method_best: If True, uses find_best_move_white. If False, uses good_move_white.
        # verbose parameter was in docstring but not in function signature, added for consistency if used by called functions
    Returns:
        The updated game state matrix after White's turn is complete, and the move made.

    EXAMPLES:
        sage: # Example 1: Simple move, no captures
        sage: GSp = board_initial_matrix(pyramid_decomposition=True)
        sage: final_state_1 = whites_turn(GSp)
         There were  0  captures of Black's pieces by White.
         White's best move: move piece at  (3, 3)  to  (3, 4)
         There were  0  captures of Black's pieces by White.
        sage: # Example 2: Scenario with initial capture then move
        sage: GSp2 = board_initial_matrix(pyramid_decomposition=True)
        sage: # Set up a capture by division: T^12 at (1,10) captures t^6 at (1,13) (dist 2)
        sage: GSp2[1, 10] = T^12
        sage: GSp2[6, 2] = 0 # Make space for T12 original pos if needed
        sage: GSp2[1, 13] = t^6
        sage: GSp2[1, 12] = 0 # Clear path
        sage: final_state_2 = whites_turn(GSp2)
         Capture by multiplication/division on  (1, 13)
         There were  1  captures of Black's pieces by White.
         White's best move: move piece at  (3, 3)  to  (3, 4)
         There were  0  captures of Black's pieces by White.

    """
    current_GS = copy(game_state)
    # Assuming take_all_captures_white handles verbosity internally or doesn't need it passed.
    state_after_initial_captures = take_all_captures_white(current_GS, verbose = True)

    if not(method_best):
        # CRITICAL FIX: Call good_move_white instead of good_move_black
        # This assumes good_move_white function exists and works like good_move_black but for White.
        print("White is using good_move_white (random good move).") # Optional: for debugging
        best_action_data = good_move_white(state_after_initial_captures, verbose = True)
    else:
        print("White is using find_best_move_white (optimal move).") # Optional: for debugging
        best_action_data = find_best_move_white(state_after_initial_captures, verbose = True)
    
    # Ensure best_action_data is not None and is in the expected format (start_pos, end_pos)
    if best_action_data is None or not (isinstance(best_action_data, (list, tuple)) and len(best_action_data) == 2):
        print("Error: No valid move found for White.")
        # Handle error appropriately: maybe return original state or raise an exception
        # For now, returning original state and a None move to prevent crash
        return game_state, None 

    start_pos, end_pos = best_action_data

    # It's good practice to check if the move is valid before applying
    # For example, check if start_pos and end_pos are valid coordinates
    # and if a piece actually exists at start_pos that belongs to White.
    # This depends on how good_move_white/find_best_move_white return values.

    state_after_move = move_piece(state_after_initial_captures, start_pos, end_pos)
    final_state = take_all_captures_white(state_after_move, verbose = True)
    
    return final_state, best_action_data


def rithmomachia_command_line(matplotlib_graphics = False, machine="odd"):
    """
    Plays a game of rithmomachia, keeping track of moves, and captures.

    If matplotlib_graphics = True the the board display function display_board_matplotlib
    is used instead of board_plot. This option is slow and BUGGY.
    ############################# FIX THESE BUGS!!!!!!!!!
    
    Parameters:
        matplotlib_graphics : bool
        machine : str
            "odd" (default) -> bot plays Black
            "even" -> bot plays White

    EXAMPLES:
        sage: rithmomachia_command_line()
        Your move. For the piece's starting coordinate (x0, y0), enter x0 or 'Q' to quit: 
        0
        For the piece's starting coordinate (x0, y0), enter y0: 
        2
        Now for ending coordinate (x1, y1), enter x1: 
        0
        For ending coordinate (x1, y1), enter y1: 
        4
        There were  0  captures of Black's pieces by White.
        There were  0  captures of Black's pieces by White.
        You played T^81c1e1
        Launched png viewer for Graphics object consisting of 185 graphics primitives

         Computing Black's move ...
        There were  0  captures of White pieces by Black.
        ((2, 12), (2, 11))  is a *good* move
        There were  0  captures of White pieces by Black.
        Launched png viewer for Graphics object consisting of 185 graphics primitives
        Your move. For the piece's starting coordinate (x0, y0), enter x0 or 'Q' to quit: 
        1
        For the piece's starting coordinate (x0, y0), enter y0: 
        2
        Now for ending coordinate (x1, y1), enter x1: 
        1
        For ending coordinate (x1, y1), enter y1: 
        4
        There were  0  captures of Black's pieces by White.
        There were  0  captures of Black's pieces by White.
        You played T^72c2e2
        Launched png viewer for Graphics object consisting of 185 graphics primitives

         Computing Black's move ...
        There were  0  captures of White pieces by Black.
        ((4, 12), (4, 11))  is a *good* move
        There were  0  captures of White pieces by Black.
        Launched png viewer for Graphics object consisting of 185 graphics primitives
        Your move. For the piece's starting coordinate (x0, y0), enter x0 or 'Q' to quit: 
        1
        For the piece's starting coordinate (x0, y0), enter y0: 
        4
        Now for ending coordinate (x1, y1), enter x1: 
        1
        For ending coordinate (x1, y1), enter y1: 
        6
        There were  0  captures of Black's pieces by White.
        The piece component T^72 (value 72) at (1, 6) captures by division the piece component t^12 (value 12) at (1, 13) at separation 6
        Capture by multiplication/division on  (1, 13)
        There were  1  captures of Black's pieces by White.
        You played T^72e2g2
        Launched png viewer for Graphics object consisting of 182 graphics primitives

         Computing Black's move ...
        There were  0  captures of White pieces by Black.
        ((4, 11), (4, 10))  is a *good* move
        There were  0  captures of White pieces by Black.
        Launched png viewer for Graphics object consisting of 182 graphics primitives
        Your move. For the piece's starting coordinate (x0, y0), enter x0 or 'Q' to quit: 
        Q
        Good bye!
        White moves:  ['T^81c1e1', 'T^72c2e2', 'T^72e2g2'] 
         White captures:  [[], [], [[((1, 6), 72, T^72), ((1, 13), 12, t^12)]]] 
         Black moves:  ['c^3m3l3', 'c^7m5l5', 'c^7l5k5'] 
         Black captures:  [[], [], []]
        ################################ a second game
	sage: rithmomachia_command_line(machine="even")
	Computing White's move ...
	There were  0  captures of Black pieces by White.
	White is using good_move_white (random good move).
	((0, 2), (0, 4))  is a *best* move
	There were  0  captures of Black pieces by White.
	Launched png viewer for Graphics object consisting of 185 graphics primitives
	Your move. Enter starting coordinate x0 or 'Q' to quit: 
	1
	Enter y0:
	13
	Enter x1:
	1
	Enter y1:
	11
	There were  0  captures of White pieces by Black.
	There were  0  captures of White pieces by Black.
	You played t^12n2l2
	Launched png viewer for Graphics object consisting of 185 graphics primitives
	Computing White's move ...
	There were  0  captures of Black pieces by White.
	White is using good_move_white (random good move).
	((1, 2), (1, 4))  is a *bestest* move
	Capture by multiplication/division on  (1, 11)
	There were  1  captures of Black pieces by White.
	Launched png viewer for Graphics object consisting of 182 graphics primitives
	Your move. Enter starting coordinate x0 or 'Q' to quit: 
	2
	Enter y0:
	13
	Enter x1:
	1
	Enter y1:
	13
	There were  0  captures of White pieces by Black.
	Capture by multiplication/division on  (1, 4)
	There were  1  captures of White pieces by Black.
	You played c^9n3n2
	Launched png viewer for Graphics object consisting of 180 graphics primitives
	Computing White's move ...
	There were  0  captures of Black pieces by White.
	White is using good_move_white (random good move).
	((1, 1), (1, 4))  is a *best* move
	There were  0  captures of Black pieces by White.
	Launched png viewer for Graphics object consisting of 180 graphics primitives
	Your move. Enter starting coordinate x0 or 'Q' to quit: 
	Q
	Good bye!
	(['T^81c1e1', 'T^72c2e2', 'P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + Sb2e2'],
	 ['t^12n2l2', 'c^9n3n2'],
	 [[], [], []],
	 [[], []])

    """
    if matplotlib_graphics:
        print("         ########### Note ############      ")
        print("Matplotlib graph display pauses the program, so they must be closed before you can make your next move.")
        print("            #######################      ")
    Z0 = ZZ^2
    playing = True
    even_mvs  = []
    odd_mvs   = []
    even_caps = []
    odd_caps  = []
    game_state = board_initial_matrix(pyramid_decomposition = True)
    GS = copy(game_state)
    for aa in range(1000):
        if playing:
            if machine == "even":
                # Bot plays White
                print("Computing White's turn ...")
                even_caps += [legal_moves_captures_white(GS)[1]]
                GS, mv = whites_turn(GS, method_best=False)
                s0, t0 = mv[0]
                s1, t1 = mv[1]
                pc_sym = str(GS[s1, t1])
                even_mvs.append(pc_sym + coordinate_to_algebraic(s0, t0) + coordinate_to_algebraic(s1, t1))
                if matplotlib_graphics == True:
                    print("Move displayed using matplotlib. Computing next turn ...")
                    dbm = display_board_matplotlib(GS)
                    plt.show()
                else:
                    board_plot(GS).show()
                # Human (Black, if machine="even") move
                legal_move = False
                while not(legal_move):
                    print("Your move. Enter starting coordinate x0 or 'Q' to quit: ")
                    pc_start_x = input()
                    if pc_start_x == "Q":
                        legal_move = True
                        playing = False
                        print("Good bye!")
                        return even_mvs, odd_mvs, even_caps, odd_caps
                    x0 = int(pc_start_x)
                    print("Enter y0:")
                    y0 = int(input())
                    pc_sym = str(GS[x0, y0])
                    print("Enter x1:")
                    x1 = int(input())
                    print("Enter y1:")
                    y1 = int(input())
                    if not(is_valid_move(GS, (x0, y0), (x1, y1), player_turn = "black")):
                        print("The move from ", (x0, y0), " to ", (x1, y1), " is not legal. Try again.")
                    else:
                        legal_move = True
                caps0 = legal_moves_captures_black(GS)[1]
                odd_caps.append(caps0)
                GS = take_all_captures_black(GS, verbose=True)
                GS = move_piece(GS, (x0, y0), (x1, y1))
                caps0 = legal_moves_captures_black(GS)[1]
                odd_caps.append(caps0)
                GS = take_all_captures_black(GS, verbose=True)
                print("You played " + pc_sym + coordinate_to_algebraic(x0, y0) + coordinate_to_algebraic(x1, y1))
                if matplotlib_graphics == True:
                    print("Move displayed using matplotlib. Computing next turn ...")
                    display_board_matplotlib(GS)
                else:
                    board_plot(GS).show()
                odd_mvs.append(pc_sym + coordinate_to_algebraic(x0, y0) + coordinate_to_algebraic(x1, y1))

            else:  # Default: bot is Black, human is White
                # Human (White, if machine="odd") move
                legal_move = False
                while not(legal_move):
                    print("Your move. Enter starting coordinate x0 or 'Q' to quit: ")
                    pc_start_x = input()
                    if pc_start_x == "Q":
                        legal_move = True
                        playing = False
                        print("Good bye!")
                        return even_mvs, odd_mvs, even_caps, odd_caps
                    x0 = int(pc_start_x)
                    print("Enter y0:")
                    y0 = int(input())
                    pc_sym = str(GS[x0, y0])
                    print("Enter x1:")
                    x1 = int(input())
                    print("Enter y1:")
                    y1 = int(input())
                    if not(is_valid_move(GS, (x0, y0), (x1, y1), player_turn = "white")):
                        print("The move from ", (x0, y0), " to ", (x1, y1), " is not legal. Try again.")
                    else:
                        legal_move = True
                caps0 = legal_moves_captures_white(GS)[1]
                GS = take_all_captures_white(GS, verbose=True)
                GS = move_piece(GS, (x0, y0), (x1, y1))
                even_caps.append(caps0 + legal_moves_captures_white(GS)[1])
                GS = take_all_captures_white(GS, verbose=True)
                print("You played " + pc_sym + coordinate_to_algebraic(x0, y0) + coordinate_to_algebraic(x1, y1))
                if matplotlib_graphics == True:
                    print("Move displayed using matplotlib. Computing next turn ...")
                    dbm = display_board_matplotlib(GS)
                    plt.show()
                else:
                    board_plot(GS).show()
                even_mvs.append(pc_sym + coordinate_to_algebraic(x0, y0) + coordinate_to_algebraic(x1, y1))		
                # Bot (Black) move
                print("Computing Black's move ...")
                odd_caps += [legal_moves_captures_black(GS)[1]]
                GS, mv = blacks_turn(GS, method_best=False)
                s0, t0 = mv[0]
                s1, t1 = mv[1]
                pc_sym = str(GS[s1, t1])
                odd_mvs.append(pc_sym + coordinate_to_algebraic(s0, t0) + coordinate_to_algebraic(s1, t1))
                if matplotlib_graphics == True:
                    print("Move displayed using matplotlib. Computing next turn ...")
                    dbm = display_board_matplotlib(GS)
                    plt.show()
                else:
                    board_plot(GS).show()
            if is_body_common_victory_black(GS, N0 = 4):
                playing = False
                print("Black/Odd wins 'by body' (common)!")
                print("White moves: ", even_mvs, "\n White captures: ", even_caps, "\n Black moves: ", odd_mvs, "\n Black captures: ", odd_caps)
                break
            if is_body_common_victory_white(GS, N0 = 4):
                playing = False
                print("White/Even wins 'by body' (common)!")
                print("White moves: ", even_mvs, "\n White captures: ", even_caps, "\n Black moves: ", odd_mvs, "\n Black captures: ", odd_caps)
                break
            if is_body_common_victory_black(GS, N0 = 4):
                playing = False
                print("Black/Odd wins 'by body' (common)!")
                print("White moves: ", even_mvs, "\n White captures: ", even_caps, "\n Black moves: ", odd_mvs, "\n Black captures: ", odd_caps)
                break
            if is_small_proper_victory_black(GS):
                playing = False
                print("Black/Odd wins 'by harmonic progression' (proper)!")
                print("White moves: ", even_mvs, "\n White captures: ", even_caps, "\n Black moves: ", odd_mvs, "\n Black captures: ", odd_caps)
                break
            if is_small_proper_victory_white(GS):
                playing = False
                print("White wins 'by harmonic progression' (proper)!")
                print("White moves: ", even_mvs, "\n White captures: ", even_caps, "\n Black moves: ", odd_mvs, "\n Black captures: ", odd_caps)
                break
        else:
            print("White moves: ", even_mvs, "\n White captures: ", even_caps, "\n Black moves: ", odd_mvs, "\n Black captures: ", odd_caps)
    return even_mvs, odd_mvs, even_caps, odd_caps

###############################################################################
############################### captures #############################################
###############################################################################
############################## chain captures are NOT tested or performed ############
###############################################################################

def captures_circle_white(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which White has a legal capture of
    a black piece using a (white) circle.

    MOVES_CIRCLE_ORTHOGONAL = True

    Capture by numbering.
    

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2, 15] = C^(36)
        sage: GS[3, 2] = 0
        sage: captures_circle_white(GS, verbose = False)
        [((2, 15, [36]), (2, 14, [36]))]
        sage: captures_circle_white(GS, verbose = True)
        [((2, 15, [36]), (2, 14, [36]), (2, 15))]
        sage: valid_captures_by_numbering_white(GS)
        [((2, 15, [36]), (2, 14, [36]), (2, 15))]
        
    """
    GS = copy(game_state)
    PR, (_,C,_,P,_,T,_,S) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    white_pos_data = positions_w(GS)
    black_occupied_coords = {item[0] for item in positions_b(GS)}
    
    attacker_coords = [item[0] for item in white_pos_data if C in item[1].variables()]
    circle_move_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    
    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for inc in circle_move_increments:
            dest = (start_pos[0] + inc[0], start_pos[1] + inc[1])
            if dest in black_occupied_coords:
                victim_values = value_of_piece(GS, dest[0], dest[1])
                if not set(attacker_values).isdisjoint(set(victim_values)):
                    if verbose:
                        cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                    else:
                        cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps


    
def captures_circle_black(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which Black has a legal capture of
    a white piece using a (black) circle.

    Capture by numbering.
    
    MOVES_CIRCLE_ORTHOGONAL = True

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: captures_circle_black(GS, verbose = True)
        []

    """
    GS = copy(game_state)
    PR, (c,_,_,_,_,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()
    
    # Get detailed data and create coordinate sets for fast lookups
    white_occupied_coords = {item[0] for item in positions_w(GS)}
    
    # Get coordinates of potential attackers
    attacker_coords = [item[0] for item in positions_b(GS) if c in item[1].variables()]
    
    # Define move patterns
    circle_move_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    
    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for inc in circle_move_increments:
            dest = (start_pos[0] + inc[0], start_pos[1] + inc[1])
            
            if dest in white_occupied_coords:
                # Destination has an enemy, check if values match for a capture
                victim_values = value_of_piece(GS, dest[0], dest[1])
                if not set(attacker_values).isdisjoint(set(victim_values)):
                    # Capture is valid
                    if verbose:
                        cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                    else:
                        cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps
    

def captures_triangle_white(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which White has a legal capture of
    a black piece using a (white) triangle.

    Capture by numbering.

    EXAMPLES:
        sage: for i in range(100):
        ....:     RS = random_board_state()
        ....:     ct = captures_triangle_white(RS)
        ....:     if len(ct)>0:
        ....:         print(RS, "\n", ct, "\n", i)
        ....:         break
        ....: 
        [ S^25     0     0  s^28     0     0   C^8  T^42  S^81  C^36     0  c^49  P^91 S^153     0     0]
        [    0 t^100     0     0     0     0   c^3     0     0     0     0     0     0     0  C^64     0]
        [  C^2     0   C^6     0  S^45     0     0     0   T^9  t^90     0  T^49  T^25     0     0  t^56]
        [    0     0     0     0     0  c^25  S^15     0  c^81   c^9     0     0     0  s^66     0  t^12]
        [    0     0  T^72     0 s^121     0   c^7     0  t^16 s^120  t^30     0  s^49     0 S^169     0]
        [s^225     0  T^20  t^64     0   c^5   c^9     0     0     0  t^36     0     0     0     0     0]
        [    0     0     0     0   T^6 p^190     0     0   C^4     0     0     0     0 S^289     0     0]
        [    0 s^361     0     0     0     0     0     0  T^81     0  C^16     0   C^4     0     0     0] 
         [((2, 11, 49), (0, 11, 49))] 
         9

    """
    GS = copy(game_state)
    PR, (_,C,_,P,_,T,_,S) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    all_occupied_coords = {item[0] for item in positions_w(GS) + positions_b(GS)}
    black_occupied_coords = {item[0] for item in positions_b(GS)}
    
    attacker_coords = [item[0] for item in positions_w(GS) if T in item[1].variables()]
    move_increments = [(0, 2), (0, -2), (2, 0), (-2, 0)]
    path_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for i in range(len(move_increments)):
            dest = (start_pos[0] + move_increments[i][0], start_pos[1] + move_increments[i][1])
            hop1 = (start_pos[0] + path_increments[i][0], start_pos[1] + path_increments[i][1])
            if dest in black_occupied_coords and hop1 not in all_occupied_coords:
                victim_values = value_of_piece(GS, dest[0], dest[1])
                if not set(attacker_values).isdisjoint(set(victim_values)):
                    if verbose:
                        cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                    else:
                        cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps


    
def captures_triangle_black(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which Black has a legal capture of
    a white piece using a (black) triangle.

    Capture by numbering.

    EXAMPLES:
        sage: for i in range(100):
        ....:     RS = random_board_state()
        ....:     ct = captures_triangle_black(RS, verbose = True)
        ....:     if len(ct)>0:
        ....:         print(RS, "\n", ct, "\n", i)
        ....:         break
        ....: 
        (4, 0) (4, 2) True (4, 1) True 64 64
        [    0     0     0     0     0     0 S^153     0     0     0     0     0   C^6   C^8     0 s^121]
        [    0 s^120     0     0     0     0   C^2     0     0     0 s^361     0  s^49     0     0     0]
        [ c^81     0   c^3     0   T^6     0     0  t^90     0     0     0   c^9     0     0  T^25  t^56]
        [    0  s^66     0  C^16  T^42  c^25     0 s^225     0     0     0     0     0  c^49  C^36  T^72]
        [ t^64     0  C^64  P^91     0   T^9 S^169     0     0     0     0     0     0  S^15     0     0]
        [    0  t^12     0     0 t^100     0     0     0     0   c^9     0  s^28     0   c^7     0     0]
        [ t^30     0  T^20  t^36     0     0 p^190     0     0   c^5     0   C^4  S^45  S^81     0     0]
        [S^289     0     0     0  T^81  t^16  T^49     0     0     0     0     0  S^25   C^4     0     0] 
         [((4, 0, 64), (4, 2, 64), t^64)] 
         41

    """
    GS = copy(game_state)
    PR, (_,_,_,_,t,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    # Get detailed data and create coordinate sets for fast lookups
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)
    all_occupied_coords = {item[0] for item in white_pos_data + black_pos_data}
    white_occupied_coords = {item[0] for item in white_pos_data}

    # Get coordinates of potential attackers (black triangles)
    attacker_coords = [item[0] for item in black_pos_data if t in item[1].variables()]

    # Define move patterns
    move_increments = [(0, 2), (0, -2), (2, 0), (-2, 0)]
    path_increments = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for i in range(len(move_increments)):
            dest = (start_pos[0] + move_increments[i][0], start_pos[1] + move_increments[i][1])
            
            if dest in white_occupied_coords:
                # Check if the path is clear
                hop1 = (start_pos[0] + path_increments[i][0], start_pos[1] + path_increments[i][1])
                if hop1 not in all_occupied_coords:
                    # Path is clear, now check values
                    victim_values = value_of_piece(GS, dest[0], dest[1])
                    if not set(attacker_values).isdisjoint(set(victim_values)):
                        # Capture is valid
                        if verbose:
                            cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                        else:
                            cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps


    
def captures_square_white(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which White has a legal capture of
    a black piece using a (white) square.

    Capture by numbering.

    EXAMPLES:
        sage: for i in range(100):
        ....:     RS = random_board_state()
        ....:     ct = captures_square_white(RS, verbose = True)
        ....:     if len(ct)>0:
        ....:         print(RS, "\n", ct, "\n", i)
        ....:         break
        ....: 
        [    0   c^9     0   c^9     0     0  t^90   C^4  T^49     0   T^6  c^49  C^64     0     0     0]
        [S^169     0     0     0   c^7     0 S^153     0   c^3  s^66 s^225     0     0     0  T^25     0]
        [ S^15     0     0     0     0     0     0  S^81     0     0  c^81  C^16     0     0     0  C^36]
        [ P^91     0     0     0   C^4     0     0  t^64     0     0     0     0     0     0   C^2     0]
        [s^361     0  T^81  S^25     0     0 s^120  s^28     0     0     0  t^36     0     0 s^121     0]
        [    0  T^72  t^16  t^56     0 p^190  T^42     0     0 t^100     0   T^9     0     0     0  s^49]
        [    0     0  S^45   C^8     0     0  T^20     0     0     0   c^5     0     0     0 S^289     0]
        [ t^30     0     0     0     0     0     0     0     0     0     0   C^6     0     0  t^12  c^25] 
         [((2, 7, 81), (2, 10, 81), S^81)] 
         93

    """
    GS = copy(game_state)
    PR, (_,C,_,P,_,T,_,S) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    all_occupied_coords = {item[0] for item in positions_w(GS) + positions_b(GS)}
    black_occupied_coords = {item[0] for item in positions_b(GS)}

    attacker_coords = [item[0] for item in positions_w(GS) if S in item[1].variables() and not P in item[1].variables()]
    move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]

    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for i in range(len(move_increments)):
            dest = (start_pos[0] + move_increments[i][0], start_pos[1] + move_increments[i][1])
            hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
            hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])
            if dest in black_occupied_coords and hop1 not in all_occupied_coords and hop2 not in all_occupied_coords:
                victim_values = value_of_piece(GS, dest[0], dest[1])
                if not set(attacker_values).isdisjoint(set(victim_values)):
                    if verbose:
                        cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                    else:
                        cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps



def captures_square_black(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which Black has a legal capture of
    a white piece using a (black) square.

    Capture by numbering.
    

    EXAMPLES:
        sage: for i in range(100):
        ....:     RS = random_board_state()
        ....:     ct = captures_square_black(RS, verbose = True)
        ....:     if len(ct)>0:
        ....:         print(RS, "\n", ct, "\n", i)
        ....:         break
        ....: 
        [    0  t^64     0     0 S^169     0 S^153     0     0  T^81  C^36 s^120 S^289     0     0  S^25]
        [s^121     0     0     0  s^66     0     0     0     0     0     0  c^49     0     0  S^45     0]
        [    0     0     0   T^9   c^7     0     0  s^49     0     0  T^49     0     0   T^6  t^30     0]
        [ t^16     0     0  t^36     0     0     0     0  t^12 t^100     0  c^81     0 s^361     0     0]
        [    0   C^2  C^16   C^8   c^5  s^28     0     0     0     0     0     0  T^25  C^64  T^72     0]
        [    0     0     0  S^81     0     0     0     0   C^6     0     0     0     0     0     0     0]
        [  c^3   c^9     0  P^91     0     0   C^4 p^190 s^225   c^9   C^4  T^42  c^25     0     0     0]
        [    0     0     0     0  S^15     0     0  t^56  t^90     0     0     0  T^20     0     0     0] 
         [((2, 7, 49), (2, 10, 49), s^49)] 
         66
	
    """
    GS = copy(game_state)
    PR, (_,_,p,_,_,_,s,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    # Get detailed data and create coordinate sets for fast lookups
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)
    all_occupied_coords = {item[0] for item in white_pos_data + black_pos_data}
    white_occupied_coords = {item[0] for item in white_pos_data}

    # Get coordinates of potential attackers (black squares, not pyramids)
    attacker_coords = [item[0] for item in black_pos_data if s in item[1].variables() and not p in item[1].variables()]

    # Define move patterns
    move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]

    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for i in range(len(move_increments)):
            dest = (start_pos[0] + move_increments[i][0], start_pos[1] + move_increments[i][1])
            
            if dest in white_occupied_coords:
                # Check if the path is clear
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])
                if hop1 not in all_occupied_coords and hop2 not in all_occupied_coords:
                    # Path is clear, now check values
                    victim_values = value_of_piece(GS, dest[0], dest[1])
                    if not set(attacker_values).isdisjoint(set(victim_values)):
                        # Capture is valid
                        if verbose:
                            cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                        else:
                            cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps



def captures_pyramid_black(game_state, verbose = False):
    """
    Given the game state matrix, game_state, this function returns all 
    coordinates for which Black has a legal capture of
    a white piece using a (black) pyramid.

    Capture by numbering. 
    
    PYRAMID_DECOMPOSITION_SQUARES_ONLY = True

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: captures_pyramid_black(GS, verbose = True)
        []

    """
    GS = copy(game_state)
    PR, (_,_,p,_,_,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    # Get detailed data and create coordinate sets for fast lookups
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)
    all_occupied_coords = {item[0] for item in white_pos_data + black_pos_data}
    white_occupied_coords = {item[0] for item in white_pos_data}

    # Get coordinates of potential attackers (Black Pyramid)
    attacker_coords = [item[0] for item in black_pos_data if p in item[1].variables()]
    
    # Define move patterns (a pyramid moves like a square)
    move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]
    
    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for i in range(len(move_increments)):
            dest = (start_pos[0] + move_increments[i][0], start_pos[1] + move_increments[i][1])
            
            if dest in white_occupied_coords:
                # Check if the path is clear
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])
                if hop1 not in all_occupied_coords and hop2 not in all_occupied_coords:
                    # Path is clear, now check values
                    victim_values = value_of_piece(GS, dest[0], dest[1])
                    if not set(attacker_values).isdisjoint(set(victim_values)):
                        # Capture is valid
                        if verbose:
                            cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                        else:
                            cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps



def captures_pyramid_white(game_state, verbose = False):
    """
    Given the game state matrix, game_state, this function returns all 
    coordinates for which White has a legal capture of
    a black piece using a (white) pyramid.

    Capture by numbering       
    
    PYRAMID_DECOMPOSITION_SQUARES_ONLY = True

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: captures_pyramid_white(GS, verbose = True)
        []

    """
    GS = copy(game_state)
    PR, (_,_,_,P,_,_,_,_) = PolynomialRing(ZZ, 8, 'c,C,p,P,t,T,s,S').objgens()

    # Get detailed data and create coordinate sets for fast lookups
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)
    all_occupied_coords = {item[0] for item in white_pos_data + black_pos_data}
    black_occupied_coords = {item[0] for item in black_pos_data}

    # Get coordinates of potential attackers (White Pyramid)
    attacker_coords = [item[0] for item in white_pos_data if P in item[1].variables()]
    
    # Define move patterns (a pyramid moves like a square)
    move_increments = [(0, 3), (0, -3), (3, 0), (-3, 0)]
    path_increments1 = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    path_increments2 = [(0, 2), (0, -2), (2, 0), (-2, 0)]
    
    cps = []
    for start_pos in attacker_coords:
        attacker_values = value_of_piece(GS, start_pos[0], start_pos[1])
        for i in range(len(move_increments)):
            dest = (start_pos[0] + move_increments[i][0], start_pos[1] + move_increments[i][1])
            
            if dest in black_occupied_coords:
                # Check if the path is clear
                hop1 = (start_pos[0] + path_increments1[i][0], start_pos[1] + path_increments1[i][1])
                hop2 = (start_pos[0] + path_increments2[i][0], start_pos[1] + path_increments2[i][1])
                if hop1 not in all_occupied_coords and hop2 not in all_occupied_coords:
                    # Path is clear, now check values
                    victim_values = value_of_piece(GS, dest[0], dest[1])
                    if not set(attacker_values).isdisjoint(set(victim_values)):
                        # Capture is valid
                        if verbose:
                            cps.append(((start_pos, attacker_values, GS[start_pos]), (dest, victim_values, GS[dest])))
                        else:
                            cps.append(((start_pos, attacker_values), (dest, victim_values)))
    return cps

    
    
def valid_captures_by_numbering_white(game_state, verbose = False):
    """ 
    Lists White's captures of a Black piece by numbering ("encounter"),
    according to Rithmomachia rules. 
 
    Note: The verbose option does nothing (yet).

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game. 
      
    Returns: 
      List of names of White's capturing pieces and Black's captured pieces, if any.

    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_numbering_white(GS)
        []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2, 15] = C^(36)
        sage: GS[3, 2] = 0
        sage: captures_circle_white(GS, verbose = False)
        [((2, 15, [36]), (2, 14, [36]))]
        sage: valid_captures_by_numbering_white(GS)
        [((2, 15, [36]), (2, 14, [36]), (2, 15), C^36, t^36)]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2, 15] = C^(36); GS[3, 2] = 0; GS[5, 15] = C^(64); GS[2, 2] = 0
        sage: valid_captures_by_numbering_white(GS)
         [((2, 15, [36]), (2, 14, [36]), (2, 15), C^36, t^36),
          ((5, 15, [64]), (5, 14, [64]), (5, 15), C^64, t^64)]

    """
    GS = copy(game_state)
    L = captures_circle_white(GS, verbose = True) + captures_triangle_white(GS, verbose = True) + captures_square_white(GS, verbose = True) + captures_pyramid_white(GS, verbose = True) 
    return L
    
def valid_captures_by_numbering_black(game_state, verbose = False):
    """ 
    Lists Black's captures of a White piece by numbering ("encounter"),
    according to Rithmomachia rules. 
 
    Note: The verbose option does nothing (yet).

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game. 
      
    Returns: 
      List of names of Black's capturing pieces and White's captured pieces, if any.
 
  
    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_numbering_black(GS)
        []


    """
    GS = copy(game_state)
    L = captures_circle_black(GS, verbose = True) + captures_triangle_black(GS, verbose = True) + captures_square_black(GS, verbose = True) + captures_pyramid_black(GS, verbose = True) 
    return L


def lands_on(game_state, pc_pos, verbose=False):
    """
    returns all the coordinates/positions that are in bounds and
    in the range of the piece pc in that game_state at coordinates/position pc_pos
    This doesn't allow jumping over a piece but does allow landing on a piece.
    For example, if pc_pos is the coordinate of a circle piece then there 
    is no restriction.

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: lands_on(GS, [5,5], verbose = True)
        No piece, so no moves.
        []
        sage: lands_on(GS, [0,2])
        [((0, 2), [0, 4])]
        sage: lands_on(GS, [0,2], verbose = True)
        Position/coordinate of  T^81  is:  [0, 2]
        Possible landing coordinates of  T^81  are: 
        [((0, 2), [0, 4])]
        sage: lands_on(GS, [5,3], verbose = True)
        Position/coordinate of  C^2  is:  [5, 3]
        Possible landing coordinates of  C^2  are: 
        [((5, 3), [4, 2]), ((5, 3), [4, 4]), ((5, 3), [6, 2]), ((5, 3), [6, 4])]
        sage: GSp = board_initial_matrix(pyramid_decomposition=True)     #### needed for pyramid moves
        sage: lands_on(GSp, [1,1], verbose = True)
        Position/coordinate of  S^36 + S^25 + T^16 + T^9 + C^4 + C^2 + 91*P  is:  [1, 1]
        Possible landing coordinates of  S^36 + S^25 + T^16 + T^9 + C^4 + C^2 + 91*P  are: 
        [((1, 1), [0, 0]), ((1, 1), [0, 2]), ((1, 1), [2, 0]), ((1, 1), [2, 2])]

    """
    GS = copy(game_state)
    i0, j0 = pc_pos

    pc = GS[i0, j0]
    if pc == 0:
        if verbose: print("No piece, so no moves.")
        return []

    # Get a single, reliable list of all occupied squares
    all_occupied_pos = positions_w(GS) + positions_b(GS)
    mvs = []
    
    # Determine move increments based on piece type
    vars_pc = pc.variables()
    increments = []
    path_check_depth = 0

    if (C in vars_pc) or (c in vars_pc):
        increments = [[(1, 0)], [(-1, 0)], [(0, 1)], [(0, -1)]]
        path_check_depth = 0 # Jumps 1 square, no intermediate checks
    elif (T in vars_pc) or (t in vars_pc):
        increments = [[(2, 0), (1, 0)], [(-2, 0), (-1, 0)], [(0, 2), (0, 1)], [(0, -2), (0, -1)]]
        path_check_depth = 1 # Jumps 2 squares, checks 1 intermediate
    elif (S in vars_pc) or (s in vars_pc) or (P in vars_pc) or (p in vars_pc):
        increments = [[(3, 0), (2, 0), (1, 0)], [(-3, 0), (-2, 0), (-1, 0)], [(0, 3), (0, 2), (0, 1)], [(0, -3), (0, -2), (0, -1)]]
        path_check_depth = 2 # Jumps 3 squares, checks 2 intermediate

    for path in increments:
        dest_coord = (i0 + path[0][0], j0 + path[0][1])

        if not in_bounds(dest_coord):
            continue

        # Check for blockers in the path
        path_is_clear = True
        if path_check_depth > 0:
            for i in range(1, path_check_depth + 1):
                intermediate_coord = (i0 + path[i][0], j0 + path[i][1])
                if intermediate_coord in all_occupied_pos:
                    path_is_clear = False
                    break
        
        if path_is_clear:
            mvs.append( (pc_pos, dest_coord) )

    return mvs


def valid_captures_by_addition_white(game_state, verbose = False):
    r""" 
    Lists White's captures of a Black piece by addition ("ambush"),
    according to Rithmomachia rules. 

    Args:
      game_state: The 8x16 matrix representing the board and pieces in the game.
      
    Returns: 
      List of names of White's capturing pieces (by addition) and Black's 
      captured pieces, if any.
    
    For every pair of white pieces (and for pair, don't worry if there is a repetition)
     compute all their potential captures (ignoring the comparison of values for now), merely
     testing if each white piece (in the chosen pair) can land on the same black piece.
    For all such pairs, compute the sum of the values of the two attacking white pieces.
    If this sum is the same as the value of the target black piece then add
     (1) both white pieces
     (2) their coordinate\positions,
     (3) the black piece that was captured,
     (4) its value,
     to the list of pieces captured by addition.

    ####### what about if pc1, pc2, or pc3 is a pyramid ???????????

    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_addition_white(GS)
         []
        sage: GS = board_initial_matrix()
        sage: GS[3,3]=0; GS[0,13] = C^6; GS[6,2] = 0; GS[1,11] = T^6
        sage: valid_captures_by_addition_white(GS, verbose=False)
         [[((0, 13), [6]), ((1, 11), [6]), ((1, 13), [12])],
          [((1, 11), [6]), ((0, 13), [6]), ((1, 13), [12])]]
        sage: valid_captures_by_addition_white(GS, verbose=True)
         The piece C^6 at (0, 13) and the piece T^6 at (1, 11) capture by addition the piece t^12 at (1, 13)
         The piece T^6 at (1, 11) and the piece C^6 at (0, 13) capture by addition the piece t^12 at (1, 13)
         [[((0, 13), [6], C^6), ((1, 11), [6], T^6), ((1, 13), [12], t^12)],
          [((1, 11), [6], T^6), ((0, 13), [6], C^6), ((1, 13), [12], t^12)]]

    """
    GS = copy(game_state)
    cps = []

    # Get detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_coords = {item[0] for item in positions_b(GS)}

    # 1. Collect all possible moves for every white piece
    all_white_moves = []
    for piece_data in white_pos_data:
        start_pos = piece_data[0] # Extract coordinate tuple
        # lands_on returns a list of (start_pos, dest_pos) tuples
        possible_moves = lands_on(GS, start_pos, verbose=False)
        all_white_moves.extend(possible_moves)

    # 2. Check every pair of moves to find common landing spots on enemy pieces
    for move1, move2 in itertools.combinations(all_white_moves, int(2)):
        start1, dest1 = move1
        start2, dest2 = move2

        # Check if two different pieces can land on the same enemy square
        if start1 != start2 and dest1 == dest2 and dest1 in black_pos_coords:
            landing_spot = dest1
            
            val1_list = value_of_piece(GS, start1[0], start1[1])
            val2_list = value_of_piece(GS, start2[0], start2[1])
            victim_val_list = value_of_piece(GS, landing_spot[0], landing_spot[1])

            # Ensure all values are valid before checking the sum rule
            if val1_list and val2_list and victim_val_list and val1_list[0] and val2_list[0] and victim_val_list[0]:
                val1 = val1_list[0]
                val2 = val2_list[0]
                victim_val = victim_val_list[0]
                
                if val1 + val2 == victim_val:
                    # Capture is valid. Format the record.
                    if verbose:
                        record = [
                            (start1, val1_list, GS[start1]), 
                            (start2, val2_list, GS[start2]), 
                            (landing_spot, victim_val_list, GS[landing_spot])
                        ]
                        print(f"Capture Found: {GS[start1]} at {start1} and {GS[start2]} at {start2} can capture {GS[landing_spot]} by Addition.")
                    else:
                        record = [
                            (start1, val1_list), 
                            (start2, val2_list), 
                            (landing_spot, victim_val_list)
                        ]
                    # Append if not already found (to avoid duplicates from different move orders)
                    if record not in cps:
                        cps.append(record)
                        
    return cps


def valid_captures_by_addition_black(game_state, verbose = False):
    r""" 
    Lists Black's captures of a white piece by addition ("ambush"),
    according to Rithmomachia rules. 
    
    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.
      
    Returns: 
      List of names of Black's capturing pieces (by addition) and White's 
      captured pieces, if any.
 
    Similar to valid_captures_by_addition_white above.

    ####### what about if pc1, pc2, or pc3 is a pyramid ???????????

    EXAMPLES: 
        sage: GS = board_initial_matrix(pyramid_decomposition = True)
        sage: valid_captures_by_addition_black(GS)
        []
        sage: GS = board_initial_matrix()
        sage: GS[1,4] = c^3; GS[2,12] = 0
        sage: GS[3,4] = c^5; GS[3,12] = 0
        sage: valid_captures_by_addition_black(GS)
         [[((1, 4), 3), ((3, 4), 5), ((2, 3), 8)],
          [((3, 4), 5), ((1, 4), 3), ((2, 3), 8)]]
        sage: valid_captures_by_addition_black(GS, verbose=True)
         The piece c^3 at (1, 4) and the piece c^5 at (3, 4) capture by addition the piece C^8 at (2, 3)
         The piece c^5 at (3, 4) and the piece c^3 at (1, 4) capture by addition the piece C^8 at (2, 3)
         [[((1, 4), 3), ((3, 4), 5), ((2, 3), 8)],
          [((3, 4), 5), ((1, 4), 3), ((2, 3), 8)]]


    """
    GS = copy(game_state)
    cps = []

    # Get detailed data for all pieces
    black_pos_data = positions_b(GS)
    white_pos_coords = {item[0] for item in positions_w(GS)}

    # 1. Collect all possible moves for every black piece
    all_black_moves = []
    for piece_data in black_pos_data:
        start_pos = piece_data[0] # Extract coordinate tuple
        # lands_on returns a list of (start_pos, dest_pos) tuples
        possible_moves = lands_on(GS, start_pos, verbose=False)
        all_black_moves.extend(possible_moves)

    # 2. Check every pair of moves to find common landing spots on enemy pieces
    for move1, move2 in itertools.combinations(all_black_moves, int(2)):
        start1, dest1 = move1
        start2, dest2 = move2

        # Check if two different pieces can land on the same enemy square
        if start1 != start2 and dest1 == dest2 and dest1 in white_pos_coords:
            landing_spot = dest1
            
            val1_list = value_of_piece(GS, start1[0], start1[1])
            val2_list = value_of_piece(GS, start2[0], start2[1])
            victim_val_list = value_of_piece(GS, landing_spot[0], landing_spot[1])

            # Ensure all values are valid before checking the sum rule
            if val1_list and val2_list and victim_val_list and val1_list[0] and val2_list[0] and victim_val_list[0]:
                val1 = val1_list[0]
                val2 = val2_list[0]
                victim_val = victim_val_list[0]
                
                if val1 + val2 == victim_val:
                    # Capture is valid. Format the record.
                    if verbose:
                        record = [
                            (start1, val1_list, GS[start1]), 
                            (start2, val2_list, GS[start2]), 
                            (landing_spot, victim_val_list, GS[landing_spot])
                        ]
                        print(f"Capture Found: {GS[start1]} at {start1} and {GS[start2]} at {start2} can capture {GS[landing_spot]} by Addition.")
                    else:
                        record = [
                            (start1, val1_list), 
                            (start2, val2_list), 
                            (landing_spot, victim_val_list)
                        ]
                    # Append if not already found (to avoid duplicates from different move orders)
                    if record not in cps:
                        cps.append(record)
                        
    return cps


def valid_captures_by_subtraction_white(game_state, verbose = False):
    r""" 
    Lists White's captures of a Black piece by subtraction,
    according to Rithmomachia rules. 

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.
      
    Returns: 
      List of names of White's capturing pieces (by subtraction) and Black's 
      captured pieces, if any.

    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_subtraction_white(GS)
        []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3,3] = 0; GS[1, 13] = t^6; GS[0,12] = C^6; GS[6,2] = 0; GS[1,11] = T^(12)
        sage: valid_captures_by_subtraction_white(GS, verbose=True)
         The piece T^12 at (1, 11) and the piece C^6 at (0, 12) capture by subtraction the piece t^6 at (1, 13)
         [[((1, 11), 12), ((0, 12), 6), ((1, 13), 6)]]
        sage: valid_captures_by_subtraction_white(GS)
         [[((1, 11), 12), ((0, 12), 6), ((1, 13), 6)]]

    """
    GS = copy(game_state)
    cps = []

    # Get detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_coords = {item[0] for item in positions_b(GS)}

    # 1. Collect all possible moves for every white piece
    all_white_moves = []
    for piece_data in white_pos_data:
        start_pos = piece_data[0] # Extract coordinate tuple
        possible_moves = lands_on(GS, start_pos, verbose=False)
        all_white_moves.extend(possible_moves)

    # 2. Check every pair of moves to find common landing spots on enemy pieces
    # Note: permutations are used instead of combinations to check both v1-v2 and v2-v1
    for move1, move2 in itertools.permutations(all_white_moves, int(2)):
        start1, dest1 = move1
        start2, dest2 = move2

        # Check if two different pieces can land on the same enemy square
        if start1 != start2 and dest1 == dest2 and dest1 in black_pos_coords:
            landing_spot = dest1
            
            val1_list = value_of_piece(GS, start1[0], start1[1])
            val2_list = value_of_piece(GS, start2[0], start2[1])
            victim_val_list = value_of_piece(GS, landing_spot[0], landing_spot[1])

            # Ensure all values are valid before checking the subtraction rule
            if val1_list and val2_list and victim_val_list and val1_list[0] and val2_list[0] and victim_val_list[0]:
                val1 = val1_list[0]
                val2 = val2_list[0]
                victim_val = victim_val_list[0]
                
                if val1 - val2 == victim_val:
                    # Capture is valid. Format the record.
                    if verbose:
                        record = [
                            (start1, val1_list, GS[start1]), 
                            (start2, val2_list, GS[start2]), 
                            (landing_spot, victim_val_list, GS[landing_spot])
                        ]
                        print(f"Capture Found: {GS[start1]} at {start1} and {GS[start2]} at {start2} can capture {GS[landing_spot]} by Subtraction.")
                    else:
                        record = [
                            (start1, val1_list), 
                            (start2, val2_list), 
                            (landing_spot, victim_val_list)
                        ]
                    # Append if not already found
                    if record not in cps:
                        cps.append(record)
                        
    return cps


def valid_captures_by_subtraction_black(game_state, verbose = False):
    r""" 
    Lists Black's captures of a White piece by subtraction,
    according to Rithmomachia rules. 

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.
      
    Returns: 
      List of names of Black's capturing pieces (by subtraction) and White's 
      captured pieces, if any.

    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_subtraction_black(GS)
         []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[1,11] = T^9; GS[7,2] = 0; GS[2,11] = c^3; GS[2,12] = 0
        sage: board_plot(GS)
         Launched png viewer for Graphics object consisting of 185 graphics primitives
        sage: valid_captures_by_subtraction_black(GS)
         [[((1, 13), [12]), ((2, 11), [3]), ((1, 11), [9])]]
        sage: valid_captures_by_subtraction_black(GS, verbose=True)
         The piece t^12 at (1, 13) and the piece c^3 at (2, 11) capture by subtraction the piece T^9 at (1, 11)
         [[((1, 13), [12], t^12), ((2, 11), [3], c^3), ((1, 11), [9], T^9)]]

    """
    GS = copy(game_state)
    cps = []

    # Get detailed data for all pieces
    black_pos_data = positions_b(GS)
    white_pos_coords = {item[0] for item in positions_w(GS)}

    # 1. Collect all possible moves for every black piece
    all_black_moves = []
    for piece_data in black_pos_data:
        start_pos = piece_data[0] # Extract coordinate tuple
        possible_moves = lands_on(GS, start_pos, verbose=False)
        all_black_moves.extend(possible_moves)

    # 2. Check every pair of moves to find common landing spots on enemy pieces
    # Note: permutations are used instead of combinations to check both v1-v2 and v2-v1
    for move1, move2 in itertools.permutations(all_black_moves, int(2)):
        start1, dest1 = move1
        start2, dest2 = move2

        # Check if two different pieces can land on the same enemy square
        if start1 != start2 and dest1 == dest2 and dest1 in white_pos_coords:
            landing_spot = dest1
            
            val1_list = value_of_piece(GS, start1[0], start1[1])
            val2_list = value_of_piece(GS, start2[0], start2[1])
            victim_val_list = value_of_piece(GS, landing_spot[0], landing_spot[1])

            # Ensure all values are valid before checking the subtraction rule
            if val1_list and val2_list and victim_val_list and val1_list[0] and val2_list[0] and victim_val_list[0]:
                val1 = val1_list[0]
                val2 = val2_list[0]
                victim_val = victim_val_list[0]
                
                if val1 - val2 == victim_val:
                    # Capture is valid. Format the record.
                    if verbose:
                        record = [
                            (start1, val1_list, GS[start1]), 
                            (start2, val2_list, GS[start2]), 
                            (landing_spot, victim_val_list, GS[landing_spot])
                        ]
                        print(f"Capture Found: {GS[start1]} at {start1} and {GS[start2]} at {start2} can capture {GS[landing_spot]} by Subtraction.")
                    else:
                        record = [
                            (start1, val1_list), 
                            (start2, val2_list), 
                            (landing_spot, victim_val_list)
                        ]
                    # Append if not already found
                    if record not in cps:
                        cps.append(record)
                        
    return cps


def valid_captures_by_multiplication_white(game_state, verbose = False):  ####### gemini's suggested changes
    r"""
    Lists White's captures of a Black piece by multiplication,
    according to the rule: value(pc1) * dist(pc1, pc2) = value(pc2).
    Allows pyramid sub-pieces to participate, using their individual values.

    Args:
      game_state: The 8x16 matrix representing the board and pieces in the game.
      verbose: If True, prints details of captures.

    Returns:
      List of tuples, where each tuple represents a capture:
      [((pos1, val1), (pos2, val2)), ...]
      val1 and val2 are the specific component values involved.

    EXAMPLES: 
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[7,7] = p^190 + s^64 + s^49 + s^36 + s^25 + s^16; GS[7, 14] = 0
        sage: valid_captures_by_multiplication_white(GS, verbose=True)
         The piece component T^9 (value 9) at (7, 2) captures by multiplication the piece component 
          p^190 + s^64 + s^49 + s^36 + s^25 + s^16 (value 36) at (7, 7) at separation 4
         [[((7, 2), 9), ((7, 7), 36)]]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5, 5] = T^4; GS[5, 9] = s^12
        sage: valid_captures_by_multiplication_white(GS, verbose=True)
         The piece component T^4 (value 4) at (5, 5) captures by multiplication the piece component 
          s^12 (value 12) at (5, 9) at separation 3
         [[((5, 5), 4), ((5, 9), 12)]]

    """
    GS = copy(game_state)
    cps = []

    # Get the detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)

    # Iterate through all white pieces as potential attackers
    for attacker_data in white_pos_data:
        attacker_coords = attacker_data[0]
        attacker_poly = attacker_data[1]
        attacker_values = value_of_piece(GS, attacker_coords[0], attacker_coords[1])

        if not attacker_values or attacker_values == [0]:
            continue

        # Iterate through all black pieces as potential victims
        for victim_data in black_pos_data:
            victim_coords = victim_data[0]
            victim_poly = victim_data[1]
            
            # Check for a clear line of sight and get distance
            dist_spaces = pieces_in_a_line(GS, attacker_coords, victim_coords)
            
            # Capture requires a distance of at least 1 empty space
            if dist_spaces < 1:
                continue

            victim_values = value_of_piece(GS, victim_coords[0], victim_coords[1])
            if not victim_values or victim_values == [0]:
                continue
            
            # Check all value combinations for the capture rule
            for v_attacker in attacker_values:
                if not isinstance(v_attacker, (int, Integer)): continue
                for v_victim in victim_values:
                    if not isinstance(v_victim, (int, Integer)): continue
                    
                    if v_attacker > 0 and v_attacker * dist_spaces == v_victim:
                        # Found a valid capture
                        capture_record = ((attacker_coords, v_attacker), (victim_coords, v_victim))
                        if capture_record not in cps:
                            cps.append(capture_record)
                            if verbose:
                                print(f"Capture Found: {attacker_poly} (value {v_attacker}) at {attacker_coords} captures {victim_poly} (value {v_victim}) at {victim_coords} by Multiplication (separation {dist_spaces}).")
    return cps


def valid_captures_by_multiplication_black(game_state, verbose = False):  ####### gemini's suggested changes
    r"""
    Lists Black's captures of a White piece by multiplication,
    according to Rithmomachia rules. 

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.

    Returns: 
      List of coordinates of black capturing pieces (by multiplication) and white
      captured pieces, if any.
     

    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_multiplication_white(GS)
         []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3, 8] = S^(15); GS[6, 0] = 0
        sage: valid_captures_by_multiplication_black(GS, verbose = True)
         The piece component c^5 (value 5) at (3, 12) captures by multiplication the piece component S^15 (value 15) at (3, 8) at separation 3
         [[((3, 12), 5), ((3, 8), 15)]]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)        ###### example with 3 captures, including a pyramid sub-piece
        sage: GS = copy(GSp)
        sage: GS[3, 8] = S^(15); GS[6, 0] = 0; GS[1, 5] = t^(12); GS[1, 13] = 0; GS[5, 3] = T^(72); GS[1, 2] = 0
        sage: valid_captures_by_multiplication_black(GS, verbose = True)
         The piece component t^12 (value 12) at (1, 5) captures by multiplication the piece component P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S (value 36) at (1, 1) at separation 3
         The piece component c^5 (value 5) at (3, 12) captures by multiplication the piece component S^15 (value 15) at (3, 8) at separation 3
         The piece component c^9 (value 9) at (5, 12) captures by multiplication the piece component T^72 (value 72) at (5, 3) at separation 8
         [[((1, 5), 12), ((1, 1), 36)],
          [((3, 12), 5), ((3, 8), 15)],
          [((5, 12), 9), ((5, 3), 72)]]
 
    """
    GS = copy(game_state)
    cps = []

    # Get the detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)

    # Iterate through all black pieces as potential attackers
    for attacker_data in black_pos_data:
        attacker_coords = attacker_data[0]
        attacker_poly = attacker_data[1]
        attacker_values = value_of_piece(GS, attacker_coords[0], attacker_coords[1])

        if not attacker_values or attacker_values == [0]:
            continue

        # Iterate through all white pieces as potential victims
        for victim_data in white_pos_data:
            victim_coords = victim_data[0]
            victim_poly = victim_data[1]
            
            # Check for a clear line of sight and get distance
            dist_spaces = pieces_in_a_line(GS, attacker_coords, victim_coords)
            
            # Capture requires a distance of at least 1 empty space
            if dist_spaces < 1:
                continue

            victim_values = value_of_piece(GS, victim_coords[0], victim_coords[1])
            if not victim_values or victim_values == [0]:
                continue
            
            # Check all value combinations for the capture rule
            for v_attacker in attacker_values:
                if not isinstance(v_attacker, (int, Integer)): continue
                for v_victim in victim_values:
                    if not isinstance(v_victim, (int, Integer)): continue
                    
                    if v_attacker > 0 and v_attacker * dist_spaces == v_victim:
                        # Found a valid capture
                        capture_record = ((attacker_coords, v_attacker), (victim_coords, v_victim))
                        if capture_record not in cps:
                            cps.append(capture_record)
                            if verbose:
                                print(f"Capture Found: {attacker_poly} (value {v_attacker}) at {attacker_coords} captures {victim_poly} (value {v_victim}) at {victim_coords} by Multiplication (separation {dist_spaces}).")
    return cps


def valid_captures_by_division_white(game_state, verbose = False):
    r"""
    Lists White's captures of a Black piece by division,
    according to the rule: value(pc1) / value(pc2) = dist(pc1, pc2).
    Allows pyramid sub-pieces to participate, using their individual values.

    Args:
      game_state: The 8x16 matrix representing the board and pieces in the game.
      verbose: If True, prints details of captures.

    Returns:
      List of tuples, where each tuple represents a capture:
      [((pos1, val1), (pos2, val2)), ...]
      val1 and val2 are the specific component values involved.

    EXAMPLES: # Note: Original examples might change with new logic
        # Need new examples demonstrating pyramid component capture by division
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3, 6] = S^(25); GS[7, 0] = 0
        sage: valid_captures_by_division_white(GS, verbose = False)
         [[((3, 6), 25), ((3, 12), 5)]]
        sage: valid_captures_by_division_white(GS, verbose = True)
         The piece component S^25 (value 25) at (3, 6) 
          captures by division the piece component c^5 (value 5) at (3, 12) at separation 5
         [[((3, 6), 25), ((3, 12), 5)]]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3, 6] = P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S; GS[1, 1] = 0
        sage: valid_captures_by_division_white(GS, verbose = True)
         The piece component P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S (value 25) at (3, 6) 
          captures by division the piece component c^5 (value 5) at (3, 12) at separation 5
         [[((3, 6), 25), ((3, 12), 5)]]

    """
    GS = copy(game_state)
    cps = []

    # Get the detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)

    # Iterate through all white pieces as potential attackers
    for attacker_data in white_pos_data:
        attacker_coords = attacker_data[0]
        attacker_poly = attacker_data[1]
        attacker_values = value_of_piece(GS, attacker_coords[0], attacker_coords[1])

        if not attacker_values or attacker_values == [0]:
            continue

        # Iterate through all black pieces as potential victims
        for victim_data in black_pos_data:
            victim_coords = victim_data[0]
            victim_poly = victim_data[1]
            
            # Check for a clear line of sight and get distance
            dist_spaces = pieces_in_a_line(GS, attacker_coords, victim_coords)
            
            # Capture requires a distance of at least 1 empty space
            if dist_spaces < 1:
                continue

            victim_values = value_of_piece(GS, victim_coords[0], victim_coords[1])
            if not victim_values or victim_values == [0]:
                continue
            
            # Check all value combinations for the capture rule
            for v_attacker in attacker_values:
                if not isinstance(v_attacker, (int, Integer)): continue
                for v_victim in victim_values:
                    if not isinstance(v_victim, (int, Integer)): continue
                    
                    # Check the division rule, ensuring no division by zero
                    if v_victim > 0 and v_attacker % v_victim == 0:
                        if v_attacker / v_victim == dist_spaces:
                            # Found a valid capture
                            capture_record = ((attacker_coords, v_attacker), (victim_coords, v_victim))
                            if capture_record not in cps:
                                cps.append(capture_record)
                                if verbose:
                                    print(f"Capture Found: {attacker_poly} (value {v_attacker}) at {attacker_coords} captures {victim_poly} (value {v_victim}) at {victim_coords} by Division (separation {dist_spaces}).")
    return cps

	
def valid_captures_by_division_black(game_state, verbose = False):
    r"""
    Lists Black's captures of a white piece by division,
    according to Rithmomachia rules. 

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.

    Returns: 
      List of names of White's capturing pieces (by division) and Black's 
      captured pieces, if any.
      
    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_division_black(GS)
        []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[1,10] = T^6; GS[6,2] = 0 ### same example as valid_captures_by_multiplication_white
        sage: valid_captures_by_division_black(GS, verbose = False)
         [[((1, 13), 12), ((1, 10), 6)]]
        sage: valid_captures_by_division_black(GS, verbose = True)
         The piece component t^12 (value 12) at (1, 13) 
          captures by division the piece component T^6 (value 6) at (1, 10) at separation 2
         [[((1, 13), 12), ((1, 10), 6)]]

    """
    GS = copy(game_state)
    cps = []

    # Get the detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)

    # Iterate through all black pieces as potential attackers
    for attacker_data in black_pos_data:
        attacker_coords = attacker_data[0]
        attacker_poly = attacker_data[1]
        attacker_values = value_of_piece(GS, attacker_coords[0], attacker_coords[1])

        if not attacker_values or attacker_values == [0]:
            continue

        # Iterate through all white pieces as potential victims
        for victim_data in white_pos_data:
            victim_coords = victim_data[0]
            victim_poly = victim_data[1]
            
            # Check for a clear line of sight and get distance
            dist_spaces = pieces_in_a_line(GS, attacker_coords, victim_coords)
            
            # Capture requires a distance of at least 1 empty space
            if dist_spaces < 1:
                continue

            victim_values = value_of_piece(GS, victim_coords[0], victim_coords[1])
            if not victim_values or victim_values == [0]:
                continue
            
            # Check all value combinations for the capture rule
            for v_attacker in attacker_values:
                if not isinstance(v_attacker, (int, Integer)): continue
                for v_victim in victim_values:
                    if not isinstance(v_victim, (int, Integer)): continue
                    
                    # Check the division rule, ensuring no division by zero
                    if v_victim > 0 and v_attacker % v_victim == 0:
                        if v_attacker / v_victim == dist_spaces:
                            # Found a valid capture
                            capture_record = ((attacker_coords, v_attacker), (victim_coords, v_victim))
                            if capture_record not in cps:
                                cps.append(capture_record)
                                if verbose:
                                    print(f"Capture Found: {attacker_poly} (value {v_attacker}) at {attacker_coords} captures {victim_poly} (value {v_victim}) at {victim_coords} by Division (separation {dist_spaces}).")
    return cps


def valid_captures_by_siege_white(game_state, verbose = False): ## this is gemini's improvement of the original version
    r"""
    Lists Black pieces captured by White via siege (also called surrounding).
    A piece is captured by siege if all four orthogonal adjacent squares
    are either off-board or occupied by other white piece.

    NOTE: If surrounding is, instead of meaning adjacent, is interpreted as 
    close enough to be blocking the black piece's movement in each of
    the 4 orthogonal directions. (So for a black/odd circle to be captured by siege,
    the white/even pieces surrounding it much be adjacent, but for triangle
    to be captured by siege, the pieces surrounding it much be either
    adjacent or exactly one square away. For a square, the surrounding pieces
    can be 2 squares away.)
    
    Args:
        game_state: The 8x16 matrix representing the board.
        verbose: If True, prints details of captures.

    Returns:
        List of tuples, where each tuple contains the position (r, c)
        and value (v) of a captured black piece: [((r1, c1), v1), ((r2, c2), v2), ...]

    EXAMPLES: 
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,2] = c^3; GS[2,12] = 0
        sage: valid_captures_by_siege_white(GS, verbose = False)
         [((2, 2), 3)]
        sage: valid_captures_by_siege_white(GS, verbose = True)
         The piece c^3 at (2, 2) with value 3 is captured by siege.
         [((2, 2), 3)]

    """
    GS = copy(game_state)
    captured_by_siege = []

    # Get detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)

    # Create data structures for efficient lookups
    white_pos_set = {item[0] for item in white_pos_data}

    # Define orthogonal directions
    shifts = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    # Check each black piece for siege
    for piece_data in black_pos_data:
        pos, poly = piece_data[0], piece_data[1]
        r, c = pos
        is_surrounded = True  # Assume surrounded until proven otherwise
        
        for dr, dc in shifts:
            adj_r, adj_c = r + dr, c + dc
            adj_pos = (adj_r, adj_c)

            # If the adjacent square is on the board, it must be occupied by a white piece
            if in_bounds(adj_pos):
                if adj_pos not in white_pos_set:
                    is_surrounded = False
                    break  # This direction is open, so no siege
            # If the adjacent square is off-board, it counts towards the siege
        
        # If the loop completed without finding an escape route, the piece is captured
        if is_surrounded:
            value = value_of_piece(GS, r, c)
            if verbose:
                # Use a format consistent with other verbose captures
                captured_info = ((pos, value, poly),)
                print(f"Capture Found: The piece {poly} at {pos} is captured by Siege.")
            else:
                captured_info = (pos, value)
            
            captured_by_siege.append(captured_info)
            
    return captured_by_siege

	
def valid_captures_by_siege_black(game_state, verbose = False):
    r"""
    Lists Black's captures of a white piece by siege, according to Rithmomachia rules. 

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.

    Returns: 
      List of names of White's captured pieces, if any.
      
    ## this is gemini's improvement of the original version

    NOTE: If surrounding is, instead of meaning adjacent, is interpreted as 
    close enough to be blocking the black piece's movement in each of
    the 4 orthogonal directions. (So for a black/odd circle to be captured by siege,
    the white/even pieces surrounding it much be adjacent, but for triangle
    to be captured by siege, the pieces surrounding it much be either
    adjacent or exactly one square away. For a square, the surrounding pieces
    can be 2 squares away.)

    EXAMPLES: 
        sage: GS = board_initial_matrix()
        sage: valid_captures_by_siege_black(GS)
        []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[7,14] = P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S
        sage: GS[1,1] = 0
        sage: valid_captures_by_siege_black(GS, verbose = False)
         [((7, 14), [36, 25, 16, 9, 4, 1])]
        sage: valid_captures_by_siege_black(GS, verbose = True)
         The piece P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S at (7, 14) 
          with value [36, 25, 16, 9, 4, 1] is captured by siege.
         [((7, 14), [36, 25, 16, 9, 4, 1])]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,11] = T^6; GS[6,2] = 0; GS[1,11] = t^(12); GS[1,13] = 0; GS[3,11] = c^(5); GS[3,12] = 0; GS[2,10] = c^9; GS[5,11] = 0
        sage: valid_captures_by_siege_black(GS, verbose = True)
         The piece T^6 at (2, 11) with value [6] is captured by siege.
         [((2, 11), [6])]
        

    """
    GS = copy(game_state)
    captured_by_siege = []

    # Get detailed data for all pieces
    white_pos_data = positions_w(GS)
    black_pos_data = positions_b(GS)

    # Create a set of black piece coordinates for efficient lookups
    black_pos_set = {item[0] for item in black_pos_data}

    # Define orthogonal directions
    shifts = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    # Check each white piece for siege
    for piece_data in white_pos_data:
        pos, poly = piece_data[0], piece_data[1]
        r, c = pos
        is_surrounded = True  # Assume surrounded until proven otherwise
        
        for dr, dc in shifts:
            adj_r, adj_c = r + dr, c + dc
            adj_pos = (adj_r, adj_c)

            # If the adjacent square is on the board, it must be occupied by a black piece
            if in_bounds(adj_pos):
                if adj_pos not in black_pos_set:
                    is_surrounded = False
                    break  # This direction is open, so no siege
            # If the adjacent square is off-board, it counts towards the siege
        
        # If the loop completed without finding an escape route, the piece is captured
        if is_surrounded:
            value = value_of_piece(GS, r, c)
            if verbose:
                # Use a format consistent with other verbose captures
                captured_info = ((pos, value, poly),)
                print(f"Capture Found: The piece {poly} at {pos} is captured by Siege.")
            else:
                captured_info = (pos, value)
            
            captured_by_siege.append(captured_info)
            
    return captured_by_siege




################################################################################################
################################ piece captures
################################################################################################


   
def take_all_captures_black(game_state, verbose = False):
    """
    Performs all of Black's legal captures of White pieces.

    NOTE:  ################# Capture format is described in c1, ..., c6 #################

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3,13] = 0; GS[5,0] = c^(25)
        sage: take_all_captures_black(GS, verbose = True)
         Capture by numbering on  (5, 1)
         There were  1  captures of White pieces by Black.
         <8x16 matrix omitted>

    """
    GS = copy(game_state)
    c1 = valid_captures_by_numbering_black(GS)
    # Capture format is ((r1, c1, [v1]), (r2, c2, [v2]), (r1, c1)) 
    c2 = valid_captures_by_addition_black(GS)
    # Capture format is [(r1, c1, [v1]), (r2, c2, [v2]), (r3, c3, [v3])] 
    c3 = valid_captures_by_subtraction_black(GS)
    # Capture format is [(r1, c1, [v1]), (r2, c2, [v2]), (r3, c3, [v3])] 
    c4 = valid_captures_by_multiplication_black(GS)
    # Capture format is [((r1, c1), v1), ((r2, c2), v2)] 
    c5 = valid_captures_by_division_black(GS)
    # Capture format is [((r1, c1), v1), ((r2, c2), v2)] 
    c6 = valid_captures_by_siege_black(GS) ##################### how is this implemented in a game??
    # Capture format is ((r, c), v))
    
    capture_count = 0

    # Capture by Numbering
    for cap in c1:
        # cap[0] is the attacker info tuple (r, c, [v])
        # cap[1] is the victim info tuple (r, c, [v])
        # We pass the full coordinate tuples.
        attacker_pos = (cap[0][0], cap[0][1])
        victim_pos = (cap[1][0], cap[1][1])
        GS = capture_piece(GS, attacker_pos, victim_pos, verbose=verbose)
        capture_count += 1

    # Capture by Sum/Difference
    for cap in c2 + c3:
        # cap[0][0] is the primary attacker's position
        GS = capture_piece(GS, cap[0][0], cap[2][0], verbose=verbose)
        capture_count += 1

    # Capture by Multiplication/Division
    for cap in c4 + c5:
        # cap[0][0] is the attacker's position
        GS = capture_piece(GS, cap[0][0], cap[1][0], verbose=verbose)
        capture_count += 1
        
    # Capture by Siege
    for cap in c6:
        # For siege, there isn't one attacker. We pass the victim's own location
        # as a placeholder for the attacker, as capture_piece doesn't use it for siege.
	########## Note:                         ###################################
	######### captures_as_dict   can be used to find an attacking piece ########
        GS = capture_piece(GS, cap[0], cap[0], verbose=verbose)
        capture_count += 1

    if verbose and capture_count > 0:
        print(f"There were {capture_count} captures of White/Even pieces by Black/Odd.")
        
    return GS
  


def take_all_captures_white(game_state, verbose = False):
    """
    Performs all of White's legal captures of Black pieces.

    NOTE:  ################# Capture format is described in c1, ..., c6 #################

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)


    """
    GS = copy(game_state)
    c1 = valid_captures_by_numbering_white(GS)
    # Capture format is ((r1, c1, [v1]), (r2, c2, [v2]), (r1, c1)) 
    c2 = valid_captures_by_addition_white(GS)
    # Capture format is [(r1, c1, [v1]), (r2, c2, [v2]), (r3, c3, [v3])] 
    c3 = valid_captures_by_subtraction_white(GS)
    # Capture format is [(r1, c1, [v1]), (r2, c2, [v2]), (r3, c3, [v3])] 
    c4 = valid_captures_by_multiplication_white(GS)
    # Capture format is [((r1, c1), v1), ((r2, c2), v2)] 
    c5 = valid_captures_by_division_white(GS)
    # Capture format is [((r1, c1), v1), ((r2, c2), v2)] 
    c6 = valid_captures_by_siege_white(GS)
    # Capture format is ((r, c), v))
    
    capture_count = 0

    # Capture by Numbering
    for cap in c1:
        # cap[0] is the attacker info tuple (r, c, [v])
        # cap[1] is the victim info tuple (r, c, [v])
        # We pass the full coordinate tuples.
        attacker_pos = (cap[0][0], cap[0][1])
        victim_pos = (cap[1][0], cap[1][1])
        GS = capture_piece(GS, attacker_pos, victim_pos, verbose=verbose)
        capture_count += 1

    # Capture by Sum/Difference
    for cap in c2 + c3:
        # cap[0][0] is the primary attacker's position
        GS = capture_piece(GS, cap[0][0], cap[2][0], verbose=verbose)
        capture_count += 1

    # Capture by Multiplication/Division
    for cap in c4 + c5:
        # cap[0][0] is the attacker's position
        GS = capture_piece(GS, cap[0][0], cap[1][0], verbose=verbose)
        capture_count += 1
        
    # Capture by Siege
    for cap in c6:
        # For siege, there isn't one attacker. We pass the victim's own location
        # as a placeholder for the attacker, as capture_piece doesn't use it for siege.
	########## Note:                         ###################################
	######### captures_as_dict   can be used to find an attacking piece ########
        GS = capture_piece(GS, cap[0], cap[0], verbose=verbose)
        capture_count += 1

    if verbose and capture_count > 0:
        print(f"There were {capture_count} captures of Black pieces by White.")
        
    return GS
    

def legal_moves_captures_white(game_state):
    """
    return the list of legal moves, captures (as a pair of lists) by White in the game state GS.

    Should the total be the "rank" of White's position?

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: GS[1,9] = t^(12)
        sage: GS[1,13] = 0
        sage: legal_moves_captures_white(GS)
        ([((2, 2), (1, 3)),
          ((2, 3), (3, 4)),
          ((2, 3), (1, 4)),
          ((3, 3), (4, 4)),
          ((3, 3), (2, 4)),
          ((4, 3), (5, 4)),
          ((4, 3), (3, 4)),
          ((5, 2), (6, 3)),
          ((5, 3), (6, 4)),
          ((5, 3), (4, 4)),
          ((0, 2), (0, 4)),
          ((1, 2), (1, 4)),
          ((6, 2), (6, 4)),
          ((7, 2), (7, 4)),
          ((1, 0), (4, 0)),
          ((6, 0), (3, 0))],
         [((1, 2, 72), (1, 9, 12))]) ## capture by division

    """
    GS = copy(game_state)
    m1 = moves_circle_white(GS, verbose = False)
    m2 = moves_triangle_white(GS, verbose = False)
    m3 = moves_square_white(GS, verbose = False)
    m4 = moves_pyramid_white(GS, verbose = False) 
    c1 = valid_captures_by_numbering_white(GS, verbose = True)
    c2 = valid_captures_by_addition_white(GS, verbose = True)
    c3 = valid_captures_by_subtraction_white(GS, verbose = True)
    c4 = valid_captures_by_multiplication_white(GS, verbose = True)
    c5 = valid_captures_by_division_white(GS, verbose = True)
    c6 = valid_captures_by_siege_white(GS, verbose = True)
    L = (m1+m2+m3+m4,c1+c2+c3+c4+c5+c6)
    return L

def legal_moves_captures_black(game_state):
    """
    return the list of legal moves, captures (as a pair of lists) by Black in the game state GS.

    Should the total be the "rank" of Black's position?

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: GS[1,11] = T^9
        sage: GS[7,2] = 0
        sage: legal_moves_captures_black(GS)
        ([((2, 12), (3, 11)),
          ((2, 13), (1, 12)),
          ((3, 12), (2, 11)),
          ((3, 12), (4, 11)),
          ((4, 12), (3, 11)),
          ((4, 12), (5, 11)),
          ((5, 12), (4, 11)),
          ((5, 12), (6, 11)),
          ((5, 13), (6, 12)),
          ((0, 13), (0, 11)),
          ((6, 13), (6, 11)),
          ((7, 13), (7, 11)),
          ((1, 15), (4, 15)),
          ((6, 15), (3, 15))],
         [((1, 13), (2, 12), (1, 11), [12, 3, 9])]) ## capture by subtraction

    """
    GS = copy(game_state)
    m1 = moves_circle_black(GS, verbose = False)
    m2 = moves_triangle_black(GS, verbose = False)
    m3 = moves_square_black(GS, verbose = False)
    m4 = moves_pyramid_black(GS, verbose = False) 
    c1 = valid_captures_by_numbering_black(GS)
    c2 = valid_captures_by_addition_black(GS)
    c3 = valid_captures_by_subtraction_black(GS)
    c4 = valid_captures_by_multiplication_black(GS)
    c5 = valid_captures_by_division_black(GS)
    c6 = valid_captures_by_siege_black(GS)
    L = (m1+m2+m3+m4, c1 + c2+c3 + c4+c5 + c6)
    return L


def order_moves_state_black(game_state, verbose = False):
    """
    return a list of 3 lists all Black/Odd (best/good/other) moves that are sorted by their closeness
    to enemy (Even/White) territory. If the piece is already in enemy territory,
    add it to the end ("other") of the list.

    Can be used as a metric for judging the goodness of a move.

    NOTE: Assumes that no captures are possible in the given <game_state>.
    
    Added a level if the enemy is close to friendly territory.   NEEDS TESTING !!!!!!!!!!!!!!!!!

    Used in good_move_black below.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: ord_mvs_odd = order_moves_state_black(GSp, verbose = True)
         Best Black/Odd moves:  []
         Good Black/Odd moves:  [((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), ((5, 12), (5, 11)), ((0, 13), (0, 11)),
	  ((1, 13), (1, 11)), ((6, 13), (6, 11)), ((7, 13), (7, 11))]
         Remaining Black/Odd moves:  [((2, 12), (1, 12)), ((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), ((5, 12), (6, 12)),
	  ((5, 12), (5, 11)), ((0, 13), (0, 11)), ((1, 13), (1, 11)), ((6, 13), (6, 11)), ((7, 13), (7, 11)), ((1, 15), (4, 15)), ((6, 15), (3, 15))]
        sage: print(ord_mvs_odd[0]+ord_mvs_odd[1]+ord_mvs_odd[2])
         [((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), ((5, 12), (5, 11)), ((0, 13), (0, 11)), ((1, 13), (1, 11)), ((6, 13), (6, 11)),
          ((7, 13), (7, 11)), ((2, 12), (1, 12)), ((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), ((5, 12), (6, 12)), ((5, 12), (5, 11)),
	  ((0, 13), (0, 11)), ((1, 13), (1, 11)), ((6, 13), (6, 11)), ((7, 13), (7, 11)), ((1, 15), (4, 15)), ((6, 15), (3, 15))]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS0 = move_piece(GSp, (1,2), (1,4))
        sage: time ord_mvs_odd = order_moves_state_black(GS0, verbose = True)
         Bestest Black/Odd moves:  [((1, 13), (1, 11))]
         Best Black/Odd moves:  []
         Good Black/Odd moves:  [((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), ((5, 12), (5, 11)), ((0, 13), (0, 11)), 
                                 ((6, 13), (6, 11)), ((7, 13), (7, 11))]
         Remaining Black/Odd moves:  [((2, 12), (1, 12)), ((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), ((5, 12), (6, 12)), 
                                      ((5, 12), (5, 11)), ((0, 13), (0, 11)), ((1, 13), (1, 11)), ((6, 13), (6, 11)), ((7, 13), (7, 11)), 
                                      ((1, 15), (4, 15)), ((6, 15), (3, 15))]
         CPU times: user 13.5 s, sys: 56 ms, total: 13.6 s
         Wall time: 13.6 s


    """
    GS = copy(game_state)
    L = legal_moves_captures_black(GS)[0]
    #print("000", L)
    ################## bester code block:
    moves_with_cap = []
    for xx in L:
        GS0 = move_piece(GS, xx[0], xx[1])
        c1 = valid_captures_by_numbering_black(GS0)
        c4 = valid_captures_by_multiplication_black(GS0)
        c5 = valid_captures_by_division_black(GS0)
    #    L0 = legal_moves_captures_black(GS0)
    #    if len(L0[1])>0: ## this means the move xx results in a capture
    #        moves_with_cap = moves_with_cap + [xx]
        if len(c1+c4+c5)>0: ## this means the move xx results in a capture
            moves_with_cap = moves_with_cap + [xx]
    #print("1111", moves_with_cap)
    ################## end code block -- works but c2, c3 are too slow 
    ## sort moves
    L_rem = [xx for xx in L if not(xx in moves_with_cap)] ## the remainder of the moves
    ############## move closer
    closest_cog = []
    for mm in L_rem:
        cogw = center_of_gravity(GS, piece_color = "white", by_rank=True)
        GS0 = move_piece(GS, mm[0], mm[1])
        cogb = center_of_gravity(GS0, piece_color = "black")
        closest_cog = closest_cog + [(sqrt((cogw[0]-cogb[0])^2+(cogw[1]-cogb[1])^2), mm)]
    closest_cog.sort()
    min_dist = closest_cog[0][0]
    nearest_moves = [mm[1] for mm in closest_cog if mm[0]==min_dist]
    L_rem2 = [xx for xx in L_rem if not(xx in nearest_moves)] ## the 2nd remainder of the moves
    ############## move forward
    best_moves = [xx for xx in L_rem2 if (xx[0][1] > xx[1][1]) and (xx[0][1]>8) and (xx[1][1]<7)]
    good_moves = [xx for xx in L_rem2 if (xx[0][1] > xx[1][1]) and xx[0][1]>8 and (xx[1][1]>8)]
    other_moves = [xx for xx in L_rem2 if not(xx[0][1] < xx[1][1]) or (xx[0][1]>7)]
    moves_sep = [moves_with_cap, nearest_moves, best_moves, good_moves, other_moves]
    if verbose:
        print("Captivating Black/Odd moves: ", moves_with_cap)
        print("Nearest Black/Odd moves: ", nearest_moves)
        print("Best (remaining) Black/Odd moves: ", best_moves)
        print("Good Black/Odd moves: ", good_moves)
        print("Remaining Black/Odd moves: ", other_moves)
        return moves_sep
    return moves_sep
    
def order_moves_state_white(game_state, verbose = False):
    """
    return a list of 3 lists of all of White/Even's (best/good/other) moves, 
    sorted by their closeness to enemy (Odd/Black) territory. If the piece is already in 
    enemy territory, add it to the end ("other") of the list.

    If distance to enemy territory used as a metric for judging the goodness of a move then
    use this function.

    NOTE: Assumes that no captures are possible in the given game_state.
    
    ################# 
    TODO: Add an fast computation of a new layer of moves that, if made, would
          immediately result in the white COG moving closer to the black COG.
    QUESTION: Why doesn't this simply sort the moves longest to shortest?
              If that's it, then there are must faster checks than COGs.   FIX THIS??? !!!!!!!!!!!1
    ################# how can this be done quickly?

    Used in good_move_white below.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: ord_mvs_even = order_moves_state_white(GSp, verbose = True)
         Best Even/White moves:  []
         Good Even/White moves:  [((2, 3), (2, 4)), ((3, 3), (3, 4)), ((4, 3), (4, 4)), ((5, 3), (5, 4)), ((0, 2), (0, 4)), ((1, 2), (1, 4)),
	  ((6, 2), (6, 4)), ((7, 2), (7, 4))]
         Remaining Even/White moves:  [((2, 3), (1, 3)), ((5, 3), (6, 3)), ((1, 0), (4, 0)), ((6, 0), (3, 0))]
        sage: print(ord_mvs_odd[0]+ord_mvs_odd[1]+ord_mvs_odd[2])
         [((2, 3), (2, 4)), ((3, 3), (3, 4)), ((4, 3), (4, 4)), ((5, 3), (5, 4)), ((0, 2), (0, 4)), ((1, 2), (1, 4)), ((6, 2), (6, 4)),
	  ((7, 2), (7, 4)), ((2, 3), (1, 3)), ((5, 3), (6, 3)), ((1, 0), (4, 0)), ((6, 0), (3, 0))]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS0 = move_piece(GSp, (1,2), (1,4))
        sage: ord_mvs_even = order_moves_state_white(GS0, verbose = True)
         Captivating White/Even moves:  [((1, 4), (1, 6))]
         Nearest White/Even moves:  [((0, 2), (0, 4)), ((6, 2), (6, 4)), ((7, 2), (7, 4))]
         Best Even/White moves:  []
         Good Even/White moves:  []
         Remaining Even/White moves:  [((2, 2), (1, 2)), ((2, 3), (1, 3)), ((5, 3), (6, 3)), ((1, 4), (3, 4)), ((1, 4), (1, 2)), ((1, 0), (4, 0)), ((6, 0), (3, 0))]
        sage: print(ord_mvs_even[0])
         [((1, 4), (1, 6))]
        sage: print(ord_mvs_even[1])
         [((0, 2), (0, 4)), ((6, 2), (6, 4)), ((7, 2), (7, 4))]
        sage: print(ord_mvs_even[2])
         []
        sage: print(ord_mvs_even[3])
         []
        sage: print(ord_mvs_even[4])
         [((2, 2), (1, 2)), ((2, 3), (1, 3)), ((5, 3), (6, 3)), ((1, 4), (3, 4)), ((1, 4), (1, 2)), ((1, 0), (4, 0)), ((6, 0), (3, 0))]

    """
    GS = copy(game_state)
    L = legal_moves_captures_white(GS)[0]
    #print("000", L)
    ################## bester code block:
    moves_with_cap = []
    for xx in L:
        GS0 = move_piece(GS, xx[0], xx[1])
        c1 = valid_captures_by_numbering_white(GS0)
        #c2 = valid_captures_by_addition_white(GS0)
        #c3 = valid_captures_by_subtraction_white(GS0)
        c4 = valid_captures_by_multiplication_white(GS0)
        c5 = valid_captures_by_division_white(GS0)
    #    L0 = legal_moves_captures_white(GS0)
    #    if len(L0[1])>0: ## this means the move xx results in a capture
    #        moves_with_cap = moves_with_cap + [xx]
        if len(c1+c4+c5)>0: ## this means the move xx results in a capture
            moves_with_cap = moves_with_cap + [xx]
    #print("1111", moves_with_cap)
    ################## end code block -- works but c2, c3 are too slow 
    ## sort moves
    L_rem = [xx for xx in L if not(xx in moves_with_cap)] ## the remainder of the moves
    ############## move closer
    closest_cog = []
    for mm in L_rem:
        cogb = center_of_gravity(GS, piece_color = "black", by_rank=True)
        GS0 = move_piece(GS, mm[0], mm[1])
        cogw = center_of_gravity(GS0, piece_color = "white")
        closest_cog = closest_cog + [(sqrt((cogw[0]-cogb[0])^2+(cogw[1]-cogb[1])^2), mm)]
    closest_cog.sort()
    min_dist = closest_cog[0][0]
    nearest_moves = [mm[1] for mm in closest_cog if mm[0]==min_dist]
    L_rem2 = [xx for xx in L_rem if not(xx in nearest_moves)] ## the 2nd remainder of the moves
    best_moves = [xx for xx in L_rem2 if (xx[0][1] > xx[1][1]) and (xx[0][1]>8) and (xx[1][1]<7)]
    good_moves = [xx for xx in L_rem2 if (xx[0][1] > xx[1][1]) and xx[0][1]>8 and (xx[1][1]>8)]
    other_moves = [xx for xx in L_rem2 if not(xx[0][1] < xx[1][1]) or (xx[0][1]>7)]
    moves_sep = [moves_with_cap, nearest_moves, best_moves, good_moves, other_moves]
    if verbose:
        print("Captivating White/Even moves: ", moves_with_cap)
        print("Nearest White/Even moves: ", nearest_moves)
        print("Best Even/White moves: ", best_moves)
        print("Good Even/White moves: ", good_moves)
        print("Remaining Even/White moves: ", other_moves)
        return moves_sep
    return moves_sep
    
def rank_state_white(game_state):
    """
    return the rank of White's position (a subjective assessment of which
    opponent is favored in the position).

    If used as a metric for judging the goodness of a move, in case of a tie (or 
    an almost tie) also include the "complement": which of the tied-for-best moves also
    decreases the enemy's choices?

    Idea/Question: Does counting all the captures after each move add any new captures?

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: rank_state_white(GS)
         16
    """
    GS = copy(game_state)
    L = legal_moves_captures_white(GS)
    return len(L[0])+5*len(L[1])
    

def rank_state_black(game_state):
    """
    return the rank of Black's position (a subjective assessment of which
    opponent is favored in the position).

    If used as a metric for judging the goodness of a move, in case of a tie (or 
    an almost tie) also include the "complement": which of the tied-for-best moves also
    decreases the enemy's choices?

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: rank_state_black(GS)
         16

    """
    GS = copy(game_state)
    L = legal_moves_captures_black(GS)
    return len(L[0])+2*len(L[1])


def find_best_move_white(game_state, verbose = False):
    """
    return White's move which (a) has the largest rank (using rank_state_white), 
    (b) if there is more than one move with maximal rank pick one that also 
    minimizes with White rank (using rank_state_white).

    ################# Can be SLOW!!!!!!!!

    Note: use board_initial_matrix(pyramid_decomposition=True)

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS = move_piece(GS, (3, 12), (3, 11))
        sage: time find_best_move_white(GS)
         CPU times: user 1min 20s, sys: 130 ms, total: 1min 20s
         Wall time: 1min 20s
         ((3, 3), (3, 4))
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3,3] = 0; GS[0,12] = C^6; GS[6,2] = 0; GS[1,11] = T^6
        sage: time find_best_move_white(GS)
         CPU times: user 3min 56s, sys: 0 ns, total: 3min 56s
         Wall time: 3min 56s
         ((4, 3), (4, 4))

    """
    original_GS = copy(game_state) # Work with a copy
    # Calculate legal moves and captures based on the original state
    all_m_c = legal_moves_captures_white(original_GS)
    mvs = all_m_c[0]
    #########################################################
    # Evaluate potential states resulting from MOVES
    #########################################################
    move_states = []
    for move in mvs:
        # Ensure move is in the expected format (start_pos, end_pos)
        # The moves functions return ((val, start, end)) or (start, end)
        if len(move) == 3:                                        # Format is (val, start, end)
            start_pos, end_pos = move[1], move[2]
        elif len(move) == 2:                                      # Format is (start, end)
            start_pos, end_pos = move[0], move[1]
        else:
            print(f"Warning: Unexpected move format skipped: {move}")
            continue
        # Simulate the move on a fresh copy of the original state
        temp_GS_after_move = move_piece(original_GS, start_pos, end_pos)
        # Calculate ranks for this potential future state
        white_rank = rank_state_white(temp_GS_after_move)
        black_rank = rank_state_black(temp_GS_after_move)       # For tie-breaking
        move_states.append([white_rank, black_rank, move])      # Store ranks and the original move action
    #########################################################
    # Combine evaluated states
    # Currently combining moves and captures by numbering
    evaluated_states = move_states 
    if not evaluated_states:
        print("No legal moves or evaluated captures found. White loses.")
        return None # Or handle appropriately
    # Sort by White's rank (descending), then Black's rank (ascending for tie-break)
    evaluated_states.sort(key=lambda x: (x[0], -x[1]), reverse=True)
    # The best action is the first element after sorting
    best_action = evaluated_states[0][2]                    # Return the original move/capture action
    if verbose:
        print("White's best move: move piece at ", best_action[0], " to ", best_action[1])
    return best_action


def find_best_move_black(game_state, verbose = False):
    """
    return Black's move which (a) has the largest rank (using rank_state_black), 
    (b) if there is more than one move with maximal rank pick one that also 
    minimizes White rank (using rank_state_black).

    ######################## add option capture_check = True/False
    ######################## to look for captures after the best move was made

    Note: use board_initial_matrix(pyramid_decomposition=True)

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS = move_piece(GS, (3, 3), (3, 4))
        sage: time find_best_move_black(GS)
         CPU times: user 1min 23s, sys: 350 ms, total: 1min 23s
         Wall time: 1min 23s
         ((1, 15), (4, 15))
        sage: print(legal_moves_captures_black(GS))
         ([((2, 12), (1, 12)), ((2, 12), (2, 11)), ((3, 12), (3, 11)), ((4, 12), (4, 11)), 
           ((5, 12), (6, 12)), ((5, 12), (5, 11)), ((0, 13), (0, 11)), ((1, 13), (1, 11)), 
           ((6, 13), (6, 11)), ((7, 13), (7, 11)), ((1, 15), (4, 15)), ((6, 15), (3, 15))], 
           [], [], [], [])

    """
    original_GS = copy(game_state) # Work with a copy
    GS = take_all_captures_black(original_GS, verbose = False)
    # Calculate legal moves and captures based on the original state
    all_m_c = legal_moves_captures_black(GS)
    mvs = all_m_c[0]
    #########################################################
    # Evaluate potential states resulting from MOVES
    #########################################################
    move_states = []
    for move in mvs:
        # Ensure move is in the expected format (start_pos, end_pos)
        # The moves functions return ((val, start, end)) or (start, end)
        if len(move) == 3:                                        # Format is (val, start, end)
            start_pos, end_pos = move[1], move[2]
        elif len(move) == 2:                                      # Format is (start, end)
            start_pos, end_pos = move[0], move[1]
        else:
            print(f"Warning: Unexpected move format skipped: {move}")
            continue
        # Simulate the move on a fresh copy of the original state
        temp_GS_after_move = move_piece(original_GS, start_pos, end_pos)
        # Calculate ranks for this potential future state
        white_rank = rank_state_white(temp_GS_after_move)
        black_rank = rank_state_black(temp_GS_after_move)       # For tie-breaking
        move_states.append([white_rank, black_rank, move])      # Store ranks and the original move action
    #########################################################
    # Combine evaluated states
    # Currently combining moves and captures by numbering
    evaluated_states = move_states 
    if not evaluated_states:
        print("No legal moves found. Black loses.")
        return None # Or handle appropriately
    # Sort by Black's rank (descending), then White's rank (ascending for tie-break)
    evaluated_states.sort(key=lambda x: (x[0], -x[1]), reverse=True)
    # The best action is the first element after sorting
    best_action = evaluated_states[0][2]                    # Return the original move/capture action
    if verbose:
        print("White's best move: move piece at ", best_action[0], " to ", best_action[1])
    return best_action


def good_move_black(game_state, verbose = False):
    """
    Uses order_moves_state_black to return a randomly selected element from the
    list of best possible Black moves (using the distance metric)

    Note: output is randomly selected.
    
    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: good_move_black(GSp, verbose = False)
         ((4, 12), (4, 11))
        sage: good_move_black(GSp, verbose = True)
         ((3, 12), (3, 11))  is a *good* move
         ((3, 12), (3, 11)) 

    """
    GS = copy(game_state)
    LL = order_moves_state_black(game_state, verbose = False) ## this is a triple: best, good, other
    num_bestest = len(LL[0])
    num_best = len(LL[1])
    num_good = len(LL[2])
    num_other = len(LL[3])
    #print("000", num_best, num_good, num_other, LL[0], "\n", LL[1], "\n", LL[2])
    if num_bestest>0:
        ii = random.randint(0, num_bestest-1)
        if verbose:
            print(LL[0][ii], " is a *bestest* move")
        return LL[0][ii]
    if num_best>0:
        ii = random.randint(0, num_best-1)
        if verbose:
            print(LL[1][ii], " is a *best* move")
        return LL[1][ii]
    if num_good>0:
        jj = random.randint(0, num_good-1)
        if verbose:
            print(LL[2][jj], " is a *good* move")
        return LL[2][jj]
    if num_other > 0:
        kk = random.randint(0, num_other-1)
        if verbose:
            print(LL[3][kk], " is a legal move for Black/Odd, but not necessarily good")
        return LL[3][k]
    return [], "There are no legal moves for Black/Odd"
    
def good_move_white(game_state, verbose = False):
    """
    Uses order_moves_state_white to return a randomly selected element from the
    list of best possible White moves (using the distance metric)

    Note: output is randomly selected.
    
    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: good_move_white(GSp, verbose = True)
         ((6, 2), (6, 4))  is a *good* move
         ((6, 2), (6, 4))

    """
    GS = copy(game_state)
    LL = order_moves_state_white(game_state, verbose = False) ## this is a triple: best, good, other
    num_bestest = len(LL[0])
    num_best = len(LL[1])
    num_good = len(LL[2])
    num_other = len(LL[3])
    #print("000", num_best, num_good, num_other, LL[0], "\n", LL[1], "\n", LL[2])
    if num_bestest>0:
        ii = random.randint(0, num_bestest-1)
        if verbose:
            print(LL[0][ii], " is a *bestest* move")
        return LL[0][ii]
    if num_best>0:
        ii = random.randint(0, num_best-1)
        if verbose:
            print(LL[1][ii], " is a *best* move")
        return LL[1][ii]
    if num_good>0:
        jj = random.randint(0, num_good-1)
        if verbose:
            print(LL[2][jj], " is a *good* move")
        return LL[2][jj]
    if num_other > 0:
        kk = random.randint(0, num_other-1)
        if verbose:
            print(LL[3][kk], " is a legal move for Even/White, but not necessarily good")
        return LL[3][k]
    return [], "There are no legal moves for White/Even"
    

def make_good_move_black(game_state, verbose = False):
    """
    Uses good_move_black to make a randomly selected element from the
    list of best possible Black moves (using the distance metric)

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS0 = make_good_move_black(GSp, verbose = True)
         Black/Odd played: c^9m6l6
        sage: board_plot(GS0)
         Launched png viewer for Graphics object consisting of 185 graphics primitives

    """
    GS = copy(game_state)
    mv = good_move_black(GS, verbose = False)
    pc_start = coordinate_to_algebraic(mv[0][0], mv[0][1])
    pc_end = coordinate_to_algebraic(mv[1][0], mv[1][1])
    if verbose:
        print("Black/Odd played: " + str(GS[mv[0][0], mv[0][1]]) + pc_start + pc_end)
    return move_piece(GS, mv[0], mv[1])

def make_good_move_white(game_state, verbose = False):
    """
    Uses good_move_white to make a randomly selected element from the
    list of best possible White moves (using the distance metric)

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS0 = make_good_move_white(GSp, verbose = True)
         White/Even played: T^9c8e8
        sage: board_plot(GS0)
         Launched png viewer for Graphics object consisting of 185 graphics primitives


    """
    GS = copy(game_state)
    mv = good_move_white(GS, verbose = False)
    pc_start = coordinate_to_algebraic(mv[0][0], mv[0][1])
    pc_end = coordinate_to_algebraic(mv[1][0], mv[1][1])
    if verbose:
        print("White/Even played: " + str(GS[mv[0][0], mv[0][1]]) + pc_start + pc_end)
    return move_piece(GS, mv[0], mv[1])


def white_takes_black_by_numbering():
    """
    lists all such captures, listing the piece, its value, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece)

    EXAMPLES:
        sage: wtb = white_takes_black_by_numbering()
        sage: len(wtb)
        25
        sage: print(wtb)
         [[(S^81, 81, (6, 0)), (c^81, 81, (5, 13))], [(T^81, 81, (0, 2)), (c^81, 81, (5, 13))], 
          [(C^64, 64, (2, 2)), (s^64, 64, (7, 14))], [(C^64, 64, (2, 2)), (t^64, 64, (5, 14))], 
          [(T^49, 49, (2, 1)), (s^49, 49, (0, 15))], [(T^49, 49, (2, 1)), (c^49, 49, (7, 14))], 
          [(T^49, 49, (2, 1)), (s^49, 49, (4, 13))], [(C^36, 36, (3, 2)), (s^36, 36, (0, 15))], 
          [(C^36, 36, (3, 2)), (t^36, 36, (7, 14))], [(S^36, 36, (1, 1)), (s^36, 36, (0, 15))], 
          [(S^36, 36, (1, 1)), (t^36, 36, (7, 14))], [(S^25, 25, (1, 1)), (s^25, 25, (3, 14))], 
          [(S^25, 25, (1, 1)), (c^25, 25, (0, 14))], [(S^25, 25, (7, 0)), (s^25, 25, (3, 14))], 
          [(S^25, 25, (7, 0)), (c^25, 25, (0, 14))], [(T^25, 25, (5, 1)), (s^25, 25, (3, 14))], 
          [(T^25, 25, (5, 1)), (c^25, 25, (0, 14))], [(C^16, 16, (4, 2)), (s^16, 16, (7, 14))], 
          [(C^16, 16, (4, 2)), (t^16, 16, (3, 13))], [(S^16, 16, (1, 1)), (s^16, 16, (7, 14))], 
          [(S^16, 16, (1, 1)), (t^16, 16, (3, 13))], [(T^9, 9, (7, 2)), (c^9, 9, (0, 13))], 
          [(T^9, 9, (7, 2)), (c^9, 9, (1, 13))], [(S^9, 9, (1, 1)), (c^9, 9, (0, 13))], 
          [(S^9, 9, (1, 1)), (c^9, 9, (1, 13))]]

	 
    """
    white_takes_black = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i in range(nwpcs):
        for j in range(nbpcs):
            wpc = wpcs[i][0]
            bpc = bpcs[j][0]
            degwpc = wpcs[i][1]
            degbpc = bpcs[j][1]
            wpc_pos = wpcs[i][2]
            bpc_pos = bpcs[j][2]
            #if (degwpc == degbpc):
            #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
            if (degwpc == degbpc) and parity_check(wpc, wpc_pos, bpc, bpc_pos):
                #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                #print(i, j, wpc, bpc)
                white_takes_black = white_takes_black + [[(wpc, degwpc, wpc_pos), (bpc, degbpc, bpc_pos)]]
    return white_takes_black




def black_takes_white_by_numbering():
    """
    lists all such captures that are potentially possible in the game.

    EXAMPLES:
        sage: btw = black_takes_white_by_numbering()
        sage: len(btw)
         25
        sage: print(btw)
         [[(c^81, 81, (5, 13)), (S^81, 81, (6, 0))], [(c^81, 81, (5, 13)), (T^81, 81, (0, 2))], 
          [(s^64, 64, (7, 14)), (C^64, 64, (2, 2))], [(t^64, 64, (5, 14)), (C^64, 64, (2, 2))], 
          [(s^49, 49, (0, 15)), (T^49, 49, (2, 1))], [(c^49, 49, (7, 14)), (T^49, 49, (2, 1))], 
          [(s^49, 49, (4, 13)), (T^49, 49, (2, 1))], [(s^36, 36, (0, 15)), (C^36, 36, (3, 2))], 
          [(s^36, 36, (0, 15)), (S^36, 36, (1, 1))], [(t^36, 36, (7, 14)), (C^36, 36, (3, 2))], 
          [(t^36, 36, (7, 14)), (S^36, 36, (1, 1))], [(s^25, 25, (3, 14)), (S^25, 25, (1, 1))], 
          [(s^25, 25, (3, 14)), (S^25, 25, (7, 0))], [(s^25, 25, (3, 14)), (T^25, 25, (5, 1))], 
          [(c^25, 25, (0, 14)), (S^25, 25, (1, 1))], [(c^25, 25, (0, 14)), (S^25, 25, (7, 0))], 
          [(c^25, 25, (0, 14)), (T^25, 25, (5, 1))], [(s^16, 16, (7, 14)), (C^16, 16, (4, 2))], 
          [(s^16, 16, (7, 14)), (S^16, 16, (1, 1))], [(t^16, 16, (3, 13)), (C^16, 16, (4, 2))], 
          [(t^16, 16, (3, 13)), (S^16, 16, (1, 1))], [(c^9, 9, (0, 13)), (T^9, 9, (7, 2))], 
          [(c^9, 9, (0, 13)), (S^9, 9, (1, 1))], [(c^9, 9, (1, 13)), (T^9, 9, (7, 2))], 
          [(c^9, 9, (1, 13)), (S^9, 9, (1, 1))]]

         [[(c^81, 81, (6, 14)), (S^81, 81, (2, 2))], [(c^81, 81, (7, 13)), (T^81, 81, (2, 2))],
	  [(s^64, 64, (5, 13)), (C^64, 64, (6, 1))], [(t^64, 64, (5, 13)), (C^64, 64, (3, 1))],
	  [(s^49, 49, (1, 14)), (T^49, 49, (1, 1))], [(c^49, 49, (1, 14)), (T^49, 49, (1, 1))],
	  [(s^49, 49, (1, 14)), (T^49, 49, (7, 0))], [(s^36, 36, (4, 14)), (C^36, 36, (5, 1))],
	  [(s^36, 36, (0, 15)), (S^36, 36, (5, 1))], [(t^36, 36, (4, 14)), (C^36, 36, (1, 1))],
	  [(t^36, 36, (0, 15)), (S^36, 36, (1, 1))], [(s^25, 25, (7, 14)), (S^25, 25, (4, 2))],
	  [(s^25, 25, (4, 13)), (T^25, 25, (4, 2))], [(s^25, 25, (0, 15)), (S^25, 25, (4, 2))],
	  [(c^25, 25, (7, 14)), (S^25, 25, (1, 1))], [(c^25, 25, (4, 13)), (T^25, 25, (1, 1))],
	  [(c^25, 25, (0, 15)), (S^25, 25, (1, 1))], [(s^16, 16, (7, 14)), (C^16, 16, (7, 1))],
	  [(s^16, 16, (2, 14)), (S^16, 16, (7, 1))], [(t^16, 16, (7, 14)), (C^16, 16, (7, 2))],
	  [(t^16, 16, (2, 14)), (S^16, 16, (7, 2))], [(c^9, 9, (0, 14)), (T^9, 9, (2, 3))],
	  [(c^9, 9, (7, 14)), (S^9, 9, (2, 3))], [(c^9, 9, (0, 14)), (T^9, 9, (6, 2))],
	  [(c^9, 9, (7, 14)), (S^9, 9, (6, 2))]]


    """
    black_takes_white = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i in range(nbpcs):
        for j in range(nwpcs):
            wpc = wpcs[j][0]
            bpc = bpcs[i][0]
            degwpc = wpcs[j][1]
            degbpc = bpcs[i][1]
            wpc_pos = wpcs[j][2]
            bpc_pos = bpcs[i][2]
            if (degbpc == degwpc) and parity_check(wpc, wpc_pos, bpc, bpc_pos):
                #if not([(bpc, degbpc), (wpc, degwpc)] in black_takes_white):
                    black_takes_white = black_takes_white + [[(bpc, degbpc, bpc_pos), (wpc, degwpc, wpc_pos)]]
    return black_takes_white


def white_takes_black_by_addition():
    """
    lists all such captures, listing the pieces, the values, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece)

    EXAMPLES:
        sage: wtb = white_takes_black_by_addition()
        sage: len(wtb)
         118
        sage: print(wtb)
         [[(S^289, 289, (0, 0)), (T^72, 72, (1, 2)), (s^361, 361, (7, 15))],
          [(S^153, 153, (0, 1)), (T^72, 72, (1, 2)), (s^225, 225, (6, 15))],
          [(P^91, 91, (1, 1)), (T^9, 9, (7, 2)), (t^100, 100, (7, 13))],
          ...
          <omitted>
	 
    """
    white_takes_black = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i1 in range(nwpcs):
        for i2 in range(nwpcs):
            for j in range(nbpcs):
                wpc1 = wpcs[i1][0]
                wpc2 = wpcs[i2][0]
                bpc = bpcs[j][0]
                degwpc1 = wpcs[i1][1]
                degwpc2 = wpcs[i2][1]
                degbpc = bpcs[j][1]
                wpc_pos1 = wpcs[i1][2]
                wpc_pos2 = wpcs[i2][2]
                bpc_pos = bpcs[j][2]
                #if (degwpc == degbpc):
                #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
                if (degwpc1+degwpc2 == degbpc) and parity_check(wpc1, wpc_pos1, bpc, bpc_pos) and parity_check(wpc2, wpc_pos2, bpc, bpc_pos):
                    #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                    #print(i, j, wpc, bpc)
                    white_takes_black = white_takes_black + [[(wpc1, degwpc1, wpc_pos1), (wpc2, degwpc2, wpc_pos2), (bpc, degbpc, bpc_pos)]]
    return white_takes_black


def black_takes_white_by_addition():
    """
    lists all such captures, listing the pieces, the values, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece)

    EXAMPLES:
        sage: btw = black_takes_white_by_addition()
        sage: len(btw)
         82
        sage: print(btw)
         [[(s^225, 225, (6, 15)), (s^64, 64, (7, 14)), (S^289, 289, (0, 0))],
          [(s^225, 225, (6, 15)), (t^64, 64, (5, 14)), (S^289, 289, (0, 0))],
          [(s^120, 120, (6, 14)), (s^49, 49, (0, 15)), (S^169, 169, (1, 0))],
          ...
          <omitted>
	 
    """
    black_takes_white = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i1 in range(nbpcs):
        for i2 in range(nbpcs):
            for j in range(nwpcs):
                bpc1 = bpcs[i1][0]
                bpc2 = bpcs[i2][0]
                wpc  = wpcs[j][0]
                degbpc1 = bpcs[i1][1]
                degbpc2 = bpcs[i2][1]
                degwpc  = wpcs[j][1]
                bpc_pos1 = bpcs[i1][2]
                bpc_pos2 = bpcs[i2][2]
                wpc_pos = wpcs[j][2]
                #if (degwpc == degbpc):
                #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
                if (degbpc1+degbpc2 == degwpc) and parity_check(bpc1, bpc_pos1, wpc, wpc_pos) and parity_check(bpc2, bpc_pos2, wpc, wpc_pos):
                    #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                    #print(i, j, wpc, bpc)
                    black_takes_white = black_takes_white + [[(bpc1, degbpc1, bpc_pos1), (bpc2, degbpc2, bpc_pos2), (wpc, degwpc, wpc_pos)]]
    return black_takes_white


def white_takes_black_by_subtraction():
    """
    lists all such captures, listing the pieces, the values, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece)

    EXAMPLES:
        sage: wtb = white_takes_black_by_subtraction()
        sage: len(wtb)
         118
        sage: print(wtb)
         [[(S^289, 289, (0, 0)), (S^169, 169, (1, 0)), (s^120, 120, (6, 14))],
          [(S^289, 289, (0, 0)), (C^64, 64, (2, 2)), (s^225, 225, (6, 15))],
          [(S^169, 169, (1, 0)), (S^153, 153, (0, 1)), (s^16, 16, (7, 14))],
          ...
          <omitted>
	 
    """
    white_takes_black = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i1 in range(nwpcs):
        for i2 in range(nwpcs):
            for j in range(nbpcs):
                wpc1 = wpcs[i1][0]
                wpc2 = wpcs[i2][0]
                bpc = bpcs[j][0]
                degwpc1 = wpcs[i1][1]
                degwpc2 = wpcs[i2][1]
                degbpc = bpcs[j][1]
                wpc_pos1 = wpcs[i1][2]
                wpc_pos2 = wpcs[i2][2]
                bpc_pos = bpcs[j][2]
                #if (degwpc == degbpc):
                #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
                if (degwpc1-degwpc2 == degbpc) and parity_check(wpc1, wpc_pos1, bpc, bpc_pos) and parity_check(wpc2, wpc_pos2, bpc, bpc_pos):
                    #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                    #print(i, j, wpc, bpc)
                    white_takes_black = white_takes_black + [[(wpc1, degwpc1, wpc_pos1), (wpc2, degwpc2, wpc_pos2), (bpc, degbpc, bpc_pos)]]
    return white_takes_black


def black_takes_white_by_subtraction():
    """
    lists all such captures, listing the pieces, the values, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece)

    EXAMPLES:
        sage: btw = black_takes_white_by_addition()
        sage: len(btw)
         119
        sage: print(btw)
         [[(s^225, 225, (6, 15)), (t^56, 56, (4, 14)), (S^169, 169, (1, 0))],
          [(s^121, 121, (1, 15)), (s^120, 120, (6, 14)), (S, 1, (1, 1))],
          [(s^121, 121, (1, 15)), (s^49, 49, (0, 15)), (T^72, 72, (1, 2))],
          ...
          <omitted>
	 
    """
    black_takes_white = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i1 in range(nbpcs):
        for i2 in range(nbpcs):
            for j in range(nwpcs):
                bpc1 = bpcs[i1][0]
                bpc2 = bpcs[i2][0]
                wpc  = wpcs[j][0]
                degbpc1 = bpcs[i1][1]
                degbpc2 = bpcs[i2][1]
                degwpc  = wpcs[j][1]
                bpc_pos1 = bpcs[i1][2]
                bpc_pos2 = bpcs[i2][2]
                wpc_pos = wpcs[j][2]
                #if (degwpc == degbpc):
                #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
                if (degbpc1-degbpc2 == degwpc) and parity_check(bpc1, bpc_pos1, wpc, wpc_pos) and parity_check(bpc2, bpc_pos2, wpc, wpc_pos):
                    #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                    #print(i, j, wpc, bpc)
                    black_takes_white = black_takes_white + [[(bpc1, degbpc1, bpc_pos1), (bpc2, degbpc2, bpc_pos2), (wpc, degwpc, wpc_pos)]]
    return black_takes_white

def white_takes_black_by_multiplication():
    """
    lists all such captures, listing the piece, its value, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece), and the distance between them.

    EXAMPLES:
        sage: wtb = white_takes_black_by_multiplication()
        sage: len(wtb)
         96
        sage: print(wtb)
         [[(S^81, 81, (6, 0)), 1, (c^81, 81, (5, 13))],
          [(T^81, 81, (0, 2)), 1, (c^81, 81, (5, 13))],
          [(C^64, 64, (2, 2)), 1, (s^64, 64, (7, 14))],
           [(C^64, 64, (2, 2)), 1, (t^64, 64, (5, 14))],
           [(T^49, 49, (2, 1)), 1, (s^49, 49, (0, 15))],
           [(T^49, 49, (2, 1)), 1, (c^49, 49, (4, 13))],
           [(T^49, 49, (2, 1)), 1, (s^49, 49, (7, 14))],
           [(S^45, 45, (6, 1)), 5, (s^225, 225, (6, 15))],
           [(S^45, 45, (6, 1)), 2, (t^90, 90, (6, 13))],
           [(C^36, 36, (3, 2)), 1, (s^36, 36, (7, 14))],
          ...
          <omitted>
	 
    """
    white_takes_black = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i in range(nwpcs):
        for j in range(nbpcs):
            wpc = wpcs[i][0]
            bpc = bpcs[j][0]
            degwpc = wpcs[i][1]
            degbpc = bpcs[j][1]
            wpc_pos = wpcs[i][2]
            bpc_pos = bpcs[j][2]
            #if (degwpc == degbpc):
            #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
            if degwpc.divides(degbpc) and (degbpc/degwpc <15):
                #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                #print(i, j, wpc, bpc)
                if (degbpc/degwpc == 1):
                    if parity_check(bpc, bpc_pos, wpc, wpc_pos):
                        white_takes_black = white_takes_black + [[(wpc, degwpc, wpc_pos), degbpc/degwpc, (bpc, degbpc, bpc_pos)]]
                else:
                    white_takes_black = white_takes_black + [[(wpc, degwpc, wpc_pos), degbpc/degwpc, (bpc, degbpc, bpc_pos)]]
    return white_takes_black


def black_takes_white_by_multiplication():
    """
    lists all such captures, listing the piece, its value, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece), and the distance between them.

    EXAMPLES:
        sage: btw = black_takes_white_by_multiplication()
        sage: len(btw)
         61
        sage: print(btw)
         [[(c^81, 81, (5, 13)), 1, (S^81, 81, (6, 0))],
          [(c^81, 81, (5, 13)), 1, (T^81, 81, (0, 2))],
          [(s^64, 64, (7, 14)), 1, (C^64, 64, (2, 2))],
          ...
          <omitted>
	 
    """
    black_takes_white = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i in range(nbpcs):
        for j in range(nwpcs):
            wpc = wpcs[j][0]
            bpc = bpcs[i][0]
            degwpc = wpcs[j][1]
            degbpc = bpcs[i][1]
            wpc_pos = wpcs[j][2]
            bpc_pos = bpcs[i][2]
            #if (degwpc == degbpc):
            #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
            if degbpc.divides(degwpc) and (degwpc/degbpc <15):
                #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                #print(i, j, wpc, bpc)
                if (degwpc/degbpc == 1):
                    if parity_check(bpc, bpc_pos, wpc, wpc_pos):
                        black_takes_white = black_takes_white + [[(bpc, degbpc, bpc_pos), degwpc/degbpc, (wpc, degwpc, wpc_pos)]]
                else:
                    black_takes_white = black_takes_white + [[(bpc, degbpc, bpc_pos), degwpc/degbpc, (wpc, degwpc, wpc_pos)]]
    return black_takes_white


def white_takes_black_by_division():
    """
    lists all such captures, listing the piece, its value, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece), and the distance between them.

    EXAMPLES:
        sage: wtb = white_takes_black_by_division()
        sage: len(wtb)
         61
        sage: print(wtb)
         [[(P^91, 91, (1, 1)), 13, (c^7, 7, (4, 12))],
          [(S^81, 81, (6, 0)), 1, (c^81, 81, (5, 13))],
          [(S^81, 81, (6, 0)), 9, (c^9, 9, (2, 13))],
          [(S^81, 81, (6, 0)), 9, (c^9, 9, (5, 12))],
          ...
          <omitted>
	 
    """
    white_takes_black = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i in range(nwpcs):
        for j in range(nbpcs):
            wpc = wpcs[i][0]
            bpc = bpcs[j][0]
            degwpc = wpcs[i][1]
            degbpc = bpcs[j][1]
            wpc_pos = wpcs[i][2]
            bpc_pos = bpcs[j][2]
            #if (degwpc == degbpc):
            #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
            if degbpc.divides(degwpc) and (degwpc/degbpc <15):
                #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                #print(i, j, wpc, bpc)
                if (degbpc/degwpc == 1):
                    if parity_check(bpc, bpc_pos, wpc, wpc_pos):
                        white_takes_black = white_takes_black + [[(wpc, degwpc, wpc_pos), degwpc/degbpc, (bpc, degbpc, bpc_pos)]]
                else:
                    white_takes_black = white_takes_black + [[(wpc, degwpc, wpc_pos), degwpc/degbpc, (bpc, degbpc, bpc_pos)]]
    return white_takes_black
    
def black_takes_white_by_division():
    """
    lists all such captures, listing the piece, its value, and the inital position
    coordinates (to avoid ambiguities, in case of a duplicate piece), and the distance between them.

    EXAMPLES:
        sage: btw = black_takes_white_by_division()
        sage: len(btw)
         96
        sage: print(btw)
         [[(s^225, 225, (6, 15)), 5, (S^45, 45, (6, 1))],
          [(s^225, 225, (6, 15)), 9, (S^25, 25, (1, 1))],
          [(s^225, 225, (6, 15)), 9, (S^25, 25, (7, 0))],
          [(s^225, 225, (6, 15)), 9, (T^25, 25, (5, 1))],
          [(s^120, 120, (6, 14)), 6, (T^20, 20, (4, 1))],
          ...
          <omitted>
	 
    """
    black_takes_white = []
    wpcs = white_pieces()
    bpcs = black_pieces()
    nbpcs = len(bpcs)
    nwpcs = len(wpcs)
    for i in range(nbpcs):
        for j in range(nwpcs):
            wpc = wpcs[j][0]
            bpc = bpcs[i][0]
            degwpc = wpcs[j][1]
            degbpc = bpcs[i][1]
            wpc_pos = wpcs[j][2]
            bpc_pos = bpcs[i][2]
            #if (degwpc == degbpc):
            #    print(i, j, wpc, bpc, degwpc, degbpc, wpc_pos, bpc_pos)
            if degwpc.divides(degbpc) and (degbpc/degwpc <15):
                #if not([(wpc, degwpc), (bpc, degbpc)] in white_takes_black):
                #print(i, j, wpc, bpc)
                if (degbpc/degwpc == 1):
                    if parity_check(bpc, bpc_pos, wpc, wpc_pos):
                        black_takes_white = black_takes_white + [[(bpc, degbpc, bpc_pos), degbpc/degwpc, (wpc, degwpc, wpc_pos)]]
                else:
                    black_takes_white = black_takes_white + [[(bpc, degbpc, bpc_pos), degbpc/degwpc, (wpc, degwpc, wpc_pos)]]
    return black_takes_white



##############################################################################
############### wins/victory
##############################################################################
######################################## common victories
##############################################################################


def is_body_common_victory_black(game_state, N0 = 4, verbose=False):
    """
    returns True if Black has a common victory by body, meaning that 
    Black has captured at least N0 of White's pieces.

    Assumes the game state was built with pyramid_decomposition = True

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[1,2] = 0
        sage: GS[2,2] = 0
        sage: GS[3,2] = 0
        sage: is_body_common_victory_black(GS, N0 = 4)
        False
        sage: GS[4,2] = 0
        sage: is_body_common_victory_black(GS, N0 = 4)
        True

    """
    GS = copy(game_state)
    cpw = captured_pieces_white(GS, pyramid_decomposition=True)
    num_caps = len(cpw)
    if verbose:
        print("Black has captured ", num_caps, " pieces: ", cpw)
        return (num_caps >= N0)
    else:
        return (num_caps >= N0) #### Boolean
    
def is_body_common_victory_white(game_state, N0 = 4, verbose=False):
    """
    returns True if White has a common victory by body, meaning that 
    White has captured at least N0 of Black's pieces.

    Assumes the game state was built with pyramid_decomposition = True

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[1,13] = 0
        sage: GS[2,13] = 0
        sage: GS[3,13] = 0
        sage: is_body_common_victory_white(GS, N0 = 4)
        False
        sage: GS[4,13] = 0
        sage: is_body_common_victory_white(GS, N0 = 4)
        True

    """
    GS = copy(game_state)
    cpb = captured_pieces_black(GS, pyramid_decomposition=True)
    num_caps = len(cpb)
    if verbose:
        print("White has captured ", num_caps, " pieces: ", cpb)
        return (num_caps >= N0)
    else:
        return (num_caps >= N0) #### Boolean


def is_goods_common_victory_black(game_state, N1 = 100):
    """
    returns True if Black has a common victory by goods, meaning that 
    the total value of the pieces that Black has captured is at least N1.

    Assumes the game state was built with pyramid_decomposition = True

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5,3] = 0; GS[4,3] = 0; GS[2,3] = 0
        sage: is_goods_common_victory_black(GS, N1 = 100)
         False
        sage: is_goods_common_victory_black(GS, N1 = 10)
         True

    """
    GS = copy(game_state)
    cpw = captured_pieces_white(GS, pyramid_decomposition=True)
    #print(cpw)
    ttl = sum([x.degree() for x in cpw])
    return (ttl >= N1)

def is_goods_common_victory_white(game_state, N1 = 100):
    """
    returns True if White has a common victory by goods, meaning that 
    the total value of the pieces that White has captured is at least N1.

    Assumes the game state was built with pyramid_decomposition = True

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5,13] = 0; GS[4,13] = 0; GS[2,13] = 0  ## "capturing" c^81, c^49, and c^9
        sage: is_goods_common_victory_white(GS, N1 = 150)
         False
        sage: is_goods_common_victory_white(GS, N1 = 100)
         True

    """
    GS = copy(game_state)
    cpb = captured_pieces_black(GS, pyramid_decomposition=True)
    #print(cpb)
    ttl = sum([x.degree() for x in cpb])
    return (ttl >= N1)


##############################################################################
############### wins/victory
##############################################################################
####################################### proper victories
##############################################################################

def is_small_proper_victory_white(game_state):
    """
    returns True if White has achieved a "small proper victory" (ie, a magna win).
    That is, using the harmonic conditions, White has 3 pieces in Black's territory,
    all arranged in a line equidistant from each other (some sources
    allow them to be in a line or in a right triangle), where the values 
    of those three pieces are in harmony.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5,3] = 0; GS[7, 9] = C^2
        sage: GS[4,3] = 0; GS[4, 9] = C^4
        sage: GS[2,3] = 0; GS[1, 9] = C^8
        sage: is_geometrical_pattern_white(GS, verbose = True)
         White has 3 pieces in enemy territory with values (2, 4, 8) in linear geometric harmony. 
         Pieces: [((1, 9), [8]), ((4, 9), [4]), ((7, 9), [2])]
         True
        sage: is_small_proper_victory_white(GS)
         True

    """
    GS = copy(game_state)
    # arithmetical harmony
    arith_har = is_arithmetical_pattern_white(GS, verbose = False)
    # geometrical harmony
    geom_har = is_geometrical_pattern_white(GS, verbose = False)
    # musical harmony
    mus_har = is_musical_pattern_white(GS, verbose = False)
    ## check if white has 3 pieces in Black territory and
    ## if their values (as a set of 3 numbers) belong to one
    ## of these "harmonic "sequences. If both are true,
    ## return True, else return False
    return (arith_har or geom_har or mus_har)


def is_small_proper_victory_black(game_state):
    """
    returns True if Black has achieved a "small proper victory" (ie, a magna win).

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,12] = 0; GS[0, 7] = c^3; GS[3,12] = 0; GS[2, 7] = c^5; GS[4,12] = 0; GS[4, 7] = c^7
        sage: is_arithmetical_pattern_black(GS, verbose = False)
        True
        sage: is_small_proper_victory_black(GS)
        True

    
    """
    GS = copy(game_state)
    # arithmetical harmony
    arith_har = is_arithmetical_pattern_black(GS, verbose = False)
    # geometrical harmony
    geom_har = is_geometrical_pattern_black(GS, verbose = False)
    # musical harmony
    mus_har = is_musical_pattern_black(GS, verbose = False)
    ## check if Black has 3 pieces in White territory and
    ## if their values (as a set of 3 numbers) belong to one
    ## of these "harmonic "sequences. If both are true,
    ## return True, else return False
    return (arith_har or geom_har or mus_har)


################################### arithmetical patterns


def list_arithmetical_patterns_white0():
    """
    lists all possible arithmetical patterns for white pieces.

    EXAMPLES:
        sage: arithmetical_patterns = list_arithmetical_patterns_white()
        sage: len(arithmetical_patterns)
        11
        sage: print(arithmetical_patterns)
        [(2, 4, 6), (2, 9, 16), (4, 6, 8), (4, 20, 36), (8, 25, 42), (8, 36, 64),
         (9, 45, 81), (9, 81, 153), (15, 20, 25), (20, 42, 64), (49, 169, 289)]

    """
    arithmetical_patterns = []
    GS = copy(board_initial_matrix())
    poswv = [[xx[0], value_of_piece(GS, xx[0][0], xx[0][1])] for xx in positions_w(GS, verbose=True)]
    valsw = [xx[1][0] for xx in poswv if xx[1][0] in ZZ]
    for v0 in valsw:
        for v1 in valsw:
            for v2 in valsw:
                if (v0<v1) and (v1<v2) and not((v0, v1, v2) in arithmetical_patterns):
                    if v2-v1==v1-v0:      ################### testing the arithmetical condition #######
                        arithmetical_patterns = arithmetical_patterns + [(v0, v1, v2)]
    arithmetical_patterns.sort()
    return arithmetical_patterns

EVEN_ARITHMETICAL = list_arithmetical_patterns_white0()

def list_arithmetical_patterns_white():
    return EVEN_ARITHMETICAL



def list_arithmetical_patterns_black0():
    """
    lists all possible arithmetical patterns for black pieces.

    EXAMPLES:
        sage: arithmetical_patterns = list_arithmetical_patterns_black()
        sage: len(arithmetical_patterns)
        9
        sage: print(arithmetical_patterns)
        [(3, 5, 7), (5, 7, 9), (7, 16, 25), (7, 28, 49), (7, 64, 121), (12, 56, 100), 
         (12, 66, 120), (16, 36, 56), (28, 64, 100)]

    """
    arithmetical_patterns = []
    GS = copy(board_initial_matrix())
    posbv = [[xx[0], value_of_piece(GS, xx[0][0], xx[0][1])] for xx in positions_b(GS, verbose=True)]
    #print("0000",posbv)
    valsb = [xx[1][0] for xx in posbv if xx[1]!=[]]
    for v0 in valsb:
        for v1 in valsb:
            for v2 in valsb:
                if (v0<v1) and (v1<v2) and not((v0, v1, v2) in arithmetical_patterns):
                    if v2-v1==v1-v0:
                        arithmetical_patterns = arithmetical_patterns + [(v0, v1, v2)]
    arithmetical_patterns.sort()
    return arithmetical_patterns

ODD_ARITHMETICAL = list_arithmetical_patterns_black0()

def list_arithmetical_patterns_black():
    return ODD_ARITHMETICAL


################################### arithmetical patterns

    
def is_arithmetical_pattern_white(game_state, verbose = False):
    r"""
    returns True if White has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       arithmetical patterns listed,
    ## c) the in_a_line condition holds.    ############ ignoring this condition

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,3] = 0; GS[6, 8] = C^6; GS[4,3] = 0; GS[3, 8] = C^4; GS[5,3] = 0; GS[0, 8] = C^2
        sage: is_arithmetical_pattern_white(GS, verbose = True)
         White has 3 pieces in enemy territory with values  [(2, 4, 6)]  in arithmetic harmony. [[(0, 8), [2]], [(3, 8), [4]], [(6, 8), [6]]]
         True

    """
    GS = copy(game_state)
    pattern_list = list_arithmetical_patterns_white()
    
    # Get detailed data for all white pieces
    posw_data = positions_w(GS)
    
    # Filter for pieces in enemy territory (column index > 7)
    posw_in_b = []
    for piece_data in posw_data:
        pos, poly = piece_data[0], piece_data[1]
        if pos[1] > 7:
            # Correctly pass coordinates to value_of_piece
            value = value_of_piece(GS, pos[0], pos[1])
            posw_in_b.append([pos, value, poly])

    if len(posw_in_b) < 3:
        return False

    # Check all combinations of 3 pieces for a winning pattern
    for p1_data, p2_data, p3_data in itertools.combinations(posw_in_b, 3):
        # The value list might contain multiple values for pyramids
        for v1 in p1_data[1]:
            for v2 in p2_data[1]:
                for v3 in p3_data[1]:
                    current_values = tuple(sorted((v1, v2, v3)))
                    if current_values in pattern_list:
                        # Found a pattern. Now check if they are in a line.
                        pos1, pos2, pos3 = p1_data[0], p2_data[0], p3_data[0]
                        if is_in_a_line(pos1, pos2, pos3):
                            if verbose:
                                print(f"White has 3 pieces in enemy territory with values {current_values} in linear arithmetic harmony.")
                            return True
    return False


def is_arithmetical_pattern_black(game_state, in_a_line = False, verbose = False):
    r"""
    returns True if Black has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       arithmetical patterns listed
    ######### c) the in_a_line condition holds.   ########## not the de Boisseiere version of the rules -- ignore this condition


    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,12] = 0; GS[0, 7] = c^3; GS[3,12] = 0; GS[2, 7] = c^5; GS[4,12] = 0; GS[4, 7] = c^7
        sage: is_arithmetical_pattern_black(GS, verbose = True)
         Black has 3 pieces in enemy territory with values (3, 5, 7) in linear arithmetic harmony. Pieces: [((0, 7), [3]), ((2, 7), [5]), ((4, 7), [7])]
         True

    """
    GS = copy(game_state)
    pattern_list = list_arithmetical_patterns_black()
    
    # Get detailed data for all black pieces
    posb_data = positions_b(GS)
    
    # Filter for pieces in enemy territory (column index < 8)
    posb_in_w = []
    for piece_data in posb_data:
        pos, poly = piece_data[0], piece_data[1]
        if pos[1] < 8:
            value = value_of_piece(GS, pos[0], pos[1])
            posb_in_w.append([pos, value, poly])

    if len(posb_in_w) < 3:
        return False

    # Check all combinations of 3 pieces for a winning pattern
    for p1_data, p2_data, p3_data in itertools.combinations(posb_in_w, 3):
        # A single piece can have multiple values (pyramid). Check all value combinations.
        for v1 in p1_data[1]:
            for v2 in p2_data[1]:
                for v3 in p3_data[1]:
                    current_values = tuple(sorted((v1, v2, v3)))
                    if current_values in pattern_list:
                        # Found a pattern. Now check if they are in a line.
                        pos1, pos2, pos3 = p1_data[0], p2_data[0], p3_data[0]
                        if is_in_a_line(pos1, pos2, pos3):
                            if verbose:
                                print(f"Black has 3 pieces in enemy territory with values {current_values} in linear arithmetic harmony.")
                            return True
    return False

    

################################### geometrical patterns


def list_geometrical_patterns_white0():
    """
    lists all possible geometrical patterns for white pieces.

    EXAMPLES:
        sage: geometrical_patterns = list_geometrical_patterns_white()
        sage: len(geometrical_patterns)
        11
        sage: print(geometrical_patterns)
        [(2, 4, 8), (4, 6, 9), (4, 8, 16), (4, 16, 64), (9, 15, 25), (16, 20, 25), (16, 36, 81), (25, 45, 81),
         (36, 42, 49), (64, 72, 81), (81, 153, 289)]

    """
    geometrical_patterns = []
    GS = copy(board_initial_matrix())
    poswv = [[x[0], value_of_piece(GS, x[0][0], x[0][1])] for x in positions_w(GS, verbose=True)]
    valsw = [x[1][0] for x in poswv if x[1][0] in ZZ]
    #print("2222  ", poswv, "\n", valsw)
    for v0 in valsw:
        for v1 in valsw:
            for v2 in valsw:
                if (v0<v1) and (v1<v2):
                    if v2/v1==v1/v0 and not((v0, v1, v2) in geometrical_patterns):
                        geometrical_patterns = geometrical_patterns + [(v0, v1, v2)]
    geometrical_patterns.sort()
    return geometrical_patterns

EVEN_GEOMETRICAL = list_geometrical_patterns_white0()

def list_geometrical_patterns_white():
    return EVEN_GEOMETRICAL



def list_geometrical_patterns_black0():
    """
    lists all possible geometrical patterns for black pieces.

    EXAMPLES:
        sage: geometrical_patterns = list_geometrical_patterns_black()
        sage: len(geometrical_patterns)
        10
        sage: print(geometrical_patterns)
        [(9, 12, 16), (9, 30, 100), (16, 28, 49), (16, 36, 81), (25, 30, 36), (36, 66, 121), 
         (36, 90, 225), (49, 56, 64), (64, 120, 225), (81, 90, 100)]

    """
    geometrical_patterns = []
    GS = copy(board_initial_matrix())
    posbv = [[x[0], value_of_piece(GS, x[0][0], x[0][1])] for x in positions_b(GS, verbose=True)]
    valsb = [x[1][0] for x in posbv if x[1][0] in ZZ]
    for v0 in valsb:
        for v1 in valsb:
            for v2 in valsb:
                if (v0<v1) and (v1<v2):
                    if v2/v1 == v1/v0 and not((v0, v1, v2) in geometrical_patterns):
                        geometrical_patterns = geometrical_patterns + [(v0, v1, v2)]
    geometrical_patterns.sort()
    return geometrical_patterns
    
ODD_GEOMETRICAL = list_geometrical_patterns_black0()

def list_geometrical_patterns_black():
    return ODD_GEOMETRICAL


################################### geometrical patterns


def is_geometrical_pattern_white(game_state, verbose = False):
    """
    returns True if White has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       geometrical patterns listed
    #### c) the in_a_line condition holds.  ######## ignore this condition


    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5,3] = 0; GS[7, 9] = C^2; GS[4,3] = 0; GS[4, 9] = C^4; GS[2,3] = 0; GS[1, 9] = C^8
        sage: is_geometrical_pattern_white(GS, verbose = True)
        White has 3 pieces in enemy territory with values (2, 4, 8) in geometric harmony. Pieces: [((1, 9), [8]), ((4, 9), [4]), ((7, 9), [2])]
         True
        sage: is_geometrical_pattern_white(GS, verbose = False)
         True

    """
    GS = copy(game_state)
    pattern_list = list_geometrical_patterns_white()
    
    # Get detailed data for all white pieces
    posw_data = positions_w(GS)
    
    # Filter for pieces in enemy territory (column index > 7)
    posw_in_b = []
    for piece_data in posw_data:
        pos, poly = piece_data[0], piece_data[1]
        if pos[1] > 7:
            value = value_of_piece(GS, pos[0], pos[1])
            posw_in_b.append([pos, value, poly])

    if len(posw_in_b) < 3:
        return False

    # Check all combinations of 3 pieces for a winning pattern
    for p1_data, p2_data, p3_data in itertools.combinations(posw_in_b, 3):
        # A single piece can have multiple values (pyramid). Check all value combinations.
        for v1 in p1_data[1]:
            for v2 in p2_data[1]:
                for v3 in p3_data[1]:
                    current_values = tuple(sorted((v1, v2, v3)))
                    if current_values in pattern_list:
                        # Found a pattern. Now check if they are in a line.
                        pos1, pos2, pos3 = p1_data[0], p2_data[0], p3_data[0]
                        if is_in_a_line(pos1, pos2, pos3):
                            if verbose:
                                print(f"White has 3 pieces in enemy territory with values {current_values} in linear geometric harmony.")
                            return True
    return False


def is_geometrical_pattern_black(game_state, verbose = False):
    """
    returns True if Black has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       geometrical patterns listed
    #### c) the in_a_line condition holds.   ################# ignore this

    
    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[0, 13] = 0; GS[0, 7] = t^(16)   ### (9, 12, 16) is in a
        sage: GS[1, 13] = 0; GS[3, 7] = t^(12)   ### geometric progression 
        sage: GS[2, 13] = 0; GS[6, 7] = c^9      ### with ratio r = 4/3
        sage: is_geometrical_pattern_black(GS)
         True

    """
    GS = copy(game_state)
    pattern_list = list_geometrical_patterns_black()
    
    # Get detailed data for all black pieces
    posb_data = positions_b(GS)
    
    # Filter for pieces in enemy territory (column index < 8)
    posb_in_w = []
    for piece_data in posb_data:
        pos, poly = piece_data[0], piece_data[1]
        if pos[1] < 8:
            value = value_of_piece(GS, pos[0], pos[1])
            posb_in_w.append([pos, value, poly])

    if len(posb_in_w) < 3:
        return False

    # Check all combinations of 3 pieces for a winning pattern
    for p1_data, p2_data, p3_data in itertools.combinations(posb_in_w, 3):
        # A single piece can have multiple values (pyramid). Check all value combinations.
        for v1 in p1_data[1]:
            for v2 in p2_data[1]:
                for v3 in p3_data[1]:
                    current_values = tuple(sorted((v1, v2, v3)))
                    if current_values in pattern_list:
                        # Found a pattern. Now check if they are in a line.
                        pos1, pos2, pos3 = p1_data[0], p2_data[0], p3_data[0]
                        if is_in_a_line(pos1, pos2, pos3):
                            if verbose:
                                print(f"Black has 3 pieces in enemy territory with values {current_values} in linear geometric harmony.")
                            return True
    return False



################################### musical patterns


def list_musical_patterns_white0():
    """
    lists all possible harmonic/musical patterns for white pieces. Lists all
    ordered triples of values of the white pieces that form three consecutive
    terms in a harmonic progression.

    NOTE: White has relatively few (compared to the other patterns) musical patterns.
 
    EXAMPLES:
        sage: musical_patterns = list_musical_patterns_white()
        sage: len(musical_patterns)
        2
        sage: print(musical_patterns)
        [(9, 15, 45), (9, 16, 72)]

    """
    musical_patterns = []
    GS = copy(board_initial_matrix())
    poswv = [[x[0], value_of_piece(GS, x[0][0], x[0][1])] for x in positions_w(GS, verbose=True)]
    valsw = [x[1][0] for x in poswv if x[1][0] in ZZ]
    for v0 in valsw:
        for v1 in valsw:
            for v2 in valsw:
                if (v0<v1) and (v1<v2):
                    if 1/v0-1/v1 == 1/v1-1/v2 and not((v0, v1, v2) in musical_patterns):
                        musical_patterns = musical_patterns + [(v0, v1, v2)]
    musical_patterns.sort()
    return musical_patterns

EVEN_MUSICAL = list_musical_patterns_white0()

def list_musical_patterns_white():
    return EVEN_MUSICAL


################################### musical patterns

def list_musical_patterns_black0():
    """
    This function lists all possible harmonic/musical patterns for black pieces.
   
    NOTE: There aren't any musical patterns for Black!

    EXAMPLES:
        sage: musical_patterns = list_musical_patterns_black()
        sage: len(musical_patterns)
        0
        sage: print(musical_patterns)
        []

    """
    musical_patterns = []
    GS = copy(board_initial_matrix())
    posbv = [[x[0], value_of_piece(GS, x[0][0], x[0][1])] for x in positions_b(GS, verbose=True)]
    valsb = [x[1][0] for x in posbv if x[1][0] in ZZ]
    for v0 in valsb:
        for v1 in valsb:
            for v2 in valsb:
                if (v0<v1) and (v1<v2):
                    if (v1*v2 - v0*v2 == v0*v2 - v0*v1) and not((v0, v1, v2) in musical_patterns):
                        musical_patterns = musical_patterns + [(v0, v1, v2)]
    musical_patterns.sort()
    return musical_patterns

ODD_MUSICAL = list_musical_patterns_black0()

def list_musical_patterns_black():
    return ODD_MUSICAL

################################### end patterns


def is_musical_pattern_black(game_state, verbose = False):
    """
    returns True if Black has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       musical patterns listed
    c) the in_a_line condition holds.

    NOTE: * Black has no triple of musical patterns:
          * there aren't any musical patterns for Black!

    EXAMPLES
        sage: list_musical_patterns_black()
         []

    """
    return False

def is_harmonic_pattern_black(game_state, verbose = False):
    return is_musical_pattern_black(game_state, verbose)
    
def is_musical_pattern_white(game_state, verbose = False):
    """
    returns True if White has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       musical patterns listed
    ###### c) the in_a_line condition holds. #################### ignore this condition

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5, 11] = T^9
        sage: GS[7, 8] = C^(16)
        sage: GS[3, 14] = T^(72)
        sage: is_musical_pattern_white(GS, verbose = True)
         White has 3 pieces in enemy territory with values  [(9, 16, 72)]  in musical harmony. [[(3, 14), [72]], [(5, 11), [9]], [(7, 8), [16]]]
         True

    """
    GS = copy(game_state)
    pattern_list = list_musical_patterns_white()
    
    # Get detailed data for all white pieces
    posw_data = positions_w(GS)
    
    # Filter for pieces in enemy territory (column index > 7)
    posw_in_b = []
    for piece_data in posw_data:
        pos, poly = piece_data[0], piece_data[1]
        if pos[1] > 7:
            value = value_of_piece(GS, pos[0], pos[1])
            posw_in_b.append([pos, value, poly])

    if len(posw_in_b) < 3:
        return False

    # Check all combinations of 3 pieces for a winning pattern
    for p1_data, p2_data, p3_data in itertools.combinations(posw_in_b, 3):
        # A single piece can have multiple values (pyramid). Check all value combinations.
        for v1 in p1_data[1]:
            for v2 in p2_data[1]:
                for v3 in p3_data[1]:
                    current_values = tuple(sorted((v1, v2, v3)))
                    if current_values in pattern_list:
                        # Found a pattern. Now check if they are in a line.
                        pos1, pos2, pos3 = p1_data[0], p2_data[0], p3_data[0]
                        if is_in_a_line(pos1, pos2, pos3):
                            if verbose:
                                print(f"White has 3 pieces in enemy territory with values {current_values} in linear musical harmony.")
                            return True
    return False


def is_harmonic_pattern_white(game_state, verbose = False):
    return is_musical_pattern_white(game_state, verbose)
    
########################################################################
################### utilities


def in_bounds(x):
    """
    INPUT: x is a pair of integers, for instance x = (2,3) or x = [3,1]
           will both work.
    
    returns True if x is a pt on the board

    EXAMPLES:
        sage: x = (7, 0)
        sage: in_bounds(x)
        True
        sage: x = (8, 0)
        sage: in_bounds(x)
        False
        sage: x = (0, 15)
        sage: in_bounds(x)
        True
        sage: x = (0, 16)
        sage: in_bounds(x)
        False

    """
    return (not(x[0]<0) and not(x[0]>7) and not(x[1]<0) and not(x[1]>15)) ## a Boolean value


def select_from_a_list_random(L, n):
    """ 
    select n random elements from L, where n < len(L), at random, without replacement

    EXAMPLES:
  
    """
    N = len(L)
    L0 = []
    for i in range(10*n):
        j = random.randint(0, N-1)
        pos = L[j]
        if not(pos in L0):
            L0 = L0 + [pos]
        if len(L0)==n:
            return L0
    return False


def common_elements(list1, list2):
    """
    Returns a list containing the common elements between two lists.

    Also remember to find the indices in a list L that are equal to x0, you can use
    the Pythonic 1-liner:

    indices = [i for i, x in enumerate(L) if x == x0]
    
    """
    set1 = Set(list1)
    set2 = Set(list2)
    common_set = set1.intersection(set2)
    return list(common_set)


def is_in_a_line(pc0, pc1, pc2):
    """
    returns True if the three piece coordinate/positions are 
    equi-distant and on a line, that is if their differences
    have the same slope

    ####################### this function is not needed in the de Boissiere version

    EXAMPLES:
        sage: pc1 = (1,2); pc2 = (2,3); pc3 = (0,1)
        sage: is_in_a_line(pc1, pc2, pc3)
        True
        sage: pc1 = (1,2); pc2 = (2,3); pc3 = (1,1)
        sage: is_in_a_line(pc1, pc2, pc3)
        False

    """
    pts = [pc0, pc1, pc2]
    pts.sort() ## these pts should be in lexicographic order
    #print(pts)
    x0 = pts[0][0]; y0 = pts[0][1]
    x1 = pts[1][0]; y1 = pts[1][1]
    x2 = pts[2][0]; y2 = pts[2][1] 
    if x0==x1:
        if x1==x2 and (y1-y0 == y2-y1):
            return True
        else:
            return False
    elif x1==x2:
        if x0==x1 and (y1-y0 == y2-y1):
            return True
        else:
            return False
    else:
        #print(pts, (y1-y0)/(x1-x0),  (y2-y1)/(x2-x1))
        if (y1-y0)/(x1-x0) == (y2-y1)/(x2-x1) and (x1-x0 == x2-x1) and (y1-y0 == y2-y1): ## equal slope, equal y-distance
            return True
        else:
            return False
    return False


def game_state_to_latex_board(GS):
    """
    returns strings for the latex formatted Rithmomachia board
    diagram. Very crude. Needs to be slicker.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[5,10] = T^9; GS[7,2] = 0
        sage: game_state_to_latex_board(GS)
         '\\[ \x08egin{array}{|c|c|c|c|c|c|c|c|} \\hline s^49 & s^121 & 0 & 0 & 0 & 0 & s^225 & s^361 \\ \\hline 
          s^28 & s^66 & t^36 & t^30 & t^56 & t^64 & s^120 & p^190 + s^64 + s^49 + s^36 + s^25 + s^16 \\ \\hline 
          t^16 & t^12 & c^9 & c^25 & c^49 & c^81 & t^90 & t^100 \\ \\hline 0 & 0 & c^3 & c^5 & c^7 & c^9 & 0 & 0 \\ \\hline 
          0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 0 & 0 & 0 & 0 & 0 & T^9 & 0 & 0 \\ \\hline 
          0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 
          0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 
          0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \\hline 
          0 & 0 & C^8 & C^6 & C^4 & C^2 & 0 & 0 \\ \\hline T^81 & T^72 & C^64 & C^36 & C^16 & C^4 & T^6 & 0 \\ \\hline 
          S^153 & P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S & T^49 & T^42 & T^20 & T^25 & S^45 & S^15 \\ \\hline 
          S^289 & S^169 & 0 & 0 & 0 & 0 & S^81 & S^25 \\ \\hline \\end{array} \\]'

    """
    s = "\\[ \begin{array}{|c|c|c|c|c|c|c|c|} \\hline "
    for k in range(16):
        j = 15-k
        s = s+ str(GS[0,j]) + " & " +  str(GS[1,j]) + " & " +  str(GS[2,j]) + " & " +  str(GS[3,j]) + " & " +  str(GS[4,j]) + " & " +  str(GS[5,j]) + " & " +  str(GS[6,j]) + " & " +  str(GS[7,j]) + " \\ \\hline "
    s = s + "\\end{array} \\]"
    return s

def piece_values_list_black():
    """
    returns the list of values, in case it's ever needed.

    EXAMPLE:
        sage: A = piece_values_list_black()
        sage: sum(A)
         1752

    """
    A = [3, 9, 12, 16, 28, 49] + [5, 25, 30, 36, 66, 121] + [7, 49, 56, 64, 120, 225] + [9, 81, 90, 100, 190, 361]
    A.sort()
    return A
    
def piece_values_list_white():
    """
    returns the list of values, in case it's ever needed.

    EXAMPLE:
        sage: A = piece_values_list_white()
        sage: sum(A)
         1312

    """
    A = [2, 4, 6, 8] + [4, 16, 36, 64] + [6, 20, 42, 72] + [9, 25, 49, 81] + [15, 45, 91, 153] + [25, 81, 169, 289]
    A.sort()
    return A
    
def piece_values_matrix_black():
    """
    returns the matrix of values, in case it's ever needed.

    EXAMPLE:
        sage: A = piece_values_matrix_black()
        sage: sum(A.row(0))+sum(A.row(1))+sum(A.row(2))+sum(A.row(3))+sum(A.row(4))+sum(A.row(5))
         1752

    """
    MS46 = MatrixSpace(ZZ, 4, 6)
    A = [[3, 9, 12, 16, 28, 49],
    [5, 25, 30, 36, 66, 121],
    [7, 49, 56, 64, 120, 225],
    [9, 81, 90, 100, 190, 361]]
    M = matrix(A).transpose()
    return M


def piece_values_matrix_white():
    """
    returns the matrix of values, in case it's ever needed.

    EXAMPLE:
        sage: A = piece_values_matrix_white()
        sage: sum(A.row(0))+sum(A.row(1))+sum(A.row(2))+sum(A.row(3))+sum(A.row(4))+sum(A.row(5))
         1312

    """
    MS46 = MatrixSpace(ZZ, 4, 6)
    A = [[2, 4, 6, 8],
     [4, 16, 36, 64],
     [6, 20, 42, 72],
     [9, 25, 49, 81],
     [15, 45, 91, 153],
     [25, 81, 169, 289]]
    M = matrix(A)
    return M


def white_pieces(algebraic = False):
    """
    returns a list of three
      1) all the White pieces, as monomials, including all subpieces of the pyramid. The pyramid with its
    initial value is listed as well,
      2) all the values of these pieces,
      3) all the initial positions of these pieces.
    It is sorted by value.

    The option algebraic = True returns a list of strings, using algebraic notation.

 
    
    EXAMPLES:
        sage: wpcs = white_pieces()
        sage: len(wpcs)
         30
        sage: print(wpcs)
         [(S^289, 289, (0, 0)), (S^169, 169, (1, 0)), (S^153, 153, (0, 1)),
	  (P^91, 91, (1, 1)), (S^81, 81, (6, 0)), (T^81, 81, (0, 2)), (T^72, 72, (1, 2)),
	  (C^64, 64, (2, 2)), (T^49, 49, (2, 1)), (S^45, 45, (6, 1)), (T^42, 42, (3, 1)),
	  (C^36, 36, (3, 2)), (S^36, 36, (1, 1)), (S^25, 25, (1, 1)), (S^25, 25, (7, 0)),
	  (T^25, 25, (5, 1)), (T^20, 20, (4, 1)), (C^16, 16, (4, 2)), (S^16, 16, (1, 1)),
	  (S^15, 15, (7, 1)), (T^9, 9, (7, 2)), (S^9, 9, (1, 1)), (C^8, 8, (2, 3)),
	  (T^6, 6, (6, 2)), (C^6, 6, (3, 3)), (C^4, 4, (4, 3)), (C^4, 4, (5, 2)),
	  (S^4, 4, (1, 1)), (C^2, 2, (5, 3)), (S, 1, (1, 1))]
         

    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    white_pcs = [(S^289, 289, (0, 0)), (S^169, 169, (1, 0)), (S^153, 153, (0, 1)),\
     (P^91, 91, (1, 1)), (S^81, 81, (6, 0)), (T^81, 81, (0, 2)), (T^72, 72, (1, 2)),\
     (C^64, 64, (2, 2)), (T^49, 49, (2, 1)), (S^45, 45, (6, 1)), (T^42, 42, (3, 1)),\
     (C^36, 36, (3, 2)), (S^36, 36, (1, 1)), (S^25, 25, (1, 1)), (S^25, 25, (7, 0)),\
     (T^25, 25, (5, 1)), (T^20, 20, (4, 1)), (C^16, 16, (4, 2)), (S^16, 16, (1, 1)),\
     (S^15, 15, (7, 1)), (T^9, 9, (7, 2)), (S^9, 9, (1, 1)), (C^8, 8, (2, 3)),\
     (T^6, 6, (6, 2)), (C^6, 6, (3, 3)), (C^4, 4, (4, 3)), (C^4, 4, (5, 2)), (S^4, 4, (1, 1)),
     (C^2, 2, (5, 3)), (S^1, 1, (1, 1))]
    if algebraic:
        white_pcs = [ "S289a1", "S169a2", "S153b1", "P091b2", "S081a7", "T081c1", "T072c2",
                      "C064c3", "T049b3", "S045b7", "T042b4", "C036c4", "S036b2", "S025b2",
                      "S025a8", "T025b6", "T020b5", "C016c5", "S016b2", "S015b8", "T009c8",
                      "S009b2", "C008d3", "T006c7", "C006d4", "C004c6", "C004d5", "S004b2", 
                      "C002d6", "S001b2"]
    return white_pcs


def black_pieces(algebraic = False):
    """
    returns three lists
      1) all the Black pieces, as monomials, including all subpieces of the pyramid. The pyramid with its
    initial value is listed as well,
      2) all the values of these pieces,
      3) all the initial positions of these pieces.
    These lists have the same length.
    
    
    EXAMPLES:
        sage: print(black_pieces())
         [(s^361, 361, (7, 15)), (s^225, 225, (6, 15)), (p^190, 190, (7, 14)), (s^121, 121, (1, 15)), 
          (s^120, 120, (6, 14)), (t^100, 100, (7, 13)), (t^90, 90, (6, 13)), (c^81, 81, (5, 13)), 
          (s^66, 66, (1, 14)), (s^64, 64, (7, 14)), (t^64, 64, (5, 14)), (t^56, 56, (4, 14)), 
          (s^49, 49, (0, 15)), (c^49, 49, (4, 13)), (s^49, 49, (7, 14)), (s^36, 36, (7, 14)), 
          (t^36, 36, (2, 14)), (t^30, 30, (3, 14)), (s^28, 28, (0, 14)), (s^25, 25, (7, 14)), 
          (c^25, 25, (3, 13)), (s^16, 16, (7, 14)), (t^16, 16, (0, 13)), (t^12, 12, (1, 13)), 
          (c^9, 9, (2, 13)), (c^9, 9, (5, 12)), (c^7, 7, (4, 12)), (c^5, 5, (3, 12)), (c^3, 3, (2, 12))]
         sage: bpcs = black_pieces(algebraic = True)
         sage: print(bpcs)
          ['s361p8', 's225p7', 'p190o8', 's121p2', 's120o7', 't100n8', 't090n7', 'c081n6', 's066o2', 's064o8', 
           't064o6', 't056o5', 's049p1', 's049o8', 'c049n5', 's036o8', 't036o3', 't030o4', 's028o1', 's025o8', 'c025n4', 
           's016o8', 't016n1', 't012n2', 'c009n3', 'c009m6', 'c007m5', 'c005m4', 'c003m3']

    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    black_pcs = [(s^361, 361, (7, 15)), (s^225, 225, (6, 15)), (p^190, 190, (7, 14)), (s^121, 121, (1, 15)),\
    (s^120, 120, (6, 14)), (t^100, 100, (7, 13)), (t^90, 90, (6, 13)), (c^81, 81, (5, 13)),\
    (s^66, 66, (1, 14)), (s^64, 64, (7, 14)), (t^64, 64, (5, 14)), (t^56, 56, (4, 14)),\
    (s^49, 49, (0, 15)), (c^49, 49, (4, 13)), (s^49, 49, (7, 14)), (s^36, 36, (7, 14)),\
    (t^36, 36, (2, 14)), (t^30, 30, (3, 14)), (s^28, 28, (0, 14)), (s^25, 25, (7, 14)),\
    (c^25, 25, (3, 13)), (s^16, 16, (7, 14)), (t^16, 16, (0, 13)), (t^12, 12, (1, 13)),\
    (c^9, 9, (2, 13)), (c^9, 9, (5, 12)), (c^7, 7, (4, 12)), (c^5, 5, (3, 12)), (c^3, 3, (2, 12))]
    if algebraic:
        black_pcs = [ "s361p8", "s225p7", "p190o8", "s121p2", "s120o7", "t100n8", "t090n7", "c081n6",
                      "s066o2", "s064o8", "t064o6", "t056o5", "s049p1", "s049o8", "c049n5", "s036o8",
		      "t036o3", "t030o4", "s028o1", "s025o8", "c025n4", "s016o8", "t016n1", "t012n2",
		      "c009n3", "c009m6", "c007m5", "c005m4", "c003m3"]
    return black_pcs


def parity_check(wpc, wpc_pos, bpc, bpc_pos):
    """
    compares two pieces, one of each color, and returns the triple
     <bool>, wpc_parity, bpc_parity,
    where <bool> is True if one can in theory capture the other by numbering
    (after a sequence of legal moves). For example, neighboring squares can't
    ever capture each other by numbering since they will never be able to attack
    each other.


    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: wpc = S^(25); wpc_pos = (7, 0); GSp[7,0]
         S^25
        sage: bpc = s^(25); bpc_pos = (7, 14); GSp[7,14]
         p^190 + s^64 + s^49 + s^36 + s^25 + s^16
        sage: parity_check(wpc, wpc_pos, bpc, bpc_pos)
	 (False, (1, 0), (1, 2))
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: wpc = T^(25); wpc_pos = (5, 1); GSp[5,1]
         T^25
        sage: bpc = s^(25); bpc_pos = (7, 14); GSp[7,14]
         p^190 + s^64 + s^49 + s^36 + s^25 + s^16
        sage: parity_check(wpc, wpc_pos, bpc, bpc_pos)
         (True, (0, 1), (1, 2))

    In the last example, the White T^25 can't capture the Black square s^25
    (a sub-piece of the Black pyramid) but the s^25 can (in theory) capture
    the T^25.
    
    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    iw = wpc_pos[0]
    jw = wpc_pos[1]
    ib = bpc_pos[0]
    jb = bpc_pos[1]
    if (S in wpc.variables()) or (P in wpc.variables()):
        wpc_parity = (iw%3, jw%3)
    elif (T in wpc.variables()):
        wpc_parity = (iw%2, jw%2)
    else:
        wpc_parity = (0, 0)
    if (s in bpc.variables()) or (p in wpc.variables()):
        bpc_parity = (ib%3, jb%3)
    elif (t in bpc.variables()):
        bpc_parity = (ib%2, jb%2)
    else:
        bpc_parity = (0, 0)
    if (c in bpc.variables()) or (C in wpc.variables()):
        return True, wpc_parity, bpc_parity
    if (t in bpc.variables()) and (S in wpc.variables()):
        return True, wpc_parity, bpc_parity
    if (s in bpc.variables()) and (T in wpc.variables()):
        return True, wpc_parity, bpc_parity
    #if verbose:
    #print("White's piece parity: ", wpc_parity," Black's piece parity: ", bpc_parity)
    return (wpc_parity == bpc_parity), wpc_parity, bpc_parity
    
def piece_list_to_game_state(pc_list, verbose = False):
    """
    Converts a list of strings of piece positions (in algebraic notation) into a
    game state matrix.

    Notation: <shape><3-digit value><position>, for example "T049b3" for the white
    triangle of value 49 at b3.

    EXAMPLES:
        sage: pc_list = ["T049b3", "C002d6", "P091b2", "p190c6"]
        sage: piece_list_to_game_state(pc_list, verbose = True)
        0  black squares,  0  white squares,
        0  black triangles,  1  white triangles,
        0  black circles,  1  white circles
        1  black pyramids,  1  white pyramids
        [    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0  P^91     0     0     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0  T^49     0     0     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0     0 p^190   C^2     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0]
        [    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0]


    """
    import string
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    GSp = board_initial_matrix(pyramid_decomposition = True)
    GS = copy(GSp)*0
    lowercase_alphabet = string.ascii_lowercase
    L = copy(pc_list)
    #x0 = L[0]
    #print(x0, x0[1]+x0[2]+x0[3], int(x0[1]+x0[2]+x0[3]), x0[4], x0[4] in lowercase_alphabet)
    PL = [(xx[0], int(xx[1] + xx[2] + xx[3]), lowercase_alphabet.index(xx[4]), int(xx[5])) for xx in L if len(xx)==6]
    black_squares =   [xx for xx in PL if xx[0]=="s"]
    white_squares =   [xx for xx in PL if xx[0]=="S"]
    black_triangles = [xx for xx in PL if xx[0]=="t"]
    white_triangles = [xx for xx in PL if xx[0]=="T"]
    black_circles =   [xx for xx in PL if xx[0]=="c"]
    white_circles =   [xx for xx in PL if xx[0]=="C"]
    black_pyramids =  [xx for xx in PL if xx[0]=="p"]
    white_pyramids =  [xx for xx in PL if xx[0]=="P"]
    for xx in PL:
        ii = xx[3]-1
        jj = xx[2]
        val_pc = xx[1]
        #print(x, i, j)
        GS[ii, jj] = PR(xx[0])^val_pc
    if verbose:
        print(len(black_squares), " black squares, ", len(white_squares), " white squares,") 
        print(len(black_triangles), " black triangles, ", len(white_triangles), " white triangles,") 
        print(len(black_circles), " black circles, ", len(white_circles), " white circles") 
        print(len(black_pyramids), " black pyramids, ", len(white_pyramids), " white pyramids") 
    return GS #, black_squares, white_squares, black_triangles, white_triangles, black_circles, white_circles, black_pyramids, white_pyramids


def game_state_to_piece_list(game_state):
    """
    Converts a game state matrix.into a list of strings of piece positions (in algebraic notation).

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: len(game_state_to_piece_list(GSp))
         48
        sage: print(game_state_to_piece_list(GSp))
         ['S289a1', 'S169a2', 'S81a7', 'S25a8', 'S153b1', 'P91b2', 'T49b3', 'T42b4', 'T20b5', 'T25b6', 'S45b7', 'S15b8', 
          'T81c1', 'T72c2', 'C64c3', 'C36c4', 'C16c5', 'C4c6', 'T6c7', 'T9c8', 'C8d3', 'C6d4', 'C4d5', 'C2d6', 
          'c3m3', 'c5m4', 'c7m5', 'c9m6', 't16n1', 't12n2', 'c9n3', 'c25n4', 'c49n5', 'c81n6', 't90n7', 't100n8', 's28o1', 
          's66o2', 't36o3', 't30o4', 't56o5', 't64o6', 's120o7', 'p190o8', 's49p1', 's121p2', 's225p7', 's361p8']

    """
    gs = copy(game_state)
    pc_list = []
    for jj in range(16):
        for ii in range(8):
            pc_str = shape_value(gs, ii, jj, fancy = False)
            pc_coord = coordinate_to_algebraic(ii, jj)
            if not(pc_str[0] == "0"):
                pc_list = pc_list + [pc_str + pc_coord]
    return pc_list

def shape_value(game_state, i, j, fancy = False):
    r"""
    returns shape, value of game_state[i,j]

    The fancy = True option returns the symbolic version from oplotsymbl
    (with \squad for S, etc)
    
    This is to help parse expressions in piece_list_to_latex

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: shape_value(GSp, 1, 1)
         'P091'
        sage: shape_value(GSp, 5, 3)
         'C002'
	sage: shape_value(GSp, 7, 15)
         's361'


    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    pc_str = str(GS[i,j])
    if fancy:
        if pc_str[0] == "0":
            return "\\quad "
        if pc_str[0] == "S":
            return "\\squad\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "s":
            return "\\squadfill\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "T":
            return "\\trianglepa\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "t":
            return "\\trianglepafill\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "C":
            return "\\circlet\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "c":
            return "\\circletfill\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "P":
            return "\\rhombus\\," + str(sum(value_of_piece(GS, i, j)))
        if pc_str[0] == "p":
            return "\\rhombusfill\\," + str(sum(value_of_piece(GS, i, j)))
    if pc_str[0] == "0":
        return "0"
    else:
        pc_value = str(sum(value_of_piece(GS, i, j)))
        if len(pc_value) == 1:
            pc_value = "00" + pc_value
        if len(pc_value) == 2:
            pc_value = "0" + pc_value
        return pc_str[0] + pc_value 

    
def piece_list_to_latex(pc_list, verbose = False):
    """
    Converts a list of strings of piece positions (in algebraic notation) into a
    latex table (vertical mode).

    Notation: <shape><3-digit value><position>, for example "T049b3" for the white
    triangle of value 49 at b3.

    A lot of straightforward latex editing is required before the output will comile.

    EXAMPLES:
        sage: pc_list = ["T049b3", "C002d6", "P091b2", "p190c6"]
        sage: piece_list_to_latex(pc_list, verbose = True)
         0  black squares,  0  white squares,
         0  black triangles,  1  white triangles,
         0  black circles,  1  white circles
         1  black pyramids,  1  white pyramids
         '\\begin{tabular}{|c|c|c|c|c|c|c|c||c} \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $p$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $o$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $n$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $m$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $l$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $k$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $j$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $i$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $h$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $g$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $f$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $e$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\circlet\\,2 & \\quad  & \\quad  & $d$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\rhombusfill\\,p^190 & \\quad  & \\quad  & $c$ \\ \\hline 
         \\quad  & \\rhombus\\,P^91 & \\trianglepa\\,49 & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $b$ \\ \\hline 
         \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & \\quad  & $a$ \\ \\hline  
         1 &  2 &  3 &  4 &  5 &  6 &  7 &  8  &  \\ \\end{tabular} '

    """
    import string
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    GSp = board_initial_matrix(pyramid_decomposition = True)
    GS = copy(GSp)*0
    lowercase_alphabet = string.ascii_lowercase
    L = copy(pc_list)
    GS = piece_list_to_game_state(pc_list, verbose)
    s = "\\begin{tabular}{|c|c|c|c|c|c|c|c||c} \\hline "
    for k in range(16):
        j = 15-k
        sh_val = [shape_value(GS, i, j, fancy = True) for i in range(8)]
        s = s+ sh_val[0] + " & " +  sh_val[1] + " & " +  sh_val[2] + " & " +  sh_val[3] + " & " +  sh_val[4] + " & " +  sh_val[5] + " & " +  sh_val[6] + " & " +  sh_val[7] + " & " + "$" + lowercase_alphabet[j] + "$" + " \\ \\hline " 
    bottom_line = " 1 &  2 &  3 &  4 &  5 &  6 &  7 &  8  &  \\ " 
    s = s + bottom_line + "\\end{tabular} "
    return s


def coordinate_to_algebraic(x, y):
    """
    converts (x,y) to algebraic "<letter><number>"

    EXAMPLES:
        sage: coordinate_to_algebraic(0, 0)
        'a1'
        sage: coordinate_to_algebraic(7, 0)
        'a8'
        sage: coordinate_to_algebraic(7, 15)
        'p8'
        sage: coordinate_to_algebraic(0, 15)
        'p1'

    """
    s = ""
    import string
    lowercase_alphabet = string.ascii_lowercase
    s = s + lowercase_alphabet[y]
    s = s + str(x + 1)
    return s


def algebraic_to_coordinate(alg_coord):
    """
    converts algebraic "<letter><number>" to coordinate (x, y)

    EXAMPLES:
        sage: alg_coord = "a1"
        sage: algebraic_to_coordinate(alg_coord)
         (0, 0)
        sage: alg_coord = "b3"
        sage: algebraic_to_coordinate(alg_coord)
         (2, 1)


    """
    import string
    lowercase_alphabet = string.ascii_lowercase
    ii = lowercase_alphabet.index(alg_coord[0])
    jj = int(alg_coord[1])-1
    return (jj, ii)

def get_algebraic_move_string(game_state, start_pos, end_pos):
    """
    returns a move in algebraic notation such as "C002d6e6" 

    written by gemini. very similar to coordinate_to_algebraic

    EXAMPLES:

    """
    gs_entry = game_state[start_pos[0], start_pos[1]]
    if gs_entry == 0:
        return "ERROR_NO_PIECE"
    piece_char = str(gs_entry)[0] # 'C', 'S', 't', etc.
    piece_val_list = value_of_piece(game_state, start_pos[0], start_pos[1])
    if not piece_val_list or piece_val_list == [0]: # Shouldn't happen if gs_entry <> 0
        display_val = 0
    else:
       display_val = sum(v for v in piece_val_list if isinstance(v, (int, Integer)))
    formatted_val = "{:03d}".format(display_val)
    alg_start = coordinate_to_algebraic(start_pos[0], start_pos[1])
    alg_end = coordinate_to_algebraic(end_pos[0], end_pos[1])
    return f"{piece_char}{formatted_val}{alg_start}{alg_end}"


def pieces_in_a_line(game_state, pc1, pc2, diagonal_lines=False):
    r"""
    returns the number of blank spaces they are separated by if
    they are in a line and have only blank spaces (in the current game_state) 
    between them, and returns -1 otherwise.

    Returns -1 if diagonal_lines = False, and the distance if it is True.

    pc1, pc2 are pairs of coordinates in the range [0,7]x[0,15]

    EXAMPLES:

    """
    GS = copy(game_state)
    x1, y1 = pc1
    x2, y2 = pc2

    if (x1 == x2) and (y1 != y2): # Horizontal path
        d = y2 - y1
        if abs(d) <= 1: return 0
        for i in range(1, abs(d)):
            y = y1 + (i * (1 if d > 0 else -1))
            if sum(value_of_piece(GS, x1, y)) > 0:
                return -1
        return abs(d) - 1

    if (y1 == y2) and (x1 != x2): # Vertical path
        d = x2 - x1
        if abs(d) <= 1: return 0
        for i in range(1, abs(d)):
            x = x1 + (i * (1 if d > 0 else -1))
            if sum(value_of_piece(GS, x, y1)) > 0:
                return -1
        return abs(d) - 1

    if diagonal_lines:
        dx = x2 - x1
        dy = y2 - y1
        if abs(dx) == abs(dy) and abs(dx) > 1:
            step_x = 1 if dx > 0 else -1
            step_y = 1 if dy > 0 else -1
            for i in range(1, abs(dx)):
                x = x1 + i * step_x
                y = y1 + i * step_y
                if sum(value_of_piece(GS, x, y)) > 0:
                    return -1
            return abs(dx) - 1

    return -1


def draw_big_square(piece_value = "361", piece_color = "black", verbose = False):
    """
    Written by gemini


    EXAMPLES:
        sage: draw_big_square(piece_value = "361", piece_color = "black").show()
        sage: draw_big_square(piece_value = "169", piece_color = "white").show()

    """
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    # Create a figure and an axes
    # figsize determines the size of the figure in inches
    fig, ax = plt.subplots(1, figsize=(6, 6))
    # Define the properties of the square
    # square_size is relative to the axes limits (0 to 1 in this case)
    square_size = 0.4
    # Calculate coordinates to center the square
    square_x = (1 - square_size) / 2
    square_y = (1 - square_size) / 2
    # Create a  square patch
    # - (square_x, square_y): bottom-left corner of the rectangle
    # - square_size, square_size: width and height of the rectangle
    # - linewidth: thickness of the edge
    # - edgecolor: color of the edge (set to 'white' for visibility against a potentially dark background)
    # - facecolor: fill color of the square (piece_color)
    if piece_color == "black":
        square_big = patches.Rectangle((square_x, square_y), square_size, square_size, linewidth=2, edgecolor = "white",  facecolor = "black")
    if piece_color == "white":
        square_big = patches.Rectangle((square_x, square_y), square_size, square_size, linewidth=2, edgecolor = "black",  facecolor = "white")
    # Add the created square patch to the axes
    ax.add_patch(square_big)
    # Add the number <piece_value> inside the square
    # Calculate text position to be the center of the square
    text_x = square_x + square_size / 2
    text_y = square_y + square_size / 2
    if piece_color == "black":
        ax.text(text_x, text_y, piece_value,
        fontsize=50,      # Set the font size of the text
        color='white',    # Set the text color to white
        ha='center',      # Horizontal alignment: center
        va='center'       # Vertical alignment: center
        )
    if piece_color == "white":
        ax.text(text_x, text_y, piece_value,
        fontsize=50,      # Set the font size of the text
        color='black',    # Set the text color to white
        ha='center',      # Horizontal alignment: center
        va='center'       # Vertical alignment: center
        )
    # --- Aesthetics and Layout ---
    # Remove the ticks and labels from the x and y axes
    ax.set_xticks([])
    ax.set_yticks([])
    # Turn off the axis lines and labels completely
    ax.axis('off')
    # Set the aspect ratio of the plot to be equal.
    # This ensures that the square is not distorted (e.g., rendered as a rectangle).
    ax.set_aspect('equal', adjustable='box')
    # Set the limits of the x and y axes.
    # This ensures the square is centered and fits well within the plot area.
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)

    # Optional: Set the background color of the entire figure
    # This can be useful if you want to ensure the black square has good contrast.
    # For example, if the default background is also dark.
    # fig.patch.set_facecolor('lightgray')
    # Add a title to the plot (optional)
    if verbose:
        plt.title(piece_color+ " square with value "+ piece_value)
    # Display the plot
    # This command will typically open a new window showing the generated image.
    return plt


def draw_big_triangle(piece_value = "100", piece_color = "black", center_pt = (0,0), fudge = 1, verbose = False):
    """
    Written by gemini


    EXAMPLES:
        sage: draw_big_triangle(piece_value = "100", piece_color = "black").show()
        sage: draw_big_triangle(piece_value = "49", piece_color = "white").show()


    """
    import matplotlib.pyplot as plt
    import numpy as np
    # 1. Define the vertices of an equilateral triangle
    s = 10  # Side length
    cntr_x = center_pt[0]
    cntr_y = center_pt[1]
    # Vertices
    x1, y1 = 0 + cntr_x, 0 + cntr_y
    x2, y2 = s + cntr_x, 0 + cntr_y
    x3, y3 = s/2 + cntr_x, s*np.sqrt(3)/2 +  + cntr_y
    vertices = np.array([[x1, y1], [x2, y2], [x3, y3]])
    # Create the figure and axes
    fig, ax = plt.subplots(figsize=(4.5*fudge, 3.5*fudge))
    # 2. Draw the equilateral triangle
    # For a truly "white" triangle on a potentially white background,
    # it's good to have an edge. If the background is not white,
    # edgecolor might not be strictly necessary for visibility of the shape,
    # but good practice.
    if piece_color == "white":
        triangle = plt.Polygon(vertices, closed=True, facecolor='white', edgecolor='black')
    if piece_color == "black":
        triangle = plt.Polygon(vertices, closed=True, facecolor='black', edgecolor='white')
    ax.add_patch(triangle)
    # 3. Place the number 72 inside the triangle
    # Calculate the centroid of the triangle
    centroid_x = (x1 + x2 + x3) / 3
    centroid_y = (y1 + y2 + y3) / 3
    # 4. Font size 50
    number = piece_value
    font_size = 50
    if piece_color == "black":
        ax.text(centroid_x, centroid_y, piece_value, fontsize=font_size,
            horizontalalignment='center', verticalalignment='center',
            color = "white") # opposite color text for visibility
    if piece_color == "white":
        ax.text(centroid_x, centroid_y, piece_value, fontsize=font_size,
            horizontalalignment='center', verticalalignment='center',
            color = "black") # Black text for visibility
    # Set plot limits
    ax.set_xlim(-s*0.1, s*1.1)
    ax.set_ylim(-s*0.1, s * np.sqrt(3) / 2 + s*0.1)
    # Remove axes for a cleaner look if desired
    ax.axis('off')
    # It's helpful to set a background color for the figure if the triangle is white,
    # so it stands out.
    #fig.set_facecolor('lightgray') # Or any color other than white
    #ax.set_facecolor('lightgray') # Ensures the axes background is also colored
    if verbose:
        plt.title(piece_color+" equilateral triangle with value " + piece_value)
    return plt


def draw_big_circle(piece_value = "49", piece_color = "black", center_pt = (0,0), verbose = False):
    """
    Written by gemini


    EXAMPLES:

    """
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    cntr_x = center_pt[0]
    cntr_y = center_pt[1]
    # 1. Create the figure and axes
    fig, ax = plt.subplots(figsize=(8, 8)) # Square figure for a nice circle
    # 2. Define circle properties
    circle_center_x = 0.5 + cntr_x
    circle_center_y = 0.5 + cntr_y
    circle_radius = 0.15  # Make it large relative to the default (0,1) axes
    circle_color = piece_color
    if piece_color == "black":
        text_color = "white"
        edge_color = 'white'
    if piece_color == "white":
        edge_color = 'black'
        text_color = "black"
    # 3. Draw the  circle
    circle = patches.Circle((circle_center_x, circle_center_y),
                        radius=circle_radius,
                        edgecolor = edge_color,
                        facecolor=circle_color,
                        transform=ax.transAxes) # Use axes coordinates for sizing
    ax.add_patch(circle)
    # 4. Define text properties
    number = piece_value
    font_size = 50
    # 5. Place the number/piece value inside the circle
    ax.text(circle_center_x, circle_center_y, number,
        fontsize=font_size,
        color=text_color,
        horizontalalignment='center',
        verticalalignment='center',
        transform=ax.transAxes) # Use axes coordinates for positioning
    # Set plot properties for a cleaner look
    ax.set_aspect('equal', adjustable='box') # Ensure it's a circle
    ax.axis('off') # Turn off the axis lines and labels
    if verbose:
        plt.title(piece_color + " circle with value " + piece_value )
    return plt


from sage.plot.colors import Color # Import the Color object

def create_styled_shape(word, cntr=(0,0), scl=1, type="square", color_scheme="white", brdr_color="blue", font_size = 50):
    """
    Generates a SageMath graphics object representing a shape (triangle, square, or circle)
    with a word printed inside, specific styling for border and colors.

    Args:
        word (str): The string to be printed inside the shape.
        cntr (tuple, optional): A pair of numbers (x,y) for the centroid of the shape.
                                Defaults to (0,0).
        scl (float, optional): A positive scale factor. For polygons, it scales their
                               characteristic dimensions. For circles, it's the radius.
                               Defaults to 1.
        type (str, optional): The type of shape: "triangle", "square", or "circle".
                              Defaults to "square".
        color_scheme (str, optional): "white" for white background and black lettering,
                                   or "black" for black background and white lettering.
                                   Defaults to "white".
        brdr_color (str, optional): The color of the shape's border.
                                    Defaults to "blue".

    Output:
        A SageMath Graphics object. The object will have no axes or tickmarks.
        The shape will have a thick double-line border.
        The word will be printed centered with font size 50.
	
    EXAMPLES:
        sage: sq_blue_border = create_styled_shape("Square", cntr=(0,0), scl=1.5, type="square", color_scheme="white", brdr_color="blue")
        sage: sq_blue_border.show(aspect_ratio=1)
        sage: tri_red_border_black_bg = create_styled_shape("Triangle", cntr=(5,0), scl=1, type="triangle", color_scheme="black", brdr_color="red")
        sage: tri_red_border_black_bg.show(aspect_ratio=1)
        sage: circ_green_border = create_styled_shape("Circle!", cntr=(-5,0), scl=1.2, type="circle", color_scheme="white", brdr_color="green")
        sage: circ_green_border.show(aspect_ratio=1)
        sage: circ_custom = create_styled_shape("Hi", cntr=(0,5), scl=2, type="circle", color_scheme="black", brdr_color="#FFD700") # Gold border
        sage: circ_custom.show(aspect_ratio=1)
        sage: tri_purple_border_white_bg = create_styled_shape("Purple Tri", cntr=(0,-5), scl=1.2, type="triangle", color_scheme="white", brdr_color="purple")
        sage: tri_purple_border_white_bg.show(aspect_ratio=1)

    """
    # Validate scale
    if scl <= 0:
        raise ValueError("Scale 'scl' must be positive.")

    # Determine background and text colors based on the color_scheme (as strings)
    if color_scheme == "white":
        background_fill_color_str = 'white'
        text_color_on_scheme_str = 'black'
    elif color_scheme == "black":
        background_fill_color_str = 'black'
        text_color_on_scheme_str = 'white'
    else:
        raise ValueError("color_scheme must be 'white' or 'black'")

    # Convert color strings to Sage Color objects for graphics elements
    sage_background_fill_color = Color(background_fill_color_str)
    sage_actual_border_color = Color(brdr_color) # brdr_color is the input string

    cx, cy = cntr

    # Define border thicknesses for the double border effect
    outer_border_thickness = 6
    middle_gap_thickness = 2

    # Initialize graphics object parts
    shape_obj_fill = None
    shape_obj_border_base = None
    shape_obj_border_gap = None

    if type == "square":
        half_side = 1.0 * scl
        vertices = [
            (cx - half_side, cy + half_side), (cx + half_side, cy + half_side),
            (cx + half_side, cy - half_side), (cx - half_side, cy - half_side)
        ]
        # Main filled shape (edgecolor here is for the edge of the fill itself, usually same as fill or tiny)
        shape_obj_fill = polygon2d(vertices, fill=True, color=sage_background_fill_color, edgecolor=sage_background_fill_color, thickness=0.5, zorder=0)
        # Border base (fill=False, so use 'color' for the line)
        shape_obj_border_base = polygon2d(vertices, fill=False, color=sage_actual_border_color, thickness=outer_border_thickness, zorder=1)
        # Border gap (fill=False, so use 'color' for the line)
        shape_obj_border_gap = polygon2d(vertices, fill=False, color=sage_background_fill_color, thickness=middle_gap_thickness, zorder=2)

    elif type == "triangle":
        side_length = 2.0 * scl
        height = side_length * sqrt(3)/2 # sqrt is a built-in SageMath function
        dist_centroid_to_base = height / 3
        dist_centroid_to_top_vertex = 2 * height / 3
        half_base_width = side_length / 2
        vertices = [
            (cx, cy + dist_centroid_to_top_vertex),
            (cx + half_base_width, cy - dist_centroid_to_base),
            (cx - half_base_width, cy - dist_centroid_to_base)
        ]
        shape_obj_fill = polygon2d(vertices, fill=True, color=sage_background_fill_color, edgecolor=sage_background_fill_color, thickness=0.5, zorder=0)
        # Border base (fill=False, so use 'color' for the line)
        shape_obj_border_base = polygon2d(vertices, fill=False, color=sage_actual_border_color, thickness=outer_border_thickness, zorder=1)
        # Border gap (fill=False, so use 'color' for the line)
        shape_obj_border_gap = polygon2d(vertices, fill=False, color=sage_background_fill_color, thickness=middle_gap_thickness, zorder=2)

    elif type == "circle":
        radius = scl
        shape_obj_fill = circle(cntr, radius, fill=True, color=sage_background_fill_color, edgecolor=sage_background_fill_color, thickness=0.5, zorder=0)
        # Border base (fill=False, so use 'color' for the line)
        shape_obj_border_base = circle(cntr, radius, fill=False, color=sage_actual_border_color, thickness=outer_border_thickness, zorder=1)
        # Border gap (fill=False, so use 'color' for the line)
        shape_obj_border_gap = circle(cntr, radius, fill=False, color=sage_background_fill_color, thickness=middle_gap_thickness, zorder=2)

    else:
        raise ValueError("type must be 'triangle', 'square', or 'circle'")

    # Create text object
    text_graphic = text(
        word,
        cntr,
        fontsize = font_size,
        rgbcolor=text_color_on_scheme_str, # Standard color names work well here
        horizontal_alignment='center',
        vertical_alignment='center',
        zorder=3
    )

    # Combine graphics objects
    final_graphic = shape_obj_fill + shape_obj_border_base + shape_obj_border_gap + text_graphic
    final_graphic.axes(False)
    return final_graphic


def black_triangles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    T012 = create_styled_shape("12", cntr=(0, c), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T016 = create_styled_shape("16", cntr=(0, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T030 = create_styled_shape("30", cntr=(c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T036 = create_styled_shape("36", cntr=(0, 2*c), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T056 = create_styled_shape("56", cntr=(c, c), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T064 = create_styled_shape("64", cntr=(c, 2*c), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T090 = create_styled_shape("90", cntr=(2*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T100 = create_styled_shape("100", cntr=(2*c, c), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    return (T012+T016+T030+T036+T056+T064+T090+T100)
    
def white_triangles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    """
    Self-explanatory

    EXAMPLES:
        sage: white_triangles_plot(plot_scale = 1.75, grid_scale = 4, edge_clr = "green", fnt_sz = 36).show(axes=False)
        Launched png viewer for Graphics object consisting of 32 graphics primitives
    """
    c = grid_scale
    T006 = create_styled_shape("6", cntr=(0, c), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T072 = create_styled_shape("72", cntr=(0, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T081 = create_styled_shape("81", cntr=(c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T009 = create_styled_shape("9", cntr=(0, 2*c), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T049 = create_styled_shape("49", cntr=(c, c), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T042 = create_styled_shape("42", cntr=(c, 2*c), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T020 = create_styled_shape("20", cntr=(2*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T025 = create_styled_shape("25", cntr=(2*c, c), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    return (T042+T020+T025+T049+T072+T081+T006+T009)

def black_circles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    c003 = create_styled_shape("3", cntr=(0, c), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c005 = create_styled_shape("5", cntr=(0, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c007 = create_styled_shape("7", cntr=(c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c009a = create_styled_shape("9", cntr=(0, 2*c), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c009b = create_styled_shape("9", cntr=(c, c), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c025 = create_styled_shape("25", cntr=(c, 2*c), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c049 = create_styled_shape("49", cntr=(2*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c081 = create_styled_shape("81", cntr=(2*c, c), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    return (c003+c005+c007+c009a+c009b+c025+c049+c081)


def white_circles_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    c002 = create_styled_shape("2", cntr=(0, c), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c004a = create_styled_shape("4", cntr=(0, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c004b = create_styled_shape("4", cntr=(c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c006 = create_styled_shape("6", cntr=(0, 2*c), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c008 = create_styled_shape("8", cntr=(c, c), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c016 = create_styled_shape("16", cntr=(c, 2*c), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c036 = create_styled_shape("36", cntr=(2*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c064 = create_styled_shape("64", cntr=(2*c, c), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    return (c002+c004a+c004b+c006+c008+c016+c036+c064)


def black_squares_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    c016 = create_styled_shape("16", cntr=(0, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c025 = create_styled_shape("25", cntr=(0, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c028 = create_styled_shape("28", cntr=(c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c036 = create_styled_shape("36", cntr=(0, 2*c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c049a = create_styled_shape("49", cntr=(c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c049b = create_styled_shape("49", cntr=(c, 2*c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c064 = create_styled_shape("64", cntr=(2*c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c066 = create_styled_shape("66", cntr=(2*c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c120 = create_styled_shape("120", cntr=(0, 3*c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c121 = create_styled_shape("121", cntr=(c, 3*c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c225 = create_styled_shape("225", cntr=(2*c, 3*c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c361 = create_styled_shape("361", cntr=(3*c, 3*c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    return (c016+c025+c028+c036+c049b+c049b+c064+c066+c120+c121+c225+c361)


def white_squares_plot(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    """
    A utility to help players print paper pieces.
    
    EXAMPLES:
        sage: white_squares_plot(plot_scale = 1.75, grid_scale = 4, edge_clr = "green", fnt_sz = 32).show(axes=False)
        Launched png viewer for Graphics object consisting of 52 graphics primitives
    """
    c = grid_scale
    c001 = create_styled_shape("1", cntr=(0, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c004 = create_styled_shape("4", cntr=(0, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c009 = create_styled_shape("9", cntr=(c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c015 = create_styled_shape("15", cntr=(0, 2*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c016 = create_styled_shape("16", cntr=(c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c025a = create_styled_shape("25", cntr=(c, 2*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c025b = create_styled_shape("25", cntr=(2*c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c036 = create_styled_shape("36", cntr=(2*c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c045 = create_styled_shape("45", cntr=(0, 3*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c081 = create_styled_shape("81", cntr=(c, 3*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c153 = create_styled_shape("153", cntr=(2*c, 3*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c169 = create_styled_shape("169", cntr=(3*c, 3*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c289 = create_styled_shape("289", cntr=(2*c, 2*c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    return (c001+c004+c009+c015+c016+c025a+c025b+c036+c045+c081+c153+c169+c289)


def black_triangles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    """
    Plots the piece shapes and values in a line, for publication purposes

    """
    c = grid_scale
    T012 = create_styled_shape("12", cntr=(2*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T016 = create_styled_shape("16", cntr=(0, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T030 = create_styled_shape("30", cntr=(c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T036 = create_styled_shape("36", cntr=(3*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T056 = create_styled_shape("56", cntr=(4*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T064 = create_styled_shape("64", cntr=(5*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T090 = create_styled_shape("90", cntr=(6*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    T100 = create_styled_shape("100", cntr=(7*c, 0), scl=plot_scale, type="triangle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    return (T012+T016+T030+T036+T056+T064+T090+T100)
    
def white_triangles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    """
    Self-explanatory

    EXAMPLES:
        sage: white_triangles_plot(plot_scale = 1.75, grid_scale = 4, edge_clr = "green", fnt_sz = 36).show(axes=False)
        Launched png viewer for Graphics object consisting of 32 graphics primitives
    """
    c = grid_scale
    T006 = create_styled_shape("6", cntr=(2*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T072 = create_styled_shape("72", cntr=(0, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T081 = create_styled_shape("81", cntr=(c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T009 = create_styled_shape("9", cntr=(3*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T049 = create_styled_shape("49", cntr=(4*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T042 = create_styled_shape("42", cntr=(5*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T020 = create_styled_shape("20", cntr=(6*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    T025 = create_styled_shape("25", cntr=(7*c, 0), scl=plot_scale, type="triangle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    return (T042+T020+T025+T049+T072+T081+T006+T009)
    
def black_circles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    c003 = create_styled_shape("3", cntr=(0, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c005 = create_styled_shape("5", cntr=(c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c007 = create_styled_shape("7", cntr=(2*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c009a = create_styled_shape("9", cntr=(3*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c009b = create_styled_shape("9", cntr=(4*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c025 = create_styled_shape("25", cntr=(5*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c049 = create_styled_shape("49", cntr=(6*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c081 = create_styled_shape("81", cntr=(7*c, 0), scl=plot_scale, type="circle", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    return (c003+c005+c007+c009a+c009b+c025+c049+c081)
    
def white_circles_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    c002 = create_styled_shape("2", cntr=(0, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c004a = create_styled_shape("4", cntr=(c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c004b = create_styled_shape("4", cntr=(2*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c006 = create_styled_shape("6", cntr=(3*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c008 = create_styled_shape("8", cntr=(4*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c016 = create_styled_shape("16", cntr=(5*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c036 = create_styled_shape("36", cntr=(6*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c064 = create_styled_shape("64", cntr=(7*c, 0), scl=plot_scale, type="circle", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    return (c002+c004a+c004b+c006+c008+c016+c036+c064)
    
def white_squares_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    """
    A utility to help players print paper pieces.
    
    EXAMPLES:
        sage: white_squares_plot(plot_scale = 1.75, grid_scale = 4, edge_clr = "green", fnt_sz = 32).show(axes=False)
        Launched png viewer for Graphics object consisting of 52 graphics primitives
    """
    c = grid_scale
    c001 = create_styled_shape("1", cntr=(0, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c004 = create_styled_shape("4", cntr=(c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c009 = create_styled_shape("9", cntr=(2*c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c015 = create_styled_shape("15", cntr=(3*c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c016 = create_styled_shape("16", cntr=(4*c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c025a = create_styled_shape("25", cntr=(5*c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c025b = create_styled_shape("25", cntr=(6*c, 0), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c036 = create_styled_shape("36", cntr=(c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c045 = create_styled_shape("45", cntr=(2*c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c081 = create_styled_shape("81", cntr=(3*c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c153 = create_styled_shape("153", cntr=(4*c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c169 = create_styled_shape("169", cntr=(5*c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    c289 = create_styled_shape("289", cntr=(6*c, c), scl=plot_scale, type="square", color_scheme="white", brdr_color = edge_clr, font_size = fnt_sz)
    return (c001+c004+c009+c015+c016+c025a+c025b+c036+c045+c081+c153+c169+c289)
    
def black_squares_plot_line(plot_scale = 1.5, grid_scale = 3, edge_clr = "red", fnt_sz = 50):
    c = grid_scale
    c016 = create_styled_shape("16", cntr=(0, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c025 = create_styled_shape("25", cntr=(c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c028 = create_styled_shape("28", cntr=(2*c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c036 = create_styled_shape("36", cntr=(3*c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c049a = create_styled_shape("49", cntr=(4*c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c049b = create_styled_shape("49", cntr=(5*c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c064 = create_styled_shape("64", cntr=(6*c, 0), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c066 = create_styled_shape("66", cntr=(c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c120 = create_styled_shape("120", cntr=(2*c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c121 = create_styled_shape("121", cntr=(3*c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c225 = create_styled_shape("225", cntr=(4*c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    c361 = create_styled_shape("361", cntr=(5*c, c), scl=plot_scale, type="square", color_scheme="black", brdr_color = edge_clr, font_size = fnt_sz)
    return (c016+c025+c028+c036+c049a+c049b+c064+c066+c120+c121+c225+c361)

def move_capture_lists_to_latex_table(even_moves, even_captures, odd_moves, odd_captures):
    """
    Almost self-explanatory: this function takes the innputted list of
    turns, as a specific type of move+capture list, and loops over this
    list. For each element of the list, it adds a line of text to a string.
    Adding these up, the final string output of the function is a
    more-or-less correctly formatted latex table representing the
    rithmomachia turns listed in the input.

    All 4 lists must be of the same length. The pre-move captures are not
    differentiated from the post-move captures.

    TO DO:
      (1) This condition rules out White making a move but not Black. FIX THIS!!!
      (2) The notation for the capture doesn't specify if it's before or after a move.
      
    EXAMPLES:
        sage: even_moves = ['T^81c1e1', 'T^72c2e2', 'T^72e2g2'];
	 even_captures = [[], [], [[((1, 6), 72, T^72), ((1, 13), 12, t^12)]]];
	 odd_moves = ['c^3m3l3', 'c^7m5l5', 'c^7l5k5']; odd_captures =  [[], [], []]
        sage: move_capture_lists_to_latex_table(even_moves, even_captures, odd_moves, odd_captures)
         '\\begin{array}{l|ll|ll|} \\hline
	 \\quad & Even moves & Even captures  & Odd moves & Odd captures \\ \\hline
	 1      & T^81c1e1 &                  & c^3m3l3 &   \\
	 2      & T^72c2e2 &                  & c^7m5l5 &   \\
	 3      & T^72e2g2 & T^72\\times t^12 & c^7l5k5 &   \\
	 \\quad & \\quad  & \\quad            & \\quad  & \\quad \\ \\hline \n
	 \\end{array}'

    """
    nn = len(even_moves)
    if not(len(even_captures) == nn):
        print("Sorry, the list lengths must be the same.")
        return False
    if not(len(odd_captures) == nn):
        print("Sorry, the lengths must be the same.")
        return False
    if not(len(odd_moves) == nn):
        print("Sorry, the list lengths must be the same.")
        return False
    top_line = "\\begin{array}{l|ll|ll|} \\hline"
    second_line = "\\quad & Even moves & Even captures & Odd moves & Odd captures \\ \\hline"
    body_lines = ""
    for ii in range(nn):
        #print("0000", even_captures[ii], odd_captures[ii])
        if len(even_captures[ii])==0:
            even_cap_str = ""
        else:
            even_cap_str = str(even_captures[ii][0][0][-1]) + "\\times " + str(even_captures[ii][0][1][-1])
        if len(odd_captures[ii])==0:
            odd_cap_str = ""
        else:
            odd_cap_str = str(odd_captures[ii][0][-1]) + "\\times " + str(odd_captures[ii][1][-1])
        next_line = str(ii+1) + " & " + str(even_moves[ii]) + " & " + even_cap_str + " & " + str(odd_moves[ii]) + " & " + odd_cap_str + "  \\" 
        body_lines = body_lines + next_line
    end_line = "\\quad & \\quad & \\quad & \\quad & \\quad \\ \\hline \n \\end{array}"
    return top_line + second_line + body_lines + end_line

def center_of_gravity(game_state, piece_color = "Odd", by_rank = False):
    """
    returns the center of gravity of the coordinates of the pieces
    with <piece_color> equal to "Odd" (or "Black, "black", "odd:)
    or equal to "white" (or "White", "Even", "even").

    The option by_rank = False just computes the COG of all the 
    pieces with the given piece_color. 
    If the option by_rank = True then the function computes the COG of all the 
    pieces with the given piece_color which are within 2 coordinates of
    the enemy territory.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: center_of_gravity(GSp, piece_color = "Odd")
         (3.5, 13.5)
        sage: center_of_gravity(GSp, piece_color = "white")
         (3.5, 1.5)
        sage: closest_cog = []
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = move_piece(GSp, (7,2),(7,4)) ## T009c8e8
        sage: center_of_gravity(GSp, piece_color = "white")
         (3.5, 1.5)
        sage: center_of_gravity(GS, piece_color = "even")
         (3.5, 1.5833333333333333)
        sage: for mm in LL:
         ....:     cogw = center_of_gravity(GS, piece_color = "white")
         ....:     GS0 = move_piece(GS, mm[0], mm[1])
         ....:     cogb = center_of_gravity(GS0, piece_color = "black")
         ....:     closest_cog = closest_cog + [(sqrt((cogw[0]-cogb[0])^2+(cogw[1]-cogb[1])^2), mm)]
         ....: 
         ....: 
        sage: closest_cog.sort()
        sage: min_dist = closest_cog[0][0]; min_dist
        11.833333333333332
        sage: nearest_moves = [mm[1] for mm in closest_cog if mm[0]==min_dist]; nearest_moves
         [((0, 13), (0, 11)),
          ((1, 13), (1, 11)),
          ((6, 13), (6, 11)),
          ((7, 13), (7, 11))]

    """
    gs = copy(game_state)
    positions_data = []

    if (piece_color in ["black", "Black", "odd", "Odd"]):
        positions_data = positions_b(gs)
        if by_rank:
            # Filter for pieces in or near enemy territory (columns 0-9)
            positions_data = [data for data in positions_data if data[0][1] < 10]
    elif (piece_color in ["even", "Even", "white", "White"]):
        positions_data = positions_w(gs)
        if by_rank:
            # Filter for pieces in or near enemy territory (columns 6-15)
            positions_data = [data for data in positions_data if data[0][1] > 5]
    else:
        print("You must select a piece color, such as 'Even' or 'Odd'. Try again.")
        return (-1, -1)

    # Extract just the coordinate tuples from the detailed data
    positions = [data[0] for data in positions_data]
    
    nn = len(positions)
    if nn == 0:
        # Avoid division by zero if no pieces match the criteria
        return (-1, -1)

    # Correctly sum the x and y coordinates from the tuples
    x0 = sum(pos[0] for pos in positions)
    y0 = sum(pos[1] for pos in positions)
    
    return (x0/nn, y0/nn)


def coordinating_progression_count_odd(v):
    """
    returns the number of coordinating progressions that the 
    Odd/Black value v belongs to.


    EXAMPLES:
        sage: print([(v, coordinating_progression_count_odd(v)) for v in odd_piece_values()])
         [(3, 1), (5, 2), (7, 5), (9, 3), (12, 3), (16, 5), (25, 2), (28, 3), (30, 2), (36, 5), (49, 3),
          (56, 3), (64, 4), (66, 2), (81, 2), (90, 2), (100, 5), (120, 2), (121, 2), (190, 1), (225, 2), (361, 1)]

    
    """
    arith_prog_odd = list_arithmetical_patterns_black()
    geom_prog_odd = list_geometrical_patterns_black()
    harm_prog_odd = list_musical_patterns_black()
    prog_odd = arith_prog_odd + geom_prog_odd + harm_prog_odd
    L = [x for x in prog_odd if v in x]
    return len(L)
    
def coordinating_progression_count_even(v):
    """
    returns the number of coordinating progressions that the 
    White/Even value v belongs to.


    EXAMPLES:
        sage: print([(v, coordinating_progression_count_even(v)) for v in even_piece_values()])
         [(2, 3), (4, 7), (6, 3), (8, 5), (9, 7), (15, 3), (16, 6), (20, 4), (25, 5), (36, 4),
          (42, 3), (45, 3), (49, 3), (64, 4), (72, 2), (81, 6), (91, 1), (153, 2), (169, 2), (289, 2)]

    
    """
    arith_prog_even = list_arithmetical_patterns_white()
    geom_prog_even = list_geometrical_patterns_white()
    harm_prog_even = list_musical_patterns_white()
    prog_even = arith_prog_even + geom_prog_even + harm_prog_even
    L = [x for x in prog_even if v in x]
    return len(L)
    
def coordinating_progression_count(v, color="white"):
    """
    simply returns the result of 
       coordinating_progression_count_even(v)
    or 
       coordinating_progression_count_even(v):
    depending on the side. Here the color option can take
    "white" or "even" or "black" or "odd".

    EXAMPLE:
        sage: coordinating_progression_count(9, color="blue")
         color must be in ["white", "even", "White", "Even", "black", "Black", "odd", "Odd"]. Please try again.
         -1
        sage: coordinating_progression_count(9, color="white")
         8
        sage: coordinating_progression_count(9, color="Odd")
         6

    """
    if color=="white" or color=="even" or color=="White" or color=="Even":
        return coordinating_progression_count_even(v)
    if color=="black" or color=="Black" or color=="odd" or color=="Odd":
        return coordinating_progression_count_odd(v)
    else:
        print('color must be in ["white", "even", "White", "Even", "black", "Black", "odd", "Odd"]. Please try again.')
        return -1
	
def even_piece_values():
    """
    returns all values of white/even pieces in some coordinating progression of White/Even pieces

    EXAMPLES:
        sage: even_piece_values()
         [2, 4, 6, 8, 9, 15, 16, 20, 25, 36, 42, 45, 49, 64, 72, 81, 91, 153, 169, 289]
        sage: len(even_piece_values())
         20

    """
    arith_prog_even = list_arithmetical_patterns_white()
    geom_prog_even = list_geometrical_patterns_white()
    harm_prog_even = list_musical_patterns_white()
    prog_even = arith_prog_even + geom_prog_even + harm_prog_even
    even_values0 =[list(x) for x in prog_even]
    even_values1 = []
    for x in even_values0:
        even_values1 = even_values1 + x
    even_piece_values = list(set(even_values1))
    even_piece_values.sort()
    return even_piece_values


def odd_piece_values():
    """
    returns all values of black/odd pieces in some coordinating progression of Black/Odd pieces

    EXAMPLES:
        sage: odd_piece_values()
         [3, 5, 7, 9, 12, 16, 25, 28, 30, 36, 49, 56, 64, 66, 81, 90, 100, 120, 121, 190, 225, 361]
        sage: len(odd_piece_values())
         22

    """
    arith_prog_odd = list_arithmetical_patterns_black()
    geom_prog_odd = list_geometrical_patterns_black()
    harm_prog_odd = list_musical_patterns_black()
    prog_odd = arith_prog_odd + geom_prog_odd + harm_prog_odd
    odd_values0 =[list(x) for x in prog_odd]
    odd_values1 = []
    for x in odd_values0:
        odd_values1 = odd_values1 + x
    odd_piece_values = list(set(odd_values1))
    odd_piece_values.sort()
    return odd_piece_values


def coordinating_progression_pair_count_odd(v1, v2):
    """
    returns the number of coordinating progressions that the 
    Odd/Black values v1, v2 simulataneously belong to.


    EXAMPLES:
        sage: coordinating_progression_pair_count_odd(7, 36)
         0 
        sage: coordinating_progression_pair_count_odd(7, 100)
         0
        sage: coordinating_progression_pair_count_odd(7, 9)
         1

    
    """
    arith_prog_odd = list_arithmetical_patterns_black()
    geom_prog_odd = list_geometrical_patterns_black()
    harm_prog_odd = list_musical_patterns_black()
    prog_odd = arith_prog_odd + geom_prog_odd + harm_prog_odd
    L = [x for x in prog_odd if (v1 in x) and (v2 in x)]
    return len(L)
    
def coordinating_progression_pair_count_even(v1, v2):
    """
    returns the number of coordinating progressions that the 
    Odd/Black values v1, v2 simulataneously belong to.


    EXAMPLES:
        sage: coordinating_progression_pair_count_even(4, 9)
         1
        sage: coordinating_progression_pair_count_even(2, 4)
         2
        sage: coordinating_progression_pair_count_even(6, 81)
         0

    
    """
    arith_prog_even = list_arithmetical_patterns_white()
    geom_prog_even = list_geometrical_patterns_white()
    harm_prog_even = list_musical_patterns_white()
    prog_even = arith_prog_even + geom_prog_even + harm_prog_even
    L = [x for x in prog_even if (v1 in x) and (v2 in x)]
    return len(L)


def coordinating_progression_pair_count(v1, v2, color="white"):
    """
    simply returns the result of 
       coordinating_progression_pair_count_even(v1, v2)
    or 
       coordinating_progression_pair_count_even(v1, v2):
    depending on the side. Here the color option can take
    "white" or "even" or "black" or "odd".

    EXAMPLE:
        sage: coordinating_progression_pair_count(4, 9, color="blue")
         color must be in ["white", "even", "White", "Even", "black", "Black", "odd", "Odd"]. Please try again.
         -1
        sage: coordinating_progression_pair_count(4, 9, color="white")
         1       

    """
    if color=="white" or color=="even" or color=="White" or color=="Even":
        return coordinating_progression_pair_count_even(v1, v2)
    if color=="black" or color=="Black" or color=="odd" or color=="Odd":
        return coordinating_progression_pair_count_odd(v1, v2)
    else:
        print('color must be in ["white", "even", "White", "Even", "black", "Black", "odd", "Odd"]. Please try again.')
        return -1
    
def get_piece_details_from_poly(poly_piece, default_color_w='green', default_color_b='red'):
    """
    This is a functions that is used in display_board_matplotlib.
    It's a helper function to map Sage piece variables to matplotlib shapes and colors.

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: pos_w = positions_w(GSp, verbose = True)
        sage: pos_w[0]
         [(0, 0), S^289]
        sage: get_piece_details_from_poly(pos_w[0][1], default_color_w='green', default_color_b='red')
         ('square', 'green')

    """
    if poly_piece == 0:
        return None, None, None
    # Re-declare Sage variables if not in global scope of this function
    # (Safer to pass them or have them accessible if this is a utility module)
    sage_vars = var("c,C,p,P,t,T,s,S")
    (c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var) = sage_vars
    #c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var]
    variables = poly_piece.variables()
    shape_mpl = "unknown"
    color_mpl = "gray" # Default
    # Determine shape and color (this needs to match your Piece class logic or desired mapping)
    if C_var in variables:
        shape_mpl, color_mpl = "circle", default_color_w
    elif T_var in variables:
        shape_mpl, color_mpl = "triangle", default_color_w
    elif P_var in variables:
        shape_mpl, color_mpl = "diamond", "lime" # White Pyramid
    elif p_var in variables:
        shape_mpl, color_mpl = "diamond", "purple" # Black Pyramid
    elif S_var in variables:
        shape_mpl, color_mpl = "square", default_color_w
    elif c_var in variables:
        shape_mpl, color_mpl = "circle", default_color_b
    elif t_var in variables:
        shape_mpl, color_mpl = "triangle", default_color_b
    elif s_var in variables:
        shape_mpl, color_mpl = "square", default_color_b
    # For value, use value_of_piece (ensure it handles polynomials correctly)
    # value_of_piece from procedural file returns a list.
    # We'll sum numeric values for display or take first.
    # Note: value_of_piece needs the game_state matrix, row, col.
    return shape_mpl, color_mpl # Value will be handled in the loop


def capture_list_to_animation_enhanced(game_state, capture_list, base_filename="capture", frame_start_index=0):
    """
    Creates 3 frames for a capture animation and returns the new game state and frame count.
    1) The board position with circles around the pieces involved.
    2) The captured piece vanishes.
    3) The board without circles.
    """
    if not capture_list or len(capture_list) < 2:
        return game_state, 0 # Return gracefully if format is wrong

    attacker_info, victim_info = capture_list[0], capture_list[1]
    loc_pc1, _, _ = attacker_info
    loc_pc2, _, _ = victim_info

    hpa = [coordinate_to_algebraic(*loc_pc1), coordinate_to_algebraic(*loc_pc2)]
    
    # Frame 1: Highlight pieces involved
    filename1 = os.path.join(SAGE_DIR, f"frame_{frame_start_index:03d}.png")
    display_board_matplotlib_enhanced(game_state, dpi=300, highlight_pieces=hpa, filename=filename1)
    
    # Update game state using the new signature
    game_state2 = capture_piece(game_state, loc_pc1, loc_pc2, verbose=False)

    # Frame 2: Show captured piece removed, but keep highlight
    filename2 = os.path.join(SAGE_DIR, f"frame_{frame_start_index + 1:03d}.png")
    display_board_matplotlib_enhanced(game_state2, dpi=300, highlight_pieces=hpa, filename=filename2)

    # Frame 3: Final state with no highlights
    filename3 = os.path.join(SAGE_DIR, f"frame_{frame_start_index + 2:03d}.png")
    display_board_matplotlib_enhanced(game_state2, dpi=300, highlight_pieces=[], filename=filename3)

    return game_state2, 3
    
    
def capture_list_to_animation(game_state, capture_list):
    """
    creates 3 frames 
    1) the board position for game_state
    2) same position with circles around the pieces involved, 
    then 
    3) the captured piece vanishes, the circles vanish, and the
       new game_state is displayed (with text "piece XXX/yyy has been captured"?)

    The capture_list represents exactly one enemy piece being captured by a friendly
    piece (in case of a capture by sum, where two friendly pieces cooperate to capture
    the enemy piece, simply use the last moved friendly piece) has the structure:
        [ (loc_pc1, val_pc1, poly_pc1), (loc_pc2, val_pc2, poly_pc2) ]
    We want a circle around the piece at loc_pc1 and the piece at loc_pc2.

    The color of the attacking piece can be determined from 
    poly_pc1, which will be the opposing color of poly_pc2. The piece
    at loc_pc2 will vanish.

    ########## ########## ########## ########## ########## ########## ########## ########## ########## 
    ########## perhaps the format here can be improved? The point is 
    ########## the goal is to create frames to animate an annotated
    ########## full rithmomachia game, for instructional/educational purposes
    ########## This program would be used along with 
    ########## move_piece(game_state, start_pos, end_pos, verbose = False)
    ########## and 
    ########## display_board_matplotlib(game_state_sage_matrix, dpi=300, highlight_pieces=None)
    ########## to create frames, which must be named in order (such as evenmove1, oddmove2,
    ########## or something like that) so that they can be fed into an animation
    ########## program such as ffmpeg that will output an mp4. 
    ########## ########## ########## ########## ########## ########## ########## ########## ########## 


    EXAMPLES:
        sage: c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
        sage: PR = ZZ[c,C,p,P,t,T,s,S]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: (loc_pc1, val_pc1, poly_pc1) = ((3, 3), 6, C^6) 
        sage: (loc_pc2, val_pc2, poly_pc2) = ((3, 12), 5, c^5)
	sage: cl = [(loc_pc1, val_pc1, poly_pc1), (loc_pc2, val_pc2, poly_pc2)]
	sage: capture_list_to_animation(GSp, cl)
         Board image saved to rithmomachia_board.png with a DPI of 300
         Board image saved to rithmomachia_board.png with a DPI of 300
         Board image saved to rithmomachia_board.png with a DPI of 300
         <module 'matplotlib.pyplot' from '/private/var/tmp/.../site-packages/matplotlib/pyplot.py'>


    """
    cl = capture_list
    (loc_pc1, val_pc1, poly_pc1) = cl[0]
    (loc_pc2, val_pc2, poly_pc2) = cl[1]
    hpa = [coordinate_to_algebraic(x[0], x[1]) for x in [loc_pc1, loc_pc2]]
    #print(hpa, (loc_pc1, val_pc1, poly_pc1), (loc_pc2, val_pc2, poly_pc2))
    dbm = display_board_matplotlib(game_state, dpi=300, highlight_pieces = hpa)
    game_state2 = capture_piece(game_state, val_pc1, loc_pc2, verbose=False)
    dbm2 = display_board_matplotlib(game_state2, dpi=300, highlight_pieces = hpa)
    dbm3 = display_board_matplotlib(game_state2, dpi=300, highlight_pieces = [])
    return plt

def captures_as_dict(game_state, verbose = False):
    """
    This returns a list of dictionaries of all captures (from both sides of 
    the board). The algorithm is to go case-by-case through the types of
    captures, since the capture record is different for different types
    of captures. Therefore, the program is quite simple to follow but also
    quite long.

    NOTATION for captures:

    * The pieces can be dictionaries:

      piece = {"color": "even"/"odd",
               "shape": "circle"/"triangle","square"/"pyramid",
               "value": v,
	       "algebraic": "C^4"/"c^7"/.../"P+<subpieces>",
	       "position": (x,y)}
      Of course, a piece can also be represented as a 5-list, where each component is represented as above.

    * The capture dictionary is similar:  
 
     capture = {"friendly_piece": piece1, ######## this is the capturing/attacking piece (or one of them)
                "enemy_piece": piece2, ######## this is the captured/attacked piece (one per capture)
	        "capture_type": "number"/"sum"/"difference"/"product"/"divisor"/"siege"/"unknown",
	        "pre_move_capture": True/False,
	        "post_move_capture": True/False}
    where the dictionary structure for piece1, piece2 are as described above (but of opposite "color,"
    of course). 

    The function computes these by means of the capture lists that arise from the legal_moves_captures_* 
    functions. Each capture list depends on the type of capture, so expect some capture lists to be short
    and others to be longer.

    EXAMPLES:
       sage: GSp = board_initial_matrix(pyramid_decomposition = True)
       sage: GS = copy(GSp)
       sage: GS[3,3]=0; GS[0,13] = C^6; GS[6,2] = 0; GS[1,11] = T^6
       sage: valid_captures_by_addition_white(GS)
       [[((0, 13), [6]), ((1, 11), [6]), ((1, 13), [12])],
        [((1, 11), [6]), ((0, 13), [6]), ((1, 13), [12])]]
       sage: captures_as_dict(GS)
       [{'friendly_piece': {'color': 'even',
          'value': [6],
          'shape': 'circle',
          'position': (0, 13),
          'algebraic': C^6},
         'enemy_piece': {'color': 'odd',
          'value': [12],
          'shape': 'triangle',
          'position': (1, 13),
          'algebraic': t^12},
         'capture_type': 'sum',
         'pre_move_capture': True,
         'post_move_capture': False},
        {'friendly_piece': {'color': 'even',
          'value': [6],
          'shape': 'triangle',
          'position': (1, 11),
          'algebraic': T^6},
         'enemy_piece': {'color': 'odd',
          'value': [12],
          'shape': 'triangle',
          'position': (1, 13),
          'algebraic': t^12},
         'capture_type': 'sum',
         'pre_move_capture': True,
         'post_move_capture': False}]
       sage: GSp = board_initial_matrix(pyramid_decomposition = True)
       sage: GS = copy(GSp)
       sage: GS[1,11] = T^9; GS[7,2] = 0; GS[2,11] = c^3; GS[2,12] = 0
       sage: captures_as_dict(GS)
       [{'friendly_piece': {'color': 'odd',
          'value': [12],
          'shape': 'triangle',
          'position': (1, 13),
          'algebraic': t^12},
         'enemy_piece': {'color': 'even',
          'value': [9],
          'shape': 'triangle',
          'position': (1, 11),
          'algebraic': T^9},
         'capture_type': 'difference',
         'pre_move_capture': True,
         'post_move_capture': False}]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2, 15] = C^(36); GS[3, 2] = 0; GS[5, 15] = C^(64); GS[2, 2] = 0
        sage: valid_captures_by_numbering_white(GS)
         [((2, 15, [36]), (2, 14, [36]), (2, 15), C^36, t^36),
          ((5, 15, [64]), (5, 14, [64]), (5, 15), C^64, t^64)]
        sage: captures_as_dict(GS)
        [{'friendly_piece': {'color': 'even',
           'value': 15,
           'shape': 'circle',
           'position': (2, 15),
           'algebraic': C^36},
          'enemy_piece': {'color': 'odd',
           'value': 14,
           'shape': 'triangle',
           'position': (2, 14),
           'algebraic': t^36},
          'capture_type': 'number',
          'pre_move_capture': True,
          'post_move_capture': False},
         {'friendly_piece': {'color': 'even',
           'value': 15,
           'shape': 'circle',
           'position': (5, 15),
           'algebraic': C^64},
          'enemy_piece': {'color': 'odd',
           'value': 14,
           'shape': 'triangle',
           'position': (5, 14),
           'algebraic': t^64},
          'capture_type': 'number',
          'pre_move_capture': True,
          'post_move_capture': False}]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[7,7] = p^190 + s^64 + s^49 + s^36 + s^25 + s^16; GS[7, 14] = 0
        sage: valid_captures_by_multiplication_white(GS, verbose=True)
         The piece component T^9 (value 9) at (7, 2) captures by multiplication the piece component p^190 + s^64 + s^49 + s^36 + s^25 + s^16 (value 36) at (7, 7) at separation 4
         [[((7, 2), 9, T^9), ((7, 7), 36, p^190 + s^64 + s^49 + s^36 + s^25 + s^16)]]
        sage: captures_as_dict(GS)
        [{'friendly_piece': {'color': 'even',
           'value': 9,
           'shape': 'triangle',
           'position': (7, 2),
           'algebraic': T^9},
          'enemy_piece': {'color': 'odd',
           'value': 36,
           'shape': 'square',
           'position': (7, 7),
           'algebraic': p^190 + s^64 + s^49 + s^36 + s^25 + s^16},
          'capture_type': 'product',
          'pre_move_capture': True,
          'post_move_capture': False}]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[3, 6] = P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S; GS[1, 1] = 0
        sage: valid_captures_by_division_white(GS, verbose = True)
        sage: captures_as_dict(GS)
        [{'friendly_piece': {'color': 'even',
           'value': 1,
           'shape': 'square',
           'position': (3, 6),
           'algebraic': P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S},
          'enemy_piece': {'color': 'odd',
           'value': 5,
           'shape': 'circle',
           'position': (3, 12),
           'algebraic': c^5},
          'capture_type': 'product',
          'pre_move_capture': True,
          'post_move_capture': False},
         {'friendly_piece': {'color': 'odd',
           'value': 5,
           'shape': 'circle',
           'position': (3, 12),
           'algebraic': c^5},
          'enemy_piece': {'color': 'even',
           'value': 25,
           'shape': 'square',
           'position': (3, 6),
           'algebraic': P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S},
          'capture_type': 'product',
          'pre_move_capture': True,
          'post_move_capture': False},
         {'friendly_piece': {'color': 'even',
           'value': 25,
           'shape': 'square',
           'position': (3, 6),
           'algebraic': P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S},
          'enemy_piece': {'color': 'odd',
           'value': 5,
           'shape': 'circle',
           'position': (3, 12),
           'algebraic': c^5},
          'capture_type': 'factor',
          'pre_move_capture': True,
          'post_move_capture': False},
         {'friendly_piece': {'color': 'odd',
           'value': 5,
           'shape': 'circle',
           'position': (3, 12),
           'algebraic': c^5},
          'enemy_piece': {'color': 'even',
           'value': 1,
           'shape': 'square',
           'position': (3, 6),
           'algebraic': P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S},
          'capture_type': 'factor',
          'pre_move_capture': True,
          'post_move_capture': False}]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,2] = c^3; GS[2,12] = 0
        sage: valid_captures_by_siege_white(GS, verbose = True)
         The piece c^3 at (2, 2) with value [3] is captured by siege.
         [[((2, 2), [3], c^3)]]
        sage: captures_as_dict(GS)
         [{'friendly_piece': {'color': 'even',
          'value': [49],
           'shape': 'triangle',
           'position': (2, 1),
           'algebraic': T^49},
          'enemy_piece': {'color': 'odd',
           'value': 2,
           'shape': 'circle',
           'position': (2, 2),
           'algebraic': c^3},
          'capture_type': 'siege',
          'pre_move_capture': True,
          'post_move_capture': False}]


    """
    GS = copy(game_state)
    # Re-declare Sage variables if not in global scope of this function
    # (Safer to pass them or have them accessible if this is a utility module)
    sage_vars = var("c,C,p,P,t,T,s,S")
    (c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var) = sage_vars
    #c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var]
    ##c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    ##PR = ZZ[c,C,p,P,t,T,s,S]
    captures_total = []
    #### now we do case-by-case for each type of capture ...
    ################ capture by sum/addition for friendly = even/white
    # in this case, capture record is list of triples of the form
    #           [((0, 12), 6), ((1, 11), 6), ((1, 13), 12)]
    vca_even = valid_captures_by_addition_white(game_state, verbose = False)
    ################ capture by sum/addition for friendly = odd/black
    vca_odd  = valid_captures_by_addition_black(game_state, verbose = False)
    vca_all = vca_even + vca_odd
    for xx in vca_all:
        piece1 = {}
        piece2 = {}
        pc_attacker = xx[0]
        #print(pc_attacker, xx)
        pos_x = pc_attacker[0][0]
        pos_y = pc_attacker[0][1]
        pc_attacker_alg = GS[pos_x, pos_y]
        variables = pc_attacker_alg.variables()
        if C_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif T_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif S_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif P_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif c_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif t_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif s_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif p_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        pc_captured = xx[2]
        pos_x = pc_captured[0][0]
        pos_y = pc_captured[0][1]
        pc_captured_alg = GS[pos_x, pos_y]
        variables = pc_captured_alg.variables()
        if C_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif T_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif S_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif P_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif c_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif t_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif s_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif p_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        caps = {"friendly_piece": piece1, "enemy_piece": piece2, "capture_type": "sum",
                "pre_move_capture": True, "post_move_capture": False}
        captures_total = captures_total + [caps]
    ################ capture by difference for friendly = even/white
    # in this case, capture record is list of triples like capture by sum
    vcs_even = valid_captures_by_subtraction_white(game_state, verbose = False)
    ################ capture by sum for friendly = odd/black
    # example of syntax:
    # valid_captures_by_subtraction_black(GS)
    #     [[((1, 13), [12]), ((2, 11), [3]), ((1, 11), [9])]]
    vcs_odd  = valid_captures_by_subtraction_black(game_state, verbose = False)
    vcs_all = vcs_even + vcs_odd
    for xx in vcs_all:
        piece1 = {}
        piece2 = {}
        pc_attacker = xx[0]
        #print(pc_attacker, xx)
        pos_x = pc_attacker[0][0]
        pos_y = pc_attacker[0][1]
        pc_attacker_alg = GS[pos_x, pos_y]
        variables = pc_attacker_alg.variables()
        if C_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif T_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif S_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif P_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif c_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif t_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif s_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif p_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        pc_captured = xx[2]
        pos_x = pc_captured[0][0]
        pos_y = pc_captured[0][1]
        pc_captured_alg = GS[pos_x, pos_y]
        variables = pc_captured_alg.variables()
        if C_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif T_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif S_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif P_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif c_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif t_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif s_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif p_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        caps = {"friendly_piece": piece1, "enemy_piece": piece2, "capture_type": "difference",
                "pre_move_capture": True, "post_move_capture": False}
        captures_total = captures_total + [caps]
    ################ capture by number for friendly = even/white
    # in this case, capture record is list of 5-tuples of the form
    #           ((2, 15, [36]), (2, 14, [36]), (2, 15), C^36, t^36)
    vcn_even = valid_captures_by_numbering_white(game_state, verbose = False)
    ################ capture by number for friendly = odd/black
    vcn_odd  = valid_captures_by_numbering_black(game_state, verbose = False)
    vcn_all = vcn_even + vcn_odd
    for xx in vcn_all:
        piece1 = {}
        piece2 = {}
        pc_attacker = xx[0]
        #print(pc_attacker, xx)
        pos_x = pc_attacker[0]
        pos_y = pc_attacker[1]
        pc_attacker_alg = GS[pos_x, pos_y]
        variables = pc_attacker_alg.variables()
        if C_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif T_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif S_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif P_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif c_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif t_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif s_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif p_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        pc_captured = xx[1]
        pos_x = pc_captured[0]
        pos_y = pc_captured[1]
        pc_captured_alg = GS[pos_x, pos_y]
        variables = pc_captured_alg.variables()
        if C_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif T_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif S_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif P_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif c_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif t_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif s_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif p_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        caps = {"friendly_piece": piece1, "enemy_piece": piece2, "capture_type": "number",
                "pre_move_capture": True, "post_move_capture": False}
        captures_total = captures_total + [caps]
    
    ################ capture by product/multiplication for friendly = even/white
    # in this case, capture record is list of pairs of the form
    #          [((7, 2), 9), ((7, 7), 36)]
    vcm_even = valid_captures_by_multiplication_white(game_state, verbose = False)
    ################ capture by product/multiplication for friendly = odd/black
    vcm_odd  = valid_captures_by_multiplication_black(game_state, verbose = False)
    vcm_all = vcm_even + vcm_odd
    for xx in vcm_all:
        piece1 = {}
        piece2 = {}
        pc_attacker = xx[0]
        #print(pc_attacker, xx)
        pos_x = pc_attacker[0][0]
        pos_y = pc_attacker[0][1]
        pc_attacker_alg = GS[pos_x, pos_y]
        variables = pc_attacker_alg.variables()
        if C_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif T_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif S_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif P_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif c_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif t_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif s_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif p_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        pc_captured = xx[1]
        pos_x = pc_captured[0][0]
        pos_y = pc_captured[0][1]
        pc_captured_alg = GS[pos_x, pos_y]
        variables = pc_captured_alg.variables()
        if C_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif T_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif S_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif P_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif c_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif t_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif s_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif p_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        caps = {"friendly_piece": piece1, "enemy_piece": piece2, "capture_type": "product",
                "pre_move_capture": True, "post_move_capture": False}
        captures_total = captures_total + [caps]
    
    ################ capture by factor/division for friendly = even/white
    # in this case, capture record is list of pairs of the form
    #          [((7, 2), 9), ((7, 7), 36)]
    vcd_even = valid_captures_by_division_white(game_state, verbose = False)
    ################ capture by factor/division for friendly = odd/black
    vcd_odd  = valid_captures_by_division_black(game_state, verbose = False)
    vcd_all = vcd_even + vcd_odd
    for xx in vcd_all:
        piece1 = {}
        piece2 = {}
        pc_attacker = xx[0]
        #print(pc_attacker, xx)
        pos_x = pc_attacker[0][0]
        pos_y = pc_attacker[0][1]
        pc_attacker_alg = GS[pos_x, pos_y]
        variables = pc_attacker_alg.variables()
        if C_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif T_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif S_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif P_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif c_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif t_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif s_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif p_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        pc_captured = xx[1]
        pos_x = pc_captured[0][0]
        pos_y = pc_captured[0][1]
        pc_captured_alg = GS[pos_x, pos_y]
        variables = pc_captured_alg.variables()
        if C_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif T_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif S_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif P_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif c_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif t_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif s_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif p_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        caps = {"friendly_piece": piece1, "enemy_piece": piece2, "capture_type": "factor",
                "pre_move_capture": True, "post_move_capture": False}
        captures_total = captures_total + [caps]

    ################ capture by siege/blocking for friendly = even/white
    # in this case, capture record only lists the captured piece, so it's of the form
    #          [((7, 2), 9)]
    vcb_even = valid_captures_by_siege_white(game_state, verbose = False)
    ################ capture by siege/blocking for friendly = odd/black
    vcb_odd  = valid_captures_by_siege_black(game_state, verbose = False)
    vcb_all = vcb_even + vcb_odd
    for xx in vcb_all:
        piece1 = {}
        piece2 = {}
        pc_captured = xx[0]
        shifts = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        #print(pc_attacker, xx)
        for dx, dy in shifts:
            pos_x = pc_captured[0] + dx
            pos_y = pc_captured[1] + dy
            if GS[pos_x, pos_y] != 0:
                pc_attacker_alg = GS[pos_x, pos_y]
                pc_attacker = [(pos_x, pos_y), value_of_piece(GS, pos_x, pos_y)]
        variables = pc_attacker_alg.variables()
        if C_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif T_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif S_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif P_var in variables:
            piece1["color"] = "even"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif c_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "circle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif t_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "triangle"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif s_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "square"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        elif p_var in variables:
            piece1["color"] = "odd"
            piece1["value"] = pc_attacker[1]
            piece1["shape"] = "pyramid"
            piece1["position"] = (pos_x, pos_y)
            piece1["algebraic"] = pc_attacker_alg
        pc_captured = xx[0]
        #print(pc_captured)
        pos_x = pc_captured[0]
        pos_y = pc_captured[1]
        pc_captured_alg = GS[pos_x, pos_y]
        variables = pc_captured_alg.variables()
        if C_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif T_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif S_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif P_var in variables:
            piece2["color"] = "even"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif c_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "circle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif t_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "triangle"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif s_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "square"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        elif p_var in variables:
            piece2["color"] = "odd"
            piece2["value"] = pc_captured[1]
            piece2["shape"] = "pyramid"
            piece2["position"] = (pos_x, pos_y)
            piece2["algebraic"] = pc_captured_alg
        caps = {"friendly_piece": piece1, "enemy_piece": piece2, "capture_type": "siege", "pre_move_capture": True, "post_move_capture": False}
        captures_total = captures_total + [caps]

    return captures_total


def turn_to_animation(game_state, pre_captures, move, post_captures, color, turn_number, frame_counter, verbose=False):
    """
    Animates a single, full turn by executing pre-captures, a move, and post-captures in sequence.
    This function now handles all state changes within the turn.


    A *turn* is a sequence of 3 actions, a pre-move capture(s), move, post-move capture(s), 
    where each capture in these lists must be of the format required for the capture_list_to_animation
    function. 
    In other words, it is a pair of the form
                     [attack_piece, captured_piece],
    where each piece list has the format
                         (loc_pc, val_pc, poly_pc),
    as explained in the above docstring for that function).
    For each such sequence, 
    1) pre-move captures -- creates 3 frames for each capture, using capture_list_to_animation,
    2) a move from the game state after the last capture -- creates 1 frame from the move,
    3) post-move captures from the game state after the move -- creates 3 frames for each capture.
    The color option (whose value can be "even" (for White/Even) or "odd" (for
    Black/Odd) should be consistent with the data in the turn lists.
    
    NOTE: In order to iterate this turn-by-turn it is necessary for this function to also return the 
    game_state after the turn (unless these have been precomputed and saved in a file).

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: precapture_list = []
        sage: postcapture_list = []
        sage: move = [(1,2), (1,4)]
        sage: turn_to_animation(GS, precapture_list, move, postcapture_list, color="even", turn_number=1, frame_counter=0)
         Turn 1 (even): Processing move from (1, 2) to (1, 4).
          - Generating move highlight frame: frame_000.png
         Board image saved to frame_000.png with a DPI of 300
          - Generating move complete frame: frame_001.png
         Board image saved to frame_001.png with a DPI of 300
         Turn 1 (even) complete. Total frames generated: 2
         <new game state matrix omitted)
	sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2, 13] = 0; GS[7, 3] = c^9; GS[1, 2] = 0; GS[1, 4] = T^(72)
        sage: precapture_list = [[((7,3), 9, c^9), ((7,2), 9, T^9)]]
        sage: move = [(1,13), (1,11)]
        sage: postcapture_list = [[((1,11), 12, t^(12)), ((1,4), 72, T^(72))]]
        sage: turn_to_animation(GS, precapture_list, move, postcapture_list, color="odd", turn_number=1, frame_counter=0, verbose=True)
         Turn 1 (odd): Animating 1 pre-move captures.
         Board image saved to /Users/davidjoyner/sagefiles/frame_000.png with a DPI of 300
         Board image saved to /Users/davidjoyner/sagefiles/frame_001.png with a DPI of 300
         Board image saved to /Users/davidjoyner/sagefiles/frame_002.png with a DPI of 300
         Turn 1 (odd): Animating move from n2 to l2.
         Board image saved to /Users/davidjoyner/sagefiles/frame_003.png with a DPI of 300
         Board image saved to /Users/davidjoyner/sagefiles/frame_004.png with a DPI of 300
         Turn 1 (odd): Animating 1 post-move captures.
         Board image saved to /Users/davidjoyner/sagefiles/frame_005.png with a DPI of 300
         Board image saved to /Users/davidjoyner/sagefiles/frame_006.png with a DPI of 300
         Board image saved to /Users/davidjoyner/sagefiles/frame_007.png with a DPI of 300
          <8x16 game state matrix omitted>

    """
    GS = copy(game_state)
    current_frame = frame_counter

    # 1. Animate and Execute Pre-Move Captures
    if pre_captures:
        if verbose: print(f"Turn {turn_number} ({color}): Animating {len(pre_captures)} pre-move captures.")
        for i, capture in enumerate(pre_captures):
            if capture is None: continue
            # This function internally updates the game state and returns the new state
            GS, frames_generated = capture_list_to_animation_enhanced(GS, capture, frame_start_index=current_frame)
            current_frame += frames_generated

    # 2. Animate and Execute the Move
    if move:
        start_pos, end_pos = move
        if verbose: print(f"Turn {turn_number} ({color}): Animating move from {coordinate_to_algebraic(*start_pos)} to {coordinate_to_algebraic(*end_pos)}.")
        
        # Check if move is legal on the current state before animating
        if GS[end_pos] != 0:
            if verbose: print(f"ANIMATION WARNING: Move to {coordinate_to_algebraic(*end_pos)} is blocked. Skipping move animation.")
        else:
            piece_to_move_alg = coordinate_to_algebraic(*start_pos)
            move_highlight_filename = os.path.join(SAGE_DIR, f"frame_{current_frame:03d}.png")
            display_board_matplotlib_enhanced(GS, dpi=300, highlight_pieces=[piece_to_move_alg], filename=move_highlight_filename)
            current_frame += 1
            
            GS = move_piece(GS, start_pos, end_pos, verbose=False)
            
            move_complete_filename = os.path.join(SAGE_DIR, f"frame_{current_frame:03d}.png")
            display_board_matplotlib_enhanced(GS, dpi=300, filename=move_complete_filename)
            current_frame += 1

    # 3. Animate and Execute Post-Move Captures
    if post_captures:
        if verbose: print(f"Turn {turn_number} ({color}): Animating {len(post_captures)} post-move captures.")
        for i, capture in enumerate(post_captures):
            if capture is None: continue
            GS, frames_generated = capture_list_to_animation_enhanced(GS, capture, frame_start_index=current_frame)
            current_frame += frames_generated
            
    return GS, current_frame


def animate_full_game(max_turns=40, move_strategy='good', log_filename="rithmomachia_log.txt", verbose=False):
    """
    Simulates a full game of Rithmomachia, turn by turn, and generates sequential image frames for animation.

    Args:
        max_turns (int): The maximum number of turns to simulate to prevent an infinite loop.
        move_strategy (str): The strategy for computer players ('good' or 'best'). 'good' is recommended for speed.
        log_filename (str): The path to the output log file.
        verbose (bool): If True, prints additional debug information to the console.
    """
    print("--- Starting Full Game Animation and Logging (Press Ctrl-C to stop early) ---")
    
    # --- Initialization ---
    current_gs = board_initial_matrix(pyramid_decomposition=True)
    game_history = []
    frame_counter = 0
    player_turn = "even"

    try:
        with open(log_filename, 'w') as log_file:
            log_file.write("Rithmomachia Game Log\n=====================\n\n")

            for turn_number in range(1, max_turns + 1):
                log_file.write(f"--- Turn {turn_number}: {player_turn.capitalize()}'s Move ---\n")
                if verbose: print(f"\n--- Turn {turn_number}: {player_turn.capitalize()}'s Move ---")

                # 1. Determine player-specific functions
                if player_turn == "even":
                    move_finder = good_move_white
                    capture_finder = legal_moves_captures_white
                    capture_taker = take_all_captures_white
                else:
                    move_finder = good_move_black
                    capture_finder = legal_moves_captures_black
                    capture_taker = take_all_captures_black
                
                # 2. Determine all actions for the turn sequentially
                pre_captures_raw = capture_finder(current_gs)[1]
                if verbose: print("List of pre-move captures:", pre_captures_raw)
                gs_after_pre_caps = capture_taker(current_gs, verbose=False)
                
                move = move_finder(gs_after_pre_caps, verbose=False)
                
                post_captures_raw = []
                if move:
                    if verbose: print(f"Move chosen: [{gs_after_pre_caps[move[0]]}, from {coordinate_to_algebraic(*move[0])} to {coordinate_to_algebraic(*move[1])}]")
                    gs_after_move = move_piece(gs_after_pre_caps, move[0], move[1])
                    post_captures_raw = capture_finder(gs_after_move)[1]
                
                if verbose: print("List of post-move captures:", post_captures_raw)

                # 3. Log all determined actions to the text file
                log_file.write("Pre-move Captures:\n")
                if not pre_captures_raw:
                    log_file.write("  None\n")
                else:
                    for cap in pre_captures_raw: log_file.write(f"  {format_capture_for_log(cap, current_gs)}\n")

                log_file.write("Move:\n")
                if not move:
                    log_file.write("  No legal moves available. Game over.\n")
                    print(f"No legal moves for {player_turn}. {('Odd' if player_turn == 'even' else 'Even')} wins.")
                    break
                else:
                    log_file.write(f"  [{gs_after_pre_caps[move[0]]}, from {coordinate_to_algebraic(*move[0])} to {coordinate_to_algebraic(*move[1])}]\n")
                
                log_file.write("Post-move Captures:\n")
                if not post_captures_raw:
                    log_file.write("  None\n")
                else:
                    for cap in post_captures_raw: log_file.write(f"  {format_capture_for_log(cap, gs_after_move)}\n")

                # 4. Call the animation function to execute the full turn
                gs_after_turn, frame_counter = turn_to_animation(
                    game_state=current_gs,
                    pre_captures=[reformat_capture_for_animation(c, current_gs) for c in pre_captures_raw if c],
                    move=move,
                    post_captures=[reformat_capture_for_animation(c, gs_after_move) for c in post_captures_raw if c],
                    color=player_turn,
                    turn_number=turn_number,
                    frame_counter=frame_counter,
                    verbose=verbose
                )
                
                current_gs = gs_after_turn
                
                # 5. Update game history list
                if move:
                    turn_data = {
                        "turn": turn_number, "player": player_turn, "pre_captures": pre_captures_raw,
                        "move": { "piece": str(gs_after_pre_caps[move[0]]), "start": coordinate_to_algebraic(*move[0]), "end": coordinate_to_algebraic(*move[1]) },
                        "post_captures": post_captures_raw
                    }
                    game_history.append(turn_data)
                
                log_file.write("\n")

                # 6. Check for Victory
                if is_body_common_victory_white(current_gs, verbose=verbose):
                    captured_by_white = captured_pieces_black(current_gs, pyramid_decomposition=True)
                    log_file.write("--- GAME OVER: White Wins (common victory, by body)! ---\n")
                    log_file.write(f"  (Captured Black pieces: {[str(p) for p in captured_by_white]})\n")
                    print("GAME OVER: White wins (common victory, by body)!")
                    break
                if is_small_proper_victory_white(current_gs):
                    log_file.write("--- GAME OVER: White Wins (small, proper victory)! ---\n")
                    print("GAME OVER: White wins (small, proper victory)!")
                    break
                if is_body_common_victory_black(current_gs, verbose=verbose):
                    captured_by_black = captured_pieces_white(current_gs, pyramid_decomposition=True)
                    log_file.write("--- GAME OVER: Black Wins (common victory, by body)! ---\n")
                    log_file.write(f"  (Captured White pieces: {[str(p) for p in captured_by_black]})\n")
                    print("GAME OVER: Black wins (common victory, by body)!")
                    break
                if is_small_proper_victory_black(current_gs):
                    log_file.write("--- GAME OVER: Black Wins (small, proper victory)! ---\n")
                    print("GAME OVER: Black wins (small, proper victory)!")
                    break
                
                player_turn = "odd" if player_turn == "even" else "even"

            if turn_number == max_turns:
                log_file.write(f"--- GAME OVER: Reached max turn limit of {max_turns}. ---\n")
                print(f"GAME OVER: Reached max turn limit of {max_turns}.")

    except KeyboardInterrupt:
        print(f"\n\n--- Game manually stopped by user. ---")
        print(f"Log file '{log_filename}' saved with progress up to the interruption.")
    
    finally:
        print(f"--- Animation Generation Finished. Total frames created: {frame_counter} ---")

    return game_history


def reformat_capture_for_animation(capture_data, gs):
    """
    Converts a raw capture record into the standardized format required by turn_to_animation.
    Format: [(loc_tuple, val, poly_str), (loc_tuple, val, poly_str)]
    """
    # This function is now more robust in identifying the capture type and extracting data.
    try:
        # Capture by Numbering: ((r,c,[v]), (r,c,[v]), poly, poly)
        if len(capture_data) == 5 and isinstance(capture_data[3], sage.symbolic.expression.Expression):
            attacker_info = capture_data[0]
            victim_info = capture_data[1]
            
            loc1 = (attacker_info[0], attacker_info[1])
            val1 = attacker_info[2][0]
            poly1 = capture_data[3]

            loc2 = (victim_info[0], victim_info[1])
            val2 = victim_info[2][0]
            poly2 = capture_data[4]
            
            return [(loc1, val1, poly1), (loc2, val2, poly2)]

        # Capture by Sum/Difference: [( (r,c), [v] ), ( (r,c), [v] ), ( (r,c), [v] )]
        elif len(capture_data) == 3 and isinstance(capture_data[0], tuple):
            loc1, val1 = capture_data[0][0], capture_data[0][1][0]
            loc2, val2 = capture_data[2][0], capture_data[2][1][0] # Victim is the 3rd element
            poly1, poly2 = gs[loc1], gs[loc2]
            return [(loc1, val1, poly1), (loc2, val2, poly2)]

        # Capture by Multiplication/Division: [((pos1, val1), (pos2, val2))]
        elif len(capture_data) == 2 and isinstance(capture_data[0], tuple):
            loc1, val1 = capture_data[0][0], capture_data[0][1]
            loc2, val2 = capture_data[1][0], capture_data[1][1]
            poly1, poly2 = gs[loc1], gs[loc2]
            return [(loc1, val1, poly1), (loc2, val2, poly2)]

    except (IndexError, TypeError) as e:
        print(f"Warning: Could not reformat capture data: {capture_data}. Error: {e}")
        return None

    return None # Return None if no known format matches


def format_capture_for_log(capture_data, gs):
    """
    Converts a raw capture record into a list formatted for a text log.
    Format: [capturing_piece_info, captured_piece_info, "descriptive_string"]
    """
    # Heuristic to guess capture type based on data structure
    # This logic is similar to reformat_capture_for_animation
    capture_type_info = "unknown"
    
    try:
        # Numbering Capture: e.g., ((r1, c1, [v1]), (r2, c2, [v2]), (r1, c1), C^36, t^36)
        if len(capture_data) == 5 and isinstance(capture_data[0], tuple):
            attacker_poly = capture_data[3]
            victim_poly = capture_data[4]
            return [f"{attacker_poly}", f"{victim_poly}", "by numbering"]

        # Sum/Difference Capture: e.g., [[(pos1, [v1]), (pos2, [v2]), (pos3, [v3])]]
        elif len(capture_data) == 3 and isinstance(capture_data[0], tuple):
            attacker1_poly = gs[capture_data[0][0]]
            attacker2_poly = gs[capture_data[1][0]]
            victim_poly = gs[capture_data[2][0]]
            # Determine if it's sum or difference based on values
            v1, v2, v3 = capture_data[0][1][0], capture_data[1][1][0], capture_data[2][1][0]
            op_type = "by addition" if v1 + v2 == v3 else "by subtraction"
            return [f"{attacker1_poly} and {attacker2_poly}", f"{victim_poly}", op_type]

        # Product/Division Capture: e.g., [((pos1, val1), (pos2, val2))]
        elif len(capture_data) == 2 and isinstance(capture_data[0], tuple):
            pos1, val1 = capture_data[0][0], capture_data[0][1]
            pos2, val2 = capture_data[1][0], capture_data[1][1]
            attacker_poly = gs[pos1]
            victim_poly = gs[pos2]
            dist = pieces_in_a_line(gs, pos1, pos2) ##  - 1
            op_type = "by multiplication" if val1 * dist == val2 else "by division"
            return [f"{attacker_poly}", f"{victim_poly}", f"{op_type}, with separation {dist}"]

        # Siege Capture: e.g., [((r, c), [v])]
        elif len(capture_data) == 1 and isinstance(capture_data[0], tuple):
            victim_poly = gs[capture_data[0][0]]
            return ["Surrounding pieces", f"{victim_poly}", "by siege"]
            
    except (IndexError, TypeError):
        # Fallback for unexpected formats
        return ["Unknown Attacker", "Unknown Victim", "with unknown capture type"]

    return ["-", "-", "unknown format"]