using DiffRules

M=:Base
f=:sin
Mf = :($M.$f)
@eval $Mf(1)
@eval begin
    da = DiffRules.diffrule(M, f, :a)
    @grad $Mf(a::Real) = $Mf(data(a)), Δ -> (Δ * $da,)
    $Mf(a::TrackedReal) = track($Mf, a)
end

macro grad(ex)
    @capture(shortdef(ex), (name_(args__) = body_) |
                           (name_(args__) where {T__} = body_)) || error("Need a function definition")
    T == nothing && (T = [])
    isexpr(name, :(::)) || (name = :(::typeof($name)))
    insert!(args, 1+isexpr(args[1], :parameters) , name)
    @q(Tracker._forward($(args...)) where $(T...) = $body) |> esc
end


      for (M, f, arity) in DiffRules.diffrules(; filter_modules=nothing)
    if !(isdefined(@__MODULE__, M) && isdefined(getfield(@__MODULE__, M), f))
      @warn "$M.$f is not available and hence rule for it can not be defined"
      continue  # Skip rules for methods not defined in the current scope
    end
    Mf = :($M.$f)
    if arity == 1
      @eval begin
        @grad $Mf(a::Real) = $Mf(data(a)), Δ -> (Δ * $(DiffRules.diffrule(M, f, :a)),)
        $Mf(a::TrackedReal) = track($Mf, a)
      end
    elseif arity == 2
      da, db = DiffRules.diffrule(M, f, :a, :b)
      @eval begin
        @grad $Mf(a::TrackedReal, b::TrackedReal) = $Mf(data(a), data(b)), Δ -> (Δ * $da, Δ * $db)
        @grad $Mf(a::TrackedReal, b::Real) = $Mf(data(a), b), Δ -> (Δ * $da, zero(b))
        @grad $Mf(a::Real, b::TrackedReal) = $Mf(a, data(b)), Δ -> (zero(a), Δ * $db)
        $Mf(a::TrackedReal, b::TrackedReal)  = track($Mf, a, b)
        $Mf(a::TrackedReal, b::Real) = track($Mf, a, b)
        $Mf(a::Real, b::TrackedReal) = track($Mf, a, b)
      end
    end
end