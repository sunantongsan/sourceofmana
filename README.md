# Source of Mana

![screenshot](data/press/readme/header.png)

**Source of Mana** is a classic 2D MMORPG inspired by the golden era of pixel art RPGs. This game project is truly open source and welcomes contributions from around the globe.

The game is still in early development but already offers a playable solo and multiplayer experience.

## วิถีเซียน: รุ่นทดสอบ Android 0.0.14

- วงกลมโต้ตอบ/เก็บของเปลี่ยนเป็นปุ่มยาฟื้นเลือด/ปราณ พร้อมรูป จำนวน และคูลดาวน์ร่วม 1 วินาที; ไม่หักยาเมื่อค่าพลังเต็ม ตรวจการใช้ที่เซิร์ฟเวอร์
- ปุ่ม L เปลี่ยนเป็นรูปกระเป๋า เปิดรายการทั้งหมด; รูปตัวละครแทนวง EXP เปิดหน้าจัดการค่าสถานะ อุปกรณ์ และสกิล
- ได้ 1 แต้มสกิลต่อเลเวลที่เพิ่ม (ตัวละครเดิมได้ตามเลเวลด้วย) ใช้ 1 แต้มต่อขั้น สูงสุด 20 ขั้น วิชาเริ่มขั้น 1 ฟรี ความแรง +10% ต่อขั้นจนถึง 290% ที่ขั้น 20 บันทึกขั้นในเซฟเดิม
- ปราณม่วงระเบิดและพายุกระบี่หยกโจมตีหมู่รอบตัว ระยะ 96/112 พิกเซล; กระบี่คลื่นครามโจมตีเดี่ยว
- ร้านค้าโทนสว่างแบบหน้าต่าง RPG มีหมวดสินค้า รูปไอเทม รายละเอียด จำนวนที่มี ราคาซื้อ ×1/×10; ช่อง GM เปิดจากปุ่ม GM
- ทดสอบออฟไลน์ด้วย `Godot --headless --path . tests/skills_ui_smoke.tscn` ครอบคลุมการใช้ยา แต้ม/ขั้น/บันทึกสกิล เป้าหมายหมู่ กระเป๋า และขอบเขต UI 800×480 พร้อมชุดทดสอบโลกและการต่อสู้เดิม

## วิถีเซียน: รุ่นทดสอบ Android 0.0.13

- เปิดเดินทางครบ 40 แผนที่ต้นฉบับ ผ่าน 44 จุดวาร์ป พร้อมช่องค้นหาในเมนูเดินทาง
- 25 พื้นที่ล่า ครอบคลุม Lv.1–100; อีก 15 แห่งเป็นเมือง/จุดพัก/พื้นที่สำรวจปลอดภัย
- เติมมอนสเตอร์ในห้องเก็บสินค้า เหมืองลึก และสนามประลอง ปรับเลเวล HP พลังโจมตี ป้องกัน EXP ตามพื้นที่ บอสถ้ำท้ายเกม Lv.93/96/99/100
- เมืองอาร์ทิสและมานาเยอร์ปลอดภัย จำนวนมอนสเตอร์ต่อแผนที่ไม่เกิน 96 ตัว (พื้นที่ในอาคารไม่เกิน 64; ห้องเรือไม่เกิน 12) เกิดใหม่ 8 วินาที
- แสดงอาวุธที่สวมจริงขณะยืน เดิน และโจมตี โดยใช้รูปอาวุธเดิมแยกจากเฟรมแขน ความยาวชัดขึ้น ไม่แสดงดาบซ้อนสองเล่ม และซ่อนเมื่อถอดอาวุธ/แปลงร่าง/ขี่กระบี่
- กระบี่บินกลับขนาดเดิม ส่วนการฟันติดตามเป้าหมายที่ถอยหนีระหว่างง้างได้ในระยะจำกัด ตรวจระยะและเส้นทางที่เซิร์ฟเวอร์ ไม่ตีไกลหรือทะลุกำแพง

ทดสอบด้วย `Godot --headless --path . tests/world_weapons_smoke.tscn`: โหลดฉากครบ 40 แห่ง, จุดวาร์ป, ช่วงเลเวล/จำนวนมอนสเตอร์, ท่าอาวุธ 4 ทิศ, ถอดอาวุธ, กระบี่บินขนาดเดิม และโจมตีเป้าหมายที่เคลื่อนพ้นระยะเริ่มต้น

## วิถีเซียน: รุ่นทดสอบ Android 0.0.12

- แตะมอนสเตอร์เพื่อเลือกเป้าหมาย แล้วกดโจมตีหรือสกิล ออโตจะใช้เป้าหมายที่เลือกจนกว่าจะตายหรือหายไป
- กระบี่ในมือใหญ่ขึ้น 45% และกระบี่บินใหญ่ขึ้น 50%
- ปุ่ม **ร้านค้า / GM** ด้านซ้าย: ซื้อยาและอุปกรณ์ได้ในเมือง ใช้ของผ่านกระเป๋า
- ฆ่ามอนสเตอร์ได้รับเงิน G อัตโนมัติ พร้อมตัวเลข `+… G` ไม่ต้องเก็บเหรียญจากพื้น
- พิมพ์ในช่อง GM หรือช่องแชต: `gm g+1000` เพิ่ม 1,000 G; `gm exp100x` เปิด EXP มอนสเตอร์ ×100; `gm exp1x` กลับปกติ
- EXP ×100 ใช้เฉพาะรอบการเล่นนั้น ไม่เพิ่ม EXP จากภารกิจ และไม่ทบเป็น ×10,000 เมื่อสั่งซ้ำ
- คำสั่งทดสอบใช้ได้ในออฟไลน์หรือผู้มีสิทธิ์ GM บนเซิร์ฟเวอร์ ไม่ได้ให้สิทธิ์บนบริการออนไลน์ต้นฉบับ
- ซื้อของตรวจเงิน ช่องกระเป๋า และน้ำหนักที่ฝั่งเซิร์ฟเวอร์ เงินไม่พอหรือกระเป๋าเต็มจะไม่หักเงิน

การตรวจสอบ: `Godot --headless --path . tests/shop_smoke.tscn` ทดสอบบัญชีออฟไลน์ การซื้อสินค้า สิทธิ์ GM เป้าหมายแบบสัมผัส EXP ×100 เงินรางวัล การต่อสู้ และการเกิดใหม่

## About the Project

**Engine:** Godot 4 (client and server)

**Design Tools:** (exact versions in [versions.cfg](versions.cfg))
- Game editor: [Godot](https://godotengine.org/)
- Level editor: [Tiled](https://www.mapeditor.org/)

**Organization:** [Manasource](https://manasource.org)

**Origins:** We are veterans of *The Mana World*, building upon and improving its assets

**Goal:** Become the go-to open source 2D MMORPG project

**Platforms:** Desktop (Windows, macOS, Linux), Mobile (Android) and Web (HTML5/WebAssembly) clients

## Gameplay Highlights

- Explore a fantasy world crafted in charming pixel art
- Interact with NPCs and other players in real-time
- Battle monsters, complete quests, and collect loot
- Dynamic server-authoritative design
- Frequent updates and community-driven development

## Screenshots

![exploration](data/press/readme/exploration.png)
![combat](data/press/readme/combat.png)
![dialogue](data/press/readme/dialogue.png)

## Controls

### General Movement
- **Move:** `WASD`
- **Click to Move / Interact:** Left Mouse Button
- **Interact:** `Ctrl`
- **Target:** `E`
- **Untarget:** `R`
- **Run (Hold):** `Shift`
- **Pickup Items:** `Q`
- **Morph / Transformation:** `M`
- **Sit:** `C`

### Camera
- **Zoom In / Out:** Mouse Scroll
- **Reset Zoom:** Middle Mouse Button
- **Screenshot:** `P`

### UI Shortcuts (Keyboard Only)
- **Menu Bar:** `F1`
- **Open Stats:** `F2`
- **Inventory:** `F3`
- **Skills:** `F4`
- **Quest Progress:** `F5`
- **Minimap:** `F6`
- **Chat:** `F7`
- **Social:** `F8`
- **Settings:** `F9`
- **Toggle Fullscreen:** `F11`
- **Emotes:** `F12`

### Contextual Actions
- **Confirm / Open Chat:** `Enter`
- **Cancel / Close:** `Esc`
- **Context Options:** `1`, `2`, `3`, `4`

## Community & Contribution

We’re always looking for contributors of all kinds:
- Pixel artists
- SFX makers
- GDScript or general programmers
- UI/UX designers
- Writers and worldbuilders

### Contact

If you’re interested in helping, join our community and check out our open issues.

- **Discord:** [Join here](https://discord.com/channels/581622549566193664/1013487216493854780)
- **IRC:** `#sourceofmana` and `#sourceofmana-dev` on [Libera.Chat](https://web.libera.chat/#sourceofmana,#sourceofmana-dev)

## License

For detailed information on the licensing of code, assets, and design, as well as credits for individual asset files, please refer to the [LICENSE.md](LICENSE.md) file.

- **Code License:** MIT License
- **Art & Design License:** CC BY-SA 4.0

---

Source of Mana is developed by volunteers in their free time. If you like retro RPGs & MMORPGs and want to help shape the future of open-source gaming, come say hi!
