# Thai mobile training build

Version 0.0.9-thai.2 (Android version code 902).

- Thai catalog for core UI, equipment/stat labels and account flows. Sarabun is bundled under OFL.
- Elanore/Kael/Ekinu teach equipment, combat, recovery and allocating attributes in short Thai instructions. Existing item IDs, graphics and save-directory remain unchanged.
- Training button shows the current goal, XP and available attribute points, with inventory/stat shortcuts. It does not pause the world.
- Kael counts lifetime bestiary kills, including previous kills, so the target is recoverable across sessions.
- Test offline: online content still comes from the upstream server. Optional legacy quests, some item descriptions, and policy/credits text are not fully localized yet.

Validation: Godot 4.7.1 headless import and tests/mobile_smoke.tscn cover offline account/character entry, independent touch input, Thai glyphs, translation lookup, guide shortcuts and objective counts. Android CI builds the APK. No physical Android device verification was performed. Upstream shutdown resource warnings remain.
