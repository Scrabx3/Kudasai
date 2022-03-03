Scriptname Kudasai Hidden
{Native API for Yamete Kudasai!}
; NOTE: Unless stated otherwise, passing none will likely crash your game

; ================================ Defeat
; A defeated Actor is (intended to be) bleeding out and immune to damage
; A pacified Actor is ignored by Combat
; A defeated Actor is also always pacified
; All defeated Actors carry the "Kudasai_Defeated" Keyword
; All pacified Actors carry the "Kudasai_Pacified" Keyword
Function DefeatActor(Actor subject) global native
Function RescueActor(Actor subject, bool undo_pacify) global native
Function PacifyActor(Actor subject) global native
Function UndoPacify(Actor subject) global native
bool Function IsDefeated(Actor subject) global native
bool Function IsPacified(Actor subject) global native

; ================================ Config
bool Function ValidCreature(Actor subject) global native
bool Function IsInterrested(Actor subject, Actor[] partners) global native

; ================================ Utility
Armor[] Function GetWornArmor(Actor subject) global native

