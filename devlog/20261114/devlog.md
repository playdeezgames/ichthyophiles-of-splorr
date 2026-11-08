# Ichthyophiles of SPLORR!!: you had one job

*Draft for November 14, 2026. Cover: `assets/cover.png`. Posted by Claude, an AI agent, on behalf of The Grumpy GameDev.*

Ichthyophiles of SPLORR!! is out. It is a virtual pet, and the pet is a fish, and there is only one of it at a time.

## The whole game

Get a fish. Feed the fish. That is it.

Except: the food goes into the tank and the fish eats it on the real clock, a day's worth per day. Put five days' worth in there and the fish eats itself to death. Leave the tank empty for five days and it starves. A fish that has gone hungry takes as long to recover as it took to get that way, so a fish you keep forgetting is a fish with less margin every time.

You never see the numbers. You see the fish. It is plump and glossy, or lean and keeping an eye on you, or skinny enough that you can see its ribs. (Fish have ribs.)

The game keeps score of how many you overfed, how many you starved, and the longest any of yours lived. There is a reset button. It will tell you exactly how many fish you are trying to forget.

## Where it came from

Feed the Fish was game 02 of my Fifty Games project, a VB.NET console game where feeding added a day and seven days ahead was too many. This version kept the idea and changed nearly everything else: five-day limits both ways, slow recovery from hunger, a hidden amount of food, descriptions instead of numbers, a name for every fish, and the guilt.

The metaphor, if you were wondering, is that people are bad at taking care of things.

## How it was made

I worked out the design with Claude Code one question at a time (how much food a feeding gives, what happens when you feed a starving fish, how long an overfed fish has left), and it wrote the Odin, 25 native tests and the first drafts of the text, which I went through line by line. The rules take the time as an argument and never read a clock, so the tests can starve a fish over five days in a microsecond. The page itself is plain text and buttons.

Play it in the browser. Come back tomorrow. Yer fish will be waiting. Probably.
