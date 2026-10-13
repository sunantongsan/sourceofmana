extends RefCounted
class_name QuickPotion

const COOLDOWN := 1.0

static func Choose(actor : Actor, mana : bool) -> ItemCell:
	if not actor or not actor.inventory:
		return null
	var names : Array = ["ยาฟื้นปราณ"] if mana else ["Cactus Potion", "ยาฟื้นเลือดขวดใหญ่"]
	for item_name in names:
		var cell : ItemCell = DB.GetItem(item_name.hash())
		var item = actor.inventory.GetItem(cell) if cell else null
		if item and item.count > 0:
			return cell
	return null

static func Use(player : PlayerAgent, cell : ItemCell) -> bool:
	if not player or not cell or not cell.usable or not ActorCommons.IsAlive(player) or player.isWarping or player.ownScript:
		return false
	var item = player.inventory.GetItem(cell)
	if not item or item.count < 1:
		return false
	var quick : bool = cell.id in ["Cactus Potion".hash(), "ยาฟื้นเลือดขวดใหญ่".hash(), "ยาฟื้นปราณ".hash()]
	if quick:
		var now : int = Time.get_ticks_msec()
		if now < int(player.get_meta("potion_ready_at", 0)):
			return false
		var mana : bool = cell.id == "ยาฟื้นปราณ".hash()
		if (mana and player.stat.mana >= player.stat.current.maxMana) or (not mana and player.stat.health >= player.stat.current.maxHealth):
			return false
		player.set_meta("potion_ready_at", now + int(COOLDOWN * 1000))
	player.inventory.UseItem(cell)
	return true
