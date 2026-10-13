extends RefCounted
class_name CellCommons

enum Type
{
	ITEM = 0,
	EMOTE,
	SKILL,
	COUNT
}

#
static func CompareCell(cell : BaseCell, id : int, customfield : String) -> bool:
	return cell and \
	cell.id == id and \
	(
		cell is not ItemCell or \
		cell.customfield == customfield \
	)

static func IsSameItem(cell : BaseCell, item : Item) -> bool:
	return item and CompareCell(cell, item.cellID, item.cellCustomfield)

static func IsSameCell(cellA : BaseCell, cellB : BaseCell) -> bool:
	return cellB and CompareCell(cellA, cellB.id, cellB.customfield if cellB is ItemCell else "")

static func IsEquipment(cell : ItemCell) -> bool:
	return cell.slot >= ActorCommons.Slot.FIRST_EQUIPMENT and cell.slot < ActorCommons.Slot.LAST_EQUIPMENT

static func IsEquipped(cell : BaseCell) -> bool:
	return cell and cell is ItemCell and IsEquipment(cell) and \
	Launcher.Player and Launcher.Player.inventory and Launcher.Player.inventory.equipment and \
	IsSameItem(cell, Launcher.Player.inventory.equipment[cell.slot])

enum Modifier {
	None = 0,
	Health,
	Mana,
	Stamina,
	MaxMana,
	RegenMana,
	CritRate,
	MAttack,
	MDefense,
	MaxStamina,
	RegenStamina,
	CooldownDelay,
	MaxHealth,
	RegenHealth,
	Defense,
	CastDelay,
	DodgeRate,
	AttackRange,
	WalkSpeed,
	WeightCapacity,
	Attack,
	Hide,
	Invisible,
	Accuracy,
	Flight,
	Count
}

static func GetModifierDisplayName(effect : Modifier) -> String:
	match effect:
		Modifier.Flight: return "ขี่กระบี่"
		Modifier.Health:		return TranslationServer.translate("Health")
		Modifier.Mana:			return TranslationServer.translate("Mana")
		Modifier.Stamina:		return TranslationServer.translate("Stamina")
		Modifier.MaxHealth:		return TranslationServer.translate("Max Health")
		Modifier.MaxMana:		return TranslationServer.translate("Max Mana")
		Modifier.MaxStamina:	return TranslationServer.translate("Max Stamina")
		Modifier.Attack:		return TranslationServer.translate("Attack")
		Modifier.Defense:		return TranslationServer.translate("Defense")
		Modifier.MAttack:		return TranslationServer.translate("M. Attack")
		Modifier.MDefense:		return TranslationServer.translate("M. Defense")
		Modifier.AttackRange:	return TranslationServer.translate("Atk Range")
		Modifier.CritRate:		return TranslationServer.translate("Crit Rate")
		Modifier.DodgeRate:		return TranslationServer.translate("Dodge Rate")
		Modifier.Accuracy:		return TranslationServer.translate("Accuracy")
		Modifier.CastDelay:		return TranslationServer.translate("Cast Delay")
		Modifier.CooldownDelay:	return TranslationServer.translate("Cooldown")
		Modifier.RegenHealth:	return TranslationServer.translate("HP Regen")
		Modifier.RegenMana:		return TranslationServer.translate("MP Regen")
		Modifier.RegenStamina:	return TranslationServer.translate("SP Regen")
		Modifier.WalkSpeed:		return TranslationServer.translate("Walk Speed")
		Modifier.WeightCapacity: return TranslationServer.translate("Carry Weight")
		_:						return TranslationServer.translate("Unknown")

static func IsInverseModifier(effect : Modifier) -> bool:
	return effect == Modifier.CastDelay or effect == Modifier.CooldownDelay

static func IsResourceModifier(effect : Modifier) -> bool:
	return effect == Modifier.Health or effect == Modifier.Mana or effect == Modifier.Stamina

static func GetModifierColor(effect : Modifier, value : Variant) -> Color:
	var val : float = -float(value) if IsInverseModifier(effect) else float(value)
	if val > 0.0:
		return UICommons.ModifierPositiveColor
	elif val < 0.0:
		return UICommons.ModifierNegativeColor
	return UICommons.LightTextColor

static func GetModifierDiffBBCode(effect : Modifier, diff : Variant) -> String:
	if float(diff) == 0.0:
		return ""
	var diffColor : String = "#" + GetModifierColor(effect, diff).to_html(false)
	var arrow : String = "↑" if float(diff) > 0.0 else "↓"
	return " [color=%s](%s %s)[/color]" % [diffColor, FormatModifierValue(effect, diff), arrow]

static func GetPercentDiffBBCode(diffPercent : float, inverse : bool = false) -> String:
	if diffPercent == 0.0:
		return ""
	var isGood : bool = diffPercent < 0.0 if inverse else diffPercent > 0.0
	var diffColor : String = "#" + (UICommons.ModifierPositiveColor.to_html(false) if isGood else UICommons.ModifierNegativeColor.to_html(false))
	var arrow : String = "↑" if diffPercent > 0.0 else "↓"
	return " [color=%s](%s%.2f%% %s)[/color]" % [diffColor, ("+" if diffPercent > 0.0 else ""), diffPercent, arrow]

static func FormatModifierValue(effect : Modifier, value : Variant) -> String:
	match effect:
		Modifier.CritRate, Modifier.DodgeRate, Modifier.Accuracy:
			var floatVal : float = float(value) * 100.0
			return ("+" if floatVal >= 0.0 else "") + ("%.2f" % floatVal) + "%"
		Modifier.CastDelay, Modifier.CooldownDelay:
			var floatVal : float = float(value)
			return ("+" if floatVal >= 0.0 else "") + ("%.2f" % floatVal) + "s"
		_:
			var intVal : int = int(value)
			return ("+" if intVal >= 0 else "") + str(intVal)
