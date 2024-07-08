# Custom assembly game

This project implements an custom CPU based on ICMC's custom risc architecture, as well as an simple roguelike game in it's assembly language to test it.

In order to those willing to play it may do so, we've put the source code of the Processors' simulator and assembler in the project, you can find more information about it in the ICMC's architecture git: https://github.com/simoesusp/Processador-ICMC.

## Details of the CPU

The CPU was developed in VHDL, being a RISC load-store architecture who uses 16 bit registers and follows strictly the ISA from the discipline's model, not adding new instructions, since everything needed to the game we were developing was already there.

## About the game

SimasRogue is a roguelike, a genre of games guided mainly by a series of principles, with permadeath and random generation of certain elements of the gameplay (forcing the player to make risky choices). It was heavily inspired by the original "Rogue", but with some adaptations to fit the scope of our project

Basically, as you start your run, your character (represented by the char @) appears in a room, with a certain number of enemies (represented by &), so you have to fight then and, if you win, an item will appear in the center of the room. After you grab it, colorful doors will open, leading to other rooms randomly generated, each one having different sizes, quantities of enemies and items (with this last one being indicated by the door's color). You, however, can only enter in one of then, so you need to choose what fits the best you necessities.

This gameplay loop will repeat itself until you die, and when that happens the second characteristic of the roguelike genre comes in hand: Every progress you had on your character will be lost, and now you'll have to start from scratch, but since much of it's room are generated randomly, you probably will face different situations when you restart.

Last but not least, your progression in the game is dictated by the items you grab. The main character starts with a certain amount of life, damage and no coins. So, you can pick items do restore your life (which certainly will be lost during the encounters with the game's enemies), increase your maximum life, damage and coins (with the last one being your score in the run).
