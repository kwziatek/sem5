#Author: Karol Wziątek
using Polynomials, Printf


#Skopiowane współczynniki wielomianu Wilkinsona
p = [1, -210.0, 20615.0,-1256850.0,
      53327946.0,-1672280820.0, 40171771630.0, -756111184500.0,          
      11310276995381.0, -135585182899530.0,
      1307535010540395.0,     -10142299865511450.0,
      63030812099294896.0,     -311333643161390640.0,
      1206647803780373360.0,     -3599979517947607200.0,
      8037811822645051776.0,      -12870931245150988800.0,
      13803759753640704000.0,      -8752948036761600000.0,
      2432902008176640000.0]

# Trzeba odwrócić
coefficients = p[end:-1:1]
      
# Wyliczanie pierwiastków wielomianiu postaci naturalnej
function calculateRoots(coefficients)
  polynomialCanonicalForm = Polynomial(coefficients)
  
  rootsComputed = roots(polynomialCanonicalForm)
  println("k | z_k | abs(z_k - k)")
  for i in 1:lastindex(rootsComputed)
      if (typeof(rootsComputed[i]) == Float64)
          @printf("%d & %.15f & %.15f\n", i, rootsComputed[i], abs(rootsComputed[i] - i))
      else 
          println(i, " & ", rootsComputed[i], " & ", abs(rootsComputed[i] - i))
      end
  end
  return rootsComputed
end

# Wyliczanie wartości dla postaci naturalnej
function printAbsValCanonical(coefficients, values)
  polynomialCanonicalForm = Polynomial(coefficients)
  for i in eachindex(values)
    @printf("|P(z_%d)| = %.15e\n", i, abs(polynomialCanonicalForm(values[i])))
  end
end

# Wyliczanie wartości dla postaci iloczynowej
function printAbsValFactored(values)
    # wielomian w postaci iloczynowej 
    polynomialFactoredForm = fromroots(collect(1:20))  
    for i in eachindex(values)
        @printf("|p(z_%d)| = %.15e\n", i, abs(polynomialFactoredForm(values[i])))
    end
end

rootsComputed = calculateRoots(coefficients)
printAbsValCanonical(coefficients, rootsComputed)
printAbsValFactored(rootsComputed)

# Zaburzenie wielomianu Wilkinsona
coefficientsNoised = copy(coefficients)
coefficientsNoised[20] = -210.0 - (1.0/(2.0^23))

println("\n\nPierwiastki zaburzonego wielomianu:")
rootsComputedNoised = calculateRoots(coefficientsNoised)
printAbsValCanonical(coefficientsNoised, rootsComputedNoised)
printAbsValFactored(rootsComputedNoised)