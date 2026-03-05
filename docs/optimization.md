# Chez Scheme Optimization Techniques for Gherkin

Techniques from the Chez Scheme compiler (v10.4.0) that can improve performance of Gerbil-to-Chez converted code.

## 1. Compiler Parameter Tuning

The most impactful knobs for compiled Gherkin output:

| Parameter | Default | Recommendation |
|-----------|---------|----------------|
| `optimize-level` | 2 | Use 3 for well-tested code (removes all type checks) |
| `cp0-effort-limit` | 200 | Increase to 500+ for generated code with deep nesting |
| `cp0-score-limit` | 20 | Increase to 50 to allow more aggressive inlining |
| `enable-type-recovery` | #t | Keep enabled — helps recover types after Gerbil wrapping layers |
| `enable-cross-library-optimization` | #t | Critical since Gherkin emits many small R6RS libraries |

Set these per-file in the compilation pipeline via `(eval-when (compile) ...)` for hot modules.

## 2. Record Type Flags

When compiling `defstruct`/`defclass` to Chez records, emit:

- **`(sealed #t)`** — prevents subclassing, enables direct field access without vtable indirection
- **`(immutable)` on fields** where Gerbil code never uses `set!` on slots — cp0 can then fold field accesses
- **`(nongenerative <uid>)`** — enables cross-library type identity and optimization

Currently the MOP uses `gerbil-struct` wrappers. For performance-critical structs, consider emitting native Chez `define-record-type` directly with these flags.

## 3. Numeric Specialization

Chez unboxes flonums at level 3 but only with explicit flonum ops:

```scheme
;; Generic (boxes intermediate results, GC pressure)
(+ (* x y) z)

;; Specialized (raw FPU instructions, no allocation)
(fl+ (fl* x y) z)
```

The compiler could emit `fx+`/`fl+` when type annotations are available from Gerbil's `def` forms (e.g., `(def (f (x : fixnum)) ...)`).

## 4. Local Binding Optimization

Chez's cp0 aggressively inlines **locally-bound, unassigned procedures**. Top-level `define`s across library boundaries are harder to optimize. This matters because Gherkin emits many small libraries.

**Actionable**: When a Gerbil helper function is only used in one place, emit it as a local `let` binding rather than a top-level `define`.

## 5. Type Guard Patterns

cp0 + cptypes recognize predicate-guarded branches:

```scheme
;; cptypes knows x is a pair in the consequent
(if (pair? x) (car x) ...)

;; cptypes knows x is a fixnum
(if (fixnum? x) (fx+ x 1) ...)
```

The `match` compiler already emits type tests — make sure the pattern is `(if (predicate? x) <then> <else>)` rather than intermediate wrappers that obscure the type information from cptypes.

## 6. Avoid the WPO Trap

WPO breaks `identifier-syntax` mutable export cells. But for pure-Scheme modules without mutable exports, WPO could still be applied selectively. Consider a build flag that enables WPO per-module.

## 7. Letrec Decomposition

Chez's `cpletrec` pass decomposes `letrec*` into simpler forms. Since Gerbil's top-level `def` forms compile to `letrec*` bodies in R6RS libraries, this pass is already working for you. But ordering matters — put pure definitions before impure ones to help cpletrec separate them.

## 8. Primitive Inlining Flags

Each Chez primitive has optimization flags (`pure`, `unrestricted`, `cp02`, `arith-op`, etc.) in `primdata.ss`. When the compat layer wraps Chez primitives (e.g., `hash-ref` wrapping `hashtable-ref`), the wrapper obscures these flags from the optimizer.

**Actionable**: For hot-path compat wrappers, consider:
- Using `define-syntax` + `syntax-rules` instead of `define` to make them transparent to cp0
- Or mark them with integration info if applicable

## 9. Closure Avoidance in Loops

Chez doesn't optimize closures allocated inside loops. The `for`/`for/collect` compilation should ensure lambda bodies are hoisted when they don't capture loop variables.

## 10. Quick Wins Checklist

- [ ] Add `(optimize-level 3)` option to gxc for release builds
- [ ] Emit `sealed` records for `defstruct` without known subclasses
- [ ] Emit `immutable` fields for non-mutated struct slots
- [ ] Emit `fx+`/`fx-` for integer arithmetic in type-annotated code
- [ ] Ensure `match` type tests are direct `(if (pred? x) ...)` — not wrapped
- [ ] Increase `cp0-effort-limit` for generated code (deep nesting from macro expansion)
- [ ] Consider selective WPO for pure modules without mutable exports
- [ ] Profile the compat wrappers (hash, MOP dispatch) — these are likely the hottest paths

## Summary

The biggest gains will come from **record type flags** (sealed/immutable), **optimize-level 3** for production builds, and **reducing compat wrapper overhead** in hot paths.
