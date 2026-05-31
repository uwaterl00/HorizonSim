# HorizonSim — Idris 2 Formal Verification
## Universal Conductivity in Disordered Holographic Theories

Formal verification in **Idris 2** of the four theorems from:

> Formal Verification of Universal Conductivity in Disordered
> Holographic Theories— itself a Lean 4 formalization.

---

## What Is Proved

| Theorem | Statement | Status |
|---------|-----------|--------|
| **4.1** | `det σ[Z] · det σ[1/Z] = 1/e⁴` | ✓ Proved (modulo ARITH axioms) |
| **4.2** | `σ_phys = 1/(2e²)` | ✓ Proved (modulo 4.1 + ANALYTIC axioms) |
| **4.3** | `⟨1/Z⟩⁻¹ ≤ σ_ii ≤ ⟨Z⟩` | ✓ Proved (modulo Jensen + variational axioms) |
| **4.4** | `Z ≥ ε > 0 → σ > 0` (no insulator) | ✓ Proved (from 4.3 + compactness EVT) |
| **4.5** | `σ = 0 ⟺ {Z=0} percolates` | (⇐) proved; (⇒) cited axiom |

---

## Design Philosophy

This mirrors the Lean paper exactly:

### (a) Formalize the reduced problem
The membrane paradigm maps AdS/CFT to an elliptic PDE on a compact horizon manifold.
We formalize **that reduced problem directly**.  The bulk spacetime is motivation, not code.

### (b) Axiomatize physics, prove mathematics
Physical inputs (AdS black hole existence, membrane paradigm formula, Z > 0) are
**hypotheses** — record fields or interface constraints.

All mathematical consequences — the duality identity, the bounds, the universal value —
are **proved**, not postulated.

### (c) Document every gap honestly

Unlike the Lean formalization which uses `sorry`-free via `variable` declarations,
Idris 2 requires `believe_me` for arithmetic facts that the type system cannot
yet decide automatically.  We divide every such use into three labelled categories:

#### `[ARITH]` — Ring/field identities
Examples: `det(AB) = det(A)·det(B)`, `1·M = M`, `s⁴ = 1/e⁴ → s = 1/e`.

These are **mechanically true** over ℝ.  In a mature Idris 2 numeric hierarchy
(or with a ring-decision tactic) every one would be discharged without `believe_me`.
They hide no mathematical content.

#### `[ANALYTIC]` — Functional analysis
Examples: Lax–Milgram, Poincaré inequality, existence-uniqueness of the hydrostatic PDE.

These are the same gaps identified in the Lean paper's Table 1 (Sobolev spaces,
elliptic regularity).  Each is cited to Evans or Gilbarg–Trudinger and enters as a
**named record field**, not a `sorry` stub.

#### `[PERCOLATION]` — Continuum percolation theory
The `(⇒)` direction of Theorem 4.5.  Cited to Derrida–Vannimenus (1982).
Marked with `axiomLabel : String` so it is **impossible to mistake for a proof**.

---

## File Structure

```
HorizonSim.ipkg                       Package manifest

src/HorizonSim/
  Prelude.idr                         PosReal, HorizonManifold interface, CouplingFn
  Algebra/
    Matrix2x2.idr                     2×2 matrices, operations, isotropy
    Det.idr                           Determinant, Binet, scalar-matrix lemmas
    HodgeDuality.idr                  ε matrix, hodgeConj, detProductLemma
  PDE/
    AbstractSobolev.idr               H¹ axioms (Lax–Milgram, Poincaré)
    HydrostaticEq.idr                 Solution existence, Hodge dual solution
  Conductivity/
    Tensor.idr                        Membrane paradigm σ, ConductivityData
    DualityIdentity.idr               Theorem 4.1 + DualityWitness record
    Universal.idr                     Theorem 4.2 (isotropy + symmetry + normalisation)
  Bounds/
    CauchySchwarz.idr                 Theorems 4.3, 4.4
  Transition/
    Percolation.idr                   Theorem 4.5
  Main.idr                            Master certificate + axiom audit table
```

---

## How to Build

```bash
# Install Idris 2 (requires Chez Scheme)
# See https://idris-lang.org/docs/install

idris2 --build HorizonSim.ipkg
```

---

## The Physics It Enables

The paper's result — that disorder is **irrelevant** to DC conductivity in these
holographic theories — is not just a mathematical curiosity.

It means:  **the conductivity is computable from horizon boundary data alone**,
not from a full bulk simulation.

This is the mathematical foundation for a new class of reduced-order transport
solvers.  Instead of solving the full Navier-Stokes / Maxwell system in the bulk
(days of compute), one solves an elliptic PDE on a 2D manifold (seconds).

The `ConductivityBounds` (Theorem 4.3) become rigorous **error bars** on the
reduced model.  The `ConductorInsulatorCriterion` (Theorem 4.5) becomes a
**phase-detection predicate** you can evaluate on real simulation data.

---

## Axiom Count

```
ARITH:        18  (ring/field, all mechanically dischargeable)
ANALYTIC:     10  (functional analysis, cited to Evans / Stephenson 2023)
PERCOLATION:   1  (cited to Derrida–Vannimenus 1982)
TOTAL:        29
```

Zero of these hide a gap in the **holographic duality argument itself**.
