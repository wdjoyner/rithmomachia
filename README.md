# rithmomachia
A Python module to play Rithmomachia. Uses tkinter for the gui interface.

This is a very basic but complete implementation of
rithmomachia in python, using tkinter for the GUI. It comtains
a standalone function 

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


