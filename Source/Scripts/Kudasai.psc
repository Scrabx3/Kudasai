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
Function SetLinkedRef(ObjectReference source, ObjectReference target, Keyword link = none) native global
; Similar to ObjectRef.RemoveAll but will always skip quest items & can be set to ignore worn armor
Function RemoveAllItems(ObjectReference from, ObjectReference to, bool excludeworn = true) native global

; ================================ Actor
; ignore_config: if Kudasais MCM settings should be ignored, i.e. true respects user preference, false returns all worn armor
Armor[] Function GetWornArmor(Actor subject, bool ignore_config) native global

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
bool Function CreateStruggle(Actor victim, Actor aggressor, int difficulty, Form callback) native global
Event OnStruggleEnd_c(Actor[] positions, bool VictimWon)
EndEvent
; Those are callback functions which will cleanup the struggle. A Struggle (incl its Animation) will continue even after the Callback until a Breakfree is called
; It is your responsibility to clean up the Struggle by calling one of these. Not doing so results in participating Actors becomming soft locked
; -----------------------------
; Play a Breakfree Animation for the passed in Actors, cleaning up the Struggle. Only call after the Callback has been invoked
; The animation will be picked from the Breakfree List in Struggle.yaml and assume the Victim of the Struggle to be victorious
; Custom will play the passed in animations instead, it is expected that (positions.Length == animations.Length) holds
Function PlayBreakfree(Actor[] positions) native global
Function PlayBreakfreeCustom(Actor[] positions, String[] animations) native global
; -----------------------------

; return true if the actor is in an active struggle, false otherwise. A struggle which had its callback invoked before is considered inactive
bool Function IsStruggling(Actor subject) native global
; Forcefully end the Struggle early (Manually invoking the callback), without stopping the animation
; return true on success or when the struggle already completed, false if the passed actor isnt struggling
bool Function StopStruggle(Actor victoire) native global
bool Function StopStruggleReverse(Actor defeated) native global

; ================================ Utility
Function ExcludeActor(Actor subject) native global
Function IncludeActor(Actor subject) native global
bool Function IsExcluded(Actor subject) native global

