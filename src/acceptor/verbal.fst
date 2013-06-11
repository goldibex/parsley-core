#include "src/symbols.fst"

$=finite-mood$ = [<ind><subj><imperat>]
$=verb$ = [#verb#]
($=person$ | $=number$ | $=tense$ | $=finite-mood$ | $=voice$ | $other$)* $=verb$ ($=person$ | $=number$ | $=tense$ | $=finite-mood$ | $=voice$ | $other$)* $=verb$
