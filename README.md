# Kyoryokuna Enhancements

Small improvements for **WoW Forever**, each on its own page of the options. **Everything starts off** (except the minimap button), so nothing changes in your game until you turn it on.

**Languages:** the addon itself is available in English and Portuguese (Portugal). Choose yours in `/ke` → **General** → **Language**.

## What it does

- **Proc Alerts:** the game's spell alert art beside your character when a proc happens, for every class and in combat too. Abilities that become usable can also make their action button glow. You can move the alerts, choose their look and animation, and test each one.
- **Trainer:**
  - Tick the spells you want at your class trainer, then learn only those.
  - A **Trainer tab in your spellbook** shows the spells still to learn, by level, with their cost. It has a search box and the total cost. It covers every trainer you visit (class, weapon master, riding...), and all characters of a class share it.
  - A new rank you learn takes the place of the old one on your action bars.
  - The chat tells you when you reach the level of new spells.
- **Missing Buffs:** the buffs and conjured items your character should have show faded on the screen while they're missing. Click one to cast or conjure it (out of combat).
- **Supplies:** macros that eat and drink the best food and drink in your bags, kept up to date by the addon.
- **Error Messages:** hide the game's red messages you don't want (their sound still plays), and silence their voice.
- **FPS and Latency:** your FPS and ping on the screen, where you want them, colored by how good they are.
- **Quest Sparkles:** quest items you can loot keep sparkling, even after a change of the graphics.
- **Action Bars:**
  - Hide the keybinds and macro names.
  - Color the cooldown numbers by time left.
  - Show a flash when you press a key.
  - Hide the micro menu's frame.
- **Experience Bar**, **Queue Timer** (the time left to accept a queue) and **Dark Mode** (darker unit frames, action bars, cast bars, minimap and tooltips).
- **Import / Export:** share your settings with a code, and keep backups to put back later.

## ⬇️ Download

**[Download the latest version (KyoryokunaEnhancements.zip)](https://github.com/Pragas/WoW-Forever-Kyoryokuna-Enhancements/releases/latest/download/KyoryokunaEnhancements.zip)**

This link always gives the newest version. Don't use the green **Code → Download ZIP** button: that zip has another folder name and the game won't load the addon.

## Install

1. Close the game.
2. Unzip `KyoryokunaEnhancements.zip` into the game's addons folder:
   `World of Warcraft\_forever_\Interface\AddOns`
3. Check that you get: `Interface\AddOns\KyoryokunaEnhancements\KyoryokunaEnhancements.toc`
4. Start the game and type **`/ke`** to open the options.

## Update

1. Close the game.
2. Delete the old folder `Interface\AddOns\KyoryokunaEnhancements`.
3. Download the zip again (same link above) and unzip it as in **Install**. Check that `KyoryokunaEnhancements.toc` is directly inside `Interface\AddOns\KyoryokunaEnhancements`, not in a folder inside it.
4. Your settings are **kept**: the game stores them in another folder (`WTF`). When it opens, the addon shows what's new in the new version.

Tip: before updating, you can back up your settings in `/ke` → **Import / Export**.

## If something goes wrong

The addon keeps the errors it meets in its saved data. Send the file `World of Warcraft\_forever_\WTF\Account\<your account>\SavedVariables\KyoryokunaEnhancements.lua` with a short description of what happened.

## What's new

Every version and what changed in it are in the [CHANGELOG](CHANGELOG.md) and on the [Releases](https://github.com/Pragas/WoW-Forever-Kyoryokuna-Enhancements/releases) page.

---

Copyright (c) 2026 Pragas. All Rights Reserved. Free for personal use; see [LICENSE](LICENSE). The proc alerts are based on [SpellActivationOverlay](https://github.com/ennvina/spellactivationoverlay) by ennvina, used under the MIT License (its notice is in the LICENSE). World of Warcraft is a trademark of Blizzard Entertainment, Inc. This addon is not affiliated with or endorsed by Blizzard Entertainment.
