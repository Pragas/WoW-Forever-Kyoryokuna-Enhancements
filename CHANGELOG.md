# Kyoryokuna Enhancements - Changelog

Copyright (c) 2026 Pragas. All Rights Reserved.

Versions follow MAJOR.MINOR.PATCH:

- **PATCH**: bug fixes only;
- **MINOR**: new features or options;
- **MAJOR**: big changes, e.g. ones that need setting the addon up again.

## 0.14.0

- Trainer: removed "Tell me when I reach the level of new spells" and "Show a Trainer tab in the spellbook", with all their code: the spellbook's tab (`Modules\SpellbookTab.lua`), the reading of the trainer's whole list at each visit (its filters turned on and put back, the spells for later levels and the learned ones, the trainers told apart), the lists kept for each character (`characters[...].trainer`, `trainerVisits`) and for each class (`trainerClasses`), the new spells told in the chat at a level up and the "Waiting at your trainer" list on the Trainer page. Those lists are taken out of the saved variables when the addon loads, and the two settings with them (also from an imported code).
- The Trainer page keeps "Choose the spells to learn" (the boxes at the class trainer and "Learn ticked") and "Put new ranks on the action bars", as before.
- Tests: the trainer's test covers the boxes and "Learn ticked" only, and that the old lists and settings are taken out; the spellbook tab's and the visits' tests are gone.

## 0.13.0

- Buttons and dropdowns of the options in the addon's own style, like the window's X and minimize (the same as Kyoryokuna Frames): a dark box with a thin grey border, lighter under the mouse, gold text (a dropdown: its value in white and a small gold arrow drawn with two bars), made of plain colors instead of the game's `UIPanelButtonTemplate` (a thin red bar on this client, 200 wide, where a long value ran out of the button). Dropdowns are 280 wide, and a text too long for its button is cut with "...". The dropdown's list is in the same style (flat dark box, thin grey border, taller rows in the normal font). The welcome window's OK uses the normal font.
- Buttons inside the game's own windows keep the game's look, like the rest of those windows (the button in Options → AddOns, the trainer's Learn).
- Fixed: the **Move** button of FPS and latency and of proc alerts didn't change its text when clicked (only when the page was drawn again), so it kept saying Move while moving. It now says **Done** right away, as the missing buffs' already did (their module redraws the options when moving starts), and Move again once done: each Move button now redraws the options itself. Closing the options (X, Escape, `/ke`, the minimap button) ends the moving of all three, as before, now tested.

## 0.12.0

- General page, "Game menu": a smaller game menu (Escape), at the size chosen with a slider (50% to 100% of the game's own, 75% by default; off by default). It's set a little higher on the screen, so its top stays about where the game's own menu starts (65 points up at 75%, in the menu's units). Turned off, the game's own size and place come back (only if the addon had changed them). The game never places the menu nor changes its size again after loading (UIPanelWindows: area "center" with centerFrameSkipAnchoring, no checkFit), so it's set when the game starts, at each change, and each time the menu shows. In a fight, if the menu were protected, it would wait for the fight's end. Part of the Import / Export code and the backups.

## 0.11.1

- Trainer: the trainer's list is read when the game sends it, not at the start of the visit. In WoW Forever the list is empty at TRAINER_SHOW and a change of the trainer's filters only shows with the next TRAINER_UPDATE (Blizzard_TrainerUI waits for it too: filterPending), so the whole list was never read at the start: the class's list stayed empty, and the character's own was only filled by the updates that followed, with the trainer's filters as the player had them. Now the "Available", "Unavailable" and "Used" filters that are off are turned on at the start of the visit and the list is read each time it comes (TRAINER_UPDATE): the first reading of a visit starts the lists again, the next ones add to them. The filters are put back as they were as soon as the list has come with their spells (half a second after the first reading, after one more, when it has none of that kind; also when the trainer is closed before). The "Used" filter is only turned on while the class's list doesn't have the learned spells yet: once it has read them ("complete"), it's never turned on again and the class's list is added to at each visit, not started again (the spells learned later were on the trainer's list before), so the learned spells don't flash on the trainer's window. The last visit's list is no longer wiped before the new one has come. The list is read again once its names and ranks have loaded (TRAINER_SERVICE_INFO_NAME_UPDATE, one event per line: a single reading 0.3 s after the last).
- Trainer: a line read before the game has its rank's text came without a rank: kept as another spell ("Mage Armor" beside "Mage Armor Rank 3", same spell), so it showed twice, and the first rank of the spell seemed taught by the trainer: "Pyroblast" without a rank made Pyroblast's ranks show again for a frost mage. Now the rank comes from the spell itself when the line has none (C_Spell.GetSpellSubtext), a line without a rank beside ranks of the same spell is left out (when read, and when shown, for the lists kept before), and such a line never counts as a first rank.
- Trainer: the trainer gives no level for a spell already learned (0): it's now the level the game says the spell is learned at (C_Spell.GetSpellLevelLearned), or the one kept before; shown at level 1 if still unknown.
- Trainer: every trainer that opens the class trainer's window counts, each with its own spells. In WoW Forever the weapon masters, the riding trainers and the mage's portal trainer open it too, and the game calls them class trainers: a visit to one of them replaced the whole list with its few spells (only "Portal: Ironforge" after the portal trainer). Each kept spell now says its trainer ("from", the trainer's name) and the group the trainer's window gives it ("category", the 6th value of GetTrainerServiceInfo); a visit starts only that trainer's spells again, and the lists shown put every trainer's together: the character's own spells from the trainers it has been to, and its class's from the others. The character's trainers (trainerVisits: name -> place) and the class's (visits: name -> place and who went) replace the single last visit, and the class's list is "complete" per trainer. The spellbook's tab names the trainer with the most spells, then "And also:" the others. The lists kept before are given to the trainer of their last visit.
- Trainer: a rank needing the rank before it no longer keeps that as a requirement when the readings after the filters went back no longer show the first rank: the spells taught from their first rank are those on the list now and those kept for the class during the visit. When shown, a requirement the trainer teaches from its first rank never hides a spell (for the lists kept before).

## 0.11.0

- Trainer tab in the spellbook:
  - A search box (the game's SearchBoxTemplate) beside the line that says where the list comes from. As you type, only the spells whose name (with its rank) has the text stay, under their levels: "Mage Armor" shows Rank 1 at level 34, Rank 2 at 46, Rank 3 at 58. Not case sensitive; emptied when the tab closes; says so when nothing matches.
  - At the bottom, under a thin line, the cost of what's listed: what can be learned now (level reached) and all of the list. Both follow the search.
- Trainer: the trainer's whole list is also kept for the class, on the account (trainerClasses, by class file name): every spell of the trainer, the learned ones too (its "Used" filter is turned on for the reading as well, and put back). A character of that class with no list of its own (it hasn't been to its trainer since the option was on) uses it, less what it knows already, for the spellbook's tab, the page and the level-up message. The tab and the page then say whose visit it was. Its first visit gives it its own list, as before. Talent requirements are kept for the class whoever has them, and checked against each character's spellbook.
- Trainer: a spell already learned leaves the list without a visit: its spell known (C_SpellBook.IsSpellKnown), or in the spellbook (a spell without ranks by its name; a rank when the book has it or a higher one, from the book's rank text). Before, a spell learned at the trainer with its "Used" filter off stayed listed until the next visit.
- Not in the Import / Export code nor in the backups (it's game data, not settings).

## 0.10.2

- Trainer: the spells kept from the trainer's list that the character can't learn are left out of the spellbook's tab, the page and the level-up message. A spell is left out when it needs an ability the character doesn't have and the trainer doesn't teach from its first rank (the trainer's own requirement, GetTrainerServiceAbilityReq, kept at each visit), or when it's a higher rank of a spell the character doesn't have whose first rank the trainer doesn't teach (a talent, or another specialization's spell: Pyroblast, Blast Wave, Arcane Blast or Arcane Wrath for a frost mage). The character's spells are read from its spellbook (its own specialization's), so once it has such a spell, its ranks show again. Works at once with the list kept before (no visit needed).

## 0.10.1

- Proc alerts: a proc can say which stacks its test shows (each proc's "Test", "Test all", and the art shown while moving), as SpellActivationOverlay's tests do; otherwise its most stacks, as before. Fingers of Frost's test shows one and two charges: both sides, as two charges do in the game (the game's AuraContainer shows each place from its stacks up: Blizzard_CustomAuraButton, applications >= minApplications), instead of the right one only.
- Proc alerts: Heating Up's three pieces are now the same art at the same size and place (before: 0.6, 0.8 and 1.0). The game shows each piece from its stacks up, so at 3 stacks all three showed at once, three wings of different sizes on each side. Now they lie on top of each other and look like one that gets stronger: one stack faint (alpha 100, grey 200), two stronger (another alpha 100, grey 222), three (Hot Streak) whole and moving. Its test shows the three, as the game does at 3 stacks.
- Proc Alerts page: "Place on the screen" is the second section, right after turning the alerts on and before the procs of the class.

## 0.10.0

- New "Trainer" page:
  - "Choose the spells to learn": at a class trainer, each spell that can be learned gets a box (on the game's own rows, through a hook on ClassTrainerFrame_InitServiceButton), and a "Learn ticked (N)" button sits next to the trainer's filter. Only the ticked spells are learned, one after another: the next is asked once the game has taught the one before (or after 3 seconds, leaving it ticked). Spells that can't be paid are left ticked; the button's tooltip lists the ticked spells and their total. Profession and pet trainers are left as they are, and the game's Train button works as always. Ticks last for the visit.
  - "Tell me when I reach the level of new spells": at each visit to the class trainer its whole list is kept for the character (the trainer's "Unavailable" filter is turned on for the reading and put back), and updated as spells are learned. On level up, the chat lists the spells that level brings. The page lists the spells that can be learned now and the next three levels'.
  - "Show a Trainer tab in the spellbook" (Modules\SpellbookTab.lua): one more tab after the spellbook's own (made with their template, SpellBookCategoryTabTemplate, next to CategoryTabSystem). A click on it shows, over the book's pages, the spells still to learn at the class trainer by level (the ones in reach now in green, the next levels' greyed), each with its icon, name, rank and cost, and its tooltip (the spell from C_TooltipInfo.GetTrainerService, kept at the visit); and the trainer and place of the last visit. The book is never changed: its pages and search box are only made invisible (alpha) and covered while the tab is open, and the game's tabs only lose their selected look (textures); another tab (hooks on CategoryTabSystem.SetTab and OnActiveCategoryChanged) or the book closing brings everything back. The list kept at each visit now has each spell's cost, icon and spell, and the trainer's name and place.
  - "Put new ranks on the action bars" (Modules\NewRanks.lua): when a new rank of a spell is learned (LEARNED_SPELL_IN_SKILL_LINE, or LEARNED_SPELL_IN_TAB), the action buttons (slots 1 to 180) with the highest lower rank of that spell get the new rank (C_Spell.PickupSpell, PlaceAction, ClearCursor); lower ranks kept on purpose stay, macros aren't touched, and the chat says what was replaced. Ranks are read from the spell's text (C_Spell.GetSpellSubtext), half a second after learning, tried again while the game hasn't loaded it. Not in combat (then when the fight ends), nor while the cursor holds something (tried again a second later).
- New "FPS and Latency" page: a small text with the FPS (GetFramerate) and the latency (GetNetStats: world, home or both), read once a second. FPS and latency, or only one of them; colored by value (FPS under 60 and 30, latency over 100 and 200 ms); text size and color; a dark background with a border. Moved with "Move" (a green frame to drag; ends with the options) and "Reset position"; the mouse goes through it otherwise.
- New "Quest Sparkles" page: keeps the game's outlineModeShowLootEffectWhenDisabled on, so lootable quest items sparkle. Set at login, again 5 seconds later, and a second after a change of the graphics quality (or of the setting itself, CVAR_UPDATE); in combat, once the fight ends. Turned off, the setting goes back off if the addon had turned it on, and the chat says the sparkles already shown go only with a restart of the game.

## 0.9.0

- New "Error Messages" page (second, after Queue): the game's red messages in the middle of the screen can be hidden by kind, each its own tick (all off at first): not ready yet (spell, ability, item cooldown), not enough mana, rage or energy (or combo points), out of range, not in line of sight, facing the wrong way, no or wrong target, another action in progress, can't do that while moving; or every one ("Hide every error message"). "Only in combat" keeps them all out of combat. Only the text of a hidden message is hidden: the addon plays its sound or voice itself, as the game's frame would (GetGameMessageInfo). "Silence the voice of the messages" turns off the game's own error speech (Sound_EnableErrorSpeech) for every message, and turns it back on when unticked (kept across sessions).
- How: with the filter on, the addon takes the game's UI_ERROR_MESSAGE instead of the game's error frame and hands on only the messages not hidden, which the game's frame then shows and speaks as usual; of a hidden one it plays the sound itself (C_Sound.PlayVocalErrorSound for a voice, else PlaySound). A message is told by its type (LE_GAME_ERR_...) or by its text (the game's own strings, so in any language). Nothing protected is touched. Off, the game's frame has the event again.

## 0.8.4

- Removed /ke procscan armor and /ke procscan fof, the checks used once to find why Fingers of Frost didn't show in combat. /ke procscan, watch, find and all stay.

## 0.8.3

- Proc alerts: the spell IDs of each proc are again only the ones known to be the proc. The other spells of the same name (found with /ke procscan all) were tried and taken out: some are auras always on, and one of them left the Clearcasting art on the screen all the time.
- Fixed: the proc alerts the game shows itself (auras hidden from addons, like Fingers of Frost in combat) never showed since 0.8.0. The game refuses to show or hide one of its frames with secret values once an addon listens to it ("Cannot be called with secrets due to existing script handlers"), and "Appear softly" listened to the bar of the art. Nothing listens to the game's frames any more; "Appear softly" now only fades in the art the addon draws itself. Fingers of Frost also asks for exact stacks, one charge on the left, two on the right, as the addon that works in WoW Forever does, with its own ID 400670 only.

## 0.8.2

- /ke procscan all: every proc of every class at once. One pass over the spell IDs asks the game the name of each and keeps those named like a proc (its English name or its name in the game's language), each marked passive or not (a talent always on, which can't be a proc's aura). Works on any character (the game knows every class's spells), takes 10 to 20 seconds without freezing the game, sums up in the chat and keeps the list in the saved data (procScan), so the right WoW Forever IDs can be given to every proc without playing each class.

## 0.8.1

- /ke procscan: what the proc alerts know now (whether the game's AuraContainer was made, and for each proc ticked: how secret the game says its aura is, whether the game shows it, and what the addon can read of it), to find why a proc doesn't show.
- Proc alerts in combat: the frames the game fills come again from the template file of 0.7.0 (its parts: the bar the game shows, the art, a cooldown that draws nothing), to rule it out as the reason the real Fingers of Frost didn't show. The code only makes the parts itself if the game gave none.
- Fixed: in combat the game refuses to give hidden auras (an error, not a hidden value); the missing buffs recorded it as an error every time. They now take it as "hidden" and keep what they last knew.
- Fingers of Frost: WoW Forever has four spells of that name (asked of the game with /ke procscan find): the alert now also follows 400669 and 401741 (400670, the one used before, never fired; 400647 is the talent itself, left out).
- /ke procscan watch (the game's own spell alerts written in the chat as they come), /ke procscan armor and /ke procscan fof (checks of the game's container), /ke procscan find <name> (every spell ID with that name).

## 0.8.0

- Proc alerts, "Animation" (instead of the "Pulse" check; one that was on is now Pulse): None (default), Pulse (grows and comes back), Breathe (fades a little and comes back, same size), Blink (fades out fast and back, then waits) or Float (rises and comes back down). "Speed (one cycle)", 0.5 to 3 seconds (1 by default, as the game's own spell alerts), and "Strength", 2% to 20% (8% by default): how much it grows, fades or rises. Procs that stay still in the game still do. "Appear softly" (off at first): the art fades in when the proc comes, also the art the game shows in combat. Every animation is the addon's own, made once for each setting.

## 0.7.1

- Proc alerts: the pulse of the art and the frames the game fills in combat are now made by the addon's own code (the XML file only names the frame the game needs). The pulse has the rhythm of the game's own spell alerts: the art grows 8% in half a second and comes back in the next half.

## 0.7.0

- Proc alerts, phase 3: glowing buttons. While an ability can be used, its button on the game's action bars glows (the main bar, the bottom, side and extra bars; the ability itself or a macro that casts it), with the game's spell alert art (a gold glow and its running "ants"). The glow is the addon's own frame on the button: the button is never changed, so it works in combat.
  - Abilities that only light their button (each off at first): Ice Barrier (mage, in combat), Overpower, Execute and Revenge (warrior), Counterattack (hunter), Holy Shock (in combat), Exorcism (in combat, on a demon or an undead that can be attacked) and Hammer of Wrath (paladin), Stormstrike (shaman, in combat). Marked "button glows" on the page.
  - Abilities with art and a button (Victory Rush, Riposte, Mongoose Bite): an "Alert" choice beside each, Art (default, as before), Button or Both. Nothing else lights a button unless ticked, so the bars never glow all over.
- Proc alerts: "Move" and "Reset position" (Place on the screen), as for missing buffs: a green frame, above the options, to drag the alerts anywhere (kept as a distance from the middle of the screen, x and y), showing a proc with art meanwhile; it ends with the options. They replace the "Height" slider.
  - Any rank counts: a higher rank (another ID) on a bar is the one looked at.
  - The tests ("Test" and "Show") make the buttons of an ability glow too.
  - The buttons of other action bar addons (Bartender, Dominos...) don't glow yet.

## 0.6.0

- Proc alerts, phase 2: every class of WoW Forever (each one off at first; a character sees only its class's):
  - Druid: Eclipse (one aura whose stacks tell lunar, on the left, or solar, on the right; small, then full), Omen of Clarity, Nature's Grace (on top).
  - Hunter: Rapid Killing; Mongoose Bite when usable, in combat (on top, turned).
  - Paladin: Infusion of Light (both of its IDs).
  - Priest: Martyrdom (blue, no pulse), Searing Light (on top).
  - Rogue: Remorseless Attacks, Cutthroat; Riposte when usable (on top, turned).
  - Shaman: Maelstrom Weapon (on top, lighter with each stack, whole at 5).
  - Warlock: Nightfall, Decimation (on top), Eye of Kilrogg (green, on top).
  - Warrior: Victory Rush when usable (red, on top).
  - Omen of Clarity always has the same art (also in cat and bear form). Reactive abilities without art (Overpower, Execute, Revenge, Counterattack, Holy Shock, Exorcism, Hammer of Wrath, Stormstrike, Ice Barrier) only light their button: they come with the glowing buttons (phase 3).
- "When usable" abilities ("counter"): shown while the ability is known, not on cooldown (the global one aside) and usable, or only short of rage or energy; looked at again on what's usable, cooldowns, combat and the target, and when a cooldown ends. What the game hides in combat keeps the last answer.
- New places for the art: on top of the character (wide and low), and on top turned a quarter clockwise; and art can have a color and a transparency of its own.
- "Test" beside each proc (it reads "Close test" while on): a fixed test that keeps that proc's alert on the screen (at its most stacks, with its name) while the look is set; again to hide it, or another proc's to switch. It shows even with the alerts off, and ends with the options window. The turning "Test all" replaces it.

## 0.5.1

- Options: the pages in a new order, the simplest first: General, Queue, Experience Bar, Supplies, Proc Alerts, Action Bars, Dark Mode, Missing Buffs, then Import / Export and About.

## 0.5.0

- New "Supplies" page (third in the list): macros of food and drink, made and kept up to date by the addon. Each character ticks the ones it wants (none at first; kept for that character, not in Import / Export):
  - "KE Food": eats the best food in the bags; "KE Drink": drinks the best drink; "KE Food+Drink": both at once (sitting, both bars fill together), with the food's icon or the drink's ("Icon" beside it; the food's by default). Named in the addon's language (KE Comida, KE Água, KE Comida+Água in Portuguese).
  - Any food or drink counts, bought, looted or conjured, for every class: an item is food or drink by the spell it casts when used ("Food" or "Drink", in the game's language). The best is the one with the highest level needed that the character can already use, conjured first when even; when it runs out, the next one.
  - Food that makes you well fed (its tooltip says so) is left in the bags, unless "Use food with a buff too" is on.
  - With nothing in the bags, a mage's macro conjures more with the highest rank known (water first for the one that does both), through a hidden button that casts that exact rank; anyone else's says in the chat there's none.
  - The macros are this character's (/macro), dragged to an action bar once. The addon rewrites them as the bags change, at a new level, with a new spell, and renames them with the language. Blizzard's API doesn't let addons change macros in combat: they follow when the fight ends. A macro unticked is deleted. With no room in the character's macros (18), the chat says so.
  - Beside each one ticked, "Pick up" puts the macro on the mouse, to click an empty slot of an action bar: no need to open the macros window. The page also shows what the macros use now, and a button opens the macros window.

- New "Proc Alerts" page (phase 1, the mage): when a proc happens, the game's own spell alert art shows on the sides of the character, as in the newer game. Made for WoW Forever.
  - Mage: Missile Barrage (Arcane Missiles art on both sides), Clearcasting (an arc on both sides, no pulse), Fingers of Frost (one charge on the left, two on both sides) and Heating Up (grows with its stacks; at 3, Hot Streak, it's whole and pulses). Each one ticked on its own (all off at first). Ice Barrier, which only lights its button, comes with the glowing buttons (phase 3).
  - In combat WoW Forever hides many auras from addons. For those (the game says which, C_Secrets), the addon asks the game's own AuraContainer to show the art while the aura is there with the stacks asked for, so the alerts keep working in combat. Auras the addon can read are shown by the addon itself.
  - Look: size (50% to 200%), distance between the sides, height, opacity (80% by default) and the pulse (off at first). "Test" shows each proc of the class in turn with its name, shrinking the options meanwhile.
  - The page warns when the game's own spell alerts (Spell Alert Opacity) are on, with a button to turn them off, and when SpellActivationOverlay is on: either would show the alerts twice.
  - The art is the game's own (file IDs): the addon ships none.

## 0.4.0

- A welcome window over the options, as in Kyoryokuna Plates: the first time the addon is opened (what it is, how to start), and after each update (what's new and what was fixed in every version since the last one seen), with the known issues (limits of the game itself) under it. Its OK shows the first page, and it doesn't come back until the next version. The About page has a "See what's new" button to show it again. After an update, a message in the chat a few seconds after logging in says so (on the first install, how to open the options). The notes are short texts for the player (Core\ReleaseNotes.lua), in English and Portuguese.
- About page: "What it is" now says what the addon does.
- Queue page: its text no longer speaks of dungeons. WoW Forever has no dungeon finder (groups are made by hand and walk in), so only battlegrounds, which do have a queue, show the time left.

- Missing buffs, each group's look: "Number size", the size of the number on a conjured item's icon (14 by default, as before; 8 to 40).
- Missing buffs page: "Place on the screen" (Move, Reset position) is now right under "Show what's missing", so the groups can be put in place first and then set up.
- Options window: a button beside the X (a minus) shrinks the window to its title bar, so what's on the screen (e.g. the missing buffs groups while moving them) can be seen and dragged; the same button (now a plus) brings it back as it was. The title bar stays where it is, and can still be dragged. Moving the missing buffs goes on while it's minimized. The window always opens whole. It keeps its width: only its height shrinks.
- Options window: the X has the same new look as the minimize button beside it, a small dark square with a gold sign.

## 0.3.1

- Fixed: a click on an icon could cast a lower rank (e.g. Conjure Water rank 3 with rank 4 known). A new rank of a spell already known (same name) wasn't noticed until a /reload, and the "highest" rank was the last one listed in the spellbook, which doesn't always list them in order. Now a conjured item's rank is found from the addon's list of ranks (checked on Wowhead), from the highest down, asking the game which one the character knows; a buff's rank comes from the spellbook (or the text under the spell's name). The list follows a new rank at once, and a click casts that exact rank (by its ID). `/ke buffscan` also shows what a click on each icon casts, with its ID.

- Missing buffs, conjured items: "Click an icon to conjure the item" (off by default). A click on the icon of a missing conjured item casts the spell that makes it, with the best rank known; its tooltip shows on hover. And "Click an icon to cast the buff" (off by default), in both groups: a click on a missing buff's icon casts it on you, whoever is targeted (for a family, the spell of the icon picked, else the one used last). In combat Blizzard's API doesn't let addons change clickable buttons: an icon already there when the fight starts still works, one that shows during it becomes clickable when the fight ends. The page says so under both options.

- Action Bars page: the cooldown numbers colored by the time left (off by default). One color while the cooldown is long (red by default), another for its last seconds (a toasted yellow by default), both changeable, and when the color changes (5 seconds by default, 1 to 30). The game writes the numbers with the addon's rules, so it works in combat too: the addon never reads the time left.

- New defaults: a new install starts with only the minimap button on, in English. Everything else is off (dark mode and each of its parts, the queue timer and its bar, missing buffs), for each player to turn on what they want. Settings already saved don't change.
- Missing buffs are never in the Import / Export code nor in the backups: which ones, and where and how they show, are each player's own. Importing a code or restoring a backup no longer changes them.
- The number on a conjured item's icon: no number when there are none (an option of each group turns it back on), and it can be in any corner (bottom right, bottom left, top right, top left) or in the middle.

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
