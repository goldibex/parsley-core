#include "src/symbols.fst"

$=noun$ = [#noun#]
($=case$ | $=number$ | $=gender$ | $other$)* $=noun$ ($=case$ | $=number$ | $=gender$ | $other$)* $=noun$ 
