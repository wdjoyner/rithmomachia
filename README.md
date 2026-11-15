# Rithmomachia

Rithmomachia is the medieval mathematical strategy game sometimes called the
*Philosophers' Game*. This repository contains related but independent
implementations, along with educational material and graphics tools.

The mathematical rules and capture mechanisms follow the author's study of
Claude de Boissière's 1556 presentation, as discussed by J. F. C. Richards
(1946). **Rithmomachia has historical rule variants**; the programs do not
yet provide a single, exhaustively validated implementation of every variant.

## Implementations

| Location | Runtime | Purpose |
| --- | --- | --- |
| [`rithmomachia.py`](rithmomachia.py) | **SageMath Python** | Large, function-oriented rules, gameplay, computational, plotting, and animation implementation |
| [`rithmo.py`](rithmo.py) | Python 3 + Tkinter | Shorter, object-oriented graphical game with an experimental computer opponent |
| [`godot-rithmo/`](godot-rithmo/) | Godot 4 / GDScript | Separate graphical implementation and rule-checking scripts |
| [historical `rithmomachia.sage` on `baseball`](https://github.com/wdjoyner/rithmomachia/blob/baseball/rithmomachia.sage) | SageMath (.sage format) | Previous repository version, preserved on the original branch and in Git history; not the corrected source |
| [`docs/`](docs/) | PDF and LaTeX | Background on the game and implementation notes |
| Blender/Matplotlib scripts in the root | Blender/Python | Board and pyramid animation experiments |

**The Python and SageMath programs are separate.** The `.py` extension on
`rithmomachia.py` does not mean it will run in an ordinary Python
installation: it imports `sage.all`, uses Sage polynomial rings and matrices,
and requires a SageMath-enabled Python interpreter.

The intended development branch is named `main`. The old `baseball` and
`rithmomachia-tutor` branches remain in the repository. Changing the GitHub
default branch is a separate repository setting.

## Run the SageMath-based implementation

Install [SageMath](https://www.sagemath.org/) first. The module also imports
Matplotlib and NumPy, which are typically available in SageMath installations.

From the repository root:

```bash
sage -python -c 'import rithmomachia as r; G = r.board_initial_matrix(pyramid_decomposition=True); print(r.is_valid_move(G, (6, 0), (3, 0), "white"))'
```

To use the available functions interactively:

```bash
sage -python
```

```python
import rithmomachia as r

G = r.board_initial_matrix(pyramid_decomposition=True)
print(r.is_valid_move(G, (6, 0), (3, 0), "white"))
G2 = r.move_piece(G, (6, 0), (3, 0))
# Plotting requires a usable graphics backend:
# r.board_plot(G2).show()
```

The large SageMath module exposes additional functions such as
`valid_captures_by_numbering_white`,
`take_all_captures_white`,
`is_arithmetical_pattern_white`,
`display_board_matplotlib`, and gameplay/animation helpers.
To discover public functions and historical comments, search the source.

Board images and animation frames may be written into
`~/sagefiles/`; create that directory if needed. Some plotting
and animation routines are still experimental.

## Run the standalone Tkinter GUI

Tkinter and a graphical desktop are required.

```bash
python -c 'import rithmo; rithmo.launch_rithmomachia_gui()'
```

The GUI supports human-vs-human and experimental human-vs-computer play.
The computer presently chooses a random legal *move* and does not perform
the full pre-/post-move capture search implemented in the Sage module.
The Tkinter help window also contains placeholder text.

## Rules and configuration

The large Sage code defaults to orthogonal circle movement and a
square-only decomposition of the pyramids, with 8 × 16 board coordinates.
Choose `pyramid_decomposition=True` for games that require individually
capturable pyramid components. Rithmomachia's arithmetic, geometric, and
musical progression victories are examined by separate functions.

Victory thresholds differ among implementations: for example, functions
in the SageMath code commonly default to four captured pieces or a value
of 100, while the Tkinter GUI uses 12 pieces or a value of 500. These are
**configuration choices**, not evidence that the implementations have
identical rule settings. Siege/blockade criteria also require reconciliation
between the Sage, Tkinter, and Godot programs.

## Corrections in `rithmomachia.py`

This Python/SageMath port is based on the later, August 2025 SageMath source
and includes these targeted changes:

- Convert Sage `^` exponent notation into standard Python `**`, introduce
  explicit Sage imports and polynomial-ring generators, and remove
  machine-specific image output directories.
- Validate the requested **start and destination** together, rather than
  accepting a destination reachable by an unrelated piece.
- Reject out-of-bounds moves before reading the matrix; allow explicit
  `validate=False` only for construction of test positions.
- Recognize occupied *intermediate* squares when checking potential captures.
- Normalize the incompatible legacy capture record formats to coordinate
  pairs and recompute available captures after board mutations.
- Treat a pyramid capture as removal of a specified subcomponent, or
  removal of the entire pyramid for a whole-pyramid capture or siege.
- Calculate goods-victory totals numerically, rather than calling
  `.degree()` on strings returned for display.
- Implement a color-symmetric Black musical-pattern check (the standard
  Black value set may not itself contain musical triples).

The original `.sage` file was removed from the root of `main` as part of the rename, but remains available on the `baseball` branch and in the repository's commit history.
The two extra four-term arithmetic-progression list functions in the newer
source are present for research; they do not change the three-piece
proper-victory rules.

## Tests and current verification status

The regression tests in [`tests/`](tests/) do **not** require SageMath.
They inspect and execute isolated function bodies with mocked board objects.

```bash
python -m unittest discover -s tests -v
python -m py_compile rithmomachia.py
```

**Limitations:** The isolated tests do not prove that the entire SageMath
module imports successfully under your installed Sage version or that the
full game, every capture variant, victory condition, GUI and animation flow
work end-to-end. That still needs a SageMath run and complete game
regression positions. The Godot scripts also need testing inside a
working Godot project. Please report reproducible issues with a board
position, rule variant, expected outcome, and observed outcome.

## Source and background

J. F. C. Richards, “Boissière's Pythagorean Game,” *Scripta
Mathematica* **12** (1946), 177–217.

This repository includes AI-assisted code revisions. Historical versions
and detailed source comments remain useful when checking the provenance
of individual rules.
