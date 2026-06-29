# Lexx Hypergraph Database Engine
# Build System for Mercury Project

MMC = mmc
MCFLAGS = --make --use-grade-subdirs
GRADE = hlc.gc

# Modules in dependency order
CORE_MODULES = \
	src/core/lexx_types \
	src/core/lexx_hypergraph \
	src/core/lexx_index

SCHEMA_MODULES = \
	src/schema/lexx_type_registry \
	src/schema/lexx_constraints \
	src/schema/lexx_rules \
	src/schema/lexx_schema

REASONING_MODULES = \
	src/reasoning/lexx_unification \
	src/reasoning/lexx_type_inference \
	src/reasoning/lexx_rule_engine \
	src/reasoning/lexx_explanation

QUERY_MODULES = \
	src/query/lexx_pattern \
	src/query/lexx_parser \
	src/query/lexx_planner \
	src/query/lexx_executor

STORAGE_MODULES = \
	src/storage/lexx_storage

API_MODULES = \
	src/api/lexx_api

ALL_MODULES = $(CORE_MODULES) $(SCHEMA_MODULES) $(REASONING_MODULES) \
              $(QUERY_MODULES) $(STORAGE_MODULES) $(API_MODULES)

# Main target
.PHONY: all clean test docs

all: lexx_engine

lexx_engine: $(addsuffix .m,$(ALL_MODULES))
	$(MMC) $(MCFLAGS) --grade $(GRADE) src/api/lexx_api

# Individual module compilation for development
core: $(addsuffix .m,$(CORE_MODULES))
	$(MMC) $(MCFLAGS) --grade $(GRADE) src/core/lexx_hypergraph

schema: core $(addsuffix .m,$(SCHEMA_MODULES))
	$(MMC) $(MCFLAGS) --grade $(GRADE) src/schema/lexx_schema

reasoning: core schema $(addsuffix .m,$(REASONING_MODULES))
	$(MMC) $(MCFLAGS) --grade $(GRADE) src/reasoning/lexx_rule_engine

# Test target
test: all
	$(MMC) $(MCFLAGS) --grade $(GRADE) tests/test_main
	./test_main

# Clean build artifacts
clean:
	rm -rf Mercury/ *.err *.mh
	find . -name "*.o" -delete
	find . -name "*.c" -delete
	find . -name "*.mh" -delete

# Generate documentation
docs:
	@echo "Documentation generation not yet implemented"

# Development helpers
.PHONY: check
check:
	$(MMC) --errorcheck-only $(addsuffix .m,$(ALL_MODULES))
