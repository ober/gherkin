# Gherkin: Gerbil Scheme on Chez Scheme

Gherkin ports Gerbil's full language (expander, MOP, module system, pattern
matching, contracts, sugar) to run natively on Chez Scheme. No Gambit dependency.

## Why

Gerbil runs on Gambit, which has immature SMP support. Chez Scheme has true SMP
with no GIL, parallel GC, atomic CAS, memory fences, and mature threading.

## Status

Phase 1: Foundation (compatibility layer + reader)

## Requirements

- Chez Scheme 10.x with threads (`./configure --threads`)

## Building

```
make        # compile all .sls libraries
make test   # run test suite
make clean  # remove compiled files
```

## Architecture

```
Gerbil Source (.ss)
       |
  Custom Reader (reader.sls)
       |
  Expander (ported from Gerbil)
       |  produces %# IR
  Compiler Backend (new)
       |
  Chez Scheme (native compilation, true SMP, parallel GC)
```

## Project Structure

```
src/
  compat/
    gambit-compat.sls   Gambit -> Chez primitive shim
    types.sls           Gerbil type descriptors on Chez records
    threading.sls       Gambit thread API -> Chez threads
  reader/
    reader.sls          Custom Gerbil-compatible reader
  boot/
    init.sls            Bootstrap initialization
tests/
    test-compat.ss      Compatibility layer tests
    test-reader.ss      Reader tests
    test-types.ss       Type system tests
    test-threading.ss   Threading tests
```
# gherkin
