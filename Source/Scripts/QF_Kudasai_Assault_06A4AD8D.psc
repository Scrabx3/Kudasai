;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname QF_Kudasai_Assault_06A4AD8D Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ally2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ally2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY B5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_B5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FirstNPC
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FirstNPC Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY RecentSpeaker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_RecentSpeaker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY C6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_C6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY B4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_B4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Root
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Root Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY C2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_C2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A7
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A7 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY B2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_B2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY B1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_B1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY C5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_C5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY B3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_B3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY C1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_C1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY C3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_C3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ally1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ally1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY C4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_C4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY B6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_B6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY A1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_A1 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
; Player exhaustion completed
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
; Ally 1 cycle done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Acheron.DisableConsequence(true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN AUTOCAST TYPE KudasaiAssault
Quest __temp = self as Quest
KudasaiAssault kmyQuest = __temp as KudasaiAssault
;END AUTOCAST
;BEGIN CODE
kmyQuest.QuestEnd()
Acheron.DisableConsequence(false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
; Ally 2 cycle done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Player exhaustion
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
