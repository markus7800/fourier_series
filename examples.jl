include("fourier.jl")
using Random

using CSV

df = CSV.read("input/markus.txt")

markus_points = Float64.(df[!, "x"]) .- im * df[!, "y"]

scatter(markus_points)
plot(markus_points, lw=5)

markus_cs = fourier_series(markus_points, 100, 0.001)

markus_F = get_fourier_func(markus_cs)
ts = collect(0.15:0.001:2π-0.15)
markus_fs = markus_F.(ts)
plot(markus_fs)

scatter(markus_points);
plot!(markus_points);
plot!(markus_fs, legend=false)

animate_fourier(markus_cs, 1000, fps=30, trace=true, t0=0.15, t1=2π-0.15, filename="markus_2.gif", lw=8)
