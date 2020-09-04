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

cs = fourier_series(points, 25, .0001)

F = get_fourier_func(cs)
ts = collect(0:0.001:2π)
fs = F.(ts)

scatter(points);
plot!(points);
plot!(fs)

plot(fs)
plot(points)

scatter(points)
plot!(points)
scatter!(interpolate(points, 0.1))
plot!(fs)

T = length(points)
Δt = 0.1

T2 = length(1:Δt:T)
println([2*π*t/T for t in 0:Δt:T])

2*π*Δt/T


Δt = 1.
f = interpolate(points, Δt)
plot(f)
T = length(points)
E = [exp(-2*π*im*t/(T-1)) for t in 0:Δt:T]
plot(E)

plot(real.(E))
plot!(imag.(E))

1/2π * Δt * E'f

1/2π * 2π/100 * points'points2

plot(real.(f))
plot!(real.(E))

plot(real.(f.*E))

1/length(f) * E'f - 1/length(f)*(f[1]*E[1]+f[end]*E[end])/2
