# Source of Mana

![screenshot](data/press/readme/header.png)

**Source of Mana** is a classic 2D MMORPG inspired by the golden era of pixel art RPGs. This game project is truly open source and welcomes contributions from around the globe.

The game is still in early development but already offers a playable solo and multiplayer experience.

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
