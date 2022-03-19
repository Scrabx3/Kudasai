Scriptname KudasaiResolutionPlayer extends ReferenceAlias

Event OnUpdate() ; Called by rPlayer Quest at Stage 100
  GoToState("Exhausted")
EndEvent

State Exhausted
  ; This State acts as a buffer to leave the Player non hostile towards Victoires. This State will last
  ; 15 seconds and is canceled early if the player does potentially "provoking"
	Event OnBeginState()
    ; IDEA: Add an "exhausted" movement Idle here

		RegisterForActorAction(8) ; Drawing Weapon
		RegisterForMenu("ContainerMenu") ; "Looting near Victoires"
    
		RegisterForSingleUpdate(15)
	EndEvent

	Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
		GotoState("")
	EndEvent

	Event OnMenuOpen(string menuName)
		GotoState("")
	EndEvent

	Event OnUpdate()
		GotoState("")
	EndEvent

	Event OnEndState()
    GetOwningQuest().SetStage(200) ; Stops Quest
	EndEvent
EndState
