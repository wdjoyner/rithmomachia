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
| [`rithmomachia.py`](rithmomachia.py) | **Python 3 (no SageMath)** | Large, function-oriented rules, gameplay, computational, plotting, and animation implementation |
| [`position_analysis.py`](position_analysis.py) | SageMath Python | Static material/territory/harmony/capture analysis and one-ply move ranking |
| [`rithmomachia_compat.py`](rithmomachia_compat.py) | Python 3 standard library | Piece-polynomial and matrix support, plus optional Matplotlib drawing adapters |
| [`rithmo.py`](rithmo.py) | Python 3 + Tkinter | Shorter, object-oriented graphical game with an experimental computer opponent |
| [`godot-rithmo/`](godot-rithmo/) | Godot 4 / GDScript | Separate graphical implementation and rule-checking scripts |
| [historical `rithmomachia.sage` on `baseball`](https://github.com/wdjoyner/rithmomachia/blob/baseball/rithmomachia.sage) | SageMath (.sage format) | Previous repository version, preserved on the original branch and in Git history; not the corrected source |
| [`docs/`](docs/) | PDF and LaTeX | Background on the game and implementation notes |
| Blender/Matplotlib scripts in the root | Blender/Python | Board and pyramid animation experiments |

**The main engine is now ordinary Python.** The modules `rithmomachia.py` and
`position_analysis.py` import directly in Python 3 and do not depend on
SageMath. Historical Sage source is preserved on the `baseball` branch.

The intended development branch is named `main`. The old `baseball` and
`rithmomachia-tutor` branches remain in the repository. Changing the GitHub
default branch is a separate repository setting.

## Run the Python rules engine — no SageMath required

**Python 3.10 or newer** is sufficient to run the game rules, piece/capture
calculations, progressions, and position evaluator. You do **not** need
SageMath, SymPy, or NumPy for those features.

The new [rithmomachia_compat.py](rithmomachia_compat.py) supplies small Python
implementations of the eight piece-polynomial symbols and the 8 × 16 matrix.
It is intentionally limited to the operations used by this game, not a
general-purpose computer algebra system.

### macOS Terminal quick start

If you have already cloned the repository under ~/Projects, update it:

```bash
cd ~/Projects/rithmomachia
git switch main
git pull origin main
```

Otherwise clone it first:

```bash
mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/wdjoyner/rithmomachia.git
cd rithmomachia
```

Start a normal Python interpreter:

```bash
python3
```

At the Python >>> prompt, enter:

```python
import rithmomachia as r
import position_analysis as pa

G = r.board_initial_matrix(pyramid_decomposition=True)
pa.display_analysis(G)

# A quick ranking, without expensive capture-method evaluation:
pa.display_ranked_moves(G, "white", top_n=5, include_captures=False)
```

To run these instructions as a program, save the Python lines in a file such
as analyze.py in the repository root, then run `python3 analyze.py`.

For graphical board plots, install optional Python packages (still no Sage):

```bash
python3 -m pip install matplotlib numpy
```

Then, in Python:

```python
r.board_plot(G).save("rithmomachia_board.png")
```

Some more elaborate graphics and animation utilities remain experimental.

### Python exponent notation

Inside Python code use `C**6` or `S**36`; `C^6` remains a readable
piece **display** notation. The old `sage:` lines in historical function
docstrings are examples retained for context, not a Sage dependency.

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

The main Python engine defaults to orthogonal circle movement and a
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

This standard-Python port is based on the later, August 2025 SageMath source
and includes these targeted changes:

- Convert Sage `^` exponent notation into standard Python `**`, introduce
  explicit Python polynomial-ring generators, and remove
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
They include isolated logic probes, mock-engine evaluation tests, and **real
Python rules-engine integration tests** (initial board, legal moves, captures,
pyramid subpieces, mathematical progressions, and position ranking).

```bash
python3 -m unittest discover -s tests -v
python3 -m py_compile rithmomachia.py
```

**Limitations:** These tests prove the tested core operations run without Sage,
but they do not validate every historical rule variant, the entire game loop,
all multi-capture combinations, the Tkinter GUI, or every animation helper.
More comprehensive game and graphics regression tests are still needed.
The Godot scripts also need testing inside Godot. Please report reproducible issues with a board
position, rule variant, expected outcome, and observed outcome.

## Source and background

J. F. C. Richards, “Boissière's Pythagorean Game,” *Scripta
Mathematica* **12** (1946), 177–217.

This repository includes AI-assisted code revisions. Historical versions
and detailed source comments remain useful when checking the provenance
of individual rules.


## Position analysis

The Sage-free [position_analysis.py](position_analysis.py) adapts the attached
`rithmomachia-analysis2.py` evaluator, with material, territorial advancement,
mathematical harmony, and tactical capture opportunities. The existing move
ranking functions in `rithmomachia.py` are unchanged; the new evaluator is
complementary, not a replacement.

In a standard Python 3 session, from the repository root:

```bash
python3
```

```python
import rithmomachia as r
import position_analysis as pa

G = r.board_initial_matrix(pyramid_decomposition=True)
report = pa.display_analysis(G)                # complete position report
print(report["advantage"])                     # White-positive heuristic score

# Fast single-ply ranking of all legal White moves:
recommendations = pa.rank_moves(G, "white", top_n=5, include_captures=False)
for result in recommendations:
    print(result["move"], result["score_change_for_player"])

# Full evaluator (can be substantially slower):
recommendations = pa.rank_moves(
    G, "black", top_n=5, include_captures=True
)

# Optional: limit the positions examined when experimenting.
# max_candidates uses coordinate order, not a prior strength ranking.
# pa.rank_moves(G, "white", top_n=3, max_candidates=8)
```

All functions also accept an explicit `engine=r` parameter to simplify
testing. `analyze_game_state(G)` returns a dictionary with the same major keys
as the attached evaluator, including `white_material`,
`black_territory_control`, `white_harmony_potential`, and `advantage`.
`display_ranked_moves(G, "white")` prints recommended moves.

### What the position score measures

The signed score is **positive for White and negative for Black**.
The four component weights (40/25/25/10) are retained from the original
analysis proposal, but their definitions are normalized:

- **Material (40 points):** difference between each player's fraction of
  starting material still on the board. This corrects the fact that the two
  players begin with unequal *absolute* piece values. Pyramids count once;
  their remaining component value is respected.
- **Territory (25 points):** difference between the fractions of each
  player's original 24 pieces currently occupying enemy territory.
- **Harmony (25 points):** difference between each player's harmony-potential
  heuristic on a 0–100 scale. Complete patterns score 100, and feasible
  two-of-three patterns score 25 each, up to 95 if incomplete. Two separate
  physical pieces are required; the missing value must still be on the board.
  White and Black use the same scoring rule. The rules engine determines
  whether a complete pattern exists.
- **Captures (10 points):** normalized difference in available capture
  **method records**, not necessarily unique target pieces or guaranteed
  multi-capture sequences.

The combined score is a heuristic in approximately `[-100, 100]` — **not**
a probability of winning, a calibrated engine rating, or a proof of strategic
superiority. A completed pattern is reported as such, but the score does not
replace the configured victory thresholds or the official end-of-game check.

`rank_moves` evaluates only the state resulting from **one legal board move**.
It does **not** execute pre-move captures, post-move captures, chained captures,
or an opponent reply. In particular, it is not a complete-turn minimax engine.
`include_captures=False` omits the expensive capture component entirely,
so its scores should not be compared numerically with full evaluations.

Position analysis now runs against the real standard-Python rules engine.
Both integration and isolated regression tests use ordinary Python:

```bash
python -m unittest discover -s tests -v
python3 -m py_compile position_analysis.py
```

Complete-turn game testing across all rules variants and empirical calibration of the
heuristic weights remain future work.
