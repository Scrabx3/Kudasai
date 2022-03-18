;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname QF_Kudasai_rNPC_Quest_058130AF Extends Quest Hidden

;BEGIN ALIAS PROPERTY Victoire00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE KudasaiResolutionNPC
Quest __temp = self as Quest
KudasaiResolutionNPC kmyQuest = __temp as KudasaiResolutionNPC
;END AUTOCAST
;BEGIN CODE
kmyQuest.ForceStopScenes()

SetStage(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN AUTOCAST TYPE KudasaiResolutionNPC
Quest __temp = self as Quest
KudasaiResolutionNPC kmyQuest = __temp as KudasaiResolutionNPC
;END AUTOCAST
;BEGIN CODE
kmyQuest.UnsetLinks()

Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN AUTOCAST TYPE KudasaiResolutionNPC
Quest __temp = self as Quest
KudasaiResolutionNPC kmyQuest = __temp as KudasaiResolutionNPC
;END AUTOCAST
;BEGIN CODE
CreateLoop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
