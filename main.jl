using Random
include("fourier.jl")
using CSV
using DataFrames

println("Filepath of csv of curve points:")
filename = input()

df = CSV.read(filename, DataFrame)
points = Float64.(df[!, "x"]) .- im * df[!, "y"]

depth = 15

coeffs = fourier_series(points, depth, 0.01)

F = get_fourier_func(coeffs)

ts = LinRange(0.15,2π-0.1, 900)
fs = F.(ts)
plot(fs)

scatter(points);
plot!(points);
plot!(fs, legend=false)

animate_fourier(coeffs, 450, fps=30, trace=true, t0=0.15, t1=2π-0.1, filename="fourier_temp.gif",
    lw=4, xlims=(-50, 400), ylims=(-300, -25))
