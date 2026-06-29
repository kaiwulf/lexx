# Lexx Hypergraph Database Engine

A hypergraph-based ontology database engine written in Mercury, designed for the Lexx Intelligence Augmentation (IA) and Synthetic Intelligence (SI) system.

## Features

- **Hypergraph Data Model**: Native support for n-ary relations via hyperedges
- **Polymorphic Type System**: Type hierarchies with inheritance and subtyping
- **Rule-Based Inference**: Forward and backward chaining reasoning
- **Explainable AI**: Proof trees track how conclusions were derived
- **Strong Typing**: Mercury's type system catches errors at compile time

## Architecture

```
API Layer          → External interface for queries and mutations
Query Processor    → Parse, plan, and execute queries  
Reasoning Engine   → Type inference + rule inference
Schema Manager     → Type registry, constraints, rules
Hypergraph Core    → In-memory data structures with indexing
Storage Engine     → Persistence (planned)
```

## Project Structure

```
lexx-hypergraph/
├── src/
│   ├── core/           # Fundamental data structures
│   │   ├── lexx_types.m        # Type definitions
│   │   └── lexx_hypergraph.m   # Hypergraph operations
│   ├── schema/         # Schema management
│   │   └── lexx_type_registry.m
│   ├── reasoning/      # Inference engine
│   │   └── lexx_rule_engine.m
│   ├── query/          # Query processing (planned)
│   ├── storage/        # Persistence (planned)
│   └── api/            # Public API (planned)
├── tests/
│   └── test_basic.m    # Basic functionality tests
├── docs/
│   └── GETTING_STARTED.md  # Learning guide
└── Makefile
```

## Quick Start

### Prerequisites

- Mercury compiler (mmc) - https://mercurylang.org/
- GNU Make

### Building

```bash
# Build core modules
make core

# Build and run tests
mmc --make tests/test_basic
./test_basic
```

### Basic Usage

```mercury
:- import_module lexx_types, lexx_hypergraph, lexx_type_registry.

% Create type registry and define schema
TypeReg0 = init,
PersonType = entity_type("person", yes("entity"), 
    [attr_spec("name", vt_string, yes, no)], []),
register_type(PersonType, _, TypeReg0, TypeReg),

% Create hypergraph and add data
HG0 = init,
add_vertex("person", 
    map.from_assoc_list(["name" - v_string("Alice")]),
    AliceId, HG0, HG1),

% Query data
get_vertices_by_type(HG1, "person", People).
```

## Documentation

- [Getting Started Guide](docs/GETTING_STARTED.md) - Architecture, ontology engineering primer, and learning path

## Design Influences

- **ODASE Platform**: Ontology-driven architecture patterns
- **TypeDB**: Polymorphic type system and inference approach
- **Mercury**: Strong typing, modes, and determinism

## Roadmap

- [x] Core type definitions
- [x] In-memory hypergraph with indexing
- [x] Type registry with inheritance
- [x] Basic forward/backward chaining inference
- [ ] Pattern unification improvements
- [ ] Query language parser
- [ ] Persistence layer
- [ ] Transaction support
- [ ] Lexx emotion ontology integration

## License

[Your License Here]

## Related

- [Mercury Programming Language](https://mercurylang.org/)
- [ODASE Platform](https://www.odase.io/)
- [TypeDB](https://typedb.com/)
