ScriptName KudasaiStruggle Hidden

bool Function MakeStruggle(Actor akAggressor, Actor akVictim, String asCallbackEvent, float afDifficulty) global
  AELStruggle struggle_api = AELStruggle.Get()
  return struggle_api.MakeStruggle(akAggressor, akVictim, asCallbackEvent, afDifficulty)
EndFunction