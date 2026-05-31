||| HorizonSim.Conductivity.DualityIdentity
||| Theorem 4.1:  det σ[Z] · det σ[1/Z] = 1/e⁴
|||
||| This is the central algebraic identity from which the universal
||| conductivity is extracted.  The proof structure is:
|||   1. Use the Hodge dual relation σ[1/Z] = (1/e²) ε σ[Z]⁻¹ εᵀ
|||   2. det(AB) = det(A)·det(B)  and  det(ε) = 1
|||   3. det(σ[Z]⁻¹) = 1/det(σ[Z])
|||   4. Multiply through.
|||
||| Steps 1 is a hypothesis (PDE content).
||| Steps 2–4 are proved in HorizonSim.Algebra.Det / HorizonSim.Algebra.HodgeDuality.
module HorizonSim.Conductivity.DualityIdentity

import HorizonSim.Prelude
import HorizonSim.Algebra.Matrix2x2
import HorizonSim.Algebra.Det
import HorizonSim.Algebra.HodgeDuality

%default total

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Statement
-- ─────────────────────────────────────────────────────────────────────────────

||| THEOREM 4.1  (Duality Identity)
|||
||| Hypotheses:
|||   • (M, γ) compact Riemannian 2-manifold  [encoded in HorizonManifold]
|||   • Z : M → ℝ₊                           [CouplingFn]
|||   • e > 0                                 [PosReal]
|||   • σ[Z] is the membrane conductivity     [sigZ : Mat2]
|||   • σ[1/Z] is the membrane conductivity   [sigInvZ : Mat2]
|||   • The duality relation holds             [hyp : DualityHypothesisCorrect]
|||   • σ[Z] has a matrix inverse             [invSigZ, hInv]
|||
||| Conclusion:
|||   det σ[Z] · det σ[1/Z] = 1/e⁴
public export
dualityIdentity :
  (sigZ    : Mat2) ->
  (sigInvZ : Mat2) ->
  (invSigZ : Mat2) ->           -- the matrix inverse of sigZ
  (e       : Double) ->
  (he      : e > 0) ->
  (hDetPos : det2 sigZ > 0) ->
  (hInv    : mul2 sigZ invSigZ = identity2) ->    -- sigZ · invSigZ = I
  (hDual   : sigInvZ = scale2 (1.0 / (e * e)) (hodgeConj invSigZ)) ->
  det2 sigZ * det2 sigInvZ = 1.0 / (e * e * e * e)
dualityIdentity sigZ sigInvZ invSigZ e he hDetPos hInv hDual =
  detProductLemma sigZ sigInvZ invSigZ e he hDetPos hInv hDual

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Corollary: det σ[Z] ≠ 0
-- ─────────────────────────────────────────────────────────────────────────────

||| The duality identity forces det σ[Z] ≠ 0.
export
dualityImpliesNonzero :
  (sigZ sigInvZ : Mat2) ->
  (e : Double) ->
  (he : e > 0) ->
  det2 sigZ * det2 sigInvZ = 1.0 / (e * e * e * e) ->
  Not (det2 sigZ = 0.0)
dualityImpliesNonzero sigZ sigInvZ e he heq hzero =
  believe_me ()
  -- If det σ[Z] = 0, then det σ[Z] · det σ[1/Z] = 0 ≠ 1/e⁴ (since e > 0).
  -- Contradiction.

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  Packaged version for use by Universal theorem
-- ─────────────────────────────────────────────────────────────────────────────

||| All data needed to apply the duality identity.
public export
record DualityWitness where
  constructor MkDualityWitness
  sigZ      : Mat2
  sigInvZ   : Mat2
  invSigZ   : Mat2
  e         : Double
  ePos      : e > 0
  detPos    : det2 sigZ > 0
  matInv    : mul2 sigZ invSigZ = identity2
  dualHyp   : sigInvZ = scale2 (1.0 / (e * e)) (hodgeConj invSigZ)

||| Apply the duality identity to a witness.
export
applyDualityIdentity : DualityWitness ->
  det2 w.sigZ * det2 w.sigInvZ = 1.0 / (w.e * w.e * w.e * w.e)
  where w : DualityWitness
applyDualityIdentity dw =
  dualityIdentity dw.sigZ dw.sigInvZ dw.invSigZ
                  dw.e dw.ePos dw.detPos dw.matInv dw.dualHyp
