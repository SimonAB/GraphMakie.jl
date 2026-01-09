# Feature Request: Automatic Label Alignment to Avoid Edge Overlaps

## Summary

Add automatic label alignment for `graphplot` that positions node labels in the largest angular gap between incident edges, preventing label-edge overlaps.

## Motivation

Currently, users must manually specify `nlabels_align` for each node, which is tedious and often results in labels overlapping with edges. This is especially problematic for nodes with many incident edges.

**Example of the problem:**
```julia
g = SimpleDiGraph(5)
add_edge!(g, 1, 2); add_edge!(g, 1, 3); add_edge!(g, 2, 4)
graphplot(g, nlabels = ["A", "B", "C", "D", "E"], nlabels_align = (:right, :bottom))
# Labels overlap with edges, hard to read
```

## Proposed API

```julia
graphplot(g, 
    nlabels = ["A", "B", "C"],
    nlabels_auto_align = true,  # New option (default: false)
    nlabels_align = (:right, :bottom)  # Fallback for isolated nodes
)
```

## Algorithm

For each node:
1. Collect angles of all incident edges (incoming + outgoing)
2. Find the largest angular gap between adjacent edges
3. Place label in the middle of that gap
4. Map to one of 8 alignment directions (East, Northeast, North, Northwest, West, Southwest, South, Southeast)

**Edge cases:**
- Isolated nodes → use `nlabels_align` default
- Single edge → place label opposite edge
- All edges in one direction → place label opposite

## Benefits

✅ Automatic label positioning  
✅ Better readability (no edge overlaps)  
✅ Works with any graph topology  
✅ Backward compatible (opt-in)

## Implementation

I have a working implementation ready to contribute:
- Core algorithm (~110 lines)
- Handles directed/undirected graphs
- Comprehensive edge case handling
- Well-documented

## Example

**Before:**
```julia
graphplot(g, nlabels = labels, nlabels_align = (:right, :bottom))
# Labels may overlap edges
```

**After:**
```julia
graphplot(g, nlabels = labels, nlabels_auto_align = true)
# Labels automatically avoid edges
```

## Questions

1. **Naming**: `nlabels_auto_align` vs `nlabels_smart_align` vs other?
2. **Default**: Opt-in (`false`) or opt-out (`true`)? → Recommend opt-in for compatibility
3. **Performance**: Any concerns for very large graphs (1000+ nodes)?

---

Ready to submit as PR with implementation, tests, and documentation.
