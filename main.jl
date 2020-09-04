using Plots
using Random

Random.seed!(1)
xs = rand(5)
ys = rand(5)

scatter(xs, ys)

points = xs + im*ys

points = [exp(im * t) for t in 0:2π/100:2π+2π/100]
points2 = [exp(2*π*im*t/100) for t in 0:1:100]

[t for t in 0:2π/10:2π]
[t*0.1 for t in 0:1:62]

scatter(points)

function interpolate(points::Vector{ComplexF64}, Δt::Float64)
    T = length(points)
    points = vcat(points, first(points))
    return [points[Int(floor(t))] + (points[Int(ceil(t))] - points[Int(floor(t))]) * (t - floor(t)) for t in 1:Δt:T+1]
end

function fourier_series(points::Vector{ComplexF64}, depth::Int, Δt::Float64=1.0)
    T = length(points)
    # interpolate
    f = interpolate(points, Δt)
    E = [exp(-2*π*im*n*t/T) for n in -depth:1:depth, t in 0:Δt:T]
    # display(E)

    # return 1/(2π) * (Δt * E*f - Δt * (f[1]*E[:,1] + f[end]*E[:,end]) / 2)
    return 1/length(f) * E * f
end

function get_fourier_func(coeffs::Vector{ComplexF64})
    # t ∈ [0, 2π]
    L = length(coeffs)
    function F(t)
        return sum(coeffs[n]*exp(im*t*(n-L÷2-1)) for n in 1:L)
    end
end

function Circle(x,y,r)
    ts = LinRange(0, 2π, 500)
    return x .+ r * cos.(ts), y .+ r * sin.(ts)
end


plot(Circle(1,1,1))

cs = fourier_series(points, 3, .0001)

F = get_fourier_func(cs)
ts = collect(0:0.001:2π)
fs = F.(ts)

scatter(points);
plot!(points);
plot!(fs, legend=false)

function plot_fourier_circles(coeffs::Vector{ComplexF64}, t::Float64=0.; circle_color=1, center_size=2)
    depth = length(coeffs) ÷ 2
    n0 = depth + 1
    ts = LinRange(0, 2π, 100)

    p = plot(legend=false, size=(600,600), aspect_ratio=:equal)

    current = coeffs[n0]
    scatter!([coeffs[n0]], mc=2, ms=center_size)


    for d in 1:depth
        n = n0 + d
        plot!(current .+ coeffs[n] * exp.(im*d*ts), lc=circle_color)
        current += coeffs[n] * exp(im*d*t)
        scatter!([current], mc=2, ms=center_size)

        n = n0 - d
        plot!(current .+ coeffs[n] * exp.(-im*d*ts), lc=circle_color)
        current += coeffs[n] * exp(-im*d*t)
        scatter!([current], mc=2, ms=center_size)
    end

    return p
end

plot_fourier_circles(cs)

function animate_fourier(coeffs::Vector{ComplexF64}, n::Int=100; fps=30, filename="fourier.gif", trace=false,
    circle_color=1, center_size=2, lw=3, lc=:black, t0=0, t1=2π, freeze_seconds=1)
    ts = vcat(LinRange(t0, t1, n), fill(t1, Int(ceil(fps + freeze_seconds))))
    F = get_fourier_func(coeffs)
    fs = F.(ts)

    anim = Animation()
    @progress for (i,t) in enumerate(ts)
        p = plot_fourier_circles(coeffs, t, circle_color=circle_color, center_size=center_size)
        if trace
            plot!(fs[1:i], lw=lw, lc=lc)
        else
            plot!(fs, lw=lw, lc=lc)
        end
        frame(anim, p)
    end
    gif(anim, pwd() * "\\" * filename, fps=fps)
end

animate_fourier(cs, 1000, fps=30)

using CSV

df = CSV.read("markus.txt")

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
