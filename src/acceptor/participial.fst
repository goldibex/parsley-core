#include "src/symbols.fst"

$=part$ = [#verb#]
$=part-tense$ = [<pres><fut>]
$pres-fut-part$ = ($=case$ | $=number$ | $=gender$ | $=part-tense$ | <act> | <part> | $other$)* $=part$ ($=case$ | $=number$ | $=gender$ | $=part-tense$ | <act> | <part> | $other$)* $=part$ 
$gerundive$ = ($=case$ | $=number$ | $=gender$ | <gerundive> | $other$)* $=part$ ($=case$ | $=number$ | $=gender$ | <gerundive> | $other$)* $=part$
$perf-pass-part$ = ($=case$ | $=number$ | $=gender$ | <perf> | <pass> | <part> | $other$)* $=part$ ($=case$ | $=number$ | $=gender$ | <perf> | <pass> | <part> | $other$)* $=part$ 

$=supine-case$ = [<acc><dat><abl>]
$supine$ = ($=supine-case$ | <sg> | <masc> | <supine> | $other$)* $=part$ ($=supine-case$ | <sg> | <masc> | <supine> | $other$)* $=part$

($pres-fut-part$ | $gerundive$ | $perf-pass-part$ | $supine$)
