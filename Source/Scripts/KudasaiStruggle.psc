Scriptname KudasaiStruggle extends Quest

String[] Function LookupStruggleAnimations(Actor[] positions) native global
String[] Function LookupBreakfreeAnimations(Actor[] positions) native global
String[] Function LookupKnockoutAnimations(Actor[] positions) native global

Function SetPositions(Actor[] positions) native global
Function ClearPositions(Actor[] positions) native global

bool Function OpenQTEMenu(int difficulty, Form callback) native global

Package Property BlankPackage Auto

; -- Only used for Player QTE
Actor[] _positions
Form _callback

bool Function CreateStruggle(Actor[] positions, int difficulty, Form callback) global
  KudasaiStruggle struggle = Quest.GetQuest("Kudasai_Struggles") as KudasaiStruggle
  return struggle.CreateStruggleAnimation(positions, difficulty, callback)
EndFunction

Function EndStruggle(Actor[] positions, bool victory) global
  String[] animations
  If(victory)
    animations = LookupBreakfreeAnimations(positions)
  Else
    animations = LookupKnockoutAnimations(positions)
  EndIf
  EndStruggleCustom(positions, animations)
EndFunction

Function EndStruggleCustom(Actor[] positions, String[] animations) global
  KudasaiStruggle struggle = Quest.GetQuest("Kudasai_Struggles") as KudasaiStruggle
  return struggle.EndStruggleAnimation(positions, animations)
EndFunction

Function EndStruggleAnimation(Actor[] positions, String[] animations)
  Debug.Trace("Struggle End -> Positions = " + positions + "Animations = " + animations)
  int n = 0
  While(n < positions.Length)
    Debug.SendAnimationEvent(positions[n], animations[n])
    If(positions[n] != Game.GetPlayer())
      ActorUtil.RemovePackageOverride(positions[n], BlankPackage)
      positions[n].EvaluatePackage()
    EndIf
    n += 1
  EndWhile
  Utility.Wait(2.3)
  ClearPositions(positions)
EndFunction

bool Function CreateStruggleAnimation(Actor[] positions, int difficulty, Form callback)
  Actor PlayerRef = Game.GetPlayer()
  bool hasplayer = positions.Find(PlayerRef) > -1
  If(hasplayer && UI.IsMenuOpen("KudasaiQTE"))
    return false
  EndIf
  String[] animations = LookupStruggleAnimations(positions)
  If(!animations.length)
    return false
  EndIf
  Debug.Trace("[Kudasai] Struggle Requested for " + positions + " with animations = " + animations + " callback = " + callback)
  ; Clear Status
  int i = 0
  While(i < positions.Length)
    If(positions[i].IsInCombat())
      positions[i].StopCombat()
    EndIf
    If(positions[i].IsSneaking())
      positions[i].StartSneaking()
    EndIf
    If(positions[i].IsWeaponDrawn())
      positions[i].SheatheWeapon()
    EndIf
    If(positions[i] != PlayerRef)
      ActorUtil.AddPackageOverride(positions[i], BlankPackage)
      positions[i].EvaluatePackage()
    EndIf
    Debug.SendAnimationEvent(positions[i], "IdleForceDefaultState")
    i += 1
  EndWhile
  SetPositions(positions)
  ; Play Animations
  int n = 0
  While(n < positions.Length)
    Debug.SendAnimationEvent(positions[n], animations[n])
    n += 1
  EndWhile
  ; Play QTE
  If(hasplayer)
    Utility.Wait(2)
    If(OpenQTEMenu(difficulty, self))
      _callback = callback
      ; Make a Copy of the array. Never thoght Papyrus would require me to use my brain here owo
      _positions = PapyrusUtil.RemoveActor(positions, none)
      return true
    EndIf
  EndIf
  bool victory = Utility.RandomInt(0, 99) < difficulty
  Kudasai.CreateFuture(8, callback, positions, victory as int)
  return true
EndFunction

Event OnQTEEnd_c(bool victory)
  Debug.Trace("[Kudasai] QTE END")
  If(_positions[0] != Game.GetPlayer())
    ; If Player is an aggressor here, invert the result, as winning in this case means the victim loses
    victory = 1 - (victory as int)
  EndIf
  Kudasai.CreateFuture(0.1, _callback, _positions, victory as int)
EndEvent
