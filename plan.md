# Gherkin Compiler Gap Analysis & Completion Plan

## Methodology

Reviewed all 39 local `gerbil-*/` projects, the gherkin compiler (`src/compiler/compile.sls`),
runtime modules, compat shims in gherkin-shell/gherkin-lsp, and Chez Scheme capabilities.
Goal: identify everything needed to make gherkin handle all Gerbil/Gambit constructs used
across the local codebase (excluding FFI, which works differently in Gambit vs Chez).

---

## 1. MISSING STDLIB COMPAT MODULES

These `:std/*` modules are used by gerbil projects but have no compat shim or import mapping in gherkin:

| Module | Used By | Functions Needed |
|--------|---------|-----------------|
| `:std/test` | All projects (157 uses) | `test-suite`, `test-case`, `check`, `check-equal?`, `check-eq?`, `check-eqv?`, `check-true`, `check-false`, `check-raise`, `run-tests!`, `test-report-summary!` |
| `:std/text/json` | gerbil-llm, gerbil-es-proxy, gerbil-lsp | Already in gherkin-lsp compat, but **not in the default import map** |
| `:std/text/base64` | gerbil-crypto | `base64-encode`, `base64-decode`, `u8vector->base64-string`, `base64-string->u8vector` |
| `:std/text/hex` | gerbil-crypto | `hex-encode`, `hex-decode`, `u8vector->hex-string`, `hex-string->u8vector` |
| `:std/crypto/digest` | gerbil-crypto (9 uses) | `md5`, `sha1`, `sha256`, `digest->hex-string` |
| `:std/net/httpd` | gerbil-es-proxy | `http-register-handler`, `start-http-server!`, `http-response-write` |
| `:std/net/request` | gerbil-llm, gerbil-aws | `http-get`, `http-post`, `request-text`, `request-status` |
| `:std/db/dbi` | gerbil-persist | `sql-connect`, `sql-exec`, `sql-query`, `sql-close` |
| `:std/sync/completion` | gerbil-persist | `make-completion`, `completion-post!`, `completion-wait!` |
| `:std/sync/channel` | gerbil-persist | `make-channel`, `channel-put`, `channel-get` |
| `:std/misc/ports` | Multiple (30 uses) | `read-all-as-string`, `copy-port`, `with-output-to-string`, `read-all-as-u8vector` |
| `:std/misc/bytes` | gerbil-crypto | `u8vector-xor`, byte manipulation |
| `:std/misc/process` | Already in compat, but limited | `run-process` with `coprocess:` keyword |
| `:std/markup/xml` | gerbil-svg | XML/SXML parsing |
| `:std/xml` | gerbil-svg | `write-xml` (SXML serialization) |
| `:std/interface` | gerbil-charts, gerbil-tui | `interface`, `interface-out`, method dispatch |
| `:std/os/temporaries` | gerbil-lsp | `make-temporary-file-name` |
| `:std/build-script` | All projects | Build-time only, not needed at runtime |
| `:std/make` | All projects | Build-time only |

---

## 2. MISSING/INCOMPLETE LANGUAGE FORMS

### 2a. `interface` (Critical — used by gerbil-charts, gerbil-tui)

Gerbil's `interface` macro generates:
- An interface type descriptor
- Method stubs for dispatch via `{obj.method args}`
- `interface-out` export form that re-exports method bindings

**Current status:** Not handled by the compiler. The `@method` reader form (`{...}`) compiles to `call-method`/`slot-ref`, but there's no `interface` form compiler.

**What's needed:** Compile `interface` to a set of generic dispatch functions, or generate `defmethod`-compatible dispatchers.

### 2b. `defmethod` (Incomplete)

Only handles `{name type}` signature form. The more common form:
```scheme
(defmethod (render (self MyWidget) buf area)
  ...)
```
needs full compilation to `(method-set! MyWidget::t 'render (lambda (self buf area) ...))`.

### 2c. `match` (Incomplete patterns)

**Missing pattern types used across projects:**
- **Struct/class patterns:** `(match x ((MyStruct a b c) ...))` — used extensively in gerbil-tui, gerbil-charts
- **Nested patterns:** `(match x ([(a . b) c] ...))` — list-within-list
- **Quoted symbol patterns:** `(match x ('foo ...))`
- **Vector patterns:** `(match x (#(a b c) ...))`
- **`and`/`or` compound patterns:** `(match x ((and (? string?) s) ...))`
- **Guard patterns:** `(match x ((? (lambda (v) (> v 0)) n) ...))`
- **`apply` patterns:** for matching against constructors
- **Keyword argument patterns** in match clauses

### 2d. `let-hash` (Missing — 470 uses)

```scheme
(let-hash config
  .host    ;; => (hash-ref config 'host)
  .port)   ;; => (hash-ref config 'port)
```
Needs compilation to sequential `hash-ref` calls.

### 2e. `let/cc` (Missing — 60 uses)

```scheme
(let/cc return
  (when condition (return early-value))
  normal-result)
```
Needs compilation to `call-with-current-continuation`.

### 2f. `defvalues` (Missing — 56 uses)

```scheme
(defvalues (a b c) (values 1 2 3))
```
Needs compilation to `define-values` or `receive`.

### 2g. `awhen` / `aif` (Missing — anaphoric macros from `:std/sugar`)

```scheme
(awhen (find pred lst)   ;; binds result to `it`
  (process it))
```

### 2h. `and-let*` (Missing — from `:std/sugar`)

Short-circuiting let*:
```scheme
(and-let* ((x (maybe-value))
           ((positive? x)))
  (use x))
```

### 2i. `spawn` / `spawn/name` (Missing — 195 uses)

Thread creation:
```scheme
(spawn (lambda () (do-work)))
(spawn/name "worker" (lambda () (do-work)))
```
Needs compilation to threading primitives (Chez `fork-thread` or gherkin threading).

### 2j. `with-lock` (Missing)

Mutex-guarded execution:
```scheme
(with-lock mutex (lambda () body))
```

---

## 3. GAMBIT PRIMITIVES NOT YET MAPPED

The compiler has a very small `*gambit-replacements*` map (~2 entries). Projects use these Gambit-specific functions that need mappings:

| Gambit Function | Used By | Chez Equivalent |
|----------------|---------|-----------------|
| `##current-time` | gerbil-persist | `(current-time)` |
| `time->seconds` | multiple | `(time-second (current-time))` |
| `make-thread`, `thread-start!`, `thread-join!` | multiple | Already in threading.sls |
| `make-mutex`, `mutex-lock!`, `mutex-unlock!` | gerbil-persist | Already in threading.sls |
| `make-condition-variable`, `condition-variable-signal!` | gerbil-persist | Already in threading.sls |
| `make-will` | gerbil-cairo | `guardian` in Chez |
| `make-parameter` | multiple | Direct Chez `make-parameter` |
| `object->serial-number` | rare | Already in gambit-compat |
| `read-line` | multiple | Chez `get-line` (textual port) |
| `pp` / `pretty-print` | debugging | Chez `pretty-print` |
| `string-contains` | multiple | Needs shim (not in R6RS) |
| `string-prefix?` | multiple | Needs shim |
| `open-input-string`, `open-output-string` | multiple | Direct Chez equivalents |
| `get-output-string` | multiple | Chez `get-output-string` |
| `with-input-from-string` | multiple | Chez `with-input-from-string` |
| `display-continuation-backtrace` | error handling | Chez stack trace API |
| `u8vector->object`, `object->u8vector` | serialization | Needs Chez `fasl-write`/`fasl-read` |
| `subvector` | rare | Needs shim via `vector-copy` |
| `bitwise-merge` | rare | Compose from and/ior/xor |

---

## 4. COMPILER ARCHITECTURE GAPS

### 4a. No Macro Expansion Phase

`defsyntax` forms are passed through, meaning complex macros used in projects won't expand. Projects using `syntax-case` directly in source (19 files) will need either:
- A macro expansion pass before compilation, or
- Manual expansion/rewriting

### 4b. Import Resolution Incomplete

The compiler maps known `:std/*` paths but doesn't resolve:
- **Relative imports** (`./module`, `../module`) — partially handled
- **Package imports** (`:pkg/submodule`) — only prefix matching
- **`only-in`/`except-in` filters** — not processed
- **`rename-in`** — not processed

### 4c. `export #t` Not Compiled

Gerbil's `(export #t)` re-exports everything. The compiler passes exports through without analysis, so transitive exports won't work correctly.

### 4d. No `include` Support

Some projects use `(include "file.ss")` to inline code. Not handled.

---

## 5. RUNTIME GAPS

### 5a. Keyword Dispatch Enhancement

The runtime `keyword-dispatch` handles basic cases, but projects use complex keyword patterns:
```scheme
(def (make-widget width: (width 100) height: (height 50) style: (style 'default))
  ...)
```
Multiple keywords with defaults need robust case-lambda generation.

### 5b. Struct Transparency

Gerbil structs with `transparent: #t` print field values. The gherkin types system has the flag but may not integrate with Chez's `record-writer` for display/write.

### 5c. Struct Equality

Gerbil `equal?` on transparent structs compares fields recursively. Chez needs custom `equal?` extension or `record-equal-procedure`.

---

## 6. SPECIFIC PROJECT CONVERSION REQUIREMENTS

### gerbil-svg (Simplest — no FFI)
**Missing:** `:std/xml` (write-xml), `:std/srfi/13` (string-join — already compiled inline), SXML handling.
**Effort:** Low — mostly string/list operations.

### gerbil-charts (Medium — uses interface)
**Missing:** `interface`/`interface-out` compilation, `:std/iter` (partially handled), Canvas interface dispatch.
**Effort:** Medium — interface system is the main blocker.

### gerbil-tui (Medium — uses interface + defclass)
**Missing:** `interface` compilation, complex `defmethod` forms, `defclass` with `:init!`, buffer/cell abstractions.
**Effort:** Medium.

### gerbil-termbox (Hard — FFI)
**Missing:** All FFI (`begin-ffi`, `define-c-lambda`, `define-const`). Skipped.

### gerbil-persist (Medium — threading + sync)
**Missing:** `spawn`, `with-lock`, `:std/sync/completion`, `:std/sync/channel`, mutex patterns, `let-hash`.
**Effort:** Medium — threading primitives exist in gherkin, need compat wrappers.

### gerbil-llm (Medium — HTTP + JSON)
**Missing:** `:std/net/request`, `:std/text/json` (partially covered), `let-hash`.
**Effort:** Medium — needs HTTP client compat.

### gerbil-emacs (Hard — FFI + complex state)
**Missing:** All Scintilla FFI. Skipped.

### gerbil-scintilla (Hard — FFI)
**Missing:** All FFI bindings. Skipped.

### gerbil-cairo (Hard — FFI)
**Missing:** All Cairo FFI. Skipped.

### gerbil-crypto (Hard — FFI + crypto)
**Missing:** All libsodium/libsignal FFI. Skipped.

---

## 7. PRIORITY RECOMMENDATIONS

### Tier 1 — High Impact, Enables Most Projects

1. **`let-hash`** — 470 uses, trivial to compile (hash-ref expansion) ✅ DONE
2. **`let/cc`** — 60 uses, trivial (`call/cc` wrapper) ✅ DONE
3. **`defvalues`** — 56 uses, trivial (`define-values`) ✅ DONE
4. **`match` struct patterns** — used in every project with defstruct ✅ DONE
5. **`match` nested patterns + guards** — used extensively ✅ DONE
6. **`spawn`/`spawn/name`** — 195 uses, map to gherkin threading ✅ DONE
7. **`defmethod` full form** — needed for any OOP code ✅ DONE
8. **`awhen`/`aif`/`and-let*`** — sugar macros, easy to add ✅ DONE

### Tier 2 — Enables Specific Project Categories

9. **`interface`/`interface-out`** — enables gerbil-charts, gerbil-tui ✅ DONE
10. **`:std/test` compat** — enables running tests for all projects ✅ DONE
11. **`:std/text/json` in default map** — already exists in gherkin-lsp ✅ DONE
12. **`:std/misc/ports` compat** — `read-all-as-string`, `copy-port`, etc. ✅ DONE
13. **`:std/xml` compat** — enables gerbil-svg ✅ DONE
14. **`with-lock`** — enables gerbil-persist patterns ✅ DONE

### Tier 3 — Completeness

15. **`:std/text/base64`/`:std/text/hex`** — encoding utilities ✅ DONE
16. **`:std/sync/completion`/`:std/sync/channel`** — concurrency primitives ✅ DONE
17. **`:std/net/request`** — HTTP client (complex, may need Chez FFI) ✅ DONE
18. **`:std/crypto/digest`** — crypto (needs native library) ✅ DONE
19. **`include` support** — file inlining ✅ DONE
20. **`export #t`** — re-export all ✅ DONE (already implemented)
21. **Import filters** (`only-in`, `except-in`, `rename-in`) ✅ DONE (already implemented)

### Tier 4 — Advanced (Future)

22. **Macro expansion phase** — for projects using `defsyntax`
23. **`:std/db/dbi`** — database abstraction ✅ DONE
24. **`:std/net/httpd`** — HTTP server ✅ DONE

---

## 8. QUICK WINS (< 50 lines each)

These could be added to `compile.sls` with minimal effort:

| Form | Compilation Strategy | Est. Lines | Status |
|------|---------------------|------------|--------|
| `let-hash` | hash-ref expansion | ~10 | ✅ DONE |
| `let/cc` | call/cc wrapper | ~5 | ✅ DONE |
| `defvalues` | define-values | ~5 | ✅ DONE |
| `spawn` | fork-thread wrapper | ~10 | ✅ DONE |
| `with-lock` | dynamic-wind + mutex | ~10 | ✅ DONE |
| `awhen`/`aif` | let + when/if expansion | ~10 each | ✅ DONE |
| `and-let*` | nested let + and | ~15 | ✅ DONE |
| `include` | read-file + splice | ~15 | ✅ DONE |

All quick wins have been implemented. The `interface` compilation and `match` patterns have also been completed.

---

## 9. WHAT'S ALREADY WELL COVERED

For reference, the gherkin compiler already handles these correctly:

- `def`/`define` with optional/keyword parameters
- `defstruct` with inheritance, constructor, predicate, accessors, mutators
- `defclass` with `:init!`, multiple inheritance, MOP
- `defrules`/`defrule` pattern macros
- `try`/`catch`/`finally` exception handling
- `for`/`for/collect`/`for/fold`/`for/or`/`for/and` iteration
- `in-range`, `in-iota`, `in-hash-keys`, `in-hash-values`, `in-hash`, `in-string`, `in-vector`
- `match` (full: literals, wildcards, predicates, pairs, structs, vectors, quoted, and/or/not, apply)
- `hash` literal constructor
- `@list` (`[...]`) and `@method` (`{...}`) reader forms
- `self.field` dot notation for slot access
- `chain` threading macro
- `using` type-checked binding
- `cut` partial application (SRFI-26)
- `while`/`until` loops
- `parameterize` dynamic binding
- `with-catch`, `with-unwind-protect`, `dynamic-wind`
- `quasiquote`/`unquote`/`unquote-splicing`
- `syntax-case`/`with-syntax`/`with-syntax*` (pass-through)
- `displayln`, `string-join`, `string-split` (compiled inline)
- Full Gambit compatibility layer (200+ `##` primitives)
- Type system with C3 linearization
- Threading (Gambit API on Chez threads)
- Hash tables (3-tier: raw, specialized, GC)
- Keyword interning and dispatch
- `let-hash`, `let/cc`, `defvalues`, `awhen`, `and-let*` (compiled inline)
- `spawn`/`spawn/name`, `with-lock` (thread primitives)
- `interface`/`interface-out` (method dispatch)
- `defmethod` full form with type annotations
- `include` (file inlining)
- `export #t` (re-export all)
- Import filters (`only-in`, `except-in`, `rename-in`)

**Compat modules (`:std/*` shims):**
- `:std/test` — test-suite, test-case, check macros, run-tests!
- `:std/misc/ports` — read-all-as-string, read-file-string, write-file-string
- `:std/text/json` — JSON parsing/serialization
- `:std/text/base64` — base64 encoding/decoding
- `:std/text/hex` — hex encoding/decoding
- `:std/xml` / `:std/markup/xml` — SXML serialization to XML
- `:std/sync/completion` — async completion tokens
- `:std/sync/channel` — buffered message channels
- `:std/net/request` — HTTP client (via curl)
- `:std/net/httpd` — HTTP server (API surface)
- `:std/crypto/digest` — md5, sha1, sha256 (via openssl)
- `:std/db/dbi` — SQL database interface (SQLite backend)
- `:std/disasm` — procedure disassembly (via objdump)
