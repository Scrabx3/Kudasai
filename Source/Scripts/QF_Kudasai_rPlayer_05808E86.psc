;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 7
Scriptname QF_Kudasai_rPlayer_05808E86 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Sec01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sec01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EnemyAny
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EnemyAny Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy18
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy18 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ter01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ter01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy14
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy14 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy19
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy19 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ter05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ter05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy17
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy17 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ter04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ter04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Sec06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sec06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy15
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy15 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EnemyNPC
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EnemyNPC Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy11
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy11 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ter03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ter03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Sec04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sec04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ter02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ter02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Sec05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sec05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy13
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy13 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Sec02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sec02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy16
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy16 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy20
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy20 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy12
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy12 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ter06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ter06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Sec03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sec03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy07 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE KudasaiRPlayer
Quest __temp = self as Quest
KudasaiRPlayer kmyQuest = __temp as KudasaiRPlayer
;END AUTOCAST
;BEGIN CODE
; Loop end 2
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE KudasaiRPlayer
Quest __temp = self as Quest
KudasaiRPlayer kmyQuest = __temp as KudasaiRPlayer
;END AUTOCAST
;BEGIN CODE
kmyQuest.ForceStopScenes()

Actor player = Game.GetPlayer()
If(Kudasai.isdefeated(player))
  Kudasai.RescueActor(player, true)
ElseIf(Kudasai.IsPacified(player))
  Kudasai.UndoPacify(player)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Quest is started through cpp

; by the time Scene01 is started the game didnt pull out the victoires out of combat yet
; have to delay this a bit

RegisterForSingleUpdate(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN AUTOCAST TYPE KudasaiRPlayer
Quest __temp = self as Quest
KudasaiRPlayer kmyQuest = __temp as KudasaiRPlayer
;END AUTOCAST
;BEGIN CODE
; Loop end 3
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN AUTOCAST TYPE KudasaiRPlayer
Quest __temp = self as Quest
KudasaiRPlayer kmyQuest = __temp as KudasaiRPlayer
;END AUTOCAST
;BEGIN CODE
; First Loop Complete
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

