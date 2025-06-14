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
* each triple in this list has the form (pc_x, pc_y, val_pc), where 
  pc_x   -- the x-coordinate of the coordinate position of the piece on the game board (0 <= pc_x <= 7), 
  pc_y   -- the y-coordinate of the coordinate position of the piece on the game board (0 <= pc_y <= 15), 
  val_pc -- the value of the piece
* the first (friendlies) list is empty for siege, a singleton for captures by numbering, otherwise, 
  they could be lists of length 2.
* See c1, c2, c3, c4, c5, c6 in take_all_captures_black (below) for details on the format of 
  the capture notation.

Current programs:

* initialize_global_variables()    ### instead, use captured_pieces_black and captured_pieces_white

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
* whites_turn(game_state, method_best = True)                        ## changes game state
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
* valid_captures_by_mutliplication_black(game_state, verbose = False)
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
* list_arithmetical_patterns_white()
* list_geometrical_patterns_white()
* list_musical_patterns_white()
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
* value_of_piece(GS, i, j)
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
* coordinating_progression_count_odd(v)
* coordinating_progression_count_even(v)
* even_piece_values()
* odd_piece_values()
* coordinating_progression_pair_count_even(v1, v2)
* coordinating_progression_pair_count_odd(v1, v2)




REFERENCES:
 [Ri46] J.F.C. Richards, Boissiere’s Pythagorean game, Scripta Mathematica 12(1946)177-217.

last modified by wdj on 2025-06-07
"""

import itertools
import string
import random 
import matplotlib.pyplot as plt
import matplotlib.patches as patches



############### unused global constants #############
CIRCLE_MOVE_DIAGONAL = False
CIRCLE_MOVE_ORTHOGONAL = True
PYRAMID_DECOMPOSITION_SQUARES_ONLY = True
#####################################################

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
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GSp = move_piece(GSp, (6, 0), (3, 0))
        sage: board_plot2(GSp, pyramid=True)
        Launched png viewer for Graphics object consisting of 152 graphics primitives

    """
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

def display_board_matplotlib(game_state_sage_matrix):
    """
    Displays the Rithmomachia board using Matplotlib, based on a SageMath game state matrix.
    """
    # SageMath specific variables if needed for parsing game_state_sage_matrix
    # This might be needed if value_of_piece or positions_w/b expect them to be defined.
    #c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var = var("c,C,p,P,t,T,s,S")
    c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c_var, C_var, p_var, P_var, t_var, T_var, s_var, S_var]
    
    rows, cols = 8, 16
    fig, ax = plt.subplots(figsize=(16, 8)) # Or (cols, rows) for different aspect
    font_size = 10              ########  change to 8 if needed
    
    # --- 1. Draw Grid and Labels (adapted from rithmomachia_board_graphic.py) ---
    """       ################################# commented out
    for x in range(cols + 1): # Grid lines
        ax.plot([x, x], [0, rows], color='black', linewidth=0.7)
    for y in range(rows + 1):
        ax.plot([0, cols], [y, y], color='black', linewidth=0.7)
    for x_label in range(cols): # Column labels (a-p)
        ax.text(x_label + 0.5, rows + 0.3, chr(97 + x_label), 
                ha='center', va='center', fontsize=font_size, color='dimgray')
    for y_label_idx in range(rows): # Row labels (1-8, with row 0 being 8 or 1 visually)
        # Assuming game_state_sage_matrix[0,:] is the top visual row (label '8' or '1')
        # And matplotlib y=0 is bottom.
        # If row 0 in matrix is row "1" visually:
        # y_display_label = str(y_label_idx + 1)
        # y_mpl_pos_for_label = (rows - 1 - y_label_idx) + 0.5
        # If row 0 in matrix is row "8" visually (like in board_plot from procedural file [cite: 1388]):
        y_display_label = str(8 - y_label_idx)
        y_mpl_pos_for_label = y_label_idx + 0.5 # Matplotlib y for row 7, 6, ..0 (top to bottom)
        ax.text(-0.4, y_mpl_pos_for_label, y_display_label, 
                ha='center', va='center', fontsize=font_size, color='dimgray')
    """     ################################# commented out
    # Draw grid
    for x in range(cols):
        for y in range(rows):
            ax.add_patch(patches.Rectangle((x, rows - y - 1), 1, 1, fill=False, edgecolor='black'))
    # Axis labels
    for x in range(cols):
        ax.text(x + 0.5, rows + 0.2, chr(97 + x), ha='center', va='center', fontsize=10, color='purple')
    for y in range(rows):
        ax.text(-0.5, rows - y - 0.5, str(y + 1), ha='center', va='center', fontsize=10, color='purple')
    # Axis labels 2
    for x in range(cols):
        ax.text(x + 0.5, rows - 8.2, str(x), ha='center', va='center', fontsize=10, color='blue')
    for y in range(rows):
        ax.text(-0.5+17, rows - y - 0.5, str(y), ha='center', va='center', fontsize=10, color='blue')

    # --- 2. Extract and Prepare Piece Data from Sage Game State ---
    pieces_to_draw = [] # Will be a list of (x_mpl, y_mpl_row_origin, color, shape_mpl, value_str)

    # White pieces
    white_positions = positions_w(game_state_sage_matrix, verbose=True) # List of [((r,c), poly_piece)] [cite: 1389]
    for item in white_positions:
        pos_tuple, poly_piece = item[0], item[1]
        r_sage, c_sage = pos_tuple[0], pos_tuple[1]
        
        shape_mpl, color_mpl = get_piece_details_from_poly(poly_piece, 'green', 'red')
        val_list = value_of_piece(game_state_sage_matrix, r_sage, c_sage) # 
        # Sum values if it's a list from a pyramid, otherwise take the degree for simple pieces.
        # This matches how get_algebraic_move_string calculates display_val 
        display_val_num = sum(v for v in val_list if isinstance(v, (int, Integer))) if val_list else 0
        value_str = str(display_val_num)
        
        if shape_mpl != "unknown":
            # matplotlib y=0 is bottom. If sage matrix r_sage=0 is top:
            y_mpl_row_origin = rows - 1 - r_sage 
            pieces_to_draw.append((c_sage, y_mpl_row_origin, color_mpl, shape_mpl, value_str))

    # Black pieces
    black_positions = positions_b(game_state_sage_matrix, verbose=True) # [cite: 1389]
    for item in black_positions:
        pos_tuple, poly_piece = item[0], item[1]
        r_sage, c_sage = pos_tuple[0], pos_tuple[1]

        shape_mpl, color_mpl = get_piece_details_from_poly(poly_piece, 'green', 'red')
        val_list = value_of_piece(game_state_sage_matrix, r_sage, c_sage) # [cite: 2267]
        display_val_num = sum(v for v in val_list if isinstance(v, (int, Integer))) if val_list else 0
        value_str = str(display_val_num)

        if shape_mpl != "unknown":
            y_mpl_row_origin = rows - 1 - r_sage
            pieces_to_draw.append((c_sage, y_mpl_row_origin, color_mpl, shape_mpl, value_str))

    # --- 3. Draw Pieces (adapted from rithmomachia_board_graphic.py) ---
    for x_col, y_row_mpl, color, shape, value in pieces_to_draw:
        # x_col is the direct column index for matplotlib x-axis (0-15)
        # y_row_mpl is the matplotlib y-coordinate for the bottom of the cell (0-7)
        x_center = x_col + 0.5
        y_center = y_row_mpl + 0.5
        
        patch_to_add = None
        if shape == 'circle':
            patch_to_add = patches.Circle((x_center, y_center), 0.4, 
                                     facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'square':
            patch_to_add = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, 
                                        facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'triangle':
            # Point up: orientation=numpy_pi/3
            patch_to_add = patches.RegularPolygon((x_center, y_center-0.1), numVertices=3, 
                                             radius=0.45, orientation=2*numpy_pi/3, 
                                             facecolor=color, edgecolor='black', linewidth=0.5)
        elif shape == 'diamond' and color == "purple": # For pyramids
            big_square = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, facecolor="red", edgecolor='black', linewidth=0.5)
            little_square = patches.RegularPolygon((x_center, y_center), numVertices=4, radius=0.45, orientation=numpy_pi/4, facecolor=color, edgecolor='black', linewidth=0.5)
            ax.add_patch(big_square)
            ax.add_patch(little_square)
        elif shape == 'diamond' and color == "lime": # For pyramids
            big_square = patches.Rectangle((x_col + 0.1, y_row_mpl + 0.1), 0.8, 0.8, facecolor="green", edgecolor='black', linewidth=0.5)
            little_square = patches.RegularPolygon((x_center, y_center), numVertices=4, radius=0.45, orientation=numpy_pi/4, facecolor=color, edgecolor='black', linewidth=0.5)
            ax.add_patch(big_square)
            ax.add_patch(little_square)
        #print("000",x_col, y_row_mpl, color, shape, value)
        if patch_to_add:
            ax.add_patch(patch_to_add)
        if shape == "diamond" and color == "purple":
            f = PR(game_state_sage_matrix[7-y_row_mpl, x_col])
            if (s_var in f.variables()):
                val_piece = [v[6] for v in f.exponents() if not(v[6]==0)]
                #print("111a",x_col, y_row_mpl, color, shape, value, val_piece, game_state_sage_matrix[7 - y_row_mpl, x_col])
            ax.text(x_center, y_center + 0.2, str(val_piece[:2]), ha='center', va='center', color='white', fontsize=6, weight='bold')
            ax.text(x_center, y_center + 0.05, str(val_piece[2:]), ha='center', va='center', color='white', fontsize=6, weight='bold')
        if shape == "diamond" and color == "lime":
            f = PR(game_state_sage_matrix[7-y_row_mpl, x_col])
            if (S_var in f.variables()):
                val_piece = [v[7] for v in f.exponents() if not(v[7]==0)]
                #print("111b",x_col, y_row_mpl, color, shape, value, val_piece, game_state_sage_matrix[7 - y_row_mpl, x_col])
            #print("222",x_col, y_row_mpl, color, shape, value, val_piece, (7-y_row_mpl, x_col), game_state_sage_matrix[7 - y_row_mpl, x_col])
            ax.text(x_center, y_center + 0.2, str(val_piece[:2]), ha='center', va='center', color='black', fontsize=6, weight='bold')
            ax.text(x_center, y_center + 0.05, str(val_piece[2:]), ha='center', va='center', color='black', fontsize=6, weight='bold')
        
        text_color = 'white' if color in ['red', 'purple', 'black', 'dimgray'] else 'black'
        ax.text(x_center, y_center-0.1, value, ha='center', va='center', 
                color=text_color, fontsize=font_size, weight='bold')

    # --- 4. Adjust Display and Show ---
    ax.set_xlim(-0.5, cols + 0.5) # Adjusted limits for labels
    ax.set_ylim(-0.5, rows + 0.5)
    ax.set_aspect('equal', adjustable='box')
    ax.axis('off')
    fig.tight_layout()
    #plt.show()
    #fig, ax = plt.subplots()
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
        sage: captured_initially = captured_pieces_white(GS)
        sage: len(captured_initially)
         0
        sage: GS = capture_piece(GS, (7,2)) # Capture T^9 initially at (7,2)
        sage: captured_now = captured_pieces_white(GS)
        sage: len(captured_now)
         1
        sage: captured_now
         [((7, 2), T^9)]
        sage: GS = move_piece(GS, (6, 0), (3, 0)) # Move S^15, shouldn't count as capture
        sage: captured_after_move = captured_pieces_white(GS)
        sage: len(captured_after_move) # Should still be 1
         1
        sage: captured_after_move
         [((7, 2), T^9)] # Only T^9 is captured

    """
    ## NEW CODE suggested by gemini based on old buggy code
    GS = copy(game_state)
    # Generate the initial board state with the same decomposition setting
    initial_GS = board_initial_matrix(pyramid_decomposition=pyramid_decomposition) # Use passed flag
    # Get list of piece symbols (not positions) for initial and current states
    initial_pieces = [item[1] for item in positions_w(initial_GS, verbose=True)]
    current_pieces = [item[1] for item in positions_w(GS, verbose=True)]
    # Use collections.Counter for efficient counting
    from collections import Counter
    initial_counts = Counter(initial_pieces)
    current_counts = Counter(current_pieces)
    captured_pieces = []
    # Iterate through the unique pieces present initially
    for piece, initial_count in initial_counts.items():
        current_count = current_counts.get(piece, 0) # Get count from current state, default to 0 if absent
        num_captured = initial_count - current_count
        # Add the piece to the results list for each one captured
        if num_captured > 0:
            captured_pieces.extend([piece] * num_captured)
    # Optional: Sort the result if a specific order is desired, though not strictly necessary
    # captured_pieces.sort(key=lambda poly: poly.degree()) # Example sort by value
    return captured_pieces
    
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
    ## NEW CODE suggested by gemini based on old buggy code
    GS = copy(game_state)
    # Generate the initial board state with the same decomposition setting
    initial_GS = board_initial_matrix(pyramid_decomposition=pyramid_decomposition) # Use passed flag
    # Get list of piece symbols (not positions) for initial and current states
    initial_pieces = [item[1] for item in positions_b(initial_GS, verbose=True)]
    current_pieces = [item[1] for item in positions_b(GS, verbose=True)]
    # Use collections.Counter for efficient counting
    from collections import Counter
    initial_counts = Counter(initial_pieces)
    current_counts = Counter(current_pieces)
    captured_pieces = []
    # Iterate through the unique pieces present initially
    for piece, initial_count in initial_counts.items():
        current_count = current_counts.get(piece, 0) # Get count from current state, default to 0 if absent
        num_captured = initial_count - current_count
        # Add the piece to the results list for each one captured
        if num_captured > 0:
            captured_pieces.extend([piece] * num_captured)
    # Optional: Sort the result if a specific order is desired, though not strictly necessary
    # captured_pieces.sort(key=lambda p: p.degree()) # Example sort by value
    return captured_pieces


def capture_piece(game_state, capturing_pc_value, captured_pos, verbose=False):    ### cap_pos = captured_pos
#def capture_piece(game_state, cap_pos, verbose=False):
    """
    identify piece at cap_pos (piece, value, color) then 
    (1) remove it from the game-board (ie, game_state), 
    #(2) remove it from from active_pieces_white (if piece is White's)
    #or active_pieces_black (if piece is Black's), 
    #(3) add it to captured_pieces_white (if piece is White's) or
    #captured_pieces_black (if piece is Black's)

    ###### new code suggested by gemini was added

    ######################### BUG if the captured piece is a subpiece/compoent of a pyramid
    ######################### In this case, change the value(s) of the Pyramid but
    ######################### do *NOT* remove.    FIX THIS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS = capture_piece(GS, [9], (7,2)) # Capture T^9 initially at (7,2)
        sage: captured_pieces_black(GS, pyramid_decomposition=True)
	 []
        sage: captured_pieces_white(GS, pyramid_decomposition=True)
         [T^9]

    """
    GS = copy(game_state)
    i0 = captured_pos[0]
    j0 = captured_pos[1]
    #i0 = cap_pos[0]
    #j0 = cap_pos[1]
    if not(in_bounds((i0, j0))):
        if verbose:
            print("Coordinate out of bounds, so no capture.")
        return GS
    #print("000 capture_piece ", i0, j0)
    cap_pos_tuple = tuple(captured_pos) # Use tuple for consistency if needed elsewhere
    # Determine piece color *before* modifying lists based on initial GS state
    pc = GS[i0, j0]
    if pc == 0:
        if verbose:
            print("No piece, so no capture.")
        return GS
    vars_pc = pc.variables()
    is_white = (C in vars_pc) or (T in vars_pc) or (S in vars_pc) or (P in vars_pc)
    is_black = (c in vars_pc) or (t in vars_pc) or (s in vars_pc) or (p in vars_pc)
    #     Find the item to add to captured list based on coordinate
    captured_item = None
    active_pieces_white = positions_w(GS, verbose=True) 
    active_pieces_black = positions_b(GS, verbose=True) 
    if is_white:
        for item in active_pieces_white:
            if item[0] == cap_pos_tuple:
                captured_item = item
                break
    elif is_black:
        for item in active_pieces_black:
            if item[0] == cap_pos_tuple:
                captured_item = item
                break
    if captured_item: # Only proceed if found
        # Set board position to 0, but *ONLY* if the piece is not a pyramid
        # In case of pyramid DO NOT remove but change the value(s) of the pyramid
        ###################################### FIXING THIS!!!
        if not(p in vars_pc) and not(P in vars_pc):
            GS[i0, j0] = 0
        elif (p in vars_pc) or (P in vars_pc):
            cap_pc_values = capturing_pc_value     ######## this is a list, since the pyramid is multivalued
            pc_values = value_of_piece(GS, i0, j0)
            common_value = list(Set(cap_pc_values).intersection(Set(pc_values)))[0]
            if p in vars_pc:
                GS[i0,j0] = GS[i0,j0] - s^(common_value)
            if P in vars_pc:
                GS[i0,j0] = GS[i0,j0] - S^(common_value)
        ############################### STILL FIXING THIS!!!
        if is_white:
            #captured_pieces_white.append(captured_item)
            # Filter out the captured piece from active list by coordinate
            #active_pieces_white = [item for item in active_pieces_white if item[0] != cap_pos_tuple]
            if verbose:
                 print(f"Captured piece at {cap_pos_tuple} is White: {captured_item[1]}") # Use captured_item[1] for piece info
        elif is_black:
            #captured_pieces_black.append(captured_item)
             # Filter out the captured piece from active list by coordinate
            #active_pieces_black = [item for item in active_pieces_black if item[0] != cap_pos_tuple]
            if verbose:
                print(f"Captured piece at {cap_pos_tuple} is Black: {captured_item[1]}") # Use captured_item[1] for piece info
        else:
            # This case should ideally not be reached if pc != 0 and is_white/is_black logic is correct
            print(f"Warning: Could not determine color for piece {pc} at {cap_pos_tuple}")
    else:
        print(f"Warning: Piece at {cap_pos_tuple} not found in active lists.")
    return GS


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
    
    QUESTION: Should the pyramid be broken down first?

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: positions_w(GS)
        [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2), (2, 1), (2, 2), 
         (2, 3), (3, 1), (3, 2), (3, 3), (4, 1), (4, 2), (4, 3), (5, 1),
         (5, 2), (5, 3), (6, 0), (6, 1), (6, 2), (7, 0), (7, 1), (7, 2)]
        sage: positions_w(GS, verbose = True)
         [[(0, 0), S^289], [(0, 1), S^153], [(0, 2), T^81], [(1, 0), S^169], 
          [(1, 1), P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S], [(1, 2), T^72], [(2, 1), T^49], 
          [(2, 2), C^64], [(2, 3), C^8], [(3, 1), T^42], [(3, 2), C^36], [(3, 3), C^6], [(4, 1), T^20], 
          [(4, 2), C^16], [(4, 3), C^4], [(5, 1), T^25], [(5, 2), C^4], [(5, 3), C^2], [(6, 0), S^81], [(6, 1), S^45], 
          [(6, 2), T^6], [(7, 0), S^25], [(7, 1), S^15], [(7, 2), T^9]]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: positions_w(GSp, verbose=True)
       

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = PR(A[i,j])
            vars = g.variables()
            #print(g, P in vars, vars, i, j) ##  g.degree(P) = ??
            #if len(vars)>0 and (P in vars):
            #    print(g, vars, i, j,  g.degree(PR(P)))
            if (C in vars) or (T in vars) or (S in vars) or (P in vars):
                if verbose and not(g in pos):
                    pos = pos + [[(i, j), g]]
                if not(verbose) and not(g in pos):
                    pos = pos + [(i, j)]
    return pos

def positions_b(game_state, verbose = False):
    """
    If GS is a game state matrix then this function returns
    all values and matrix coordinates of black pieces.
    
    QUESTION: Should the pyramid be broken down first?

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: pos_b = positions_b(GS); len(pos_b)
        24
        sage: positions_b(GS, verbose = True)
        [(t^16, 0, 13), (s^28, 0, 14), (s^49, 0, 15), (t^12, 1, 13),
         (s^66, 1, 14), (s^121, 1, 15), (c^3, 2, 12), (c^9, 2, 13),
         (t^36, 2, 14), (c^5, 3, 12), (c^25, 3, 13), (t^30, 3, 14),
         (c^7, 4, 12), (c^49, 4, 13), (t^56, 4, 14), (c^9, 5, 12),
         (c^81, 5, 13), (t^64, 5, 14), (t^90, 6, 13), (s^120, 6, 14),
         (s^225, 6, 15), (t^100, 7, 13), (s^190 + p, 7, 14), (s^361, 7, 15)]

    """
    GS = copy(game_state)
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    A = M(GS)
    pos = []
    for i in range(8):
        for j in range(16):
            g = PR(A[i,j])
            #print(g)
            vars = g.variables()
            if (c in vars) or (t in vars) or (s in vars) or (p in vars):
                if verbose and not(g in pos):
                    pos = pos + [[(i, j), g]]
                if not(verbose) and not(g in pos):
                    pos = pos + [(i, j)]
    return pos

############################################
## The default is MOVES_CIRCLE_DIAGONAL = False.
## If MOVES_CIRCLE_DIAGONAL = True:
## rename moves_circle_white and moves_circle_black as
## moves_circle_white2 and moves_circle_black2, and then
## With this name change, the circle moves are diagonal
###########################################

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
    cpw = circle_positions_white(GS, verbose = False)
    cpw0 = circle_positions_white(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    circle_move_increments = [[1, 0], [-1, 0], [0, 1], [0, -1]]  ## MOVES_CIRCLE_ORTHOGONAL = True
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

def moves_circle_black(game_state, verbose = False):
    """
    Given the game state matrix, GS, this function returns all 
    coordinates for which black has a legal circle move.

    CIRCLE_MOVE_ORTHOGONAL = True

    EXAMPLES:
        sage: GS = board_initial_matrix()
        sage: moves_circle_black(GS, verbose = True)
         [(c^3, (2, 12), (1, 12)), (c^9, (5, 12), (6, 12))]
        

    """
    GS = copy(game_state)
    cpb = circle_positions_black(GS, verbose = False)
    cpb0 = circle_positions_black(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    circle_move_increments = [[1, 0], [-1, 0], [0, 1], [0, -1]]  ## MOVES_CIRCLE_ORTHOGONAL = True
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
    tpw  = triangle_positions_white(GS, verbose = False)
    tpw0 = triangle_positions_white(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    mvs = []
    for x in tpw:
        #print(x, x[0], x[1])
        x_new = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)]
        x_no = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a triangle
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no[ii]
            #print(x, x0, x in pos, x0 in pos)
            if not(x0 in pos) and not(x1 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and not(x1 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                jj = tpw.index(x)
                mvs = mvs + [(tpw0[jj][0], x, x0)]
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
    tpb  = triangle_positions_black(GS, verbose = False)
    tpb0 = triangle_positions_black(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    mvs = []
    for x in tpb:
        #print(x, x[0], x[1])
        x_new = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)]
        x_no = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a triangle
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no[ii]
            #print(x, x0, x in pos, x0 in pos)
            if not(x0 in pos) and not(x1 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and not(x1 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                jj = tpb.index(x)
                mvs = mvs + [(tpb0[jj][0], x, x0)]
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
    spw  = square_positions_white(GS, verbose = False)
    spw0 = square_positions_white(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    mvs = []
    for x in spw:
        #print(x, x[0], x[1])
        x_new = [(x[0]+3, x[1]), (x[0]-3, x[1]), (x[0], x[1]-3), (x[0], x[1]+3)]
        x_no1 = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a square
        x_no2 = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)] ## can't jump over a piece using a square
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            #print(x, x0, x in pos, x0 in pos)
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                jj = spw.index(x)
                mvs = mvs + [(spw0[jj][0], x, x0)]
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
    spb  = square_positions_black(GS, verbose = False)
    spb0 = square_positions_black(GS, verbose = True)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    mvs = []
    for x in spb:
        #print(x, x[0], x[1])
        x_new = [(x[0]+3, x[1]), (x[0]-3, x[1]), (x[0], x[1]-3), (x[0], x[1]+3)]
        x_no1 = [(x[0]+1, x[1]), (x[0]-1, x[1]), (x[0], x[1]-1), (x[0], x[1]+1)] ## can't jump over a piece using a square
        x_no2 = [(x[0]+2, x[1]), (x[0]-2, x[1]), (x[0], x[1]-2), (x[0], x[1]+2)] ## can't jump over a piece using a square
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            #print(x, x0, x in pos, x0 in pos)
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and not(verbose) and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and verbose and not(x0[0]<0) and not(x0[0]>7) and not(x0[1]<0) and not(x0[1]>15):
                jj = spb.index(x)
                mvs = mvs + [(spb0[jj][0], x, x0)]
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
    ppb  = pyramid_positions_black(GS, verbose = False)
    ppb0 = pyramid_positions_black(GS, verbose = True)
    i = ppb[0][0]
    j = ppb[0][1]
    g = GS[i,j]
    #print(g)
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    vars = g.variables()
    #print(vars)
    square_move_increments = [[3, 0], [-3, 0], [0, 3], [0, -3]]  
    square_move_subincrements1 = [[1, 0], [-1, 0], [0, 1], [0, -1]]  
    square_move_subincrements2 = [[2, 0], [-2, 0], [0, 2], [0, -2]]  
    mvs = []
    for x in ppb:
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in square_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements1 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no2 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements2 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and not(verbose):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and verbose:
                jj = ppb.index(x)
                mvs = mvs + [(ppb0[jj][0], x, x0)]
    return mvs


def moves_pyramid_white(game_state, verbose = False):
    """
    Given the game state matrix, this function returns all 
    coordinates for which White has a legal pyramid move.

    PYRAMID_DECOMPOSITION_SQUARES_ONLY = True

    EXAMPLES:
	sage: GSp = board_initial_matrix(pyramid_decomposition = True)   
        sage: moves_pyramid_white(GSp, verbose = True)                 
        []

    """
    GS = copy(game_state)
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
    square_move_increments = [[3, 0], [-3, 0], [0, 3], [0, -3]]  
    square_move_subincrements1 = [[1, 0], [-1, 0], [0, 1], [0, -1]]  
    square_move_subincrements2 = [[2, 0], [-2, 0], [0, 2], [0, -2]]  
    mvs = []
    for x in ppw:
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in square_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements1 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no2 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements2 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and not(verbose):
                mvs = mvs + [(x, x0)]
            if not(x0 in pos) and not(x1 in pos) and not(x2 in pos) and verbose:
                jj = ppw.index(x)
                mvs = mvs + [(ppw0[jj][0], x, x0)]
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
    cpw = circle_positions_white(GS, verbose = False)
    cpw0 = circle_positions_white(GS, verbose = True)                     ## don't need piece symbolically, only value(s)
    cpw00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in cpw]    ## <--- use instead
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    cps = []
    circle_move_increments = [[1, 0], [-1, 0], [0, 1], [0, -1]]  ## MOVES_CIRCLE_ORTHOGONAL = True
    for x in cpw:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in circle_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        for x0 in x_new:
            in_bds = in_bounds(x0)  ## a Boolean value
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #cps = cps + []
            #print(x, x0, x in pos, x0 in pos, value_of_piece(GS, x[0], x[1]), value_of_piece(GS, x0[0], x0[1]))
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_b) and values_match and not(verbose) and in_bds: 
                ii = cpw.index(x)
                x1 = (x[0], x[1], cpw00[ii][2])
                x01 = (x0[0], x0[1], cpw00[ii][2])
                cps = cps + [(x1, x01)]                                                    
            if (x0 in pos_b) and values_match and verbose and in_bds:  
                ii = cpw.index(x)
                x1 = (x[0], x[1], cpw00[ii][2])
                x01 = (x0[0], x0[1], cpw00[ii][2])
                cps = cps + [(x1, x01, cpw0[ii][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]    
            continue                         
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
    cpb  = circle_positions_black(GS, verbose = False)
    cpb0 = circle_positions_black(GS, verbose = True)                   ## don't need piece symbolically, only value(s)
    cpb00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in cpb]    ## <--- use instead
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    cps = []
    circle_move_increments = [[1, 0], [-1, 0], [0, 1], [0, -1]]  ## MOVES_CIRCLE_ORTHOGONAL = True
    for x in cpb:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in circle_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        for x0 in x_new:
            in_bds = in_bounds(x0)  ## a Boolean value
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #cps = cps + []
            #print(x, x0, x in pos, x0 in pos, value_of_piece(GS, x[0], x[1]), value_of_piece(GS, x0[0], x0[1]))
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_w) and values_match and not(verbose) and in_bds: 
                ii = cpb.index(x)
                x1 = (x[0], x[1], cpb00[ii][2])
                x01 = (x0[0], x0[1], cpb00[ii][2])
                cps = cps + [(x1, x01)]                                           
                #cps = cps + [(x, x0)]
            if (x0 in pos_w) and values_match and verbose and in_bds:  
                ii = cpb.index(x)
                x1 = (x[0], x[1], cpb00[ii][2])
                x01 = (x0[0], x0[1], cpb00[ii][2])
                cps = cps + [(x1, x01, cpb0[ii][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #ii = cpb.index(x)
                #cps = cps + [(cpb0[ii][0], x, x0)]
            continue
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
    tpw  = triangle_positions_white(GS, verbose = False)
    tpw0 = triangle_positions_white(GS, verbose = True)     ## don't need piece symbolically, only value(s)
    tpw00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in tpw]    ## <--- use instead
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    cps = []
    PS1 = [(1,0),(-1,0),(0,1),(0,-1)]
    PS2 = [(2,0),(-2,0),(0,2),(0,-2)]
    for x in tpw:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in PS2 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 =[(x[0]+a[0], x[1]+a[1]) for a in PS1 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            in_bds = in_bounds(x0)
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #cps = cps + []
            #print(x, x0, x in pos, x0 in pos, value_of_piece(GS, x[0], x[1]), value_of_piece(GS, x0[0], x0[1]), in_bds)
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_b) and not(x1 in pos) and values_match and not(verbose) and in_bds:
                ii = tpw.index(x)
                x1 = (x[0], x[1], tpw00[ii][2])
                x01 = (x0[0], x0[1], tpw00[ii][2])
                cps = cps + [(x1, x01)]                                           
                #print("0000")
                #cps = cps + [(x, x0)]
            if (x0 in pos_b) and not(x1 in pos) and values_match and verbose and in_bds:
                ii = tpw.index(x)
                x1 = (x[0], x[1], tpw00[ii][2])
                x01 = (x0[0], x0[1], tpw00[ii][2])
                cps = cps + [(x1, x01, tpw0[ii][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #print("0001")
                #ii = tpw.index(x)
                #cps = cps + [(tpw0[ii][0], x, x0)]
            continue
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
    tpb  = triangle_positions_black(GS, verbose = False)
    tpb0 = triangle_positions_black(GS, verbose = True)     ## don't need piece symbolically, only value(s)
    tpb00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in tpb]    ## <--- use instead
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    cps = []
    PS1 = [(1,0),(-1,0),(0,1),(0,-1)]
    PS2 = [(2,0),(-2,0),(0,2),(0,-2)]
    for x in tpb:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in PS2 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in PS1 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        for x0 in x_new:
            ii = x_new.index(x0)    ## that is, x0 = x_new[ii]
            x1 = x_no1[ii]
            in_bds = in_bounds(x0)
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #cps = cps + []
            #print(x, x0, x in pos, x0 in pos, value_of_piece(GS, x[0], x[1]), value_of_piece(GS, x0[0], x0[1]), in_bds)
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_w) and not(x1 in pos) and values_match and not(verbose) and in_bds:
                jj = tpb.index(x)
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01)]                                           
                #print("0000")
                #cps = cps + [(x, x0)]
            if (x0 in pos_w) and not(x1 in pos) and values_match and verbose and in_bds:
                #print(x, x0, x0 in pos, x1, not(x1 in pos), vpc_x, vpc_x0)
                jj = tpb.index(x)
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01, tpb0[jj][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #print("0001")
                #ii = tpb.index(x)
                #cps = cps + [(tpb0[ii][0], x, x0)]
            continue
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
    spw  = square_positions_white(GS, verbose = False)
    spw0 = square_positions_white(GS, verbose = True)   ## don't need piece symbolically, only value(s)
    spw00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in spw]    ## <--- use instead
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    cps = []
    PS3 = [(3,0),(-3,0),(0,-3),(0,3)]
    PS2 = [(2,0),(-2,0),(0,-2),(0,2)]
    PS1 = [(1,0),(-1,0),(0,-1),(0,1)]
    for x in spw:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in PS3 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in PS1 if in_bounds([x[0]+a[0], x[1]+a[1]])]   ## can't jump over a piece using a square
        x_no2 = [(x[0]+a[0], x[1]+a[1]) for a in PS2 if in_bounds([x[0]+a[0], x[1]+a[1]])] ## can't jump over a piece using a square
        for x0 in x_new:
            ii = x_new.index(x0)              ## that is, x0 = x_new[ii]
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            in_bds = in_bounds(x0) and in_bounds(x1) and in_bounds(x2)
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #cps = cps + []
            #print(x, x0, x in pos, x0 in pos, value_of_piece(GS, x[0], x[1]), value_of_piece(GS, x0[0], x0[1]), in_bds)
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_b) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and not(verbose):
                jj = spw.index(x)             ## that is, x = spw[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01)]                                           
                #print("0000", x0, (x0 in pos_b), x1, not(x1 in pos), x2, not(x2 in pos))
                #cps = cps + [(x, x0)]
            if (x0 in pos_b) and values_match and verbose and in_bds and not(x1 in pos) and not(x2 in pos):
                jj = spw.index(x)
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01, spw0[jj][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #print("0001")
                #print("0001", x0, (x0 in pos_b), x1, not(x1 in pos), x2, not(x2 in pos))
                #ii = spw.index(x)
                #cps = cps + [(spw0[ii][0], x, x0)]
            continue
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
    spb  = square_positions_black(GS, verbose = False)
    spb0 = square_positions_black(GS, verbose = True) ## don't need piece symbolically, only value(s)
    spb00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in spb]    ## <--- use instead
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    #print(pos)
    square_move_increments = [[3, 0], [-3, 0], [0, 3], [0, -3]]  
    square_move_subincrements1 = [[1, 0], [-1, 0], [0, 1], [0, -1]]  
    square_move_subincrements2 = [[2, 0], [-2, 0], [0, 2], [0, -2]]  
    cps = []
    PS = [(3,0),(-3,0),(0,-3),(0,3)]
    for x in spb:
        #print(x, x[0], x[1])
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in square_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements1 if in_bounds([x[0]+a[0], x[1]+a[1]])] ## can't jump over a piece 
        x_no2 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements2 if in_bounds([x[0]+a[0], x[1]+a[1]])] ## can't jump over a piece 
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)     ## that is, x0 = x_new[ii]
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            in_bds = in_bounds(x0) and in_bounds(x1) and in_bounds(x2)
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #cps = cps + []
            #print(x, x0, x in pos, x0 in pos, value_of_piece(GS, x[0], x[1]), value_of_piece(GS, x0[0], x0[1]), in_bds)
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_w) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and not(verbose):
                jj = spb.index(x)             ## that is, x = spb[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01)]                                           
                #print("0000")
                #cps = cps + [(x, x0)]
            if (x0 in pos_w) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and verbose:
                jj = spb.index(x)           ## that is, x = spb[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01, spb0[jj][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #print("0001")
                #jj = spb.index(x)
                #cps = cps + [(spb0[jj][0], x, x0)]
            continue
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
       sage: GSp = board_initial_matrix(pyramid_decomposition = True)
       sage: GS = copy(GSp)
       sage: GS[3,5] = p^190 + s^64 + s^49 + s^36 + s^25 + s^16
       sage: GS[3,3] = 0
       sage: GS[7,14] = 0
       sage: captures_pyramid_black(GS, verbose = True)
       [((3, 5, [64, 49, 36, 25, 16]), (3, 2, 36), (3, 5))]
       sage: 

    """
    GS = copy(game_state)
    ppb  = pyramid_positions_black(GS, verbose = False)
    ppb0 = pyramid_positions_black(GS, verbose = True)          ## don't need piece symbolically, only value(s)
    ppb00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in ppb]    ## <--- use instead
    #print(ppb,ppb0)
    i = ppb[0][0]
    j = ppb[0][1]
    g = GS[i,j]
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    vars = g.variables()
    #print(vars)
    square_move_increments = [[3, 0], [-3, 0], [0, 3], [0, -3]]  
    square_move_subincrements1 = [[1, 0], [-1, 0], [0, 1], [0, -1]]  
    square_move_subincrements2 = [[2, 0], [-2, 0], [0, 2], [0, -2]]  
    cps = []
    for x in ppb:
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in square_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements1 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no2 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements2 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            in_bds = in_bounds(x0) and in_bounds(x1) and in_bounds(x2)
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #print(x0, value_of_piece(GS, x0[0], x0[1]), x, g,(x0 in pos_w),not(x1 in pos), not(x2 in pos))
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_w) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and not(verbose):
                jj = ppb.index(x)             ## that is, x = ppb[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01)]                                           
                #print("0000")
                #cps = cps + [(x, x0)]
            if (x0 in pos_w) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and (verbose):
                jj = ppb.index(x)           ## that is, x = ppb[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01, ppb0[jj][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #print("0000")
                #cps = cps + [(x, x0)]
                #jj = ppb.index(x)
                #cps = cps + [(ppb0[jj][0], x, x0)]
            continue
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
    ppw  = pyramid_positions_white(GS, verbose = False)
    ppw0 = pyramid_positions_white(GS, verbose = True)         ## don't need piece symbolically, only value(s)
    ppw00 = [(x[0], x[1], value_of_piece(GS, x[0], x[1])) for x in ppw]    ## <--- use instead
    #print(ppw,ppw0)
    i = ppw[0][0]
    j = ppw[0][1]
    g = GS[i,j]
    pos_w = positions_w(GS)
    pos_b = positions_b(GS)
    pos = pos_w + pos_b
    vars = g.variables()
    square_move_increments = [[3, 0], [-3, 0], [0, 3], [0, -3]]  
    square_move_subincrements1 = [[1, 0], [-1, 0], [0, 1], [0, -1]]  
    square_move_subincrements2 = [[2, 0], [-2, 0], [0, 2], [0, -2]]  
    cps = []
    for x in ppw:
        x_new = [(x[0]+a[0], x[1]+a[1]) for a in square_move_increments if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no1 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements1 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no2 = [(x[0]+a[0], x[1]+a[1]) for a in square_move_subincrements2 if in_bounds([x[0]+a[0], x[1]+a[1]])]
        x_no = x_no1 + x_no2
        for x0 in x_new:
            ii = x_new.index(x0)
            x1 = x_no1[ii]
            x2 = x_no2[ii]
            in_bds = in_bounds(x0) and in_bounds(x1) and in_bounds(x2)
            vpc_x = value_of_piece(GS, x[0], x[1])
            vpc_x0 = value_of_piece(GS, x0[0], x0[1])
            #print(x0, value_of_piece(GS, x0[0], x0[1]), x,(x0 in pos_w),not(x1 in pos), not(x2 in pos))
            values_match = any(v in vpc_x0 for v in vpc_x) or any(v in vpc_x for v in vpc_x0)
            if (x0 in pos_b) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and not(verbose):
                jj = ppw.index(x)             ## that is, x = ppw[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01)]                                           
                #print("0000")
                #cps = cps + [(x, x0)]
            if (x0 in pos_b) and values_match and in_bds and not(x1 in pos) and not(x2 in pos) and (verbose):
                jj = ppw.index(x)           ## that is, x = ppw[jj]
                x1 = (x[0], x[1], vpc_x)
                x01 = (x0[0], x0[1], vpc_x0)
                cps = cps + [(x1, x01, ppw0[jj][0], GS[x[0], x[1]], GS[x0[0], x0[1]])]  
                #print("0000")
                #cps = cps + [(x, x0)]
                #jj = ppw.index(x)
                #cps = cps + [(ppw0[jj][0], x, x0)]
            continue
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
        [((2, 15, [36]), (2, 14, [36]), (2, 15))]
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2, 15] = C^(36); GS[3, 2] = 0; GS[5, 15] = C^(64); GS[2, 2] = 0
        sage: valid_captures_by_numbering_white(GS)
         [((2, 15, [36]), (2, 14, [36]), (2, 15)),
          ((5, 15, [64]), (5, 14, [64]), (5, 15))]

    """
    GS = copy(game_state)
    L = captures_circle_white(GS, verbose = True) + captures_triangle_white(GS, verbose = True) + captures_square_white(GS, verbose = True)  + captures_pyramid_white(GS, verbose = True) 
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
    i0 = pc_pos[0]
    j0 = pc_pos[1]
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    M = Mat(PR, 8, 16)
    pc = GS[i0, j0]
    if pc == 0:
        print("No piece, so no moves.")
        return []
    vars = pc.variables()
    posw = positions_w(GS)
    posb = positions_b(GS)
    mvs = []
    #print("000", pc, "\n", pc_pos, "\n", posw, "\n", posb)
    if (pc_pos == []) or not(in_bounds(pc_pos)):
        #print(pc_pos, " is not on the board.")
        return []
    if verbose:
        print("Position/coordinate of ", pc, " is: ", pc_pos)
    if (c in vars) or (C in vars):
        #print("0", (c in vars), (C in vars))
        E = [[1,0],[-1,0],[0,-1],[0,1]]
        for k in range(4):
            e = E[k]
            mv = [i0+e[0],j0+e[1]]
            #print("0000", pc_pos, pc, mv, GS[mv[0], mv[1]], in_bounds(mv), not((tuple(pc_pos),mv) in mvs))
            if in_bounds(mv) and not((tuple(pc_pos),mv) in mvs):
                mvs = mvs+[(tuple(pc_pos),mv)]
    if (t in vars) or (T in vars):
        #print("1", (t in vars), (T in vars))
        E = [[[2,0],[1,0]], [[-2,0],[-1,0]], [[0,-2],[0,-1]], [[0,2],[0,1]]]
        for k in range(4):
            e = E[k][1]
            f = E[k][0]
            hop = tuple([i0+e[0],j0+e[1]])
            mv = [i0+f[0],j0+f[1]]
            if not(in_bounds(hop)):
                continue
            hop_pc = GS[hop[0], hop[1]]
            if not(hop_pc == 0):
                continue
            #print("001", k, pc_pos, "original pc: ", pc, hop, "hop pc: ", hop_pc, in_bounds(hop), mv, "moved pc: ", GS[mv[0], mv[1]], in_bounds(mv), not((tuple(pc_pos),mv) in mvs))
            if in_bounds(hop) and (in_bounds(mv)) and (not((tuple(pc_pos),mv) in mvs)) and (hop_pc == 0):
                mvs = mvs+[(tuple(pc_pos),mv)]
    if (s in vars) or (S in vars):
        #print("2", (s in vars), (S in vars))
        E = [[[3,0],[2,0],[1,0]], [[-3,0],[-2,0],[-1,0]], [[0,-3],[0,-2],[0,-1]], [[0,3],[0,2],[0,1]]]
        for k in range(4):
            e = E[k][2]
            f = E[k][1]
            g = E[k][0]
            hop1 = tuple([i0+e[0],j0+e[1]])
            if not(in_bounds(hop1)):
                continue
            hop1_pc = GS[hop1[0], hop1[1]]
            if not(hop1_pc == 0):
                continue
            hop2 = tuple([i0+f[0],j0+f[1]])
            if not(in_bounds(hop2)):
                continue
            hop2_pc = GS[hop2[0], hop2[1]]
            if not(hop2_pc == 0):
                continue
            mv   = [i0+g[0],j0+g[1]]
            #print("002", k, pc_pos, "original pc: ", pc, hop1, "hop1 pc: ", hop1_pc, in_bounds(hop1), mv, "moved pc: ", GS[mv[0], mv[1]], in_bounds(mv), not((tuple(pc_pos),mv) in mvs))
            if in_bounds(hop1) and not(hop1 in posw+posb) and in_bounds(hop2) and not(hop2 in posw+posb) and not((tuple(pc_pos),mv) in mvs):
                mvs = mvs + [(tuple(pc_pos),mv)]
    if (p in vars) or (P in vars):
        # uncomment the lines below if the version you play has circles and triangles in the pyramid
	# in the curent version, the pyramid only has square subpieces, no circles or triangles.
        #print("0", (p in vars), (P in vars))
        #if (c in vars) or (C in vars):
        #    E = [[1,0],[-1,0],[0,-1],[0,1]]
        #    for k in range(4):
        #        e = E[k]
        #        mv = [i0+e[0],j0+e[1]]
        #        if in_bounds(mv) and not((tuple(pc_pos),mv) in mvs):
        #            #print(pc, k, mv, mvs, in_bounds(mv), not((tuple(pc_pos),mv) in mvs))
        #            mvs = mvs+[(tuple(pc_pos),mv)]
        #if (t in vars) or (T in vars):
        #    E = [[[2,0],[1,0]], [[-2,0],[-1,0]], [[0,-2],[0,-1]], [[0,2],[0,1]]]
        #    for k in range(4):
        #        e = E[k][1]
        #        f = E[k][0]
        #        hop = [i0+e[0],j0+e[1]]
        #        if not(in_bounds(hop)):
        #            continue
        #        hop_pc = GS[hop[0], hop[1]]
        #        if not(hop_pc == 0):
        #            continue
        #        mv = [i0+f[0],j0+f[1]]
        #        if in_bounds(mv) and not((tuple(pc_pos),mv) in mvs):
        #            mvs = mvs+[(tuple(pc_pos),mv)]
        #if (s in vars) or (S in vars):
            #print("2", (s in vars), (S in vars))
            E = [[[3,0],[2,0],[1,0]], [[-3,0],[-2,0],[-1,0]], [[0,-3],[0,-2],[0,-1]], [[0,3],[0,2],[0,1]]]
            for k in range(4):
                e = E[k][2]
                f = E[k][1]
                g = E[k][0]
                hop1 = tuple([i0+e[0],j0+e[1]])
                if not(in_bounds(hop1)):
                    continue
                hop1_pc = GS[hop1[0], hop1[1]]
                if not(hop1_pc == 0):
                    continue
                hop2 = tuple([i0+f[0],j0+f[1]])
                if not(in_bounds(hop2)):
                    continue
                hop2_pc = GS[hop2[0], hop2[1]]
                if not(hop2_pc == 0):
                    continue
                if in_bounds(hop1) and not(tuple(hop1) in posw+posb) and in_bounds(hop2) and not(tuple(hop2) in posw+posb) and not((tuple(pc_pos),mv) in mvs):
                    mvs = mvs + [(tuple(pc_pos),mv)]
    if verbose:
        print("Possible landing coordinates of ", pc, " are: ")
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
        sage: GS[3,3]=0
        sage: GS[0,12] = C^6
        sage: GS[6,2] = 0; GS[1,11] = T^6
        sage: lands_on( GS, C^6, verbose = False)
        [((0, 12), [1, 11]), ((0, 12), [1, 13])]
        sage: lands_on_by_coordinate( GS, (0,12), verbose = False)
        [((0, 12), [1, 11]), ((0, 12), [1, 13])]
        sage: value_of_piece( GS, 0, 12)
        6
        sage: lands_on( GS, T^6, verbose = False)
        [((1, 11), [3, 11]), ((1, 11), [1, 9]), ((1, 11), [1, 13])]
        sage: value_of_piece( GS, 1, 11)
        6
        sage: value_of_piece( GS, 1, 13)
        12
        sage: valid_captures_by_addition_white(GS)
         [[((0, 12), 6), ((1, 11), 6), ((1, 13), 12)],
          [((1, 11), 6), ((0, 12), 6), ((1, 13), 12)]]
        sage: valid_captures_by_addition_white(GS, verbose=True)
         The piece C^6 at (0, 12) and the piece T^6 at (1, 11) capture by addition the piece t^12 at (1, 13)
         The piece T^6 at (1, 11) and the piece C^6 at (0, 12) capture by addition the piece t^12 at (1, 13)
         [[((0, 12), 6), ((1, 11), 6), ((1, 13), 12)],
          [((1, 11), 6), ((0, 12), 6), ((1, 13), 12)]]

    """
    GS = copy(game_state)
    posw = positions_w(GS)
    posb = positions_b(GS)
    board = [[i,j] for i in range(8) for j in range(16)]
    #print("00", posw)
    mvsw = []
    mvsw0 = []
    pairs_land_on_same_pos = []
    common_mvs = []
    for pc1 in posw:
        lo1 = lands_on( GS, pc1, verbose = False)
        if len(lo1)>0:                                                               ## combined cases ...
            #print("0.3", pc1, lo1, len(lo1), value_of_piece( GS, pc1[0], pc1[1]))
            mvsw0 = mvsw0 + [tuple(lo1[0][1])]
            mvsw = mvsw + lo1
    ## find all pairs of pieces P1, P2 where lo1[P1) intersects lo1[P2]
    #print("1", len(mvsw), "\n", mvsw)
    for X in mvsw:
        for Y in mvsw:
            loX = X[1]
            loY = Y[1]
            #print("0.9", X, loX, Y, loY)
            #ce = common_elements(loX, loY)
            if (loX==loY) and not(X[0] == Y[0]):
                #print("0", X, loX, Y, loY)
                valX = value_of_piece( GS, X[0][0], X[0][1])
                valY = value_of_piece( GS, Y[0][0], Y[0][1])
                XxY = loX
                valXxY = value_of_piece( GS, XxY[0], XxY[1])
                if (tuple(XxY) in posb):
                    pairs_land_on_same_pos = pairs_land_on_same_pos + [(X[0], Y[0], tuple(XxY), [valX, valY, valXxY])]
    #for x in pairs_land_on_same_pos:         # format of output is wrong
    #    if x[3][0]+x[3][1]==x[3][2]:
    #        #print(x[3][0]+x[3][1]==x[3][2], x[3])
    #        common_mvs = common_mvs + [x]
    #    if verbose:
    #        print("The piece ", GS[x[0][0],x[0][1]], " at ", x[0], " and the piece ",  GS[x[1][0],x[1][1]], " at ", x[1], " capture by addition the piece ",  GS[x[2][0],x[2][1]], " at ", x[2])
    #return common_mvs                        # use this snippet suggested by gemini instead:
    for x in pairs_land_on_same_pos:
        # x is like: ((r1, c1), (r2, c2), (r3, c3), [v1, v2, v3])
        pos1, pos2, pos3 = x[0], x[1], x[2]
        val1, val2, val3 = x[3][0], x[3][1], x[3][2]
        # Check the addition condition
        if val1[0] + val2[0] == val3[0]:                               ##################### what about if pc1, pc2, or pc3 is a pyramid ???????????
            # Create the desired output format: [(pos1, val1), (pos2, val2), (pos3, val3)]
            if verbose:
                formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]]), (pos3, val3, GS[pos3[0], pos3[1]])]
            else:
                formatted_result = [(pos1, val1), (pos2, val2), (pos3, val3)]
            common_mvs.append(formatted_result) # Append the newly formatted list
            if verbose:
                # Keep or adjust the verbose print as needed
                print(f"The piece {GS[pos1[0],pos1[1]]} at {pos1} and the piece {GS[pos2[0],pos2[1]]} at {pos2} capture by addition the piece {GS[pos3[0],pos3[1]]} at {pos3}")
    return common_mvs

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
    posw = positions_w(GS)
    posb = positions_b(GS)
    board = [[i,j] for i in range(8) for j in range(16)]
    #print("00", posw)
    mvsb = []
    mvsb0 = []
    pairs_land_on_same_pos = []
    common_mvs = []
    for pc1 in posb:
        lo1 = lands_on( GS, pc1, verbose = False)
        if len(lo1)>0:
            #print("0.3", pc1, lo1, len(lo1), value_of_piece( GS, pc1[0], pc1[1]))
            mvsb0 = mvsb0 + [tuple(lo1[0][1])]
            mvsb = mvsb + lo1
    ## find all pairs of pieces P1, P2 where lo1[P1) intersects lo1[P2]
    #print("1", len(mvsb), "\n", mvsw)
    for X in mvsb:
        for Y in mvsb:
            loX = X[1]
            loY = Y[1]
            #print("0.9", X, loX, Y, loY)
            #ce = common_elements(loX, loY)
            if (loX==loY) and not(X[0] == Y[0]):
                #print("0", X, loX, Y, loY)
                valX = value_of_piece( GS, X[0][0], X[0][1])
                valY = value_of_piece( GS, Y[0][0], Y[0][1])
                XxY = loX
                valXxY = value_of_piece( GS, XxY[0], XxY[1])
                if (tuple(XxY) in posw):
                    pairs_land_on_same_pos = pairs_land_on_same_pos + [(X[0], Y[0], tuple(XxY), [valX, valY, valXxY])]
    #for x in pairs_land_on_same_pos:
    #    if x[3][0]+x[3][1]==x[3][2]:
    #        #print(x[3][0]+x[3][1]==x[3][2], x[3])
    #        common_mvs = common_mvs + [x]
    #    if verbose:
    #        print("The piece ", GS[x[0][0],x[0][1]], " at ", x[0], " and the piece ",  GS[x[1][0],x[1][1]], " at ", x[1], " capture by addition the piece ",  GS[x[2][0],x[2][1]], " at ", x[2])
    #return common_mvs      # use this snippet suggested by gemini instead:
    for x in pairs_land_on_same_pos:
        # x is like: ((r1, c1), (r2, c2), (r3, c3), [v1, v2, v3])
        pos1, pos2, pos3 = x[0], x[1], x[2]
        val1, val2, val3 = x[3][0], x[3][1], x[3][2]
        # Check the addition condition
        if val1[0] + val2[0] == val3[0]:                         ####### what about if pc1, pc2, or pc3 is a pyramid ???????????
            # Create the desired output format: [(pos1, val1), (pos2, val2), (pos3, val3)]
            if verbose:
                formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]]), (pos3, val3, GS[pos3[0], pos3[1]])]
            else:
                formatted_result = [(pos1, val1), (pos2, val2), (pos3, val3)]
            common_mvs.append(formatted_result) # Append the newly formatted list
            if verbose:
                # Keep or adjust the verbose print as needed
                print(f"The piece {GS[pos1[0],pos1[1]]} at {pos1} and the piece {GS[pos2[0],pos2[1]]} at {pos2} capture by addition the piece {GS[pos3[0],pos3[1]]} at {pos3}")
    return common_mvs


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
    GS = game_state
    posw = positions_w(GS)
    posb = positions_b(GS)
    board = [[i,j] for i in range(8) for j in range(16)]
    #print("00", posw)
    mvsw = []
    mvsw0 = []
    pairs_land_on_same_pos = []
    common_mvs = []
    for pc1 in posw:
        lo1 = lands_on( GS, pc1, verbose = False)
        if len(lo1)==1:
            #print("0.3", pc1, lo1, len(lo1), value_of_piece( GS, pc1[0], pc1[1]))
            mvsw0 = mvsw0 + [tuple(lo1[0][1])]
            mvsw = mvsw + lo1
        if len(lo1)>1:
            #print("0.6", pc1, lo1, len(lo1), value_of_piece( GS, pc1[0], pc1[1]))
            mvsw0 = mvsw0 + [tuple(lo1[0][1])]
            mvsw = mvsw + lo1
    ## find all pairs of pieces P1, P2 where lo1[P1) intersects lo1[P2]
    #print("1", len(mvsw), "\n", mvsw)
    for X in mvsw:
        for Y in mvsw:
            loX = X[1]
            loY = Y[1]
            #print("0.9", X, loX, Y, loY)
            #ce = common_elements(loX, loY)
            if (loX==loY) and not(X[0] == Y[0]):
                #print("0", X, loX, Y, loY)
                valX = value_of_piece( GS, X[0][0], X[0][1])
                valY = value_of_piece( GS, Y[0][0], Y[0][1])
                XxY = loX
                valXxY = value_of_piece( GS, XxY[0], XxY[1])
                if (tuple(XxY) in posb):
                    pairs_land_on_same_pos = pairs_land_on_same_pos + [(X[0], Y[0], tuple(XxY), [valX, valY, valXxY])]
    #for x in pairs_land_on_same_pos:
    #    if (x[3][0]-x[3][1]==x[3][2]):
    #        #print(x[3][0]+x[3][1]==x[3][2], x[3])
    #        common_mvs = common_mvs + [x]
    #    if (x[3][0]-x[3][1]==x[3][2]) and verbose:
    #        print("The piece ", GS[x[0][0],x[0][1]], " at ", x[0], " and the piece ",  GS[x[1][0],x[1][1]], " at ", x[1], " capture by subtraction the piece ",  GS[x[2][0],x[2][1]], " at ", x[2])
    #return common_mvs    # use this snippet suggested by gemini instead:
    for x in pairs_land_on_same_pos:
        # x is like: ((r1, c1), (r2, c2), (r3, c3), [v1, v2, v3])
        pos1, pos2, pos3 = x[0], x[1], x[2]
        val1, val2, val3 = x[3][0], x[3][1], x[3][2]
        # Check the addition condition
        if val1[0] - val2[0] == val3[0]:                        ####### what about if pc1, pc2, or pc3 is a pyramid ???????????
            # Create the desired output format: [(pos1, val1), (pos2, val2), (pos3, val3)]
            if verbose:
                formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]]), (pos3, val3, GS[pos3[0], pos3[1]])]
            else:
                formatted_result = [(pos1, val1), (pos2, val2), (pos3, val3)]
            common_mvs.append(formatted_result) # Append the newly formatted list
            if verbose:
                # Keep or adjust the verbose print as needed
                print(f"The piece {GS[pos1[0],pos1[1]]} at {pos1} and the piece {GS[pos2[0],pos2[1]]} at {pos2} capture by subtraction the piece {GS[pos3[0],pos3[1]]} at {pos3}")
    return common_mvs


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
        sage: GS[1,11] = T^9; GS[7,2] = 0
        sage: valid_captures_by_subtraction_black(GS)
         [[((1, 13), 12), ((2, 12), 3), ((1, 11), 9)]]
        sage: valid_captures_by_subtraction_black(GS, verbose=True)
        The piece  t^12  at  (1, 13)  and the piece  c^3  at  (2, 12)  capture by subtraction the piece  T^9  at  (1, 11)
        [[((1, 13), 12), ((2, 12), 3), ((1, 11), 9)]]

    """
    GS = game_state
    posw = positions_w(GS)
    posb = positions_b(GS)
    board = [[i,j] for i in range(8) for j in range(16)]
    #print("00", posw)
    mvsb = []
    mvsb0 = []
    pairs_land_on_same_pos = []
    common_mvs = []
    for pc1 in posb:
        lo1 = lands_on( GS, pc1, verbose = False)
        if len(lo1)==1:
            #print("0.3", pc1, lo1, len(lo1), value_of_piece( GS, pc1[0], pc1[1]))
            mvsb0 = mvsb0 + [tuple(lo1[0][1])]
            mvsb = mvsb + lo1
        if len(lo1)>1:
            #print("0.6", pc1, lo1, len(lo1), value_of_piece( GS, pc1[0], pc1[1]))
            mvsb0 = mvsb0 + [tuple(lo1[0][1])]
            mvsb = mvsb + lo1
    ## find all pairs of pieces P1, P2 where lo1[P1) intersects lo1[P2]
    #print("1", len(mvsw), "\n", mvsw)
    for X in mvsb:
        for Y in mvsb:
            loX = X[1]
            loY = Y[1]
            #print("0.9", X, loX, Y, loY)
            #ce = common_elements(loX, loY)
            if (loX==loY) and not(X[0] == Y[0]):
                #print("0", X, loX, Y, loY)
                valX = value_of_piece( GS, X[0][0], X[0][1])
                valY = value_of_piece( GS, Y[0][0], Y[0][1])
                XxY = loX
                valXxY = value_of_piece( GS, XxY[0], XxY[1])
                if (tuple(XxY) in posw):
                    pairs_land_on_same_pos = pairs_land_on_same_pos + [(X[0], Y[0], tuple(XxY), [valX, valY, valXxY])]
    #for x in pairs_land_on_same_pos:
    #    if (x[3][0]-x[3][1]==x[3][2]):
    #        #print(x[3][0]+x[3][1]==x[3][2], x[3])
    #        common_mvs = common_mvs + [x]
    #    if (x[3][0]-x[3][1]==x[3][2]) and verbose:
    #        print("The piece ", GS[x[0][0],x[0][1]], " at ", x[0], " and the piece ",  GS[x[1][0],x[1][1]], " at ", x[1], " capture by subtraction the piece ",  GS[x[2][0],x[2][1]], " at ", x[2])
    #return common_mvs # use this snippet suggested by gemini instead:
    for x in pairs_land_on_same_pos:
        # x is like: ((r1, c1), (r2, c2), (r3, c3), [v1, v2, v3])
        pos1, pos2, pos3 = x[0], x[1], x[2]
        val1, val2, val3 = x[3][0], x[3][1], x[3][2]
        # Check the addition condition
        if val1[0] - val2[0] == val3[0]:                        ####### what about if pc1, pc2, or pc3 is a pyramid ???????????
            # Create the desired output format: [(pos1, val1), (pos2, val2), (pos3, val3)]
            if verbose:
                formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]]), (pos3, val3, GS[pos3[0], pos3[1]])]
            else:
                formatted_result = [(pos1, val1), (pos2, val2), (pos3, val3)]
            common_mvs.append(formatted_result) # Append the newly formatted list
            if verbose:
                # Keep or adjust the verbose print as needed
                print(f"The piece {GS[pos1[0],pos1[1]]} at {pos1} and the piece {GS[pos2[0],pos2[1]]} at {pos2} capture by subtraction the piece {GS[pos3[0],pos3[1]]} at {pos3}")
    return common_mvs


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
    # Get coordinates first to avoid redundant calls to value_of_piece inside loops
    posw_coords = positions_w(GS, verbose=False)
    posb_coords = positions_b(GS, verbose=False)
    cps = [] # List to store valid captures
    for x_coords in posw_coords:
        # Ensure coordinates are Sage Integers if necessary for GS indexing
        pc1_coords = (ZZ(x_coords[0]), ZZ(x_coords[1]))
        # Get the list of values for the white piece (attacker)
        valw_list = value_of_piece(GS, pc1_coords[0], pc1_coords[1])
        # Skip if the value list is empty or represents an empty square ([0])
        if not valw_list or valw_list == [0]:
            continue
        for y_coords in posb_coords:
            # Ensure coordinates are Sage Integers
            pc2_coords = (ZZ(y_coords[0]), ZZ(y_coords[1]))
            # Get the list of values for the black piece (target)
            valb_list = value_of_piece(GS, pc2_coords[0], pc2_coords[1])
            # Skip if the value list is empty or represents an empty square ([0])
            if not valb_list or valb_list == [0]:
                continue
            # Calculate the distance (number of spaces between)
            # pieces_in_a_line returns number of board units apart (dist+1)
            # returns -1 if not in a line or obstructed
            dist_units = pieces_in_a_line(GS, pc1_coords, pc2_coords)
            # Check if pieces are in a line and separated by at least one space
            if dist_units <= 1:
                continue
            # The required distance multiplier is the number of empty spaces
            dist_spaces = dist_units - 1
            # Iterate through all value combinations for pc1 and pc2
            for v1 in valw_list:
                # Ensure v1 is a numeric type (handle potential non-numeric markers like P/p)
                if not isinstance(v1, (int, Integer)):
                     continue
                for v2 in valb_list:
                    # Ensure v2 is a numeric type
                    if not isinstance(v2, (int, Integer)):
                        continue
                    # Check the capture rule: value(pc1_component) * dist_spaces == value(pc2_component)
                    # Use try-except for safety, though v1 should be non-zero if code reaches here
                    try:
                        if v1 != 0 and v1 * dist_spaces == v2:
                            # Capture occurs!
                            pos1 = pc1_coords # White piece position
                            val1 = v1         # White component value involved
                            pos2 = pc2_coords # Black piece position
                            val2 = v2         # Black component value involved
                            # Format as [(pos1, val1), (pos2, val2)]
                            if verbose:
                                formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]])]
                            else:
                                formatted_result = [(pos1, val1), (pos2, val2)]
                            # Avoid adding duplicate captures if multiple components could technically work
                            # (Rules might specify only one counts, e.g., the largest value?)
                            # For now, we add if the specific combination hasn't been added.
                            if formatted_result not in cps:
                                cps.append(formatted_result)
                                if verbose:
                                    # Fetch symbolic representation for printing
                                    pc1_symbol = GS[pos1[0], pos1[1]]
                                    pc2_symbol = GS[pos2[0], pos2[1]]
                                    print(f"The piece component {pc1_symbol} (value {val1}) at {pos1} captures by multiplication the piece component {pc2_symbol} (value {val2}) at {pos2} at separation {dist_spaces}")
                            # Depending on rules, you might 'break' here if only one capture per pair is allowed.
                    except TypeError:
                        # Handle potential errors if v1 or v2 weren't numeric despite checks
                        if verbose:
                             print(f"Skipping comparison due to non-numeric types: v1={v1}, v2={v2}")
                        continue
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
    # Get coordinates first to avoid redundant calls to value_of_piece inside loops
    posw_coords = positions_w(GS, verbose=False)
    posb_coords = positions_b(GS, verbose=False)
    cps = [] # List to store valid captures
    for x_coords in posb_coords:
        # Ensure coordinates are Sage Integers if necessary for GS indexing
        pc1_coords = (ZZ(x_coords[0]), ZZ(x_coords[1]))
        # Get the list of values for the black piece (attacker)
        valb_list = value_of_piece(GS, pc1_coords[0], pc1_coords[1])
        # Skip if the value list is empty or represents an empty square ([0])
        if not valb_list or valb_list == [0]:
            continue
        for y_coords in posw_coords:
            # Ensure coordinates are Sage Integers
            pc2_coords = (ZZ(y_coords[0]), ZZ(y_coords[1]))
            # Get the list of values for the white piece (target)
            valw_list = value_of_piece(GS, pc2_coords[0], pc2_coords[1])
            # Skip if the value list is empty or represents an empty square ([0])
            if not valw_list or valw_list == [0]:
                continue
            # Calculate the distance (number of spaces between)
            # pieces_in_a_line returns number of board units apart (dist+1)
            # returns -1 if not in a line or obstructed
            dist_units = pieces_in_a_line(GS, pc1_coords, pc2_coords)
            # Check if pieces are in a line and separated by at least one space
            if dist_units <= 1:
                continue
            # The required distance multiplier is the number of empty spaces
            dist_spaces = dist_units - 1
            # Iterate through all value combinations for pc1 and pc2
            for v1 in valb_list:
                # Ensure v1 is a numeric type (handle potential non-numeric markers like P/p)
                if not isinstance(v1, (int, Integer)):
                     continue
                for v2 in valw_list:
                    # Ensure v2 is a numeric type
                    if not isinstance(v2, (int, Integer)):
                        continue
                    # Check the capture rule: value(pc1_component) * dist_spaces == value(pc2_component)
                    # Use try-except for safety, though v1 should be non-zero if code reaches here
                    try:
                        if v1 != 0 and v1 * dist_spaces == v2:
                            # Capture occurs!
                            pos1 = pc1_coords # Black piece position
                            val1 = v1         # Black component value involved
                            pos2 = pc2_coords # white piece position
                            val2 = v2         # white component value involved
                            # Format as [(pos1, val1), (pos2, val2)]
                            if verbose:
                                formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]])]
                            else:
                                formatted_result = [(pos1, val1), (pos2, val2)]
                            # Avoid adding duplicate captures if multiple components could technically work
                            # (Rules might specify only one counts, e.g., the largest value?)
                            # For now, we add if the specific combination hasn't been added.
                            if formatted_result not in cps:
                                cps.append(formatted_result)
                                if verbose:
                                    # Fetch symbolic representation for printing
                                    pc1_symbol = GS[pos1[0], pos1[1]]
                                    pc2_symbol = GS[pos2[0], pos2[1]]
                                    print(f"The piece component {pc1_symbol} (value {val1}) at {pos1} captures by multiplication the piece component {pc2_symbol} (value {val2}) at {pos2} at separation {dist_spaces}")
                            # Depending on rules, you might 'break' here if only one capture per pair is allowed.
                    except TypeError:
                        # Handle potential errors if v1 or v2 weren't numeric despite checks
                        if verbose:
                             print(f"Skipping comparison due to non-numeric types: v1={v1}, v2={v2}")
                        continue
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
    # Get coordinates first
    posw_coords = positions_w(GS, verbose=False)
    posb_coords = positions_b(GS, verbose=False)
    cps = [] # List to store valid captures
    for x_coords in posw_coords:
        # Ensure coordinates are Sage Integers if necessary
        pc1_coords = (ZZ(x_coords[0]), ZZ(x_coords[1]))
        # Get the list of values for the white piece (attacker)
        valw_list = value_of_piece(GS, pc1_coords[0], pc1_coords[1])
        if not valw_list or valw_list == [0]: continue # Skip empty squares
        for y_coords in posb_coords:
            # Ensure coordinates are Sage Integers
            pc2_coords = (ZZ(y_coords[0]), ZZ(y_coords[1]))
            # Get the list of values for the black piece (target)
            valb_list = value_of_piece(GS, pc2_coords[0], pc2_coords[1])
            if not valb_list or valb_list == [0]: continue # Skip empty squares
            # Calculate distance (number of spaces between)
            dist_units = pieces_in_a_line(GS, pc1_coords, pc2_coords)
            # Check if pieces are in a line and separated by at least one space
            if dist_units <= 1:
                continue
            dist_spaces = dist_units - 1
            # Iterate through all value combinations
            for v1 in valw_list: # White attacker value component
                if not isinstance(v1, (int, Integer)): continue # Skip non-numeric markers
                for v2 in valb_list: # Black target value component
                    if not isinstance(v2, (int, Integer)): continue # Skip non-numeric markers
                    # Check the capture rule: value(pc1)/value(pc2) == dist_spaces
                    # Requires v2 != 0 and v2 must divide v1
                    try:
                        if v2 != 0 and v1 % v2 == 0:
                            quotient = ZZ(v1 / v2) # Use ZZ for Sage integer division
                            if quotient == dist_spaces:
                                # Capture occurs!
                                pos1 = pc1_coords # White piece position
                                val1 = v1         # White component value involved
                                pos2 = pc2_coords # Black piece position
                                val2 = v2         # Black component value involved
                                # Format as [(pos1, val1), (pos2, val2)]
                                if verbose:
                                    formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]])]
                                else:
                                    formatted_result = [(pos1, val1), (pos2, val2)]
                                # Avoid duplicates
                                if formatted_result not in cps:
                                    cps.append(formatted_result)
                                    if verbose:
                                        pc1_symbol = GS[pos1[0], pos1[1]]
                                        pc2_symbol = GS[pos2[0], pos2[1]]
                                        print(f"The piece component {pc1_symbol} (value {val1}) at {pos1} captures by division the piece component {pc2_symbol} (value {val2}) at {pos2} at separation {dist_spaces}")
                                # Maybe break inner loops if only one capture allowed per pair?
                    except Exception as e: # Catch potential division errors or type issues
                        if verbose:
                            print(f"Error during division check for v1={v1}, v2={v2}: {e}")
                        continue
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
    # Get coordinates first
    posw_coords = positions_w(GS, verbose=False)
    posb_coords = positions_b(GS, verbose=False)
    cps = [] # List to store valid captures
    for x_coords in posb_coords:
        # Ensure coordinates are Sage Integers if necessary
        pc1_coords = (ZZ(x_coords[0]), ZZ(x_coords[1]))
        # Get the list of values for the black piece (attacker)
        valb_list = value_of_piece(GS, pc1_coords[0], pc1_coords[1])
        if not valb_list or valb_list == [0]: continue # Skip empty squares
        for y_coords in posw_coords:
            # Ensure coordinates are Sage Integers
            pc2_coords = (ZZ(y_coords[0]), ZZ(y_coords[1]))
            # Get the list of values for the white piece (target)
            valw_list = value_of_piece(GS, pc2_coords[0], pc2_coords[1])
            if not valw_list or valw_list == [0]: continue # Skip empty squares
            # Calculate distance (number of spaces between)
            dist_units = pieces_in_a_line(GS, pc1_coords, pc2_coords)
            # Check if pieces are in a line and separated by at least one space
            if dist_units <= 1:
                continue
            dist_spaces = dist_units - 1
            # Iterate through all value combinations
            for v1 in valb_list: # Black attacker value component
                if not isinstance(v1, (int, Integer)): continue # Skip non-numeric markers
                for v2 in valw_list: # White target value component
                    if not isinstance(v2, (int, Integer)): continue # Skip non-numeric markers
                    # Check the capture rule: value(pc1)/value(pc2) == dist_spaces
                    # Requires v2 != 0 and v2 must divide v1
                    try:
                        if v2 != 0 and v1 % v2 == 0:
                            quotient = ZZ(v1 / v2) # Use ZZ for Sage integer division
                            if quotient == dist_spaces:
                                # Capture occurs!
                                pos1 = pc1_coords # black piece position
                                val1 = v1         # black component value involved
                                pos2 = pc2_coords # white piece position
                                val2 = v2         # white component value involved
                                # Format as [(pos1, val1), (pos2, val2)]
                                if verbose:
                                    formatted_result = [(pos1, val1, GS[pos1[0], pos1[1]]), (pos2, val2, GS[pos2[0], pos2[1]])]
                                else:
                                    formatted_result = [(pos1, val1), (pos2, val2)]
                                # Avoid duplicates
                                if formatted_result not in cps:
                                    cps.append(formatted_result)
                                    if verbose:
                                        pc1_symbol = GS[pos1[0], pos1[1]]
                                        pc2_symbol = GS[pos2[0], pos2[1]]
                                        print(f"The piece component {pc1_symbol} (value {val1}) at {pos1} captures by division the piece component {pc2_symbol} (value {val2}) at {pos2} at separation {dist_spaces}")
                                # Maybe break inner loops if only one capture allowed per pair?
                    except Exception as e: # Catch potential division errors or type issues
                        if verbose:
                            print(f"Error during division check for v1={v1}, v2={v2}: {e}")
                        continue
    return cps


def valid_captures_by_siege_white(game_state, verbose = False): ## this is gemini's improvement of the original version
    r"""
    Lists Black pieces captured by White via siege.
    A piece is captured by siege if all four orthogonal adjacent squares
    are either off-board or occupied by a white piece.

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
    GS = copy(game_state) # Keep alias for brevity if preferred
    captured_by_siege = []
    # Get positions efficiently
    # Use sets for faster lookups (O(1) average)
    black_positions_values = {}
    for r_int, c_int in positions_b(GS):
         # Ensure coordinates are standard Python integers if needed
         r, c = int(r_int), int(c_int)
         val = value_of_piece(GS, r, c)
         black_positions_values[(r, c)] = val
    white_pos_set = set()
    for r_int, c_int in positions_w(GS):
        white_pos_set.add( (int(r_int), int(c_int)) )
    # Define orthogonal directions
    shifts = [(0, 1), (0, -1), (1, 0), (-1, 0)] # Right, Left, Down, Up
    # Check each black piece for siege
    for (r, c), value in black_positions_values.items():
        is_surrounded = True # Assume surrounded until proven otherwise
        for dr, dc in shifts:
            adj_r, adj_c = r + dr, c + dc
            adj_pos = (adj_r, adj_c)
            # Check if the adjacent square is within bounds
            if in_bounds(adj_pos):
                # If it's in bounds, it must be occupied by white for siege to continue
                if adj_pos not in white_pos_set:
                    is_surrounded = False
                    break # No need to check other directions for this piece
            # else: If adj_pos is out of bounds, it counts towards the siege
        # If the loop completed without setting is_surrounded to False
        if is_surrounded:
            if verbose:
                captured_info = [((r, c), value, GS[r, c])]
            else:
                captured_info = ((r, c), value)
            captured_by_siege.append(captured_info)
            if verbose:
                # Assuming GS[r, c] gives a printable representation of the piece
                print(f"The piece {GS[r,c]} at {(r, c)} with value {value} is captured by siege.")
    return captured_by_siege

	
def valid_captures_by_siege_black(game_state, verbose = False):
    r"""
    Lists Black's captures of a white piece by siege,
    according to Rithmomachia rules. 

    Args: 
      game_state: The 8x16 matrix representing the board and pieces in the game.

    Returns: 
      List of names of White's captured pieces, if any.
      
    ## this is gemini's improvement of the original version

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
    GS = copy(game_state) # Keep alias for brevity if preferred
    captured_by_siege = []
    # Get positions efficiently
    # Use sets for faster lookups (O(1) average)
    white_positions_values = {}
    for r_int, c_int in positions_w(GS):
         # Ensure coordinates are standard Python integers if needed
         r, c = int(r_int), int(c_int)
         val = value_of_piece(GS, r, c)
         white_positions_values[(r, c)] = val
    black_pos_set = set()
    for r_int, c_int in positions_b(GS):
        black_pos_set.add( (int(r_int), int(c_int)) )
    # Define orthogonal directions
    shifts = [(0, 1), (0, -1), (1, 0), (-1, 0)] # Right, Left, Down, Up
    # Check each white piece for siege
    for (r, c), value in white_positions_values.items():
        is_surrounded = True # Assume surrounded until proven otherwise
        for dr, dc in shifts:
            adj_r, adj_c = r + dr, c + dc
            adj_pos = (adj_r, adj_c)
            # Check if the adjacent square is within bounds
            if in_bounds(adj_pos):
                # If it's in bounds, it must be occupied by black for siege to continue
                if adj_pos not in black_pos_set:
                    is_surrounded = False
                    break # No need to check other directions for this piece
            # else: If adj_pos is out of bounds, it counts towards the siege
        # If the loop completed without setting is_surrounded to False
        if is_surrounded:
            if verbose:
                captured_info = [((r, c), value, GS[r, c])]
            else:
                captured_info = ((r, c), value)
            captured_by_siege.append(captured_info)
            if verbose:
                # Assuming GS[r, c] gives a printable representation of the piece
                print(f"The piece {GS[r,c]} at {(r, c)} with value {value} is captured by siege.")
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
    printed = 0
    for cap in c1:
        capturing_pc_value = cap[0][1]  #### this is a list
        captured_pos = (cap[1][0], cap[1][1])
        if verbose:
            print("Capture by numbering on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos) # Use copy here too
    for cap in c2+c3:
        capturing_pc_value = cap[2][2]      # the value of the pc in the last arg
        captured_pos = (cap[2][0], cap[2][1])
        if verbose:
            print("Capture by addition/subtraction on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos[0]) # Use copy here too
    for cap in c4+c5:
        capturing_pc_value = cap[1][1]        # the value of the pc in the last arg
        captured_pos = (cap[1][0][0], cap[1][0][1])
        if verbose:
            print("Capture by multiplication/division on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos) # Use copy here too
    for cap in c6:
        capturing_pos = [-1]                ######### there is no value assigned to a capturing piece in this case
        captured_pos = (cap[0][0], cap[0][1])
        capturing_pc_value = 0
        if verbose:
            print("Capture by siege on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos) # Use copy here too
    if verbose:
        print("There were ", printed, " captures of White pieces by Black.")
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
    printed = 0
    for cap in c1:
        capturing_pc_value = cap[0][1]  #### this is a list
        captured_pos = (cap[1][0], cap[1][1])
        if verbose:
            print("Capture by numbering on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos) # Use copy here too
    for cap in c2+c3:
        capturing_pc_value = cap[2][2]      # the value of the pc in the last arg
        captured_pos = (cap[2][0], cap[2][1])
        if verbose:
            print("Capture by addition/subtraction on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos[0]) # Use copy here too
    for cap in c4+c5:
        capturing_pc_value = cap[1][1]        # the value of the pc in the last arg
        captured_pos = (cap[1][0][0], cap[1][0][1])
        if verbose:
            print("Capture by multiplication/division on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos) # Use copy here too
    for cap in c6:
        capturing_pos = [-1]                ######### there is no value assigned to a capturing piece in this case
        captured_pos = (cap[0][0], cap[0][1])
        capturing_pc_value = 0
        if verbose:
            print("Capture by siege on ", captured_pos)
            printed = printed + 1
        # Simulate the capture on a fresh copy of the original state
        GS = capture_piece(copy(GS), capturing_pc_value, captured_pos) # Use copy here too
    if verbose:
        print("There were ", printed, " captures of Black pieces by White.")
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
    L = (m1+m2+m3+m4, c1, c2+c3, c4+c5, c6)
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


def is_body_common_victory_black(game_state, N0 = 4):
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
    return (len(cpw) >= N0) #### Boolean
    
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
    
    
def list_arithmetical_patterns_white():
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
    poswv = [[x[0], value_of_piece(GS, x[0][0], x[0][1])] for x in positions_w(GS, verbose=True)]
    valsw = [x[1][0] for x in poswv if x[1][0] in ZZ]
    for v0 in valsw:
        for v1 in valsw:
            for v2 in valsw:
                if (v0<v1) and (v1<v2) and not((v0, v1, v2) in arithmetical_patterns):
                    if v2-v1==v1-v0:      ################### testing the arithmetical condition #######
                        arithmetical_patterns = arithmetical_patterns + [(v0, v1, v2)]
    arithmetical_patterns.sort()
    return arithmetical_patterns
    
def list_arithmetical_patterns_black():
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
    posbv = [[x[0], value_of_piece(GS, x[0][0], x[0][1])] for x in positions_b(GS, verbose=True)]
    valsb = [x[1][0] for x in posbv if x[1][0] in ZZ]
    for v0 in valsb:
        for v1 in valsb:
            for v2 in valsb:
                if (v0<v1) and (v1<v2) and not((v0, v1, v2) in arithmetical_patterns):
                    if v2-v1==v1-v0:
                        arithmetical_patterns = arithmetical_patterns + [(v0, v1, v2)]
    arithmetical_patterns.sort()
    return arithmetical_patterns

    
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
    posw = positions_w(GS)
    posw_in_b = [[x, value_of_piece(GS, x[0], x[1])] for x in posw if x[1]>7]
    vals_posw_in_b = [y[1] for y in posw_in_b]
    num_vals = len(vals_posw_in_b)
    if num_vals < 3:
        return False
    ## instead of using pattern_list, use a triple for loop to
    ## pick 3, check they are distinct, sort them
    ## test the c-b = b-a condition
    ## if valid, return True, else False
    good_coords0 = []
    z0 = []
    for z in pattern_list:
        for w1 in posw_in_b:
            for w2 in posw_in_b:
                for w3 in posw_in_b:
                    if len(list(Set([w1,w2,w3]))) < 3:
                        continue
                    w11 = sum(w1[1]); w21 = sum(w2[1]); w31 = sum(w3[1])
                    #print("000", (w1, w2, w3), z, Set(z) == Set([w1[1], w2[1], w3[1]]), good_coords0)
                    #if (z[0] == w11) and (z[1] == w21) and (z[2] == w31):
                    if Set(z) == Set([w11, w21, w31]):
                        w = [w1, w2, w3]
                        #w.sort
                        #print("111", w, z0, good_coords0)
                        if not(w1 in good_coords0) and not(w2 in good_coords0) and not(w3 in good_coords0):
                            z0 = z0 + [z]
                            good_coords0 = good_coords0 + w
                            #print("222", w, z0, good_coords0)
    #print(z, good_coords0,len(good_coords0)>=3)
    if len(good_coords0)>=3:
         #winning = is_in_a_line(good_coords0[0][0], good_coords0[1][0], good_coords0[2][0])   ##### ignore this condition
         winning = True
         if winning and not(verbose):
             return True
         elif winning:
             #if (z[0] in vals_posw_in_b) and (z[1] in vals_posw_in_b) and (z[2] in vals_posw_in_b):
             print("White has 3 pieces in enemy territory with values ", z0, " in arithmetic harmony.", good_coords0)
             return True
         #else:
         #    if verbose:
         #        print("White has 3 pieces in enemy territory with values ", z, " in non-linear arithmetic harmony.", good_coords0)
    return False

def is_arithmetical_pattern_black(game_state, in_a_line = False, verbose = False):
    r"""
    returns True if Black has
    a) at least 3 pieces in enemy territory,
    b) there are 3 of these pieces whose values
       agree (in some order) with one of the
       arithmetical patterns listed
    ######### c) the in_a_line condition holds.   ########## ignore this condition


    EXAMPLES:
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: GS[2,12] = 0; GS[0, 7] = c^3; GS[3,12] = 0; GS[2, 7] = c^5; GS[4,12] = 0; GS[4, 7] = c^7
        sage: is_arithmetical_pattern_black(GS, verbose = True)
         Black has 3 pieces in enemy territory with values (3, 5, 7) in linear arithmetic harmony. Pieces: [((0, 7), [3]), ((2, 7), [5]), ((4, 7), [7])]
         True

    """
    GS = copy(game_state)
    pattern_list = list_arithmetical_patterns_black() # Get valid patterns
    posb = positions_b(GS) # Get all black positions
    # Get black pieces in enemy territory (col index < 8)
    # Store as [(position_tuple, value_list), ...]
    posb_in_w = []
    for r, c in posb:
        if c < 8: # Enemy territory for black
            value = value_of_piece(GS, r, c)
            # Ensure value is not [0] (empty square) and is a list
            if isinstance(value, list) and value != [0]:
                 posb_in_w.append( ((r, c), value) ) # Store position and value list
    # Need at least 3 pieces
    if len(posb_in_w) < 3:
        return False
    # Iterate through all combinations of 3 distinct pieces in enemy territory
    for w1, w2, w3 in itertools.combinations(posb_in_w, 3):
        # Extract values - take the first element assuming single-value pieces
        # Note: Assumes patterns don't directly involve pyramid components
        val1 = w1[1][0] if w1[1] else None
        val2 = w2[1][0] if w2[1] else None
        val3 = w3[1][0] if w3[1] else None
        # Skip if any piece somehow had an empty value list
        if val1 is None or val2 is None or val3 is None:
            continue
        # Check if the values form any known arithmetical pattern
        # Create sorted tuple of values to check against patterns
        current_values_sorted = tuple(sorted([val1, val2, val3]))
        if current_values_sorted in pattern_list:
            # Found an arithmetical pattern! Now check linearity.
            pos1 = w1[0]
            pos2 = w2[0]
            pos3 = w3[0]
            if is_in_a_line(pos1, pos2, pos3):
                # Found a winning pattern
                if verbose:
                    # Use the matched pattern tuple for printing clarity
                    print(f"Black has 3 pieces in enemy territory with values {current_values_sorted} in arithmetic harmony. Pieces: {[w1, w2, w3]}")
                return True
            # else:
            #    if verbose: # Optional: report non-linear patterns
            #        print(f"Black has 3 pieces in enemy territory with values {current_values_sorted} in non-linear arithmetic harmony. Pieces: {[w1, w2, w3]}")
    # If no combination satisfied both conditions
    return False
    
    
def list_geometrical_patterns_white():
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
    
def list_geometrical_patterns_black():
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
    posw = positions_w(GS)
    # Get white pieces in enemy territory (col index > 7)
    # Store as [(position_tuple, value_list), ...]
    posw_in_b = []
    for r, c in posw:
        if c > 7:
            value = value_of_piece(GS, r, c)
            # Ensure value is not [0] (empty square) and is a list
            if isinstance(value, list) and value != [0]:
                 posw_in_b.append( ((r, c), value) ) # Store position and value list
    # Need at least 3 pieces
    if len(posw_in_b) < 3:
        return False
    # Iterate through all combinations of 3 distinct pieces in enemy territory
    for w1, w2, w3 in itertools.combinations(posw_in_b, 3):
        # Extract values - take the first element assuming single-value pieces for patterns
        # Note: This assumes patterns don't involve pyramid components directly
        val1 = w1[1][0] if w1[1] else None
        val2 = w2[1][0] if w2[1] else None
        val3 = w3[1][0] if w3[1] else None
        # Skip if any piece somehow had an empty value list
        if val1 is None or val2 is None or val3 is None:
            continue
        # Check if the values form any known geometric pattern
        # Create sorted tuple of values to check against patterns
        current_values_sorted = tuple(sorted([val1, val2, val3]))
        #print("0000  ", w1, w2, w3, "\n", val1, val2, val3, "\n", current_values_sorted)
        if current_values_sorted in pattern_list:
            # Found a geometric pattern! Now check linearity.
            pos1 = w1[0]
            pos2 = w2[0]
            pos3 = w3[0]
            #print("1111  ", w1, w2, w3, "\n", val1, val2, val3, "\n", pos1, pos2, pos3, is_in_a_line(pos1, pos2, pos3))
            #if is_in_a_line(pos1, pos2, pos3):
            # Found a winning pattern
            if verbose:
                # Use the matched pattern tuple for printing clarity
                print(f"White has 3 pieces in enemy territory with values {current_values_sorted} in geometric harmony. Pieces: {[w1, w2, w3]}")
            return True
            # else:
            #    if verbose: # Optional: report non-linear patterns
            #        print(f"White has 3 pieces in enemy territory with values {current_values_sorted} in non-linear geometric harmony. Pieces: {[w1, w2, w3]}")
    # If no combination satisfied both conditions
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
    import itertools
    GS = copy(game_state)                         
    pattern_list = list_geometrical_patterns_black()
    posb = positions_b(GS)
    # Get black pieces in enemy territory (col index <= 7)
    # Store as [(position_tuple, value_list), ...]
    posw_in_w = []
    for r, c in posb:
        if c <= 7:
            value = value_of_piece(GS, r, c)
            # Ensure value is not [0] (empty square) and is a list
            if isinstance(value, list) and value != [0]:
                 posw_in_w.append( ((r, c), value) ) # Store position and value list
    # Need at least 3 pieces
    if len(posw_in_w) < 3:
        return False
    # Iterate through all combinations of 3 distinct pieces in enemy territory
    for w1, w2, w3 in itertools.combinations(posw_in_w, 3):
        # Extract values - take the first element assuming single-value pieces for patterns
        # Note: This assumes patterns don't involve pyramid components directly
        val1 = w1[1][0] if w1[1] else None
        val2 = w2[1][0] if w2[1] else None
        val3 = w3[1][0] if w3[1] else None
        # Skip if any piece somehow had an empty value list
        if val1 is None or val2 is None or val3 is None:
            continue
        # Check if the values form any known geometric pattern
        # Create sorted tuple of values to check against patterns
        current_values_sorted = tuple(sorted([val1, val2, val3]))
        #print("0000  ", w1, w2, w3, "\n", val1, val2, val3, "\n", current_values_sorted)
        if current_values_sorted in pattern_list:
            # Found a geometric pattern! Now check linearity.
            pos1 = w1[0]
            pos2 = w2[0]
            pos3 = w3[0]
            #print("1111  ", w1, w2, w3, "\n", val1, val2, val3, "\n", pos1, pos2, pos3, is_in_a_line(pos1, pos2, pos3))
            #if is_in_a_line(pos1, pos2, pos3):
            # Found a winning pattern
            if verbose:
                # Use the matched pattern tuple for printing clarity
                print(f"Black has 3 pieces in enemy territory with values {current_values_sorted} in linear geometric harmony. Pieces: {[w1, w2, w3]}")
            return True
            # else:
            #    if verbose: # Optional: report non-linear patterns
            #        print(f"Black has 3 pieces in enemy territory with values {current_values_sorted} in non-linear geometric harmony. Pieces: {[w1, w2, w3]}")
    # If no combination satisfied both conditions
    return False

    

def list_musical_patterns_white():
    """
    lists all possible musical patterns for white pieces.

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

def list_musical_patterns_black():
    """
    This function lists all possible musical patterns for black pieces.
   
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
                    if 1/v0-1/v1 == 1/v1-1/v2 and not((v0, v1, v2) in musical_patterns):
                        musical_patterns = musical_patterns + [(v0, v1, v2)]
    musical_patterns.sort()
    return musical_patterns


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
    posw = positions_w(GS)
    posw_in_b = [[x, value_of_piece(GS, x[0], x[1])] for x in posw if x[1]>7]
    vals_posw_in_b = [y[1] for y in posw_in_b]
    num_vals = len(vals_posw_in_b)
    if num_vals < 3:
        return False
    ## instead of using pattern_list, use a triple for loop to
    ## pick 3, check they are distinct, sort them
    ## test the 1/a-1/b = 1/b-1/c condition
    ## if valid, return True, else False
    good_coords0 = []
    z0 = []
    for z in pattern_list:
        for w1 in posw_in_b:
            for w2 in posw_in_b:
                for w3 in posw_in_b:
                    if len(list(Set([w1,w2,w3]))) < 3:
                        continue
                    w11 = sum(w1[1]); w21 = sum(w2[1]); w31 = sum(w3[1])
                    #print("000", (w1, w2, w3), z, Set(z) == Set([w1[1], w2[1], w3[1]]), good_coords0)
                    #if (z[0] == w11) and (z[1] == w21) and (z[2] == w31):
                    if Set(z) == Set([w11, w21, w31]):
                        w = [w1, w2, w3]
                        w.sort
                        if not(w1 in good_coords0) and not(w2 in good_coords0) and not(w3 in good_coords0):
                            z0 = z0 + [z]
                            good_coords0 = good_coords0 + w
    #print(z, good_coords0,len(good_coords0)>=3)
    if len(good_coords0)>=3:
         #winning = is_in_a_line(good_coords0[0][0], good_coords0[1][0], good_coords0[2][0])
         winning = True
         if winning and not(verbose):
             return True
         elif winning:
             #if (z[0] in vals_posw_in_b) and (z[1] in vals_posw_in_b) and (z[2] in vals_posw_in_b):
             print("White has 3 pieces in enemy territory with values ", z0, " in musical harmony.", good_coords0)
             return True
         #else:
         #    if verbose:
         #        print("White has 3 pieces in enemy territory with values ", z, " in non-linear musical harmony.", good_coords0)
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


def value_of_piece(GS, i, j):
    """
    returns the value of the piece at (i,j), in game state
    matrix notation. If the position/coordinate is empty 
    then the value is 0. If the piece is a pyramid then
    it returns all the values, as a tuple.

    EXAMPLE:
        sage: GS = board_initial_matrix()
        sage: value_of_piece(GS, 2, 4) ## 0 means there is no piece there
        0
        sage: value_of_piece(GS, 2, 3)
        8
        sage: value_of_piece(GS, 3, 3)
        6
        sage: value_of_piece(GS, 3, 13)
        25
        sage: GSp = board_initial_matrix(pyramid_decomposition = True)
        sage: GS = copy(GSp)
        sage: pyramid_positions_white(GS, verbose = True)
         [(P^91 + S^36 + S^25 + S^16 + S^9 + S^4 + S, 1, 1)]
        sage: value_of_piece(GS, 1, 1)
         [4, 91, 16, 36] 
        sage: pyramid_positions_black(GS, verbose = True)
         [(p^190 + s^64 + s^49 + s^36 + s^25 + s^16, 7, 14)]
        sage: value_of_piece(GS, 7, 14)
         [16, 190, 36, 64]

    """
    c,C,p,P,t,T,s,S = var("c,C,p,P,t,T,s,S")
    PR = ZZ[c,C,p,P,t,T,s,S]
    all_vars = [c,C,p,P,t,T,s,S]
    xx = GS[i,j]
    #print("0000", xx, xx.variables())
    if xx == 0:
        return [xx]
    if not(p in xx.variables()) and not(P in xx.variables()):    ######## non-pyramid case
        return [xx.degree()]
    else:                                                         ######## pyramid case
        f = PR(xx)
        #print("0001", f, f.exponents())
        if (s in xx.variables()):
            return [v[6] for v in f.exponents() if not(v[6]==0)]
        if (S in xx.variables()):
            return [v[7] for v in f.exponents() if not(v[7]==0)]
    return [xx]

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
    x1 = pc1[0]
    y1 = pc1[1]
    x2 = pc2[0]
    y2 = pc2[1]
    if (x1==x2) and (y1==y2):
        return 0
    if (x1==x2) and (y1>y2):
        d = y1-y2
        if d==1:
            return 0
        if d>1:
            for i in range(1, d):     ### does this go to d-1??
               x = x2    ## = x1
               y = y2+i
               if value_of_piece(GS, x, y)[0]>0:
                   return -1
            return d.abs()                  ### should this be d-1??
    if (x1==x2) and (y1<y2):
        d = y2-y1
        if d==1:
            return 0
        if d>1:
            for i in range(1, d):
               x = x1    ## = x2
               y = y1+i
               if value_of_piece(GS, x, y)[0]>0:
                   return -1
            return d.abs()
    if (x1>x2) and (y1==y2):
        d = x1-x2
        if d==1:
            return 0
        if d>1:
            for i in range(1, d):
               x = x2+i
               y = y2   ## = y1
               if value_of_piece(GS, x, y)[0] > 0:
                   return -1
            return d.abs()
    if (x1<x2) and (y1==y2):
        d = x2-x1
        if d==1:
            return 0
        if d>1:
            for i in range(1, d):
               x = x1+i
               y = y1   ## = y2
               if value_of_piece(GS, x, y)[0] > 0:
                   return -1
            return d.abs()
    if (diagonal_lines):
        if (x2 > x1) and ((y2-y1)/(x2-x1) == 1):
            d = x2-x1
            if d==1:
                return 0
            if d>1:
                for i in range(1, d):
                   x = x1+i
                   y = y1+i
                   if value_of_piece(GS, x, y)[0] > 0:
                       return -1
                return d.abs()
        if (x2 < x1) and ((y2-y1)/(x2-x1) == 1):
            d = x1-x2
            if d==1:
                return 0
            if d>1:
                for i in range(1, d):
                   x = x1-i
                   y = y1-i
                   if value_of_piece(GS, x, y)[0] > 0:
                       return -1
                return d.abs()
        if (x2 > x1) and ((y2-y1)/(x2-x1) == -1):
            d = x2-x1
            #print(d, x1, x2, y1, y2)
            if d==1:
                return 0
            if d>1:
                for i in range(1, d):
                   x = x1+i
                   y = y1-i
                   if value_of_piece(GS, x, y)[0] > 0:
                       return -1
                return d.abs()
        if (x2 < x1) and ((y2-y1)/(x2-x1) == -1):
            d = x1-x2
            if d==1:
                return 0
            if d>1:
                for i in range(1, d):
                   x = x1-i
                   y = y1+i
                   if value_of_piece(GS, x, y)[0] > 0:
                       return -1
                return d.abs()
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
    Self-explanatory.

    All 4 lists must be of the same length.

    TO DO: This condition rules out White making a move but not Black. FIX THIS!!!
    
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
    if (piece_color in ["black", "Black", "odd", "Odd"]):
        if by_rank == False:
            positions = positions_b(gs)
        else:
            positions = [xx for xx in positions_b(gs) if xx[1]<10]
        nn = len(positions)
        if nn==0:
            positions = positions_b(gs)
            nn = len(positions)
        x0 = sum([vv[0] for vv in positions])
        y0 = sum([vv[1] for vv in positions])
        return (x0/nn, y0/nn)
    elif (piece_color in ["even", "Even", "white", "White"]):
        if by_rank == False:
            positions = positions_w(gs)
        else:
            positions = [xx for xx in positions_w(gs) if xx[1]>5]
        nn = len(positions)
        if nn==0:
            positions = positions_w(gs)
            nn = len(positions)
        x0 = sum([vv[0] for vv in positions])
        y0 = sum([vv[1] for vv in positions])
        return (x0/nn, y0/nn)
    else:
        print("You must select a piece color, such as 'Even' or 'Odd'. Try again.")
        return (-1, -1)

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

# Helper to map Sage piece variables to matplotlib shapes and colors
def get_piece_details_from_poly(poly_piece, default_color_w='green', default_color_b='red'):
    """
    This is a functions that is used in display_board_matplotlib

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