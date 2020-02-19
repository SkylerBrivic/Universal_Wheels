# Universal_Wheels

## Summary:
Universal Wheels is a video game I made with Alice Webb as a group project for a computer science class at Westchester Community College. In the game, you play as a car company based in Westechester called Universal Wheels. From the initial amount of money that you start off with, you have to purchase other locations for stores and factories, and make good decisions when decision prompts appear in order to grow your business. Once you become powerful enough, you can expand into the greater New York area outside of Westchester. Once you dominate this market, you can expand into states outside of New York. Once you have come to dominate the US market, you win the game!

## Gameplay:
The main interaction that the player has with the game is that the player can click on business locations and choose to buy them. Additionally, a player can choose to sell businesses that they already own. Decisions of what to buy and sell for the other businesses in the game that the player is competing with are made by the computer. 

A player can also view a list of properties for all businesses (including owners) by clicking on the "See all Businesses" tab. Furthermore, a player can search for lists of specific business locations and companies by using the search feature. A player can also optionally select to have the list of businesses sorted by some criteria.

By clicking on the "Company Statistics" tab (which is located in the "See All Businesses" tab), a player can see a summary of the financial status of all of the companies in the game.

At various points in time, decision prompts will pop up, which will require the player to make a decision that will impact their business. The "correct" answer for each prompt will vary for each playthrough, with the probability of a given answer being right varying depending on what businesses the player owns and how much money the player has. Furthermore, for most decisions, there is only a probability of a particular decision being right, rather than a guarantee. For example, for the second decision (the one with Romano the mobster), if 90% or more of the player's property locations are in the northern half of Westchester, then there is a 90% chance that they should accept Romano's offer (since Romano only operates within northern Westchester). Otherwise, there is a 10% chance that accepting Romano's offer is the right option. Correct choices will increase the likelihood that the player will have a high monthly profit, while incorrect choices increase the likelihood that the player will have a net loss of money in a given month. Overall, there are 30 total decisions scattered throughout the game, with 10 applying to the Westchester area, 10 applying to the greater New York area, and 10 applying to locations outside of New York.

When the player becomes powerful enough to expand into the next market, they will unlock a new map of locations. However, they will be able to click on an icon to enter back into the previous map, and they were also be able to exit back out of the older map into the newer map as well.

The player needs to own 65% of all businesses (by purchase price) in Westchester to be able to expand out of Westchester, 70% of businesses in the greater New York area to expand to the federal level, and 75% of all businesses outside of New York in order to beat the game. If the player goes bankrupt or cannot beat the game within 14 in-game years, then they lose the game.

## High Scores:

Once a player beats the game, they have the option to enter their name into the high score leaderboards. The name a player puts down for a high score must be unique. Additionally, when a player enters in a high score, they also enter in a password, so that if they set a later high score they can enter in the name they originally used to update their record. There are 2 high score leaderboards: one keeps track of most money held by a player at the end of the game, and the other keeps track of fastest completion of the game by a player (in terms of in-game days). All of this information would be stored in a MySQL database, if this game had a website with server space.

## Project Structure:

The WebContent folder contains the file with all of the HTML, CSS and JavaScript code for the game, which is carProject.jsp
Additionally, WebContent contains a folder called images which stores all of the images used by the game.

The src folder contains the packages which contain all of the servlets and Java classes that are used for the backend of the game.

The screenshots folder contains a list of screenshorts from the game which shows a series of snapshots of a sample playthrough of the game from start to finish in order (the first one listed is the earliest in the game). 

### Dependencies:

The MySQL connector jar (5.1.47) and gson jar (2.6.2) need to be in the classpath and build path for this project in order to build and run this project.
