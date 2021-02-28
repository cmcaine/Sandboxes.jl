# Sandboxes

[Docs](https://cmcaine.github.io/Sandboxes.jl/dev/)

A simple sandboxing mechanism for evaluating Julia code in a restricted environment.
You might want to use this if:

- You want to evaluate untrusted code and restrict what it can do
- You want to define a simpler version of Julia for teaching something or as a DSL

## Method

1. Make a bare module, M
2. Eval the desired interface into M
3. Check an expr E to eval in M
   - White or blacklist certain Expr heads and types
   - Rewrite symbols that are equal to symbols in Core and `:ccall` (so the only available symbols are those that have been eval'd in)
     - This step unnecessary if Julia later supports more bare baremodules (https://discourse.julialang.org/t/even-more-bare-baremodule/56156/)

A valid alternative method might be to use a compiler pass like Cassette, but I don't think we need to.

## API

**This isn't implemented yet, I'm still deciding.** For now, check the tests to see how to use it.

```jl
@sandboxed module M
    # Your safe interfaces here
end

sandboxed_eval(M, expr)
sandboxed_include(M, file)

# Evaluate code without sandboxing, if you need to
@eval M unsandboxed_expr
```

It might be appropriate for us to warn if the user imports any code with anything other than `using X: something_safe`.
Users will need to be cautious of `eval` available on most module objects, for example.

If you need many sandboxes:

```jl
sandbox() = eval(:(@sandboxed module M ... end))
```

Probably want to provide a string interface for REPLs and an easy interface for disabling bits of Julia, seeing as I've done that work and it might be useful for others.
Or maybe I should just provide an example and suggest they copy it to start them off, idk.

## Safe part of Base

It would be useful if users could easily use the safe parts of `Base`.
`map`, `filter`, arithmetic, etc, are probably safe :)

## Outside of threat model

- eval'ing extra properties onto `Core` after a sandbox has started
