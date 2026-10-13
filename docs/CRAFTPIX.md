# CraftPix character integration

The player renderer uses the original Warrior SCML animation curves, hierarchy,
spin, pivots and draw order in four directions. Head, clothing colors and jian
are native vector edits. Walk timing is unchanged. The jian is attached to a
hand when an idle/walk clip omits its sword; attacks retain source transforms.

Vendor images and derived motion data are intentionally gitignored. CraftPix
permits finished games and modifications but prohibits redistribution of raw or
modified reusable art. Obtain the Free Warrior 4-direction Character Sprites
from https://craftpix.net/freebies/free-warrior-4-direction-character-sprites/.
Run `python tools/import_craftpix.py /path/to/extracted/archive` with Ghostscript,
PyMuPDF and Python. Assets absent: the game falls back to its existing renderer.

The owner's private Android test build includes the derived assets. Optional
Sentry monitoring is omitted in the test-build copy to use the standard Godot
Android template without Gradle. The public source keeps monitoring unchanged.
