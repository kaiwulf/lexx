%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% File: lexx_type_registry.m
% Main author: [Your Name]
%
% Type Registry for managing the ontology schema.
% Handles type definitions, inheritance hierarchies, and polymorphic
% type resolution (finding all subtypes of a given type).
%
% ONTOLOGY ENGINEERING CONCEPTS:
% - Types form a hierarchy (like classes in OOP)
% - Subtypes inherit properties from supertypes
% - Polymorphic queries can match any subtype
%
%-----------------------------------------------------------------------------%

:- module lexx_type_registry.
:- interface.

:- import_module lexx_types.
:- import_module list.
:- import_module map.
:- import_module set.
:- import_module maybe.

%-----------------------------------------------------------------------------%
%
% Type Registry Data Structure
%

:- type type_registry.

    % Create an empty registry with built-in root types
:- func init = type_registry.

%-----------------------------------------------------------------------------%
%
% Type Definition Operations
%

    % Register a new type
:- pred register_type(type_def::in, lexx_result(unit)::out,
    type_registry::in, type_registry::out) is det.

    % Get a type definition
:- pred get_type(type_registry::in, type_id::in, type_def::out) is semidet.

    % Check if a type exists
:- pred type_exists(type_registry::in, type_id::in) is semidet.

    % Remove a type (fails if has subtypes)
:- pred remove_type(type_id::in, lexx_result(unit)::out,
    type_registry::in, type_registry::out) is det.

%-----------------------------------------------------------------------------%
%
% Hierarchy Operations
%

    % Get the parent type (if any)
:- pred get_parent(type_registry::in, type_id::in, 
    maybe(type_id)::out) is semidet.

    % Get direct subtypes
:- pred get_direct_subtypes(type_registry::in, type_id::in,
    set(type_id)::out) is det.

    % Get ALL subtypes (transitive closure)
:- pred get_all_subtypes(type_registry::in, type_id::in,
    set(type_id)::out) is det.

    % Get all supertypes (ancestors)
:- pred get_all_supertypes(type_registry::in, type_id::in,
    list(type_id)::out) is det.

    % Check if TypeA is a subtype of TypeB (including TypeA = TypeB)
:- pred is_subtype_of(type_registry::in, type_id::in, type_id::in) is semidet.

%-----------------------------------------------------------------------------%
%
% Polymorphic Type Resolution
%

    % Resolve a type constraint to concrete types
:- pred resolve_type_constraint(type_registry::in, type_constraint::in,
    set(type_id)::out) is det.

    % Get types that can play a given role in a relation
:- pred get_types_for_role(type_registry::in, type_id::in, role_name::in,
    set(type_id)::out) is det.

%-----------------------------------------------------------------------------%
%
% Attribute and Role Inheritance
%

    % Get all attributes for a type (including inherited)
:- pred get_all_attributes(type_registry::in, type_id::in,
    list(attr_spec)::out) is det.

    % Get all roles a type can play (including inherited)
:- pred get_all_playable_roles(type_registry::in, type_id::in,
    list(role_spec)::out) is det.

    % Check if a type can own an attribute
:- pred can_own_attribute(type_registry::in, type_id::in, 
    attr_name::in) is semidet.

    % Check if a type can play a role
:- pred can_play_role(type_registry::in, type_id::in,
    type_id::in, role_name::in) is semidet.

%-----------------------------------------------------------------------------%
%
% Listing Operations
%

    % Get all entity types
:- func get_all_entity_types(type_registry) = list(type_def).

    % Get all relation types
:- func get_all_relation_types(type_registry) = list(type_def).

    % Get all attribute types
:- func get_all_attribute_types(type_registry) = list(type_def).

%-----------------------------------------------------------------------------%
:- implementation.

:- import_module int.
:- import_module string.
:- import_module solutions.
:- import_module require.
:- import_module unit.

%-----------------------------------------------------------------------------%
%
% Internal Representation
%

:- type type_registry
    --->    type_registry(
                % Main type storage
                tr_types            :: map(type_id, type_def),
                % Parent -> Children index (for finding subtypes)
                tr_children_idx     :: map(type_id, set(type_id)),
                % Role lookup: (relation_type, role_name) -> allowed types
                tr_role_types_idx   :: map({type_id, role_name}, set(type_id))
            ).

%-----------------------------------------------------------------------------%
%
% Built-in Root Types
%

    % Root types that all others inherit from
:- func root_entity_type = type_def.
:- func root_relation_type = type_def.
:- func root_attribute_type = type_def.

root_entity_type = entity_type("entity", no, [], []).
root_relation_type = relation_type("relation", no, [], []).
root_attribute_type = attribute_type("attribute", no, vt_string).

%-----------------------------------------------------------------------------%
%
% Initialization
%

init = Registry :-
    Types0 = map.init,
    map.det_insert("entity", root_entity_type, Types0, Types1),
    map.det_insert("relation", root_relation_type, Types1, Types2),
    map.det_insert("attribute", root_attribute_type, Types2, Types),
    Registry = type_registry(Types, map.init, map.init).

%-----------------------------------------------------------------------------%
%
% Type Definition Operations Implementation
%

register_type(TypeDef, Result, !Registry) :-
    TypeId = get_type_id(TypeDef),
    
    % Check if type already exists
    ( if type_exists(!.Registry, TypeId) then
        Result = error(type_error("Type already exists: " ++ TypeId))
    else
        % Check parent exists (if specified)
        MaybeParent = get_parent_id(TypeDef),
        ( if 
            MaybeParent = yes(ParentId),
            not type_exists(!.Registry, ParentId)
        then
            Result = error(type_error("Parent type not found: " ++ ParentId))
        else
            % Add to main types map
            map.det_insert(TypeId, TypeDef, 
                !.Registry ^ tr_types, NewTypes),
            
            % Update children index
            ChildIdx0 = !.Registry ^ tr_children_idx,
            ChildIdx = (
                MaybeParent = yes(PId) ->
                    ( if map.search(ChildIdx0, PId, ExistingChildren) then
                        map.det_update(PId, 
                            set.insert(ExistingChildren, TypeId),
                            ChildIdx0)
                    else
                        map.det_insert(PId, 
                            set.make_singleton_set(TypeId), 
                            ChildIdx0)
                    )
                ;
                    ChildIdx0
            ),
            
            % Update role types index for relation types
            RoleIdx0 = !.Registry ^ tr_role_types_idx,
            RoleIdx = update_role_index(TypeDef, RoleIdx0),
            
            !:Registry = type_registry(NewTypes, ChildIdx, RoleIdx),
            Result = ok(unit)
        )
    ).

:- func update_role_index(type_def, 
    map({type_id, role_name}, set(type_id))) = 
    map({type_id, role_name}, set(type_id)).

update_role_index(TypeDef, !.Idx) = !:Idx :-
    (
        TypeDef = relation_type(RelId, _, RoleDefs, _),
        list.foldl(
            (pred(role_def(RName, AllowedTypes)::in, 
                  I0::in, I1::out) is det :-
                Key = {RelId, RName},
                ( if map.search(I0, Key, Existing) then
                    map.det_update(Key, 
                        set.union(Existing, AllowedTypes), I0, I1)
                else
                    map.det_insert(Key, AllowedTypes, I0, I1)
                )
            ),
            RoleDefs, !Idx
        )
    ;
        ( TypeDef = entity_type(_, _, _, _)
        ; TypeDef = attribute_type(_, _, _)
        )
    ).

get_type(Registry, TypeId, TypeDef) :-
    map.search(Registry ^ tr_types, TypeId, TypeDef).

type_exists(Registry, TypeId) :-
    map.contains(Registry ^ tr_types, TypeId).

remove_type(TypeId, Result, !Registry) :-
    % Check if type has subtypes
    get_direct_subtypes(!.Registry, TypeId, Subtypes),
    ( if set.is_empty(Subtypes) then
        ( if map.search(!.Registry ^ tr_types, TypeId, TypeDef) then
            % Remove from types map
            map.delete(TypeId, !.Registry ^ tr_types, NewTypes),
            
            % Remove from parent's children index
            MaybeParent = get_parent_id(TypeDef),
            ChildIdx0 = !.Registry ^ tr_children_idx,
            ChildIdx = (
                MaybeParent = yes(PId) ->
                    ( if map.search(ChildIdx0, PId, Children) then
                        NewChildren = set.delete(Children, TypeId),
                        ( if set.is_empty(NewChildren) then
                            map.delete(PId, ChildIdx0)
                        else
                            map.det_update(PId, NewChildren, ChildIdx0)
                        )
                    else
                        ChildIdx0
                    )
                ;
                    ChildIdx0
            ),
            
            !:Registry = !.Registry ^ tr_types := NewTypes,
            !:Registry = !.Registry ^ tr_children_idx := ChildIdx,
            Result = ok(unit)
        else
            Result = error(not_found_error("Type not found: " ++ TypeId))
        )
    else
        Result = error(type_error("Cannot remove type with subtypes: " ++ TypeId))
    ).

%-----------------------------------------------------------------------------%
%
% Helper Functions
%

:- func get_type_id(type_def) = type_id.

get_type_id(entity_type(Id, _, _, _)) = Id.
get_type_id(relation_type(Id, _, _, _)) = Id.
get_type_id(attribute_type(Id, _, _)) = Id.

:- func get_parent_id(type_def) = maybe(type_id).

get_parent_id(entity_type(_, Parent, _, _)) = Parent.
get_parent_id(relation_type(_, Parent, _, _)) = Parent.
get_parent_id(attribute_type(_, Parent, _)) = Parent.

%-----------------------------------------------------------------------------%
%
% Hierarchy Operations Implementation
%

get_parent(Registry, TypeId, MaybeParent) :-
    get_type(Registry, TypeId, TypeDef),
    MaybeParent = get_parent_id(TypeDef).

get_direct_subtypes(Registry, TypeId, Subtypes) :-
    ( if map.search(Registry ^ tr_children_idx, TypeId, Children) then
        Subtypes = Children
    else
        Subtypes = set.init
    ).

get_all_subtypes(Registry, TypeId, AllSubtypes) :-
    get_direct_subtypes(Registry, TypeId, DirectSubtypes),
    AllSubtypes = set.fold(
        (func(Child, Acc) = NewAcc :-
            get_all_subtypes(Registry, Child, ChildSubtypes),
            NewAcc = set.union(set.insert(Acc, Child), ChildSubtypes)
        ),
        DirectSubtypes, set.init
    ).

get_all_supertypes(Registry, TypeId, Supertypes) :-
    ( if get_parent(Registry, TypeId, yes(ParentId)) then
        get_all_supertypes(Registry, ParentId, ParentSupertypes),
        Supertypes = [ParentId | ParentSupertypes]
    else
        Supertypes = []
    ).

is_subtype_of(Registry, TypeA, TypeB) :-
    ( TypeA = TypeB
    ; 
        get_all_supertypes(Registry, TypeA, Supertypes),
        list.member(TypeB, Supertypes)
    ).

%-----------------------------------------------------------------------------%
%
% Polymorphic Type Resolution Implementation
%

resolve_type_constraint(Registry, Constraint, ResolvedTypes) :-
    (
        Constraint = tc_exact(TypeId),
        ( if type_exists(Registry, TypeId) then
            ResolvedTypes = set.make_singleton_set(TypeId)
        else
            ResolvedTypes = set.init
        )
    ;
        Constraint = tc_subtype(TypeId),
        ( if type_exists(Registry, TypeId) then
            get_all_subtypes(Registry, TypeId, Subtypes),
            ResolvedTypes = set.insert(Subtypes, TypeId)
        else
            ResolvedTypes = set.init
        )
    ;
        Constraint = tc_any,
        % Return all types - probably want to filter by category
        ResolvedTypes = set.from_list(map.keys(Registry ^ tr_types))
    ).

get_types_for_role(Registry, RelationTypeId, RoleName, AllowedTypes) :-
    Key = {RelationTypeId, RoleName},
    ( if map.search(Registry ^ tr_role_types_idx, Key, Types) then
        % Expand to include all subtypes
        AllowedTypes = set.fold(
            (func(T, Acc) = NewAcc :-
                get_all_subtypes(Registry, T, Subtypes),
                NewAcc = set.union(set.insert(Acc, T), Subtypes)
            ),
            Types, set.init
        )
    else
        AllowedTypes = set.init
    ).

%-----------------------------------------------------------------------------%
%
% Attribute and Role Inheritance Implementation
%

get_all_attributes(Registry, TypeId, AllAttrs) :-
    ( if get_type(Registry, TypeId, TypeDef) then
        OwnAttrs = get_own_attributes(TypeDef),
        MaybeParent = get_parent_id(TypeDef),
        ( MaybeParent = yes(ParentId) ->
            get_all_attributes(Registry, ParentId, ParentAttrs),
            AllAttrs = OwnAttrs ++ ParentAttrs
        ;
            AllAttrs = OwnAttrs
        )
    else
        AllAttrs = []
    ).

:- func get_own_attributes(type_def) = list(attr_spec).

get_own_attributes(entity_type(_, _, Attrs, _)) = Attrs.
get_own_attributes(relation_type(_, _, _, Attrs)) = Attrs.
get_own_attributes(attribute_type(_, _, _)) = [].

get_all_playable_roles(Registry, TypeId, AllRoles) :-
    ( if get_type(Registry, TypeId, TypeDef) then
        OwnRoles = get_own_roles(TypeDef),
        MaybeParent = get_parent_id(TypeDef),
        ( MaybeParent = yes(ParentId) ->
            get_all_playable_roles(Registry, ParentId, ParentRoles),
            AllRoles = OwnRoles ++ ParentRoles
        ;
            AllRoles = OwnRoles
        )
    else
        AllRoles = []
    ).

:- func get_own_roles(type_def) = list(role_spec).

get_own_roles(entity_type(_, _, _, Roles)) = Roles.
get_own_roles(relation_type(_, _, _, _)) = [].
get_own_roles(attribute_type(_, _, _)) = [].

can_own_attribute(Registry, TypeId, AttrName) :-
    get_all_attributes(Registry, TypeId, AllAttrs),
    list.member(attr_spec(AttrName, _, _, _), AllAttrs).

can_play_role(Registry, TypeId, RelationTypeId, RoleName) :-
    get_types_for_role(Registry, RelationTypeId, RoleName, AllowedTypes),
    set.member(TypeId, AllowedTypes).

%-----------------------------------------------------------------------------%
%
% Listing Operations Implementation
%

get_all_entity_types(Registry) = 
    list.filter(is_entity_type, map.values(Registry ^ tr_types)).

get_all_relation_types(Registry) =
    list.filter(is_relation_type, map.values(Registry ^ tr_types)).

get_all_attribute_types(Registry) =
    list.filter(is_attribute_type, map.values(Registry ^ tr_types)).

:- pred is_entity_type(type_def::in) is semidet.
is_entity_type(entity_type(_, _, _, _)).

:- pred is_relation_type(type_def::in) is semidet.
is_relation_type(relation_type(_, _, _, _)).

:- pred is_attribute_type(type_def::in) is semidet.
is_attribute_type(attribute_type(_, _, _)).

%-----------------------------------------------------------------------------%
:- end_module lexx_type_registry.
%-----------------------------------------------------------------------------%
