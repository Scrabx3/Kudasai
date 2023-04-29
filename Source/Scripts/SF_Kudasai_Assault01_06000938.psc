;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 13
Scriptname SF_Kudasai_Assault01_06000938 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
Debug.Trace("[Kudasai] Player Scene End")
KudasaiAssault s = GetOwningQuest() as KudasaiAssault
s.EndCycle(0, Game.GetPlayer())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
Debug.Trace("[Kudasai] Player Scene Start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
; Post scene end, have actors move on their own again
KudasaiAssault scr = GetOwningQuest() as KudasaiAssault
scr.SetStage(110)
scr.EvaluatePackageGroup(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
KudasaiAssault s = GetOwningQuest() as KudasaiAssault
s.EndCycle(0, Game.GetPlayer())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
KudasaiAssault s = GetOwningQuest() as KudasaiAssault
if !s.CanEnterNSFW
KudasaiInternal.RobActor(s.PlayerRef, s.FirstNPC.GetActorRef())
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10(ReferenceAlias akAlias)
;BEGIN CODE
Player.GoToState("Exhausted")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ReferenceAlias akAlias)
;BEGIN CODE
KudasaiAssault s = GetOwningQuest() as KudasaiAssault
If s.CanEnterNSFW
s.MakePlayerCycle()
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ReferenceAlias Property DialogueNPC  Auto  

ReferenceAlias Property Player  Auto  
