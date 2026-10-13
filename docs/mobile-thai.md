# Thai mobile training build

Version 0.0.9-cultivation.3 (Android version code 903).

- Thai catalog for core UI, equipment/stat labels and account flows. Sarabun is bundled under OFL.
- Elanore/Kael/Ekinu teach equipment, combat, recovery and allocating attributes in short Thai instructions. Existing item IDs, graphics and save-directory remain unchanged.
- Training button shows the current goal, XP and available attribute points, with inventory/stat shortcuts. It does not pause the world.
- Kael counts lifetime bestiary kills, including previous kills, so the target is recoverable across sessions.
- Test offline: online content still comes from the upstream server. Optional legacy quests, some item descriptions, and policy/credits text are not fully localized yet.

Validation: Godot 4.7.1 headless import and tests/mobile_smoke.tscn cover offline account/character entry, independent touch input, Thai glyphs, translation lookup, guide shortcuts and objective counts. Android CI builds the APK. No physical Android device verification was performed. Upstream shutdown resource warnings remain.

## Cultivation and combat update

- Ten realms with ten layers each (levels 1–100): หลอมกาย, ฝึกปราณ, สร้างรากฐาน, แก่นปราณ, แก่นทองคำ, ทารกกำเนิด, ก่อกำเนิดวิญญาณ, หลอมเซียน, เซียน, ปรมาจารย์เซียน. Each realm boundary costs double the ordinary experience formula. Level 100 is capped.
- Original circular mobile controls: large normal attack, three skill buttons with cooldowns, targeting, interaction, pickup and rest. Existing skill icons are reused.
- Auto modes: off, normal attacks, skills only. Manual movement pauses auto; windows, dialogue, city entry, character changes and focus loss stop it. Targets are living monsters only.
- New and existing characters receive one starter sword (equipped if the weapon slot is empty) and three existing skills. A persisted marker prevents duplicate grants.
- Tulimshar city monster spawns are relocated to Sandstorm and the beach; no city monster spawns remain. The south gate is accessible before tutorial completion. Existing map art and NPCs are retained.
- Server rejects player damage skills within the city. Player melee repetition now follows deliberate held input or auto mode.

Additional validation: tests/combat_smoke.tscn checks realm boundaries, starter grants, safe-city spawn data, outdoor travel, real server damage, normal/skill auto, stopping auto, and touch controls. These are headless checks, not a physical-device usability test.
