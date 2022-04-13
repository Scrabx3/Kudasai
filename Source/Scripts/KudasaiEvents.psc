ScriptName KudasaiEvents Hidden
{ API Script to Register Event Listeners }

; ----------------------------
; Invoked whenever an Actor is defeated
Function RegisterForActorDefeated(Form akForm) native global
Function UnregisterForActorDefeated(Form akForm) native global
Function RegisterForActorDefeated_Alias(ActiveMagicEffect akEffect) native global
Function UnregisterForActorDefeated_Alias(ActiveMagicEffect akEffect) native global
Function RegisterForActorDefeated_MgEff(ReferenceAlias akAlias) native global
Function UnregisterForActorDefeated_MgEff(ReferenceAlias akAlias) native global

Event OnActorDefeated(Actor akVictim)
EndEvent

; ----------------------------
; Invoked whenever an Actor is rescued ('healed' from Defeat)
Function RegisterForActorRescued(Form akForm) native global
Function UnregisterForActorRescued(Form akForm) native global
Function RegisterForActorRescued_Alias(ActiveMagicEffect akEffect) native global
Function UnregisterForActorRescued_Alias(ActiveMagicEffect akEffect) native global
Function RegisterForActorRescued_MgEff(ReferenceAlias akAlias) native global
Function UnregisterForActorRescued_MgEff(ReferenceAlias akAlias) native global

Event OnActorRescued(Actor akVictim)
EndEvent