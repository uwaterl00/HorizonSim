||| HorizonSim.PDE.HydrostaticEq
||| The hydrostatic equation on the horizon and its solution theory.
|||
||| Equation (5) in the paper:
|||   ∂ᵢ[ √γ · γⁱʲ · Z · (∂ⱼα + Eⱼ) ] = 0
|||
||| For each source direction j ∈ {1,2}, there is a unique (mean-zero)
||| solution α_j : M → ℝ.  We package these as a pair.
module HorizonSim.PDE.HydrostaticEq

import HorizonSim.Prelude
import HorizonSim.PDE.AbstractSobolev

%default total

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Current tensor
-- ─────────────────────────────────────────────────────────────────────────────

||| The current J^i_j = Z(x) · (δ^i_j + ∂^i α_j(x))
||| returned as a 2×2 matrix-valued function on M.
||| Row index = i (upper), column index = j (source direction).
public export
record CurrentTensor (0 m : Type) where
  constructor MkCurrentTensor
  ||| J^i_j(x)  for i,j ∈ {0,1} (zero-indexed)
  eval : m -> (Double, Double, Double, Double)
  -- (J^0_0, J^0_1, J^1_0, J^1_1)

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Solution existence (Lax–Milgram application)
-- ─────────────────────────────────────────────────────────────────────────────

||| Given a positive bounded coupling Z, the hydrostatic equation has
||| a unique weak solution for each source direction.
||| This is a direct application of Lax–Milgram; we record the result
||| as a hypothesis (the functional-analytic input to the theorem).
public export
record HydrostaticSolvable (0 m : Type)
    (z : m -> Double) where
  constructor MkHydrostaticSolvable
  ||| Solution for source E = e₁
  alpha1 : m -> Double
  ||| Solution for source E = e₂
  alpha2 : m -> Double
  ||| AXIOM (Lax–Milgram): both solutions exist and are unique up to constants.
  wellPosed : Type
  ||| AXIOM: Z > 0 implies the bilinear form is coercive (ellipticity).
  coercive  : (x : m) -> z x > 0 -> Type

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  The Hodge dual solution pair
-- ─────────────────────────────────────────────────────────────────────────────

||| Given solutions α₁, α₂ for Z, the Hodge-dual potentials α̃₁, α̃₂
||| solve the 1/Z problem.  This is the PDE step in the duality argument.
public export
record DualHydrostaticSol (0 m : Type)
    (z : m -> Double)
    (sol : HydrostaticSolvable m z) where
  constructor MkDualHydrostaticSol
  ||| Dual solutions
  alphaDual1 : m -> Double
  alphaDual2 : m -> Double
  ||| AXIOM: ε applied to the divergence equation gives the dual problem.
  ||| Reference: Stephenson (2023), §2.3.
  dualSolvesInvZ : Type
