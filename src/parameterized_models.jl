# Reference/Adapted from:
# https://www.mortality.org/Public/HMD_4th_Symposium/Pascariu_poster.pdf
# https://github.com/mpascariu/MortalityLaws/blob/master/R/MortalityLaw_models.R

abstract type ParametricMortality end
"""
    Makeham(;a,b,c)

Construct a mortality model following Makeham's law.

Default args:
    
    a = 0.0002
    b = 0.13
    c = 0.001

"""
Base.@kwdef struct Makeham <: ParametricMortality
    a = 0.0002
    b = 0.13
    c = 0.001
end


hazard(m::Makeham,age) = m.a*exp(m.b*age) + m.c
cumhazard(m::Makeham,age) = m.a / m.b * (exp(m.b*age) - 1) + age * m.c
survivorship(m::Makeham,age) = exp(-cumhazard(m,age))


"""
    Gompertz(a,b)

Construct a mortality model following Gompertz' law of mortality.

This is a special case of Makeham's law and will `Makeham` model where `c=0`.

Default args:

    a = 0.0002
    b = 0.13

"""
function Gompertz(;a=0.0002, b=0.13) 
    return Makeham(a=a, b=b, c=0)
end

"""
    InverseGompertz(;a,b,c)

Construct a mortality model following InverseGompertz's law.

Default args:
    
    m = 49
    σ = 7.7

"""
Base.@kwdef struct InverseGompertz <: ParametricMortality
    m = 49
    σ = 7.7
end


hazard(m::InverseGompertz,age) = 1 / m.σ * exp(-(age - m.m)/m.σ) / (exp(exp(-(age - m.m)/m.σ)) - 1)
cumhazard(m::InverseGompertz,age) = -log(survivorship(m,age))
survivorship(m::InverseGompertz,age) = (1 - exp(-exp(-(age - m.m)/m.σ))) / (1 - exp(-exp(m.m/m.σ)))

"""
    Opperman(a,b,c)

Construct a mortality model following Opperman's law of mortality.

Default args:

    a = 0.04
    b = 0.0004
    c = 0.001
"""
Base.@kwdef struct Opperman <: ParametricMortality
    a = 0.04
    b = 0.0004
    c = 0.001
end

hazard(m::Opperman,age) = max(m.a / √(age+1) - m.b + m.c * √(age+1),0.0)

"""
    Thiele(a,b,c,d,e,f,g)

Construct a mortality model following Opperman's law of mortality.

Default args:

    a = 0.02474 
    b = 0.3
    c = 0.004
    d = 0.5
    e = 25
    f = 0.0001
    g = 0.13
"""
Base.@kwdef struct Thiele <: ParametricMortality
    a = 0.02474 
    b = 0.3
    c = 0.004
    d = 0.5
    e = 25
    f = 0.0001
    g = 0.13
end

function hazard(m::Thiele,age) 
    μ₁ = m.a * exp(-m.b*age)
    μ₂ = m.c * exp(-0.5 * m.d * (age -m.e)^2)
    μ₃ = m.f * exp(m.g *age)

    if age == 0 
        return μ₁ + μ₃
    else
        return  μ₁ + μ₂ + μ₃
    end
end

"""
    Wittstein(a,b,m,n)

Construct a mortality model following Wittstein's law of mortality.

Default args:

    a = 1.5
    b = 1.
    n = 0.5
    m = 100

"""
Base.@kwdef struct Wittstein <: ParametricMortality
    a = 1.5
    b = 1.
    n = 0.5
    m = 100
end

function hazard(m::Wittstein,age) 
    return (1 / m.b) * m.a ^ -((m.b * age) ^ m.n) + m.a ^ -((m.m -  age) ^ m.n) 
end

"""
    Weibull(m,σ)

Construct a mortality model following Weibull's law of mortality.

Note that if σ > m, then the mode of the density is 0 and hx is a non-increasing function of x, while if σ < m, then the mode is greater than 0 and hx is an increasing function. 
 - `m >0` is a measure of location
 - `σ >0` is measure of dispersion


 Default args:

    m = 1
    σ = 2
"""
Base.@kwdef struct Weibull <: ParametricMortality
    m = 1
    σ = 2
end

function hazard(m::Weibull,age)
    if age == 0
        return 1.0
    else 
        return 1 / m.σ * (age / m.m)^(m.m / m.σ - 1)
    end
end

function cumhazard(m::Weibull,age)
    return (age / m.m) ^ (m.m / m.σ)
end

function survivorship(m::Weibull,age) 
    return exp(-cumhazard(m,age))
end

"""
    InverseWeibull(m,σ)

Construct a mortality model following Weibull's law of mortality.

The Inverse-Weibull proves useful for modelling the childhood and teenage years, because the logarithm of h(x) is a concave function.
 - `m >0` is a measure of location
 - `σ >0` is measure of dispersion

 Default args:

    m = 5
    σ = 10

"""
Base.@kwdef struct InverseWeibull <: ParametricMortality
    m = 5
    σ = 10
end

function hazard(m::InverseWeibull,age)
    return (1/m.σ) * (age/m.m)^(-m.m/m.σ - 1) / (exp((age/m.m)^(-m.m/m.σ)) - 1)
end

function cumhazard(m::InverseWeibull,age)
    return -log(1 - exp(-(age/m.m)^(-m.m/m.σ)))
end

function survivorship(m::InverseWeibull,age) 
    return exp(-cumhazard(m,age))
end

"""
    Perks(a,b,c,d)

Construct a mortality model following Perks' law of mortality.

Default args:

    a = 0.002
    b = 0.13
    c = 0.01
    d = 0.01
"""
Base.@kwdef struct Perks <: ParametricMortality
    a = 0.002
    b = 0.13
    c = 0.01
    d = 0.01
end

function hazard(m::Perks,age) 
    return (m.a + m.b*m.c^age) / (m.b*(m.c^-age) + 1 + m.d*m.c^age)
end

"""
    VanderMaen(a,b,c,i,n)

Construct a mortality model following VanderMaen's law of mortality.

Default args:
    
    a = 0.01
    b = 1
    c = 0.01
    i = 100
    n = 200
"""
Base.@kwdef struct VanderMaen <: ParametricMortality
    a = 0.01
    b = 1.
    c = 0.01
    i = 100.
    n = 200.
end

function hazard(m::VanderMaen,age) 
    return m.a + m.b*age + m.c*(age^2) + m.i/(m.n - age)
end

"""
    VanderMaen2(a,b,i,n)

Construct a mortality model following VanderMaen2's law of mortality.

Default args:

    a = 0.01
    b = 1
    i = 100
    n = 200

"""
Base.@kwdef struct VanderMaen2 <: ParametricMortality
    a = 0.01
    b = 1.
    i = 100.
    n = 200.
end

function hazard(m::VanderMaen2,age) 
    return m.a + m.b * age + m.i/(m.n - age)
end

"""
    StrehlerMildvan(k,v₀,b,d)

Construct a mortality model following StrehlerMildvan's law of mortality.

Default args:

    k   = 0.01
    v₀  = 2.5
    b   = 0.2
    d   = 6.0

"""
Base.@kwdef struct StrehlerMildvan <: ParametricMortality
    k   = 0.01
    v₀  = 2.5
    b   = 0.2
    d   = 6.0
end

function hazard(m::StrehlerMildvan,age) 
    return  m.k * exp(-m.v₀ * (1 - m.b * age) / m.d)
end

"""
    Beard(a,b,k)

Construct a mortality model following Beard's law of mortality.

Default args:
    
    a = 0.002
    b = 0.13
    k = 1.
"""
Base.@kwdef struct Beard <: ParametricMortality
    a = 0.002
    b = 0.13
    k = 1.
end

function hazard(m::Beard,age) 
    return  m.a * exp(m.b*age) / (1 + m.k * m.a * exp(m.b*age))
end

"""
    MakehamBeard(a,b,k)

Construct a mortality model following MakehamBeard's law of mortality.

Default args:

    a = 0.002
    b = 0.13
    c = 0.01
    k = 1.
"""
Base.@kwdef struct MakehamBeard <: ParametricMortality
    a = 0.002
    b = 0.13
    c = 0.01
    k = 1.
end

function hazard(m::MakehamBeard,age) 
    return  m.a * exp(m.b*age) / (1 + m.k * m.a * exp(m.b*age)) + m.c
end

"""
    Quadratic(a,b,k)

Construct a mortality model following Quadratic law of mortality.

Default args:

    a = 0.01
    b = 1.
    c = 0.01
"""
Base.@kwdef struct Quadratic <: ParametricMortality
    a = 0.01
    b = 1.
    c = 0.01
end

function hazard(m::Quadratic,age) 
    return  m.a + m.b * age + m.c * age^2
end

### Generic Functions

"""
    μ(m::ParametricMortality,age)

``\\mu_x``: Return the force of mortality at the given age. 
"""
function μ(m::ParametricMortality, age) 
    return hazard(m,age)
end


# # use the integral to calculate the one-year survival
# function survivorship(m::ParametricMortality, from_age, to_age) 
#     if from_age == to_age
#         return 1.0
#     else
#         return exp(-quadgk(age->μ(m, age), from_age, to_age)[1])
#     end
# end
# survivorship(m::ParametricMortality,to_age) = survivorship(m, 0, to_age)

survivorship(m::ParametricMortality,age) = exp(-quadgk(age->μ(m, age), 0, to_age)[1])
survivorship(m,from,to) = survivorship(m,to) / survivorship(m,from)
decrement(m::ParametricMortality,from_age,to_age) = 1 - survivorship(m, from_age, to_age)
decrement(m::ParametricMortality,to_age) = 1 - survivorship(m, to_age)

(m::ParametricMortality)(x) = μ(m, x)
Base.getindex(m::ParametricMortality,x) = m(x)
Base.broadcastable(pm::ParametricMortality) = Ref(pm)