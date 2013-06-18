#include "src/symbols.fst"
#include "src/phonology.fst"

ALPHABET = [#character#] [#symbol#]

$pres$ = <conj1>:<are_vb>
$perf$ = <avperf>:<are_vb>
$pp4$ = {a\_t<pp4>}:<are_vb>

.* ($pres$ | $perf$ | $pp4$)? .*
