SCHEME = scheme
SCHEMEFLAGS = --libdirs .:src --compile-imported-libraries

SLS_FILES = src/compat/gambit-compat.sls \
            src/compat/types.sls \
            src/compat/threading.sls \
            src/reader/reader.sls \
            src/boot/init.sls \
            src/boot/gherkin.sls

TEST_FILES = tests/test-compat.ss \
             tests/test-types.ss \
             tests/test-threading.ss \
             tests/test-reader.ss

.PHONY: all test clean compile

all: compile

compile:
	@echo "Compiling Gherkin libraries..."
	@$(SCHEME) -q $(SCHEMEFLAGS) --program tests/compile-libs.ss

test: compile
	@echo "Running tests..."
	@$(SCHEME) -q $(SCHEMEFLAGS) --program tests/run-all.ss

test-compat: compile
	@echo "Running compat tests..."
	@$(SCHEME) -q $(SCHEMEFLAGS) --program tests/test-compat.ss

test-types: compile
	@echo "Running type system tests..."
	@$(SCHEME) -q $(SCHEMEFLAGS) --program tests/test-types.ss

test-threading: compile
	@echo "Running threading tests..."
	@$(SCHEME) -q $(SCHEMEFLAGS) --program tests/test-threading.ss

test-reader: compile
	@echo "Running reader tests..."
	@$(SCHEME) -q $(SCHEMEFLAGS) --program tests/test-reader.ss

clean:
	find src -name "*.so" -delete
	find src -name "*.wpo" -delete
	find tests -name "*.so" -delete
	@echo "Cleaned."

loc:
	@wc -l $(SLS_FILES) $(TEST_FILES) 2>/dev/null || true
