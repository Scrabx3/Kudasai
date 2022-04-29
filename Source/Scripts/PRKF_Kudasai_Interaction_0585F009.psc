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
int choice = MenuTEMP.Show()
If(choice == 1)
  Capture(v)
ElseIf(choice == 2)
  Execute(v)
ElseIf(choice == 3)
  Feed(v)
ElseIf(choice == 4)
  Assault(v)
ElseIf(choice == 5)
  Rob(v)
ElseIf(choice == 6)
  Strip(v)
ElseIf(choice == 7)
  TieUp(v)
ElseIf(choice == 8)
  Rescue(v)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property MenuTEMP Auto

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

; Capturing should lock a Victim away from the World map and store them somewhere
; Goal of this Function will be to properly despawn and force an actor to stay persistent until released
Function Capture(Actor Victim)
  ; TODO: Check for Ring
  Captures.Store(Victim)
EndFunction

; TODO: Add animation
Function Execute(Actor Victim)
  If(!CheckEssential(Victim))
    return
  EndIf
  Victim.Kill(Game.GetPlayer())
EndFunction

; Vampire Feed. This will always kill the Victim cause well.. theyre weak and stuff
Function Feed(Actor Victim)
  If(!CheckEssential(Victim))
    return
  EndIf
  Game.GetPlayer().StartVampireFeed(Victim)
  PlayerVampireQuest.VampireFeed()
  Victim.Kill(Game.GetPlayer())
EndFunction

Function Assault(Actor Victim)
  Actor[] positions = new Actor[1]
  positions[0] = Game.GetPlayer()
  If(KudasaiAnimation.CreateAssault(Victim, positions, "KudasaiHunterAssault") == -1)
    Debug.Notification("Failed to create Scene")
  EndIf
  RegisterForModEvent("ostim_end", "PostSceneOStim")
  RegisterForModEvent("HookAnimationEnd_KudasaiHunterAssault", "PostSceneSL")
EndFunction
Event PostSceneSL(int tid, bool hasPlayer)
  Actor[] positions = KudasaiAnimationSL.GetPositions(tid)
  HandlePostScene(positions)
EndEvent
Event PostSceneOStim(string eventName, string strArg, float numArg, Form sender)
  Actor[] positions = KudasaiAnimationOStim.GetPositions(numArg as int)
  If(numArg > -2 && positions.Find(Game.GetPlayer()) > -1)
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

Function Rob(Actor Victim)
  Victim.OpenInventory(true)
EndFunction

Function Strip(Actor Victim)
  Armor[] worn = Kudasai.GetWornArmor(Victim, true)
  Keyword SexLabNoStrip = Keyword.GetKeyword("SexLabNoStrip")
  Keyword ToysToy = Keyword.GetKeyword("ToysToy")
  int i = 0
  While (i < worn.length)
    If ((!SexLabNoStrip || !worn[i].HasKeyword(SexLabNoStrip)) && (!ToysToy || !worn[i].HasKeyword(ToysToy)))
      Victim.UnequipItem(worn[i], abSilent = true)
    EndIf
    i += 1
  EndWhile
EndFunction

Function TieUp(Actor Victim)
  Debug.Notification("--- TODO: ---")
EndFunction

Function Rescue(Actor Victim)
  Actor Player = Game.GetPlayer()
  Potion p = Kudasai.GetMostEfficientPotion(Victim, Player)
  Debug.Trace("[Kudasai] HunterRescue -> Found Potion = " + p)
  If(!p)
    NoPotionMsg.Show()
    return
  EndIf
  Player.RemoveItem(p, 1, true, Victim)
  Victim.EquipItem(p, false, true)
EndFunction

bool Function CheckEssential(Actor Victim)
  ActorBase base = Victim.GetLeveledActorBase()
  If(!base.IsEssential())
    return true
  EndIf
  If(EssentialConformation.Show() == 1)
    base.SetEssential(false)
    return true
  EndIf
  return false
EndFunction

PlayerVampireQuestScript Property PlayerVampireQuest  Auto  

Message Property EssentialConformation  Auto

KudasaiCaptures Property Captures  Auto

Message Property NoPotionMsg  Auto
