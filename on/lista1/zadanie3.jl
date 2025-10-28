function inspect_floats(start, stop; n=5)
    println("x \t nextfloat(x) - x \t bitstring(x)")
    x = start
    for i in 1:n
        x_next = nextfloat(x)
        println("$x \t $(x_next - x) \t $(bitstring(x))")
        x = x_next
        if x > stop
            break
        end
    end
end

println("Przedział [1,2]:")
inspect_floats(1.0, 2.0)

println("Przedział [1/2,1]:")
inspect_floats(0.5, 1.0)

println("Przedział [2,4]:")
inspect_floats(2.0, 4.0)
