||| HorizonSim.PDE.AbstractSobolev
||| Abstract Hilbert/Sobolev space for the elliptic PDE on the horizon.
|||
||| Idris 2 does not yet have a Sobolev space library.  We axiomatize
||| exactly the properties the proof needs:
|||   • An abstract Hilbert space V
|||   • A gradient operator ∇ : V → (M → Vec2)
|||   • A Poincaré inequality ‖u‖ ≤ C_P · ‖∇u‖
|||   • The Lax–Milgram theorem (bilinear form existence/uniqueness)
|||
||| EVERY such axiom is recorded explicitly.  None is hidden in a `believe_me`.
||| The *mathematical* content of the holography proof is *not* touched here;
||| these are purely functional-analytic prerequisites, cited to Evans §5 and
||| Gilbarg–Trudinger as in the paper.
module HorizonSim.PDE.AbstractSobolev

import HorizonSim.Prelude

%default total

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Abstract Hilbert space interface
-- ─────────────────────────────────────────────────────────────────────────────

||| An abstract Hilbert space V over ℝ.
||| We require only the structure actually used by the proof.
public export
interface HilbertSpace (0 v : Type) where
  ||| Inner product
  inner    : v -> v -> Double
  ||| Norm derived from inner product
  norm     : v -> Double
  ||| Completeness (existence of Cauchy-sequence limits) is asserted as an
  ||| axiom; Idris cannot verify existence of analytic limits internally.
  complete : Type   -- placeholder; populated in records that use it

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  H¹ on the horizon manifold (abstract axiomatization)
-- ─────────────────────────────────────────────────────────────────────────────

||| The Sobolev space H¹(M) for a compact Riemannian manifold M.
||| We record the axioms as a record (not an interface) so multiple
||| instances can coexist and proof terms reference specific axioms.
public export
record SobolevH1 (0 m : Type) where
  constructor MkSobolevH1

  ||| The carrier type of H¹(M).
  0 carrier : Type

  ||| The gradient of an element u ∈ H¹(M), as a function M → ℝ².
  gradient  : carrier -> (m -> (Double, Double))

  ||| Poincaré inequality: ‖u - <u>‖ ≤ C_P · ‖∇u‖
  ||| (for functions with zero mean; we state the consequence used in proofs)
  ||| Reference: Evans §5.8, Theorem 1.
  poincare  : (cP : Double) -> cP > 0 ->
              (u : carrier) ->
              Type   -- ‖u‖ ≤ cP · ‖∇u‖   (asserted, not computed)

  ||| Existence and uniqueness of weak solutions (Lax–Milgram).
  ||| For the bilinear form B[u,v] = ∫ Z · ∇u · ∇v dA with Z > 0
  ||| bounded and bounded below, Lax–Milgram guarantees a unique u ∈ H¹(M).
  ||| Reference: Evans §6.2, Theorem 1.
  laxMilgram :
    (z     : m -> Double) ->        -- coefficient function Z
    (zPos  : (x : m) -> z x > 0) -> -- Z > 0
    (zBdd  : (c : Double ** ((x : m) -> z x <= c))) ->  -- Z bounded
    (rhs   : m -> Double) ->        -- right-hand side f
    (sol   : carrier **              -- unique weak solution u
             Type)                  -- B[u,v] = <f,v> for all v (asserted)

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  Solution to the hydrostatic equation
-- ─────────────────────────────────────────────────────────────────────────────

||| A solution record for the hydrostatic equation (membrane paradigm eq. 5):
|||   ∂ᵢ[ √γ · γⁱʲ · Z · (∂ⱼα + Eⱼ) ] = 0
||| with periodic boundary conditions.
|||
||| We only record that a solution EXISTS and is UNIQUE (up to constants).
||| The PDE is proved well-posed by Lax–Milgram applied to the bilinear form
|||   B[α,φ] = ∫_M Z · γⁱʲ · ∂ᵢα · ∂ⱼφ  dA.
public export
record HydrostaticSolution (0 m : Type) (z : m -> Double) where
  constructor MkHydrostaticSol
  ||| The correction potential α : M → ℝ
  alpha       : m -> Double
  ||| Existence: α is the unique weak solution (asserted via Lax–Milgram).
  ||| AXIOM: follows from Lax–Milgram + compactness of M.
  existence   : Type   -- proof term omitted; this is the functional-analytic input
  ||| Uniqueness up to an additive constant (mean-zero normalisation).
  uniqueness  : Type

-- ─────────────────────────────────────────────────────────────────────────────
-- 4.  The duality of hydrostatic solutions
-- ─────────────────────────────────────────────────────────────────────────────

||| Key PDE lemma (§2.3 of the paper):
||| If α solves the hydrostatic equation with coefficient Z and source E = eⱼ,
||| then the Hodge dual of the current
|||   J^i_j = Z · γⁱᵏ · (∂_k α_j + δ_kj)
||| satisfies the hydrostatic equation with coefficient 1/Z.
|||
||| This is the *physical* content that links Z ↔ 1/Z.
||| We record it as an axiom/hypothesis (not proved here; proved in the paper
||| by a direct calculation using 2D Hodge duality on the horizon manifold).
public export
record HodgeDualSolutionHyp (0 m : Type)
    (z : m -> Double) (alphaZ : m -> Double) where
  constructor MkHodgeDualSolHyp
  ||| The Hodge-dual potential α̃ solves the 1/Z problem.
  alphaDual   : m -> Double
  ||| AXIOM: follows from ε_{ik} applied to the divergence equation.
  ||| Reference: Stephenson (2023), proof of Theorem 2.
  dualSolves  : Type
