Scriptname KudasaiAssaultPacify extends activemagiceffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If (akTarget.IsPlayerTeammate() || !akTarget.IsHostileToActor(Game.GetPlayer()))
    Debug.SendAnimationEvent(akTarget, "KudasaiSurrender")
  EndIf
	akCaster.StopCombat()
	akTarget.StopCombat()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
EndEvent
