"""Sage-free compatibility objects for Rithmomachia's polynomial piece labels.

The eight formal symbols represent pieces, NOT general symbolic algebra.
The standard-library classes here implement precisely the polynomial methods
and board matrix access used by the historical Rithmomachia code.
Matplotlib is imported only when a graphic is rendered/saved.
"""
from __future__ import annotations
from fractions import Fraction
from math import sqrt

NAMES = ('c', 'C', 'p', 'P', 't', 'T', 's', 'S')
_ZERO = (0,) * len(NAMES)


class PiecePolynomial:
    """Immutable sparse integer polynomial with eight piece generators."""

    __slots__ = ('_terms',)

    def __init__(self, terms=None):
        self._terms = tuple(sorted((tuple(exp), int(value)) for exp, value in
                                   (terms or {}).items() if value))

    @classmethod
    def variable(cls, index):
        powers = list(_ZERO)
        powers[index] = 1
        return cls({tuple(powers): 1})

    @classmethod
    def coerce(cls, x):
        if isinstance(x, PiecePolynomial):
            return x
        if isinstance(x, int):
            return cls({_ZERO: x})
        raise TypeError('unsupported piece polynomial value: %r' % (x,))

    def __hash__(self):
        return hash(self._terms)

    def __eq__(self, other):
        if isinstance(other, (int, PiecePolynomial)):
            return self._terms == self.coerce(other)._terms
        return NotImplemented

    def __bool__(self):
        return bool(self._terms)

    def _binary(self, other, sign):
        other = self.coerce(other)
        terms = dict(self._terms)
        for exps, coefficient in other._terms:
            terms[exps] = terms.get(exps, 0) + sign * coefficient
        return PiecePolynomial(terms)

    def __add__(self, other):
        return self._binary(other, 1)

    __radd__ = __add__

    def __neg__(self):
        return PiecePolynomial({exp: -coeff for exp, coeff in self._terms})

    def __sub__(self, other):
        return self._binary(other, -1)

    def __rsub__(self, other):
        return self.coerce(other)._binary(self, -1)

    def __mul__(self, other):
        other = self.coerce(other)
        terms = {}
        for a, x in self._terms:
            for b, y in other._terms:
                exp = tuple(z + w for z, w in zip(a, b))
                terms[exp] = terms.get(exp, 0) + x * y
        return PiecePolynomial(terms)

    __rmul__ = __mul__

    def __pow__(self, power):
        if not isinstance(power, int) or power < 0:
            raise ValueError('piece polynomial exponents must be nonnegative integers')
        result = self.coerce(1)
        base = self
        while power:
            if power % 2:
                result = result * base
            base = base * base
            power //= 2
        return result

    def variables(self):
        found = {i for exp, _ in self._terms for i, power in enumerate(exp) if power}
        return tuple(PIECE_GENERATORS[i] for i in sorted(found))

    def exponents(self):
        return [exp for exp, _ in self._terms]

    def degree(self, variable=None):
        if not self._terms:
            return -1
        if variable is None:
            return max(sum(exp) for exp, _ in self._terms)
        variable = self.coerce(variable)
        if len(variable._terms) != 1:
            raise TypeError('degree requires a polynomial generator')
        (exp, coeff), = variable._terms
        if coeff != 1 or sum(exp) != 1:
            raise TypeError('degree requires a polynomial generator')
        return max(monomial[exp.index(1)] for monomial, _ in self._terms)

    def __repr__(self):
        if not self._terms:
            return '0'
        parts = []
        for exp, coeff in sorted(self._terms, key=lambda t: (-sum(t[0]), t[0])):
            factors = [name + ('^%d' % k if k != 1 else '')
                       for name, k in zip(NAMES, exp) if k]
            term = '*'.join(factors)
            if not term:
                term = str(abs(coeff))
            elif abs(coeff) != 1:
                term = str(abs(coeff)) + '*' + term
            parts.append(('-' if coeff < 0 else '+' if parts else '') + term)
        return ' '.join(parts).replace(' +', ' + ').replace(' -', ' - ')

    __str__ = __repr__


PIECE_GENERATORS = tuple(PiecePolynomial.variable(i) for i in range(len(NAMES)))


class PolynomialRing:
    def __init__(self, base=None, n=None, names=None, order=None):
        if isinstance(n, (tuple, list, str)) and names is None:
            names = n
        if isinstance(names, str):
            names = tuple(x.strip() for x in names.split(','))
        if names is not None and tuple(names) != NAMES:
            raise ValueError('Rithmomachia only supports its eight piece generators')
        if isinstance(n, int) and n != len(NAMES):
            raise ValueError('incorrect number of piece generators')

    def __call__(self, value):
        return PiecePolynomial.coerce(value)

    def gens(self):
        return PIECE_GENERATORS

    def objgens(self):
        return self, self.gens()


class _Integers:
    def __getitem__(self, variables):
        return PolynomialRing(names=NAMES)

    def __contains__(self, value):
        return isinstance(value, int)

    def __call__(self, value):
        return int(value)


ZZ = _Integers()
Integer = int
QQ = Fraction
Set = set
true = True
false = False


class BoardMatrix:
    """Dense mutable matrix with Sage-like M[i,j] indexing and copy semantics."""

    def __init__(self, rows, cols, values=None):
        self._rows, self._cols = int(rows), int(cols)
        if values is None or (isinstance(values, int) and values == 0):
            self._data = [[0 for _ in range(cols)] for _ in range(rows)]
        elif isinstance(values, BoardMatrix):
            if (rows, cols) != (values._rows, values._cols):
                raise ValueError('matrix dimensions differ')
            self._data = [row[:] for row in values._data]
        else:
            nested = list(values)
            if len(nested) != rows or any(len(row) != cols for row in nested):
                raise ValueError('incorrect matrix dimensions')
            self._data = [list(row) for row in nested]

    def __getitem__(self, key):
        if isinstance(key, tuple) and len(key) == 2:
            i, j = key
            if not 0 <= i < self._rows or not 0 <= j < self._cols:
                raise IndexError(key)
            return self._data[i][j]
        return self._data[key][:]

    def __setitem__(self, key, value):
        i, j = key
        if not 0 <= i < self._rows or not 0 <= j < self._cols:
            raise IndexError(key)
        self._data[i][j] = value

    def __copy__(self):
        return BoardMatrix(self._rows, self._cols, self)

    def __eq__(self, other):
        return isinstance(other, BoardMatrix) and self._data == other._data

    def __mul__(self, scalar):
        if not isinstance(scalar, int):
            return NotImplemented
        result = self.__copy__()
        result._data = [[p * scalar for p in row] for row in result._data]
        return result

    __rmul__ = __mul__

    def __iter__(self):
        return iter(self._data)

    def row(self, i):
        return self._data[i][:]

    def transpose(self):
        return BoardMatrix(self._cols, self._rows,
                           [list(col) for col in zip(*self._data)])

    def nrows(self):
        return self._rows

    def ncols(self):
        return self._cols

    def __repr__(self):
        return '\n'.join('[%s]' % (', '.join(str(p) for p in row))
                         for row in self._data)


class Mat:
    def __init__(self, ring, rows, cols):
        self.rows, self.cols = int(rows), int(cols)

    def __call__(self, values=None):
        return BoardMatrix(self.rows, self.cols, values)


MatrixSpace = Mat


def matrix(values):
    if isinstance(values, BoardMatrix):
        return values.__copy__()
    values = list(values)
    return BoardMatrix(len(values), len(values[0]), values)


class Graphics:
    """Composable drawing primitives with an optional Matplotlib renderer."""

    def __init__(self, primitives=()):
        self.primitives = list(primitives)
        self._axes = False

    def __add__(self, other):
        if other == 0:
            return self
        if not isinstance(other, Graphics):
            return NotImplemented
        return Graphics(self.primitives + other.primitives)

    __radd__ = __add__

    def __bool__(self):
        return bool(self.primitives)

    def axes(self, show=True):
        self._axes = bool(show)
        return self

    def _draw(self, ax):
        import matplotlib.patches as patches
        for kind, args, opts in self.primitives:
            color = opts.get('rgbcolor', opts.get('color', 'black'))
            edge = opts.get('edgecolor', opts.get('color', 'black'))
            fill = opts.get('fill', False)
            kw = {'alpha': opts.get('alpha', 1.0),
                  'linewidth': opts.get('thickness', 1.0),
                  'zorder': opts.get('zorder', 1)}
            if kind == 'circle':
                center, radius = args
                face = opts.get('facecolor', color)
                ax.add_patch(patches.Circle(center, radius, fill=fill,
                             ec=edge, fc=face if fill else 'none', **kw))
            elif kind == 'polygon':
                face = opts.get('facecolor', opts.get('rgbcolor', color))
                ax.add_patch(patches.Polygon(args[0], closed=True, fill=fill,
                             ec=edge, fc=face if fill else 'none', **kw))
            elif kind == 'line':
                xs, ys = zip(*args[0])
                ax.plot(xs, ys, color=color, lw=kw['linewidth'])
            elif kind == 'text':
                text_value, xy = args
                ax.text(*xy, str(text_value), ha='center', va='center',
                        color=color, fontsize=opts.get('fontsize', 12),
                        fontweight=opts.get('fontweight', 'normal'))
        ax.set_aspect('equal', adjustable='datalim')
        if not self._axes:
            ax.axis('off')

    def show(self, **kwargs):
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots()
        self._draw(ax)
        plt.show()
        return fig

    def save(self, filename, **kwargs):
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots()
        self._draw(ax)
        fig.savefig(filename, dpi=kwargs.get('dpi', 150), bbox_inches='tight')
        plt.close(fig)


def _graphic(kind, *args, **kwargs):
    return Graphics(((kind, args, kwargs),))


def circle(pt, radius, **kwargs):
    return _graphic('circle', pt, radius, **kwargs)


def polygon(vertices, **kwargs):
    return _graphic('polygon', vertices, **kwargs)


polygon2d = polygon


def text(string, pt, **kwargs):
    return _graphic('text', string, pt, **kwargs)


def line(vertices, **kwargs):
    return _graphic('line', vertices, **kwargs)


def show(plot, **kwargs):
    return plot.show(**kwargs)


def Color(value):
    return value


def latex(value):
    return str(value)


__all__ = ('PolynomialRing', 'Mat', 'MatrixSpace', 'matrix', 'BoardMatrix',
           'PiecePolynomial', 'ZZ', 'Integer', 'QQ', 'Set', 'true', 'false',
           'Graphics', 'circle', 'polygon', 'polygon2d', 'text', 'line',
           'show', 'Color', 'sqrt', 'latex')
