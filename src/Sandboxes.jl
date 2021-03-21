module Sandboxes

using MLStyle: @match
using ReplMaker: LineEdit, enter_mode!, initrepl

"""
    baremod()

Return an anonymous baremodule
"""
baremod() = @eval baremodule $(gensym(:Sandboxes_mod)) end

# :ccall is here because it's not exported, but is callable. It's a special-cased not-function.
# I don't think there are any others (`outer` used to be like this, but is now syntax).
const core_name_remaps = Dict(n => gensym(:Sandboxes_remaps) for n in [:ccall, names(Core)...])
const inverse_core_name_remaps = Dict(reverse.(collect(core_name_remaps)))

"""
    sandboxify(ex:Expr)

Return an expression that, when evaluated in a baremodule, cannot:

- access identifiers in `Core`
- import other modules
- define new modules (this would allow escape by `eval` or `.Core`)
- define macros (this allows escape by returning `:(:Core)`)

To punch holes in the sandbox, interpolate values into the expression like this:

```
sandboxify( :( nand(a, b) = \$(~)(\$(&)(a, b)) ) )
```

The above example will return an expression for a function that will internally
call `~` and `&` as defined in the scope you created the expression in, rather
than as defined in the sandbox.
"""
function sandboxify(ex)
    filterer(ex) = @match ex begin
        # Map names that are in Core to generated symbols so that they cannot be accessed.
        s::Symbol => get(core_name_remaps, s, s)

        # This is to prevent `baremodule X end; X.Core`.
        # QuoteNode remapping will unfortunately make it impossible to access a
        # property with a reserved name on a struct you've imported into the
        # sandbox and will make code that deals with literal QuoteNodes pretty
        # weird and error prone.
        # Maybe this can be done with less breakage.
        # QuoteNode(s) => QuoteNode(get(core_name_remaps, s, s))

        # For now let's ban all modules so we don't need to rewrite QuoteNodes
        Expr(:module, _...) => error("You cannot define modules in this sandbox.")

        # Not allowed to import stuff
        Expr(:using, _...) ||
        Expr(:import, _...) => error("Imports are not permitted in this sandbox: $ex")

        # Can't use a macro to escape the sandbox
        #
        # At the moment, I can't work out how to make macro definition inside the
        # sandbox safe (filtering the globalrefs in the macroexpand of the
        # expression, maybe, but then that interferes with macros you've
        # deliberately imported into the sandbox)
        #
        # Possibly I could put a special form inside the macro definitions that I
        # then use as a signal to turn on sandboxing, but that seems like a bunch
        # of work.
        #
        # So anyway, for now you can't define macros inside the sandbox at all.
        Expr(:macro, _...) => error("Macro definitions are not permitted in this sandbox: $ex")

        # This allows trivial escape via `eval` and `Base`
        Expr(:module, true, _...) => error("You cannot define non-bare modules in this sandbox.")

        # Recurse
        Expr(head, args...) => Expr(head, filterer.(args)...)

        # Fallback
        x => x
    end
    filterer(ex)
end

"""
    sandboxed_eval_expr(m::Module, ex::Expr)

Return an expression that, when evaluated, will safely evaluate some transformation of `ex` in `m`.
"""
function sandboxed_eval_expr(m::Module, ex)
    quote
        try
            @eval $m $(sandboxify(ex))
        catch e
            if e isa UndefVarError && haskey($inverse_core_name_remaps, e.var)
                rethrow(UndefVarError($inverse_core_name_remaps[e.var]))
            else
                rethrow()
            end
        end
    end
end

# REPL inside sandbox

"""
    repl_in(m::Module)

Define a REPL that eval's sandboxed code inside the baremodule `m`.
"""
function repl_in(m::Module)
    function valid_julia(s)
        input = String(take!(copy(LineEdit.buffer(s))))
        ex = Meta.parse(input)
        !(ex isa Expr && ex.head == :incomplete)
    end

    function sandbox_parser(s::String)
        ex = Meta.parse(s)
        sandboxed_eval_expr(m, ex)
    end

    sandbox_mode = initrepl(sandbox_parser;
                            prompt_text="Sandbox> ",
                            prompt_color = :yellow,
                            startup_text = false,
                            mode_name = :sandbox,
                            valid_input_checker = valid_julia)
end

"""
    enter_repl(m::Module)

Start a sandboxed REPL mode inside baremodule `m`.
"""
function enter_repl(m::Module)
    enter_mode!(repl_in(m))
end

end
