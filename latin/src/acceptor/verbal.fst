#include "src/symbols.fst"
#include "src/phonology.fst"

#nonmorph# = #character# #other#
$nonmorph$ = [#nonmorph#]

$=finite-mood$ = [<ind><subj><imperat>]
$=verb$ = [#verb#]
($=person$ | $=number$ | $=tense$ | $=finite-mood$ | $=voice$ | $nonmorph$)* $=verb$ ($=person$ | $=number$ | $=tense$ | $=finite-mood$ | $=voice$ | $nonmorph$)* $=verb$
