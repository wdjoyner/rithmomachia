"""Static position evaluation for the standard-Python Rithmomachia rules engine.

Adapted from rithmomachia-analysis2.py. Components have weights 40/25/25/10
(material, territory, harmony, capture), each normalized on its own scale.
Scores are heuristic, NOT winning probabilities. Positive favors White.

This module and the rules engine run under ordinary Python 3; the engine is imported lazily. A test
double can be supplied with engine=... to test the integration contract.
"""
from __future__ import annotations
from itertools import combinations

WEIGHTS = {"material": 40.0, "territory": 25.0, "harmony": 25.0, "captures": 10.0}
SIDES = ("white", "black")
TYPES = ("circles", "triangles", "squares", "pyramids")
PATTERNS = ("arithmetic", "geometric", "musical")
CAPTURE_METHODS = ("numbering", "addition", "subtraction", "multiplication",
                   "division", "siege")


def _engine(engine=None):
    if engine is None:
        import rithmomachia as engine
    return engine


def _side(player):
    if player not in SIDES:
        raise ValueError("player must be 'white' or 'black'")
    return player


def _positions(state, player, engine):
    get_positions = engine.positions_w if player == "white" else engine.positions_b
    return [(tuple(pos), poly) for pos, poly in get_positions(state)]


def _kind(poly):
    names = {str(variable) for variable in poly.variables()}
    if names & {"P", "p"}:
        return "pyramids"
    if names & {"C", "c"}:
        return "circles"
    if names & {"T", "t"}:
        return "triangles"
    if names & {"S", "s"}:
        return "squares"
    raise ValueError("Unrecognized piece polynomial: %r" % poly)


def _value(poly, engine):
    if _kind(poly) == "pyramids":
        # The core helper handles the remaining value after losing subpieces.
        data = engine._pyramid_data(poly)
        if data is None:
            raise ValueError("Could not decode pyramid %r" % poly)
        return int(data[1])
    return int(poly.degree())


def count_pieces(game_state, player, *, engine=None):
    """Count physical pieces; a pyramid is one piece, not many squares."""
    engine = _engine(engine)
    result = {kind: 0 for kind in TYPES}
    for _, poly in _positions(game_state, _side(player), engine):
        result[_kind(poly)] += 1
    result["total"] = sum(result.values())
    return result


def calculate_material(game_state, player, *, engine=None):
    """Count values by shape, including partly captured pyramids."""
    engine = _engine(engine)
    result = {kind: 0 for kind in TYPES}
    for _, poly in _positions(game_state, _side(player), engine):
        result[_kind(poly)] += _value(poly, engine)
    result["total"] = sum(result.values())
    return result


def territory_control(game_state, player, *, engine=None):
    """Opponent territory: White columns 8-15; Black columns 0-7."""
    engine = _engine(engine)
    player = _side(player)
    invading = []
    for pos, poly in _positions(game_state, player, engine):
        if pos[1] >= 8 if player == "white" else pos[1] < 8:
            invading.append({"position": pos, "shape": _kind(poly),
                             "value": _value(poly, engine), "piece": str(poly)})
    return {"pieces_in_enemy_territory": len(invading),
            "pieces_with_values": [(p["value"], p["position"]) for p in invading],
            "pieces": invading}


def _pattern_data(game_state, player, engine):
    rows = []
    for pos, _ in _positions(game_state, player, engine):
        values = frozenset(int(v) for v in engine.value_of_piece(game_state, *pos) if v > 0)
        rows.append({"position": pos, "values": values,
                     "in_enemy": pos[1] >= 8 if player == "white" else pos[1] < 8})
    return rows


def _complete(result):
    # bool((False, None)) is True: test the first element of engine results!
    return bool(result[0]) if isinstance(result, (tuple, list)) else bool(result)


def _two_distinct_in_enemy(pattern, rows):
    """Find two different invaders with two different pattern values.

    The remaining value must belong to a third surviving piece; otherwise
    the mathematical pattern is no longer attainable.
    """
    invading = [r for r in rows if r["in_enemy"]]
    for a, b in combinations(invading, 2):
        for first, second in combinations(pattern, 2):
            if ((first in a["values"] and second in b["values"]) or
                    (second in a["values"] and first in b["values"])):
                missing = next(v for v in pattern if v not in (first, second))
                if any(r["position"] not in (a["position"], b["position"])
                       and missing in r["values"] for r in rows):
                    return (first, second, missing)
    return None


def check_harmony_potential(game_state, player, *, engine=None):
    """Evaluate complete patterns and feasible two-of-three patterns.

    Complete: 100/100. Distinct feasible partial: +25, capped at 95/100.
    These numbers are scores, not probabilities. The existing engine's
    victory detectors determine whether a complete pattern has been achieved.
    """
    engine = _engine(engine)
    player = _side(player)
    rows = _pattern_data(game_state, player, engine)
    info = {kind + "_patterns": [] for kind in PATTERNS}
    info.update({"potential_score": 0, "complete": False, "partial_pattern_count": 0})
    partial_count = 0
    for kind in PATTERNS:
        stem = {"arithmetic": "arithmetical", "geometric": "geometrical",
                "musical": "musical"}[kind]
        catalog = getattr(engine, "list_%s_patterns_%s" % (stem, player))()
        detector = getattr(engine, "is_%s_pattern_%s" % (stem, player))
        key = kind + "_patterns"
        if _complete(detector(game_state)):
            info[key].append("Complete pattern (rules engine)")
            info["complete"] = True
            continue
        seen = set()
        for entry in catalog:
            pattern = tuple(sorted(int(value) for value in entry))
            if len(pattern) != 3 or len(set(pattern)) != 3 or pattern in seen:
                continue
            seen.add(pattern)
            match = _two_distinct_in_enemy(pattern, rows)
            if match:
                info[key].append("Partial %s; missing %s" % (pattern, match[2]))
                partial_count += 1
    info["partial_pattern_count"] = partial_count
    info["potential_score"] = 100 if info["complete"] else min(95, 25 * partial_count)
    return info


def count_capture_opportunities(game_state, player, *, engine=None):
    """Count available capture-METHOD records, including repeat targets.

    One target may have several capture mechanisms. Captures are counted in
    the current state, before any new move; no chain-capture search is done.
    """
    engine = _engine(engine)
    player = _side(player)
    by_method = {}
    for method in CAPTURE_METHODS:
        find = getattr(engine, "valid_captures_by_%s_%s" % (method, player))
        by_method[method] = len(find(game_state))
    return {"total": sum(by_method.values()), "by_method": by_method}


def _components(game_state, engine, include_captures):
    initial = engine.board_initial_matrix(pyramid_decomposition=True)
    first = {side: count_pieces(initial, side, engine=engine) for side in SIDES}
    pieces = {side: count_pieces(game_state, side, engine=engine) for side in SIDES}
    start_material = {side: calculate_material(initial, side, engine=engine)
                      for side in SIDES}
    material = {side: calculate_material(game_state, side, engine=engine)
                for side in SIDES}
    territory = {side: territory_control(game_state, side, engine=engine)
                 for side in SIDES}
    harmony = {side: check_harmony_potential(game_state, side, engine=engine)
               for side in SIDES}
    if include_captures:
        captures = {side: count_capture_opportunities(game_state, side, engine=engine)
                    for side in SIDES}
    else:
        captures = {side: {"total": 0, "by_method": {}, "skipped": True}
                    for side in SIDES}
    # Opposing armies have different initial absolute values: compare each
    # player's proportion of original material, not the raw material totals.
    wm = material["white"]["total"] / max(1, start_material["white"]["total"])
    bm = material["black"]["total"] / max(1, start_material["black"]["total"])
    wt = territory["white"]["pieces_in_enemy_territory"] / max(1, first["white"]["total"])
    bt = territory["black"]["pieces_in_enemy_territory"] / max(1, first["black"]["total"])
    wh = harmony["white"]["potential_score"]
    bh = harmony["black"]["potential_score"]
    wc, bc = captures["white"]["total"], captures["black"]["total"]
    scores = {
        "material_component": WEIGHTS["material"] * (wm - bm),
        "territory_component": WEIGHTS["territory"] * (wt - bt),
        "harmony_component": WEIGHTS["harmony"] * (wh - bh) / 100.0,
        "capture_component": (WEIGHTS["captures"] * (wc - bc) / max(1, wc + bc)
                              if include_captures else 0.0)
    }
    return {"pieces": pieces, "material": material, "start_material": start_material,
            "territory": territory, "harmony": harmony, "captures": captures,
            "scores": scores, "include_captures": include_captures}


def _advantage(components):
    score = sum(components["scores"].values())
    if score > 10:
        label = "Strong White Advantage"
    elif score > 5:
        label = "Moderate White Advantage"
    elif score > 1:
        label = "Slight White Advantage"
    elif score < -10:
        label = "Strong Black Advantage"
    elif score < -5:
        label = "Moderate Black Advantage"
    elif score < -1:
        label = "Slight Black Advantage"
    else:
        label = "Even Position"
    return {"score": score, **components["scores"], "advantage": label,
            "is_probability": False,
            "capture_score_included": components["include_captures"]}


def analyze_game_state(game_state, *, engine=None, include_captures=True):
    """Produce a detailed, symmetric White-and-Black analysis dictionary."""
    engine = _engine(engine)
    d = _components(game_state, engine, include_captures)
    return {
        "white_pieces": d["pieces"]["white"], "black_pieces": d["pieces"]["black"],
        "white_material": d["material"]["white"], "black_material": d["material"]["black"],
        "white_initial_material": d["start_material"]["white"]["total"],
        "black_initial_material": d["start_material"]["black"]["total"],
        "white_territory_control": d["territory"]["white"],
        "black_territory_control": d["territory"]["black"],
        "white_harmony_potential": d["harmony"]["white"],
        "black_harmony_potential": d["harmony"]["black"],
        "white_capture_opportunities": d["captures"]["white"],
        "black_capture_opportunities": d["captures"]["black"],
        "advantage": _advantage(d)
    }


def calculate_advantage(game_state, *, engine=None, include_captures=True):
    """Return signed score and its separate components; not a probability."""
    return _advantage(_components(game_state, _engine(engine), include_captures))


def display_analysis(game_state, *, engine=None, include_captures=True, file=None):
    """Print a position report and return the structured analysis."""
    import sys
    output = sys.stdout if file is None else file
    info = analyze_game_state(game_state, engine=engine, include_captures=include_captures)
    print("\n===== RITHMOMACHIA POSITION ANALYSIS =====", file=output)
    print("MATERIAL:", file=output)
    for side in SIDES:
        material = info[side + "_material"]
        start = info[side + "_initial_material"]
        count = info[side + "_pieces"]["total"]
        print("  %s: %s/%s (%s pieces)" %
              (side.capitalize(), material["total"], start, count), file=output)
    print("TERRITORY:", file=output)
    for side in SIDES:
        n = info[side + "_territory_control"]["pieces_in_enemy_territory"]
        print("  %s: %s pieces in enemy territory" % (side.capitalize(), n), file=output)
    print("HARMONY (heuristic, not win probability):", file=output)
    for side in SIDES:
        h = info[side + "_harmony_potential"]
        print("  %s: %s/100" % (side.capitalize(), h["potential_score"]), file=output)
        for kind in PATTERNS:
            for pattern in h[kind + "_patterns"]:
                print("    %s: %s" % (kind, pattern), file=output)
    print("CAPTURE OPPORTUNITIES:", file=output)
    for side in SIDES:
        cap = info[side + "_capture_opportunities"]
        description = ("not evaluated" if cap.get("skipped") else
                       "%s capture-method records" % cap["total"])
        print("  %s: %s" % (side.capitalize(), description), file=output)
    a = info["advantage"]
    print("OVERALL: %s (%+.2f)" % (a["advantage"], a["score"]), file=output)
    print("Components: " + ", ".join("%s %+.2f" % (kind, a[kind + "_component"])
          for kind in ("material", "territory", "harmony", "capture")), file=output)
    print("========================================\n", file=output)
    return info


def rank_moves(game_state, player, *, engine=None, top_n=5,
               max_candidates=None, include_captures=True):
    """One-ply STATIC ranking of legal board moves from player's viewpoint.

    Does not perform the pre-/post-move capture phases or opponent replies.
    max_candidates limits candidates in coordinate order, NOT by a prior score.
    include_captures=False is faster but changes the evaluation measure.
    """
    engine = _engine(engine)
    player = _side(player)
    if top_n is not None and top_n < 0:
        raise ValueError("top_n must be >= 0 or None")
    if max_candidates is not None and max_candidates < 0:
        raise ValueError("max_candidates must be >= 0 or None")
    moves = []
    for shape in ("circle", "triangle", "square", "pyramid"):
        generate = getattr(engine, "moves_%s_%s" % (shape, player))
        for move in generate(game_state, verbose=False):
            if len(move) == 2:
                moves.append((tuple(move[0]), tuple(move[1])))
    moves = sorted(set(moves))
    if max_candidates is not None:
        moves = moves[:max_candidates]
    before = calculate_advantage(game_state, engine=engine,
                                 include_captures=include_captures)["score"]
    sign = 1 if player == "white" else -1
    results = []
    for start, end in moves:
        if not engine.is_valid_move(game_state, start, end, player):
            continue
        after = engine.move_piece(game_state, start, end)
        if after == game_state:
            continue
        new = calculate_advantage(after, engine=engine,
                                  include_captures=include_captures)
        score = new["score"]
        results.append({"move": (start, end),
                        "score_for_player_after": sign * score,
                        "score_after_white_positive": score,
                        "score_change_for_player": sign * (score - before),
                        "advantage_after": new["advantage"]})
    results.sort(key=lambda item: (-item["score_for_player_after"], item["move"]))
    return results if top_n is None else results[:top_n]


def display_ranked_moves(game_state, player, *, engine=None, top_n=5,
                         max_candidates=None, include_captures=True, file=None):
    """Print and return static move rankings with score improvements."""
    import sys
    output = sys.stdout if file is None else file
    ranked = rank_moves(game_state, player, engine=engine, top_n=top_n,
                        max_candidates=max_candidates,
                        include_captures=include_captures)
    print("%s candidate moves:" % player.capitalize(), file=output)
    for i, item in enumerate(ranked, 1):
        start, end = item["move"]
        print("  %d. %s -> %s | score %+.2f | change %+.2f" %
              (i, start, end, item["score_for_player_after"],
               item["score_change_for_player"]), file=output)
    print("Moves are static; captures and opponent replies are not simulated.", file=output)
    return ranked
