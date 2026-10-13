extends RefCounted
class_name SupplyShop

const ACTION := "XianWaySupplyShop"
const CATALOG : Array[Dictionary] = [
	{"item":"Cactus Potion", "title":"ยาฟื้นเลือด • HP +100", "price":8},
	{"item":"ยาฟื้นปราณ", "title":"ยาฟื้นปราณ • MP +100", "price":12},
	{"item":"ยาฟื้นเลือดขวดใหญ่", "title":"ยาฟื้นเลือดขวดใหญ่ • HP +500", "price":35},
	{"item":"Cactus Drink", "title":"ยาแก้พิษ • HP +75", "price":10},
	{"item":"Short Sword", "title":"กระบี่เริ่มต้น • พลังโจมตี +20", "price":80},
	{"item":"Leather Shirt", "title":"เสื้อหนัง", "price":60},
	{"item":"Leather Boots", "title":"รองเท้าหนัง", "price":40}
]

static func Buy(player : PlayerAgent, request : int) -> bool:
	if not player or not ActorCommons.IsAlive(player) or player.isWarping or player.ownScript or Travel.IsFlying(player):
		return false
	var map := WorldAgent.GetMapFromAgent(player)
	if not map or not Cultivation.IsCity(map.id):
		Network.CommandFeedback("ร้านค้า: กลับเข้าเมืองเพื่อซื้อสินค้า", player.peerID)
		return false
	if request < 0:
		return false
	var index : int = request / 100
	var count : int = request % 100
	if index >= CATALOG.size() or count not in [1, 10]:
		return false
	var product : Dictionary = CATALOG[index]
	var cell : ItemCell = DB.GetItem(String(product.item).hash())
	var cost : int = product.price * count
	if not cell:
		return false
	if player.stat.gp < cost:
		Network.CommandFeedback("ร้านค้า: เงิน G ไม่พอ", player.peerID)
		return false
	if player.stat.weight + cell.weight * count / 1000.0 > player.stat.current.weightCapacity:
		Network.CommandFeedback("ร้านค้า: น้ำหนักเกิน กรุณาจัดกระเป๋าก่อน", player.peerID)
		return false
	# No await: add and debit occur together on the authoritative game thread.
	if not player.inventory.AddItem(cell, count):
		Network.CommandFeedback("ร้านค้า: กระเป๋าเต็ม ไม่ได้หักเงิน", player.peerID)
		return false
	player.stat.gp -= cost
	player.stat.vital_stats_updated.emit()
	Network.CommandFeedback("ร้านค้า: ซื้อ %s ×%d สำเร็จ • จ่าย %d G" % [product.title, count, cost], player.peerID)
	return true
