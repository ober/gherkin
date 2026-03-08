# Gerbil Fully Self-Hosted on Chez Scheme — Master Plan

## Vision

**True self-hosting**: Gerbil's own expander and compiler, running on Chez Scheme, can compile arbitrary Gerbil programs. Not just cross-compilation (gherkin translating Gerbil syntax to Chez), but the actual Gerbil toolchain running natively on Chez.

```
Gerbil source → Gerbil expander (on Chez) → Gerbil compiler (on Chez) → Chez native code
```

### Lessons from Racket CS

Racket's transition to Chez Scheme (2016–2021, led by Matthew Flatt) provides the blueprint:

1. **Rewrite subsystems in the high-level language first** — Racket rewrote the expander, I/O, threading, and regexp from C to Racket before touching Chez. This made them portable.

2. **Define a clean intermediate representation** — The "linklet" abstraction decoupled the expander from the compiler backend. Linklets are lambda-like blocks with imports/exports — no module semantics.

3. **Pre-generate bootstrap artifacts** — The `racket/src/cs/schemified/` directory contains human-readable, pre-expanded `.scm` files checked into Git. Building Racket CS only requires Chez Scheme, not an existing Racket.

4. **Build a "Rumble" layer** — A Chez Scheme library providing the primitives the higher layers expect (immutable hash tables, applicable structs, delimited continuations). Analogous to our `gambit-compat.sls`.

5. **Layer strictly** — Each layer must not reference layers above it. Enables independent compilation.

6. **Expect to patch the target Scheme** — Racket maintains a Chez fork with patches for `equal?` on records, immutable containers, and continuation support.

---

## Current State: Cross-Compilation Bootstrap

We have a working cross-compiler (gherkin) and bootstrap environment:

| Component | Compilation | Evaluation | Gap to Self-Hosting |
|-----------|-------------|------------|---------------------|
| Runtime (14 files) | 100% | ✅ Works | None — fully operational |
| Expander (9 files) | 100% | ✅ Works | `core-expand-expression` works (method dispatch fixed) |
| Core macros (10 files) | 100% | ⚠️ Partial | `define-syntax` forms skip (need expander) |
| Compiler (12 files) | 100% | ⚠️ Partial | `define-syntax` forms skip |
| Module system | ✅ Loader works | ✅ 14 std modules | Uses gherkin, not Gerbil's expander |
| REPL | ✅ Works | ✅ Gerbil syntax | Uses gherkin for compilation |

**Phase A complete**: `core-expand-expression` works — method dispatch on expander structs is fully operational. The fix required (1) injecting `##type` and `##closure?` Gambit primitives for hash table operations at eval time, and (2) replacing `{method obj}` syntax with `(call-method obj 'method)` in eval'd context constructors since `{}` isn't a Chez reader feature.

---

## Architecture: Target State

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Gerbil Self-Hosted on Chez                      │
│                                                                     │
│  ┌──────────────┐                                                   │
│  │ Gerbil Source │ .ss files                                        │
│  └──────┬───────┘                                                   │
│         │                                                           │
│  ┌──────▼───────┐  Uses syntax objects, contexts, bindings          │
│  │   Expander   │  core-expand-expression, syntax-case              │
│  │  (Gerbil's)  │  Module resolution, phase separation              │
│  └──────┬───────┘                                                   │
│         │  Produces core forms                                      │
│  ┌──────▼───────┐                                                   │
│  │   Compiler   │  compile-e, optimize, method compilation          │
│  │  (Gerbil's)  │  Retargeted: emit Chez Scheme instead of Gambit  │
│  └──────┬───────┘                                                   │
│         │  Produces Chez Scheme code                                │
│  ┌──────▼───────┐                                                   │
│  │  Chez Scheme │  Native compilation, GC, threads                  │
│  │   Runtime    │                                                   │
│  └──────────────┘                                                   │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              Chez-Side Support Layer                          │   │
│  │  gambit-compat.sls │ types.sls │ runtime/*.sls │ reader.sls  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase A: Fix Method Dispatch on Expander Structs

**Goal:** `core-expand-expression` works — method dispatch finds `apply-macro-expander` through the class hierarchy.

**Why this is the #1 blocker:** The entire expander revolves around `core-apply-expander`, which calls `(bound-method-ref K 'apply-macro-expander)`. This requires:

1. Expander struct types (`expression-form::t`, `core-expander::t`, etc.) have proper class hierarchy
2. `defmethod` forms in expander/core.ss actually call `bind-method!` at eval time
3. `bind-method!` correctly stores methods in the class's `methods` symbolic table
4. `method-ref` / `find-method` traverses the precedence list to find inherited methods
5. `bound-method-ref` wraps the found method in a closure

### A.1 Diagnose the exact failure ✅

- [x] Created `tests/test-method-dispatch.ss` with 6 diagnostic sections
- [x] Found: method dispatch chain (method-ref, bound-method-ref) works correctly
- [x] Found: `{method obj}` syntax doesn't work at Chez eval time (reader doesn't know `{}`)
- [x] Found: `##type` Gambit primitive not injected, causing hash table operations to fail at eval time
- [x] Found: `bind-core-syntax-expanders!` silently failed, leaving context table empty

### A.2 Fix the method dispatch chain ✅

Two fixes applied:

1. **Inject `##type` and `##closure?`** — These Gambit primitives are used by `eq-hash` (table.ss) and `procedure-hash`. Without them, any hash table lookup at eval time fails.

2. **Replace `{method obj}` with `(call-method obj 'method)`** — The `{}` method dispatch syntax is a Gerbil reader feature that compiles to `(@method ...)`. At Chez eval time, `{}` aren't method dispatch — they're just delimiters. Using `call-method` directly works.

### A.3 Verify core-expand-expression ✅

- [x] `core-expand1` works — single-step expansion
- [x] `core-expand-expression` on literal `42` — works
- [x] `core-expand-expression` on `(if #t 1 2)` — works
- [x] `resolve-identifier` finds core bindings (`if`, `begin`, etc.)
- [x] `core-apply-expander` dispatches correctly via `bound-method-ref`
- [x] Root context has 66 bindings (31 syntax + 34 macro + 1 features)

### A.4 Test ✅

- [x] `tests/test-method-dispatch.ss` — comprehensive diagnostics pass
- [x] `tests/self-host-core.ss` — **94/94 checks pass** (6 new Phase A checks)

---

## Phase B: Working define-syntax and syntax-case

**Goal:** `define-syntax` forms evaluate correctly, enabling Gerbil macros to work at runtime.

**Why:** Once the expander can expand expressions, `define-syntax` forms that define user macros need to work. These use `syntax-case` for pattern matching on syntax objects.

### B.1 syntax-case at runtime ✅

- [x] Chez's `syntax-case` works at eval time after restoring builtins
- [x] `core-syntax-case` handled by gherkin at compile time (no eval needed)
- [x] `defsyntax` with `syntax-case` body produces working `define-syntax (lambda ...)`

### B.2 define-syntax evaluation ✅

- [x] Fixed `defrules` multi-clause pattern — was duplicating macro name in pattern
- [x] `define-syntax` + `syntax-rules` works at eval time
- [x] `define-syntax` + `syntax-case` lambda works at eval time
- [x] Chez builtins restoration (`import (only (chezscheme) ...)`) after loading expander
  - Gerbil's expander redefines `syntax-rules`, `with-syntax`, `define`, `let`, `lambda` etc.
  - These Gerbil versions use Gerbil-specific helpers that don't work in eval environment
  - Restoring Chez originals enables user macros to work

### B.3 User macros work ✅

- [x] `defrules` → Chez `define-syntax (syntax-rules ...)` — works
- [x] `defsyntax` → Chez `define-syntax (lambda ...)` with `syntax-case` — works
- [x] Multi-clause `defrules` with `...` patterns — works
- [x] Sugar macros (`when`, `unless`, `and`, `or`, `while`) — work

---

## Phase C: Include Directive Support ✅

**Goal:** `(include "file.scm")` works, unblocking many std library modules.

### C.1 Implement include in gherkin ✅

- [x] Added `*current-source-dir*` parameter to `src/compiler/compile.sls`
- [x] `compile-include` resolves relative paths using `*current-source-dir*`
- [x] Module loader sets `*current-source-dir*` via `parameterize` around compilation
- [x] Chez builtins restoration in `gerbil-module-init!` — without this, `define-syntax` forms in include'd files fail because Gerbil's expander redefines `syntax-rules`

### C.2 Verify ✅

- [x] `:std/sort` loads and `(sort '(3 1 4 1 5 9 2 6) <)` returns `(1 1 2 3 4 5 6 9)`
- [x] `(stable-sort '(5 3 1 4 2) <)` returns `(1 2 3 4 5)`
- [x] All 5 include files compile inline: sort-support.scm, lmsort.scm, vhsort.scm, vmsort.scm, sortp.scm

---

## Phase D: Module Expansion via Gerbil's Expander

**Goal:** Gerbil's own `core-import-module` and `core-read-module` work on Chez, replacing our gherkin-based module loader.

**Why:** True self-hosting means Gerbil's module system handles imports, not our hand-rolled loader. This enables proper namespace management, phase separation, and `for-syntax` imports.

### D.1 Module reading ✅

- [x] `core-read-module` reads a `.ss` file and extracts prelude/namespace/package
- [x] `gerbil.pkg` files are parsed for package prefixes
- [x] Module paths resolve correctly (`:std/sort` → absolute path, `:std/error` → correct metadata)
- [x] Fixed `gerbil.pkg` dot-notation bug — compiler was treating `gerbil.pkg` variable as `(slot-ref gerbil 'pkg)` field access
- [x] Injected Gambit compat functions: `read-syntax-from-file` (via gherkin reader), `call-with-input-source-file`, `path-directory`, `path-strip-directory`, `gambit-path-expand`, `gambit-path-normalize`, `macro-datum-parsing-exception?`

### D.2 Module expansion

- [ ] `core-import-module` loads and expands a module through the expander
  - Requires prelude resolution (recursive module import)
  - Requires `core-expand-module-begin` to work
  - Requires module context creation with struct field access
- [ ] Import/export filtering works (only-in, except-in, rename-in, prefix-in)
- [ ] `for-syntax` imports load at the correct phase
- [ ] Module contexts are created with proper namespaces

### D.3 Module compilation

- [ ] Expanded module forms compile to Chez Scheme code
- [ ] Module caching prevents re-expansion
- [ ] Cyclic import detection works

### D.4 Verify

- [ ] `(import :std/sugar)` works through Gerbil's expander
- [ ] `(import :std/error)` works with proper type exports
- [ ] Modules that use `for-syntax` imports work

---

## Phase E: Compiler Backend Retargeting

**Goal:** Gerbil's compiler emits Chez Scheme instead of Gambit/C.

**Why:** Gerbil's compiler currently targets Gambit's C backend. For true self-hosting, it needs to emit Chez Scheme code that Chez can compile natively.

### E.1 Strategy choice

Two options:

**Option 1: Thin translation layer** — Intercept Gerbil's compiler output (which is Gambit Scheme) and translate to Chez. Similar to what gherkin already does, but as a post-pass on the compiler's output.

**Option 2: New Chez backend** — Add a new compilation target alongside the Gambit backend. The compiler's `compile-e` dispatch would have a Chez-specific code generator.

**Recommended: Option 1** — It's less invasive and leverages gherkin's existing translation logic.

### E.2 Implementation

- [ ] Hook Gerbil's `__compile-top` to use gherkin's `gerbil-compile-top` for code generation
- [ ] Translate compiler output (Gambit-flavored Scheme) to Chez Scheme
- [ ] Handle `##` primitives in generated code via gambit-compat mappings
- [ ] Handle Gambit-specific code generation patterns (C FFI calls, structure operations)

### E.3 Verify

- [ ] Compile a simple Gerbil module through Gerbil's compiler on Chez
- [ ] The compiled output runs on Chez
- [ ] Compile a module that uses defstruct and verify the output

---

## Phase F: Bootstrap Artifacts (Racket's Schemified Approach)

**Goal:** Pre-generate compiled Chez Scheme files and check them into Git, so building gherkin only requires Chez Scheme.

**Why:** Following Racket's approach — the `schemified/` directory contains human-readable, pre-expanded code. This breaks the bootstrap chicken-and-egg: you don't need Gerbil to build Gerbil-on-Chez.

### F.1 Generate bootstrap files

- [ ] Create `bootstrap/` directory in the repo
- [ ] Generate compiled `.sls` files for all runtime modules
- [ ] Generate compiled `.sls` files for all expander modules
- [ ] Generate compiled `.sls` files for core macro modules
- [ ] Generate compiled `.sls` files for compiler modules

### F.2 Bootstrap build system

- [ ] `make bootstrap` — build gherkin from pre-generated files (only needs Chez)
- [ ] `make regenerate` — regenerate bootstrap files from Gerbil source (needs working gherkin)
- [ ] Verify that bootstrap → regenerate → bootstrap produces identical output

### F.3 CI/CD

- [ ] CI builds from bootstrap files only (no Gerbil dependency)
- [ ] CI verifies bootstrap files are up-to-date with source

---

## Phase G: Full Standard Library

**Goal:** The complete `:std` library works on Chez.

### G.1 Pure Scheme modules (after include support)

- [ ] `:std/sugar` — full syntax sugar (via expander, not just gherkin)
- [ ] `:std/iter` — iterators and `for` loops
- [ ] `:std/sort` — with included sort implementations
- [ ] `:std/pregexp` — regular expressions
- [ ] `:std/format` — formatted output
- [ ] `:std/text/json` — JSON parsing
- [ ] `:std/getopt` — command line parsing
- [ ] `:std/srfi/1` — list library
- [ ] `:std/misc/*` — all misc utilities
- [ ] `:std/coroutine` — coroutines
- [ ] `:std/amb` — ambiguous operator

### G.2 System modules (Chez-specific porting)

- [ ] `:std/event` — event handling (Chez threading)
- [ ] `:std/actor` — actor system (Chez threading)
- [ ] `:std/logger` — logging
- [ ] `:std/misc/ports` — port utilities
- [ ] `:std/misc/path` — path manipulation

### G.3 FFI modules (Chez FFI)

- [ ] Implement Chez FFI bridge (`foreign-procedure`, `load-shared-object`)
- [ ] `:std/net/socket` — TCP/UDP
- [ ] `:std/net/httpd` — HTTP server
- [ ] `:std/crypto` — OpenSSL bindings
- [ ] `:std/db/sqlite` — SQLite
- [ ] `:std/os/*` — OS interfaces

---

## Phase H: Production REPL and Tooling

**Goal:** A production-quality `gxi` REPL and `gxc` compiler.

- [ ] `gxi` uses Gerbil's expander for macro expansion (not gherkin)
- [ ] `gxc` compiles Gerbil files to Chez Scheme libraries
- [ ] Tab completion via readline/linenoise
- [ ] Proper error reporting with source locations
- [ ] Module compilation caching (`.zo` equivalent)
- [ ] Package manager integration (`gxpkg` equivalent)

---

## Milestone Summary

| # | Milestone | Dependencies | Difficulty | Status |
|---|-----------|-------------|------------|--------|
| A | Method dispatch works | None | **Critical** | ✅ Done |
| B | define-syntax evaluates | Phase A | Hard | ✅ Done |
| C | include directive | None | Easy | ✅ Done |
| D | Module expansion via expander | Phase A+B | Hard | 🔨 In progress (D.1 done) |
| E | Compiler retargeting | Phase A+B+D | Medium | 🔲 |
| F | Bootstrap artifacts | Phase A-E | Easy | 🔲 |
| G | Full std library | Phase C+D | Medium | 🔲 |
| H | Production REPL/tooling | Phase D+E+G | Medium | 🔲 |

**Critical path:** A → B → D → E → F → H

Phase C can proceed in parallel with A/B. Phase G depends on C and D.

---

## Prior Work (Completed Phases 1-7)

The following phases established the cross-compilation bootstrap:

| Phase | Description | Result |
|-------|-------------|--------|
| 1 | Runtime self-hosting | 14/14 files compile and evaluate |
| 2 | Expander evaluation | 9/9 files compile and evaluate (minus core-expand-expression) |
| 3 | Core macro layer | 10/10 files compile and evaluate |
| 4 | Module system | Dependency-aware module loader |
| 5 | Compiler on Chez | 12/12 files compile and evaluate |
| 6 | Standard library | 14 std modules loaded |
| 7 | REPL and tooling | Working REPL with gherkin-based compilation |

**Test harness:** `tests/self-host-core.ss` — 112/112 checks pass

---

## Technical Reference

### Key Files

```
src/compiler/compile.sls     — Gerbil → Chez compiler (gherkin)
src/reader/reader.sls        — Gerbil reader
src/compat/gambit-compat.sls — 90+ ## primitive mappings
src/compat/types.sls         — gerbil-struct record type
src/runtime/*.sls            — MOP, hash, syntax, eval, error
src/module/loader.sls        — Module resolution and loading
src/repl/gxi.ss              — REPL entry point
```

### Gerbil Source (what we're compiling)

```
~/mine/gerbil/src/gerbil/runtime/   — 14 files
~/mine/gerbil/src/gerbil/expander/  — 9 files
~/mine/gerbil/src/gerbil/compiler/  — 12 files
~/mine/gerbil/src/gerbil/core/      — 10 files
~/mine/gerbil/src/std/              — ~470 files
```

### Build & Test

```bash
# Run all-phases test
scheme -q --libdirs .:src --program tests/self-host-core.ss

# Interactive REPL
scheme -q --libdirs .:src --program src/repl/gxi.ss

# Component tests
scheme -q --libdirs .:src --program tests/test-<component>.ss
```

### Method Dispatch Call Chain (the critical path)

```
core-expand-expression(stx)
  → resolve-identifier(stx)          # find binding for head symbol
  → core-apply-expander(K, stx)      # K = expander struct instance
    → bound-method-ref(K, 'apply-macro-expander)
      → method-ref(K, 'apply-macro-expander)
        → find-method(class-of(K), K, 'apply-macro-expander)
          → direct-method-ref(klass, K, 'apply-macro-expander)
            → symbolic-table-ref(class-type-methods(klass), 'apply-macro-expander)
          → mixin-method-ref(klass, K, 'apply-macro-expander)
            → walk precedence-list, try direct-method-ref on each
    → (method K stx)                  # call the found method
```

### Expander Type Hierarchy

```
expander (e)
├── core-expander (id compile-top)
│   ├── expression-form ()           ← if, lambda, quote, etc.
│   ├── special-form ()
│   │   ├── definition-form ()       ← define, define-syntax
│   │   └── top-special-form ()      ← begin, include
│   │       └── module-special-form () ← module
│   └── (methods: apply-macro-expander)
├── macro-expander ()
│   ├── rename-macro-expander ()
│   └── user-expander (context phi)  ← user-defined macros
└── (base method: apply-macro-expander → error)
```
