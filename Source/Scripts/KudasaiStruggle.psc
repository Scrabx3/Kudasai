Scriptname KudasaiStruggle extends Quest
{API & Implementation for Struggle Animations
!IMPORTANT By the time of writing this, only 2p Struggles are supported}

; ---------------------------------------------------------------------------
; Create a new Struggle between the passed in positions.
; NOTE: This function will only start the struggle and invoke a callback. It will not end the animation
;       Use EndStruggle or EndStruggleCustom to properly stop the Animation
; --- Parameters:
; positions: The Actors to create the Struggle with. position[0] will be Victim, all others aggressors
; difficulty: A number between 0 and 100 to describe the difficulty of the Struggle. The higher this is, the easier the struggle
;             - For NPC: This is equal the chance the Victim will succeed in struggling out
;             - For Player: Described the average time the Player has to react -> Avg.Time = Sqrt(Difficulty)/4
;                           The actual time is randomized and will go up or down by 30% with each individual event
;                           A balanced difficulty would be 60~70, below 30 becomes impossibly difficult
; callback: A form to send the Callback to, the Callback Event is a Future_c Event, see Kudasai.psc for more Info
;           argActor = positions, argNum = if the victim won the struggle, argStr = empty
; duration: The time the struggle should last before the callback is invoked. Default 8 for values <= 0
;           If the player is part of the encounter and this is any other value greater than 0, the flash game will not be started
; --- return:
; true if the Struggle succeeded, false otherwise. See Console and Kudasai.log in Docs/SKSE for failure reason
; If the flashgame fails to start, the Struggle will be treated as if duration = 8
bool Function CreateStruggle(Actor[] positions, int difficulty, Form callback, int duration = 0) global
  KudasaiStruggle struggle = Quest.GetQuest("Kudasai_Struggles") as KudasaiStruggle
  return struggle.CreateStruggleAnimation(positions, difficulty, callback, duration)
EndFunction

; ---------------------------------------------------------------------------
; Stop the Struggle with default animations (if they exist)
; !IMPORTANT Knockout Animations dont exist. This is a placeholder "in case"
;            Thus, victory = false will always play: [StaggerStart, StaggerStart]
; --- Parameters:
; positions: The Actors to stop struggling. Should be identical to the array used in "CreateStruggle"
; victory: If the victim should escape or has been defeated in this struggle
Function EndStruggle(Actor[] positions, bool victory) global
  return EndStruggleImpl(positions, victory)
EndFunction

; ---------------------------------------------------------------------------
; Stop the Struggle with the given animations. This is useful, and recommended, if you want to use
; a custom follow up animation as consequence of the struggle. E.g. a bleedout animation
; --- Parameters:
; positions: The Actors to stop struggling. Should be identical to the array used in "CreateStruggle"
; animations: The animations to use to stop the struggle
Function EndStruggleCustom(Actor[] positions, String[] animations) global
  KudasaiStruggle struggle = Quest.GetQuest("Kudasai_Struggles") as KudasaiStruggle
  return struggle.EndStruggleAnimation(positions, animations)
EndFunction



; ===========================================================================
; ---------------------------------------------------------------------------
; ---------------------------- IMPLEMENTATION -------------------------------
; ---------------------------------------------------------------------------
; ===========================================================================

String[] Function LookupStruggleAnimations(Actor[] positions) native global
String[] Function LookupBreakfreeAnimations(Actor[] positions) native global
String[] Function LookupKnockoutAnimations(Actor[] positions) native global
Function SetPositions(Actor[] positions) native global
Function ClearPositions(Actor[] positions) native global

bool Function OpenQTEMenu(int difficulty, Form callback) native global
Function CloseQTEMenu() native global

Package Property BlankPackage Auto
Actor[] _positions
Form _callback

bool Function CreateStruggleAnimation(Actor[] positions, int difficulty, Form callback, int duration)
  If(positions.Find(Game.GetPlayer()) > -1 && UI.IsMenuOpen("KudasaiQTE"))
    return false
  EndIf
  String[] animations = LookupStruggleAnimations(positions)
  If(!animations.length)
    return false
  EndIf
  return CreateStruggleAnimationImpl(positions, difficulty, callback, duration, animations)
EndFunction

Function EndStruggleAnimation(Actor[] positions, String[] animations)
  Debug.Trace("Struggle End -> Positions = " + positions + "Animations = " + animations)
  If(UI.IsMenuOpen("KudasaiQTE") && positions.Find(Game.GetPlayer()) > -1)
    CloseQTEMenu()
  EndIf
  int n = 0
  While(n < positions.Length)
    Debug.SendAnimationEvent(positions[n], animations[n])
    If(positions[n] != Game.GetPlayer())
      ActorUtil.RemovePackageOverride(positions[n], BlankPackage)
      positions[n].EvaluatePackage()
    EndIf
    n += 1
  EndWhile
  If(animations.Find("IdleForceDefaultState") == -1)
    Utility.Wait(2.3)
  EndIf
  ClearPositions(positions)
EndFunction

Event OnQTEEnd_c(bool victory)
  Debug.Trace("[Kudasai] QTE END")
  If(_positions[0] != Game.GetPlayer())
    ; If Player is an aggressor here, invert the result, as winning in this case means the victim loses
    victory = 1 - (victory as int)
  EndIf
  Kudasai.CreateFuture(0.1, _callback, _positions, victory as int)
EndEvent

bool Function CreateStruggleAnimationImpl(Actor[] positions, int difficulty, Form callback, int duration, String[] animations)
  Debug.Trace("[Kudasai] Struggle Requested for " + positions + " with animations = " + animations + " callback = " + callback)
  Actor PlayerRef = Game.GetPlayer()
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
  If(positions.Find(PlayerRef) > -1 && duration <= 0)
    Utility.Wait(2)
    If(OpenQTEMenu(difficulty, self))
      _callback = callback
      ; Make a Copy of the array. Never thoght Papyrus would require me to use my brain here owo
      _positions = PapyrusUtil.RemoveActor(positions, none)
      return true
    EndIf
  EndIf
  bool victory = Utility.RandomInt(0, 99) < difficulty
  Kudasai.CreateFuture(duration, callback, positions, victory as int)
  return true
EndFunction

Function EndStruggleImpl(Actor[] positions, bool victory) global
  If(victory)
    EndStruggleCustom(positions, LookupBreakfreeAnimations(positions))
    If(positions[1] == Game.GetPlayer()) ; Dont ragdoll the player..
      return
    EndIf
    String rk = Kudasai.GetRaceKey(positions[1])
    If(rk == "Human")
      return
    ElseIf(rk == "Skeever" || rk == "Wolf")
      positions[0].PushActorAway(positions[1], 5.00000)
    ElseIf(rk == "Riekling" || rk == "DwarvenSpider")
      positions[0].PushActorAway(positions[1], 3.50000)
    ElseIf(rk == "FrostbiteSpider" || rk == "Falmer" || rk == "Draugr")
			positions[0].PushActorAway(positions[1], 2.00000)
    ElseIf(rk == "Sabrecat" || rk == "Gargoyle")
			positions[0].PushActorAway(positions[1], 1.00000)
    ElseIf(rk == "Bear" || rk == "Werewolf" || rk == "Chaurus" || rk == "ChaurusReaper" || rk == "ChaurusHunter")
			positions[0].PushActorAway(positions[1], 0.500000)
    Else ;If(rk == "Troll" || rk == "Giant")
			positions[0].PushActorAway(positions[1], 0.200000)
    EndIf
  Else
    EndStruggleCustom(positions, LookupKnockoutAnimations(positions))
  EndIf
EndFunction