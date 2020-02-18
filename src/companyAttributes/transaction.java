package companyAttributes;

//an object of type transaction stores an owner (who is affected by the transaction) a city (what location is affected by the transaction) a type
//of transaction (either profit, purchase, sale, or bankrupt) and a cost (representing the amount of money gained or lost by the transaction.
public class transaction
{
	public String owner;
	public String city;
	public String type;
	public int cost;
	
	public transaction(String new_owner, String new_city, String new_type, int new_cost)
	{
		owner = new_owner;
		city = new_city;
		type = new_type;
		cost = new_cost;
	}
}