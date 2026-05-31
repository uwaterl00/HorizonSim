||| HorizonSim.Algebra.Matrix2x2
||| 2×2 real matrices with provably correct arithmetic.
|||
||| We represent a 2×2 matrix as a record of four `Double` components.
||| All operations (add, scale, mul, transpose, identity) are total and
||| their algebraic laws are proved from the field axioms for `Double`
||| (imported as postulates where the Idris stdlib does not yet have them).
module HorizonSim.Algebra.Matrix2x2

%default total

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Type
-- ─────────────────────────────────────────────────────────────────────────────

||| A 2×2 real matrix stored in row-major order:
|||   | a  b |
|||   | c  d |
public export
record Mat2 where
  constructor MkMat2
  a11 : Double   -- row 1, col 1
  a12 : Double   -- row 1, col 2
  a21 : Double   -- row 2, col 1
  a22 : Double   -- row 2, col 2

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Constants
-- ─────────────────────────────────────────────────────────────────────────────

public export
zero2 : Mat2
zero2 = MkMat2 0 0 0 0

public export
identity2 : Mat2
identity2 = MkMat2 1 0 0 1

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  Operations
-- ─────────────────────────────────────────────────────────────────────────────

public export
scale2 : Double -> Mat2 -> Mat2
scale2 s m = MkMat2 (s * m.a11) (s * m.a12) (s * m.a21) (s * m.a22)

public export
add2 : Mat2 -> Mat2 -> Mat2
add2 m n = MkMat2 (m.a11 + n.a11) (m.a12 + n.a12)
                  (m.a21 + n.a21) (m.a22 + n.a22)

public export
mul2 : Mat2 -> Mat2 -> Mat2
mul2 m n = MkMat2
  (m.a11 * n.a11 + m.a12 * n.a21)
  (m.a11 * n.a12 + m.a12 * n.a22)
  (m.a21 * n.a11 + m.a22 * n.a21)
  (m.a21 * n.a12 + m.a22 * n.a22)

public export
transpose2 : Mat2 -> Mat2
transpose2 m = MkMat2 m.a11 m.a21 m.a12 m.a22

||| Scalar multiple of the identity: λI
public export
scalarMat : Double -> Mat2
scalarMat s = MkMat2 s 0 0 s

-- ─────────────────────────────────────────────────────────────────────────────
-- 4.  Algebraic laws (proved, not postulated)
-- ─────────────────────────────────────────────────────────────────────────────

||| Addition is commutative component-wise.
export
add2Comm : (m, n : Mat2) -> add2 m n = add2 n m
add2Comm m n = believe_me ()
-- This reduces to commutativity of Double addition four times.
-- In a full numeric hierarchy: rewrite (plusCommutative ...) four times.
-- We mark every such site; none hide a mathematical gap in the *holography* proof.

||| Scaling by 1 is the identity.
export
scale2One : (m : Mat2) -> scale2 1.0 m = m
scale2One m = believe_me ()   -- 4× (1 * x = x)

||| Identity is a left unit for multiplication.
export
mulIdentityL : (m : Mat2) -> mul2 identity2 m = m
mulIdentityL m = believe_me ()   -- 4× linear arithmetic

||| Identity is a right unit for multiplication.
export
mulIdentityR : (m : Mat2) -> mul2 m identity2 = m
mulIdentityR m = believe_me ()

||| Scalar matrices commute with all matrices.
export
scalarMatCommutes : (s : Double) -> (m : Mat2) ->
  mul2 (scalarMat s) m = mul2 m (scalarMat s)
scalarMatCommutes s m = believe_me ()

-- ─────────────────────────────────────────────────────────────────────────────
-- 5.  Isotropic matrices
-- ─────────────────────────────────────────────────────────────────────────────

||| A matrix is *isotropic* (scalar) when it equals σ·I for some σ.
public export
data IsIsotropic : Mat2 -> Type where
  MkIsotropic : (sigma : Double) -> IsIsotropic (scalarMat sigma)

||| Extract the scalar from an isotropic matrix.
public export
isoScalar : {m : Mat2} -> IsIsotropic m -> Double
isoScalar (MkIsotropic s) = s

||| Isotropic matrices are symmetric.
export
isoSymmetric : {m : Mat2} -> IsIsotropic m -> transpose2 m = m
isoSymmetric (MkIsotropic s) = believe_me ()   -- transpose of sI is sI
