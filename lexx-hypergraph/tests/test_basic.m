%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% File: test_basic.m
% 
% Basic test and example usage of the Lexx Hypergraph Database Engine.
% This demonstrates the core concepts: types, vertices, edges, and rules.
%
%-----------------------------------------------------------------------------%

:- module test_basic.
:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

%-----------------------------------------------------------------------------%
:- implementation.

:- import_module lexx_types.
:- import_module lexx_hypergraph.
:- import_module lexx_type_registry.
:- import_module lexx_rule_engine.

:- import_module list.
:- import_module map.
:- import_module set.
:- import_module maybe.
:- import_module string.
:- import_module int.
:- import_module unit.

%-----------------------------------------------------------------------------%

main(!IO) :-
    io.write_string("=== Lexx Hypergraph Database Engine Test ===\n\n", !IO),
    
    % Step 1: Create the schema (type definitions)
    io.write_string("1. Creating Schema...\n", !IO),
    create_test_schema(TypeReg, !IO),
    
    % Step 2: Create the hypergraph and add data
    io.write_string("\n2. Creating Data...\n", !IO),
    create_test_data(TypeReg, HG, !IO),
    
    % Step 3: Define inference rules
    io.write_string("\n3. Creating Inference Rules...\n", !IO),
    create_test_rules(RuleReg, !IO),
    
    % Step 4: Query the data
    io.write_string("\n4. Querying Data...\n", !IO),
    run_test_queries(HG, TypeReg, RuleReg, !IO),
    
    % Step 5: Run forward chaining inference
    io.write_string("\n5. Running Forward Chaining Inference...\n", !IO),
    run_inference(HG, TypeReg, RuleReg, HG2, !IO),
    
    % Step 6: Query inferred data
    io.write_string("\n6. Querying Inferred Data...\n", !IO),
    query_inferred_data(HG2, !IO),
    
    io.write_string("\n=== Test Complete ===\n", !IO).

%-----------------------------------------------------------------------------%
%
% Schema Creation
%
% This demonstrates ONTOLOGY ENGINEERING:
% - We define WHAT KINDS of things can exist (entity types)
% - We define HOW things can relate (relation types)
% - We establish a TYPE HIERARCHY (inheritance)
%

:- pred create_test_schema(type_registry::out, io::di, io::uo) is det.

create_test_schema(TypeReg, !IO) :-
    TypeReg0 = init,
    
    % Define entity types
    % "Person" is a subtype of the root "entity" type
    PersonType = entity_type(
        "person",                           % Type ID
        yes("entity"),                      % Parent type
        [                                   % Attributes it can own
            attr_spec("name", vt_string, yes, no),
            attr_spec("age", vt_int, no, no)
        ],
        [                                   % Roles it can play
            role_spec("friendship", "friend"),
            role_spec("employment", "employee"),
            role_spec("employment", "employer")
        ]
    ),
    
    % "Company" is also an entity
    CompanyType = entity_type(
        "company",
        yes("entity"),
        [
            attr_spec("name", vt_string, yes, no),
            attr_spec("founded", vt_int, no, no)
        ],
        [
            role_spec("employment", "employer")
        ]
    ),
    
    % Define relation types
    % "Friendship" connects two persons
    FriendshipType = relation_type(
        "friendship",
        yes("relation"),
        [
            role_def("friend", set.from_list(["person"]))
        ],
        []
    ),
    
    % "Employment" connects a person to a company
    EmploymentType = relation_type(
        "employment",
        yes("relation"),
        [
            role_def("employee", set.from_list(["person"])),
            role_def("employer", set.from_list(["company", "person"]))
        ],
        [
            attr_spec("start_year", vt_int, no, no)
        ]
    ),
    
    % "Colleague" relation - will be inferred by rules
    ColleagueType = relation_type(
        "colleague",
        yes("relation"),
        [
            role_def("coworker", set.from_list(["person"]))
        ],
        []
    ),
    
    % Register all types
    register_type(PersonType, _, TypeReg0, TypeReg1),
    register_type(CompanyType, _, TypeReg1, TypeReg2),
    register_type(FriendshipType, _, TypeReg2, TypeReg3),
    register_type(EmploymentType, _, TypeReg3, TypeReg4),
    register_type(ColleagueType, _, TypeReg4, TypeReg),
    
    io.write_string("   Registered types: person, company, friendship, employment, colleague\n", !IO).

%-----------------------------------------------------------------------------%
%
% Data Creation
%
% This demonstrates KNOWLEDGE REPRESENTATION:
% - Vertices are ENTITIES (concrete instances)
% - Hyperedges are RELATIONS (connections between entities)
%

:- pred create_test_data(type_registry::in, hypergraph::out, 
    io::di, io::uo) is det.

create_test_data(_TypeReg, HG, !IO) :-
    HG0 = init,
    
    % Create people
    add_vertex("person", 
        map.from_assoc_list([
            "name" - v_string("Alice"),
            "age" - v_int(30)
        ]), 
        AliceId, HG0, HG1),
    
    add_vertex("person",
        map.from_assoc_list([
            "name" - v_string("Bob"),
            "age" - v_int(28)
        ]),
        BobId, HG1, HG2),
    
    add_vertex("person",
        map.from_assoc_list([
            "name" - v_string("Carol"),
            "age" - v_int(35)
        ]),
        CarolId, HG2, HG3),
    
    % Create company
    add_vertex("company",
        map.from_assoc_list([
            "name" - v_string("TechCorp"),
            "founded" - v_int(2010)
        ]),
        TechCorpId, HG3, HG4),
    
    io.format("   Created vertices: Alice(%d), Bob(%d), Carol(%d), TechCorp(%d)\n",
        [i(AliceId), i(BobId), i(CarolId), i(TechCorpId)], !IO),
    
    % Create friendship: Alice <-> Bob
    add_hyperedge("friendship",
        [role_binding("friend", AliceId), role_binding("friend", BobId)],
        map.init, explicit, _, HG4, HG5),
    
    % Create employments: Alice and Bob work at TechCorp
    add_hyperedge("employment",
        [role_binding("employee", AliceId), role_binding("employer", TechCorpId)],
        map.from_assoc_list(["start_year" - v_int(2015)]),
        explicit, _, HG5, HG6),
    
    add_hyperedge("employment",
        [role_binding("employee", BobId), role_binding("employer", TechCorpId)],
        map.from_assoc_list(["start_year" - v_int(2018)]),
        explicit, _, HG6, HG),
    
    io.write_string("   Created relations: Alice-Bob friendship, Alice-TechCorp employment, Bob-TechCorp employment\n", !IO).

%-----------------------------------------------------------------------------%
%
% Rule Creation
%
% This demonstrates KNOWLEDGE ENGINEERING:
% - Rules encode domain knowledge as IF-THEN statements
% - "If two people work at the same company, they are colleagues"
%

:- pred create_test_rules(rule_registry::out, io::di, io::uo) is det.

create_test_rules(RuleReg, !IO) :-
    RuleReg0 = init_rules,
    
    % Rule: If person A and person B both work at company C, 
    %       then A and B are colleagues
    %
    % In pattern form:
    %   WHEN: 
    %     employment(employee: $a, employer: $c) AND
    %     employment(employee: $b, employer: $c) AND
    %     $a != $b
    %   THEN:
    %     colleague(coworker: $a, coworker: $b)
    
    ColleagueRule = rule(
        "colleague_rule",
        pattern_and(
            edge_pattern(
                "emp1",
                tc_exact("employment"),
                [role_bound("employee", "person_a"), 
                 role_bound("employer", "company")],
                []
            ),
            edge_pattern(
                "emp2",
                tc_exact("employment"),
                [role_bound("employee", "person_b"),
                 role_bound("employer", "company")],
                []
            )
        ),
        conclude_edge(
            "colleague",
            [role_from_var("coworker", "person_a"),
             role_from_var("coworker", "person_b")],
            []
        )
    ),
    
    add_rule(ColleagueRule, _, RuleReg0, RuleReg),
    
    io.write_string("   Created rule: colleague_rule (same employer -> colleagues)\n", !IO).

%-----------------------------------------------------------------------------%
%
% Query Execution
%

:- pred run_test_queries(hypergraph::in, type_registry::in, 
    rule_registry::in, io::di, io::uo) is det.

run_test_queries(HG, _TypeReg, _RuleReg, !IO) :-
    % Query 1: Get all people
    io.write_string("   Query: All people\n", !IO),
    get_vertices_by_type(HG, "person", People),
    list.foldl(print_vertex, People, !IO),
    
    % Query 2: Get all friendships
    io.write_string("\n   Query: All friendships\n", !IO),
    get_hyperedges_by_type(HG, "friendship", Friendships),
    list.foldl(print_edge, Friendships, !IO),
    
    % Query 3: Get all employments
    io.write_string("\n   Query: All employments\n", !IO),
    get_hyperedges_by_type(HG, "employment", Employments),
    list.foldl(print_edge, Employments, !IO).

:- pred print_vertex(vertex::in, io::di, io::uo) is det.

print_vertex(Vertex, !IO) :-
    Vertex = vertex(Id, Type, Attrs),
    NameStr = (
        map.search(Attrs, "name", v_string(N)) -> N ; "unnamed"
    ),
    io.format("      [%d] %s: %s\n", [i(Id), s(Type), s(NameStr)], !IO).

:- pred print_edge(hyperedge::in, io::di, io::uo) is det.

print_edge(Edge, !IO) :-
    Edge = hyperedge(Id, Type, Roles, _, Status),
    RolesStr = string.join_list(", ", 
        list.map(
            (func(role_binding(R, V)) = R ++ ":" ++ int_to_string(V)),
            Roles
        )
    ),
    StatusStr = (
        Status = explicit -> "explicit"
        ; Status = inferred(RuleId, _) -> "inferred by " ++ RuleId
    ),
    io.format("      [%d] %s(%s) [%s]\n", 
        [i(Id), s(Type), s(RolesStr), s(StatusStr)], !IO).

%-----------------------------------------------------------------------------%
%
% Inference
%

:- pred run_inference(hypergraph::in, type_registry::in, rule_registry::in,
    hypergraph::out, io::di, io::uo) is det.

run_inference(HG0, TypeReg, RuleReg, HG, !IO) :-
    io.write_string("   Running materialization...\n", !IO),
    
    EdgeCountBefore = hyperedge_count(HG0),
    
    materialize_all(TypeReg, RuleReg, HG0, HG),
    
    EdgeCountAfter = hyperedge_count(HG),
    NewEdges = EdgeCountAfter - EdgeCountBefore,
    
    io.format("   Derived %d new facts\n", [i(NewEdges)], !IO).

:- pred query_inferred_data(hypergraph::in, io::di, io::uo) is det.

query_inferred_data(HG, !IO) :-
    io.write_string("   Query: All colleague relations (inferred)\n", !IO),
    get_hyperedges_by_type(HG, "colleague", Colleagues),
    ( if list.is_empty(Colleagues) then
        io.write_string("      (none found - inference may need refinement)\n", !IO)
    else
        list.foldl(print_edge, Colleagues, !IO)
    ),
    
    io.write_string("\n   All inferred facts:\n", !IO),
    get_inferred_hyperedges(HG, AllInferred),
    ( if list.is_empty(AllInferred) then
        io.write_string("      (none)\n", !IO)
    else
        list.foldl(print_edge, AllInferred, !IO)
    ).

%-----------------------------------------------------------------------------%
:- end_module test_basic.
%-----------------------------------------------------------------------------%
