Scriptname KudasaiMain extends Quest  

KudasaiMCM Property MCM Auto

Perk Property InteractionPerk Auto

Quest Property SurrenderQuest Auto
Message Property SurrenderQFailure Auto

Spell Property HunterPride Auto
Message Property HunterPrideAdd Auto
Message Property HunterPrideRemove Auto

Message Property AssaultDefeated Auto

Function Maintenance()
  Game.GetPlayer().AddPerk(InteractionPerk)
  RegisterKeys()

  If(Game.GetModByName("SexLab.esm") == 255)
    MCM.iSLWeight = 0
  EndIf
  If(Game.GetModByName("OStim.esp") == 255)
    MCM.iOStimWeight = 0
  EndIf
  If(!MCM.FrameAny)
    MCM.bPostCombatAssault = false
  EndIf
EndFunction

Function RegisterKeys()
  UnregisterForAllKeys()
  RegisterForKey(MCM.iSurrenderKey)
  RegisterForKey(MCM.iHunterPrideKey)
  RegisterForKey(MCM.iAssaultKey)
EndFunction

Event OnKeyDown(int keyCode)
  If(Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Dialogue Menu"))
		return
  Else
    Actor Player = Game.GetPlayer()
    If(Kudasai.IsDefeated(Player) || Kudasai.IsStruggling(Player) || Player.IsDead())
      return
    EndIf
	EndIf
  If(keyCode == MCM.iSurrenderKey)
    If (!SurrenderQuest.Start())
      SurrenderQFailure.Show()
    EndIf
  ElseIf(keyCode == MCM.iHunterPrideKey)
    ToggleHunterPride()
  ElseIf(keyCode == MCM.iAssaultKey)
    CreateAssault()
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

Function ToggleHunterPride()
  Actor Player = Game.GetPlayer()
  If(Player.HasSpell(HunterPride))
    Player.RemoveSpell(HunterPride)
    HunterPrideRemove.Show()
  Else
    Player.AddSpell(HunterPride, false)
    HunterPrideAdd.Show()
  EndIf
EndFunction

Function CreateAssault()
  Actor ref = Game.GetCurrentCrosshairRef() as Actor
  If(!ref)
    return
  EndIf
  Actor Player = Game.GetPlayer()
  If(Kudasai.IsDefeated(ref))
    AssaultDefeated.Show()
    return
  ElseIf(ref.IsInCombat() || ref.IsDead() || Kudasai.IsStruggling(ref))
    return
  EndIf

  Kudasai.CreateStruggle(ref, Player, 0, self)
  ref.SendAssaultAlarm()
EndFunction

Event OnStruggleEnd_c(Actor[] positions, bool VictimWon)
  If(VictimWon)
    Kudasai.PlayBreakfree(positions)
    positions[0].SendAssaultAlarm()

    If(positions[1].GetActorValuePercentage("Health") > 0.2)
      float dmg = positions[1].GetActorValueMax("Health") * 0.2
      positions[1].DamageActorValue("Health", dmg)
    EndIf
  Else
    String[] anims = new String[2]
    anims[0] = "IdleForceDefaultState"
    anims[1] = "IdleForceDefaultState"
    Kudasai.PlayBreakfreeCustom(positions, anims)

    Kudasai.DefeatActor(positions[0])
  EndIf
EndEvent