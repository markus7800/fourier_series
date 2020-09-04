using Plots
using ProgressMeter

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

    return 1/length(f) * E * f
end

function get_fourier_func(coeffs::Vector{ComplexF64})
    # t ∈ [0, 2π]
    L = length(coeffs)
    function F(t)
        return sum(coeffs[n]*exp(im*t*(n-L÷2-1)) for n in 1:L)
    end
end


function plot_fourier_circles(coeffs::Vector{ComplexF64}, t::Float64=0.; circle_color=1, center_size=2, xlims, ylims)
    depth = length(coeffs) ÷ 2
    n0 = depth + 1
    ts = LinRange(0, 2π, 100)

    p = plot(legend=false, size=(600,600), xlims=xlims, ylims=ylims, aspect_ratio=:equal, axis=nothing, border=:none, xlabel="", ylabel="")

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


function animate_fourier(coeffs::Vector{ComplexF64}, n::Int=100; fps=30, filename="fourier.gif", trace=false,
    circle_color=1, center_size=2, lw=3, lc=:black, t0=0, t1=2π, xlims, ylims)
    ts = LinRange(0, 2π, n)
    F = get_fourier_func(coeffs)
    fs = F.(ts)

    trace0 = 0
    trace1 = length(ts)
    for t in ts
        if t < t0
            trace0 += 1
        end
        if t >= t1
            trace1 -= 1
        end
    end
    trace_range = trace0:trace1

    anim = Animation()
    i = 0
    @showprogress for (i,t) in enumerate(ts)
        p = plot_fourier_circles(coeffs, t, circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims)

        if trace
            plot!(fs[trace_range], lw=lw, lc=:gray)
            plot!(fs[intersect(trace_range, 1:i)], lw=lw, lc=lc)
        else
            plot!(fs, lw=lw, lc=lc)
        end
        xlabel!("")
        ylabel!("")
        frame(anim, p)
    end
    gif(anim, pwd() * "/" * filename, fps=fps)
end
