Scriptname KudasaiMain extends Quest  

KudasaiMCM Property MCM Auto

Faction Property GuardFaction Auto
Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto
Message Property AssaultDefeated Auto
Message Property FrameMissing Auto

String Function HunterAssaultID() global
  return "YK_HunterAssault"
EndFunction

String Function HunterStripID() global
  return "YK_HunterStrip"
EndFunction

Function Maintenance()
  RegisterKeys()

  If(Game.GetModByName("SexLab.esm") == 255)
    MCM.iFrameSL = -1
    If(!KudasaiAnimation.OStimThere())
      FrameMissing.Show()
    EndIf
  Else
    MCM.iFrameSL = 1
  EndIf

  If (!KudasaiInternal.StruggleThere())
    MCM.bUseStruggle = false
    MCM.bUseStruggleCrt = false
  EndIf

  If(MCM.bHunterAssault && !Acheron.HasOption(HunterAssaultID()))
    AddHunterAssaultOption()
  EndIf
  If(MCM.bHunterStrip && !Acheron.HasOption(HunterStripID()))
    AddHunterStripOption()
  EndIf
  Acheron.RegisterForHunterPrideSelect(self)
EndFunction

Function RegisterKeys()
  UnregisterForAllKeys()
  If(MCM.iSurrenderKey > 0)
    RegisterForKey(MCM.iSurrenderKey) 
  EndIf
  If(MCM.iAssaultKey > 0)
    RegisterForKey(MCM.iAssaultKey)
  EndIf
  Debug.Trace("[Kudasai] Registering keys: " + MCM.iSurrenderKey + " | " + MCM.iAssaultKey)
EndFunction

Event OnKeyDown(int keyCode)
  If(Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled() || !Game.IsActivateControlsEnabled() || !Game.IsMovementControlsEnabled())
		return
  Else
    Actor Player = Game.GetPlayer()
    If(Acheron.IsDefeated(Player) || Player.IsDead())
      return
    EndIf
	EndIf
  If(keyCode == MCM.iAssaultKey)
    Debug.Trace("[Kudasai] Key press for assault")
    If(MCM.iAssaultKeyM == -1 || Input.IsKeyPressed(MCM.iAssaultKeyM))
      CreateAssault()
    EndIf
  EndIf
EndEvent

State KeyDown
  Event OnBeginState()
    RegisterForSingleUpdate(2)
  EndEvent
  Event OnUpdate()
    GoToState("")
  EndEvent
  Event OnKeyDown(int keyCode)
  EndEvent
EndState

Function CreateAssault()
  Actor ref = Game.GetCurrentCrosshairRef() as Actor
  If(!ref)
    return
  EndIf
  Actor Player = Game.GetPlayer()
  If(ref.IsBleedingOut() || Acheron.IsDefeated(ref))
    AssaultDefeated.Show()
    return
  ElseIf(ref.IsInCombat() || ref.IsDead())
    return
  EndIf

  AELStruggle struggle_api = AELStruggle.Get()
  String callbackevent = "Kudasai_StruggleResult_Assault"
  float lvDiff = ref.GetLevel() - Player.GetLevel()
  float guard = 1 + (ref.IsGuard() || ref.IsInFaction(GuardFaction)) as int
  float difficulty = (60.0 - lvDIff) / guard
  Debug.Trace("[Kudasai] Hotkey Assault; Setting difficulty to { " + difficulty + " } // lvDiff = " + lvDiff + "; Guard = " + guard)
  If(struggle_api.MakeStruggle(Player, ref, callbackevent, difficulty))
    RegisterForModEvent(callbackevent, "OnStruggleEnd")
    ref.SendAssaultAlarm()
  Else
    Debug.Trace("[Kudasai] Failed to create Struggle")
    Debug.Notification("Assault failed due to an unexpected error")
  EndIf
EndFunction

Event OnStruggleEnd(Form akVictim, Form akAggressor, bool abVictimEscaped)
  If(abVictimEscaped)
    Actor player = akAggressor as Actor
    float dmg = player.GetActorValue("Health") * 0.5
    player.DamageActorValue("Health", dmg)
  Else
    Acheron.DefeatActor(akVictim as Actor)
  EndIf
EndEvent

Function AddHunterAssaultOption()
  Acheron.AddOption(HunterAssaultID(), "$YK_AssaultOption", "YKudasai\\grab.dds")
EndFunction
Function AddHunterStripOption()
  Acheron.AddOption(HunterStripID(), "$YK_StripOption", "YKudasai\\clothes.dds")
EndFunction

Event OnHunterPrideSelect(int aiOptionID, Actor akTarget)
  If(aiOptionID == Acheron.GetOptionID(HunterAssaultID()))
    Actor[] positions = new Actor[2]
    positions[0] = akTarget
    positions[1] = Game.GetPlayer()
    If(KudasaiAnimation.CreateAssault(positions, akTarget, "KudasaiHunterAssault") == -1)
      Debug.Notification("Failed to create Scene")
      return
    EndIf
    akTarget.SendAssaultAlarm()
    RegisterForModEvent("ostim_end", "PostSceneOStim")
    RegisterForModEvent("HookAnimationEnd_KudasaiHunterAssault", "PostSceneSL")
  ElseIf(aiOptionID == Acheron.GetOptionID(HunterStripID()))
    Acheron.StripActor(akTarget)
  EndIf
EndEvent

Event PostSceneSL(int tid, bool hasPlayer)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  HandlePostScene(positions)
EndEvent
Event PostSceneOStim(string eventName, string strArg, float numArg, Form sender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(numArg as int)
  If(positions.Find(Game.GetPlayer()) > -1)
    HandlePostScene(positions)
  EndIf
EndEvent
Function HandlePostScene(Actor[] akPositions)
  Utility.Wait(0.3)
  int i = 0
  While(i < akPositions.Length)
    If(Acheron.IsDefeated(akPositions[i]))
      Debug.SendAnimationEvent(akPositions[i], "bleedoutStart")
    EndIf
    i += 1
  EndWhile
EndFunction
