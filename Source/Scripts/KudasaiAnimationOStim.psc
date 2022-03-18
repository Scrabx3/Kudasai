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

int Function CreateAnimation(KudasaiMCM MCM, Actor prim, Actor[] secundi, Actor aggressor) global
  OSexIntegrationMain OStim = OUtils.GetOStim()
  If(secundi.length < 1)
    Debug.Trace("[Kudasai] No enough Actors", 1)
    return -1
  EndIf
  Actor Player = Game.GetPlayer()
	bool hasPlayer = (prim == Player || secundi.find(Player) > -1)
  Actor third = none
  If(secundi.length > 1)
    third = secundi[1]
  EndIf
  OStim.AddSceneMetadata("or_player_nocheat")
  OStim.AddSceneMetadata("or_npc_nocheat")

  If(hasPlayer)
    If(OStim.StartScene(secundi[0], prim, false, true, false, zThirdActor = third, aggressive = (aggressor != none), AggressingActor = aggressor))
      return 29
    EndIf
  Else
    OStimSubthread st = OStim.GetUnusedSubthread()
    float timer = Utility.RandomFloat(MCM.fOStimDurMin, MCM.fOStimDurMax)
    If(st.StartScene(secundi[0], prim, third, timer, isaggressive = (aggressor != none), AggressingActor = aggressor))
      return Math.Floor(timer)
    EndIf
  EndIf
  return -1
EndFunction

float Function GetArousal(Actor subject) global
  OArousedScript Aroused = OArousedScript.GetOAroused()
  return Aroused.getArousal(subject)
EndFunction

; if filter = true, remove the actors from the array
Function FilterArousal(Actor[] subjects) global
  KudasaiMCM MCM = KudasaiInternal.GetMCM()
  int i = 0
  While(i < subjects.Length)
    float arousal = GetArousal(subjects[i])
    If(subjects[i].IsPlayerTeammate())
      If (arousal < MCM.fArousalFollower)
        subjects = PapyrusUtil.RemoveActor(subjects, subjects[i])
      EndIf
    ElseIf(arousal < MCM.fArousalNPC)
      subjects = PapyrusUtil.RemoveActor(subjects, subjects[i])
    EndIf
    i += 1
  EndWhile
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
