%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% File: lexx_hypergraph.m
% Main author: [Your Name]
%
% Core hypergraph data structure and operations.
% This is the heart of the database - it stores vertices and hyperedges
% and provides basic CRUD operations.
%
%-----------------------------------------------------------------------------%

:- module lexx_hypergraph.
:- interface.

:- import_module lexx_types.
:- import_module list.
:- import_module map.
:- import_module set.
:- import_module maybe.

%-----------------------------------------------------------------------------%
%
% Hypergraph Data Structure
%

    % The main hypergraph structure
:- type hypergraph.

    % Create an empty hypergraph
:- func init = hypergraph.

%-----------------------------------------------------------------------------%
%
% Vertex Operations
%

    % Add a vertex, returns new ID and updated graph
:- pred add_vertex(type_id::in, attribute_map::in,
    vertex_id::out, hypergraph::in, hypergraph::out) is det.

    % Get a vertex by ID
:- pred get_vertex(hypergraph::in, vertex_id::in, vertex::out) is semidet.

    % Update a vertex's attributes
:- pred update_vertex_attrs(vertex_id::in, attribute_map::in,
    hypergraph::in, hypergraph::out) is semidet.

    % Remove a vertex (also removes connected hyperedges)
:- pred remove_vertex(vertex_id::in,
    hypergraph::in, hypergraph::out) is semidet.

    % Get all vertices
:- func get_all_vertices(hypergraph) = list(vertex).

    % Get vertices by type
:- pred get_vertices_by_type(hypergraph::in, type_id::in,
    list(vertex)::out) is det.

%-----------------------------------------------------------------------------%
%
% Hyperedge Operations
%

    % Add a hyperedge, returns new ID and updated graph
:- pred add_hyperedge(type_id::in, list(role_binding)::in, 
    attribute_map::in, inference_status::in,
    hyperedge_id::out, hypergraph::in, hypergraph::out) is det.

    % Get a hyperedge by ID
:- pred get_hyperedge(hypergraph::in, hyperedge_id::in, 
    hyperedge::out) is semidet.

    % Remove a hyperedge
:- pred remove_hyperedge(hyperedge_id::in,
    hypergraph::in, hypergraph::out) is semidet.

    % Get all hyperedges
:- func get_all_hyperedges(hypergraph) = list(hyperedge).

    % Get hyperedges by type
:- pred get_hyperedges_by_type(hypergraph::in, type_id::in,
    list(hyperedge)::out) is det.

    % Get hyperedges connected to a vertex
:- pred get_hyperedges_for_vertex(hypergraph::in, vertex_id::in,
    list(hyperedge)::out) is det.

    % Get hyperedges where a vertex plays a specific role
:- pred get_hyperedges_for_vertex_role(hypergraph::in, vertex_id::in,
    role_name::in, list(hyperedge)::out) is det.

%-----------------------------------------------------------------------------%
%
% Query Helpers
%

    % Check if a vertex exists
:- pred vertex_exists(hypergraph::in, vertex_id::in) is semidet.

    % Check if a hyperedge exists
:- pred hyperedge_exists(hypergraph::in, hyperedge_id::in) is semidet.

    % Count vertices
:- func vertex_count(hypergraph) = int.

    % Count hyperedges
:- func hyperedge_count(hypergraph) = int.

    % Get all inferred hyperedges
:- pred get_inferred_hyperedges(hypergraph::in, 
    list(hyperedge)::out) is det.

    % Clear all inferred data (for re-materialization)
:- pred clear_inferred(hypergraph::in, hypergraph::out) is det.

%-----------------------------------------------------------------------------%
%
% Traversal Operations
%

    % Get neighbors of a vertex (vertices connected by any hyperedge)
:- pred get_neighbors(hypergraph::in, vertex_id::in,
    list(vertex_id)::out) is det.

    % Get neighbors via a specific relation type
:- pred get_neighbors_by_relation(hypergraph::in, vertex_id::in,
    type_id::in, list(vertex_id)::out) is det.

    % Get vertices playing a specific role in edges connected to given vertex
:- pred get_role_fillers(hypergraph::in, vertex_id::in,
    type_id::in, role_name::in, list(vertex_id)::out) is det.

%-----------------------------------------------------------------------------%
:- implementation.

:- import_module int.
:- import_module string.
:- import_module solutions.
:- import_module require.

%-----------------------------------------------------------------------------%
%
% Internal Representation
%

:- type hypergraph
    --->    hypergraph(
                hg_vertices         :: map(vertex_id, vertex),
                hg_hyperedges       :: map(hyperedge_id, hyperedge),
                hg_next_vertex_id   :: vertex_id,
                hg_next_edge_id     :: hyperedge_id,
                % Indexes for efficient lookup
                hg_vertex_type_idx  :: map(type_id, set(vertex_id)),
                hg_edge_type_idx    :: map(type_id, set(hyperedge_id)),
                hg_vertex_edge_idx  :: map(vertex_id, set(hyperedge_id))
            ).

%-----------------------------------------------------------------------------%
%
% Initialization
%

init = hypergraph(
    map.init,           % vertices
    map.init,           % hyperedges
    1,                  % next vertex id
    1,                  % next edge id
    map.init,           % vertex type index
    map.init,           % edge type index
    map.init            % vertex-edge index
).

%-----------------------------------------------------------------------------%
%
% Vertex Operations Implementation
%

add_vertex(TypeId, Attrs, VId, !HG) :-
    VId = !.HG ^ hg_next_vertex_id,
    Vertex = vertex(VId, TypeId, Attrs),
    
    % Add to main vertex map
    map.det_insert(VId, Vertex, !.HG ^ hg_vertices, NewVertices),
    
    % Update type index
    TypeIdx0 = !.HG ^ hg_vertex_type_idx,
    ( if map.search(TypeIdx0, TypeId, ExistingSet) then
        NewTypeSet = set.insert(ExistingSet, VId),
        map.det_update(TypeId, NewTypeSet, TypeIdx0, TypeIdx)
    else
        map.det_insert(TypeId, set.make_singleton_set(VId), TypeIdx0, TypeIdx)
    ),
    
    % Initialize empty edge index for this vertex
    VEIdx0 = !.HG ^ hg_vertex_edge_idx,
    map.det_insert(VId, set.init, VEIdx0, VEIdx),
    
    !:HG = !.HG ^ hg_vertices := NewVertices,
    !:HG = !.HG ^ hg_next_vertex_id := VId + 1,
    !:HG = !.HG ^ hg_vertex_type_idx := TypeIdx,
    !:HG = !.HG ^ hg_vertex_edge_idx := VEIdx.

get_vertex(HG, VId, Vertex) :-
    map.search(HG ^ hg_vertices, VId, Vertex).

update_vertex_attrs(VId, NewAttrs, !HG) :-
    map.search(!.HG ^ hg_vertices, VId, OldVertex),
    NewVertex = OldVertex ^ v_attrs := NewAttrs,
    map.det_update(VId, NewVertex, !.HG ^ hg_vertices, NewVertices),
    !:HG = !.HG ^ hg_vertices := NewVertices.

remove_vertex(VId, !HG) :-
    map.search(!.HG ^ hg_vertices, VId, Vertex),
    
    % Remove from main map
    map.delete(VId, !.HG ^ hg_vertices, NewVertices),
    
    % Remove from type index
    TypeId = Vertex ^ v_type,
    TypeIdx0 = !.HG ^ hg_vertex_type_idx,
    ( if map.search(TypeIdx0, TypeId, TypeSet0) then
        TypeSet = set.delete(TypeSet0, VId),
        ( if set.is_empty(TypeSet) then
            map.delete(TypeId, TypeIdx0, TypeIdx)
        else
            map.det_update(TypeId, TypeSet, TypeIdx0, TypeIdx)
        )
    else
        TypeIdx = TypeIdx0
    ),
    
    % Remove connected hyperedges
    ( if map.search(!.HG ^ hg_vertex_edge_idx, VId, ConnectedEdges) then
        set.fold(remove_hyperedge_if_exists, ConnectedEdges, !HG)
    else
        true
    ),
    
    % Remove from vertex-edge index
    map.delete(VId, !.HG ^ hg_vertex_edge_idx, VEIdx),
    
    !:HG = !.HG ^ hg_vertices := NewVertices,
    !:HG = !.HG ^ hg_vertex_type_idx := TypeIdx,
    !:HG = !.HG ^ hg_vertex_edge_idx := VEIdx.

:- pred remove_hyperedge_if_exists(hyperedge_id::in,
    hypergraph::in, hypergraph::out) is det.

remove_hyperedge_if_exists(EId, !HG) :-
    ( if remove_hyperedge(EId, !HG) then
        true
    else
        true
    ).

get_all_vertices(HG) = map.values(HG ^ hg_vertices).

get_vertices_by_type(HG, TypeId, Vertices) :-
    TypeIdx = HG ^ hg_vertex_type_idx,
    ( if map.search(TypeIdx, TypeId, VIds) then
        VertexMap = HG ^ hg_vertices,
        Vertices = set.fold(
            (func(VId, Acc) = 
                ( if map.search(VertexMap, VId, V) then [V | Acc] else Acc )
            ),
            VIds, []
        )
    else
        Vertices = []
    ).

%-----------------------------------------------------------------------------%
%
% Hyperedge Operations Implementation
%

add_hyperedge(TypeId, Roles, Attrs, Status, EId, !HG) :-
    EId = !.HG ^ hg_next_edge_id,
    Edge = hyperedge(EId, TypeId, Roles, Attrs, Status),
    
    % Add to main edge map
    map.det_insert(EId, Edge, !.HG ^ hg_hyperedges, NewEdges),
    
    % Update type index
    EdgeTypeIdx0 = !.HG ^ hg_edge_type_idx,
    ( if map.search(EdgeTypeIdx0, TypeId, ExistingSet) then
        NewTypeSet = set.insert(ExistingSet, EId),
        map.det_update(TypeId, NewTypeSet, EdgeTypeIdx0, EdgeTypeIdx)
    else
        map.det_insert(TypeId, set.make_singleton_set(EId), 
            EdgeTypeIdx0, EdgeTypeIdx)
    ),
    
    % Update vertex-edge index for all connected vertices
    VEIdx0 = !.HG ^ hg_vertex_edge_idx,
    VEIdx = list.foldl(
        (func(role_binding(_, VId), Idx0) = Idx :-
            ( if map.search(Idx0, VId, EdgeSet0) then
                EdgeSet = set.insert(EdgeSet0, EId),
                map.det_update(VId, EdgeSet, Idx0, Idx)
            else
                Idx = Idx0  % Vertex doesn't exist - shouldn't happen
            )
        ),
        Roles, VEIdx0
    ),
    
    !:HG = !.HG ^ hg_hyperedges := NewEdges,
    !:HG = !.HG ^ hg_next_edge_id := EId + 1,
    !:HG = !.HG ^ hg_edge_type_idx := EdgeTypeIdx,
    !:HG = !.HG ^ hg_vertex_edge_idx := VEIdx.

get_hyperedge(HG, EId, Edge) :-
    map.search(HG ^ hg_hyperedges, EId, Edge).

remove_hyperedge(EId, !HG) :-
    map.search(!.HG ^ hg_hyperedges, EId, Edge),
    
    % Remove from main map
    map.delete(EId, !.HG ^ hg_hyperedges, NewEdges),
    
    % Remove from type index
    TypeId = Edge ^ he_type,
    EdgeTypeIdx0 = !.HG ^ hg_edge_type_idx,
    ( if map.search(EdgeTypeIdx0, TypeId, TypeSet0) then
        TypeSet = set.delete(TypeSet0, EId),
        ( if set.is_empty(TypeSet) then
            map.delete(TypeId, EdgeTypeIdx0, EdgeTypeIdx)
        else
            map.det_update(TypeId, TypeSet, EdgeTypeIdx0, EdgeTypeIdx)
        )
    else
        EdgeTypeIdx = EdgeTypeIdx0
    ),
    
    % Remove from vertex-edge index
    Roles = Edge ^ he_roles,
    VEIdx0 = !.HG ^ hg_vertex_edge_idx,
    VEIdx = list.foldl(
        (func(role_binding(_, VId), Idx0) = Idx :-
            ( if map.search(Idx0, VId, EdgeSet0) then
                EdgeSet = set.delete(EdgeSet0, EId),
                map.det_update(VId, EdgeSet, Idx0, Idx)
            else
                Idx = Idx0
            )
        ),
        Roles, VEIdx0
    ),
    
    !:HG = !.HG ^ hg_hyperedges := NewEdges,
    !:HG = !.HG ^ hg_edge_type_idx := EdgeTypeIdx,
    !:HG = !.HG ^ hg_vertex_edge_idx := VEIdx.

get_all_hyperedges(HG) = map.values(HG ^ hg_hyperedges).

get_hyperedges_by_type(HG, TypeId, Edges) :-
    EdgeTypeIdx = HG ^ hg_edge_type_idx,
    ( if map.search(EdgeTypeIdx, TypeId, EIds) then
        EdgeMap = HG ^ hg_hyperedges,
        Edges = set.fold(
            (func(EId, Acc) =
                ( if map.search(EdgeMap, EId, E) then [E | Acc] else Acc )
            ),
            EIds, []
        )
    else
        Edges = []
    ).

get_hyperedges_for_vertex(HG, VId, Edges) :-
    VEIdx = HG ^ hg_vertex_edge_idx,
    ( if map.search(VEIdx, VId, EIds) then
        EdgeMap = HG ^ hg_hyperedges,
        Edges = set.fold(
            (func(EId, Acc) =
                ( if map.search(EdgeMap, EId, E) then [E | Acc] else Acc )
            ),
            EIds, []
        )
    else
        Edges = []
    ).

get_hyperedges_for_vertex_role(HG, VId, RoleName, Edges) :-
    get_hyperedges_for_vertex(HG, VId, AllEdges),
    Edges = list.filter(
        (pred(E::in) is semidet :-
            list.member(role_binding(RoleName, VId), E ^ he_roles)
        ),
        AllEdges
    ).

%-----------------------------------------------------------------------------%
%
% Query Helpers Implementation
%

vertex_exists(HG, VId) :-
    map.contains(HG ^ hg_vertices, VId).

hyperedge_exists(HG, EId) :-
    map.contains(HG ^ hg_hyperedges, EId).

vertex_count(HG) = map.count(HG ^ hg_vertices).

hyperedge_count(HG) = map.count(HG ^ hg_hyperedges).

get_inferred_hyperedges(HG, InferredEdges) :-
    AllEdges = get_all_hyperedges(HG),
    InferredEdges = list.filter(
        (pred(E::in) is semidet :-
            E ^ he_status = inferred(_, _)
        ),
        AllEdges
    ).

clear_inferred(!HG) :-
    get_inferred_hyperedges(!.HG, InferredEdges),
    list.foldl(
        (pred(E::in, HG0::in, HG1::out) is det :-
            ( if remove_hyperedge(E ^ he_id, HG0, HG1Prime) then
                HG1 = HG1Prime
            else
                HG1 = HG0
            )
        ),
        InferredEdges, !HG
    ).

%-----------------------------------------------------------------------------%
%
% Traversal Operations Implementation
%

get_neighbors(HG, VId, Neighbors) :-
    get_hyperedges_for_vertex(HG, VId, Edges),
    NeighborSet = list.foldl(
        (func(E, Acc) = 
            list.foldl(
                (func(role_binding(_, V), A) =
                    ( if V = VId then A else set.insert(A, V) )
                ),
                E ^ he_roles, Acc
            )
        ),
        Edges, set.init
    ),
    Neighbors = set.to_sorted_list(NeighborSet).

get_neighbors_by_relation(HG, VId, RelTypeId, Neighbors) :-
    get_hyperedges_for_vertex(HG, VId, AllEdges),
    RelevantEdges = list.filter(
        (pred(E::in) is semidet :- E ^ he_type = RelTypeId),
        AllEdges
    ),
    NeighborSet = list.foldl(
        (func(E, Acc) =
            list.foldl(
                (func(role_binding(_, V), A) =
                    ( if V = VId then A else set.insert(A, V) )
                ),
                E ^ he_roles, Acc
            )
        ),
        RelevantEdges, set.init
    ),
    Neighbors = set.to_sorted_list(NeighborSet).

get_role_fillers(HG, VId, RelTypeId, TargetRole, Fillers) :-
    get_hyperedges_for_vertex(HG, VId, AllEdges),
    RelevantEdges = list.filter(
        (pred(E::in) is semidet :- E ^ he_type = RelTypeId),
        AllEdges
    ),
    FillerSet = list.foldl(
        (func(E, Acc) =
            list.foldl(
                (func(role_binding(R, V), A) =
                    ( if R = TargetRole, V \= VId then 
                        set.insert(A, V) 
                    else 
                        A 
                    )
                ),
                E ^ he_roles, Acc
            )
        ),
        RelevantEdges, set.init
    ),
    Fillers = set.to_sorted_list(FillerSet).

%-----------------------------------------------------------------------------%
:- end_module lexx_hypergraph.
%-----------------------------------------------------------------------------%
