from typing import (  # noqa: F401
    cast,
    List,
    Sequence,
    Tuple,
    Union,
)

from py_ecc.utils import (
    deg,
    prime_field_inv,
)


IntOrFQ = Union[int, "FQ"]


class FQ(object):
    """
    A class for field elements in FQ. Wrap a number in this class,
    and it becomes a field element.
    """
    n = None  # type: int
    field_modulus = None

    def __init__(self, val: IntOrFQ) -> None:
        if self.field_modulus is None:
            raise AttributeError("Field Modulus hasn't been specified")

        if isinstance(val, FQ):
            self.n = val.n
        elif isinstance(val, int):
            self.n = val % self.field_modulus
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(val))
            )

    def __add__(self, other: IntOrFQ) -> "FQ":
        if isinstance(other, FQ):
            on = other.n
        elif isinstance(other, int):
            on = other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

        return type(self)((self.n + on) % self.field_modulus)

    def __mul__(self, other: IntOrFQ) -> "FQ":
        if isinstance(other, FQ):
            on = other.n
        elif isinstance(other, int):
            on = other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

        return type(self)((self.n * on) % self.field_modulus)

    def __rmul__(self, other: IntOrFQ) -> "FQ":
        return self * other

    def __radd__(self, other: IntOrFQ) -> "FQ":
        return self + other

    def __rsub__(self, other: IntOrFQ) -> "FQ":
        if isinstance(other, FQ):
            on = other.n
        elif isinstance(other, int):
            on = other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

        return type(self)((on - self.n) % self.field_modulus)

    def __sub__(self, other: IntOrFQ) -> "FQ":
        if isinstance(other, FQ):
            on = other.n
        elif isinstance(other, int):
            on = other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

        return type(self)((self.n - on) % self.field_modulus)

    def __mod__(self, other: IntOrFQ) -> "FQ":
        raise NotImplementedError("Modulo Operation not yet supported by fields")

    def __div__(self, other: IntOrFQ) -> "FQ":
        if isinstance(other, FQ):
            on = other.n
        elif isinstance(other, int):
            on = other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

        return type(self)(
            self.n * prime_field_inv(on, self.field_modulus) % self.field_modulus
        )

    def __truediv__(self, other: IntOrFQ) -> "FQ":
        return self.__div__(other)

    def __rdiv__(self, other: IntOrFQ) -> "FQ":
        if isinstance(other, FQ):
            on = other.n
        elif isinstance(other, int):
            on = other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

        return type(self)(
            prime_field_inv(self.n, self.field_modulus) * on % self.field_modulus
        )

    def __rtruediv__(self, other: IntOrFQ) -> "FQ":
        return self.__rdiv__(other)

    def __pow__(self, other: int) -> "FQ":
        if other == 0:
            return type(self)(1)
        elif other == 1:
            return type(self)(self.n)
        elif other % 2 == 0:
            return (self * self) ** (other // 2)
        else:
            return ((self * self) ** int(other // 2)) * self

    def __eq__(self, other: IntOrFQ) -> bool:  # type:ignore # https://github.com/python/mypy/issues/2783 # noqa: E501
        if isinstance(other, FQ):
            return self.n == other.n
        elif isinstance(other, int):
            return self.n == other
        else:
            raise TypeError(
                "Expected an int or FQ object, but got object of type {}"
                .format(type(other))
            )

    def __ne__(self, other: IntOrFQ) -> bool:    # type:ignore # https://github.com/python/mypy/issues/2783 # noqa: E501
        return not self == other

    def __neg__(self) -> "FQ":
        return type(self)(-self.n)

    def __repr__(self) -> str:
        return repr(self.n)

    def __int__(self) -> int:
        return self.n

    @classmethod
    def one(cls) -> "FQ":
        return cls(1)

    @classmethod
    def zero(cls) -> "FQ":
        return cls(0)


class FQP(object):
    """
    A class for elements in polynomial extension fields
    """
    degree = 0  # type: int
    field_modulus = None
    mc_tuples = None  # type: List[Tuple[int, int]]

    def __init__(self,
                 coeffs: Sequence[IntOrFQ],
                 modulus_coeffs: Sequence[IntOrFQ]=None) -> None:
        if self.field_modulus is None:
            raise AttributeError("Field Modulus hasn't been specified")

        if len(coeffs) != len(modulus_coeffs):
            raise Exception(
                "coeffs and modulus_coeffs aren't of the same length"
            )

        # Not converting coeffs to FQ or explicitly making them integers for performance reasons
        if isinstance(coeffs[0], int):
            self.coeffs = tuple(coeff % self.field_modulus for coeff in coeffs)
        else:
            self.coeffs = tuple(coeffs)
        # The coefficients of the modulus, without the leading [1]
        self.modulus_coeffs = tuple(modulus_coeffs)
        # The degree of the extension field
        self.degree = len(self.modulus_coeffs)

    def __add__(self, other: "FQP") -> "FQP":
        if not isinstance(other, type(self)):
            raise TypeError(
                "Expected an FQP object, but got object of type {}"
                .format(type(other))
            )

        return type(self)([
            int(x + y) % self.field_modulus
            for x, y
            in zip(self.coeffs, other.coeffs)
        ])

    def __sub__(self, other: "FQP") -> "FQP":
        if not isinstance(other, type(self)):
            raise TypeError(
                "Expected an FQP object, but got object of type {}"
                .format(type(other))
            )

        return type(self)([
            int(x - y) % self.field_modulus
            for x, y
            in zip(self.coeffs, other.coeffs)
        ])

    def __mod__(self, other: Union[int, "FQP"]) -> "FQP":
        raise NotImplementedError("Modulo Operation not yet supported by fields")

    def __mul__(self, other: Union[int, "FQP"]) -> "FQP":
        if isinstance(other, int):
            return type(self)([
                int(c) * other % self.field_modulus
                for c
                in self.coeffs
            ])
        elif isinstance(other, FQP):
            b = [0] * (self.degree * 2 - 1)
            inner_enumerate = list(enumerate(other.coeffs))
            for i, eli in enumerate(self.coeffs):
                for j, elj in inner_enumerate:
                    b[i + j] += int(eli * elj)
            # MID = len(self.coeffs) // 2
            for exp in range(self.degree - 2, -1, -1):
                top = b.pop()
                for i, c in self.mc_tuples:
                    b[exp + i] -= top * c
            return type(self)([x % self.field_modulus for x in b])
        else:
            raise TypeError(
                "Expected an int or FQP object, but got object of type {}"
                .format(type(other))
            )

    def __rmul__(self, other: Union[int, "FQP"]) -> "FQP":
        return self * other

    def __div__(self, other: Union[int, "FQ", "FQP"]) -> "FQP":
        if isinstance(other, int):
            return type(self)([
                int(c) * prime_field_inv(other, self.field_modulus) % self.field_modulus
                for c
                in self.coeffs
            ])
        elif isinstance(other, type(self)):
            return self * other.inv()
        else:
            raise TypeError(
                "Expected an int or FQP object, but got object of type {}"
                .format(type(other))
            )

    def __truediv__(self, other: Union[int, "FQ", "FQP"]) -> "FQP":
        return self.__div__(other)

    def __pow__(self, other: int) -> "FQP":
        o = type(self)([1] + [0] * (self.degree - 1))
        t = self
        while other > 0:
            if other & 1:
                o = o * t
            other >>= 1
            t = t * t
        return o

    def optimized_poly_rounded_div(self,
                                   a: Sequence[IntOrFQ],
                                   b: Sequence[IntOrFQ]) -> Sequence[IntOrFQ]:
        dega = deg(a)
        degb = deg(b)
        temp = [x for x in a]
        o = [0 for x in a]
        for i in range(dega - degb, -1, -1):
            o[i] = int(o[i] + temp[degb + i] * prime_field_inv(int(b[degb]), self.field_modulus))
            for c in range(degb + 1):
                temp[c + i] = (temp[c + i] - o[c])
        return [x % self.field_modulus for x in o[:deg(o) + 1]]

    # Extended euclidean algorithm used to find the modular inverse
    def inv(self) -> "FQP":
        lm, hm = [1] + [0] * self.degree, [0] * (self.degree + 1)
        low, high = (
            cast(List[IntOrFQ], list(self.coeffs + (0,))),
            cast(List[IntOrFQ], list(self.modulus_coeffs + (1,))),
        )
        while deg(low):
            r = cast(List[IntOrFQ], list(self.optimized_poly_rounded_div(high, low)))
            r += [0] * (self.degree + 1 - len(r))
            nm = [x for x in hm]
            new = [x for x in high]
            # assert len(lm) == len(hm) == len(low) == len(high) == len(nm) == len(new) == self.degree + 1  # noqa: E501
            for i in range(self.degree + 1):
                for j in range(self.degree + 1 - i):
                    nm[i + j] -= lm[i] * int(r[j])
                    new[i + j] -= low[i] * r[j]
            nm = [x % self.field_modulus for x in nm]
            new = [int(x) % self.field_modulus for x in new]
            lm, low, hm, high = nm, new, lm, low
        return type(self)(lm[:self.degree]) / low[0]

    def __repr__(self) -> str:
        return repr(self.coeffs)

    def __eq__(self, other: "FQP") -> bool:     # type: ignore # https://github.com/python/mypy/issues/2783 # noqa: E501
        if not isinstance(other, type(self)):
            raise TypeError(
                "Expected an FQP object, but got object of type {}"
                .format(type(other))
            )

        for c1, c2 in zip(self.coeffs, other.coeffs):
            if c1 != c2:
                return False
        return True

    def __ne__(self, other: "FQP") -> bool:     # type: ignore # https://github.com/python/mypy/issues/2783 # noqa: E501
        return not self == other

    def __neg__(self) -> "FQP":
        return type(self)([-c for c in self.coeffs])

    @classmethod
    def one(cls) -> "FQP":
        return cls([1] + [0] * (cls.degree - 1))

    @classmethod
    def zero(cls) -> "FQP":
        return cls([0] * cls.degree)


class FQ2(FQP):
    """
    The quadratic extension field
    """
    degree = 2
    FQ2_MODULUS_COEFFS = None

    def __init__(self, coeffs: Sequence[IntOrFQ]) -> None:
        if self.FQ2_MODULUS_COEFFS is None:
            raise AttributeError("FQ2 Modulus Coeffs haven't been specified")

        self.mc_tuples = [(i, c) for i, c in enumerate(self.FQ2_MODULUS_COEFFS) if c]
        super().__init__(coeffs, self.FQ2_MODULUS_COEFFS)


class FQ12(FQP):
    """
    The 12th-degree extension field
    """
    degree = 12
    FQ12_MODULUS_COEFFS = None

    def __init__(self, coeffs: Sequence[IntOrFQ]) -> None:
        if self.FQ12_MODULUS_COEFFS is None:
            raise AttributeError("FQ12 Modulus Coeffs haven't been specified")

        self.mc_tuples = [(i, c) for i, c in enumerate(self.FQ12_MODULUS_COEFFS) if c]
        super().__init__(coeffs, self.FQ12_MODULUS_COEFFS)
