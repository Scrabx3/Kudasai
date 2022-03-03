Scriptname Kudasai Hidden
{Native API for Yamete Kudasai!}
; NOTE: I dont do defensive programming. Passing none to any of those functions will crash your game unless specified that none is acceptable

; animation = false -> pacifies them
Function DefeatActor(Actor subject, bool animation) global native

; un-pacify them and pull them out of the bleedout, if they are bleeding out
; returns false if the actor was not pacified
bool Function RestoreActor(Actor subject, bool rescue) global native

; pacified = defeated but not in bleedout
bool Function IsPacified(Actor subject) global native

; pacified + in bleedout state
bool Function IsDefeated(Actor subject) global
  Package p = Game.GetFormFromFile(0x7802E8, "YKudasai.esp") as Package
  return IsPacified(subject) && (subject == Game.GetPlayer() || subject.GetCurrentPackage() == p)
EndFunction

; Return allcurrently worn armor. Respects DD, Toys, SL No Strip keywords
Armor[] Function GetWornArmor(Actor subject) global native

; If the Creature is allowed for intercourse as by the players config.yaml
bool Function ValidCreature(Actor subject) global native

; ################ Papyrus Utility
; Remove the n'th position in the given array
Function ActorRemoveAt(Actor[] array, int pos) global native
; Insert a new actor at the n'th position, existing actors will be pushed back once
Function ActorInsertAt(Actor[] array, Actor insert, int pos) global native
; Insert a new actor at the very end of the array
Function ActorPushBack(Actor[] array, Actor insert) global native
; Insert a new actor at the very beginning of the array, existing actors will be pushed back
Function ActorPushFront(Actor[] array, Actor insert) global native
