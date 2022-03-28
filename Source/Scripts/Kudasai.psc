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

; ================================ ObjectReference
; Setting 'target' to 'none' unsets the Link
Function SetLinkedRef(ObjectReference object, ObjectReference target, Keyword link = none) native global

; ================================ Actor
; Similar to ObjectRef.RemoveAll but will always skip quest items & can be set to ignore worn armor or items below a certain value
; if 'to' is 'none', the items will be deleted instead of transfered
Function RemoveAllItems(Actor from, ObjectReference to, bool excludeworn = true, int minvalue = 0) native global
Armor[] Function GetWornArmor(Actor subject, bool ignoreconfig) native global

; ================================ Config
; Checks for the subjects RaceKey. Always returns true for NPC
bool Function ValidRace(Actor subject) native global
bool Function IsInterrested(Actor subject, Actor[] partners) native global

; ================================ Utility
Function ExcludeActor(Actor subject) native global
Function IncludeActor(Actor subject) native global
bool Function IsExcluded(Actor subject) native global

