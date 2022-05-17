;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname PRKF_Kudasai_Interaction_0585F009 Extends Perk Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
Actor v = akTargetRef as Actor
If(!v)
  return
EndIf
OpenMenu(v)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property MenuTEMP Auto

Function OpenMenu(Actor victim)
  Actor PlayerRef = Game.GetPlayer()
  ; Validate Worn Items
  Armor[] worn = Kudasai.GetWornArmor(Victim, true)
  Keyword SexLabNoStrip = Keyword.GetKeyword("SexLabNoStrip")
  If(SexLabNoStrip)
    Kudasai.RemoveArmorByKeyword(worn, SexLabNoStrip)
  EndIf
  Keyword ToysToy = Keyword.GetKeyword("ToysToy")
  If(ToysToy)
    Kudasai.RemoveArmorByKeyword(worn, ToysToy)
  EndIf
  Debug.Trace("[Kudasai] Robbing, Worn Armor = " + worn)
  Potion healthpotion = Kudasai.GetMostEfficientPotion(victim, PlayerRef)
  Debug.Trace("[Kudasai] Rescue, Potion = " + healthpotion)
  ;/
  - Capture
  - Execute
  - Feed (Kill Drain) (Vampire only)
  - Assault
  - Rob
  - Strip
  - Tie Up
  - Rescue
  /;
  If(PlayerRef.GetItemCount(HunterSeal) > 0) ; Capture
  EndIf
  If(PlayerRef.HasKeyword(Vampire)) ; Vampire
  EndIf
  If(MCM.FrameAny) ; Assault
  EndIf
  If(worn.Length) ; Strip
  EndIf
  If(healthpotion) ; Rescue
  EndIf
  ; TODO: Replace with .swf Menu call
  int result = MenuTEMP.Show()
  Utility.Wait(0.5)

  If(result == 1) ; Capture
    Captures.Store(Victim)
  ElseIf(result == 2) ; Execute
    If(IsEssential(Victim))
      return
    EndIf
    ; TODO: Add Animation
    Victim.Kill(Game.GetPlayer())
  ElseIf(result == 3) ; Feed
    If(IsEssential(Victim))
      return
    EndIf
    Game.GetPlayer().StartVampireFeed(Victim)
    PlayerVampireQuest.VampireFeed()
    Victim.Kill(Game.GetPlayer())
  ElseIf(result == 4) ; Assault
    Actor[] positions = new Actor[1]
    positions[0] = Game.GetPlayer()
    If(KudasaiAnimation.CreateAssault(Victim, positions, "KudasaiHunterAssault") == -1)
      Debug.Notification("Failed to create Scene")
      return
    EndIf
    Victim.SendAssaultAlarm()
    RegisterForModEvent("ostim_end", "PostSceneOStim")
    RegisterForModEvent("HookAnimationEnd_KudasaiHunterAssault", "PostSceneSL")
  ElseIf(result == 5) ; Rob
    Victim.OpenInventory(true)
    Victim.SendAssaultAlarm()
  ElseIf(result == 6) ; Strip
    int i = 0
    While (i < worn.length)
      victim.UnequipItem(worn[i])
      i += 1
    EndWhile
  ElseIf(result == 7) ; Tie Up
    Debug.Notification("--- TODO: ---")
  ElseIf(result == 8) ; Rescue
    PlayerRef.RemoveItem(healthpotion, 1, true, Victim)
    Victim.EquipItem(healthpotion, false, true)
  EndIf
EndFunction

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

Armor Property HunterSeal Auto

Keyword Property Vampire Auto

KudasaiMCM Property MCM Auto

PlayerVampireQuestScript Property PlayerVampireQuest  Auto  

Message Property EssentialConformation  Auto

KudasaiCaptures Property Captures  Auto

Message Property NoPotionMsg  Auto
