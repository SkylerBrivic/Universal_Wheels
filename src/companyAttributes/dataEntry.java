package companyAttributes;

//the dataEntry class stores a name (a city), the type of a business location (either store or factory), the location of the 
//business (either in Westchester, New York, or Outside New York), the owner of the location, the purchasePrice of the location,
//the return price of the location, and the day of the month that the place was purchased on. Locations that aren't owned by any company
//have None listed for owner and a monthDate of -1

public class dataEntry
{
	public String name, type, location, owner;
	public int purchasePrice, returnPrice;
	public int monthDate;
	
	public dataEntry()
	{
		
		purchasePrice = 0;
		monthDate = 0;
	}
	
	public dataEntry(String new_name, String new_type, String new_owner, int new_purchase, int new_return, String new_location, int new_month)
	{
		name = new_name;
		type = new_type;
		owner = new_owner;
		purchasePrice = new_purchase;
		returnPrice = new_return;
		location = new_location;
		monthDate = new_month;
		
	}

}
