local ItemDefs = {}

function ItemDefs:DefineItems()
    items = {
        -- Ansem Reports
        {ID = 226, Name = "Secret Ansem's Report 1",  Ability = "false", Address = 0x36C4, Bitmask = 6},
        {ID = 227, Name = "Secret Ansem's Report 2",  Ability = "false", Address = 0x36C4, Bitmask = 7},
        {ID = 228, Name = "Secret Ansem's Report 3",  Ability = "false", Address = 0x36C5, Bitmask = 0},
        {ID = 229, Name = "Secret Ansem's Report 4",  Ability = "false", Address = 0x36C5, Bitmask = 1},
        {ID = 230, Name = "Secret Ansem's Report 5",  Ability = "false", Address = 0x36C5, Bitmask = 2},
        {ID = 231, Name = "Secret Ansem's Report 6",  Ability = "false", Address = 0x36C5, Bitmask = 3},
        {ID = 232, Name = "Secret Ansem's Report 7",  Ability = "false", Address = 0x36C5, Bitmask = 4},
        {ID = 233, Name = "Secret Ansem's Report 8",  Ability = "false", Address = 0x36C5, Bitmask = 5},
        {ID = 234, Name = "Secret Ansem's Report 9",  Ability = "false", Address = 0x36C5, Bitmask = 6},
        {ID = 235, Name = "Secret Ansem's Report 10", Ability = "false", Address = 0x36C5, Bitmask = 7},
        {ID = 236, Name = "Secret Ansem's Report 11", Ability = "false", Address = 0x36C6, Bitmask = 0},
        {ID = 237, Name = "Secret Ansem's Report 12", Ability = "false", Address = 0x36C6, Bitmask = 1},
        {ID = 238, Name = "Secret Ansem's Report 13", Ability = "false", Address = 0x36C6, Bitmask = 2},

        --Progression
        {ID = 593, Name = "Proof of Connection",      Ability = "false", Address = 0x36B2},
        {ID = 594, Name = "Proof of Nonexistence",    Ability = "false", Address = 0x36B3},
        {ID = 595, Name = "Proof of Peace",           Ability = "false", Address = 0x36B4},
        {ID = 524, Name = "Promise Charm",            Ability = "false", Address = 0x3694},
        {ID = 368, Name = "Namine Sketches",          Ability = "false", Address = 0x3642},
        {ID = 460, Name = "Disney Castle Key",        Ability = "false", Address = 0x365D}, --dummy 13
        {ID = 54,  Name = "Battlefields of War",      Ability = "false", Address = 0x35AE},
        {ID = 55,  Name = "Sword of the Ancestor",    Ability = "false", Address = 0x35AF},
        {ID = 59,  Name = "Beast's Claw",             Ability = "false", Address = 0x35B3},
        {ID = 60,  Name = "Bone Fist",                Ability = "false", Address = 0x35B4},
        {ID = 61,  Name = "Proud Fang",               Ability = "false", Address = 0x35B5},
        {ID = 62,  Name = "Skill and Crossbones",     Ability = "false", Address = 0x35B6},
        {ID = 72,  Name = "Scimitar",                 Ability = "false", Address = 0x35C0},
        {ID = 369, Name = "Membership Card",          Ability = "false", Address = 0x3643},
        {ID = 375, Name = "Ice Cream",                Ability = "false", Address = 0x3649},
        {ID = 73,  Name = "Way to the Dawn",          Ability = "false", Address = 0x35C1},
        {ID = 74,  Name = "Identity Disk",            Ability = "false", Address = 0x35C2},
        {ID = 32,  Name = "Torn Page",                Ability = "false", Address = 0x3598},

        --Forms
        {ID = 26,  Name = "Valor Form",               Ability = "false", Address = 0x36C0, Bitmask = 1},
        {ID = 27,  Name = "Wisdom Form",              Ability = "false", Address = 0x36C0, Bitmask = 2},
        {ID = 563, Name = "Limit Form",               Ability = "false", Address = 0x36CA, Bitmask = 3},
        {ID = 31,  Name = "Master Form",              Ability = "false", Address = 0x36C0, Bitmask = 6},
        {ID = 29,  Name = "Final Form",               Ability = "false", Address = 0x36C0, Bitmask = 4},
        {ID = 30,  Name = "Anti Form",                Ability = "false", Address = 0x36C0, Bitmask = 5},

        --Magic
        {ID = 21, Name = "Fire Element",              Ability = "false", Address = 0x3594},
        {ID = 22, Name = "Blizzard Element",          Ability = "false", Address = 0x3595},
        {ID = 23, Name = "Thunder Element",           Ability = "false", Address = 0x3596},
        {ID = 24, Name = "Cure Element",              Ability = "false", Address = 0x3597},
        {ID = 87, Name = "Magnet Element",            Ability = "false", Address = 0x35CF},
        {ID = 88, Name = "Reflect Element",           Ability = "false", Address = 0x35D0},

        --Summons
        {ID = 159,Name = "Genie",                     Ability = "false", Address = 0x36C4, Bitmask = 4},
        {ID = 160,Name = "Peter Pan",                 Ability = "false", Address = 0x36C4, Bitmask = 5},
        {ID = 25, Name = "Stitch",                    Ability = "false", Address = 0x36C0, Bitmask = 0},
        {ID = 383,Name = "Chicken Little",            Ability = "false", Address = 0x36C0, Bitmask = 3},

        --Keyblades
        {ID = 42,  Name = "Oathkeeper",               Ability = "false", Address = 0x35A2},
        {ID = 43,  Name = "Oblivion",                 Ability = "false", Address = 0x35A3},
        {ID = 480, Name = "Star Seeker",              Ability = "false", Address = 0x367B},
        {ID = 481, Name = "Hidden Dragon",            Ability = "false", Address = 0x367C},
        {ID = 484, Name = "Hero's Crest",             Ability = "false", Address = 0x367F},
        {ID = 485, Name = "Monochrome",               Ability = "false", Address = 0x3680},
        {ID = 486, Name = "Follow the Wind",          Ability = "false", Address = 0x3681},
        {ID = 487, Name = "Circle of Life",           Ability = "false", Address = 0x3682},
        {ID = 488, Name = "Photon Debugger",          Ability = "false", Address = 0x3683},
        {ID = 489, Name = "Gull Wing",                Ability = "false", Address = 0x3684},
        {ID = 490, Name = "Rumbling Rose",            Ability = "false", Address = 0x3685},
        {ID = 491, Name = "Guardian Soul",            Ability = "false", Address = 0x3686},
        {ID = 492, Name = "Wishing Lamp",             Ability = "false", Address = 0x3687},
        {ID = 493, Name = "Decisive Pumpkin",         Ability = "false", Address = 0x3688},
        {ID = 494, Name = "Sleeping Lion",            Ability = "false", Address = 0x3689},
        {ID = 495, Name = "Sweet Memories",           Ability = "false", Address = 0x368A},
        {ID = 496, Name = "Mysterious Abyss",         Ability = "false", Address = 0x368B},
        {ID = 543, Name = "Two Become One",           Ability = "false", Address = 0x3698},
        {ID = 497, Name = "Fatal Crest",              Ability = "false", Address = 0x368C},
        {ID = 498, Name = "Bond of Flame",            Ability = "false", Address = 0x368D},
        {ID = 499, Name = "Fenrir",                   Ability = "false", Address = 0x368E},
        {ID = 500, Name = "Ultima Weapon",            Ability = "false", Address = 0x368F},
        {ID = 544, Name = "Winner's Proof",           Ability = "false", Address = 0x3699},
        {ID = 71,  Name = "Pureblood",                Ability = "false", Address = 0x35BF},

        --Staves
        {ID = 546, Name = "Centurion+",               Ability = "false", Address = 0x369B},
        {ID = 150, Name = "Meteor Staff",             Ability = "false", Address = 0x35F1},
        {ID = 155, Name = "Nobody Lance",             Ability = "false", Address = 0x35F6},
        {ID = 549, Name = "Precious Mushroom",        Ability = "false", Address = 0x369E},
        {ID = 550, Name = "Precious Mushroom+",       Ability = "false", Address = 0x369F},
        {ID = 551, Name = "Premium Mushroom",         Ability = "false", Address = 0x36A0},
        {ID = 154, Name = "Rising Dragon",            Ability = "false", Address = 0x35F5},
        {ID = 503, Name = "Save The Queen+",          Ability = "false", Address = 0x3692},
        {ID = 156, Name = "Shaman's Relic",           Ability = "false", Address = 0x35F7},

        --Shields
        {ID = 146, Name = "Akashic Record",           Ability = "false", Address = 0x35ED},
        {ID = 553, Name = "Frozen Pride+",            Ability = "false", Address = 0x36A2},
        {ID = 145, Name = "Genji Shield",             Ability = "false", Address = 0x35EC},
        {ID = 556, Name = "Majestic Mushroom",        Ability = "false", Address = 0x36A5},
        {ID = 557, Name = "Majestic Mushroom+",       Ability = "false", Address = 0x36A6},
        {ID = 147, Name = "Nobody Guard",             Ability = "false", Address = 0x35EE},
        {ID = 141, Name = "Ogre Shield",              Ability = "false", Address = 0x35E8},
        {ID = 504, Name = "Save The King+",           Ability = "false", Address = 0x3693},
        {ID = 558, Name = "Ultimate Mushroom",        Ability = "false", Address = 0x36A7},

        --Accessories
        {ID = 8,   Name = "Ability Ring",             Ability = "false", Address = 0x3587},
        {ID = 9,   Name = "Engineer's Ring",          Ability = "false", Address = 0x3588},
        {ID = 10,  Name = "Technician's Ring",        Ability = "false", Address = 0x3589},
        {ID = 38,  Name = "Skill Ring",               Ability = "false", Address = 0x359F},
        {ID = 39,  Name = "Skillful Ring",            Ability = "false", Address = 0x35A0},
        {ID = 11,  Name = "Expert's Ring",            Ability = "false", Address = 0x358A},
        {ID = 34,  Name = "Master's Ring",            Ability = "false", Address = 0x359B},
        {ID = 52,  Name = "Cosmic Ring",              Ability = "false", Address = 0x35AD},
        {ID = 599, Name = "Executive's Ring",         Ability = "false", Address = 0x36B5},
        {ID = 12,  Name = "Sardonyx Ring",            Ability = "false", Address = 0x358B},
        {ID = 13,  Name = "Tourmaline Ring",          Ability = "false", Address = 0x358C},
        {ID = 14,  Name = "Aquamarine Ring",          Ability = "false", Address = 0x358D},
        {ID = 15,  Name = "Garnet Ring",              Ability = "false", Address = 0x358E},
        {ID = 16,  Name = "Diamond Ring",             Ability = "false", Address = 0x358F},
        {ID = 17,  Name = "Silver Ring",              Ability = "false", Address = 0x3590},
        {ID = 18,  Name = "Gold Ring",                Ability = "false", Address = 0x3591},
        {ID = 19,  Name = "Platinum Ring",            Ability = "false", Address = 0x3592},
        {ID = 20,  Name = "Mythril Ring",             Ability = "false", Address = 0x3593},
        {ID = 28,  Name = "Orichalcum Ring",          Ability = "false", Address = 0x359A},
        {ID = 40,  Name = "Soldier Earring",          Ability = "false", Address = 0x35A6},
        {ID = 46,  Name = "Fencer Earring",           Ability = "false", Address = 0x35A7},
        {ID = 47,  Name = "Mage Earring",             Ability = "false", Address = 0x35A8},
        {ID = 48,  Name = "Slayer Earring",           Ability = "false", Address = 0x35AC},
        {ID = 53,  Name = "Medal",                    Ability = "false", Address = 0x35B0},
        {ID = 35,  Name = "Moon Amulet",              Ability = "false", Address = 0x359C},
        {ID = 36,  Name = "Star Charm",               Ability = "false", Address = 0x359E},
        {ID = 56,  Name = "Cosmic Arts",              Ability = "false", Address = 0x35B1},
        {ID = 57,  Name = "Shadow Archive",           Ability = "false", Address = 0x35B2},
        {ID = 58,  Name = "Shadow Archive+",          Ability = "false", Address = 0x35B7},
        {ID = 64,  Name = "Full Bloom",               Ability = "false", Address = 0x35B9},
        {ID = 66,  Name = "Full Bloom+",              Ability = "false", Address = 0x35BB},
        {ID = 65,  Name = "Draw Ring",                Ability = "false", Address = 0x35BA},
        {ID = 63,  Name = "Lucky Ring",               Ability = "false", Address = 0x35B8},

        --Armor
        {ID = 67,  Name = "Elven Bandana",            Ability = "false", Address = 0x35BC},
        {ID = 68,  Name = "Divine Bandana",           Ability = "false", Address = 0x35BD},
        {ID = 78,  Name = "Protect Belt",             Ability = "false", Address = 0x35C7},
        {ID = 79,  Name = "Gaia Belt",                Ability = "false", Address = 0x35CA},
        {ID = 69,  Name = "Power Band",               Ability = "false", Address = 0x35BE},
        {ID = 70,  Name = "Buster Band",              Ability = "false", Address = 0x35C6},
        {ID = 111, Name = "Cosmic Belt",              Ability = "false", Address = 0x35D1},
        {ID = 173, Name = "Fire Bangle",              Ability = "false", Address = 0x35D7},
        {ID = 174, Name = "Fira Bangle",              Ability = "false", Address = 0x35D8},
        {ID = 197, Name = "Firaga Bangle",            Ability = "false", Address = 0x35D9},
        {ID = 284, Name = "Firagun Bangle",           Ability = "false", Address = 0x35DA},
        {ID = 286, Name = "Blizzard Armlet",          Ability = "false", Address = 0x35DC},
        {ID = 287, Name = "Blizzara Armlet",          Ability = "false", Address = 0x35DD},
        {ID = 288, Name = "Blizzaga Armlet",          Ability = "false", Address = 0x35DE},
        {ID = 289, Name = "Blizzagun Armlet",         Ability = "false", Address = 0x35DF},
        {ID = 291, Name = "Thunder Trinket",          Ability = "false", Address = 0x35E2},
        {ID = 292, Name = "Thundara Trinket",         Ability = "false", Address = 0x35E3},
        {ID = 293, Name = "Thundaga Trinket",         Ability = "false", Address = 0x35E4},
        {ID = 294, Name = "Thundagun Trinket",        Ability = "false", Address = 0x35E5},
        {ID = 132, Name = "Shock Charm",              Ability = "false", Address = 0x35D2},
        {ID = 133, Name = "Shock Charm+",             Ability = "false", Address = 0x35D3},
        {ID = 296, Name = "Shadow Anklet",            Ability = "false", Address = 0x35F9},
        {ID = 297, Name = "Dark Anklet",              Ability = "false", Address = 0x35FB},
        {ID = 298, Name = "Midnight Anklet",          Ability = "false", Address = 0x35FC},
        {ID = 299, Name = "Chaos Anklet",             Ability = "false", Address = 0x35FD},
        {ID = 305, Name = "Champion Belt",            Ability = "false", Address = 0x3603},
        {ID = 301, Name = "Abas Chain",               Ability = "false", Address = 0x35FF},
        {ID = 302, Name = "Aegis Chain",              Ability = "false", Address = 0x3600},
        {ID = 303, Name = "Acrisius",                 Ability = "false", Address = 0x3601},
        {ID = 307, Name = "Acrisius+",                Ability = "false", Address = 0x3605},
        {ID = 308, Name = "Cosmic Chain",             Ability = "false", Address = 0x3606},
        {ID = 306, Name = "Petite Ribbon",            Ability = "false", Address = 0x3604},
        {ID = 304, Name = "Ribbon",                   Ability = "false", Address = 0x3602},
        {ID = 157, Name = "Grand Ribbon",             Ability = "false", Address = 0x35D4},

        --Useful
        {ID = 535, Name = "Mickey Munny Pouch",       Ability = "false", Address = 0x3695},
        {ID = 362, Name = "Olette Munny Pouch",       Ability = "false", Address = 0x363C},
        {ID = 537, Name = "Hades Cup Trophy",         Ability = "false", Address = 0x3696},
        {ID = 462, Name = "Unknown Disk",             Ability = "false", Address = 0x365F},
        {ID = 370, Name = "Olympus Stone",            Ability = "false", Address = 0x3644},
        {ID = 112, Name = "Max HP Up",                Ability = "false", Address = 0x3671},  --470 is DUMMY 23, 112 is Encampment Area Map
        {ID = 113, Name = "Max MP Up",                Ability = "false", Address = 0x3672},  --471 is DUMMY 24, 113 is Village Area Map
        {ID = 114, Name = "Drive Gauge Up",           Ability = "false", Address = 0x3673},  --472 is DUMMY 25, 114 is Cornerstone Hill Map
        {ID = 116, Name = "Armor Slot Up",            Ability = "false", Address = 0x3674},  --473 is DUMMY 26, 116 is Lilliput Map
        {ID = 117, Name = "Accessory Slot Up",        Ability = "false", Address = 0x3675},  --474 is DUMMY 27, 117 is Building Site Map
        {ID = 118, Name = "Item Slot Up",             Ability = "false", Address = 0x3660},  --463 is DUMMY 16, 118 is Mickey’s House Map

        --Boosts
        {ID = 253, Name = "Power Boost",              Ability = "false", Address = 0x359D},  --276, 0x3666, market place map
        {ID = 586, Name = "Magic Boost",              Ability = "false", Address = 0x35E0},  --277, 0x3667, dark rememberance map
        {ID = 590, Name = "Defense Boost",            Ability = "false", Address = 0x35F8},  --278, 0x3668, depths of remembrance map
        {ID = 532, Name = "AP Boost",                 Ability = "false", Address = 0x35FE},  --279, 0x3669, mansion map

        --Consumable
        {ID = 127, Name = "Potion",                   Ability = "false", Address = 0x36B8},  --1, 0x3580, piglets house map
        {ID = 126, Name = "Hi-Potion",                Ability = "false", Address = 0x36B9},  --2, 0x03581, rabbits house map
        {ID = 128, Name = "Ether",                    Ability = "false", Address = 0x36BA},  --3, 0x3582, kangas house map
        {ID = 129, Name = "Elixir",                   Ability = "false", Address = 0x36BB},  --4, 0x3583, spooky cave map
        {ID = 124, Name = "Megalixir",                Ability = "false", Address = 0x36BC},  --7, 0x3586, starry hill map
        {ID = 512, Name = "Tent",                     Ability = "false", Address = 0x36BD},  --131,0x35E1, savannah map
        {ID = 252, Name = "Drive Recovery",           Ability = "false", Address = 0x36BE},  --274,0x3664, pride rock map
        {ID = 511, Name = "High Drive Recovery",      Ability = "false", Address = 0x36BF},  --275,0x3665, oasis map

        --Wincon
        {ID = 367, Name = "Lucky Emblem",             Ability = "false", Address = 0x3641}, --letter item
        {ID = 461, Name = "Bounty",                   Ability = "false", Address = 0x365E}, --Dummy 14
    }
  return items
end

function ItemDefs:DefineAbilities()
    abilities = {
        --Movement
        {ID = 94,  Name = "High Jump",             Ability = "Sora", Address = 0x05E},
        {ID = 98,  Name = "Quick Run",             Ability = "Sora", Address = 0x062},
        {ID = 564, Name = "Aerial Dodge",          Ability = "Sora", Address = 0x234},
        {ID = 102, Name = "Glide",                 Ability = "Sora", Address = 0x066},
        {ID = 106, Name = "Dodge Roll",            Ability = "Sora", Address = 0x06A},

        --Support Abilities
        {ID = 138, Name = "Scan",                  Ability = "Sora", Address = 0x08A},
        {ID = 158, Name = "Aerial Recovery",       Ability = "Sora", Address = 0x09E},
        {ID = 539, Name = "Combo Master",          Ability = "Sora", Address = 0x21B},
        {ID = 162, Name = "Combo Plus",            Ability = "Sora", Address = 0x0A2},
        {ID = 163, Name = "Air Combo Plus",        Ability = "Sora", Address = 0x0A3},
        {ID = 390, Name = "Combo Boost",           Ability = "Sora", Address = 0x186},
        {ID = 391, Name = "Air Combo Boost",       Ability = "Sora", Address = 0x187},
        {ID = 392, Name = "Reaction Boost",        Ability = "Sora", Address = 0x188},
        {ID = 393, Name = "Finishing Plus",        Ability = "Sora", Address = 0x189},
        {ID = 394, Name = "Negative Combo",        Ability = "Sora", Address = 0x18A},
        {ID = 395, Name = "Berserk Charge",        Ability = "Sora", Address = 0x18B},
        {ID = 396, Name = "Damage Drive",          Ability = "Sora", Address = 0x18C},
        {ID = 397, Name = "Drive Boost",           Ability = "Sora", Address = 0x18D},
        {ID = 398, Name = "Form Boost",            Ability = "Sora", Address = 0x18E},
        {ID = 399, Name = "Summon Boost",          Ability = "Sora", Address = 0x18F},
        {ID = 401, Name = "Experience Boost",      Ability = "Sora", Address = 0x191},
        {ID = 405, Name = "Draw",                  Ability = "Sora", Address = 0x195},
        {ID = 406, Name = "Jackpot",               Ability = "Sora", Address = 0x196},
        {ID = 407, Name = "Lucky Lucky",           Ability = "Sora", Address = 0x197},
        {ID = 540, Name = "Drive Converter",       Ability = "Sora", Address = 0x21C},
        {ID = 408, Name = "Fire Boost",            Ability = "Sora", Address = 0x198},
        {ID = 409, Name = "Blizzard Boost",        Ability = "Sora", Address = 0x199},
        {ID = 410, Name = "Thunder Boost",         Ability = "Sora", Address = 0x19A},
        {ID = 411, Name = "Item Boost",            Ability = "Sora", Address = 0x19B},
        {ID = 412, Name = "MP Rage",               Ability = "Sora", Address = 0x19C},
        {ID = 413, Name = "MP Haste",              Ability = "Sora", Address = 0x19D},
        {ID = 421, Name = "MP Hastera",            Ability = "Sora", Address = 0x1A5},
        {ID = 422, Name = "MP Hastega",            Ability = "Sora", Address = 0x1A6},
        {ID = 414, Name = "Defender",              Ability = "Sora", Address = 0x19E},
        {ID = 542, Name = "Damage Control",        Ability = "Sora", Address = 0x21E},
        {ID = 541, Name = "Light & Darkness",      Ability = "Sora", Address = 0x21D},
        {ID = 403, Name = "Magic Lock-On",         Ability = "Sora", Address = 0x193},
        {ID = 402, Name = "Leaf Bracer",           Ability = "Sora", Address = 0x192},
        {ID = 400, Name = "Combination Boost",     Ability = "Sora", Address = 0x190},
        {ID = 416, Name = "Once More",             Ability = "Sora", Address = 0x1A0},
        {ID = 415, Name = "Second Chance",         Ability = "Sora", Address = 0x19F},
        {ID = 404, Name = "No Experience",         Ability = "Sora", Address = 0x194},

        --Action Abilities
        {ID = 82,  Name = "Guard",                 Ability = "Sora", Address = 0x052},
        {ID = 137, Name = "Upper Slash",           Ability = "Sora", Address = 0x089},
        {ID = 271, Name = "Horizontal Slash",      Ability = "Sora", Address = 0x10F},
        {ID = 267, Name = "Finishing Leap",        Ability = "Sora", Address = 0x10B},
        {ID = 273, Name = "Retaliating Slash",     Ability = "Sora", Address = 0x111},
        {ID = 262, Name = "Slapshot",              Ability = "Sora", Address = 0x106},
        {ID = 263, Name = "Dodge Slash",           Ability = "Sora", Address = 0x107},
        {ID = 559, Name = "Flash Step",            Ability = "Sora", Address = 0x22F},
        {ID = 264, Name = "Slide Dash",            Ability = "Sora", Address = 0x108},
        {ID = 562, Name = "Vicinity Break",        Ability = "Sora", Address = 0x232},
        {ID = 265, Name = "Guard Break",           Ability = "Sora", Address = 0x109},
        {ID = 266, Name = "Explosion",             Ability = "Sora", Address = 0x10A},
        {ID = 269, Name = "Aerial Sweep",          Ability = "Sora", Address = 0x10D},
        {ID = 560, Name = "Aerial Dive",           Ability = "Sora", Address = 0x230},
        {ID = 270, Name = "Aerial Spiral",         Ability = "Sora", Address = 0x10E},
        {ID = 272, Name = "Aerial Finish",         Ability = "Sora", Address = 0x110},
        {ID = 561, Name = "Magnet Burst",          Ability = "Sora", Address = 0x231},
        {ID = 268, Name = "Counterguard",          Ability = "Sora", Address = 0x10C},
        {ID = 385, Name = "Auto Valor",            Ability = "Sora", Address = 0x181},
        {ID = 386, Name = "Auto Wisdom",           Ability = "Sora", Address = 0x182},
        {ID = 568, Name = "Auto Limit",            Ability = "Sora", Address = 0x238},
        {ID = 387, Name = "Auto Master",           Ability = "Sora", Address = 0x183},
        {ID = 388, Name = "Auto Final",            Ability = "Sora", Address = 0x184},
        {ID = 389, Name = "Auto Summon",           Ability = "Sora", Address = 0x185},
        {ID = 198, Name = "Trinity Limit",         Ability = "Sora", Address = 0x0C6},

        --Donald Abilities
        {ID = 165, Name = "Donald Fire",           Ability = "Donald", Address = 0x0A5},
        {ID = 166, Name = "Donald Blizzard",       Ability = "Donald", Address = 0x0A6},
        {ID = 167, Name = "Donald Thunder",        Ability = "Donald", Address = 0x0A7},
        {ID = 168, Name = "Donald Cure",           Ability = "Donald", Address = 0x0A8},
        {ID = 199, Name = "Fantasia",              Ability = "Donald", Address = 0x0C7},
        {ID = 200, Name = "Flare Force",           Ability = "Donald", Address = 0x0C8},
        {ID = 412, Name = "Donald MP Rage",        Ability = "Donald", Address = 0x19C},
        {ID = 406, Name = "Donald Jackpot",        Ability = "Donald", Address = 0x196},
        {ID = 407, Name = "Donald Lucky Lucky",    Ability = "Donald", Address = 0x197},
        {ID = 408, Name = "Donald Fire Boost",     Ability = "Donald", Address = 0x198},
        {ID = 409, Name = "Donald Blizzard Boost", Ability = "Donald", Address = 0x199},
        {ID = 410, Name = "Donald Thunder Boost",  Ability = "Donald", Address = 0x19A},
        {ID = 413, Name = "Donald MP Haste",       Ability = "Donald", Address = 0x19D},
        {ID = 421, Name = "Donald MP Hastera",     Ability = "Donald", Address = 0x1A5},
        {ID = 422, Name = "Donald MP Hastega",     Ability = "Donald", Address = 0x1A6},
        {ID = 417, Name = "Donald Auto Limit",     Ability = "Donald", Address = 0x1A1},
        {ID = 419, Name = "Donald Hyper Healing",  Ability = "Donald", Address = 0x1A3},
        {ID = 420, Name = "Donald Auto Healing",   Ability = "Donald", Address = 0x1A4},
        {ID = 411, Name = "Donald Item Boost",     Ability = "Donald", Address = 0x19B},
        {ID = 542, Name = "Donald Damage Control", Ability = "Donald", Address = 0x21E},
        {ID = 405, Name = "Donald Draw",           Ability = "Donald", Address = 0x195},

        --Goofy Abilites
        {ID = 423, Name = "Goofy Tornado",         Ability = "Goofy", Address = 0x1A7},
        {ID = 425, Name = "Goofy Turbo",           Ability = "Goofy", Address = 0x1A9},
        {ID = 429, Name = "Goofy Bash",            Ability = "Goofy", Address = 0x1AD},
        {ID = 201, Name = "Tornado Fusion",        Ability = "Goofy", Address = 0x0C9},
        {ID = 202, Name = "Teamwork",              Ability = "Goofy", Address = 0x0CA},
        {ID = 405, Name = "Goofy Draw",            Ability = "Goofy", Address = 0x195},
        {ID = 406, Name = "Goofy Jackpot",         Ability = "Goofy", Address = 0x196},
        {ID = 407, Name = "Goofy Lucky Lucky",     Ability = "Goofy", Address = 0x197},
        {ID = 411, Name = "Goofy Item Boost",      Ability = "Goofy", Address = 0x19B},
        {ID = 412, Name = "Goofy MP Rage",         Ability = "Goofy", Address = 0x19C},
        {ID = 414, Name = "Goofy Defender",        Ability = "Goofy", Address = 0x19E},
        {ID = 542, Name = "Goofy Damage Control",  Ability = "Goofy", Address = 0x21E},
        {ID = 417, Name = "Goofy Auto Limit",      Ability = "Goofy", Address = 0x1A1},
        {ID = 415, Name = "Goofy Second Chance",   Ability = "Goofy", Address = 0x19F},
        {ID = 416, Name = "Goofy Once More",       Ability = "Goofy", Address = 0x1A0},
        {ID = 418, Name = "Goofy Auto Change",     Ability = "Goofy", Address = 0x1A2},
        {ID = 419, Name = "Goofy Hyper Healing",   Ability = "Goofy", Address = 0x1A3},
        {ID = 420, Name = "Goofy Auto Healing",    Ability = "Goofy", Address = 0x1A4},
        {ID = 413, Name = "Goofy MP Haste",        Ability = "Goofy", Address = 0x19D},
        {ID = 421, Name = "Goofy MP Hastera",      Ability = "Goofy", Address = 0x1A5},
        {ID = 422, Name = "Goofy MP Hastega",      Ability = "Goofy", Address = 0x1A6},
        {ID = 596, Name = "Goofy Protect",         Ability = "Goofy", Address = 0x254},
        {ID = 597, Name = "Goofy Protectra",       Ability = "Goofy", Address = 0x255},
        {ID = 598, Name = "Goofy Protectga",       Ability = "Goofy", Address = 0x256},
    }
    return abilities
end

return ItemDefs