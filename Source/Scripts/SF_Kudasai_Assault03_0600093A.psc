;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname SF_Kudasai_Assault03_0600093A Extends Scene Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Debug.Trace("[Kudasai] AllyScene 1 Start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
Debug.Trace("[Kudasai] AllyScene 1 End")
KudasaiAssault s = GetOwningQuest() as KudasaiAssault
Actor ref = s.RefAlly1.GetActorRef()
s.EndCycle(2, ref)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
KudasaiAssault s = GetOwningQuest() as KudasaiAssault
s.MakeAllyCycle(2)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
