# Kyoryokuna Enhancements - Changelog

Copyright (c) 2026 Pragas. All Rights Reserved.

Versions follow MAJOR.MINOR.PATCH:

- **PATCH**: bug fixes only;
- **MINOR**: new features or options;
- **MAJOR**: big changes, e.g. ones that need setting the addon up again.

## 0.3.0

- Missing buffs (new Missing Buffs page, second in the list): what your character should always have, read from its spellbook. Tick what to watch; while something is missing, its icon shows on the screen, grey and faded (so it never looks like something that's there), in and out of combat (not while dead).
  - Buffs: suggested ones for every class (e.g. for a mage: the armors, Arcane Intellect, Dampen / Amplify Magic), and a button to pick any other spell of the spellbook.
  - Conjured items: mana gems, conjured food and water (mage); healthstones, soulstones, spellstones and firestones (warlock). Shown when the bags hold fewer than a minimum (1 by default, up to 20), with the count on the icon. Any rank counts.
  - Two groups, Essential and Utility, each with its own place and look (icon size, opacity, space, direction). Each thing ticked goes to the group you pick: buffs start in Essential, items in Utility.
  - Buffs that can't be on together (a mage's armors, a hunter's aspects, a paladin's auras and blessings, a warlock's armors, a shaman's shields) are one line and one icon: any of them is enough. Its icon can be picked (e.g. Dampen Magic or Amplify Magic), or be the one of the spell last used. The same buff from someone else counts, and so do the group versions (Arcane Brilliance, Prayer of Fortitude, Gift of the Wild...). Every rank counts.
  - The choice is kept for each character. A new character with nothing chosen is told in the chat (once) when another character of its class has a choice, and the page has a button to copy it.
  - Move (drag both groups with a green frame) and Reset position.
  - In combat the game may hide your auras from addons: the icons then stay as they were last known. `/ke buffscan` shows what the addon can read on you at that moment.
  - The choices of each character aren't in the Import / Export code.

- A setting with a list of choices no longer takes a value that isn't one of them.

- The message asking to restart the game after an update now shows: it was written at login, while the game was still making its interface, and got lost. It now shows 5 seconds after the world appears.

## 0.2.0

- Options in pages of their own: General (language, minimap button), Action Bars, Experience Bar, Queue, Dark Mode, Import / Export and About.

- Action bars (Action Bars page):
  - hide the key of each button, and the names of macros (they come back as they were when shown again);
  - the size of the cooldown numbers on the buttons, 50% to 200% of the game's (the game's "Show cooldown numbers" option must be on);
  - an effect when a button's key is pressed: a white flash or a glowing border over the button, fading out quickly (off by default);
  - hide the frame and background of the micro menu.

- Experience bar (Experience Bar page, off by default): a texture of the addon (Flat, Smooth, Classic or Raid) for the experience bar and the other bars shown there (reputation, honor...). Each kind keeps its color (experience, rested, reputation by standing, honor). Turned off, the game's own texture comes back.

- Queue timer (Queue page, on by default): when a dungeon (dungeon finder) or a battleground is ready, the game's window to enter it shows how long is left to accept, in big numbers (green, then yellow at 20 seconds, red at 10) and a bar under the window that empties (can be turned off). A dungeon's offer lasts 40 seconds; a battleground's time comes from the game. Kept across a /reload.

- Import / Export page, the same as Kyoryokuna Plates': a code with all the settings to share (your language and the minimap button aren't in it), importing one (your current settings are kept as a backup first), and backups to put back later, with a name of your own (Edit). The last 10 are kept.

- After an update that adds files, a /reload no longer gives errors. The game reads the addon's list of files only when it starts, so a /reload leaves the new ones out; the addon now notices it (the version the game read isn't the code's), stays off (no events, nothing runs, settings untouched) and says to close the game and open it again, in the chat and in a window, in the player's language. /ke and the addon's entry in the game's addon button say it too.

- Dark mode (now on its own page, off by default): the art of the game's interface loses its color and is darkened, by a "Darkness" slider from 5% to 100% that shows its effect at once, while dragging. Each part can be turned on or off: unit frames (player, target, focus, pet, party, bosses), action bars (button borders, the bar's decoration and end caps, bags, menu, experience bar), cast bars, minimap (its ring, buttons and the rings of addon buttons), tooltips (border and a darker background), objective headers, the personal resource display (its bars' borders and the backgrounds of the class points: combo points, runes, chi, essence...), the bags (the windows and the slot borders, never the items) and the game menu (Escape), party and raid frames. `/ke darkscan` shows how many pieces each part finds in the game. The end caps, buttons and level circles stay a little lighter so their shapes still show. When the game paints a piece again (a new target, a new group member), it's darkened again at once; turned off, each piece gets back exactly the color the game last asked for. Protected frames are never touched.

- Minimap button: a click opens or closes the options; drag it to move it around the minimap (the place is kept). On by default, at its own place (away from the other Kyoryokuna addons' buttons). General page: "Show the minimap button".

## 0.1.0

- The start of the addon: its options window (/ke, the addon button of the minimap, or the game's AddOns settings) with the General page (language: English or Portuguese) and the About page (emblem, version, author, copyright). No features yet.
