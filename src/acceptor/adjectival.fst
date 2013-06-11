#include "src/symbols.fst"

$=adj$ = [#adj#]
($=case$ | $=number$ | $=gender$ | $=degree$ | $other$)* $=adj$ ($=case$ | $=number$ | $=gender$ | $=degree$ | $other$)* $=adj$ 
