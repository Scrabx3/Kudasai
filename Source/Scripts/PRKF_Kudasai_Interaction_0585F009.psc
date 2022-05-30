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
  ; Open Menu
  UI.OpenCustomMenu("YameteKudasaiHunterPride")
	int iHandle = UICallback.Create("CustomMenu", "_root.YamMenu.OpenMenu")
  If(!iHandle)
    Debug.MessageBox("Error opening Menu..")
    return
  EndIf
  UICallback.PushInt(iHandle, 1) ; Tie Up
  UICallback.PushInt(iHandle, (worn.Length > 0) as int) ; Strip
  UICallback.PushInt(iHandle, 1) ; Rob
  UICallback.PushInt(iHandle, (hPotion != none) as int) ; Rescue
  UICallback.PushInt(iHandle, PlayerRef.HasKeyword(Vampire) as int) ; Feed
  int ph
  If(Game.GetModByName("paradise_halls.esm") != 255)
    ph = 1
  Else
    ph = -1
  EndIf
  UICallback.PushInt(iHandle, ph) ; Paradise Halls
  UICallback.PushInt(iHandle, 1) ; Capture
  UICallback.PushInt(iHandle, MCM.FrameAny as int) ; Assault
  UICallback.PushInt(iHandle, 1) ; Execute
  UICallback.PushInt(iHandle, -1) ; Missing
  result = -2
  RegisterForModEvent("YamMenu_Accept", "MenuAccept")
  RegisterForModEvent("YamMenu_Cancel", "MenuCancel")
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
    Debug.MessageBox("--- TODO: ---\nThis means this is NOT YET IMPLEMENTED")
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
    Victim.EquipItem(hPotion, false, true)
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
  ; Debug.MessageBox("Returned = " + menu_id + " ( " + menu_name + " )")
  result = menu_id as int
EndEvent

Event MenuCancel(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[Kudasai] HUNTER PRIDE: Menu Cancel")
  ; Debug.MessageBox("Canceled")
  result = -1
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
