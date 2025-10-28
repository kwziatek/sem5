function find(T) 
    helper = T(1.0)
    while true
        helper = nextfloat(helper)
        if helper * (T(1.0) / helper) != T(1.0)
            return helper
        end
        if helper >= T(2.0)
            break
        end
    end
    return nothing
end

println(find(Float64))
