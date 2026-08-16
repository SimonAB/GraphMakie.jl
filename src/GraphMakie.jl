module GraphMakie

using NetworkLayout
using Graphs
using Makie
using Makie: add_input!, add_constant!
using LinearAlgebra
using SimpleTraits

import Makie: DocThemer, ATTRIBUTES, project, automatic
import DataStructures: DefaultDict, DefaultOrderedDict

# Import Pointf explicitly to silence Julia 1.12's
# deprecation warning about extending its constructor
# (triggered by Point{N,Float32} helpers in utils.jl).
import GeometryBasics: Pointf

include("beziercurves.jl")
include("recipes.jl")
include("interaction.jl")
include("utils.jl")

end
