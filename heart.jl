using Random
include("fourier.jl")

ts = LinRange(0, 2 * pi, 500)

# depth = 15 ok
heart_xs = [16 * sin(t)^3 for t in ts]
heart_ys = [12 * cos(t) - 5*cos(2*t) - 2*cos(3*t)-cos(4*t) for t in ts]

scatter(heart_xs, heart_ys, aspect_ratio=:equal)

begin
    flip = true
    df = CSV.read("input/markus.txt", DataFrame)
    # depth = 35 ok
    markus_xs = df[!, "x"] / 17 .- 10
    markus_ys = -df[!, "y"] / 17 .+ 14 .- (flip ? 4.5 : 0.)

    df = CSV.read("input/caroline.csv", DataFrame)
    caroline_xs = df[!, "x"] / 17 .- 10
    caroline_ys = -df[!, "y"] / 17 .+ 7 .+ (flip ? 5.8 : 0.)


    scatter(heart_xs, heart_ys, aspect_ratio=:equal);
    scatter!(markus_xs, markus_ys, aspect_ratio=:equal);
    scatter!(caroline_xs, caroline_ys, aspect_ratio=:equal)
end




points = markus_xs .+ im .* markus_ys
coeffs = fourier_series(points, 150, 0.01)
markus_coeffs = coeffs

points = caroline_xs .+ im .* caroline_ys
coeffs = fourier_series(points, 150, 0.01)
caroline_coeffs = coeffs

points = heart_xs .+ im .* heart_ys
coeffs = fourier_series(points, 15, 0.01)
heart_coeffs = coeffs

using Statistics
moving_average(vs,n) = [sum(@view vs[i:(i+n-1)])/n for i in 1:(length(vs)-(n-1))]
moving_average2(vs,n) = [mean(@view vs[max(1,i):min(length(vs),(i+n-1))]) for i in 1:length(vs)]


begin
    depth = 150 # = number of circles / 2

    coeffs = fourier_series(points, depth, 0.01)

    F = get_fourier_func(coeffs)

    ts = LinRange(0,2π-0.1, 900)
    fs = F.(ts)

    fs = moving_average2(fs, 10)

    plot(fs)
end



function plot_fourier_circles(coeffs::Vector{ComplexF64}, t::Float64=0.; circle_color=1, center_size=2, xlims, ylims, p=nothing, alpha=1)
    depth = length(coeffs) ÷ 2
    n0 = depth + 1
    ts = LinRange(0, 2π, 100)

    if isnothing(p)
        p = plot(legend=false, size=(600,600), xlims=xlims, ylims=ylims, aspect_ratio=:equal, axis=nothing, border=:none, xlabel="", ylabel="")
    end

    current = coeffs[n0]
    scatter!([coeffs[n0]], mc=2, ms=center_size, alpha=alpha)


    for d in 1:depth
        n = n0 + d
        plot!(current .+ coeffs[n] * exp.(im*d*ts), lc=circle_color, alpha=alpha)
        current += coeffs[n] * exp(im*d*t)
        if d < 5
            scatter!([current], mc=2, ms=center_size, alpha=alpha)
        end

        n = n0 - d
        plot!(current .+ coeffs[n] * exp.(-im*d*ts), lc=circle_color, alpha=alpha)
        current += coeffs[n] * exp(-im*d*t)
        if d < 5
            scatter!([current], mc=2, ms=center_size, alpha=alpha)
        end
    end

    return p
end

function animate_fourier_heart(
    markus_coeffs::Vector{ComplexF64}, caroline_coeffs::Vector{ComplexF64}, heart_coeffs::Vector{ComplexF64},
    n::Int=100; trace=false,
    circle_color=1, center_size=2, lw=3, lc=:black, xlims, ylims)
    ts = LinRange(0, 2π, n)

    # markus_fs = get_fourier_func(markus_coeffs).(ts)
    # caroline_fs = get_fourier_func(caroline_coeffs).(ts)
    # heart_fs = get_fourier_func(heart_coeffs).(ts)
    #
    # markus_trace_range = sum(ts .<= 0.1):sum(ts .< 2π-0.1)
    # caroline_trace_range = sum(ts .<= 0.1):sum(ts .< 2π-0.1)

    markus_fs = moving_average2(get_fourier_func(markus_coeffs).(ts), 10)
    caroline_fs = moving_average2(get_fourier_func(caroline_coeffs).(ts), 10)
    heart_fs = get_fourier_func(heart_coeffs).(ts)
    #ts = moving_average(ts, 10)

    markus_trace_range = sum(ts .<= 0):sum(ts .< 2π-0.1)
    caroline_trace_range = sum(ts .<= 0):sum(ts .< 2π-0.1)
    moving_average(fs, 10)

    anim = Animation()
    i = 0
    L = length(ts)
    @showprogress for (i,t) in enumerate(ts)
        a = min(i / 15, 1)
        p = plot_fourier_circles(markus_coeffs, -t, circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims, alpha=a)
        p = plot_fourier_circles(caroline_coeffs, t, circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims, p=p, alpha=a)
        p = plot_fourier_circles(heart_coeffs, t, circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims, p=p, alpha=a)

        #plot!(markus_fs[markus_trace_range], lw=lw, lc=:gray)
        plot!(markus_fs[intersect(markus_trace_range, (L-i+1):L)], lw=lw, lc=lc)

        #plot!(caroline_fs[caroline_trace_range], lw=lw, lc=:gray)
        plot!(caroline_fs[intersect(caroline_trace_range, 1:i)], lw=lw, lc=lc)

        #plot!(heart_fs, lw=lw, lc=:gray)
        plot!(heart_fs[1:i], lw=lw, lc=:red)

        xlabel!("")
        ylabel!("")
        frame(anim, p)
    end

    @showprogress for i in 1:150
        a = max(1 - i / 15, 0)
        p = plot_fourier_circles(markus_coeffs, ts[end], circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims, alpha=a)
        p = plot_fourier_circles(caroline_coeffs, ts[end], circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims, p=p, alpha=a)
        p = plot_fourier_circles(heart_coeffs, ts[end], circle_color=circle_color, center_size=center_size, xlims=xlims, ylims=ylims, p=p, alpha=a)

        #plot!(markus_fs[markus_trace_range], lw=lw, lc=:gray)
        plot!(markus_fs[markus_trace_range], lw=lw, lc=lc)

        #plot!(caroline_fs[caroline_trace_range], lw=lw, lc=:gray)
        plot!(caroline_fs[caroline_trace_range], lw=lw, lc=lc)

        #plot!(heart_fs, lw=lw, lc=:gray)
        plot!(heart_fs, lw=lw, lc=:red)


        xlabel!("")
        ylabel!("")
        frame(anim, p)
    end
    return anim
end


#n = 450
n = 900
anim = animate_fourier_heart(markus_coeffs, caroline_coeffs, heart_coeffs, n,
    lw=4, xlims=(-20, 20), ylims=(-22, 15))

gif(anim, "tmp.gif", fps=30)


mp4(anim, "tmp.mp4", fps=30)
