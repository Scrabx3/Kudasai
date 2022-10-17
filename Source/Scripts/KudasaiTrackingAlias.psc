Scriptname KudasaiTrackingAlias extends ReferenceAlias  

int Property myObjective Auto
{Objective to display to track this alias}

bool Function IsTracked(ObjectReference akTracked = none)
  ObjectReference ref = GetReference()
  If(akTracked)
    return ref && ref == akTracked
  EndIf
  return ref
EndFunction

Function TrackMe(Actor akTrackingTarget)
  ForceRefTo(akTrackingTarget)
  Kudasai.RegisterForActorRescued_Alias(self)
  Quest q = GetOwningQuest()
  If(q.IsObjectiveCompleted(myObjective))
    q.SetObjectiveCompleted(myObjective, false)
  EndIf
  q.SetObjectiveDisplayed(myObjective, true, true)
EndFunction

Function UntrackMe()
  If(GetReference())
    FoundMe()
  EndIf
EndFunction

Event OnActorRescued(Actor akVictim)
  If(akVictim == GetReference())
    FoundMe()
  EndIf
EndEvent

Function FoundMe()
  GetOwningQuest().SetObjectiveCompleted(myObjective)
  Clear()
EndFunction
