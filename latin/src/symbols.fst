#include "src/stemtypes.fst"

#person# = <1st><2nd><3rd>
#number# = <sg><pl>
#gender# = <masc><fem><neut>
#case# = <nom><acc><gen><dat><abl><voc><adverbial>
#tense# = <pres><imperf><fut><perf><plup><futperf>
#mood# = <ind><inf><imperat><subj><gerundive><supine><part>
#voice# = <act><pass>
#degree# = <pos><comp><superl><irreg_superl>
#morph# = #person# #number# #gender# #case# #tense# #mood# #voice# #degree#

#time# = <early><late>
#type# = <pers_name><person><place><ethnic><river>
#other# = #deriv# #time# #type# <no_comp>

#symbol# = #morph# #other# #stemtype#

$person$ = [#person#]
$number$ = [#number#]
$gender$ = [#gender#]
$case$ = [#case#]
$tense$ = [#tense#]
$mood$ = [#mood#]
$voice$ = [#voice#]
$degree$ = [#degree#]
$other$ = [#other#]
$stemtype$ = [#stemtype#]
$symbol$ = [#symbol#]

$=person$ = [#person#]
$=number$ = [#number#]
$=gender$ = [#gender#]
$=case$ = [#case#]
$=tense$ = [#tense#]
$=mood$ = [#mood#]
$=voice$ = [#voice#]
$=degree$ = [#degree#]
$=stemtype$ = [#stemtype#]

$separator$ = {\:\:}:<>
