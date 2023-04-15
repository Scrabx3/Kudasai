;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 12
Scriptname SF_KudasaiSurrender_0578A4F6 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
GetOwningQuest().SetStage(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Scene Begin
Debug.Trace("[Kudasai] Surrender Scene Begin")
SendModEvent("dhlp-Suspend")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
; Scene End
(GetOwningQuest() as KudasaiSurrender).SurrenderEnd()
Debug.Trace("[Kudasai] Surrender Scene End")
SendModEvent("dhlp-Resume")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
