;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname QF_Kudasai_rPlayer_05808E86 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Actor player = Game.GetPlayer()
If Kudasai.isdefeated(player)
  Kudasai.RescueActor(player, true)
Else
  Kudasai.UndoPacify(Game.GetPlayer())
EndIf

Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
Scene01.Start()
If(!Scene01.IsPlaying())
  Debug.Notification("Your tormentors seem to be busy. They might not realize if you make a run for it.")
  SetStage(100)
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
RegisterForSingleUpdate(3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
Kudasai.RescueActor(Game.GetPlayer(), false)

Alias_Player.RegisterForSingleUpdate(1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Event OnUpdate()
  SetStage(10)
EndEvent

Scene Property Scene01 Auto  
