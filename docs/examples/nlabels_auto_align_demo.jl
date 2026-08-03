# Before/after figures for MakieOrg/GraphMakie.jl#257 (`nlabels_auto_align`).
#
# From the GraphMakie.jl repo root (on `pr/nlabels-auto-align`):
#   julia --threads=auto docs/examples/nlabels_auto_align_demo.jl

using Pkg
const REPO = dirname(dirname(@__DIR__))
Pkg.activate(temp = true)
Pkg.develop(path = REPO)
Pkg.add(["CairoMakie", "Graphs", "NetworkLayout", "GeometryBasics"])

using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout
using GeometryBasics: Point2f

CairoMakie.activate!(type = "png", px_per_unit = 2)

const OUTDIR = joinpath(REPO, "docs", "src", "assets")
mkpath(OUTDIR)

function before_after!(fig, g, labels, layout; title_prefix, row)
    common = (;
        nlabels = labels,
        layout,
        node_size = 28,
        nlabels_fontsize = 16,
        nlabels_distance = 8,
        edge_width = 2,
    )
    ax1 = Axis(fig[row, 1];
               title = "$title_prefix — default (auto align off)",
               aspect = DataAspect())
    graphplot!(ax1, g; common..., nlabels_auto_align = false)
    hidedecorations!(ax1)
    hidespines!(ax1)

    ax2 = Axis(fig[row, 2];
               title = "$title_prefix — nlabels_auto_align = true",
               aspect = DataAspect())
    graphplot!(ax2, g; common..., nlabels_auto_align = true)
    hidedecorations!(ax2)
    hidespines!(ax2)
end

g_star = SimpleDiGraph(5)
for j in 2:5
    add_edge!(g_star, 1, j)
end
labels_star = ["Exposure", "Outcome", "Mediator", "Confounder", "Instrument"]
layout_star = vcat(
    [Point2f(0, 0)],
    [Point2f(2cos(θ), 2sin(θ)) for θ in range(π / 4; step = π / 2, length = 4)],
)

g_dag = SimpleDiGraph(6)
for (i, j) in ((1, 3), (1, 6), (2, 3), (2, 4), (3, 4), (3, 6), (4, 6), (5, 4), (5, 6))
    add_edge!(g_dag, i, j)
end
labels_dag = ["U₁", "U₂", "A", "M", "Z", "Y"]
layout_dag = Spring(iterations = 500, seed = 42)

fig = Figure(size = (1100, 900), fontsize = 14)
before_after!(fig, g_star, labels_star, layout_star; title_prefix = "Star digraph", row = 1)
before_after!(fig, g_dag, labels_dag, layout_dag; title_prefix = "Denser DAG", row = 2)
Label(fig[0, :], "nlabels_auto_align: before (left) vs after (right)";
      fontsize = 18, font = :bold, tellwidth = false)

out = joinpath(OUTDIR, "nlabels_auto_align_before_after.png")
save(out, fig)
println("wrote ", out)
