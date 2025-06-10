use NQPHLL;

grammar Flea::Grammar is HLL::Grammar {
    rule TOP { <statement>+ % [';'] }

    rule statement { <say_stmt> }

    rule say_stmt { 'say' <str_lit> }

    token str_lit { \" <-["]>* \" }
}

class Flea::Actions is HLL::Actions {

}

class Flea::Compiler is HLL::Compiler {

    method eval($code, *@_args, *%adverbs) {
        my $output := self.compile($code, :compunit_ok(1), |%adverbs);

        if %adverbs<target> eq '' {
            my $outer_ctx := %adverbs<outer_ctx>;
            $output := self.backend.compunit_mainline($output);
            if nqp::defined($outer_ctx) {
                nqp::forceouterctx($output, $outer_ctx);
            }

            $output := $output();
        }

        $output;
    }
}

sub MAIN(*@ARGS) {

    my $comp := Flea::Compiler.new();
    $comp.language('flea');
    $comp.parsegrammar(Flea::Grammar);
    $comp.parseactions(Flea::Actions);
    $comp.command_line(@ARGS, :encoding('utf8'));
}
