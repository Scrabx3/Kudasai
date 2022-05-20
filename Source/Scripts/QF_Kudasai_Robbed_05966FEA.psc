;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF_Kudasai_Robbed_05966FEA Extends Quest Hidden

;BEGIN ALIAS PROPERTY robber
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_robber Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY newRobber
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_newRobber Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Alias_newRobber.GetActorReference().ResetInventory()

FailAllObjectives()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
ToMapEdge.Start()

Actor robber = ALias_Robber.GetActorRef()
ActorBase robberbase = robber.GetActorBase()
ObjectReference newRobber
If(KudasaiInternal.IsRadiant(robber))
  newRobber = robber.PlaceAtMe(robberbase)
Else
  newRobber = robber
EndIf
Alias_NewRobber.ForceRefTo(newRobber)

Kudasai.RemoveAllItems(Game.GetPlayer(), newRobber)
SetStage(10)
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

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
RegisterForSingleUpdateGameTime(72)

SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Event OnUpdateGameTime()
  SetStage(30)
EndEvent

Quest Property ToMapEdge  Auto  