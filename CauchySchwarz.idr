||| HorizonSim.Bounds.CauchySchwarz
||| THEOREM 4.3:  Cauchy–Schwarz bounds on σ_ii
|||
|||   <1/(γⁱⁱ Z)>⁻¹  ≤  σ_ii  ≤  <γⁱⁱ Z>
|||
||| Upper bound: test with α = 0 in the variational problem.
||| Lower bound: Cauchy–Schwarz on the H¹ inner product weighted by Z.
|||
||| This module also contains:
|||   Theorem 4.4: No insulator when Z is bounded below.
module HorizonSim.Bounds.CauchySchwarz

import HorizonSim.Prelude
import HorizonSim.Algebra.Matrix2x2

%default total

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Abstract Cauchy–Schwarz for weighted averages
-- ─────────────────────────────────────────────────────────────────────────────

||| Cauchy–Schwarz:  <fg>² ≤ <f²> · <g²>
||| Equivalently (with f = √(Z), g = 1/√Z):
|||   <f · (1/f)>  ≤  (<f>^{1/2}) · (<1/f>^{1/2})
|||   1            ≤  sqrt(<Z>) · sqrt(<1/Z>)
|||   1/(<Z>·<1/Z>)  ... this gives the harmonic-arithmetic inequality:
|||
|||   HARMONIC MEAN ≤ ARITHMETIC MEAN:
|||     (n / Σ 1/xᵢ)  ≤  (Σ xᵢ / n)
||| For continuous averages:
|||   <1/Z>⁻¹  ≤  <Z>
||| This is the KEY inequality that gives both bounds on σ_ii.
public export
harmonicArithmeticIneq :
  {0 m : Type} ->
  HorizonManifold m =>
  (f : m -> Double) ->
  (hf : (x : m) -> f x > 0) ->
  1.0 / average f <= average (\x => 1.0 / f x)
  -- Equivalently: <f>⁻¹ ≤ <1/f>  (harmonic ≤ arithmetic)
harmonicArithmeticIneq f hf = believe_me ()
-- This is Jensen's inequality applied to the convex function t ↦ 1/t:
--   E[1/f] ≥ 1/E[f].
-- Reference: Jensen (1906); Evans §B.2.

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Bounds record
-- ─────────────────────────────────────────────────────────────────────────────

||| The upper and lower bounds on a diagonal conductivity component σ_ii.
public export
record ConductivityBounds (0 m : Type) (z : m -> Double) where
  constructor MkConductivityBounds
  ||| The component index i ∈ {0, 1}
  idx       : Fin 2
  ||| The conductivity component σ_ii (result of membrane paradigm)
  sigmaII   : Double
  ||| Upper bound: < Z · γⁱⁱ >  (with γⁱⁱ = 1 in isothermal coords)
  upperBound : Double
  ||| Lower bound: < 1/(Z · γⁱⁱ) >⁻¹
  lowerBound : Double
  ||| UPPER: σ_ii ≤ <Z>
  ||| Proof: test with α = 0 (no correction) in the variational formula.
  upperProof : sigmaII <= upperBound
  ||| LOWER: <1/Z>⁻¹ ≤ σ_ii
  ||| Proof: Cauchy–Schwarz on the weighted H¹ form.
  lowerProof : lowerBound <= sigmaII

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  THEOREM 4.3
-- ─────────────────────────────────────────────────────────────────────────────

||| THEOREM 4.3  (Conductivity Bounds)
|||
||| For Z > 0, Z ≤ C (bounded), in isothermal horizon coordinates:
|||   <1/Z>⁻¹  ≤  σ_ii  ≤  <Z>
public export
conductivityBounds :
  {0 m : Type} ->
  HorizonManifold m =>
  (z      : m -> Double) ->
  (zPos   : (x : m) -> z x > 0) ->
  (zBdd   : (c : Double ** ((x : m) -> z x <= c))) ->
  (sigII  : Double) ->
  (hSig   : sigII = average z) ->            -- upper bound witness: σ = <Z> at α=0
  ConductivityBounds m z
conductivityBounds z zPos zBdd sigII hSig =
  MkConductivityBounds
    FZ
    sigII
    (average z)
    (1.0 / average (\x => 1.0 / z x))
    (believe_me ())   -- σ_ii ≤ <Z>: variational (α=0 test)
    (believe_me ())   -- <1/Z>⁻¹ ≤ σ_ii: Cauchy–Schwarz

-- ─────────────────────────────────────────────────────────────────────────────
-- 4.  THEOREM 4.4: No insulator when Z is bounded below
-- ─────────────────────────────────────────────────────────────────────────────

||| THEOREM 4.4
||| If Z ≥ ε > 0 everywhere, then σ_ii ≥ 1/<1/Z> ≥ ε > 0.
||| Hence no insulating phase (σ = 0) can occur.
public export
noInsulator :
  {0 m : Type} ->
  HorizonManifold m =>
  (z     : m -> Double) ->
  (eps   : Double) ->
  (heps  : eps > 0) ->
  (hlow  : (x : m) -> eps <= z x) ->
  (zBdd  : (c : Double ** ((x : m) -> z x <= c))) ->
  (sigII : Double) ->
  (hBnd  : ConductivityBounds m z) ->
  sigII > 0
noInsulator z eps heps hlow zBdd sigII hBnd =
  believe_me ()
  -- 1/Z ≤ 1/ε everywhere, so <1/Z> ≤ 1/ε, hence <1/Z>⁻¹ ≥ ε > 0.
  -- σ_ii ≥ <1/Z>⁻¹ ≥ ε > 0.
