Scriptname KudasaiMain extends Quest  

KudasaiMCM Property MCM Auto
KudasaiCaptures Property Captures Auto
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

  If(Kudasaiinternal.IsAlternateVersion())
    If(Game.GetModByName("SexLab.esm") == 255)
      MCM.iSLWeight = 0
    EndIf
    If(Game.GetModByName("OStim.esp") == 255)
      MCM.iOStimWeight = 0
    EndIf
  Else
    MCM.iSLWeight = 0
    MCM.iOStimWeight = 0
  EndIf
  MCM.SetPages()
EndFunction

Function RegisterKeys()
  UnregisterForAllKeys()
  RegisterForKey(MCM.iSurrenderKey)
  RegisterForKey(MCM.iHunterPrideKey)
  RegisterForKey(MCM.iAssaultKey)
  RegisterForKey(MCM.iCapturesKey)
EndFunction

Event OnKeyDown(int keyCode)
  If(Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled() || UI.IsMenuOpen("Dialogue Menu") || UI.IsMenuOpen("KudasaiQTE"))
		return
  Else
    Actor Player = Game.GetPlayer()
    If(Kudasai.IsDefeated(Player) || Player.IsDead())
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
  ElseIf(keyCode == MCM.iCapturesKey)
    ViewCaptures()
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
  ElseIf(ref.IsInCombat() || ref.IsDead() || UI.IsMenuOpen("KudasaiQTE"))
    return
  EndIf

  Actor[] positions = new Actor[2]
  positions[0] = ref
  positions[1] = Player
  String[] animations = new String[2]
  animations[0] = "KudasaiHumanStruggleA1S1"
  animations[1] = "KudasaiHumanStruggleA2S1"
  (Quest.GetQuest("Kudasai_Struggles") as KudasaiStruggle).CreateStruggleAnimationImpl(positions, 70, self, 0, animations)
  ref.SendAssaultAlarm()
EndFunction

Event OnFuture_c(Actor[] positions, int victory, String argStr)
  If(victory)
    KudasaiStruggle.EndStruggle(positions, true)
    float dmg = positions[1].GetActorValue("Health") * 0.5
    positions[1].DamageActorValue("Health", dmg)
  Else
    String[] anims = new String[2]
    anims[0] = "IdleForceDefaultState"
    anims[1] = "IdleForceDefaultState"
    KudasaiStruggle.EndStruggleCustom(positions, anims)
    Kudasai.DefeatActor(positions[0])
  EndIf
EndEvent

Function ViewCaptures()
  RegisterForModEvent("YKCaptures_Accept", "CapturesAccept")
  RegisterForModEvent("YKCaptures_Cancel", "CapturesCancel")
  Captures.OpenCapturesMenu()
EndFunction

Event CapturesAccept(string asEventName, string CapturesName, float aiCapturesIndex, form akSender)
  Debug.Trace("[Kudasai] Rescueing Actor = " + CapturesName)
  Captures.RescueActorByID(aiCapturesIndex as int, Game.GetPlayer())
EndEvent

Event CapturesCancel(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[Kudasai] Canceled Captures View")
EndEvent
