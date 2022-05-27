;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname QF_Kudasai_ToMapEdge_0588C931 Extends Quest Hidden

;BEGIN ALIAS PROPERTY currentHold
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_currentHold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FallbackMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FallbackMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EdgeMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EdgeMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MapMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MapMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY OutsideMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_OutsideMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EdgeMarkerHold
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EdgeMarkerHold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY OutsideMarkerHold
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_OutsideMarkerHold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY currentLoc
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_currentLoc Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
; Quest will throw the Player to some random cell near their current Position (entrance if dungeon)
; .. and close itself afterwards
RegisterForSingleUpdate(5)
FadeToBlackImod.Apply()
Utility.Wait(2)

ObjectReference player = Alias_Player.GetReference()
If(player.IsInInterior())
  If(PortIfPossible(Alias_OutsideMarker))
    return
  EndIf
  If(PortIfPossible(Alias_OutsideMarkerHold))
    return
  EndIf
  If(PortIfPossible(Alias_EdgeMarkerHold))
    return
  EndIf
Else
  If(PortIfPossible(Alias_EdgeMarkerHold))
    return
  EndIf
  If(PortIfPossible(Alias_EdgeMarker))
    return
  EndIf
  If(PortIfPossible(Alias_OutsideMarkerHold))
    return
  EndIf
EndIf

; Fallback if not returned
If(PortIfPossible(Alias_FallbackMarker))
  return
EndIf

Debug.Messagebox("[Kudasai] Failed to find valid porting Location")
Debug.Trace("[Kudasai] < ToMapEdge > Failed to find a valid porting Location", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Actor player = Alias_Player.GetReference() as Actor
If(Kudasai.IsDefeated(player))
  Kudasai.RescueActor(player, false)
  Utility.Wait(3)
  Kudasai.UndoPacify(player)
ElseIf(Kudasai.IsPacified(player))
  Kudasai.UndoPacify(player)
  Debug.SendAnimationEvent(player, "ForceDefaultState")
EndIf

Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

bool Function PortIfPossible(ReferenceAlias ref)
  ObjectReference player = Alias_Player.GetReference()
  ObjectReference marker = ref.GetReference()
  If (marker)
    player.MoveTo(marker)
    return true
  EndIf
  return false
EndFunction

Event OnUpdate()
  SetStage(25)
EndEvent

ImageSpaceModifier Property FadeToBlackImod  Auto  
