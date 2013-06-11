#include "symbols.fst"
#include "stemtypes.fst"
#include "phonology.fst"

#morph-or-other# = #morph# #other#
$strip-letter$ = <>:[A-Za-z0-9\^\_\+]+ || $letter$+
$stems$ = "<stems/stems.a>" || $letter$+ [#morph-or-other#]:<>* [#stemtype#]:<>
$ends$ = "<endings/endings.a>" || $letter$+ [#morph-or-other#]:<>* [#stemtype#]:<>
$morph$ = $stems$ $ends$

$acceptor$ = "<acceptor.a>"

$strip-letter$
