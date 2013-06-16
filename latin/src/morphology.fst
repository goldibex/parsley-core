#include "src/symbols.fst"
#include "src/phonology.fst"

#all-but-stemtype# = #character# #morph# #other#

$stems$ = "<out/stems.a>" || $letter$+ [#symbol#]:<>+
$indecl-stems$ = [#all-but-stemtype#]+ [#indecl#] || $stems$
$ends$ = "<out/endings.a>" || $letter$+ [#symbol#]:<>+
$morph$ = $stems$ $ends$

$acceptor$ = "<out/acceptor.a>"

($acceptor$ || $morph$) | $indecl-stems$
