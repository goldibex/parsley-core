#include "src/symbols.fst"
#include "src/phonology.fst"

ALPHABET = [#character#] [#symbol#]

$pres$ = <conj1>:<ire_vb>
$perf$ = <ivperf>:<ire_vb>
$pp4$ = {i\_t<pp4>}:<ire_vb>

.* ($pres$ || $perf$ || $pp4$)? .*
