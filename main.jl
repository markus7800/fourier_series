using Random
include("fourier.jl")
using CSV
using DataFrames

filename = "input/hello.csv"

df = CSV.read(filename, DataFrame)
points = Float64.(df[!, "x"]) .- im * df[!, "y"]

depth = 15 # = number of circles / 2

coeffs = fourier_series(points, depth, 0.01)
CSV.write("hello_fourier15.csv", DataFrame(x=real.(coeffs), y=imag.(coeffs)))


plot_fourier_circles(coeffs, 1., xlims=(-50, 400), ylims=(-300, -25))

F = get_fourier_func(coeffs)

ts = LinRange(0.15,2π-0.1, 900)
fs = F.(ts)
plot(fs)

scatter(points);
plot!(points);
plot!(fs, legend=false)

anim = animate_fourier(coeffs, 450, fps=30, trace=true, t0=0.15, t1=2π-0.1,
    lw=4, xlims=(-50, 400), ylims=(-300, -25))

gif(anim, "hello.gif", fps=30)
