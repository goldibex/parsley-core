#include "src/symbols.fst"
#include "src/phonology.fst"

#nonmorph# = #character# #other#
$nonmorph$ = [#nonmorph#]

$=part$ = [#verb#]
$=part-tense$ = [<pres><fut>]
$pres-fut-part$ = ($=case$ | $=number$ | $=gender$ | $=part-tense$ | <act> | <part> | $nonmorph$)* $=part$ ($=case$ | $=number$ | $=gender$ | $=part-tense$ | <act> | <part> | $nonmorph$)* $=part$ 
$gerundive$ = ($=case$ | $=number$ | $=gender$ | <gerundive> | $nonmorph$)* $=part$ ($=case$ | $=number$ | $=gender$ | <gerundive> | $nonmorph$)* $=part$
$perf-pass-part$ = ($=case$ | $=number$ | $=gender$ | <perf> | <pass> | <part> | $nonmorph$)* $=part$ ($=case$ | $=number$ | $=gender$ | <perf> | <pass> | <part> | $nonmorph$)* $=part$ 

$=supine-case$ = [<nom><dat>]
$supine$ = ($=supine-case$ | <sg> | <neut> | <supine> | $nonmorph$)* <pp4> ($=supine-case$ | <sg> | <neut> | <supine> | $nonmorph$)* <pp4>

($pres-fut-part$ | $gerundive$ | $perf-pass-part$ | $supine$)
