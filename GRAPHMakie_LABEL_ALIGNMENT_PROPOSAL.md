# Proposal: Automatic Label Alignment for GraphMakie

## Problem Statement

Currently, `graphplot` requires users to manually specify `nlabels_align` for each node, which can be tedious and often results in labels overlapping with edges. For graphs with many nodes or complex topologies, finding optimal label positions manually is impractical.

**Current behavior:**
```julia
graphplot(g, nlabels = ["A", "B", "C"], nlabels_align = (:right, :bottom))  # Same for all nodes
# or
graphplot(g, nlabels = ["A", "B", "C"], nlabels_align = [(:right, :bottom), (:left, :top), ...])  # Manual per-node
```

**Problem:** Labels often overlap with edges, making graphs hard to read, especially for nodes with many incident edges.

## Proposed Solution

Add an `nlabels_auto_align` option that automatically computes optimal label positions by finding the largest angular gap between incident edges for each node.

### API Design

```julia
graphplot(g, 
    nlabels = ["A", "B", "C"],
    nlabels_auto_align = true,  # New option (default: false for backward compatibility)
    nlabels_align = (:right, :bottom)  # Fallback when auto_align is false or for isolated nodes
)
```

**Behavior:**
- When `nlabels_auto_align = true` and `nlabels` is provided:
  - Automatically computes per-node alignments based on edge geometry
  - Overrides any user-provided `nlabels_align` (or uses it as fallback for isolated nodes)
- When `nlabels_auto_align = false` (default):
  - Uses existing behavior with `nlabels_align`
- For isolated nodes (no incident edges):
  - Falls back to `nlabels_align` default

### Algorithm

For each node:
1. Collect angles of all incident edges (both incoming and outgoing)
2. Normalize angles to [0, 2π] and sort
3. Find the largest angular gap between adjacent edges (including wrap-around)
4. Place label in the middle of the largest gap
5. Map the gap midpoint angle to one of 8 alignment directions:
   - East, Northeast, North, Northwest, West, Southwest, South, Southeast

**Edge cases:**
- Isolated nodes (no edges): Use default `nlabels_align`
- Single edge: Place label opposite the edge
- All edges in one direction: Place label in the opposite direction

### Example Usage

**Before (manual alignment):**
```julia
using Graphs, GraphMakie, CairoMakie

g = SimpleDiGraph(5)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 2, 4)
add_edge!(g, 3, 4)
add_edge!(g, 4, 5)

# Labels may overlap with edges
graphplot(g, nlabels = ["A", "B", "C", "D", "E"], nlabels_align = (:right, :bottom))
```

**After (automatic alignment):**
```julia
# Labels automatically positioned to avoid edge overlaps
graphplot(g, nlabels = ["A", "B", "C", "D", "E"], nlabels_auto_align = true)
```

### Implementation Details

**New function to add:**
```julia
function compute_auto_label_aligns(g::AbstractGraph, node_positions::AbstractVector)
    # Returns Vector{Tuple{Symbol, Symbol}} of alignments
    # Implementation details below...
end
```

**Integration point:**
In `graphplot!`, when `nlabels_auto_align = true`:
```julia
if nlabels_auto_align && nlabels !== nothing
    node_positions = layout isa AbstractVector ? layout : layout(g)
    nlabels_align = compute_auto_label_aligns(g, node_positions)
end
```

**Key implementation considerations:**
1. Works with any layout algorithm (uses computed node positions)
2. Handles both directed and undirected graphs
3. Accounts for both incoming and outgoing edges
4. Handles edge cases (isolated nodes, single edge, etc.)
5. Maintains backward compatibility (opt-in feature)

### Benefits

1. **Better readability**: Labels avoid overlapping with edges automatically
2. **Less manual work**: No need to manually specify alignments for each node
3. **Adaptive**: Works with any graph topology and layout algorithm
4. **Backward compatible**: Opt-in feature, existing code unaffected

### Testing Considerations

**Test cases:**
1. Simple chain graph (A → B → C)
2. Fork pattern (A ← B → C)
3. Collider pattern (A → B ← C)
4. Dense graph (many edges per node)
5. Sparse graph (few edges)
6. Isolated nodes (no edges)
7. Single edge per node
8. Undirected graphs
9. Large graphs (performance)
10. Edge case: all edges in same direction

**Visual regression tests:**
- Compare before/after for various graph topologies
- Ensure labels don't overlap with edges
- Verify labels are readable

### Open Questions

1. **Naming**: Is `nlabels_auto_align` the best name? Alternatives:
   - `nlabels_smart_align`
   - `nlabels_avoid_edges`
   - `auto_nlabels_align`

2. **Default behavior**: Should this be opt-in (default `false`) or opt-out (default `true`)?
   - Recommendation: Opt-in (`false` by default) for backward compatibility

3. **Performance**: For very large graphs (1000+ nodes), should there be a threshold?
   - The algorithm is O(E + V log V) per node, which should scale well
   - Could add a warning or automatic fallback for very large graphs

4. **Customization**: Should users be able to provide a fallback alignment for isolated nodes?
   - Current proposal: Uses `nlabels_align` as fallback

### Implementation Plan

1. **Phase 1**: Add `compute_auto_label_aligns` function
   - Implement core algorithm
   - Add comprehensive tests
   - Document edge cases

2. **Phase 2**: Integrate into `graphplot!`
   - Add `nlabels_auto_align` parameter
   - Update documentation
   - Add examples

3. **Phase 3**: Polish and optimization
   - Performance testing on large graphs
   - Visual regression tests
   - User feedback and refinement

### Code Contribution

I have a working implementation that:
- Handles all edge cases
- Works with directed and undirected graphs
- Is well-documented
- Has been tested in production use

I'm happy to contribute this as a PR with:
- Implementation code
- Comprehensive tests
- Documentation updates
- Example notebooks

### References

- Current implementation: [link to our code]
- Related issues: [if any exist in GraphMakie]
- Similar features in other libraries: NetworkX, D3.js, Cytoscape

---

**Status**: Ready for review and discussion
