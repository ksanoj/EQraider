# EQRaider

EQRaider is a toolkit for modern EverQuest raiding with bot control and synchronized raid features. It provides dynamic combat behavior, group buffing, raid burn modes, and a set of commands to control your raid bots.
Settings are based on the serverwide top 5 race guilds

---

## Features

### Dynamic combat capabilities
- assistrange — distance at which bots will engage a target
- Combat camp range — how far bots may move from the camp spot
- Combat range — distance to start attacking
- Range mode — enable/disable melee or change range behavior
- Set/Change MA — change main assist on the fly; each bot can have a unique MA
- Engage mode — controls how bots melee a target (for example, always from behind)
- Balancing — maintain DPS balance and avoid dropping below a configured minimum

### Combat & buffs
- Combat spell casting
- Combat buff casting
- Buff tracking GUI — tracks missing buffs across your army
- Simple MGB — one command issues a full mgb cycle

### Raidburns
Synchronized raidburns across toons to maximize DPS. Preset modes:
- All-in — for fights that die under ~3 minutes
- 10m — optimize DPS over ~10 minutes
- 30m — optimize DPS over ~30 minutes

---

## Commands

Commands are shown with their usage and a brief description.

### Combat & Targeting
```
rddps <on/off>              — Toggle DPS for shamans
rdattack <targetname>       — Bots attack the specified target
rdattack clear              — Clear forced target
rdsetnewma <playername>     — Set new main assist (MA)
rdbalance <on/off>          — Toggle DPS balancing mode
rdassrange <number>         — Set assist range (distance to start attacking)
rdstickrange <number>       — Set stick range (melee distance)
rdhealtarget <name>         — Set primary heal target for clerics
```

### Movement & Positioning
```
rdcamp <on/off>             — Enable/disable camping at current location
rdcamprad <number>          — Set camp radius (how far bots can move from camp)
rdrangemode <mode>          — Set range behavior mode
/rangemode <mode>           — Direct slash command for range mode
rdstickloose                — Set loose stick mode
rdstickbehind               — Set stick behind mode
rdpause <on/off>            — Pause/unpause bot operations
/rdpause <on/off>           — Direct slash command for pause/unpause
```

---

## Community & Support

Class automation is not public yet.

**Discord:** https://discord.gg/86p3hbYW

If you are a hardcore EQ fan, consider donating to the EQ4Fans project: https://gofund.me/b4b3a4ac5
