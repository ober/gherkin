# Gherkin: Gerbil Scheme on Chez Scheme

Gherkin compiles Gerbil Scheme programs to run natively on Chez Scheme. It
translates Gerbil's full language (expander, MOP, module system, pattern
matching, contracts, sugar) to R6RS libraries that Chez compiles to native
code. No Gambit dependency at runtime.

## Why

Gerbil runs on Gambit, which has immature SMP support. Chez Scheme has true SMP
with no GIL, parallel GC, atomic CAS, memory fences, and mature threading.

## Status

All phases complete. 152/152 self-hosting tests pass. Gerbil's expander,
compiler, and module system run on Chez. Multiple real-world projects compiled
successfully (shell, LSP server, CloudTrail analyzer).

## Requirements

- Chez Scheme 10.x with threads (`./configure --threads`)
- Gerbil Scheme source tree (for compiling Gerbil projects)

## Quick Start

```bash
# Build the gherkin compiler
git clone https://github.com/ober/gherkin ~/mine/gherkin
cd ~/mine/gherkin
make

# Run the self-hosting test suite
make self-host-test

# Launch the Gerbil REPL on Chez
make repl
```

## Compiling a Gerbil Project

Gherkin's primary use case is compiling existing Gerbil projects to run on Chez
Scheme. The workflow has three stages:

```
Gerbil Source (.ss)
       |
  gherkin translate     build-gherkin.ss
       |
  R6RS Libraries (.sls)
       |
  Chez compile          build-all.ss
       |
  Native Code (.so)     or standalone binary via build-binary.ss
```

### Setting Up a New Project

A gherkin project wraps an existing Gerbil project. You need:

1. **A `Makefile`** that sets `GHERKIN` to point at gherkin's `src/` directory
2. **A `build-gherkin.ss`** script that translates each `.ss` module
3. **A `build-all.ss`** script that imports all modules to trigger Chez compilation
4. **A `src/compat/`** directory with any compatibility shims your project needs

Here's the minimal `Makefile`:

```makefile
SCHEME = scheme
GHERKIN = $(or $(GHERKIN_DIR),$(HOME)/mine/gherkin/src)
LIBDIRS = src:$(GHERKIN)
COMPILE = $(SCHEME) -q --libdirs $(LIBDIRS) --compile-imported-libraries

.PHONY: all gherkin compile run clean

all: gherkin compile

# Step 1: Translate .ss -> .sls via gherkin
gherkin:
	$(COMPILE) < build-gherkin.ss

# Step 2: Compile .sls -> .so via Chez
compile: gherkin
	$(COMPILE) < build-all.ss

# Run interpreted (no binary)
run: all
	$(SCHEME) -q --libdirs $(LIBDIRS) --program main.ss

clean:
	find src -name '*.so' -o -name '*.wpo' | xargs rm -f 2>/dev/null || true
```

### The build-gherkin.ss Script

This is the core of a gherkin project. It:

1. Imports gherkin's compiler (`(compiler compile)`)
2. Defines an **import map** translating Gerbil module paths to R6RS library names
3. Defines **base imports** shared by all compiled modules
4. Calls `gerbil-compile-to-library` for each source module
5. Applies `fix-import-conflicts` to resolve R6RS import restrictions

```scheme
#!chezscheme
(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (compiler compile))

;; Map Gerbil imports to R6RS library names
(define my-import-map
  '((:std/sugar   . (compat sugar))
    (:std/format  . (compat format))
    (:std/sort    . (compat sort))
    (:std/error   . (runtime error))
    ;; Strip imports that have no Chez equivalent
    (:gerbil/core . #f)))

;; Imports injected into every compiled module
(define my-base-imports
  '((except (chezscheme) void box box? unbox set-box! ...)
    (compat types)
    (runtime util)
    (runtime table)
    (runtime mop)
    (except (compat gambit) ...)))

(define (compile-module name)
  (let* ((input  (string-append name ".ss"))
         (output (string-append "src/mylib/" name ".sls"))
         (lib    `(mylib ,(string->symbol name))))
    (let* ((lib-form (gerbil-compile-to-library
                       input lib my-import-map my-base-imports))
           (lib-form (fix-import-conflicts lib-form)))
      (call-with-output-file output
        (lambda (port)
          (display "#!chezscheme\n" port)
          (parameterize ([print-gensym #f])
            (pretty-print lib-form port)))
        'replace))))

;; Compile in dependency order
(compile-module "util")
(compile-module "core")
(compile-module "main")
```

See [gherkin-shell's build-gherkin.ss](https://github.com/ober/gherkin-shell)
for a complete real-world example with import conflict resolution, post-build
patching, and tiered compilation.

### The build-all.ss Script

Triggers Chez compilation by importing every module:

```scheme
#!chezscheme
(import (mylib util) (mylib core) (mylib main))
```

### Building a Standalone Binary

For a self-contained native binary with no runtime dependencies:

```scheme
;; build-binary.ss — see docs/gherkin-single-binary.md for the full guide
;; Key techniques:
;;   - Boot files embedded as C byte arrays (Sregister_boot_file_bytes)
;;   - Program loaded via memfd (threading workaround)
;;   - FFI via C shim compiled into the binary
```

See [docs/gherkin-single-binary.md](docs/gherkin-single-binary.md) for the
complete guide to building self-contained binaries.

### Key Concepts

**Import map**: Gerbil uses `:std/sort`, Chez uses `(compat sort)`. The import
map translates between them. Map a Gerbil module to `#f` to strip it entirely.

**Base imports**: R6RS libraries that every compiled module needs. Typically
includes `(chezscheme)` with exclusions for Gambit-compatible replacements,
plus the gherkin runtime (`types`, `table`, `mop`, `gambit-compat`).

**Import conflict resolution**: R6RS forbids local definitions that shadow
imports. `fix-import-conflicts` automatically adds `(except ...)` clauses.
It also handles exported variables that are `set!`'d (forbidden in R6RS) by
rewriting them with `identifier-syntax` indirection.

**Post-build patching**: Some Gerbil patterns need fixups after translation:
keyword dispatch in constructors, `make-mutex` string→symbol arguments,
`(define (void) (void))` infinite recursion. These are applied as string
patches in `build-gherkin.ss`.

**Compilation order**: Modules must be compiled in dependency order (leaves
first). Group them into tiers in `build-gherkin.ss`.

## Using the Gherkin REPL

```bash
make repl
# or directly:
scheme -q --libdirs .:src --program src/repl/gxi.ss
```

The REPL supports Gerbil syntax and provides:

- **Comma commands**: `,q` quit, `,h` help, `,load` file, `,expand` form, `,dis` disassembly
- **Module imports**: `(import :std/sort)` loads and compiles from Gerbil source
- **Tab completion**: Chez expeditor with Gerbil keywords (when running in a terminal)
- **Module caching**: Compiled modules cached in `/tmp/gherkin-modules/`

## Using the Compiler CLI

```bash
make gxc GXCARGS="--check file.ss"    # syntax check
make gxc GXCARGS="--expand file.ss"   # show compiled output
make gxc GXCARGS="--deps file.ss"     # show import dependencies
make gxc GXCARGS="-o out/ file.ss"    # compile to output directory
```

## Architecture

```
Gerbil Source (.ss)
       |
  Gerbil Reader (reader.sls)       parses Gerbil syntax
       |
  Gherkin Compiler (compile.sls)   translates to R6RS
       |
  R6RS Library (.sls)              standard Scheme
       |
  Chez Scheme                      native compilation, true SMP, parallel GC

Support Layer:
  gambit-compat.sls    90+ Gambit ## primitive mappings
  types.sls            Gerbil type descriptors on Chez records
  threading.sls        Gambit SRFI-18 threads -> Chez threads
  runtime/*.sls        MOP, hash tables, syntax objects, eval, error
  module/loader.sls    Module resolution, caching, dependency loading
```

## Project Structure

```
src/
  compiler/
    compile.sls         Gerbil -> Chez compiler
  reader/
    reader.sls          Gerbil-compatible reader
  compat/
    gambit-compat.sls   Gambit primitive shim (90+ mappings)
    types.sls           Gerbil type descriptors on Chez records
    threading.sls       Gambit thread API -> Chez threads
  runtime/
    *.sls               MOP, hash, syntax, eval, error (14 files)
  module/
    loader.sls          Module resolution, caching, dependency loading
  boot/
    init.sls            Bootstrap initialization
    gherkin.sls         Top-level compiler API
  repl/
    gxi.ss              Interactive REPL
    repl.sls            REPL library (expeditor, basic modes)
  tools/
    gxc.ss              Compiler CLI
    pkg.sls             Package manager (gxpkg equivalent)
bootstrap/
  runtime/              Pre-compiled runtime (14 files)
  expander/             Pre-compiled expander (8 files)
  core/                 Pre-compiled core macros (10 files)
  compiler/             Pre-compiled compiler (12 files)
scripts/
  generate-bootstrap.ss Bootstrap artifact generator
tests/
  self-host-core.ss     All-phases test harness (152 checks)
  compile-libs.ss       Library pre-compilation
  test-*.ss             Component tests
docs/
  gherkin-single-binary.md   Building self-contained binaries
  lsp-conversion.md          Lessons from porting gerbil-lsp
  optimization.md            Chez optimization techniques
```

## Build Targets

| Target | Description |
|--------|-------------|
| `make` | Compile all gherkin libraries |
| `make test` | Run component test suite |
| `make self-host-test` | Run 152-check self-hosting test suite |
| `make repl` | Launch Gerbil REPL on Chez |
| `make gxc GXCARGS="..."` | Run compiler CLI |
| `make bootstrap` | Generate bootstrap artifacts from Gerbil source |
| `make compile-opt3` | Compile with optimize-level 3 |
| `make compile-wpo` | Compile with whole-program optimization |
| `make clean` | Remove compiled files |

## Real-World Projects

| Project | Description | Binary Size |
|---------|-------------|-------------|
| [gherkin-shell](https://github.com/ober/gherkin-shell) | POSIX shell with bash extensions | 6.5 MB |
| gherkin-lsp | Gerbil LSP server (53 modules) | 5.6 MB |
| gherkin-kunabi | CloudTrail log analyzer | — |
| gherkin-aws | AWS S3/STS client libraries | — |

## License

MIT
