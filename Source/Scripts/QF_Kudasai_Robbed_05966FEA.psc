;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF_Kudasai_Robbed_05966FEA Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY robber
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_robber Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY newRobber
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_newRobber Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
RobbedScene.Stop()
SetObjectiveDisplayed(10)

RegisterForSingleUpdateGameTime(72)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
RegisterForSingleUpdate(0.5)
ToMapEdge.Start()

Actor robber = ALias_Robber.GetActorRef()
ActorBase robberbase = robber.GetActorBase()
ObjectReference newRobber
If(KudasaiInternal.IsRuntimeGenerated(robber))
  newRobber = robber.PlaceAtMe(robberbase)
Else
  newRobber = robber
EndIf
Alias_NewRobber.ForceRefTo(newRobber)

KudasaiInternal.RobActor(Game.GetPlayer(), newRobber as Actor, false)
; --- Follower Dismissal here ---
; ---
SetStage(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Alias_newRobber.GetActorReference().ResetInventory()

FailAllObjectives()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
CompleteAllObjectives()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Event OnUpdate()
  RobbedScene.Start()
EndEvent

Event OnUpdateGameTime()
  SetStage(30)
EndEvent

Quest Property ToMapEdge  Auto  

Scene Property RobbedScene  Auto  
