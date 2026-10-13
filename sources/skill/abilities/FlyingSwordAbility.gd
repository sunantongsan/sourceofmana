extends CellScript

func Execute(target : BaseAgent, _cell : BaseCell):
	if target is PlayerAgent:
		Travel.ToggleFlight(target)
