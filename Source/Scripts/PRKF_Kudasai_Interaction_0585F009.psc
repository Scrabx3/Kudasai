;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname PRKF_Kudasai_Interaction_0585F009 Extends Perk Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
Actor victim = akTargetRef as Actor
If(!victim)
  return
EndIf
OpenMenu(victim)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

int result

Function OpenMenu(Actor victim)
  Actor PlayerRef = Game.GetPlayer()
  ; Validate Menu Options
  Armor[] worn = KudasaiInternal.GetWornArmor_Filtered(victim)
  Potion hPotion = Kudasai.GetMostEfficientPotion(victim, PlayerRef)
  Debug.Trace("[Kudasai] Robbing, Worn Armor = " + worn)
  Debug.Trace("[Kudasai] Rescue, Potion = " + hPotion)
  result = -2
  RegisterForModEvent("YamMenu_Accept", "MenuAccept")
  RegisterForModEvent("YamMenu_Cancel", "MenuCancel")
  ; Prepare Args
  int[] args = new int[11]
  args[0] = 1 ; Tie Up
  args[1] = (worn.Length > 0) as int ; Strip
  args[2] = 1 ; Rob
  args[3] = (hPotion != none) as int ; Rescue
  args[4] = PlayerRef.HasKeyword(Vampire) as int ; Feed
  If(Game.GetModByName("paradise_halls.esm") != 255)
    args[5] = 1
  Else
    args[5] = -1
  EndIf
  args[6] = 1 ; Capture
  args[7] = MCM.FrameAny as int
  args[8] = 1 ; Execute
  args[9] = -1 ; Nothin yet
  args[10] = Kudasaiinternal.IsAlternateVersion() as int
  ; Open Menu
  UI.OpenCustomMenu("YameteKudasaiHunterPride")
	int iHandle = UICallback.Create("CustomMenu", "_root.YamMenu.OpenMenu")
  If(!iHandle)
    Debug.MessageBox("Error opening Menu..")
    return
  EndIf
  int n = 0
  While(n < args.Length)
    UICallback.PushInt(iHandle, args[n])
    n += 1
  EndWhile
  ; KudasaiInternal.OpenHunterPrideMenu(1, (worn.Length > 0) as int, 1, (hPotion != none) as int,  PlayerRef.HasKeyword(Vampire) as int, ph, 1, MCM.FrameAny as int, 1, -1)
  UICallback.Send(iHandle)
  ; Wait for Result..
  While(result == -2)
    Utility.Wait(0.1)
  EndWhile
  ;/
  - Tie Up
  - Strip
  - Rob
  - Rescue
  - Feed (Kill Drain) (Vampire only)

  - Paradise Halls
  - Capture
  - Assault
  - Execute
  - Nothing
  /;
  If(result == 0)
    ; Debug.MessageBox(" --- TODO: ---\n\nTHIS MEANS THIS IS NOT YET IMPLEMENTED")
    DoTieUp(victim)
  ElseIf(result == 1)
    int i = 0
    While(i < worn.Length)
      victim.UnequipItem(worn[i])
      i += 1
    EndWhile
  ElseIf(result == 2)
    Victim.OpenInventory(true)
    Victim.SendAssaultAlarm()
  ElseIf(result == 3)
    PlayerRef.RemoveItem(hPotion, 1, true, Victim)
    victim.EquipItem(hPotion, false, true)
    Utility.Wait(0.2)
    If(Kudasai.IsDefeated(victim))
      victim.PlaceAtMe(HealTargetFX)
      victim.RestoreActorValue("Health", 25.0)
      Kudasai.RescueActor(victim, true)
    EndIf
  ElseIf(result == 4)
    If(IsEssential(Victim))
      return
    EndIf
    PlayerRef.StartVampireFeed(Victim)
    PlayerVampireQuest.VampireFeed()
    Victim.Kill(PlayerRef)
  ElseIf(result == 5)
    KudasaiParadiseHalls.ParadaiseHallsEnslave(victim)
  ElseIf(result == 6)
    Captures.Store(Victim)
  ElseIf(result == 7)
    Actor[] positions = new Actor[1]
    positions[0] = PlayerRef
    If(KudasaiAnimation.CreateAssault(Victim, positions, "KudasaiHunterAssault") == -1)
      Debug.Notification("Failed to create Scene")
      return
    EndIf
    Victim.SendAssaultAlarm()
    RegisterForModEvent("ostim_end", "PostSceneOStim")
    RegisterForModEvent("HookAnimationEnd_KudasaiHunterAssault", "PostSceneSL")
  ElseIf(result == 8)
    If(IsEssential(Victim))
      return
    EndIf
    ; TODO: Add Animation
    Victim.Kill(Game.GetPlayer())
  ElseIf(result == 9)
    Debug.MessageBox("No Option here...")
  EndIf
EndFunction


Event MenuAccept(string asEventName, string menu_name, float menu_id, form akSender)
  Debug.Trace("[Kudasai] HUNTER PRIDE: Menu Acceot with Option = " + menu_name)
  result = menu_id as int
EndEvent
Event MenuCancel(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[Kudasai] HUNTER PRIDE: Menu Cancel")
  result = -1
EndEvent


Function DoTieUp(Actor victim)
  String[] options = new String[14]
  options[0] = "Sit: Relaxed"
  options[1] = "Sit"
  options[2] = "Lying: Face down"
  options[3] = "Lying: Sideway, Relaxed"
  options[4] = "Lying: Sideway"
  options[5] = "Lying: Face up"
  options[6] = "Hogtie: Relaxed"
  options[7] = "Hogtie: legs open"
  options[8] = "Hogtie: legs closed "
  options[9] = "Captive"
  options[10] = "Captive: Legs closed"
  options[11] = "Captive: Legs open"
  options[12] = "Captive: Relaxed"
  options[13] = "Reset"
  String[] animevents = new String[14]
  animevents[0] = "KudasaiAPC006" ; Sit, Relaxed
  animevents[1] = "KudasaiAPC008" ; Sit
  animevents[2] = "KudasaiAPC011" ; Face down
  animevents[3] = "KudasaiAPC012" ; Sideway, Relaxed
  animevents[4] = "KudasaiAPC014" ; Sideway
  animevents[5] = "KudasaiAPC013" ; Face up
  animevents[6] = "KudasaiAPC015" ; Hogtie, Relaxed
  animevents[7] = "KudasaiAPC056" ; Hogtie, legs open
  animevents[8] = "KudasaiAPC057" ; Hogtie, legs closed 
  animevents[9] = "KudasaiAPC016" ; Captive
  animevents[10] = "KudasaiAPC018" ; Captive, Legs closed
  animevents[11] = "KudasaiAPC019" ; Captive, Legs open
  animevents[12] = "KudasaiAPC058" ; Captive, Relaxed
  animevents[13] = "BleedoutStart"
  RegisterForModEvent("YKSelect_Accept", "SelectAccept")
  RegisterForModEvent("YKSelect_Cancel", "SelectCancel")
  result = -3
  While(UI.IsMenuOpen("CustomMenu"))
    Utility.Wait(0.05)
  EndWhile
  UI.OpenCustomMenu("YameteKudasaiSelect")
  UI.InvokeStringA("CustomMenu", "_root.main.OpenMenu", options)
  While(result == -3)
    Utility.Wait(0.05)
  EndWhile
  If(result == -1)
    return
  EndIf
  FadeToBlackAndBackFastImod.Apply()
  Utility.Wait(0.5)
  Debug.SendAnimationEvent(victim, animevents[result])
  If(result == 13)
    RemoveAllRestraints(victim)
  Else
    EquipRestraint(victim, RopeWrist)
    EquipRestraint(victim, RopeWElbow)
    If(result == 6 || result == 7 || result == 8)
      EquipRestraint(victim, RopeAnkle)
    Else
      RemoveRestraint(victim, RopeAnkle)
    EndIf
  EndIf
EndFunction

Event SelectAccept(string asEventName, string optionname, float optionindex, form akSender)
  Debug.Trace("[Kudasai] Selection Menu Accept -> Option = " + optionname)
  result = optionindex as int
  UnregisterForModEvent(asEventName)
EndEvent
Event SelectCancel(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[Kudasai] Selection Menu Cancel")
  result = -1
  UnregisterForModEvent(asEventName)
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
Function HandlePostScene(Actor[] positions)
  Utility.Wait(0.3)
  int i = 0
  While(i < positions.Length)
    If(Kudasai.isdefeated(positions[i]))
      Debug.SendAnimationEvent(positions[i], "bleedoutStart")
    EndIf
    i += 1
  EndWhile
EndFunction

Function EquipRestraint(Actor victim, Armor restraint)
  If(victim.IsEquipped(restraint))
    return
  ElseIf(victim.GetItemCount(restraint) == 0)
    victim.AddItem(restraint, 1, true)
  EndIf
  victim.EquipItem(restraint, false, true)
EndFunction
Function RemoveRestraint(Actor victim, Armor restraint)
  If(victim.IsEquipped(restraint))
    victim.UnequipItem(restraint, false, true)
    victim.RemoveItem(restraint, 1, true)
  ElseIf(victim.GetItemCount(restraint) > 0)
    victim.RemoveItem(restraint, victim.GetItemCount(restraint), true)
  EndIf
EndFunction
Function RemoveAllRestraints(Actor victim)
  RemoveRestraint(victim, RopeWrist)
  RemoveRestraint(victim, RopeWElbow)
  RemoveRestraint(victim, RopeAnkle)
EndFunction

bool Function IsEssential(Actor Victim)
  ActorBase base = Victim.GetLeveledActorBase()
  If(!base.IsEssential())
    return false
  EndIf
  If(EssentialConformation.Show() == 1)
    base.SetEssential(false)
    return false
  EndIf
  return true
EndFunction

Keyword Property Vampire Auto

KudasaiMCM Property MCM Auto

PlayerVampireQuestScript Property PlayerVampireQuest  Auto  

Message Property EssentialConformation  Auto

KudasaiCaptures Property Captures  Auto

ImageSpaceModifier Property FadeToBlackAndBackFastImod Auto

Armor Property RopeWrist Auto

Armor Property RopeWElbow Auto

Armor Property RopeAnkle Auto

Activator Property HealTargetFX Auto
