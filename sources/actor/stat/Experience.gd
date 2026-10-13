extends RefCounted
class_name Experience

const MAX_LEVEL_REACHED = 0

static func GetNeededExperienceForNextLevel(currentLevel : int) -> int:
	if currentLevel >= Cultivation.MAX_LEVEL:
		return MAX_LEVEL_REACHED
	# Fast first lessons; each realm is progressively longer, with a larger
	# requirement at layer ten. Level 1..100 is the persisted cultivation rank.
	var rank : int = maxi(1, currentLevel)
	var needed : int = 16 + rank * rank * 4
	return needed * 2 if Cultivation.Layer(rank) == 10 else needed
