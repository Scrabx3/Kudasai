;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF_Kudasai_rNPC_Quest_058130AF Extends Quest Hidden

;BEGIN ALIAS PROPERTY Victim00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim00 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire24
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire24 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire23
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire23 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire17
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire17 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire20
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire20 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire15
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire15 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire18
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire18 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire21
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire21 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire22
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire22 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire19
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire19 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire12
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire12 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire13
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire13 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire14
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire14 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire16
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire16 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire11
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire11 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
; called when setup completes
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN AUTOCAST TYPE KudasaiResolutionNPC
Quest __temp = self as Quest
KudasaiResolutionNPC kmyQuest = __temp as KudasaiResolutionNPC
;END AUTOCAST
;BEGIN CODE
kmyQuest.Init()
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
kmyQuest.CleanUp()

Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
