#include "src/symbols.fst"
#include "src/phonology.fst"

#nonmorph# = #character# #other#
$nonmorph$ = [#nonmorph#]

$=noun$ = [#noun#]
($=case$ | $=number$ | $=gender$ | $nonmorph$)* $=noun$ ($=case$ | $=number$ | $=gender$ | $nonmorph$)* $=noun$ 
