# HundredPoints

## What is this?
A fun game for Nat! I had not heard of this game before.

## Rules
Players get points for performing actions. First to 100 points (get it?) wins.

**Phase 1:** Players write cards, describing the action and assigning a point value. When everyone's ready to rock, the moderator starts the game.

**Phase 2:** Cards are shuffled and players are assigned a random turn order. Players then take turns picking a card off the deck. They have 3 choices:
* Perform the action to gain points equal to the value of the card
* Skip their turn
* Pass the card to another player of their choosing

Rinse and repeat!

## Deployment
* Currently up at https://round-brave-davidstiger.gigalixirapp.com/. Is David Stiger brave, or does David have a rotund brave tiger? We may never know.

## Known issues
* Only one game is possible at a time, so don't tell anyone this is here.
* We don't kick users off the server on socket disconnect, so if someone leaves without exiting the game with the `Leave game` button, the moderator will need to kick them.
* I think excess cards will get carried over to the next game. Maybe that's fine!
* The styling is hilariously bad
* I probably missed some things. File an issue!

## Refactoring opportunities

In addition to the known issues above, the code could be better...

* We probably don't need controllers at all, I initially put them in because I wasn't getting the layout to render, but later found the solution in the docs
* Break up that massive game template. Child views maybe?
* The `GameServer` is just getting used as a proxy to the `UserServer` for a lot of things, there are opportunities for API cleanup
* And much much more...
