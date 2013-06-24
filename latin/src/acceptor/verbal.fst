#include "src/symbols.fst"
#include "src/phonology.fst"

#nonmorph# = #character# #other#
$nonmorph$ = [#nonmorph#]

$=finite-mood$ = [<ind><subj><imperat>]
$=verb$ = [#verb#]
$finite_acceptor$ = ($=person$ | $=number$ | $=tense$ | $=finite-mood$ | $=voice$ | $nonmorph$)* $=verb$ ($=person$ | $=number$ | $=tense$ | $=finite-mood$ | $=voice$ | $nonmorph$)* $=verb$
$infinite_acceptor$ = (<inf> | $=tense$ | $=voice$ | $nonmorph$)* $=verb$ (<inf> | $=tense$ | $=voice$ | $nonmorph$)* $=verb$

$finite_acceptor$ | $infinite_acceptor$
