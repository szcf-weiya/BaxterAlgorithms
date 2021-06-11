using MATLAB
include("../Cell-Video/utils/data.jl")
include("../Cell-Video/utils/measure.jl")
using .Data

function run_KTHSE(; σ::Float64 = 1.0)
    X, M = gen_zoomed_data(15*4, 10, σ=1, zoom=2)
    mX = mxarray(Array{Matrix{Float64}, 1}([hcat(x...)' for x in X]))
    path = mat"RunWithoutImages($mX, $σ)"
    return acc2fβ(calc_path_accuracy_point(path, M, length.(X)))
end

function run_KTHSE(X, M; σ::Float64 = 1.0, fβ = true)
    mX = mxarray(Array{Matrix{Float64}, 1}([hcat(x...)' for x in X]))
    path = mat"RunWithoutImages($mX, $σ)"

    if size(path, 2) == 1
        # convert Array{, 1} to Array{, 2}
        if fβ
            return acc2fβ(calc_path_accuracy_point(reshape(path, :, 1), M, length.(X)))
        else
            return calc_path_accuracy_point(reshape(path, :, 1), M, length.(X))
        end
    elseif size(path, 2) == 0
        # no cell
        if fβ
            return acc2fβ(calc_path_accuracy_point(-ones(size(path, 1), 1), M, length.(X)))
        else
            return calc_path_accuracy_point(-ones(size(path, 1), 1), M, length.(X))
        end
    else
        if fβ
            return acc2fβ(calc_path_accuracy_point(path, M, length.(X)))
        else
            return calc_path_accuracy_point(path, M, length.(X))
        end
    end
end

function cum_run_KTHSE(X, M; σ::Float64 = 1.0)
    f = length(X)
    acc = ones(f)
    for t = 2:f
        mX = mxarray(Array{Matrix{Float64}, 1}([hcat(x...)' for x in X[1:t]]))
        path = mat"RunWithoutImages($mX, $σ)"    
        if size(path, 2) == 1
            acc[t] = acc2fβ(calc_path_accuracy(reshape(path, :, 1), M[1:t-1], length.(X[1:t]))...)
        elseif size(path, 2) == 0
            acc[t] = acc2fβ(calc_path_accuracy(-ones(size(path, 1), 1), M[1:t-1], length.(X[1:t]))...)
        else
            acc[t] = acc2fβ(calc_path_accuracy(path, M[1:t-1], length.(X[1:t]))...)
        end
    end
    return acc
end