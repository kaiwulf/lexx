# Lexx Hypergraph Database Engine

## Getting Started Guide & Ontology Engineering Primer

This guide will help you understand the architecture, learn ontology engineering basics, and get started building the Lexx hypergraph database.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Ontology Engineering Fundamentals](#ontology-engineering-fundamentals)
3. [Building the Engine: Recommended Order](#building-order)
4. [Learning Resources](#learning-resources)
5. [Implementation Roadmap](#implementation-roadmap)

---

## Architecture Overview

### The Engine Kernel

The Lexx hypergraph engine has a layered architecture:

```
┌─────────────────────────────────────────┐
│  API Layer (lexx_api)                   │  ← External interface
├─────────────────────────────────────────┤
│  Query Processor (lexx_query/*)         │  ← Parse, plan, execute queries
├─────────────────────────────────────────┤
│  Reasoning Engine (lexx_reasoning/*)    │  ← Inference & explanation
├─────────────────────────────────────────┤
│  Schema Manager (lexx_schema/*)         │  ← Type system & rules
├─────────────────────────────────────────┤
│  Hypergraph Core (lexx_core/*)          │  ← Data structures & indexes
├─────────────────────────────────────────┤
│  Storage Engine (lexx_storage/*)        │  ← Persistence (future)
└─────────────────────────────────────────┘
```

### Key Modules (in dependency order)

| Module | Purpose | Status |
|--------|---------|--------|
| `lexx_types` | Core type definitions | ✅ Created |
| `lexx_hypergraph` | In-memory hypergraph | ✅ Created |
| `lexx_type_registry` | Schema management | ✅ Created |
| `lexx_rule_engine` | Inference engine | ✅ Created |
| `lexx_index` | Query optimization indexes | 📋 TODO |
| `lexx_unification` | Pattern matching | 📋 TODO |
| `lexx_parser` | Query language parser | 📋 TODO |
| `lexx_storage` | Persistence layer | 📋 TODO |

---

## Ontology Engineering Fundamentals

### What is an Ontology?

An **ontology** is a formal description of knowledge as a set of concepts within a domain and the relationships between those concepts. Think of it as a "schema for knowledge."

### Key Concepts

#### 1. Classes (Types)
Classes define **categories of things** that can exist.

```
Example ontology for a social network:
- Person (can have name, age)
- Company (can have name, founded date)
- Post (can have content, timestamp)
```

In Lexx, these are `entity_type` definitions.

#### 2. Relations
Relations define **how things connect** to each other.

```
Example relations:
- friendship(friend, friend)     -- connects two Persons
- employment(employee, employer) -- connects Person to Company
- authored(author, post)         -- connects Person to Post
```

In Lexx, these are `relation_type` definitions with named **roles**.

#### 3. Properties/Attributes
Attributes are **data values** attached to entities.

```
Person:
  - name: string (required)
  - age: integer (optional)
  
Company:
  - name: string (required)
  - founded: integer
```

#### 4. Inheritance (Subsumption)
Types can **inherit** from other types.

```
entity
  └── person
        ├── employee
        └── customer
  └── organization
        ├── company
        └── nonprofit
```

This enables **polymorphic queries**: asking for all "persons" returns employees AND customers.

#### 5. Inference Rules
Rules define **implicit knowledge** that can be derived.

```
Rule: colleague_inference
  IF person A works at company C
  AND person B works at company C
  AND A ≠ B
  THEN A and B are colleagues
```

### Why Hypergraphs?

Traditional graphs connect exactly 2 nodes per edge. **Hypergraphs** allow edges to connect **any number** of nodes:

```
Binary Graph:                    Hypergraph:
Alice --friend-- Bob             (Alice, Bob, Carol) --group_chat
                                 
Need 3 edges for triangle:       Just 1 hyperedge for n-ary relation:
Alice --friend-- Bob             sale(buyer: Alice, 
Bob --friend-- Carol                   seller: Bob,
Carol --friend-- Alice                 item: Book,
                                       price: $20,
                                       date: 2024-01-15)
```

This naturally models **n-ary relations** without awkward decomposition.

---

## Building Order

### Phase 1: Core Foundation (Start Here!)

**Goal**: Get basic data storage and retrieval working.

1. **Understand `lexx_types.m`**
   - Read through all type definitions
   - Understand: vertex, hyperedge, type_def, pattern, rule

2. **Understand `lexx_hypergraph.m`**
   - Study the internal representation
   - Understand indexing strategy

3. **Run the test**:
   ```bash
   cd /home/claude/lexx-hypergraph
   mmc --make tests/test_basic
   ./test_basic
   ```

### Phase 2: Schema System

**Goal**: Full type hierarchy with validation.

1. **Enhance `lexx_type_registry.m`**
   - Add validation (can't create orphan types)
   - Add schema export/import

2. **Create `lexx_constraints.m`** (new file):
   - Uniqueness constraints
   - Cardinality constraints (e.g., "a person can have at most 1 spouse")

### Phase 3: Query System

**Goal**: Declarative queries with pattern matching.

1. **Create `lexx_unification.m`**:
   - Pattern unification algorithm
   - Variable binding

2. **Create `lexx_pattern.m`**:
   - Pattern compilation
   - Index selection

3. **Create `lexx_parser.m`** (optional):
   - Query language syntax
   - Or just use Mercury data constructors directly

### Phase 4: Inference Enhancement

**Goal**: Full backward/forward chaining with explanation.

1. **Enhance `lexx_rule_engine.m`**:
   - Proper inequality handling ($a ≠ $b)
   - Recursive rules
   - Better cycle detection

2. **Create `lexx_explanation.m`**:
   - Human-readable proof output
   - Visualization helpers

### Phase 5: Persistence

**Goal**: Durable storage.

1. **Create `lexx_storage.m`**:
   - Serialization format
   - File-based storage

2. **Create `lexx_storage_ffi.c`** (optional):
   - Memory-mapped files
   - B-tree indexes in C

### Phase 6: Integration with Lexx AI

**Goal**: Connect to emotion/motivation systems.

1. Design ontology for Kismet-style emotions
2. Define rules for emotional inference
3. Create query interface for cognitive layer

---

## Learning Resources

### Ontology Engineering

1. **"Ontology Development 101"** (Stanford/Protégé)
   - Free PDF, excellent introduction
   - https://protege.stanford.edu/publications/ontology_development/ontology101.pdf

2. **"A Practical Guide to Building OWL Ontologies"** (Manchester)
   - Hands-on tutorial
   - http://owl.cs.manchester.ac.uk/publications/talks-and-tutorials/

3. **"Semantic Web for the Working Ontologist"** (Book)
   - Comprehensive but accessible
   - Covers RDF, OWL, SPARQL

### Mercury Programming

1. **Mercury Tutorial**
   - https://mercurylang.org/documentation/papers/book.pdf

2. **Mercury Reference Manual**
   - https://mercurylang.org/documentation/reference_manual.html

3. **Mercury Library Reference**
   - https://mercurylang.org/documentation/library_reference.html

### Database Internals

1. **"Architecture of a Database System"** (Hellerstein et al.)
   - Free paper on database architecture
   - Good for understanding query processing

2. **TypeDB Documentation**
   - https://typedb.com/docs
   - Good examples of polymorphic queries

### Knowledge Representation

1. **"Knowledge Representation and Reasoning"** (Brachman & Levesque)
   - Academic but comprehensive

2. **"Artificial Intelligence: A Modern Approach"** (Russell & Norvig)
   - Chapter 8-12 cover logic and knowledge representation

---

## Implementation Roadmap

### Week 1-2: Foundation
- [ ] Read ontology101.pdf completely
- [ ] Study existing code thoroughly
- [ ] Get test_basic.m compiling and running
- [ ] Add 3-5 more entity types to test schema
- [ ] Add 2-3 more relation types
- [ ] Write tests for type inheritance

### Week 3-4: Query System
- [ ] Implement proper pattern unification
- [ ] Add inequality constraints to patterns
- [ ] Implement attribute value matching in queries
- [ ] Write query tests

### Week 5-6: Inference
- [ ] Fix the colleague rule to handle $a ≠ $b
- [ ] Add 3-5 more inference rules
- [ ] Implement explanation pretty-printing
- [ ] Test recursive rules

### Week 7-8: Lexx Integration Design
- [ ] Design emotion ontology (based on Kismet)
- [ ] Define motivation/drive types
- [ ] Design sensory input representation
- [ ] Plan cognitive layer interface

### Beyond: Production Features
- [ ] Persistence layer
- [ ] Transaction support
- [ ] Query optimization
- [ ] Concurrent access

---

## Quick Start Commands

```bash
# Navigate to project
cd /home/claude/lexx-hypergraph

# Check Mercury installation
mmc --version

# Build core modules
mmc --make src/core/lexx_hypergraph

# Build all and run test
mmc --make tests/test_basic
./test_basic

# Clean build artifacts
make clean
```

---

## Example: Building a Simple Ontology

Here's how to think about ontology design for Lexx's emotion system:

### Step 1: Identify Core Concepts
```
What "things" exist in the emotional domain?
- EmotionalState (happy, sad, curious, etc.)
- Drive (hunger, social, stimulation)
- Stimulus (visual input, audio input, interaction)
- Response (expression, action, utterance)
```

### Step 2: Identify Relationships
```
How do these things connect?
- Stimulus --triggers--> EmotionalState
- Drive --influences--> EmotionalState  
- EmotionalState --produces--> Response
- Response --satisfies--> Drive
```

### Step 3: Define Attributes
```
What data do we track?
- EmotionalState: valence (positive/negative), arousal (high/low), intensity
- Drive: current_level, threshold, decay_rate
- Stimulus: type, intensity, novelty
```

### Step 4: Define Inference Rules
```
What can we derive?
- IF stimulus is novel AND arousal is low THEN increase curiosity
- IF social_drive > threshold AND no_recent_interaction THEN increase loneliness
- IF positive_interaction THEN decrease social_drive level
```

---

## Need Help?

As you work through this:

1. **Start small** - Get one type working before adding more
2. **Test incrementally** - Add tests as you add features
3. **Read the types** - Mercury's type system catches many errors
4. **Trace inference** - Use explanation system to debug rules

Good luck building Lexx!
