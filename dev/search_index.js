var documenterSearchIndex = {"docs":
[{"location":"api/","page":"API","title":"API","text":"CurrentModule = Sandboxes","category":"page"},{"location":"api/#API-Reference","page":"API","title":"API Reference","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/","page":"API","title":"API","text":"Modules = [Sandboxes]","category":"page"},{"location":"api/#Sandboxes.baremod-Tuple{}","page":"API","title":"Sandboxes.baremod","text":"baremod()\n\nReturn an anonymous baremodule\n\n\n\n\n\n","category":"method"},{"location":"api/#Sandboxes.enter_repl-Tuple{Module}","page":"API","title":"Sandboxes.enter_repl","text":"enter_repl(m::Module)\n\nStart a sandboxed REPL mode inside baremodule m.\n\n\n\n\n\n","category":"method"},{"location":"api/#Sandboxes.repl_in-Tuple{Module}","page":"API","title":"Sandboxes.repl_in","text":"repl_in(m::Module)\n\nDefine a REPL that eval's sandboxed code inside the baremodule m.\n\n\n\n\n\n","category":"method"},{"location":"api/#Sandboxes.sandboxed_eval_expr-Tuple{Module,Any}","page":"API","title":"Sandboxes.sandboxed_eval_expr","text":"sandboxed_eval_expr(m::Module, ex::Expr)\n\nReturn an expression that, when evaluated, will safely evaluate some transformation of ex in m.\n\n\n\n\n\n","category":"method"},{"location":"api/#Sandboxes.sandboxify-Tuple{Any}","page":"API","title":"Sandboxes.sandboxify","text":"sandboxify(ex:Expr)\n\nReturn an expression that, when evaluated in a baremodule, cannot:\n\naccess identifiers in Core\nimport other modules\ndefine new modules (this would allow escape by eval or .Core)\ndefine macros (this allows escape by returning :(:Core))\n\nTo punch holes in the sandbox, interpolate values into the expression like this:\n\nsandboxify( :( nand(a, b) = $(~)($(&)(a, b)) ) )\n\nThe above example will return an expression for a function that will internally call ~ and & as defined in the scope you created the expression in, rather than as defined in the sandbox.\n\n\n\n\n\n","category":"method"},{"location":"#Sandboxes","page":"Home","title":"Sandboxes","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Docs","category":"page"},{"location":"","page":"Home","title":"Home","text":"A simple sandboxing mechanism for evaluating Julia code in a restricted environment. You might want to use this if:","category":"page"},{"location":"","page":"Home","title":"Home","text":"You want to evaluate untrusted code and restrict what it can do\nYou want to define a simpler version of Julia for teaching something or as a DSL","category":"page"},{"location":"#Method","page":"Home","title":"Method","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Make a bare module, M\nEval the desired interface into M\nCheck an expr E to eval in M\nWhite or blacklist certain Expr heads and types\nRewrite symbols that are equal to symbols in Core and :ccall (so the only available symbols are those that have been eval'd in)\nThis step unnecessary if Julia later supports more bare baremodules (https://discourse.julialang.org/t/even-more-bare-baremodule/56156/)","category":"page"},{"location":"","page":"Home","title":"Home","text":"A valid alternative method might be to use a compiler pass like Cassette, but I don't think we need to.","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This isn't implemented yet, I'm still deciding. For now, check the tests to see how to use it.","category":"page"},{"location":"","page":"Home","title":"Home","text":"@sandboxed module M\n    # Your safe interfaces here\nend\n\nsandboxed_eval(M, expr)\nsandboxed_include(M, file)\n\n# Evaluate code without sandboxing, if you need to\n@eval M unsandboxed_expr","category":"page"},{"location":"","page":"Home","title":"Home","text":"It might be appropriate for us to warn if the user imports any code with anything other than using X: something_safe. Users will need to be cautious of eval available on most module objects, for example.","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you need many sandboxes:","category":"page"},{"location":"","page":"Home","title":"Home","text":"sandbox() = eval(:(@sandboxed module M ... end))","category":"page"},{"location":"","page":"Home","title":"Home","text":"Probably want to provide a string interface for REPLs and an easy interface for disabling bits of Julia, seeing as I've done that work and it might be useful for others. Or maybe I should just provide an example and suggest they copy it to start them off, idk.","category":"page"},{"location":"#Safe-part-of-Base","page":"Home","title":"Safe part of Base","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"It would be useful if users could easily use the safe parts of Base. map, filter, arithmetic, etc, are probably safe :)","category":"page"},{"location":"#Outside-of-threat-model","page":"Home","title":"Outside of threat model","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"eval'ing extra properties onto Core after a sandbox has started","category":"page"}]
}