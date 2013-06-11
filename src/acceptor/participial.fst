#include "src/symbols.fst"
#include "src/phonology.fst"

#nonmorph# = #character# #other#
$nonmorph$ = [#nonmorph#]

$=part$ = [#verb#]
$=part-tense$ = [<pres><fut>]
$pres-fut-part$ = ($=case$ | $=number$ | $=gender$ | $=part-tense$ | <act> | <part> | $nonmorph$)* $=part$ ($=case$ | $=number$ | $=gender$ | $=part-tense$ | <act> | <part> | $nonmorph$)* $=part$ 
$gerundive$ = ($=case$ | $=number$ | $=gender$ | <gerundive> | $nonmorph$)* $=part$ ($=case$ | $=number$ | $=gender$ | <gerundive> | $nonmorph$)* $=part$
$perf-pass-part$ = ($=case$ | $=number$ | $=gender$ | <perf> | <pass> | <part> | $nonmorph$)* $=part$ ($=case$ | $=number$ | $=gender$ | <perf> | <pass> | <part> | $nonmorph$)* $=part$ 

$=supine-case$ = [<acc><dat><abl>]
$supine$ = ($=supine-case$ | <sg> | <masc> | <supine> | $nonmorph$)* $=part$ ($=supine-case$ | <sg> | <masc> | <supine> | $nonmorph$)* $=part$

($pres-fut-part$ | $gerundive$ | $perf-pass-part$ | $supine$)
