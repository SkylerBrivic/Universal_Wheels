package playerScore;

//an object of type highScore has a username (the name of the player), a statistic (which represents either the amount of money the player made
//or the time the user finished the game in, depending on which high score table the user is in) and a String called dateSet, which represents the date
//and time that the user set the high score.
public class highScore
{
public String username, dateSet;
public int statistic;


public highScore(String new_name, int new_statistic, String new_date)
{
	username = new_name;
	statistic = new_statistic;
	dateSet = new_date;
}
}
