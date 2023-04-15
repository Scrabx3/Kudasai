Scriptname KudasaiMain extends Quest  

KudasaiMCM Property MCM Auto

Faction Property GuardFaction Auto
Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto
Message Property AssaultDefeated Auto

Function Maintenance()
  RegisterKeys()

  If(Game.GetModByName("SexLab.esm") == 255)
    MCM.iFrameSL = -1
  ElseIf(MCM.iFrameSL == -1)
    MCM.iFrameSL = 50
  EndIf
EndFunction

Function RegisterKeys()
  UnregisterForAllKeys()
  RegisterForKey(MCM.iSurrenderKey)
  RegisterForKey(MCM.iAssaultKey)
EndFunction

Event OnKeyDown(int keyCode)
  If(Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Dialogue Menu"))
		return
  Else
    Actor Player = Game.GetPlayer()
    If(Acheron.IsDefeated(Player) || Player.IsDead())
      return
    EndIf
	EndIf
  If(keyCode == MCM.iSurrenderKey)
    If(MCM.iSurrenderKeyM == -1 || Input.IsKeyPressed(MCM.iSurrenderKeyM))
      If (!SurrenderQuest.Start())
        SurrenderQFailure.Show()
      EndIf
    EndIf
  ElseIf(keyCode == MCM.iAssaultKey)
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
  If(Acheron.IsDefeated(ref))
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
