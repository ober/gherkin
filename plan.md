# Gherkin Compiler Gap Analysis & Completion Plan

## Current Status (March 2025)

**407 tests passing** across 18 test files, 0 failures in core suites.

| Test Suite | Tests | Status |
|-----------|-------|--------|
| Gambit Compat | 95 | PASS |
| Type System | 47 | PASS |
| Threading | 21 | PASS |
| Reader | 80 | PASS |
| Runtime | 63 | PASS |
| Compiler | 17 | PASS |
| End-to-End | 19 | PASS |
| Extended Compiler | 52 | PASS |
| gxi | 13 | PASS |
| Tier 1 Features | 24 | PASS |
| Tier 2 Features | 19 | PASS (1 test-bug in check-equal? bad-math) |
| Tier 3 Features | 15 | PASS |
| Match & Defmethod | 26 | PASS |
| Interface | 16 | PASS |
| XML/SXML | 14 | PASS |
| Sync Primitives | 15 | PASS |
| Defsyntax | 9 | PASS |
| Net & Crypto | 8 | PASS |
| HTTPD & DBI | 8 | PASS |
| Disasm | 4 | PASS |

---

## What's Already Implemented

### Compiler (compile.sls)
- `def`/`define` with optional/keyword parameters, type annotations
- `def*` (case-lambda define)
- `defstruct` with inheritance, constructor, predicate, accessors, mutators
- `defclass` with `:init!`, multiple inheritance, MOP
- `defmethod` full form with type annotations
- `defrules`/`defrule` pattern macros
- `defsyntax` (pass-through to Chez)
- `interface`/`interface-out` (method dispatch)
- `defvalues` (define-values)
- `match` (full: literals, wildcards, predicates, pairs, structs, vectors, quoted, and/or/not, apply, guards)
- `try`/`catch`/`finally` exception handling
- `for`/`for/collect`/`for/fold`/`for/or`/`for/and` iteration
- `in-range`, `in-iota`, `in-hash-keys`, `in-hash-values`, `in-hash`, `in-string`, `in-vector`
- `hash`/`hash-eq`/`hash-eqv` literal constructors
- `hash-ref`, `hash-get`, `hash-put!`, `hash-remove!`, `hash-update!`, `hash-copy`, `hash-merge`
- `let-hash` (hash deconstructor)
- `let/cc` (call/cc wrapper)
- `awhen` (anaphoric when)
- `and-let*` (short-circuiting let*)
- `chain` threading macro
- `using` type-checked binding
- `cut` partial application (SRFI-26)
- `while`/`until` loops
- `parameterize` dynamic binding
- `with-catch`, `with-unwind-protect`, `dynamic-wind`
- `quasiquote`/`unquote`/`unquote-splicing`
- `syntax-case`/`with-syntax`/`with-syntax*` (pass-through)
- `@list` (`[...]`) and `@method` (`{...}`) reader forms
- `self.field` dot notation for slot access
- `spawn`/`spawn/name` (thread creation)
- `with-lock` (mutex-guarded execution)
- `include` (file inlining)
- `export #t` (re-export all)
- Import filters (`only-in`, `except-in`, `rename-in`)
- `receive` (values destructuring)
- `pregexp` (regular expressions)
- `assert`
- `gensym`
- `read-line`, `pp`/`pretty-print`
- `make-parameter`
- `displayln`

### Reader (reader.sls)
- `[...]` list syntax
- `{...}` method call syntax
- Keyword syntax (`key:`)
- `#!void`, `#!eof`, `#!optional`
- `#;` datum comment
- `#u8(...)` bytevectors
- `#\` character literals
- String escapes
- Hash reader `#hash((k . v) ...)`

### Runtime
- MOP (mop.sls): defstruct/defclass type descriptors, C3 linearization, slot access
- Hash tables (hash.sls, table.sls): 3-tier (raw, specialized, GC)
- Error system (error.sls): Gerbil exception hierarchy
- Keyword interning and dispatch (control.sls)
- Syntax utilities (syntax.sls)
- Eval (eval.sls)
- Threading (threading.sls): Gambit thread API on Chez threads

### Compat Modules (:std/* shims)
- `:std/test` — test-suite, test-case, check macros, run-tests!
- `:std/sugar` — via boot/sugar.sls
- `:std/error` — via runtime/error
- `:std/misc/ports` — read-all-as-string, read-file-string, write-file-string
- `:std/text/json` — JSON parsing/serialization
- `:std/text/base64` — base64 encoding/decoding
- `:std/text/hex` — hex encoding/decoding
- `:std/xml` / `:std/markup/xml` — SXML serialization to XML
- `:std/sync/completion` — async completion tokens
- `:std/sync/channel` / `:std/misc/channel` — buffered message channels
- `:std/net/request` — HTTP client (via curl)
- `:std/net/httpd` — HTTP server (API surface)
- `:std/crypto/digest` — md5, sha1, sha256 (via openssl)
- `:std/db/dbi` — SQL database interface (SQLite backend)
- `:std/disasm` — procedure disassembly (via objdump)
- `:std/iter` — stripped (for-loops compiled natively)
- `:std/format` — via compat/format
- `:std/sort` — via compat/sort
- `:std/pregexp` — via compat/pregexp
- `:std/misc/string`, `:std/misc/list`, `:std/misc/path`, `:std/misc/hash` — via compat/misc
- `:std/srfi/1` — via compat/misc
- `:std/stxutil` — via compat/std-stxutil
- `:std/os/signal`, `:std/os/signal-handler` — via compat/signal
- `:std/os/fdio` — via compat/fdio

---

## What's Missing

### 1. MISSING COMPILER FORMS

#### 1a. Sugar Macros (Easy — simple expansions)

| Form | Usage | Expansion | Est. Lines |
|------|-------|-----------|------------|
| `if-let` | 8 files | `(let (test expr) (if test (let (id test) then) else))` | ~15 |
| `when-let` | 6 files | `(if-let bindings (begin body ...) (void))` | ~5 |
| `ignore-errors` | 2 files | `(with-catch false (lambda () form ...))` | ~3 |
| `with-destroy` | 3 files | `(let ($obj obj) (try body ... (finally {destroy $obj})))` | ~5 |
| `do-while` | rare | Named let with test-after-body | ~10 |
| `values-set!` | rare | `(let-values ... (set! ...) ...)` | ~10 |
| `do` (R5RS) | rare | Named let loop (already in Chez, may need Gerbil variant) | ~10 |

#### 1b. Advanced Macros (Medium)

| Form | Usage | Notes |
|------|-------|-------|
| `definterface` | 6 files | Different from `interface` — defines contract types. Used in gerbil-charts, gerbil-tui. The compiler handles `interface` but not `definterface` from `:std/contract`. |
| `defmethod/alias` | rare | Defines method + binds aliases |
| `with-methods` | rare | Binds method procs from an object |
| `with-id` | 2 files | Identifier-splicing macro (compile-time) |
| `syntax-eval` | 1 file | Compile-time eval |
| `def/c` | 4 files | Contract-annotated definitions (from `:std/contract`) |
| `cond-expand` | 2 files | Feature-based conditional compilation |

#### 1c. Coroutine/Producer Support (Medium)

| Form | Usage | Notes |
|------|-------|-------|
| `in-producer` | 2 files | Iterator over coroutine/generator output |
| `in-coroutine` | 1 file | Iterator wrapping a coroutine |
| `coroutine` | 2 files | Coroutine creation |
| `yield` | used with coroutine | Coroutine yield point |

#### 1d. FFI Forms (Hard — different paradigm on Chez)

| Form | Usage | Notes |
|------|-------|-------|
| `begin-ffi` | 5 files | Gambit FFI block |
| `begin-foreign` | 10 files | Foreign code block |
| `define-c-lambda` | 6 files | C function binding |
| `c-declare` | in FFI files | C code declaration |
| `c-lambda` | in FFI files | C function binding |

These require a completely different approach on Chez (Chez has its own FFI). Most FFI-heavy projects (gerbil-cairo, gerbil-qt, gerbil-scintilla, gerbil-termbox, gerbil-crypto) would need per-project porting rather than compiler support.

#### 1e. Lazy Evaluation (Easy)

| Form | Usage | Notes |
|------|-------|-------|
| `delay` | 1 file | Promise creation — Chez has `delay` natively |
| `force` | 7 files | Promise forcing — Chez has `force` natively |
| `lazy` | rare | Lazy evaluation — may just be `delay` alias |

### 2. MISSING STDLIB COMPAT MODULES

#### High Priority (used by 8+ project files)

| Module | Files | Key Functions Needed |
|--------|-------|---------------------|
| `:std/getopt` / `:std/cli/getopt` | 10 | `getopt`, `option`, `flag`, `command`, `argument`, `getopt-display-help` |
| `:std/actor` | 24 | `start-actor!`, `<-`, `->`, `->>`, `-->`, `defmessage`, `defproto` |
| `:std/event` | 13 | `sync`, `select`, `choice`, `wrap`, `handle`, `never-evt`, `always-evt` |
| `:std/io` | 8 | New I/O subsystem (BufferedReader, BufferedWriter, etc.) |
| `:std/logger` | 8 | `current-logger`, `debugf`, `infof`, `warnf`, `errorf` |
| `:std/srfi/13` | 13 | String operations (many already in compat/misc) |
| `:std/misc/process` | 9 | `run-process`, `run-process/batch` (partially in compat) |

#### Medium Priority (used by 3-7 project files)

| Module | Files | Key Functions Needed |
|--------|-------|---------------------|
| `:std/srfi/19` | 6 | Date/time handling |
| `:std/srfi/1` | 6 | List operations (partially covered by compat/misc) |
| `:std/misc/repr` | 4 | `repr`, `display-repr`, `write-repr` |
| `:std/misc/bytes` | 3 | `u8vector-xor`, byte manipulation |
| `:std/misc/concurrent-plan` | 5 | DAG-based concurrent execution |
| `:std/parser` | 5 | `deflexer`, `defparser`, token streams |
| `:std/os/path` | 8 | `path-extension`, `path-strip-extension`, `path-directory` |
| `:std/os/env` | 3 | `getenv`, `setenv` (Chez has these) |
| `:std/os/temporaries` | 1 | `make-temporary-file-name` |
| `:std/generic` | rare | Generic functions |
| `:std/crypto` (full) | 5 | Full crypto (beyond digest — cipher, hmac, pkey, bn, dh) |
| `:std/net/ssl` | 3 | TLS/SSL support |
| `:std/net/uri` | rare | URI parsing |
| `:std/net/websocket` | rare | WebSocket client/server |
| `:std/text/csv` | 3 | CSV parsing |
| `:std/text/utf8` | 3 | UTF-8 handling |

#### Low Priority (used by 1-2 project files)

| Module | Files | Notes |
|--------|-------|-------|
| `:std/db/sqlite` | 7 | Direct SQLite (DBI covers basic) |
| `:std/db/postgresql` | 4 | PostgreSQL client |
| `:std/db/conpool` | 3 | Connection pooling |
| `:std/misc/alist` | rare | Alist utilities |
| `:std/misc/queue` | rare | Queue data structure |
| `:std/misc/deque` | rare | Double-ended queue |
| `:std/misc/pqueue` | rare | Priority queue |
| `:std/misc/rbtree` | rare | Red-black tree |
| `:std/misc/uuid` | rare | UUID generation |
| `:std/misc/barrier` | rare | Barrier synchronization |
| `:std/misc/threads` | rare | Thread utilities |
| `:std/misc/timeout` | rare | Timeout utilities |
| `:std/misc/list-builder` | rare | List builder |
| `:std/misc/number` | rare | Number utilities |
| `:std/debug/heap` | 4 | Heap debugging |
| `:std/debug/threads` | rare | Thread debugging |
| `:std/text/base58` | rare | Base58 encoding |
| `:std/text/char-set` | rare | Character sets |
| `:std/text/zlib` | rare | Compression |
| `:std/net/address` | rare | Network addresses |
| `:std/net/socket` | rare | Raw sockets |
| `:std/os/socket` | rare | OS socket ops |
| `:std/os/fd` | rare | File descriptors |
| `:std/os/pipe` | rare | Pipe operations |
| `:std/os/hostname` | rare | Hostname queries |

### 3. COMPILER ARCHITECTURE GAPS

#### 3a. No Macro Expansion Phase
`defsyntax` forms are passed through to Chez, meaning complex macros using Gerbil-specific expander APIs (`syntax-local-value`, `stx-identifier`, `core-apply-expander`, etc.) won't work. Projects using `syntax-case` with Gerbil expander internals (19 files) need either:
- A Gerbil-compatible expander implementation for Chez, or
- Manual pre-expansion of affected macros

#### 3b. Module System Incompleteness
- `group-in` import form not compiled
- `prefix-in` import form not compiled
- `prefix-out` / `except-out` / `rename-out` / `struct-out` export forms not compiled
- `for-syntax` / `for-template` phase imports not compiled
- `defsyntax-for-import` / `defsyntax-for-export` custom import/export expanders not supported
- No `cond-expand` / `require` feature testing

#### 3c. Contract System (`:std/contract`)
The full contract system (`definterface`, `def/c`, contract annotations, type checking) is not compiled. This is a significant subsystem used by several projects.

### 4. GAMBIT PRIMITIVES NOT YET MAPPED

Most commonly-used Gambit primitives are mapped. Still missing:

| Gambit Function | Chez Equivalent | Usage |
|----------------|-----------------|-------|
| `make-will` | `guardian` | 1 file (GC weak refs) |
| `u8vector->object` / `object->u8vector` | `fasl-write`/`fasl-read` | serialization |
| `display-continuation-backtrace` | Chez stack trace API | error handling |
| `bitwise-merge` | compose from and/ior/xor | rare |

---

## Priority Recommendations

### Tier 1 — Quick Wins (< 30 lines each, high usage)

| # | Form | Usage | Strategy | Status |
|---|------|-------|----------|--------|
| 1 | `if-let` | 8 files | Compile to nested let+if | TODO |
| 2 | `when-let` | 6 files | Compile via if-let | TODO |
| 3 | `ignore-errors` | 2 files | `(with-catch false (lambda () ...))` | TODO |
| 4 | `with-destroy` | 3 files | try/finally expansion | TODO |
| 5 | `do-while` | rare | Named let variant | TODO |
| 6 | `values-set!` | rare | let-values + set! | TODO |
| 7 | `delay`/`force`/`lazy` | 7 files | Pass through to Chez | TODO |
| 8 | `cond-expand` | 2 files | Feature-based `if` | TODO |

### Tier 2 — Compat Modules (enables more project porting)

| # | Module | Usage | Strategy |
|---|--------|-------|----------|
| 9 | `:std/getopt` | 10 files | Chez compat shim (command-line parsing) |
| 10 | `:std/logger` | 8 files | Simple logging to stderr |
| 11 | `:std/os/path` | 8 files | Path manipulation (mostly string ops) |
| 12 | `:std/os/env` | 3 files | `getenv`/`setenv` (Chez native) |
| 13 | `:std/srfi/13` | 13 files | Extend compat/misc with more string ops |
| 14 | `:std/srfi/19` | 6 files | Date/time (Chez has SRFI-19 via lib) |
| 15 | `:std/misc/repr` | 4 files | Object representation printing |
| 16 | `:std/misc/bytes` | 3 files | Byte manipulation utilities |
| 17 | `:std/text/csv` | 3 files | CSV parser |
| 18 | `:std/text/utf8` | 3 files | UTF-8 utilities |
| 19 | `:std/misc/process` | 9 files | Extend run-process compat |

### Tier 3 — Major Subsystems (enables specific project categories)

| # | Feature | Projects Enabled | Effort |
|---|---------|-----------------|--------|
| 20 | `:std/actor` system | gerbil-persist, gerbil-lsp, gerbil-sinatra | High — full actor/message framework |
| 21 | `:std/event` system | gerbil-persist, actor-based projects | High — sync/select event loop |
| 22 | `:std/io` new I/O | gerbil-lsp, modern I/O code | Medium — BufferedReader/Writer |
| 23 | `definterface`/`def/c` (contracts) | gerbil-charts, gerbil-tui | Medium — contract system macros |
| 24 | Coroutine support | 2 files | Medium — yield/resume |
| 25 | `:std/parser` | 5 files | Medium — lexer/parser generators |
| 26 | `:std/generic` | rare | Low — generic functions |

### Tier 4 — Full Ecosystem (completeness)

| # | Feature | Notes |
|---|---------|-------|
| 27 | Full `:std/crypto` | Needs native library bindings |
| 28 | `:std/net/ssl` | TLS support |
| 29 | `:std/net/websocket` | WebSocket protocol |
| 30 | `:std/db/sqlite` direct | Beyond DBI abstraction |
| 31 | `:std/db/postgresql` | PostgreSQL wire protocol |
| 32 | `:std/db/conpool` | Connection pooling |
| 33 | Macro expansion phase | Gerbil expander on Chez |
| 34 | Module system completeness | group-in, phase imports, etc. |
| 35 | FFI bridge | Gambit FFI → Chez FFI translation |

---

## Project Portability Assessment

### Ready to Port (no/minimal additional work)

| Project | Blockers | Notes |
|---------|----------|-------|
| gerbil-svg | None | Pure string/list/XML operations |
| gerbil-utils | None | Basic utilities |
| gerbil-graphviz | Minimal | DOT generation |

### Nearly Ready (need Tier 1-2 items)

| Project | Missing | Priority Items Needed |
|---------|---------|----------------------|
| gerbil-coreutils | getopt | #9 |
| gerbil-gawk | getopt, misc | #9, #19 |
| gerbil-llm | if-let, logger | #1, #10 |
| gerbil-jira | net/request, json (done), getopt | #9 |
| gerbil-gitlab | net/request, json, getopt | #9 |
| gerbil-swagger | json, text | #17 |
| gerbil-auth | crypto/digest (done), base64 (done) | Ready? |

### Need Tier 3 Work

| Project | Missing Subsystems |
|---------|--------------------|
| gerbil-charts | definterface, contracts |
| gerbil-tui | definterface, contracts, event |
| gerbil-persist | actor, event, db |
| gerbil-lsp | actor, io, event |
| gerbil-sinatra | actor, httpd |
| gerbil-es-proxy | actor, httpd |
| gerbil-mcp | actor, io, json-rpc |
| gerbil-shell | Already ported to Chez via gherkin-shell |

### FFI-Dependent (need per-project porting)

| Project | FFI Library |
|---------|-------------|
| gerbil-cairo | libcairo |
| gerbil-qt | Qt5/Qt6 |
| gerbil-scintilla | Scintilla |
| gerbil-termbox | termbox |
| gerbil-emacs | Scintilla + complex state |
| gerbil-crypto | libsodium, libsignal |
| gerbil-pcre2 | libpcre2 |
| gerbil-leveldb | libleveldb |
| gerbil-duckdb | libduckdb |
| gerbil-litehtml | litehtml |
| gerbil-libxml | libxml2 |
| gerbil-libsignal | libsignal |
| gerbil-webview | webview |
| gerbil-redis | hiredis |
| gerbil-postgres | libpq |
| gerbil-lora | LoRA |
| gerbil-prometheus | HTTP metrics |

---

## Implementation Notes

### Compiler Architecture
- Source: `src/compiler/compile.sls`
- Entry points: `gerbil-compile-top` (top-level), `gerbil-compile-expression` (expressions)
- Import resolution: `*default-import-map*` alist + `resolve-import` function
- New forms: Add case to `gerbil-compile-top` or `gerbil-compile-expression` + compile function

### Adding a New Sugar Form
1. Add case in `gerbil-compile-expression` matching the head symbol
2. Write `compile-<form>` function that returns Chez s-expression
3. Add test in appropriate test file
4. Example: `if-let` → `(let (test expr) (if test (let (id test) then) else))`

### Adding a New Compat Module
1. Create `src/compat/std-<module>.sls` as R6RS library
2. Add entry to `*default-import-map*` in compile.sls
3. Add tests
4. Example: see `src/compat/std-test.sls` for pattern

### Test Organization
- `tests/test-compat.ss` — Gambit compat layer (95 tests)
- `tests/test-types.ss` — Type system (47 tests)
- `tests/test-threading.ss` — Threading (21 tests)
- `tests/test-reader.ss` — Reader (80 tests)
- `tests/test-runtime.ss` — Runtime (63 tests)
- `tests/test-compiler.ss` — Core compiler (17 tests)
- `tests/test-e2e.ss` — End-to-end (19 tests)
- `tests/test-extended.ss` — Extended compiler features (52 tests)
- `tests/test-gxi.ss` — REPL/interpreter (13 tests)
- `tests/test-tier1.ss` through `test-tier3.ss` — Tiered feature tests
- `tests/test-match-defmethod.ss` — Match patterns & defmethod (26 tests)
- `tests/test-interface.ss` — Interface compilation (16 tests)
- `tests/test-xml.ss` — XML/SXML (14 tests)
- `tests/test-sync.ss` — Sync primitives (15 tests)
- `tests/test-defsyntax.ss` — Defsyntax (9 tests)
- `tests/test-net-crypto.ss` — Net & Crypto (8 tests)
- `tests/test-httpd-dbi.ss` — HTTPD & DBI (8 tests)
- `tests/test-disasm.ss` — Disassembly (4 tests)
