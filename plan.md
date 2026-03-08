# Gerbil Fully Hosted on Chez Scheme — Master Plan

## Vision

Run Gerbil Scheme entirely on Chez Scheme, replacing the Gambit backend. This means:
- A Gerbil REPL (`gxi`) powered by Chez Scheme
- Gerbil's module system resolving and loading modules via Chez
- Gerbil's compiler (`gxc`) targeting Chez's native code generation
- The full `:std` library available to Gerbil programs

The gherkin compiler translates Gerbil source to Chez-compatible Scheme. The challenge is not just syntactic translation (which is ~100% done) but making the translated code **execute correctly** within a coherent runtime environment.

---

## Current Status (2026-03-07)

### Compilation (Gerbil → Chez translation)

| Component | Files | Forms | Rate | Status |
|-----------|-------|-------|------|--------|
| Runtime (14 files) | 14/14 | 668/668 | 100% | ✅ Compiles AND evaluates |
| Expander (9 files) | 9/9 | 372/372 | 100% | ✅ Compiles, eval not tested |
| Compiler (12 files) | 12/12 | 535/535 | 100% | ✅ Compiles, eval not tested |
| Core macros (10 files) | ~10/10 | ~98% | ~98% | Partially tested |
| Std library (~470 files) | ~445/470 | ~98.7% | ~98.7% | Compilation only |

### Evaluation (compiled code actually runs)

| Component | Status | Notes |
|-----------|--------|-------|
| Runtime | ✅ 31/31 checks pass | 5 expected eval errors (Gambit internals) |
| Expander | 🔲 Not started | Needs runtime + forward references |
| Compiler | 🔲 Not started | Needs runtime + expander |
| Core macros | 🔲 Not started | Needs expander |
| Std library | 🔲 Not started | Needs everything above |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Gerbil on Chez                           │
│                                                                 │
│  ┌───────────┐  ┌───────────┐  ┌──────────┐  ┌──────────────┐ │
│  │  Runtime   │  │  Expander  │  │ Compiler │  │  Std Library  │ │
│  │  14 files  │→│  9 files   │→│ 12 files  │  │  ~470 files   │ │
│  │           │  │           │  │          │  │              │ │
│  │ util      │  │ stx       │  │ base     │  │ :std/sugar   │ │
│  │ table     │  │ core      │  │ compile  │  │ :std/iter    │ │
│  │ mop       │  │ top       │  │ optimize │  │ :std/net     │ │
│  │ hash      │  │ module    │  │ driver   │  │ :std/db      │ │
│  │ syntax    │  │ stxcase   │  │ method   │  │ ...          │ │
│  │ eval      │  │ root      │  │          │  │              │ │
│  │ thread    │  │           │  │          │  │              │ │
│  │ ...       │  │           │  │          │  │              │ │
│  └─────┬─────┘  └─────┬─────┘  └────┬─────┘  └──────┬───────┘ │
│        │              │             │               │          │
│  ┌─────┴──────────────┴─────────────┴───────────────┴───────┐  │
│  │                  Chez Scheme Runtime                       │  │
│  │  gambit-compat.sls  │  types.sls  │  gherkin compiler     │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Dependency order:** Runtime → Expander → Core Macros → Compiler → Std Library

---

## Phase 1: Runtime Self-Hosting ✅ COMPLETE

**Goal:** All 14 runtime files compile and evaluate on Chez Scheme.

**Status:** Done. `tests/self-host-runtime.ss` — 31/31 checks pass, 0 failures.

**What works:**
- MOP (meta-object protocol) with class types, slot access, method dispatch
- Hash tables with eq/eqv/equal comparison
- Syntax objects (AST, identifiers, marks)
- Control flow (keyword dispatch, contract validation)
- C3 linearization
- Module interface system
- Eval/compilation dispatch stubs
- Thread type stubs

**What doesn't (5 expected eval errors):**
- `syntax-error "unsupported compilation target"` — intentional guard in mop.ss
- `define-syntax core-ast-case%` — requires full Gerbil expander, not available at bootstrap
- `seal-class! SyntaxError::t` — specialize-class needs fully bootstrapped method tables
- `set! ##readtable-setup-for-language!` — Chez treats this as immutable
- `define-type-of-thread` — Gambit-internal threading primitive

**Key infrastructure built:**
- `(compat types)` — gerbil-struct record type with type descriptors, `##structure-*` ops
- `(compat gambit-compat)` — 90+ `##` primitive mappings
- `(runtime *)` — util, table, mop, hash, eval, syntax, error modules
- Test harness pattern: compile via gherkin → write to /tmp → eval form-by-form → inject stubs

---

## Phase 2: Expander Evaluation — COMPLETE (36/37 checks pass)

**Goal:** The 9 expander files evaluate on Chez, producing a working syntax expander.

**Why this matters:** The expander is the heart of Gerbil. It transforms Gerbil source (with `def`, `defstruct`, `match`, `syntax-case`, modules) into core forms. Without it, you can't load Gerbil modules.

### 2.1 Bootstrap the eval environment

- [x] Load all 14 compiled runtime files into the interaction environment
- [x] Inject forward references for expander symbols
- [x] Save/restore hash AND symbolic-table operations (compiled code overwrites native Chez versions)
- [x] Create `tests/self-host-expander.ss` test harness

### 2.2 Compile and evaluate expander files in order

All 9 files compile and evaluate with 0 errors:
1. [x] `common.ss` — 3 compiled forms (1 expected eval skip: core-syntax-case defsyntax)
2. [x] `stx.ss` — 64 compiled forms, 0 errors
3. [x] `core.ss` — 106 compiled forms, 0 errors
4. [x] `top.ss` — 60 compiled forms, 0 errors
5. [x] `module.ss` — 62 compiled forms, 0 errors
6. [x] `compile.ss` — 31 compiled forms, 0 errors
7. [x] `root.ss` — 7 compiled forms, 0 errors
8. [x] `stxcase.ss` — 9 compiled forms, 0 errors
9. [x] `init.ss` — 6 compiled forms, 0 errors

### 2.3 Compiler fixes applied

1. **`core-syntax-case` expansion** — Expanded at compile time in gherkin (recursive pattern matching on syntax objects using `stx-pair?`, `stx-null?`, `identifier?`, `core-identifier=?`, `keyword?`).

2. **`with` struct destructuring** — Added support for `(with ((type-name f1 f2 ...) obj) body)` → `(let ([tmp obj]) (let ([f1 (##structure-ref tmp 1)] ...) body))`. Fixed 21 struct destructuring patterns across core.ss, module.ss, compile.ss.

3. **`@method` 0-arg dispatch** — Fixed `(@method method-name obj)` to compile as `(call-method obj 'method-name)` instead of `(slot-ref obj 'method-name)`. The 2-arg form is a method call, not field access (field access uses dotted syntax `(@method obj.field)`).

4. **Unchecked `&` accessors** — Both `defstruct` and `defclass` now generate `&name-field` and `&name-field-set!` unchecked accessors alongside the checked versions. Required by 39 unique `&` accessors across the expander files.

5. **Context constructor patching** — After root.ss loads, `make-top-context` and `make-root-context` are overridden to call `struct-instance-init!` with proper field values (id, table=hash-table-eq, super chain).

6. **Save/restore symbolic-table operations** — Extended the hash save/restore pattern to include `symbolic-table-ref`, `symbolic-table-set!`, `make-symbolic-table`, `class-slot-offset`, and `__class-slot-offset`. Required because compiled `table.ss` expects gerbil-structs but native slot tables are Chez records.

### 2.4 Verification

- [x] AST type defined and `make-AST` works
- [x] `syntax-e` works on AST objects
- [x] `identifier?` works
- [x] `current-expander-context` parameter defined
- [x] Binding types (binding::t, runtime-binding::t, syntax-binding::t) defined
- [x] `make-top-context` creates proper top-context with table and super chain
- [x] `make-root-context` creates proper root-context
- [x] `stx-map`, `genident`, `stx-pair?`, `stx-null?` work
- [x] `core-context-put!/get` work on contexts
- [x] `make-syntax-binding` and `make-runtime-binding` work
- [x] Expander types (special-form, expression-form) defined
- [x] Module types (module-import, module-export) defined
- [ ] `core-expand-expression` — requires method dispatch on expander structs (Phase 3 stretch)

---

## Phase 3: Core Macro Layer

**Goal:** The 10 core/ files evaluate, providing the full Gerbil surface syntax.

**Files:** `runtime.ss`, `sugar.ss`, `more-sugar.ss`, `more-syntax-sugar.ss`, `match.ss`, `mop.ss`, `contract.ss`, `module-sugar.ss`, `expander.ss`, `macro-object.ss`

These files define Gerbil's user-facing macros: `def`, `defstruct`, `defclass`, `match`, `with`, `using`, `defrules`, `when`, `unless`, `cond`, `and`, `or`, etc.

### 3.1 Strategy

Many of these macros are already handled natively by gherkin (we compiled them as part of the compiler's built-in transformations). The question is whether the **expander-based** versions work too, because user code may call them through the expander path.

- [ ] Compile all 10 core/ files through gherkin
- [ ] Evaluate in the environment with runtime + expander loaded
- [ ] Verify that macro expansion produces correct output for key forms:
  - `def`, `defstruct`, `defclass`, `defrule`, `defrules`
  - `match`, `with-catch`, `using`, `parameterize`
  - `for`, `for-each`, `map` sugar variants
  - `declare`, `begin-annotation`

### 3.2 Expected challenges

- Core macros use `(phi: +1 ...)` phase imports — compile-time evaluation. This requires the expander to be functional.
- `match` is a complex macro with many patterns. Gherkin handles match natively; the core/match.ss version must produce compatible expansions.
- `defstruct`/`defclass` in core/mop.ss generate method tables, type hierarchies, and slot accessors. Must produce types compatible with `(runtime mop)`.

---

## Phase 4: Module System

**Goal:** `(import :std/sugar)` works — Gerbil's module resolution, loading, and linking functions correctly on Chez.

### 4.1 Module resolution

- [ ] Implement `load-module` that maps Gerbil module paths to compiled files
- [ ] Map `:std/foo` → find `std/foo.ss`, compile via gherkin, evaluate
- [ ] Handle `(import (only-in ...) (except-in ...) (rename-in ...) (prefix-in ...))`
- [ ] Handle `(export #t)` re-exports
- [ ] Handle `prelude:` and `package:` headers

### 4.2 Module caching

- [ ] Cache compiled modules (don't recompile on every import)
- [ ] Track dependencies for incremental recompilation
- [ ] Store compiled forms in a Chez library path

### 4.3 Library path integration

- [ ] Set up `GERBIL_HOME` equivalent for Chez
- [ ] Map Gerbil package paths to filesystem locations
- [ ] Support `gerbil.pkg` package descriptors

### 4.4 Verification

- [ ] Import a simple module with exports
- [ ] Import a module that imports another module
- [ ] Import `:std/sugar` and use `defrules`
- [ ] Import `:std/iter` and use `for` loops

---

## Phase 5: Compiler on Chez

**Goal:** Gerbil's own compiler (`gxc`) runs on Chez, producing compiled output.

### 5.1 Strategy

The compiler translates expanded Gerbil to Gambit Scheme (C backend). For Chez hosting, we have two options:

**Option A: Retarget to Chez** — Modify Gerbil's compiler backend to emit Chez Scheme instead of Gambit. This is the "real" self-hosting path but is a large effort.

**Option B: Compiler as library** — Get the compiler's 12 files evaluating on Chez so the compilation logic is available, even if the actual code generation still targets Gambit-style output. This proves the compiler runs on Chez.

- [ ] Evaluate all 12 compiler files in the bootstrapped environment
- [ ] Verify compiler passes (optimization, method compilation, ssxi)
- [ ] Create a simple compilation test: expand + compile a Gerbil form

### 5.2 Expected challenges

- The compiler uses `syntax-case` extensively in pattern matching
- AST case analysis (`ast-case`) is expander-dependent
- Code generation refers to Gambit primitives — need compat layer or retarget
- Link-time code (`ssxi`) references compiler-specific metadata

---

## Phase 6: Standard Library

**Goal:** Key `:std` modules work on Chez.

### 6.1 Tier 1 — Pure Scheme modules (no FFI)

These modules are pure Gerbil/Scheme and should work once the module system is up:

- [ ] `:std/sugar` — syntax sugar
- [ ] `:std/iter` — iterators and `for` loops
- [ ] `:std/sort` — sorting
- [ ] `:std/misc/list` — list utilities
- [ ] `:std/misc/hash` — hash table utilities
- [ ] `:std/text/json` — JSON parsing/serialization
- [ ] `:std/text/hex` — hex encoding
- [ ] `:std/assert` — assertions
- [ ] `:std/error` — error types
- [ ] `:std/contract` — contracts
- [ ] `:std/coroutine` — coroutines (via delimited continuations)
- [ ] `:std/amb` — ambiguous operator
- [ ] `:std/values` — multiple values utilities

### 6.2 Tier 2 — Chez-portable system modules

These need some Chez-specific porting but no external C FFI:

- [ ] `:std/pregexp` — regular expressions (pure Scheme implementation)
- [ ] `:std/format` — formatted output
- [ ] `:std/getopt` — command line parsing
- [ ] `:std/logger` — logging
- [ ] `:std/event` — event handling (needs Chez threading)
- [ ] `:std/actor` — actor system (needs Chez threading)
- [ ] `:std/misc/ports` — port utilities
- [ ] `:std/misc/string` — string utilities
- [ ] `:std/misc/path` — path manipulation

### 6.3 Tier 3 — FFI-dependent modules

These use Gambit's FFI (`c-lambda`, `c-define-type`) and need Chez FFI equivalents:

- [ ] `:std/net/socket` — TCP/UDP sockets
- [ ] `:std/net/httpd` — HTTP server
- [ ] `:std/os/*` — OS interfaces (fd, signal, epoll, etc.)
- [ ] `:std/crypto` — cryptographic operations (OpenSSL bindings)
- [ ] `:std/db/sqlite` — SQLite bindings
- [ ] `:std/db/postgresql` — PostgreSQL bindings
- [ ] `:std/foreign` — foreign function interface
- [ ] `:std/xml` — libxml2 bindings

**Strategy:** Use Chez's own `(foreign)` or `(load-shared-object)` to bind the same C libraries. The Scheme-level API stays the same; only the FFI glue changes.

---

## Phase 7: REPL and Tooling

**Goal:** A working `gxi` REPL on Chez Scheme.

- [ ] `gerbil-runtime-init!` — initialize the runtime environment
- [ ] `gxi-main` — command-line parsing, file loading, REPL entry
- [ ] Interactive evaluation with module imports
- [ ] `load` and `include` support
- [ ] Error display with Gerbil-style formatting
- [ ] Tab completion and readline (if available)
- [ ] `gxc` — compile Gerbil files from command line

---

## Milestone Summary

| # | Milestone | Dependencies | Difficulty | Status |
|---|-----------|-------------|------------|--------|
| 1 | Runtime evaluates on Chez | None | Medium | ✅ Done |
| 2 | Expander evaluates on Chez | Phase 1 | Hard | 🔲 Next |
| 3 | Core macros work | Phase 2 | Medium | 🔲 |
| 4 | Module system works | Phase 2-3 | Hard | 🔲 |
| 5 | Compiler runs on Chez | Phase 2-4 | Medium | 🔲 |
| 6a | Pure std modules work | Phase 4 | Easy-Medium | 🔲 |
| 6b | System std modules work | Phase 4 | Medium | 🔲 |
| 6c | FFI std modules work | Phase 4 + FFI layer | Hard | 🔲 |
| 7 | gxi REPL on Chez | Phase 1-6a | Medium | 🔲 |

**Critical path:** Phase 1 → Phase 2 → Phase 4 → Phase 6a → Phase 7

Phase 3 and 5 can proceed in parallel once Phase 2 is done. Phase 6b-6c can proceed independently once the module system works.

---

## Technical Decisions

### What gherkin handles vs. what the expander handles

Gherkin's compiler natively transforms many Gerbil forms:
- `def`/`defstruct`/`defclass` → Chez `define` + MOP calls
- `match` → nested `cond`/`let` chains
- `defrules`/`defrule` → compile-time macro registration
- `@list`/`@method` → `list`/`call-method`
- `using`/`with`/`try`/`with-catch` → Chez equivalents
- Keyword arguments → positional `case-lambda`

For self-hosting, both paths must produce compatible output. During bootstrap, gherkin handles compilation. Once the expander is running, Gerbil's own macros take over.

### Chez vs. Gambit differences requiring compat layers

| Feature | Gambit | Chez | Resolution |
|---------|--------|------|------------|
| Structures | `##structure` (tagged vectors) | Records | `gerbil-struct` record type in `(compat types)` |
| Type tags | Type ID symbols | Record type descriptors | Symbol-based `##structure-instance-of?` |
| Threading | Green threads + `thread-yield!` | Native threads (SMP) | Stubs or Chez `(threads)` library |
| Keywords | `#!keyword` reader syntax | Keyword-object records | `(compat gambit-compat)` keyword-object type |
| FFI | `c-lambda`, `c-define` | `(foreign-procedure ...)` | Per-module FFI porting |
| Continuations | `##continuation-*` | Chez continuations | Compat wrappers |
| Hash tables | `##gc-hash-table` | `(hashtable ...)` | `(runtime hash)` wrapper |
| `##` primitives | Direct C access | Not available | `gambit-compat.sls` (90+ mappings) |

### Build system

Current: `scheme -q --libdirs .:src --program tests/<test>.ss`

Target:
```
gherkin build                  # compile all Gerbil sources
gherkin repl                   # start Gerbil REPL on Chez
gherkin compile file.ss        # compile a single file
```

---

## Files Reference

### Gherkin (our code)
```
src/compiler/compile.sls     — Gerbil → Chez compiler (main)
src/reader/reader.sls        — Gerbil reader
src/compat/gambit-compat.sls — ## primitive mappings
src/compat/types.sls         — gerbil-struct type system
src/runtime/util.sls         — utility functions
src/runtime/table.sls        — raw hash tables
src/runtime/mop.sls          — meta-object protocol
src/runtime/hash.sls         — high-level hash tables
src/runtime/eval.sls         — eval/compiler dispatch
src/runtime/syntax.sls       — syntax object support
src/runtime/error.sls        — error types
```

### Gerbil source (what we're compiling)
```
~/mine/gerbil/src/gerbil/runtime/   — 14 files, ~5500 lines
~/mine/gerbil/src/gerbil/expander/  — 9 files, ~4200 lines
~/mine/gerbil/src/gerbil/compiler/  — 12 files, ~8200 lines
~/mine/gerbil/src/gerbil/core/      — 10 files, ~8500 lines
~/mine/gerbil/src/std/              — ~470 files, ~100K lines
```

### Test harnesses
```
tests/self-host-runtime.ss   — Runtime evaluation (31 checks)
tests/self-host-expander.ss  — Expander evaluation (TODO)
tests/test-self-host.ss      — Compilation coverage tests
tests/test-*.ss              — Component tests (~20 files)
```
