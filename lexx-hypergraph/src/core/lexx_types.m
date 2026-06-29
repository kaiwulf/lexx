%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% File: lexx_types.m
% Main author: [Your Name]
% 
% Core type definitions for the Lexx Hypergraph Database Engine.
% This module defines the fundamental data structures used throughout
% the system, following ontology engineering principles.
%
% Key Concepts:
% - Vertices represent entities (things that exist)
% - Hyperedges represent n-ary relations (connections between entities)
% - Types define the schema (what kinds of things can exist)
% - Rules define inference (what can be derived)
%
%-----------------------------------------------------------------------------%

:- module lexx_types.
:- interface.

:- import_module list.
:- import_module map.
:- import_module set.
:- import_module maybe.
:- import_module int.
:- import_module string.
:- import_module float.

%-----------------------------------------------------------------------------%
%
% Identity Types
%

    % Unique identifiers for various entities
:- type vertex_id == int.
:- type hyperedge_id == int.
:- type type_id == string.
:- type rule_id == string.
:- type attr_name == string.
:- type role_name == string.

%-----------------------------------------------------------------------------%
%
% Value Types (Attribute Values)
%

    % Primitive values that can be stored as attributes
:- type value
    --->    v_string(string)
    ;       v_int(int)
    ;       v_float(float)
    ;       v_bool(bool)
    ;       v_null.

    % Type descriptor for values
:- type value_type
    --->    vt_string
    ;       vt_int
    ;       vt_float
    ;       vt_bool.

%-----------------------------------------------------------------------------%
%
% Attribute System
%

    % An attribute is a named value
:- type attribute
    --->    attribute(
                attr_name   :: attr_name,
                attr_value  :: value
            ).

    % Map of attribute names to values
:- type attribute_map == map(attr_name, value).

%-----------------------------------------------------------------------------%
%
% Core Hypergraph Elements
%

    % A vertex represents an entity in the knowledge base
:- type vertex
    --->    vertex(
                v_id        :: vertex_id,
                v_type      :: type_id,
                v_attrs     :: attribute_map
            ).

    % A role binding connects a role name to a vertex
    % Used in hyperedges for n-ary relations
:- type role_binding
    --->    role_binding(
                rb_role     :: role_name,
                rb_vertex   :: vertex_id
            ).

    % Inference status tracks whether data is explicit or derived
:- type inference_status
    --->    explicit                    % Directly asserted by user
    ;       inferred(                   % Derived by inference engine
                inf_rule    :: rule_id,
                inf_proof   :: proof_node
            ).

    % A hyperedge represents an n-ary relation
:- type hyperedge
    --->    hyperedge(
                he_id       :: hyperedge_id,
                he_type     :: type_id,
                he_roles    :: list(role_binding),
                he_attrs    :: attribute_map,
                he_status   :: inference_status
            ).

%-----------------------------------------------------------------------------%
%
% Proof/Explanation System
%

    % Proof trees for explaining inferences
:- type proof_node
    --->    proof_fact(hyperedge_id)            % Base case: explicit fact
    ;       proof_rule(                         % Recursive: rule application
                pr_rule     :: rule_id,
                pr_children :: list(proof_node)
            ).

%-----------------------------------------------------------------------------%
%
% Type System (Schema Definitions)
%

    % A role definition within a relation type
:- type role_def
    --->    role_def(
                rd_name         :: role_name,
                rd_allowed_types :: set(type_id)  % Types that can play this role
            ).

    % Attribute specification in a type
:- type attr_spec
    --->    attr_spec(
                as_name         :: attr_name,
                as_type         :: value_type,
                as_required     :: bool,
                as_unique       :: bool
            ).

    % Role specification (what roles a type can play)
:- type role_spec
    --->    role_spec(
                rs_relation     :: type_id,       % The relation type
                rs_role         :: role_name      % The role within it
            ).

    % Type definitions - the schema building blocks
:- type type_def
    --->    entity_type(
                et_id           :: type_id,
                et_parent       :: maybe(type_id),    % Inheritance
                et_owns         :: list(attr_spec),   % Attributes
                et_plays        :: list(role_spec)    % Roles it can play
            )
    ;       relation_type(
                rt_id           :: type_id,
                rt_parent       :: maybe(type_id),
                rt_relates      :: list(role_def),    % Roles in this relation
                rt_owns         :: list(attr_spec)
            )
    ;       attribute_type(
                at_id           :: type_id,
                at_parent       :: maybe(type_id),
                at_value_type   :: value_type
            ).

%-----------------------------------------------------------------------------%
%
% Pattern Matching (Query Patterns)
%

    % Variable names in patterns
:- type var_name == string.

    % Type constraints in patterns
:- type type_constraint
    --->    tc_exact(type_id)           % Exactly this type
    ;       tc_subtype(type_id)         % This type or any subtype
    ;       tc_any.                     % Any type

    % Attribute constraints in patterns
:- type attr_constraint
    --->    attr_equals(attr_name, value)
    ;       attr_var(attr_name, var_name)
    ;       attr_exists(attr_name).

    % Role constraints in patterns
:- type role_constraint
    --->    role_bound(role_name, var_name)
    ;       role_value(role_name, vertex_id).

    % Query patterns - what we're searching for
:- type pattern
    --->    vertex_pattern(
                vp_var          :: var_name,
                vp_type         :: type_constraint,
                vp_attrs        :: list(attr_constraint)
            )
    ;       edge_pattern(
                ep_var          :: var_name,
                ep_type         :: type_constraint,
                ep_roles        :: list(role_constraint),
                ep_attrs        :: list(attr_constraint)
            )
    ;       pattern_and(pattern, pattern)
    ;       pattern_or(pattern, pattern)
    ;       pattern_not(pattern).

%-----------------------------------------------------------------------------%
%
% Inference Rules
%

    % A rule defines how to derive new facts
:- type rule
    --->    rule(
                rule_id         :: rule_id,
                rule_when       :: pattern,       % Antecedent (condition)
                rule_then       :: conclusion     % Consequent (what to infer)
            ).

    % What a rule can conclude
:- type conclusion
    --->    conclude_edge(
                ce_type         :: type_id,
                ce_roles        :: list(role_conclusion),
                ce_attrs        :: list(attr_conclusion)
            )
    ;       conclude_attr(
                ca_var          :: var_name,
                ca_attr         :: attr_name,
                ca_value        :: attr_value_expr
            ).

:- type role_conclusion
    --->    role_from_var(role_name, var_name).

:- type attr_conclusion
    --->    attr_const(attr_name, value)
    ;       attr_from_var(attr_name, var_name).

:- type attr_value_expr
    --->    ave_const(value)
    ;       ave_var(var_name).

%-----------------------------------------------------------------------------%
%
% Query Results and Substitutions
%

    % A substitution maps variables to vertex IDs
:- type substitution == map(var_name, vertex_id).

    % A query result includes bindings and optional proof
:- type query_result
    --->    query_result(
                qr_bindings     :: substitution,
                qr_proof        :: maybe(proof_node)
            ).

%-----------------------------------------------------------------------------%
%
% Transaction Types
%

:- type transaction_id == int.

:- type transaction_mode
    --->    tx_read
    ;       tx_write.

:- type transaction_status
    --->    tx_active
    ;       tx_committed
    ;       tx_aborted.

%-----------------------------------------------------------------------------%
%
% Error Types
%

:- type lexx_error
    --->    type_error(string)
    ;       constraint_error(string)
    ;       not_found_error(string)
    ;       transaction_error(string)
    ;       inference_error(string)
    ;       parse_error(string).

:- type lexx_result(T)
    --->    ok(T)
    ;       error(lexx_error).

%-----------------------------------------------------------------------------%

:- implementation.

% No implementation needed - this is a pure type definition module

%-----------------------------------------------------------------------------%
:- end_module lexx_types.
%-----------------------------------------------------------------------------%
