Scriptname Kudasai Hidden
{Native API for Yamete Kudasai}

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
Function SetLinkedRef(ObjectReference source, ObjectReference target, Keyword link = none) native global
; Similar to ObjectRef.RemoveAll but will always skip quest items & can be set to ignore worn armor
Function RemoveAllItems(ObjectReference from, ObjectReference to, bool excludeworn = true) native global

; ================================ Actor
; ignore_config: true returns all worn armor, false respects user preference (MCM)
Armor[] Function GetWornArmor(Actor subject, bool ignore_config) native global
; Get the most efficien Potion (= the Potion which gets the Hp closest to max) for this subject from the given container
; The function recognizes all Healing Potions in the container inventory which are pure beneficial
Potion Function GetMostEfficientPotion(Actor subject, ObjectReference container) native global
; Get the Template ActorBase of this Actor
ActorBase Function GetTemplateBase(Actor akActor) native global

; ================================ Config
; Checks for the subjects RaceKey. Always returns true for NPC
bool Function ValidRace(Actor subject) native global
; Check if Actor is valid based on their 'sexuality', ie if 'partner' is interested in 'subject'. Subject preference is ignored
bool Function IsInterested(Actor subject, Actor partner) native global

; ================================ Struggling
; Create a Struggle Animation with the given Actors. Animations are taken from "Struggle.yaml"
; 'difficulty': - NPC: Chance for the Victim to succeed
;               - Player: Range from 0 ~ 3: Easy/Normal/Hard/Legendary
; 'callback': A Form to send the below Event to. You do not need to register for this Event
; return true if the Struggle started successfully, false otherwise. See YameteKudasai.log or Console for failure reason
bool Function CreateStruggle(Actor victim, Actor aggressor, int difficulty, Form callback = none) native global
Event OnStruggleEnd_c(Actor[] positions, bool VictimWon)
EndEvent

; return true if the actor is in an active struggle, false otherwise. A struggle which had its callback invoked before is considered inactive
bool Function IsStruggling(Actor subject) native global
; Forcefully end the Struggle early (Manually invoking the callback)
; return true on success or when the struggle is already completed, false if the passed actor isnt struggling
bool Function StopStruggle(Actor victoire) native global
bool Function StopStruggleReverse(Actor defeated) native global

; ================================ Utility
; Remove all Entries in the Array which have the specified Keyword. Array positions may contain none
Function RemoveArmorByKeyword(Armor[] array, Keyword filter) native global

Function ExcludeActor(Actor subject) native global
Function IncludeActor(Actor subject) native global
bool Function IsExcluded(Actor subject) native global

