Scriptname KudasaiAnimationOStim Hidden

; Return true if the Actor participated in the given Scene (ID)
bool Function FindActor(Actor subject, int ID) global
  OSexIntegrationMain OStim = OUtils.GetOstim()
  If(ID == -1)
    return OStim.IsActorInvolved(subject)
  Else
    OStimSubthread st = OStim.GetSubthread(ID)
    If(st)
      return st.actorlist.find(subject) > -1
    EndIf
  EndIf
  return false
EndFunction

int Function CreateAnimation(Actor[] akPositions, Actor akVictim) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  OStim.AddSceneMetadata("or_player_nocheat")
  OStim.AddSceneMetadata("or_npc_nocheat")

  int w = -1
  If(akVictim)
    w = akPositions.Find(akVictim)
  EndIf
  Actor[] p = new Actor[3]
  If(w <= 0)
    p[0] = akPositions[0]
    p[1] = akPositions[1]
    p[1] = akPositions[2]
  ElseIf(w == 1)
    p[0] = akPositions[1]
    p[1] = akPositions[0]
    p[1] = akPositions[2]
  Else
    p[0] = akPositions[w]
    p[1] = akPositions[0]
    p[1] = akPositions[1]
  EndIf

  If(akPositions.Find(Game.GetPlayer()) > -1)
    If(OStim.StartScene(p[1], p[0], false, false, false, "", zThirdActor = p[2], aggressive = w > -1, AggressingActor = p[0]))
      return 29
    EndIf
  Else
    OStimSubthread st = OStim.GetUnusedSubthread()
    float timer = Utility.RandomFloat(30, 60)
    If(st.StartScene(p[1], p[0], p[2], timer, isaggressive = w > -1, AggressingActor = p[0]))
      return Math.Floor(timer)
    EndIf
  EndIf
  return -1
EndFunction

OStimSubthread Function GetSubthreadFromActor(Actor subject) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  Quest sq = OStim.subthreadquest
  Alias[] aliases = sq.GetAliases()
  int i = 0
	While (i < aliases.Length) 
		OStimSubthread thread = aliases[i] as OStimSubthread
    if (thread.actorlist.find(subject) > -1)
      return thread
    endif
		i += 1
	EndWhile
  return none
EndFunction

bool Function StopAnimating(Actor subject) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  If (!Ostim.isactoractive(subject))
    return false
  ElseIf (Ostim.IsActorInvolved(subject))
    OStim.EndAnimation()
    return true
  Else
    OStimSubthread thread = GetSubthreadFromActor(subject)
    if (thread)
      thread.EndAnimation()
      return true
    endif
  EndIf
  return false
EndFunction

Actor[] Function GetPositions(int id) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  If (id == -1)
    return OStim.GetActors()
  Else
    OStimSubthread thread = OStim.GetSubthread(id)
    return thread.actorlist
  EndIf
  return PapyrusUtil.ActorArray(0)
EndFunction

bool Function IsAnimating(Actor subject) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  return OStim.IsActorActive(subject)
EndFunction
