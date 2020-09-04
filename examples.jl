
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



cs = fourier_series(points, 3, .0001)

F = get_fourier_func(cs)
ts = collect(0:0.001:2π)
fs = F.(ts)

scatter(points);
plot!(points);
plot!(fs, legend=false)


plot_fourier_circles(cs)

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
