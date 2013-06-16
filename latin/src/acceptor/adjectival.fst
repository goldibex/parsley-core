#include "src/symbols.fst"
#include "src/phonology.fst"

#nonmorph# = #character# #other#
$nonmorph$ = [#nonmorph#]
$=adj$ = [#adj#]
($=case$ | $=number$ | $=gender$ | $=degree$ | $nonmorph$)* $=adj$ ($=case$ | $=number$ | $=gender$ | $=degree$ | $nonmorph$)* $=adj$ 
