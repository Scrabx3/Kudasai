Scriptname KudasaiParadiseHalls Hidden

Function ParadaiseHallsEnslave(Actor newSlave) global
  Quest PAH = Game.GetFormFromFile(0x01FAEF, "paradise_halls.esm") as Quest
  PAHCore Core = (PAH as PAHCore)
	Core.capture(newslave)
EndFunction