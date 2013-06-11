#include "src/symbols.fst"
#include "src/phonology.fst"

#all-but-stemtype# = #character# #morph# #other#

$stems$ = "<out/stems.a>" || $letter$+ [#symbol#]:<>+
$indecl-stems$ = [#all-but-stemtype#]+ [#indecl#] || $stems$
$ends$ = "<out/endings.a>" || $letter$+ [#symbol#]:<>+
$morph$ = $stems$ $ends$
$morph$ = $morph$ | $indecl-stems$

$acceptor$ = "<out/acceptor.a>"

$x$ = $acceptor$ || $morph$
$indecl-stems$
