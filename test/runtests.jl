using Sandboxes: baremod, sandboxify, sandboxed_eval_expr
using Test

"Test `ex` evaluates without throwing"
macro test_nothrow(ex)
    :(@test ($(esc(ex)); true))
end

@testset "Sandboxes.jl" begin
    s = baremod()

    # We can inject functionality into the sandbox
    @test eval(sandboxed_eval_expr(s, :( nand(a, b) = $(~)($(&)(a, b)) ) )) == s.nand
    @test eval(sandboxed_eval_expr(s, :( not(a) = nand(a, true) ) )) == s.not
    @test eval(sandboxed_eval_expr(s, :( not(false) ) )) == true == s.not(false)

    # We can access properties and create symbols with names that are exported from Core
    @test_nothrow sandboxify( :( X.Int ) )
    @test_nothrow sandboxify( :( :Int ) )
    @test_nothrow sandboxify( :( Int = "foo" ) )

    # Some expression types are denied
    @test_throws Exception sandboxify( :( import X ) )
    @test_throws Exception sandboxify( :( import X: y ) )
    @test_throws Exception sandboxify( :( using X ) )
    @test_throws Exception sandboxify( :( using X: y ) )
    @test_throws Exception sandboxify( :( baremodule X end ) )
    @test_throws Exception sandboxify( :( baremodule X end ) )
    @test_throws Exception sandboxify( :( module X end; X.eval ) )

    # Access to values of `Core` is denied
    @test_throws UndefVarError eval(sandboxed_eval_expr(s, :( Core ) ))
    @test s.eval == Core.eval
    @test_throws UndefVarError eval(sandboxed_eval_expr(s, :( eval ) ))

    # Can't use a macro to escape the sandbox
    @test_throws Exception sandboxify(:(macro x() :($(:Core)) end))

    # Eventually it would be nice to allow macro definitions within the
    # sandbox, so here's a broken test to remind us.
    # eval(sandboxed_eval_expr(s, :(macro x() :($(:Core)) end)))
    @test_broken eval(sandboxed_eval_expr(s, :(@x().eval))) != Core.eval

    # Until you define something with that name
    @test eval(sandboxed_eval_expr(s, :( eval() = "hello" ) )) != s.eval
    @test eval(sandboxed_eval_expr(s, :( eval() ) )) == "hello"
end
