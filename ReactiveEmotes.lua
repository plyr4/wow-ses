-- Author      : khris(chris) Xo-Malfurion
-- (refactored and extended by Gormb github.com/plyr4/super-emotes-and-sounds)
--SuperEmotes works in tandem with ReactiveEmotes."]={};
--ReactiveEmotes ..react.. to other emotes by queue'ing up emote responses."]={};
--Queue up emotes from other addons with 'G_SES_RE:QueueEmote(emote,target)' command."]={};

local ResponseTriggerDelay = 1;             -- Response delay in seconds."]={};
local ResponseTriggerCooldown = 5;          -- Minimal time between queued emotes in seconds."]={};
local ResponseTriggerRateLimit = 1;         -- Max times you will reply to an emote before timing out
local DefaultResponseCooldown = 20;         -- ?document
local GlobalResponseCooldown = 15;          -- ?document

local _responseRateLimitCounter = 0;        -- ?document
local _lastDefaultResponseTime = GetTime(); -- ?document
local _lastResponseTime = GetTime();        -- Time of last emote, used in calculations/cd's

local PLAYER_GUID;                          -- All of the players ID info.

local PLAYER_NAME = GetUnitName("player");
local SERVER_NAME = GetRealmName("player");

local PLAYER_FULL_NAME = PLAYER_NAME .. "-" .. SERVER_NAME:gsub("%s", ""); -- Combine both names to make a full name which is used most of the time
local NAME_PATTERN = "%%N";                                                -- Pattern for string.gsub() to replace with the sender's name
local DEFAULT_RESPONSE = "SHRUG";                                          -- Default response to things we don't have curated responses to.

--########--TRIGGERS / RESPONSES-------EDIT/ADD TRIGGERS/RESPONSES BELOW---------------------------######--
----------------------------------------------------------------------------------------------------------
local RESPONSES = {
	--ANIMATED EMOTES
	--Angry & Mad
	["fist in anger at you."] = { "GASP", "APOLOGIZE", "GROVEL", "PLEAD" },
	--Applaud, Applause & Bravo
	["applauds at you"] = { "THANK", "BOW", "CURTSEY" },
	--Attacktarget
	["tells everyone to attack you."] = { "SURRENDER", "ROAR", "TAUNT", "CRY" },
	--Bashful
	["is so bashful...too bashful to get your attention."] = { "HUG", "INTRODUCE", "FIDGET" },
	--Beg
	["begs you.  How pathetic."] = { "MOAN", "SHOO", "SIGH", "DOH" },
	--Blow & Kiss
	["blows you a kiss."] = { "NOSEPICK", "KISS", "FLIRT", "BLUSH", "SLAP", "PURR" },
	--Blush
	["blushes at you."] = { "CURIOUS", "FLIRT", "QUESTION", "PONDER" },
	--Boggle
	["boggles at you."] = { "BOW", "GROVEL" },
	--Bow
	["bows before you."] = { "HI", "CURTSEY", "BLUSH", "GLOAT" },
	--Bye, Goodbye & Farewell
	["waves goodbye to you.  Farewell!"] = { "waves farewell to %N!" },
	--Cackle
	["cackles maniacally at you."] = { "CRY", "HELPME", "FLOP" },
	--Cheer
	["cheers at you."] = { "DROOL" },
	--Chew, Eat & Feast
	["begins to eat rations in front of you."] = { "THREATEN", "DROOL" },
	--Chicken, Flap & Strut
	--With arms flapping, %Name
	["struts around you.  Cluck, Cluck, Chicken."] = { "CHICKEN", "CHICKEN", "CHICKEN", "incites a \"Cluck-Off!\"" },
	--Chuckle
	["chuckles at you."] = { "CRINGE" },
	--Clap
	["claps excitedly for you."] = { "THANK", "wonders why %N is clapping and nobody else is...", "BOW" },
	--Commend
	["commends you on a job well done."] = { "BOW", "thanks %N for proving their mother true.", "THANK" },
	--Confused
	["looks at you with a confused look."] = { "PONDER", "WAVE" },
	--Congrats & Congratulate
	["congratulates you."] = { "SALUTE", "HAIL" },
	--Cower & Fear
	["cowers in fear at the sight of you."] = { "CACKLE", "JK" },
	--Cry, Sob & Weep
	["cries on your shoulder."] = { "COMFORT" },
	--Curious
	["is curious what you are up to."] = { "SNARL", "SHINDIG", "SCRATCH" },
	--Curtsey
	["curtsies before you."] = { "BOW", "KISS", "FART", "SHY" },
	--Dance
	["dances with you."] = { "DANCE", "thinks %N needs to go watch Footloose.", "has never seen moves like %N's before!",
		"asks if %N knows Kevin Bacon.", "challenges everybody here to a dance off!" },
	--Drink & Shindig
	["raises a drink to you.  Cheers."] = { "HAIL", "FOOD", "OOM" },
	--Flee
	["yells for you to flee."] = { "flees from %N with a tear in their eye!", "PRAY", "GUFFAW" },
	--Flex & Strong
	["flexes at you.  Oooooh so strong."] = { "GROVEL", "PEER", "COMMEND", "YAWN", "COWER" },
	--Flirt
	["flirts with you."] = { "GLOAT", "READY", "POUNCE", "VETO", "KISS",
		"hides their left hand before saying they are single and ready to mingle..." },
	--Followme
	["motions for you to follow."] = { "LOST", "SALUTE" },
	--Gasp
	["gasps at you."] = { "GASP", "SHRUG", "RUDE", "FLEX" },
	--Giggle
	["giggles at you."] = { "TALKQ", "INTRODUCE", "TICKLE", "SURPRISED" },
	--Gloat
	["gloats over your misfortune."] = { "spits on %N's mom.", "STARE", "THREATEN", "MAD" },
	--Golfclap
	["claps for you, clearly unimpressed."] = { "is unimpressed with %N's Mom.", "CRY", "CURTSEY", "BITE" },
	--Greet & Greetings
	["greets you warmly."] = { "HAPPY", "INTRODUCE" },
	--Grovel & Peon
	["grovels before you like a subservient peon."] = { "SIGH", "SHOO", "PITY" },
	--Guffaw
	["takes one look at you and lets out a guffaw."] = { "BLINK" },
	--Hail
	["hails you."] = { "HELLO" },
	--Healme
	["calls out for healing."] = { "LOL", "VETO", "SOOTHE" },
	--Hello & Hi
	["greets you with a hearty hello."] = { "WAVE" },
	--Helpme (No Target Emote)
	["cries out for help."] = { "VOLUNTEER" },
	--Incoming
	["points you out as an incoming enemy."] = { "NO" },
	--Insult
	["thinks you are the son of a motherless ogre."] = { "SNARL", "SURPRISED" },
	--Kneel
	["kneels before you."] = { "FLEX", "BORED" },
	--Lay, Laydown, Lie & Liedown
	["lies down before you."] = { "CUDDLE", "GROAN" },
	--Lol
	["laughs at you."] = { "FART", "SMILE", "QUESTION" },
	--Lost
	["wants you to know that he is hopelessly lost."] = { "FACEPALM" },
	--Mourn
	--In quiet contemplation, %Name
	["mourns your death."] = { "COMFORT", "SOOTHE" },
	--Nod & Yes
	["nods at you."] = { "NO" },
	--OOM
	["is low on mana."] = { "FROWN" },
	--Openfire
	["orders you to open fire."] = { "NOD" },
	--Plead
	["pleads with you."] = { "WRATH", "NO", "SNUB" },
	--Point
	["points at you."] = { "MOON" },
	--Ponder
	["ponders your actions."] = { "SMIRK" },
	--Pray
	["says a prayer for you."] = { "THANK" },
	--Puzzled
	["puzzled by you. What are you doing."] = { "SNICKER" },
	--Question & Talkq
	["questions you."] = { "SHRUG", "SMILE", "REAR" },
	--Rasp & Rude
	["makes a rude gesture at you."] = { "PUNCH" },
	--Roar
	["roars with bestial vigor at you.  So fierce!"] = { "BOGGLE", "YAWN", "FEAR", "BONK" },
	--Rofl
	["rolls on the floor laughing at you."] = { "CRY" },
	--Salute
	["salutes you with respect."] = { "HAIL", "BOW" },
	--Shrug (Default Reply, do not react)
	["shrugs at you.  Who knows."] = { "WINK" },
	--Shy
	["smiles shyly at you."] = { "SMILE", "BLUSH" },
	--Sleep (No Target Emote)
	["falls asleep. Zzzzzzz."] = { "CUDDLE", "YAWN", "TAP" },
	--Surrender
	["surrenders before you.  Such is the agony of defeat..."] = { "ROAR", "LAUGH" },
	--Talk
	["wants to talk things over with you."] = { "NO", "LISTEN" },
	--Talkex
	["talks excitedly with you."] = { "BLINK", "NOSEPICK", "SHOO" },
	--Taunt
	["makes a taunting gesture at you. Bring it."] = { "RASP", "INSULT", "THREATEN" },
	--Victory
	["basks in the glory of victory with you."] = { "CHEER", "ROAR" },
	--Violin
	["plays the world's smallest violin for you."] = { "CRY" },
	--Wave
	["waves at you."] = { "GREET" },
	--Welcome
	["welcomes you."] = { "THANK", "INTRODUCE" },

	--NON-ANIMATED EMOTES
	--Agree
	["agrees with you."] = { "FLIRT", "THANK" },
	--Amaze
	["amazed by you."] = { "FLIRT", "THANK" },
	--Apologize
	["apologizes to you."] = { "GUFFAW", "THANK", "BOW", "THREATEN", "tells %N that everything is okay.", "forgives %N." },
	--Bark
	["barks at you."] = { "BARK", "COWER", "thinks %N needs to use mouthwash... Stinky!" },
	--Beckon
	["beckons you over."] = { "QUESTION", "DOH", "BOW", "NO" },
	--Belch--Burp
	["burps rudely in your face."] = { "CRINGE", "RASP", "INSULT", "BELCH" },
	--Bite
	["bites you."] = { "CRINGE", "RASP", "INSULT", "CRY", "BLEED" },
	--Bleed (self-only emote, no response)
	--Blink
	["blinks at you."] = { "WINK", "SNUB", "INSULT", "SHOO", "BORED" },
	--Blood (self-only emote, no response)
	--Bonk
	["bonks you on the noggin. Doh!"] = { "CRINGE", "RASP", "INSULT", "BELCH" },
	--Bored
	["is terribly bored with you."] = { "MOON", "RASP", "ROAR", "GREET" },
	--Bounce
	["bounces up and down in front of you."] = { "CRINGE", "FLIRT", "INSULT", "BELCH", "ROAR", "NOSEPICK" },
	--BRB
	["will be right back."] = { "CRINGE", "FLIRT" },
	--Calm
	["tries to calm you down."] = { "ROAR", "THANK", "NO", "decrees that they will NOT be calming down!" },
	--Cat--Catty & Scratch
	["scratches you. How catty!"] = { "PURR", "CRY", "SHOO", "RUDE" },
	--Cold
	["lets you know that she is cold."] = { "CUDDLE", "DOH", "COMFORT" },
	["lets you know that he is cold."] = { "CUDDLE", "DOH", "COMFORT" },
	--Comfort
	["comforts you."] = { "CRINGE", "CRY", "needs more than what %N has to offer." },
	--Cough
	["coughs at you."] = { "CRINGE", "RASP", "INSULT" },
	--Crack & Knuckles
	["cracks her knuckles while staring at you."] = { "CRINGE", "RASP", "IMPATIENT", "CRY", "MOAN" },
	["cracks his knuckles while staring at you."] = { "CRINGE", "RASP", "IMPATIENT", "CRY", "MOAN" },
	--Cringe
	["cringes away from you."] = { "RASP", "CRY", "GLARE" },
	--Cuddle & Spoon
	["cuddles up against you."] = { "FLIRT", "LICK", "PURR", "HUG", "MOAN", "MASSAGE" },
	--Disappointed & Frown
	["frowns with disappointment at you."] = { "CRINGE", "CRY", "GROAN", "FART", "MOCK" },
	--Doh (alias for BONK)
	--Doom, Threaten & Wrath
	["threatens you with the wrath of doom."] = { "COWER", "CRY" },
	--Drool
	["looks at you and begins to drool."] = { "SNAP" },
	--Duck
	["ducks behind you."] = { "SHOO" },
	--Eye
	["eyes you up and down."] = { "FART" },
	--Fart
	["brushes up against you and farts loudly."] = { "thinks %N smells." },
	--Fidget
	["fidgets impatiently while waiting for you."] = { "thinks %N smells." },
	--Flop
	["flops about helplessly around you."] = { "thinks %N needs more self confidence." },

	--Food, Hungry & Pizza
	["Maybe you have some food..."] = { "SHOO" },
	--"EAT"
	--Gaze
	["gazes longingly at you."] = { "SHY" },


	--Glad
	["is very happy with you!"] = { "SALUTE" },
	--Glare
	["glares angrily at you."] = { "GUFFAW", "JK" },
	--Grin
	["grins at you wickedly."] = { "GUFFAW" },

	--Groan
	--Happy
	--Hug
	["hugs you."] = { "CUDDLE" },

	--Impatient
	--Introduce (herself)
	["introduces herself to you."] = { "BOW" },
	--Introduce (himself)
	["introduces himself to you."] = { "BOW" },
	--JK
	["lets you know he was just kidding."] = { "LAUGH", "GUFFAW" },
	["lets you know she was just kidding."] = { "LAUGH", "GUFFAW" },

	--Lavish
	--Lick
	["licks you."] = { "COWER", "CRY", "GIGGLE" },
	--Listen
	--Look
	["looks at you."] = { "MOON" },
	--Massage
	["massages your shoulders."] = { "MOAN" },
	--Moan
	["moans suggestively at you."] = { "CUDDLE" },
	--Mock
	["mocks your foolishness."] = { "pretends they can't hear %N." },

	--Moon
	["drops his trousers and moons you."] = { "GASP" },
	["drops her trousers and moons you."] = { "GASP" },
	--No
	["tells you NO."] = { "licks %N's finger." },
	--Nosepick
	--Panic
	["takes one look at you and panics."] = { "BARK", "PURR", "MOO" },
	--Pat
	["gently pats you."] = { "PURR", "BITE" },

	--Peer
	["peers at you searchingly."] = { "LOOK", "COUGH" },

	--Pest
	--Pet
	["pets you."] = { "BARK", "PURR", "MOO" },
	--Pick
	["picks his nose and shows it to you."] = { "SIGH" },
	["picks her nose and shows it to you."] = { "SIGH" },
	--Pity
	["looks down upon you with pity."] = { "CRY" },
	--Poke
	["pokes you."] = { "COUGH", "LOOK" },
	--Pounce
	--Praise
	["lavishes praise upon you."] = { "SALUTE", "BOW", "THANK" },

	--Purr
	["purrs at you."] = { "WINK", "BARK" },
	--Raise
	--Rdy
	["lets you know that he is ready!"] = { "SALUTE", "CHEER" },
	["lets you know that she is ready!"] = { "SALUTE", "CHEER" },

	--Ready
	--Rear & Shake
	--Sexy
	["thinks you are a sexy devil."] = { "gasps in shock at %N!" },
	--Shimmy
	--Shiver
	["shivers beside you."] = { "HUG", "COMFORT", "warms $N." },

	--Shoo
	["shoos you away."] = { "POKE" },
	--Sigh
	["sighs at you."] = { "reassures %N." },
	--Slap
	--Smell
	--Smirk
	["smirks slyly at you."] = { "snickers at %N." },

	--Snap
	["snaps his fingers at you."] = { "COUGH" },
	--Snarl
	["bares his teeth and snarls at you."] = { "LOOK" },
	["bares her teeth and snarls at you."] = { "LOOK" },
	--Snicker
	["snickers at you."] = { "WINK", "LAUGH" },
	--Sniff
	["sniffs you."] = { "WINK", "LAUGH" },
	--Snub
	--Soothe
	["soothes you."] = { "HUG", "CRY" },
	--Sorry
	--Spit
	--Stare
	["stares you down."] = { "MOON", "THREATEN" },
	--Stink
	--Surprised
	["is surprised by your actions."] = { "WINK" },
	--Tap
	--Tease
	["teases you."] = { "CRY" },
	--Thank
	--Thanks
	["thanks you."] = { "SALUTE" },

	--Thirsty
	["lets you know that he is thirsty."] = { "offers %N a glass of water." },
	["lets you know that she is thirsty."] = { "offers %N a glass of water." },

	--Threat
	--Tickle
	-- starts a tickle fight with other SES users
	["tickles you."] = { "TICKLE", "tickles %N." },
	--Threaten
	--Tired
	["lets you know that he is tired."] = { "COMFORT" },
	["lets you know that she is tired."] = { "COMFORT" },

	--TY

	--Veto
	["vetoes your motion."] = { "SIGH" },

	--Volunteer
	["looks at you and raises his hand."] = { "asks %N if they have a question." },
	["looks at you and raises her hand."] = { "asks %N if they have a question." },

	--Whine
	["whines pathetically at you."] = { "BARK" },

	--Whistle
	["whistles at you."] = { "BARK" },

	--Wicked & Wickedly (GRIN)

	--Work
	["works with you."] = { "BARK" },

	--Yawn
	["yawns sleepily at you."] = { "SNAP" },

	--NO MESSAGE EMOTES
	--Sit
	--Train
	--Charge when targeting

	--NO REPONSE
	["begins charging alongside"] = { "NOREPLY" },

	--GLOBAL RESPONSE
	["challenges everybody here to a dance off!"] = { "DANCE" },
	["yells \"FOOTLOOSE!\""] = { "DANCE" },
	--Charge (No Target Emote)
	["starts to charge."] = { "begins charging alongside %N." },
	["incites a \"Cluck Off!\""] = { "CHICKEN" },
	["cheers for the Horde!"] = { "FORTHEHORDE" },
	["cheers for the Alliance!"] = { "FORTHEALLIANCE" },
} -- This table contains the trigger phrases and reply type/messages.


local GLOBAL_RESPONSES = { "challenges everybody here to a dance off!",
	"yells \"FOOTLOOSE!\"",
	"starts to charge.",
	"incites a \"Cluck Off!\"",
	"cheers for the Horde!",
	"cheers for the Alliance!" };

-----------Frames&EventListener-----------------------
local SES_RE = CreateFrame("Frame");
G_SES_RE = CreateFrame("Frame");
SES_RE:RegisterEvent("CHAT_MSG_TEXT_EMOTE"); -- Built-in emotes
SES_RE:RegisterEvent("CHAT_MSG_EMOTE");      -- Custom emotes

SES_RE.ResponseQueue = {};
SES_RE.Recycled = {};

local _tableIn = {};

--~###GLOBAL CALLS###~-- -- For other addOns to use.
function G_SES_RE:QueueEmote(emote, target)
	SES_RE:QueueEmote(emote, target)
end

-- Function to add responses to the queue
function SES_RE:QueueEmote(emote, target)
	-- Get a table from our recycled tables or create a new one
	if table.getn(_tableIn) > 0 then
		table.wipe(_tableIn)
	end

	-- Setup data and insert
	_tableIn[1] = emote
	_tableIn[2] = target
	_tableIn[3] = GetTime()

	table.insert(self.ResponseQueue, _tableIn);
end

local function findEmoteIndex(msg)
	for key, value in pairs(RESPONSES) do
		local found = string.find(msg, key)
		if found ~= nil then
			return key
		end
	end
end

local function checkForGlobal(msg)
	for key, value in pairs(GLOBAL_RESPONSES) do
		local found = string.find(msg, value)
		if found ~= nil then
			return true
		end
	end
	return false
end

-- Listens to messages and determines how to respond if at all
SES_RE:SetScript("OnEvent", function(self, event, ...)
	if not PLAYER_GUID then PLAYER_GUID = UnitGUID("player"); end
	local now = GetTime();
	local guid, msg, sender = select(12, ...), ...;
	local response = RESPONSES[findEmoteIndex(msg)];
	if type(response) == "table" then
		-- why check next?
		-- if next(response) == nil then
		-- 	response = nil;
		-- end
	end

	if guid ~= PLAYER_GUID then -- Don't respond to emotes the player sent.
		if response == nil then
			local shouldRespond
			if string.match(msg, PLAYER_NAME) then shouldRespond = true end -- if name heard acknowledge
			if string.match(msg, PLAYER_FULL_NAME) then shouldRespond = true end -- if name+server name heard acknowledge
			if string.match(msg, "you") then shouldRespond = true end   -- if 'you' heard acknowledge

			-- supply custom msg matching here, this could be better
			if string.match(msg, "will be right back") then shouldRespond = true end

			if now - _lastDefaultResponseTime < DefaultResponseCooldown then return end

			-- todo: randomize the default response
			response = DEFAULT_RESPONSE;

			sender = "none";
			if shouldRespond == true then
				_lastDefaultResponseTime = GetTime();
				self:QueueEmote(response, sender);
			end
		elseif type(response) == "table" then
			-- Don't reply to a curated non reply emote
			if response[1] == "NOREPLY" then return end

			-- Check CD on global before playing.
			if checkForGlobal(msg) and now - _lastResponseTime < GlobalResponseCooldown then return end

			if _responseRateLimitCounter < ResponseTriggerRateLimit then
				-- choose a random response from the list of triggers
				local r = response[math.random(1, #response)];

				-- queue the response
				SES_RE:QueueEmote(r, sender);

				-- increase the response rate limit counter
				_responseRateLimitCounter = _responseRateLimitCounter + 1;
			else
				_responseRateLimitCounter = 0;
			end
		elseif type(response) == "string" then -- Handle single (shouldnt trigger)
			self:QueueEmote(response, sender);
		end
	end
end)

-- Runs all Queued commands
SES_RE:SetScript("OnUpdate", function(self)
	local playSuccess = false;

	local now = GetTime();

	-- after a certain time, reset the rate limit counter
	if now - _lastResponseTime > 10 then _responseRateLimitCounter = 0 end

	-- skip nil response
	if self.ResponseQueue[1] == nil then return end

	--  Check against our global cooldown and if we have messages waiting
	if table.getn(self.ResponseQueue) > 0 and now - _lastResponseTime > ResponseTriggerCooldown then
		local ptr = self.ResponseQueue[1];

		if ptr[3] == nil then
			table.remove(self.ResponseQueue, 1);
			return
		end

		if now - ptr[3] > ResponseTriggerDelay then -- Check for individual delay
			-- First attempt to check if it's a slash command for an emote
			-- this checks the global WoW emote list
			-- it is supposed to include them all, but it doesnt
			local token = hash_EmoteTokenList[ptr[1]:upper()];

			-- If not, check if it's an actual token
			if not token then
				for i, j in pairs(hash_EmoteTokenList) do
					if ptr[1]:upper() == j then
						token = j;
						break;
					end
				end
			end

			-- Token should be detected now if it's being referenced
			if token then
				DoEmote(token, ptr[2]); -- Perform token emote with no target
				playSuccess = true;
			else
				-- No token found in hash list, sending custom emote
				SendChatMessage(ptr[1]:gsub(NAME_PATTERN, ptr[2]), "EMOTE"); -- Custom emote
				playSuccess = true;
			end

			_lastResponseTime = now; -- Reset our timestamp

			-- Cleanup
			if playSuccess == true then
				table.remove(self.ResponseQueue, 1); -- Shift the queue
				self.ResponseQueue = self.ResponseQueue
				table.wipe(ptr);         -- Clean and recycle table
			else
				-- Do Nothing we didn't play.
			end
		end
	end
end);
