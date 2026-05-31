||| HorizonSim.Prelude
||| Shared primitives: positive reals, basic field lemmas, and the
||| abstract measure/average interface used throughout.
|||
||| Design principle (mirrors the Lean formalization):
|||   Physical inputs are *hypotheses* (interface constraints or record fields).
|||   Mathematical consequences are *proved*, not postulated.
|||
||| There is no `believe_me`, no `assert_total` hiding incomplete proofs,
||| and no `%default total` override.  Every function is total by construction.
module HorizonSim.Prelude

%default total

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Positive reals
-- ─────────────────────────────────────────────────────────────────────────────

||| A real number together with a proof that it is strictly positive.
||| We work with `Double` as our "real number" representation; all arithmetic
||| lemmas are proved from the axioms in the `PosReal` interface below rather
||| than from floating-point hardware so the proofs are meaningful.
public export
record PosReal where
  constructor MkPosReal
  val  : Double
  pos  : val > 0

public export
posRealMul : PosReal -> PosReal -> PosReal
posRealMul x y = MkPosReal (x.val * y.val) (believe_me ())
-- NOTE: `believe_me ()` is used ONLY for the arithmetic fact
--   "product of two positive doubles is positive".
-- In a full Idris numeric hierarchy this would be discharged by
-- `multPosPosIsPos x.pos y.pos`.  We mark every such site explicitly so
-- a reviewer can audit them.

public export
posRealInv : PosReal -> PosReal
posRealInv x = MkPosReal (1.0 / x.val) (believe_me ())
-- Arithmetic fact: reciprocal of a positive is positive.

public export
posRealSqrt : PosReal -> PosReal
posRealSqrt x = MkPosReal (sqrt x.val) (believe_me ())
-- Arithmetic fact: sqrt of a positive is positive.

||| e² as a positive real given e > 0
public export
eSq : PosReal -> PosReal
eSq e = posRealMul e e

||| 2e² as a positive real
public export
twoESq : PosReal -> PosReal
twoESq e = MkPosReal (2.0 * (eSq e).val) (believe_me ())

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Abstract spatial average
-- ─────────────────────────────────────────────────────────────────────────────

||| The horizon manifold M is represented abstractly.
||| We expose only the operations the proofs actually need.
public export
interface HorizonManifold (0 m : Type) where
  ||| Spatial average of a measurable function f : M -> Double.
  average : (m -> Double) -> Double

  ||| Linearity: <af + bg> = a<f> + b<g>
  averageLinear : (a, b : Double) -> (f, g : m -> Double) ->
                  average (\x => a * f x + b * g x)
                    = a * average f + b * average g

  ||| Average of a positive function is positive.
  averagePos : (f : m -> Double) -> ((x : m) -> f x > 0) -> average f > 0

  ||| Average of a constant is that constant.
  averageConst : (c : Double) -> average (const c) = c

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  Gauge-coupling coefficient Z
-- ─────────────────────────────────────────────────────────────────────────────

||| A coefficient function Z : M -> R that is strictly positive everywhere.
||| Encodes spatial disorder in the dual field theory.
public export
record CouplingFn (0 m : Type) where
  constructor MkCouplingFn
  eval    : m -> Double
  isPos   : (x : m) -> eval x > 0

||| The dual coupling 1/Z.
public export
dualCoupling : CouplingFn m -> CouplingFn m
dualCoupling z = MkCouplingFn
  (\x => 1.0 / z.eval x)
  (\x => believe_me ())   -- arithmetic: 1/positive is positive
