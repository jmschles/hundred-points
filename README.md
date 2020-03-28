# HundredPoints

## What is this?
A fun game for Nat! I had not heard of this game before.

## Rules
Players get points for performing actions. First to 100 points (get it?) wins.

**Phase 1:** Players write cards, desribing the action and assigning a point value. When everyone's ready to rock, the moderator starts the game.

**Phase 2:** Cards are shuffled and players are assigned a random turn ordr. Players then take turns picking a card off the deck. They have 3 choices:
* Perform the action to gain points equal to the value of the card
* Skip their turn
* Pass the card to another player of their choosing

Rinse and repeat!

## Deployment
* Currently up at https://round-brave-davidstiger.gigalixirapp.com/. Is David Stiger brave, or does David have a brave tiger? We may never know.

## Known issues
* Only one game is possible at a time, so don't tell anyone this is here.
* We don't kick users off the server on socket disconnect, which means the game will break if a user leaves midgame (since they can't take their turn).
  * Temp fix for this could be to give the moderator skipping privileges
* If the moderator goes AFK everything will grind to a halt pretty fast. Also forever.
* No handling for running out of cards mid-game; the app will crash, so write those cards!
* I think excess cards will get carried over to the next game. Maybe that's fine!
* The styling is hilariously bad
* I probably missed some things. File an issue!
