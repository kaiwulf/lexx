%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% File: lexx_rule_engine.m
% Main author: [Your Name]
%
% Rule-based inference engine for the Lexx hypergraph database.
% Implements both backward chaining (query-time) and forward chaining
% (materialization) inference strategies.
%
% KNOWLEDGE ENGINEERING CONCEPTS:
% - Rules encode domain knowledge as IF-THEN statements
% - Backward chaining: Start from query, work backward to find supporting facts
% - Forward chaining: Start from facts, derive all possible conclusions
% - Proof trees: Track how conclusions were derived (explainability)
%
%-----------------------------------------------------------------------------%

:- module lexx_rule_engine.
:- interface.

:- import_module lexx_types.
:- import_module lexx_hypergraph.
:- import_module lexx_type_registry.
:- import_module list.
:- import_module map.
:- import_module set.
:- import_module maybe.

%-----------------------------------------------------------------------------%
%
% Rule Registry
%

:- type rule_registry.

    % Create empty rule registry
:- func init_rules = rule_registry.

    % Add a rule
:- pred add_rule(rule::in, lexx_result(unit)::out,
    rule_registry::in, rule_registry::out) is det.

    % Get a rule by ID
:- pred get_rule(rule_registry::in, rule_id::in, rule::out) is semidet.

    % Get all rules
:- func get_all_rules(rule_registry) = list(rule).

    % Get rules that could produce a given relation type
:- pred get_rules_for_type(rule_registry::in, type_id::in,
    list(rule)::out) is det.

%-----------------------------------------------------------------------------%
%
% Inference Configuration
%

:- type inference_config
    --->    inference_config(
                ic_max_depth        :: int,         % Max recursion depth
                ic_enable_explain   :: bool,        % Track proofs?
                ic_timeout_ms       :: int          % Timeout in milliseconds
            ).

:- func default_config = inference_config.

%-----------------------------------------------------------------------------%
%
% Backward Chaining (Query-Time Inference)
%

    % Execute a query with inference enabled
    % Returns all matching results with optional proof trees
:- pred query_with_inference(
    hypergraph::in,
    type_registry::in,
    rule_registry::in,
    inference_config::in,
    pattern::in,
    list(query_result)::out) is det.

%-----------------------------------------------------------------------------%
%
% Forward Chaining (Materialization)
%

    % Materialize all possible inferences
    % Runs rules until no new facts are derived
:- pred materialize_all(
    type_registry::in,
    rule_registry::in,
    hypergraph::in, hypergraph::out) is det.

    % Materialize incrementally (one step)
    % Returns whether any new facts were derived
:- pred materialize_step(
    type_registry::in,
    rule_registry::in,
    bool::out,
    hypergraph::in, hypergraph::out) is det.

%-----------------------------------------------------------------------------%
%
% Explanation
%

    % Get human-readable explanation of a proof
:- func explain_proof(hypergraph, proof_node) = string.

%-----------------------------------------------------------------------------%
:- implementation.

:- import_module int.
:- import_module string.
:- import_module solutions.
:- import_module require.
:- import_module bool.
:- import_module unit.

%-----------------------------------------------------------------------------%
%
% Rule Registry Implementation
%

:- type rule_registry
    --->    rule_registry(
                rr_rules            :: map(rule_id, rule),
                % Index: conclusion type -> rules that produce it
                rr_conclusion_idx   :: map(type_id, set(rule_id))
            ).

init_rules = rule_registry(map.init, map.init).

add_rule(Rule, Result, !Registry) :-
    RuleId = Rule ^ rule_id,
    ( if map.contains(!.Registry ^ rr_rules, RuleId) then
        Result = error(type_error("Rule already exists: " ++ RuleId))
    else
        % Add to main map
        map.det_insert(RuleId, Rule, !.Registry ^ rr_rules, NewRules),
        
        % Index by conclusion type
        ConclusionType = get_conclusion_type(Rule ^ rule_then),
        ConcIdx0 = !.Registry ^ rr_conclusion_idx,
        ( if map.search(ConcIdx0, ConclusionType, ExistingRules) then
            map.det_update(ConclusionType, 
                set.insert(ExistingRules, RuleId), ConcIdx0, ConcIdx)
        else
            map.det_insert(ConclusionType, 
                set.make_singleton_set(RuleId), ConcIdx0, ConcIdx)
        ),
        
        !:Registry = rule_registry(NewRules, ConcIdx),
        Result = ok(unit)
    ).

:- func get_conclusion_type(conclusion) = type_id.

get_conclusion_type(conclude_edge(TypeId, _, _)) = TypeId.
get_conclusion_type(conclude_attr(_, _, _)) = "attribute".

get_rule(Registry, RuleId, Rule) :-
    map.search(Registry ^ rr_rules, RuleId, Rule).

get_all_rules(Registry) = map.values(Registry ^ rr_rules).

get_rules_for_type(Registry, TypeId, Rules) :-
    ConcIdx = Registry ^ rr_conclusion_idx,
    ( if map.search(ConcIdx, TypeId, RuleIds) then
        RuleMap = Registry ^ rr_rules,
        Rules = set.fold(
            (func(RId, Acc) =
                ( if map.search(RuleMap, RId, R) then [R | Acc] else Acc )
            ),
            RuleIds, []
        )
    else
        Rules = []
    ).

%-----------------------------------------------------------------------------%
%
% Configuration
%

default_config = inference_config(
    100,        % max depth
    yes,        % enable explanations
    30000       % 30 second timeout
).

%-----------------------------------------------------------------------------%
%
% Backward Chaining Implementation
%

    % Internal state for backward chaining
:- type bc_state
    --->    bc_state(
                bcs_hg          :: hypergraph,
                bcs_types       :: type_registry,
                bcs_rules       :: rule_registry,
                bcs_config      :: inference_config,
                bcs_depth       :: int,
                bcs_visited     :: set(pattern)     % Cycle detection
            ).

query_with_inference(HG, TypeReg, RuleReg, Config, QueryPattern, Results) :-
    State = bc_state(HG, TypeReg, RuleReg, Config, 0, set.init),
    backward_chain(State, QueryPattern, Results).

:- pred backward_chain(bc_state::in, pattern::in, 
    list(query_result)::out) is det.

backward_chain(State, Pattern, Results) :-
    % Check depth limit
    ( if State ^ bcs_depth > State ^ bcs_config ^ ic_max_depth then
        Results = []
    % Check for cycles
    else if set.member(Pattern, State ^ bcs_visited) then
        Results = []
    else
        NewVisited = set.insert(State ^ bcs_visited, Pattern),
        NewState = State ^ bcs_visited := NewVisited,
        NewState2 = NewState ^ bcs_depth := State ^ bcs_depth + 1,
        
        % Try explicit matches first
        find_explicit_matches(State ^ bcs_hg, State ^ bcs_types, 
            Pattern, ExplicitResults),
        
        % Then try rule-based inference
        find_rule_matches(NewState2, Pattern, RuleResults),
        
        % Combine and deduplicate
        AllResults = ExplicitResults ++ RuleResults,
        Results = deduplicate_results(AllResults)
    ).

    % Find matches in explicit (asserted) data
:- pred find_explicit_matches(hypergraph::in, type_registry::in,
    pattern::in, list(query_result)::out) is det.

find_explicit_matches(HG, TypeReg, Pattern, Results) :-
    (
        Pattern = vertex_pattern(VarName, TypeConstraint, AttrConstraints),
        resolve_type_constraint(TypeReg, TypeConstraint, ValidTypes),
        Vertices = get_all_vertices(HG),
        MatchingVertices = list.filter(
            vertex_matches(TypeReg, ValidTypes, AttrConstraints),
            Vertices
        ),
        Results = list.map(
            (func(V) = query_result(
                map.singleton(VarName, V ^ v_id),
                yes(proof_fact(-1))
            )),
            MatchingVertices
        )
    ;
        Pattern = edge_pattern(VarName, TypeConstraint, RoleConstraints, 
            AttrConstraints),
        resolve_type_constraint(TypeReg, TypeConstraint, ValidTypes),
        Edges = get_all_hyperedges(HG),
        MatchingEdges = list.filter(
            edge_matches(TypeReg, ValidTypes, AttrConstraints),
            Edges
        ),
        Results = list.filter_map(
            edge_to_result(VarName, RoleConstraints),
            MatchingEdges
        )
    ;
        Pattern = pattern_and(P1, P2),
        find_explicit_matches(HG, TypeReg, P1, Results1),
        find_explicit_matches(HG, TypeReg, P2, Results2),
        Results = join_results(Results1, Results2)
    ;
        Pattern = pattern_or(P1, P2),
        find_explicit_matches(HG, TypeReg, P1, Results1),
        find_explicit_matches(HG, TypeReg, P2, Results2),
        Results = Results1 ++ Results2
    ;
        Pattern = pattern_not(_),
        % Negation requires special handling - for now, return empty
        Results = []
    ).

:- pred vertex_matches(type_registry::in, set(type_id)::in, 
    list(attr_constraint)::in, vertex::in) is semidet.

vertex_matches(TypeReg, ValidTypes, AttrConstraints, Vertex) :-
    % Check type constraint (including inheritance)
    VType = Vertex ^ v_type,
    ( set.member(VType, ValidTypes)
    ; 
        set.fold(
            (pred(ValidT::in, Found::in, Found1::out) is det :-
                ( if 
                    Found = no,
                    is_subtype_of(TypeReg, VType, ValidT) 
                then
                    Found1 = yes
                else
                    Found1 = Found
                )
            ),
            ValidTypes, no, yes)
    ),
    % Check attribute constraints
    all_attr_constraints_match(Vertex ^ v_attrs, AttrConstraints).

:- pred all_attr_constraints_match(attribute_map::in, 
    list(attr_constraint)::in) is semidet.

all_attr_constraints_match(_, []).
all_attr_constraints_match(Attrs, [C | Cs]) :-
    attr_constraint_matches(Attrs, C),
    all_attr_constraints_match(Attrs, Cs).

:- pred attr_constraint_matches(attribute_map::in, 
    attr_constraint::in) is semidet.

attr_constraint_matches(Attrs, attr_equals(Name, Value)) :-
    map.search(Attrs, Name, Value).
attr_constraint_matches(Attrs, attr_var(Name, _)) :-
    map.contains(Attrs, Name).
attr_constraint_matches(Attrs, attr_exists(Name)) :-
    map.contains(Attrs, Name).

:- pred edge_matches(type_registry::in, set(type_id)::in,
    list(attr_constraint)::in, hyperedge::in) is semidet.

edge_matches(TypeReg, ValidTypes, AttrConstraints, Edge) :-
    EType = Edge ^ he_type,
    ( set.member(EType, ValidTypes)
    ;
        set.fold(
            (pred(ValidT::in, Found::in, Found1::out) is det :-
                ( if 
                    Found = no,
                    is_subtype_of(TypeReg, EType, ValidT)
                then
                    Found1 = yes
                else
                    Found1 = Found
                )
            ),
            ValidTypes, no, yes)
    ),
    all_attr_constraints_match(Edge ^ he_attrs, AttrConstraints).

:- func edge_to_result(var_name, list(role_constraint), hyperedge) = 
    query_result is semidet.

edge_to_result(VarName, RoleConstraints, Edge) = Result :-
    % Build substitution from role constraints
    Roles = Edge ^ he_roles,
    Subst0 = map.singleton(VarName, Edge ^ he_id),
    list.foldl(
        (pred(RC::in, S0::in, S1::out) is semidet :-
            (
                RC = role_bound(RoleName, RoleVar),
                list.find_first_match(
                    (pred(role_binding(RN, _)::in) is semidet :- RN = RoleName),
                    Roles, role_binding(_, VId)
                ),
                map.det_insert(RoleVar, VId, S0, S1)
            ;
                RC = role_value(RoleName, ExpectedVId),
                list.member(role_binding(RoleName, ExpectedVId), Roles),
                S1 = S0
            )
        ),
        RoleConstraints, Subst0, Subst
    ),
    Result = query_result(Subst, yes(proof_fact(Edge ^ he_id))).

    % Find matches using inference rules
:- pred find_rule_matches(bc_state::in, pattern::in, 
    list(query_result)::out) is det.

find_rule_matches(State, Pattern, Results) :-
    % Get the type from the pattern
    PatternType = get_pattern_type(Pattern),
    
    % Find applicable rules
    get_rules_for_type(State ^ bcs_rules, PatternType, ApplicableRules),
    
    % Try each rule
    list.map(try_rule(State, Pattern), ApplicableRules, ResultLists),
    list.condense(ResultLists, Results).

:- func get_pattern_type(pattern) = type_id.

get_pattern_type(vertex_pattern(_, tc_exact(T), _)) = T.
get_pattern_type(vertex_pattern(_, tc_subtype(T), _)) = T.
get_pattern_type(vertex_pattern(_, tc_any, _)) = "entity".
get_pattern_type(edge_pattern(_, tc_exact(T), _, _)) = T.
get_pattern_type(edge_pattern(_, tc_subtype(T), _, _)) = T.
get_pattern_type(edge_pattern(_, tc_any, _, _)) = "relation".
get_pattern_type(pattern_and(P, _)) = get_pattern_type(P).
get_pattern_type(pattern_or(P, _)) = get_pattern_type(P).
get_pattern_type(pattern_not(P)) = get_pattern_type(P).

:- pred try_rule(bc_state::in, pattern::in, rule::in, 
    list(query_result)::out) is det.

try_rule(State, Pattern, Rule, Results) :-
    Rule = rule(RuleId, WhenPattern, ThenConclusion),
    
    % Check if conclusion could match pattern
    ( if conclusion_could_match(Pattern, ThenConclusion) then
        % Recursively prove the antecedent
        backward_chain(State, WhenPattern, AntecedentResults),
        
        % For each successful antecedent match, create a result
        Results = list.filter_map(
            make_rule_result(RuleId, Pattern, ThenConclusion),
            AntecedentResults
        )
    else
        Results = []
    ).

:- pred conclusion_could_match(pattern::in, conclusion::in) is semidet.

conclusion_could_match(edge_pattern(_, tc_exact(T), _, _), 
    conclude_edge(T, _, _)).
conclusion_could_match(edge_pattern(_, tc_subtype(_), _, _), 
    conclude_edge(_, _, _)).
conclusion_could_match(edge_pattern(_, tc_any, _, _), 
    conclude_edge(_, _, _)).
conclusion_could_match(_, conclude_attr(_, _, _)).

:- func make_rule_result(rule_id, pattern, conclusion, query_result) = 
    query_result is semidet.

make_rule_result(RuleId, _Pattern, _Conclusion, AntResult) = Result :-
    % Combine the antecedent bindings with rule application
    AntResult = query_result(Bindings, MaybeProof),
    NewProof = (
        MaybeProof = yes(ChildProof) ->
            yes(proof_rule(RuleId, [ChildProof]))
        ;
            yes(proof_rule(RuleId, []))
    ),
    Result = query_result(Bindings, NewProof).

    % Join results from AND patterns
:- func join_results(list(query_result), list(query_result)) = 
    list(query_result).

join_results(Results1, Results2) = JoinedResults :-
    JoinedResults = list.filter_map(
        (func(R1) = Joined is semidet :-
            R1 = query_result(Bindings1, Proof1),
            list.find_first_match(
                (pred(R2::in) is semidet :-
                    R2 = query_result(Bindings2, _),
                    compatible_bindings(Bindings1, Bindings2)
                ),
                Results2, query_result(Bindings2, Proof2)
            ),
            MergedBindings = map.overlay(Bindings1, Bindings2),
            MergedProof = merge_proofs(Proof1, Proof2),
            Joined = query_result(MergedBindings, MergedProof)
        ),
        Results1
    ).

:- pred compatible_bindings(substitution::in, substitution::in) is semidet.

compatible_bindings(B1, B2) :-
    map.foldl(
        (pred(K::in, V::in, Compat::in, Compat1::out) is semidet :-
            ( if map.search(B2, K, V2) then
                V = V2,
                Compat1 = Compat
            else
                Compat1 = Compat
            )
        ),
        B1, yes, yes
    ).

:- func merge_proofs(maybe(proof_node), maybe(proof_node)) = maybe(proof_node).

merge_proofs(yes(P1), yes(P2)) = yes(proof_rule("and", [P1, P2])).
merge_proofs(yes(P), no) = yes(P).
merge_proofs(no, yes(P)) = yes(P).
merge_proofs(no, no) = no.

:- func deduplicate_results(list(query_result)) = list(query_result).

deduplicate_results(Results) = 
    list.sort_and_remove_dups(Results).

%-----------------------------------------------------------------------------%
%
% Forward Chaining Implementation
%

materialize_all(TypeReg, RuleReg, !HG) :-
    materialize_step(TypeReg, RuleReg, Changed, !HG),
    (
        Changed = yes,
        materialize_all(TypeReg, RuleReg, !HG)
    ;
        Changed = no
    ).

materialize_step(TypeReg, RuleReg, Changed, !HG) :-
    Rules = get_all_rules(RuleReg),
    list.foldl2(
        apply_rule_forward(TypeReg),
        Rules, !HG, no, Changed
    ).

:- pred apply_rule_forward(type_registry::in, rule::in,
    hypergraph::in, hypergraph::out, bool::in, bool::out) is det.

apply_rule_forward(TypeReg, Rule, !HG, !Changed) :-
    Rule = rule(RuleId, WhenPattern, ThenConclusion),
    
    % Find all matches for the antecedent
    find_explicit_matches(!.HG, TypeReg, WhenPattern, Matches),
    
    % For each match, try to instantiate the conclusion
    list.foldl2(
        instantiate_conclusion(RuleId, ThenConclusion),
        Matches, !HG, !Changed
    ).

:- pred instantiate_conclusion(rule_id::in, conclusion::in,
    query_result::in, hypergraph::in, hypergraph::out, 
    bool::in, bool::out) is det.

instantiate_conclusion(RuleId, Conclusion, QueryResult, !HG, !Changed) :-
    QueryResult = query_result(Bindings, MaybeAntProof),
    (
        Conclusion = conclude_edge(TypeId, RoleConcs, AttrConcs),
        
        % Build role bindings from conclusion
        RoleBindings = list.filter_map(
            (func(role_from_var(RoleName, VarName)) = 
                role_binding(RoleName, VId) is semidet :-
                map.search(Bindings, VarName, VId)
            ),
            RoleConcs
        ),
        
        % Build attributes from conclusion
        Attrs = list.foldl(
            (func(AC, A) = NewA :-
                (
                    AC = attr_const(Name, Value),
                    map.set(Name, Value, A, NewA)
                ;
                    AC = attr_from_var(_, _),
                    % Would need value bindings too
                    NewA = A
                )
            ),
            AttrConcs, map.init
        ),
        
        % Check if this edge already exists
        ( if edge_already_exists(!.HG, TypeId, RoleBindings) then
            true
        else
            % Create proof node
            Proof = (
                MaybeAntProof = yes(AntProof) ->
                    proof_rule(RuleId, [AntProof])
                ;
                    proof_rule(RuleId, [])
            ),
            Status = inferred(RuleId, Proof),
            
            % Add the new edge
            add_hyperedge(TypeId, RoleBindings, Attrs, Status, _, !HG),
            !:Changed = yes
        )
    ;
        Conclusion = conclude_attr(_, _, _),
        % Attribute conclusions - not yet implemented
        true
    ).

:- pred edge_already_exists(hypergraph::in, type_id::in, 
    list(role_binding)::in) is semidet.

edge_already_exists(HG, TypeId, RoleBindings) :-
    get_hyperedges_by_type(HG, TypeId, Edges),
    list.member(Edge, Edges),
    Edge ^ he_roles = RoleBindings.

%-----------------------------------------------------------------------------%
%
% Explanation
%

explain_proof(HG, ProofNode) = Explanation :-
    explain_proof_impl(HG, 0, ProofNode, Explanation).

:- pred explain_proof_impl(hypergraph::in, int::in, proof_node::in,
    string::out) is det.

explain_proof_impl(HG, Indent, ProofNode, Explanation) :-
    IndentStr = string.duplicate_char(' ', Indent * 2),
    (
        ProofNode = proof_fact(EdgeId),
        ( if EdgeId = -1 then
            Explanation = IndentStr ++ "MATCHED explicit data\n"
        else if get_hyperedge(HG, EdgeId, Edge) then
            Explanation = IndentStr ++ "FACT: " ++ 
                Edge ^ he_type ++ " (id=" ++ 
                string.int_to_string(EdgeId) ++ ")\n"
        else
            Explanation = IndentStr ++ "FACT: (unknown edge)\n"
        )
    ;
        ProofNode = proof_rule(RuleId, Children),
        Header = IndentStr ++ "BY RULE: " ++ RuleId ++ "\n",
        ChildExplanations = list.map(
            (func(Child) = ChildExpl :-
                explain_proof_impl(HG, Indent + 1, Child, ChildExpl)
            ),
            Children
        ),
        Explanation = Header ++ string.append_list(ChildExplanations)
    ).

%-----------------------------------------------------------------------------%
:- end_module lexx_rule_engine.
%-----------------------------------------------------------------------------%
