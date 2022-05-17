Scriptname KudasaiCaptures extends Quest

GlobalVariable Property Capacity Auto
{Total amount of Victims that the Ring may store}

Cell Property HoldingCell Auto
ObjectReference Property HoldingCellMarker Auto

Message Property _NoFreeSlot Auto

ImageSpaceModifier Property FadeToBlackAndBackFast Auto
{Fast Fading in and out. Wind up is 0.55 seconds, fade out lasts 0.15 seconds, fade back takes 0.2 seconds}

int Property size = 0 Auto Hidden
{Number of Victims currently stored}

; Sort an Actor into the List of Defeated Victims
bool Function Store(Actor subject)
  If(size == Capacity.Value)
    Debug.Trace("[Kudasai] Cannot store subject = " + subject + " No available capacity")
    _NoFreeSlot.Show()
    return false
  EndIf
  ReferenceAlias empty = GetFreeAlias()
  ; This returns none if the Actor isnt leveled - which implies that the Actor is unique in some way
  ; The reason why SLDefeat has issues is that it tries to capture the actor object itself in its holding cell, which clashes with the games actor cleanup
  ; Kudasai avoids that by making a copy of the exact actor instead. This also has the benefit that the captured npc will respawn normally after a cell 
  ; reset, supporting the idea that the bandits in the dungeon arent the same bandits you slaughtered the last time \o/
  ActorBase vicbase = Kudasai.GetTemplateBase(subject)
  ; Before we do any NPC moving magic fade the screen out and beg that 0.15 seconds are enough for all of the things happenin here
  FadeToBlackAndBackFast.Apply()
  Utility.Wait(0.6)
  If(!vicbase)
    subject.MoveTo(HoldingCellMarker)
    ; Can only be called on a defeated actor..
    Kudasai.RescueActor(subject, true)
    empty.ForceRefTo(subject)
  Else
    ObjectReference victim = subject.PlaceAtMe(vicbase)
    victim.MoveTo(HoldingCellMarker)
    empty.ForceRefTo(victim)
    subject.DisableNoWait()
  EndIf
  size += 1
EndFunction

bool Function Retrieve(Actor subject, ObjectReference place = none)
  Alias[] aliases = GetAliases()
  int i = 0
  While(i < aliases.Length)
    KudasaiCapturesAlias captured = aliases[i] as KudasaiCapturesAlias
    If(captured.GetReference() as Actor == subject)
      If(place)
        subject.MoveTo(place)
        Kudasai.DefeatActor(subject)
      Else
        subject.KillEssential(Game.GetPlayer())
      EndIf
      captured.Clear()
      size -= 1
      return true
    EndIf
    i += 1
  EndWhile
  return false
EndFunction

Actor[] Function GetAllCaptured()
  Actor[] captures = PapyrusUtil.ActorArray(size)
  Alias[] aliases = GetAliases()
  int i = 0
  int ii = 0
  While(i < aliases.Length)
    Actor captured = (aliases[i] as ReferenceAlias).GetReference() as Actor
    If(captured != none)
      captures[ii] = captured
      ii += 1
    EndIf
    i += 1
  EndWhile
  return captures
EndFunction

ReferenceAlias Function GetFreeAlias()
  Alias[] aliases = GetAliases()
  int i = 0
  While(i < aliases.Length)
    ReferenceAlias that = aliases[i] as ReferenceAlias
    If(that.GetReference() == none)
      return that
    EndIf
    i += 1
  EndWhile
  return none
EndFunction
