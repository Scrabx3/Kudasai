;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 12
Scriptname SF_Kudasai_rPlayerScene01_058274D5 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
(GetOwningQuest() as KudasaiRPlayer).CreateStruggle(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
(GetOwningQuest() as KudasaiRPlayer).CreateCycle(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
KudasaiRPlayer q = GetOwningQuest() as KudasaiRPlayer
q.QuitCycle(0)
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
; Post Rob Dialogue, moved this into pre Rob Dialogue to have the NPC say his line 'while' robbing
; (GetOwningQuest() as KudasaiRPlayer).RobVictim(Game.GetPlayer(), EnemyNPC.GetReference() as Actor)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Pre Rob Dialogue
(GetOwningQuest() as KudasaiRPlayer).RobVictim(Game.GetPlayer(), EnemyNPC.GetReference() as Actor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ReferenceAlias Property EnemyNPC  Auto  
