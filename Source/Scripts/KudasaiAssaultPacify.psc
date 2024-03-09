Scriptname KudasaiAssaultPacify extends activemagiceffect  

Faction Property AssaultQFaction Auto
Faction Property FriendFaction2 Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(akTarget.IsInFaction(AssaultQFaction))
    akTarget.StopCombat()
    akCaster.StopCombat()
    return
  EndIf
  bool hostile = akTarget.IsHostileToActor(akCaster)
  akTarget.AddToFaction(FriendFaction2)
	akTarget.StopCombat()
	akCaster.StopCombat()
  If (akTarget.IsPlayerTeammate())
    Debug.SendAnimationEvent(akTarget, "KudasaiSurrender")
    akTarget.SetDontMove(true)
  ElseIf (!hostile)
    Debug.SendAnimationEvent(akTarget, "KudasaiSurrender")
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  akTarget.RemoveFromFaction(FriendFaction2)
  If (akTarget.IsPlayerTeammate())
    akTarget.SetDontMove(false)
  EndIf
EndEvent
