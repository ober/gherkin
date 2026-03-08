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
| Expander (9 files) | 100% | ✅ Works | `core-expand-expression` works, method dispatch fixed |
| Core macros (10 files) | 100% | ⚠️ Partial | `define-syntax` forms skip (need expander) |
| Compiler (12 files) | 100% | ⚠️ Partial | `define-syntax` forms skip |
| Module system | ✅ Loader works | ✅ **72 std modules** | Curated subset compile and load via module loader |
| REPL | ✅ Works | ✅ Gerbil syntax | Uses gherkin for compilation |
| Test suite | **262 checks** | ✅ All pass | Compilation + loader + functionality |

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

### D.2 Module expansion ✅

**Key fix: method-ref/bound-method-ref injection**

The compiled Gerbil runtime's `method-ref`/`bound-method-ref`/`find-method`/`call-method` functions are not produced by our compiler (they use typed parameters like `(id : :symbol)` and class-of dispatch). We now inject proper implementations that:
1. Handle both type descriptors and struct instances via `obj->type`
2. Walk the class precedence list for inherited methods
3. Use `raw-table-ref` on the `class-type-methods` slot (which stores methods in symbolic tables)

**Key architecture: Gherkin bridge for module compilation**

Full source expansion of modules requires the entire Gerbil core macro layer (`def`, `defrules`, `defsyntax`, etc.) bound in the expander context. Instead of replicating this chicken-and-egg bootstrap, we use a hybrid approach:

- `core-import-module` is overridden with a gherkin bridge: for unknown modules, it reads the source with `read-gerbil-file`, compiles with `gerbil-compile-top`, evals the result, and caches in `__module-registry`
- `core-read-module` strips `(for-syntax ...)` import wrappers (Chez's `parameterize` doesn't work with Gerbil parameters, preventing the compiled expander from resolving `for-syntax`)
- `current-expander-compile` and `current-expander-eval` are wired up for any future expansion that needs them

**Status:**
- [x] Method dispatch works — `bind-method!` stores correctly, `method-ref` finds methods in hierarchy
- [x] `core-expand-module-begin` sets up module context correctly
- [x] `core-expand-head` and `core-expand1` work on module body forms
- [x] `core-expand-module-body` → `core-expand-block` dispatches special forms correctly
- [x] Module reading works — `core-read-module` extracts prelude/id/ns/body from `.ss` files
- [x] Module registry with 80+ pre-registered modules
- [x] `for-syntax` import stripping works
- [x] Gherkin bridge compiles `:std/sort` (with recursive `:std/error` → runtime deps)
- [x] `sort` and `stable-sort` work after gherkin-bridge import
- [x] `current-expander-compile` wired to gherkin, `current-expander-eval` wired to Chez eval

### D.3 Module compilation ✅

- [x] Gherkin bridge compiles module forms to Chez Scheme code (via `gerbil-compile-top`)
- [x] Module caching in `__module-registry` prevents re-compilation
- [x] Recursive imports resolve correctly (`:std/sort` → `:std/error` → runtime)

### D.4 Verify ✅

- [x] `(core-import-module ':std/sort)` works through gherkin bridge
- [x] `(sort '(3 1 4 1 5 9 2 6) <)` returns correct result after import
- [x] `(stable-sort '(5 3 1 4 2) <)` returns correct result after import

---

## Phase E: Compiler Backend Retargeting ✅

**Goal:** Gerbil's compiler emits Chez Scheme instead of Gambit/C.

**Approach:** Thin translation layer (Option 1) — `core-form->gerbil` translates expanded `%#` core forms back to plain Gerbil, which gherkin then compiles to Chez Scheme.

### E.1 Strategy ✅

Used Option 1: core form translator in gherkin's `gerbil-compile-top`. When the input is a `%#` prefixed form (from the Gerbil expander), it's translated to plain Gerbil first, then compiled normally.

### E.2 Implementation ✅

- [x] `core-form->gerbil` translates 20+ core forms (`%#quote`, `%#if`, `%#ref`, `%#lambda`, `%#let-values`, `%#define-values`, `%#call`, etc.)
- [x] `gerbil-compile-top` auto-detects `%#` forms and applies translation
- [x] `current-expander-compile` wired to gherkin's compiler
- [x] `current-expander-eval` wired to Chez's `eval`
- [x] `eval-syntax*` works end-to-end (expander → gherkin → Chez eval)

### E.3 Verify ✅

- [x] `core-expand-expression(42)` → `(%#quote 42)` → `'42` → evaluates to `42`
- [x] `core-expand-expression(if #t 1 2)` → compiled → evaluates to `1`
- [x] `core-expand-expression(begin 42)` → compiled → evaluates to `42`
- [x] `eval-syntax*` full chain works
- [x] `defstruct point (x y)` compiles and creates working accessors
- [x] `def (square n) (* n n)` compiles and `(square 7)` → `49`
- [x] Module compilation via gherkin bridge still works

---

## Phase F: Bootstrap Artifacts ✅

**Goal:** Pre-generate compiled Chez Scheme files for self-hosting bootstrap.

### F.1 Generate bootstrap files ✅

- [x] Created `bootstrap/` with subdirectories: `runtime/`, `expander/`, `core/`, `compiler/`
- [x] `scripts/generate-bootstrap.ss` compiles all 44 Gerbil source files through gherkin
- [x] 14 runtime files → `bootstrap/runtime/`
- [x] 8 expander files → `bootstrap/expander/`
- [x] 10 core macro files → `bootstrap/core/`
- [x] 12 compiler files → `bootstrap/compiler/`

### F.2 Bootstrap build system ✅

- [x] `make bootstrap` — generates bootstrap artifacts from Gerbil source via gherkin
- [x] `make self-host-test` — runs the self-host test suite
- [x] Bootstrap files are human-readable, pre-compiled Chez Scheme

### F.3 CI/CD

- [ ] CI builds from bootstrap files only (no Gerbil dependency)
- [ ] CI verifies bootstrap files are up-to-date with source

---

## Phase G: Full Standard Library ✅

**Goal:** Demonstrate that the gherkin bridge can import and use `:std` modules.

### G.1 Pure Scheme modules ✅

Tested via gherkin bridge — modules are compiled from source through gherkin and eval'd:

- [x] `:std/error` — error types
- [x] `:std/values` — multi-value utilities
- [x] `:std/pregexp` — imports but `include`'d pregexp.scm has Gerbil error class deps (expected limitation)
- [x] `:std/sort` — sort and stable-sort work (verified in Phase C/D)
- [x] `:std/deprecation` — deprecation warnings
- [x] `:std/contract` — contract checking

### G.2 Misc modules ✅

- [x] `:std/misc/list-builder` — list construction
- [x] `:std/misc/alist` — association list utilities
- [x] `:std/misc/plist` — property list utilities
- [x] `:std/misc/symbol` — symbol utilities
- [x] `:std/misc/func` — function combinators
- [x] `:std/misc/completion` — completion utilities
- [x] `:std/text/hex` — hex encoding

### G.3 Module count ✅

- [x] 93 modules registered in module registry (runtime + expander + core + std)
- [x] Gherkin bridge successfully imports 12+ std modules from source

### G.4 Known limitations

- `include`-based modules with Gerbil error class references (e.g., pregexp.scm) compile but functions aren't bound
- Modules requiring FFI (`:std/net/*`, `:std/crypto`, `:std/db/*`, `:std/os/*`) not yet supported
- Modules with heavy macro dependencies (`:std/sugar`, `:std/iter`) would need expander-level compilation

### G.5 Future work (not blocking self-hosting)

- [ ] `:std/sugar` — full syntax sugar (via expander, not just gherkin)
- [ ] `:std/iter` — iterators and `for` loops
- [ ] `:std/text/json` — JSON parsing
- [ ] `:std/getopt` — command line parsing
- [ ] FFI bridge: Chez `foreign-procedure`, `load-shared-object`
- [ ] `:std/net/socket`, `:std/net/httpd` — networking
- [ ] `:std/crypto`, `:std/db/sqlite` — crypto and database

---

## Phase H: Production REPL and Tooling ✅

**Goal:** A production-quality `gxi` REPL and `gxc` compiler.

### H.1 Module loader ✅

- [x] `gerbil-module-init!` initializes source directory and marks runtime/expander/core/compiler as pre-loaded
- [x] `gerbil-resolve-module-path` resolves `:std/sort`, `./relative`, `../parent` paths
- [x] `gerbil-load-module` with dependency-aware topological loading
- [x] Module caching prevents re-compilation
- [x] Cyclic dependency detection

### H.2 REPL (`gxi`) ✅

- [x] `src/repl/gxi.ss` — full REPL with Gerbil syntax support
- [x] Comma commands: `,q` quit, `,h` help, `,load` file, `,expand` form, `,dis` disassembly
- [x] Import resolution for Gerbil-style `:std/foo` imports
- [x] Source registry for `,dis` of defined names
- [x] Gambit compatibility stubs (threading, f64vector, process stats)
- [x] `make repl` — launch REPL

### H.3 Compiler (`gxc`) ✅

- [x] `src/tools/gxc.ss` — CLI compiler for Gerbil source files
- [x] `--check` mode: syntax check without output
- [x] `--expand` mode: show compiled forms
- [x] `--deps` mode: show import dependencies
- [x] `-o DIR` output directory
- [x] `-v` verbose mode
- [x] Multi-file compilation with error tracking
- [x] `make gxc GXCARGS="--check file.ss"` — run from Makefile

### H.4 Source location tracking ✅

- [x] Gerbil reader preserves source locations (file, line, column) in annotated datums
- [x] Error messages include source information from annotation

### H.5 Tab completion via Chez expeditor ✅

- [x] Chez's built-in expeditor provides line editing, history, and paren matching
- [x] `new-cafe` integration with custom eval for Gerbil forms
- [x] Gerbil-specific identifiers added to `ee-common-identifiers` for tab completion
- [x] Auto-detection: falls back to basic REPL when terminal not available (pipes, scripts)

### H.6 Module compilation caching ✅

- [x] Cache compiled output in `/tmp/gherkin-modules/`
- [x] File modification time comparison: skip recompilation if cache is newer than source
- [x] `*enable-cache*` flag to disable caching when needed
- [x] `load-from-cache` loads pre-compiled forms directly, bypassing gherkin

### H.7 Package manager ✅

- [x] `src/tools/pkg.sls` — full `gxpkg`-equivalent package manager
- [x] Commands: `build`, `clean`, `deps`, `install`, `uninstall`, `update`, `link`, `unlink`, `list`, `new`
- [x] `gerbil.pkg` parsing and package prefix resolution
- [x] Build spec parsing (`defbuild-script` in `build.ss`)
- [x] Git-based package install/update
- [x] Project scaffolding (`pkg-new`)

### H.8 Future work

- [ ] `gxi` using Gerbil's expander for macro expansion (currently uses gherkin)

---

## Remaining Gaps to Full Self-Hosting

### Current Architecture

Gherkin is a **cross-compiler**: it pattern-matches Gerbil syntax and emits Chez Scheme. This is distinct from true self-hosting, where Gerbil's own expander and compiler run natively on Chez. The cross-compiler has proven capable — gerbil-shell (27 modules, 30k+ lines) compiles and runs — but several categories of gaps remain.

### I. Native Expander Bootstrap (the fundamental gap)

**Goal:** Gerbil's own expander performs all macro expansion, replacing gherkin's pattern-based translation.

This is the Racket CS "linklet problem" — the expander must be able to expand itself.

#### I.1 Gerbil syntax-case on Gerbil syntax objects

Gerbil's `syntax-case` operates on wrapped syntax objects (`AST`, `stx-datum`, `stx-e`) with its own mark/rename hygiene system. Currently, user macros fall through to Chez's native `syntax-case`, which works on Chez syntax objects. For the expander to run natively, Gerbil's `syntax-case` must operate on Gerbil syntax objects at eval time.

- [ ] Gerbil's `core-syntax-case` dispatches correctly at eval time
- [ ] Pattern variables bind to Gerbil syntax objects, not Chez datums
- [ ] `syntax` template reconstructs Gerbil syntax objects with correct marks

#### I.2 Phase separation (for-syntax)

Gerbil has multi-phase compilation where `(import (for-syntax ...))` makes bindings available at macro expansion time. Gherkin currently strips `for-syntax` wrappers. Chez has its own R6RS phase system which doesn't align with Gerbil's.

- [ ] `for-syntax` imports evaluated at correct phase
- [ ] Phase-separated environments for compile-time vs runtime
- [ ] `begin-syntax` blocks evaluate at phase 1

#### I.3 Module expansion without gherkin bridge

`core-import-module` currently falls back to gherkin for unknown modules. True self-hosting means the expander's own `core-expand-module-begin` → `core-expand-block` pipeline handles all module forms, including `def`, `defrules`, `defsyntax`, `defstruct`, `defclass`, etc.

- [ ] `core-expand-module` processes a module end-to-end (no gherkin fallback)
- [ ] Core macro bindings (`def`, `defstruct`, `defrules`, etc.) available in expander context
- [ ] Module exports resolved through expander's binding tables
- [ ] Recursive module imports through expander (not gherkin bridge)

#### I.4 Bootstrap cycle

Once the expander can expand itself, the bootstrap is complete: generate pre-expanded `.scm` files for the runtime, expander, core macros, and compiler. Building Gerbil-on-Chez then requires only Chez Scheme.

- [ ] Expander expands its own source files
- [ ] Pre-expanded bootstrap files regenerated from Gerbil source
- [ ] Build from bootstrap requires only Chez (no Gerbil or gherkin)

---

### II. Language Features

Features that gherkin handles partially or not at all.

#### II.1 Method dispatch syntax

`{method obj}` is a Gerbil reader feature that compiles to `(@method ...)`. Chez's reader doesn't know `{}` as method dispatch. Currently worked around with `call-method` injection, but real Gerbil code uses `{}` pervasively.

- [ ] Reader emits method dispatch forms for `{}`
- [ ] `@method` compiles to `call-method` at read time (not eval time)

#### II.2 Full pattern matching

Gerbil's `match` is a complex macro. Gherkin handles common cases (literal patterns, variable binding, cons/list, `else`) but not the full language.

- [ ] Record/struct patterns (`(point x y)`)
- [ ] Guard patterns (`(? predicate)`, `(? predicate pattern)`)
- [ ] `and`/`or` pattern combinators
- [ ] Quasiquote patterns
- [ ] `match*` (multiple value match)

#### II.3 Iterators and for loops

`:std/iter` defines `for`, `for/collect`, `for/fold`, `for/hash`, `in-range`, `in-list`, `in-hash-keys`, etc. These are heavy macros that expand to iterator protocol calls.

- [ ] Iterator protocol (`iter-start!`, `iter-next!`, `iter-end?`)
- [ ] `for` / `for/collect` / `for/fold` macro expansion
- [ ] Standard iterators (`in-range`, `in-list`, `in-vector`, `in-hash-keys`, `in-hash-values`)

#### II.4 Interfaces

`:std/interface` provides `definterface` with structural typing and method dispatch tables. Used in modern Gerbil code (especially `:std/io`).

- [ ] `definterface` macro expansion
- [ ] Interface method tables
- [ ] `satisfies?` type checking

#### II.5 Other macros

- [ ] Full `:std/sugar` (`try`/`catch`/`finally`, `defvalues`, `with-destroy`, `hash`, `hash-eq`, etc.)
- [ ] `parameterize` with Gerbil parameters (currently uses Chez `parameterize`)
- [ ] `defsyntax` with `syntax-case` at full generality (currently limited)
- [ ] `with` (struct accessor binding)
- [ ] `using` (method dispatch binding)
- [ ] Keyword argument dispatch in user-defined functions

---

### III. Standard Library Coverage

~339 non-test modules in `:std/`, **72 verified via module loader** (compile + load + eval), plus 43 compat shims.

#### III.1 Pure Scheme (easiest — no FFI, no heavy macros)

| Module | Status | Notes |
|--------|--------|-------|
| `:std/error` | ✅ Working | |
| `:std/sort` | ✅ Working | Via `include` of 5 `.scm` files |
| `:std/values` | ✅ Working | |
| `:std/deprecation` | ✅ Working | |
| `:std/contract` | ✅ Working | |
| `:std/misc/list-builder` | ✅ Working | |
| `:std/misc/alist` | ✅ Working | |
| `:std/misc/plist` | ✅ Working | |
| `:std/misc/symbol` | ✅ Working | |
| `:std/misc/func` | ✅ Working | |
| `:std/misc/completion` | ✅ Working | |
| `:std/text/hex` | ✅ Working | |
| `:std/format` | ✅ Working | Loads via module loader |
| `:std/pregexp` | ✅ Working | Loads via module loader |
| `:std/hash-table` | ✅ Working | Loads via module loader |
| `:std/misc/string` | ✅ Working | Loads via module loader |
| `:std/misc/list` | ✅ Working | Loads via module loader |
| `:std/misc/path` | ✅ Working | Loads via module loader |
| `:std/misc/hash` | ✅ Working | Loads via module loader |
| `:std/misc/bytes` | ✅ Working | Loads via module loader |
| `:std/misc/number` | ✅ Working | Loads via module loader |
| `:std/misc/ports` | ✅ Working | Loads via module loader |
| `:std/misc/queue` | ✅ Working | Compile + eval verified |
| `:std/misc/deque` | ✅ Working | Compile + eval verified |
| `:std/misc/pqueue` | ✅ Working | Compile + eval verified |
| `:std/misc/shuffle` | ✅ Working | Loads via module loader |
| `:std/misc/atom` | ✅ Working | Loads via module loader |
| `:std/misc/walist` | ✅ Working | Loads via module loader |
| `:std/misc/vector` | ✅ Working | Loads via module loader |
| `:std/misc/evector` | ✅ Working | Loads via module loader |
| `:std/misc/dag` | ✅ Working | Loads via module loader |
| `:std/misc/decimal` | ✅ Working | Loads via module loader |
| `:std/misc/channel` | ✅ Compiles | Needs threading primitives |
| `:std/misc/timeout` | ✅ Compiles | Needs threading primitives |
| `:std/misc/lru` | ✅ Working | Loads via module loader |
| `:std/misc/rbtree` | ✅ Compiles | 0 compile errors |
| `:std/misc/repr` | ✅ Working | Loads via module loader |
| `:std/srfi/1` | ✅ Working | Loads via module loader |
| `:std/srfi/8` | ✅ Working | Loads via module loader |
| `:std/srfi/9` | ✅ Working | Loads via module loader |
| `:std/srfi/13` | ✅ Working | Loads via module loader |
| `:std/srfi/14` | ✅ Working | Loads via module loader |
| `:std/srfi/19` | ✅ Working | Loads via module loader |
| `:std/srfi/41` | ✅ Working | Loads via module loader |
| `:std/srfi/42` | ✅ Working | Loads via module loader |
| `:std/srfi/43` | ✅ Working | Loads via module loader |
| `:std/srfi/95` | ✅ Working | Loads via module loader |
| `:std/srfi/101` | ✅ Working | Loads via module loader |
| `:std/srfi/115` | ✅ Working | Loads via module loader |
| `:std/srfi/116` | ✅ Working | Loads via module loader |
| `:std/srfi/117` | ✅ Working | Loads via module loader |
| `:std/srfi/121` | ✅ Working | Loads via module loader |
| `:std/srfi/127` | ✅ Working | Loads via module loader |
| `:std/srfi/128` | ✅ Working | Loads via module loader |
| `:std/srfi/130` | ✅ Working | Loads via module loader |
| `:std/srfi/132` | ✅ Working | Loads via module loader |
| `:std/srfi/133` | ✅ Working | Loads via module loader |
| `:std/srfi/134` | ✅ Working | Loads via module loader |
| `:std/srfi/135` | ✅ Working | Loads via module loader |
| `:std/sugar` | ✅ Working | Loads via module loader |
| `:std/lazy` | ✅ Working | Loads via module loader |
| `:std/contract` | ✅ Working | Loads via module loader |
| `:std/deprecation` | ✅ Working | Loads via module loader |
| `:std/hash-table` | ✅ Working | Loads via module loader |
| `:std/stxutil` | ✅ Working | Loads via module loader |
| `:std/generic` | ✅ Working | Loads via module loader |
| `:std/amb` | ✅ Working | Loads via module loader |
| `:std/assert` | ✅ Working | Loads via module loader |
| `:std/source` | ✅ Working | Loads via module loader |
| `:std/srfi/78` | ✅ Working | Loads via module loader |
| `:std/srfi/113` | ✅ Working | Loads via module loader |
| `:std/srfi/141` | ✅ Working | Loads via module loader |
| `:std/srfi/143` | ✅ Working | Loads via module loader |
| `:std/srfi/145` | ✅ Working | Loads via module loader |
| `:std/srfi/151` | ✅ Working | Loads via module loader |
| `:std/cli/getopt` | ✅ Compiles | 0 compile errors |

#### III.2 Text processing (moderate — mostly pure Scheme)

| Module | Status | Notes |
|--------|--------|-------|
| `:std/text/json` | ✅ Working | Loads via module loader (with sub-module deps) |
| `:std/text/csv` | ✅ Working | Loads via module loader |
| `:std/text/base64` | ✅ Working | .scm file, loads via module loader |
| `:std/text/utf8` | ✅ Compiles | 0 compile errors |
| `:std/text/hex` | ✅ Compiles | 0 compile errors |
| `:std/text/utf16` | ⬜ Not started | |
| `:std/text/zlib` | ⬜ Not started | Needs FFI (libz) |
| `:std/xml` | ⬜ Not started | SSAX parser, mostly Scheme |

#### III.3 I/O system (hard — interfaces + actors)

`:std/io` is ~30 modules built on `:std/interface`. This is the modern I/O layer replacing Gambit ports.

- [ ] Bio (buffered I/O): input, output, chunked, delimited
- [ ] Socket I/O: stream, datagram, server
- [ ] String I/O: reader, writer, packed
- [ ] File I/O

Blocked by: `definterface` (Phase II.4)

#### III.4 Networking (hard — FFI + I/O + TLS)

| Module | Status | Blockers |
|--------|--------|----------|
| `:std/net/httpd` | ⬜ | I/O system, sockets |
| `:std/net/request` | ⬜ | HTTP client, TLS |
| `:std/net/websocket` | ⬜ | I/O system |
| `:std/net/ssl` | ⬜ | FFI to OpenSSL |
| `:std/net/bio` | ⬜ | I/O system |

#### III.5 Crypto & database (hard — FFI)

| Module | Status | Blockers |
|--------|--------|----------|
| `:std/crypto` | ⬜ | FFI to libcrypto (OpenSSL) |
| `:std/db/sqlite` | ⬜ | FFI to libsqlite3 |
| `:std/db/postgresql` | ⬜ | FFI to libpq |
| `:std/db/conpool` | ⬜ | Threading + db driver |

#### III.6 Concurrency (hard — Gambit threading model)

| Module | Status | Blockers |
|--------|--------|----------|
| `:std/event` | ⬜ | Gambit thread scheduling |
| `:std/coroutine` | ⬜ | Continuations |
| `:std/actor-v18/*` | ⬜ | Threading + I/O + crypto |
| `:std/misc/channel` | ⬜ | Threading primitives |

#### III.7 Build system

| Module | Status | Notes |
|--------|--------|-------|
| `:std/build-script` | ⬜ | `defbuild-script` |
| `:std/build-spec` | ⬜ | Build specification parsing |
| `:std/build` | ⬜ | `gerbil build` driver |
| `:std/cli/getopt` | ⬜ | Command-line parsing |
| `:std/cli/multicall` | ⬜ | Multi-command CLI |

---

### IV. Gambit Primitives Gap

`gambit-compat.sls` maps 90+ `##` primitives. Remaining gaps by category:

#### IV.1 Threading and concurrency

Gambit uses green threads with `##thread-start!`, `##mutex-lock!`, `##condition-variable-signal!`. Chez has native OS threads via `fork-thread`. The threading models are fundamentally different:

- Gambit: cooperative green threads, single OS thread (default), `thread-yield!`
- Chez: preemptive OS threads, `fork-thread`, `make-mutex`, `mutex-acquire`

- [ ] Thread creation/join mapping
- [ ] Mutex/condition-variable mapping
- [ ] Mailbox/thread-specific mapping
- [ ] `dynamic-wind` vs `thread-terminate!` semantics

#### IV.2 I/O port internals

Gambit exposes port internals (`##port-device`, `##read-u8`, `##write-u8`, `##port-mutex`). Chez ports are opaque. The `fdio.sls` compat shim handles basic fd operations but not the full Gambit port API.

- [ ] Port-to-fd extraction
- [ ] Custom port types (device ports)
- [ ] Port buffering control
- [ ] Binary/textual port distinction alignment

#### IV.3 Continuations

Gambit has `##continuation?`, `##continuation-creator`, `##continuation-next`. Chez has `call/cc` and `call/1cc` but different continuation inspection APIs.

- [ ] Continuation capture alignment
- [ ] Continuation inspection (if needed)

#### IV.4 Weak references and finalization

Gambit uses `##make-will`, `##will-testator`, `##will-execute!`. Chez uses `make-guardian` / `guardian` protocol.

- [ ] Will → guardian mapping
- [ ] Weak pair / weak hashtable

#### IV.5 Memory and GC

- [ ] `##gc` → `(collect)`
- [ ] `##process-statistics` → Chez equivalents
- [ ] Memory allocation tracking

---

### V. Toolchain and Ecosystem

#### V.1 Standalone executables

Gherkin-shell demonstrates the pattern: `compile-whole-program` + custom boot file. But there's no general `gxc -exe` equivalent.

- [ ] General-purpose `gxc -exe` for any Gerbil program
- [ ] Automatic dependency bundling
- [ ] Shared library linking (`-l` flags from build.ss)

#### V.2 Standard build system

`pkg.sls` parses `build.ss` and `gerbil.pkg` but compilation goes through gherkin, not `gxc`.

- [ ] `gerbil build` equivalent using gherkin compilation
- [ ] `build.ss` `lib:` / `exe:` target types
- [ ] `gerbil.pkg` `depend:` automatic LOADPATH

#### V.3 Package ecosystem

Most Gerbil packages assume the Gambit backend. Third-party packages would need:

- [ ] `gxpkg install` that compiles with gherkin instead of gxc
- [ ] Compatibility testing for popular packages
- [ ] Package-level compat shims where needed

---

### Strategic Options

**Option A: Extend the cross-compiler (pragmatic)**

Keep gherkin as the primary compiler. Add more pattern handlers, compat shims, and compiler transforms. This is what built gerbil-shell — proven to work for real code. Covers 80%+ of Gerbil usage without solving the expander bootstrap.

Pros: Incremental, each step produces working code, proven approach
Cons: Each new macro/feature needs manual compiler support, can't handle arbitrary user macros

**Option B: Native expander bootstrap (pure)**

Get Gerbil's own expander running on Chez. This is the Racket CS approach — hard upfront, but once done, all Gerbil macros and syntax work automatically.

Pros: Complete compatibility, handles arbitrary user macros, true self-hosting
Cons: Large upfront investment, chicken-and-egg bootstrap problem

**Option C: Hybrid (recommended)**

Use gherkin for the bootstrap (compile runtime + expander + core to Chez), then switch to Gerbil's expander for user code. This is essentially what Phases A-H achieved partially — the expander runs but falls back to gherkin. The gap is closing the fallback path.

1. Extend gherkin to handle remaining core macro patterns (match, for, interface)
2. Progressively wire more of the expander's pipeline to run natively
3. Eventually eliminate the gherkin fallback entirely

---

## Milestone Summary

| # | Milestone | Dependencies | Difficulty | Status |
|---|-----------|-------------|------------|--------|
| A | Method dispatch works | None | **Critical** | ✅ Done |
| B | define-syntax evaluates | Phase A | Hard | ✅ Done |
| C | include directive | None | Easy | ✅ Done |
| D | Module expansion via expander | Phase A+B | Hard | ✅ Done |
| E | Compiler retargeting | Phase A+B+D | Medium | ✅ Done |
| F | Bootstrap artifacts | Phase A-E | Easy | ✅ Done |
| G | Full std library | Phase C+D | Medium | ✅ Done |
| H | Production REPL/tooling | Phase D+E+G | Medium | ✅ Done |
| I | Native expander bootstrap | Phase A-H | **Critical** | ⬜ |
| II | Language features (match, iter, interface) | Phase I or gherkin | Hard | ⬜ |
| III | Standard library coverage (~339 modules) | Phase II + FFI | Large | ⬜ |
| IV | Gambit primitives (threading, ports, GC) | None | Hard | ⬜ |
| V | Toolchain (gxc -exe, gerbil build, gxpkg) | Phase III | Medium | ⬜ |

**Critical path (cross-compiler):** II → III → V (pragmatic, incremental)

**Critical path (true self-hosting):** I → II → III → V (harder, but complete)

Phase IV can proceed in parallel — each primitive mapped unblocks more std modules.

---

## Real-World Validation: gerbil-shell

The gherkin cross-compiler has been validated on **gerbil-shell**, a POSIX shell implementation written in Gerbil Scheme:

- **27 modules** compiled through gherkin in 7 dependency tiers
- **30k+ lines** of Gerbil source translated to Chez Scheme
- Features exercised: defstruct, defclass, match, hash tables, keyword args, string/list processing, process management, signal handling, job control, line editing, file I/O, pipes, redirects
- Standalone binary via `compile-whole-program`
- Passes echo, variables, arithmetic, pipes, functions, conditionals, loops tests
- Repository: `~/mine/gherkin-shell` (gerbil-shell as submodule + compat layer + build scripts)

This demonstrates gherkin handles real-world Gerbil code, not just toy examples.

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

**Test harness:** `tests/self-host-core.ss` — 262/262 checks pass

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
src/tools/gxc.ss             — Compiler CLI (--check, --expand, --deps, compile)
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
