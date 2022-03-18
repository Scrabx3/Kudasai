Scriptname Kudasai Hidden
{Native API for Yamete Kudasai}
; NOTE: Unless stated otherwise, passing none will likely crash your game

; ================================ Defeat
; A defeated Actor is bleeding out and immune to damage
; A defeated Actor is always pacified
; A pacified Actor is ignoring & ignored by Combat
; All defeated Actors carry the "Kudasai_Defeated" Keyword
; All pacified Actors carry the "Kudasai_Pacified" Keyword
Function DefeatActor(Actor subject) native global
Function RescueActor(Actor subject, bool undo_pacify) native global
Function PacifyActor(Actor subject) native global
Function UndoPacify(Actor subject) native global
bool Function IsDefeated(Actor subject) native global
bool Function IsPacified(Actor subject) native global

; ================================ Actor
; Setting 'target' to 'none' unsets the Link
Function SetLinkedRef(ObjectReference object, ObjectReference target, Keyword link = none) native global

; ================================ Config
bool Function ValidCreature(Actor subject) native global
bool Function IsInterrested(Actor subject, Actor[] partners) native global

; ================================ Utility
Function ExcludeActor(Actor subject) native global
Function IncludeActor(Actor subject) native global
bool Function IsExcluded(Actor subject) native global

Armor[] Function GetWornArmor(Actor subject) native global
