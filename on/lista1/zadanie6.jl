f(x) = sqrt(x^2 + 1) - 1
g(x) = x^2 / (sqrt(x^2 + 1) + 1)

# Following values x = 8^-1, 8^-2, 8^-3, ...
xs = [8.0^-k for k in 1:20]  # 10 values


println(" x \t f(x) \t\t g(x)")
for x in xs
    println("$x \t $(f(x)) \t $(g(x))")
end

