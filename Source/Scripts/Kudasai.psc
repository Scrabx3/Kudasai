Scriptname Kudasai Hidden
{Native API for Yamete Kudasai}

; Disable/Enable hit processing, including protection of defeated victims
Function DisableProcessing(bool abDisable) native global
bool Function IsProcessingDisabled() native global
; Disable/Enable Consequence selection, including Blackout Events
Function DisableConsequence(bool abDisable) native global
bool Function IsConsequenceDisabled() native global

; ================================ Defeat
; A defeated Actor is bleeding out and immune to damage
; A defeated Actor is always pacified
; A pacified Actor is ignoring & ignored by Combat
; All defeated Actors carry the "Kudasai_Defeated" Keyword
; All pacified Actors carry the "Kudasai_Pacified" Keyword
Function DefeatActor(Actor akActor, bool abSkipAnimation = false) native global
Function RescueActor(Actor akActor, bool abUndoPacify, bool abSkipAnimation = false) native global
Function PacifyActor(Actor akActor) native global
Function UndoPacify(Actor akActor) native global
bool Function IsDefeated(Actor akActor) native global
bool Function IsPacified(Actor akActor) native global

; Return all currently defeated Actors
Actor[] Function GetDefeated() native global

; Invoked whenever an Actor is defeated
Function RegisterForActorDefeated(Form akForm) native global
Function UnregisterForActorDefeated(Form akForm) native global
Function RegisterForActorDefeated_Alias(ReferenceAlias akAlias) native global
Function UnregisterForActorDefeated_Alias(ReferenceAlias akAlias) native global
Function RegisterForActorDefeated_MgEff(ActiveMagicEffect akEffect) native global
Function UnregisterForActorDefeated_MgEff(ActiveMagicEffect akEffect) native global
Event OnActorDefeated(Actor akVictim)
EndEvent

; Invoked whenever an Actor is rescued
Function RegisterForActorRescued(Form akForm) native global
Function UnregisterForActorRescued(Form akForm) native global
Function RegisterForActorRescued_Alias(ReferenceAlias akAlias) native global
Function UnregisterForActorRescued_Alias(ReferenceAlias akAlias) native global
Function RegisterForActorRescued_MgEff(ActiveMagicEffect akEffect) native global
Function UnregisterForActorRescued_MgEff(ActiveMagicEffect akEffect) native global
Event OnActorRescued(Actor akVictim)
EndEvent

; ================================ ObjectReference
; Link source to target with the given keyword. Setting 'target' to 'none' unsets the Link
Function SetLinkedRef(ObjectReference akSource, ObjectReference akTarget, Keyword akLink = none) native global
; Similar to ObjectRef.RemoveAll but will always skip quest items & can be set to ignore worn armor
Function RemoveAllItems(ObjectReference akTransferFrom, ObjectReference akTransferTo, bool abExcludeWorn = true) native global

; ================================ Actor
; ignore_config: true returns all worn armor, false excludes the slots the player doesn't want to be stripped
Armor[] Function GetWornArmor(Actor akActor) native global
; Get the most efficien Potion (= the Potion which gets the Hp closest to max) for this subject from the given container
; The function recognizes all Healing Potions in the container inventory which are pure beneficial
Potion Function GetMostEfficientPotion(Actor akActor, ObjectReference akContainer) native global
; Get the Template ActorBase of this Actor, none if the Actor isnt leveled
ActorBase Function GetTemplateBase(Actor akActor) native global
; Return this actors RaceKey. Returns an empty string if the Actors race isnt recognized
String Function GetRaceKey(Actor akActor) native global
; Return all of the Players current Followers
Actor[] Function GetFollowers() native global

; ================================ Utility
; Remove all Entries in the Array which have the specified Keyword
Function RemoveArmorByKeyword(Armor[] akArray, Keyword akFilter) native global
; Create a Future object which sends the passed in value to the callback Form after <duration> seconds have passed
; Use "OnFuture_c" to receive the passed values. You do not need to register for this Event
Function CreateFuture(float afDuration, Form akCallback, Actor[] argActor, int argNum = 0, string argStr = "") native global
Event OnFuture_c(Actor[] argActor, int argNum, string argStr)  
EndEvent
; Sort the given Array based on distance to center
Function SortByDistance(Actor[] akArray, ObjectReference akCenter) native global
Function SortByDistanceRef(ObjectReference[] akArray, ObjectReference akCenter) native global

; ================================ Config
; Checks if the Actors racekey is excluded
bool Function ValidRace(Actor akActor) native global
; Check if Actor is valid based on their 'sexuality', ie if 'partner' is interested in 'subject'. Subject preference is ignored
bool Function IsInterested(Actor akActor, Actor akPartner) native global

; ================================ Interface
; Create a QTE Game with the specified difficulty
; --- Param
; difficulty: The average time the Player has to react -> Avg.Time = Sqrt(Difficulty)/4
;             The actual time is randomized and will go up or down by 30% with each individual event
;             A balanced difficulty would be 60~70, below 30 becomes impossibly difficult
; callback: A callback form to send the result of the Struggle to (OnQTEEnd_c). You do not have to register for this Event
; --- Return
; If the QTE successfully started
bool Function OpenQTEMenu(int aiDifficulty, Form callback) native global
Event OnQTEEnd_c(bool abVictory)
EndEvent
; Forcefully close/stop the QTE Event, invoking the callback. This is treated as the player losing the game
Function CloseQTEMenu() native global
