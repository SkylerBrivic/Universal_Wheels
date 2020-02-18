package carServlets;

import companyAttributes.*;
import dataProcessingObjects.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;


//processTime is called once every second to determine profits and losses for each business owned by each company.
//processTime returns a transactionArray which states which profits and losses and types of transactions occurred from each company
//this second
/**
 * Servlet implementation class processTime
 */
@WebServlet("/processTime")
public class processTime extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private ArrayList<transaction> myTransactions = new ArrayList<transaction>();
    private ArrayList<dataEntry> allCompaniesArray;
	private int day_num;
	
	
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public processTime() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		
		if(request.getParameter("PriorityArray") == null)
		{
			System.out.println("Exception on Day " + request.getParameter("day" + "With companies of " + request.getParameter("CompanyList")));
		}
		ArrayList<priorityVal> priorityArray = new PriorityReader().returnPriority(request.getParameter("PriorityArray"));
		
		
		allCompaniesArray = new AllCompanyReader().getArrayData(request.getParameter("CompanyList"));
		myTransactions.clear();
		day_num = Integer.parseInt(request.getParameter("day"));
		

		//checking to see if its the one month anniversary of purchasing any location. If it is, then the profit or loss for the location is calculated
		for(int tempIndex = 0; tempIndex < priorityArray.size(); ++tempIndex)
		{
			
				for(int index = 0; index < allCompaniesArray.size(); ++index)
				{
					if(allCompaniesArray.get(index).owner.equals(priorityArray.get(tempIndex).owner) && day_num == allCompaniesArray.get(index).monthDate)
					{
						if(statusChange(allCompaniesArray.get(index).name, priorityArray.get(tempIndex)))
							break;
						
						
					}
					
					
				}
				if(! priorityArray.get(tempIndex).owner.equals("Universal Wheels"))
				randomPurSell(priorityArray.get(tempIndex));
			}
			
			
		
	Gson gson = new Gson();
	String returnString = gson.toJson(myTransactions);
	
	response.getWriter().println(returnString);
	return;
	}

	
	//randomPurSell creates a random chance that a company will buy or sell one of their locations in a given second. It is slightly more likely
	//that a company will sell than that they will buy
	public void randomPurSell(priorityVal company)
	{
		boolean anyCompaniesLeft = false, continuing = true;
		int myRand = new Random().nextInt(800);
		if(myRand == 250)
		{
		
			for(int i = 0; i < allCompaniesArray.size(); ++i)
		
		{
			if(allCompaniesArray.get(i).owner.equals("None"))
			{
				anyCompaniesLeft = true;
				break;
			}
		}
			if(anyCompaniesLeft == false)
				return;
			while(continuing)
			{
				myRand = new Random().nextInt(allCompaniesArray.size());
				if(allCompaniesArray.get(myRand).owner.equals("None"))
				{
					continuing = false;
					if(allCompaniesArray.get(myRand).purchasePrice < company.cash)
					{
						company.cash -= allCompaniesArray.get(myRand).purchasePrice;
						allCompaniesArray.get(myRand).owner = company.owner;
						myTransactions.add(new transaction(company.owner, allCompaniesArray.get(myRand).name, "Purchase", -1 * allCompaniesArray.get(myRand).purchasePrice));
						return;
					}
					return;
				}
			}
	
		}
		myRand = new Random().nextInt(750);
		
		if(myRand == 250)
		{
			for(int i = 0; i < allCompaniesArray.size(); ++i)
			{
				if(allCompaniesArray.get(i).owner.equals(company.owner))
				{
					anyCompaniesLeft = true;
					break;
				}
			}
			if(anyCompaniesLeft == false)
				return;
			while(continuing)
			{
				
				myRand = new Random().nextInt(allCompaniesArray.size());
				if(allCompaniesArray.get(myRand).owner.equals(company.owner))
				{
					company.cash += allCompaniesArray.get(myRand).returnPrice;
					allCompaniesArray.get(myRand).owner = "None";
					myTransactions.add(new transaction(company.owner, allCompaniesArray.get(myRand).name, "Sell", allCompaniesArray.get(myRand).returnPrice));
					return;
				}
				
				
			}
			
			
		}
		
	}
	
	//statusChange calculates the profit or loss on a business location.
	//each location has an average profit, low value and high value associated with it.
	//additionally each location has a random variability which can randomly be added or subtracted from the end
	//result of the profit. Priority and luck determine which outcome will occur for the company, with higher priority/luck
	//making the highValue more likely. Each profit or loss is calculates as either averageValue highValue or lowValue +- a number between
	//0 and variability -1.
	
	public boolean statusChange(String city, priorityVal company)
	{
		int averageValue = 0;
		boolean adding = true;
		int highValue = 0;
		int lowValue = 0;
		int variability;
		int AmountChanged;
		int outcome; // -1 = low value 0 = average value 1 = high value
		double tempRand;
		int priority = company.priority, luck = company.luck;
		
		Random rand = new Random();
		
		if(city.equals("Yonkers"))
		{
			averageValue = 4000;
			lowValue = -2000;
			highValue = 4500;
			variability = 1500;
		}
		else if(city.equals("Elmsford"))
			{
			averageValue = 10000;
			lowValue = 8000;
			highValue = 15000;
			variability = 8000;
			}
		else if(city.equals("Ardsley"))
		{
			averageValue = 5000;
			lowValue = -1500;
			highValue = 7000;
			variability = 1000;
		}
		else if(city.equals("Ossining"))
		{
			averageValue = 2000;
			lowValue = -4500;
			highValue = 5000;
			variability = 1000;
		}
		else if(city.equals("Valhalla"))
		{
			averageValue = 3000;
			lowValue = -4000;
			highValue = 4000;
			variability = 2000;
		}
		else if(city.equals("Armonk"))
		{
			averageValue = 10000;
			highValue = 15000;
			lowValue = -1000;
			variability = 5000;
		}
		else if(city.equals("Bedford"))
		{
			averageValue = 2000;
			lowValue = -4500;
			highValue = 4000;
			variability = 1500;
		}
		else if(city.equals("Portchester"))
		{
			averageValue = -1000;
			lowValue = -3000;
			highValue = 800;
			variability = 500;
		}
		else if(city.equals("White Plains"))
		{
			averageValue = 4000;
			lowValue = -3000;
			highValue = 6000;
			variability = 1100;
		}
		else if(city.equals("Yorktown"))
		{
			averageValue = 2000;
			lowValue = -3000;
			highValue = 2700;
			variability = 500;
		}
		else if(city.equals("Mt Kisco"))
		{
			averageValue = 6500;
			lowValue = -1000;
			highValue = 8000;
			variability = 2000;
		}
		else if(city.equals("New Rochelle"))
		{
			averageValue = 4000;
			highValue = 6000;
			lowValue = -2000;
			variability = 2000;
			
		}
		else if(city.equals("Scarsdale"))
		{
			averageValue = 5000;
			highValue = 10000;
			lowValue = 0;
			variability = 2000;
		}
		else if(city.equals("Somers"))
		{
			averageValue = 2500;
			highValue = 3000;
			lowValue = -3000;
			variability = 500;
			
		}
		else if(city.equals("Peekskill"))
		{
			averageValue = 1200;
			highValue = 2000;
			lowValue = -2000;
			variability = 1000;
		}
		else if(city.equals("North Salem"))
		{
			averageValue = 700;
			lowValue = 0;
			highValue = 1400;
			variability = 1000;
		}
		else if(city.equals("Mamaroneck"))
		{
			averageValue = 1800;
			lowValue = -2000;
			highValue = 3500;
			variability = 1400;
		}
		else if(city.equals("Mount Vernon"))
		{
			averageValue = -750;
			lowValue = -2800;
			highValue = 500;
			variability = 500;
		}
		
		else if(city.equals("Tuckahoe"))
		{
			averageValue = 3500;
			lowValue = -2500;
			highValue = 5000;
			variability = 500;
		}
		
		else if(city.equals("Mohegan Lake"))
		{
			averageValue = 3500;
			lowValue = -2000;
			highValue = 6000;
			variability = 1000;
			
		}
		
		else if(city.equals("Albany"))
		{
			averageValue = 2000;
			lowValue = -4500;
			highValue = 4000;
			variability = 1500;
		}
		
		else if(city.equals("Manhattan"))
		{
			averageValue = 25000;
			highValue = 40000;
			lowValue = 4000;
			variability = 5000;
		}
		
		else if(city.equals("Bronx"))
		{
			averageValue = 15000;
			highValue = 20000;
			lowValue = 5000;
			variability = 10000;
		}
		
		else if(city.equals("Queens"))
		{
			averageValue = 20000;
			highValue = 30000;
			lowValue = 7000;
			variability = 5000;
		}
		
		else if(city.equals("Newburgh"))
		{
			averageValue = 1500;
			highValue = 2000;
			lowValue = -2000;
			variability = 1000;
		}
		
		else if(city.equals("Brooklyn"))
		{
			averageValue = 17000;
			highValue = 25000;
			lowValue = 8000;
			variability = 4000;
		}
		
		else if(city.equals("Staten Island"))
		{
			averageValue = 10000;
			highValue = 15000;
			lowValue = -1000;
			variability = 5000;
		}
		else if(city.equals("Long Island"))
		{
			averageValue = 6000;
			highValue = 10000;
			lowValue = 2000;
			variability = 4000;
		}
		
		else if(city.equals("Ithaca"))
		{
			averageValue = 4000;
			highValue = 6000;
			lowValue = -2000;
			variability = 2000;
		}
		else if(city.equals("Niagara Falls"))
		{
			averageValue = 15000;
			highValue = 20000;
			lowValue = 5000;
			variability = 7000;
		}
		else if(city.equals("Olean"))
		{
			averageValue = 3000;
			highValue = 5000;
			lowValue = 1000;
			variability = 2000;
		}
		else if(city.equals("Mechanicville"))
		{
			averageValue = 12000;
			highValue = 15000;
			lowValue = 7000;
			variability = 3000;
		}
		else if(city.equals("Jamestown"))
		{
			averageValue = 17000;
			highValue = 25000;
			lowValue = 8000;
			variability = 4000;
		}
		else if(city.equals("Plattsburgh"))
		{
			averageValue = 1500;
			highValue = 2500;
			lowValue = -1000;
			variability = 1500;
		}
		else if(city.equals("Syracuse"))
		{
			averageValue = -1000;
			highValue = 1000;
			lowValue = -3000;
			variability = 2000;
		}
		else if(city.equals("Troy"))
		{
			averageValue = 2500;
			highValue = 3500;
			lowValue = 0;
			variability = 1500;
		}
		else if(city.equals("Rochester"))
		{
			averageValue = 15000;
			highValue = 23000;
			lowValue = 5000;
			variability = 6000;
		}
		else if(city.equals("Buffalo"))
		{
			averageValue = 2000;
			highValue = 3000;
			lowValue = 1000;
			variability = 2000;
		}
		else if(city.equals("Poughkeepsie"))
		{
			averageValue = 4000;
			highValue = 6000;
			lowValue = 1000;
			variability = 3000;
		}
		else if(city.equals("Watertown"))
		{
			averageValue = 12000;
			highValue = 15000;
			lowValue = 7000;
			variability = 3000;
		}
		else if(city.equals("Tupper Lake"))
		{
			averageValue = 25000;
			highValue = 40000;
			lowValue = 4000;
			variability = 5000;
		}
		
		else if(city.equals("Ankang China"))
		{
			averageValue = 17000;
			highValue = 25000;
			lowValue = 10000;
			variability = 5000;
		}
		else if(city.equals("Rose Plaza"))
		{
			averageValue = 40000;
			highValue = 60000;
			lowValue = 20000;
			variability = 10000;
		}
		
		else if(city.equals("Boston"))
		{
			averageValue = 17000;
			highValue = 25000;
			lowValue = 8000;
			variability = 4000;	
		}
		else if(city.equals("Philadelphia"))
		{
			averageValue = 2000;
			lowValue = -4500;
			highValue = 4000;
			variability = 1500;
		}
		else if(city.equals("Los Angeles"))
		{
			averageValue = 0;
			highValue = 17000;
			lowValue = -13000;
			variability = 16000;
		}
		else if(city.equals("Las Vegas"))
		{
			averageValue = 80000;
			highValue = 100000;
			lowValue = 60000;
			variability = 20000;
		}
		else if(city.equals("Chicago"))
		{
			averageValue = 7000;
			highValue = 10000;
			lowValue = 4000;
			variability = 6000;
		}
		else if(city.equals("Dallas"))
		{
			averageValue = 30000;
			highValue = 45000;
			lowValue = 20000;
			variability = 10000;
		}
		else if(city.equals("Denver"))
		{
			averageValue = 20000;
			highValue = 25000;
			lowValue = 10000;
			variability = 1000;
		}
		else if(city.equals("Fargo"))
		{
			averageValue = 25000;
			highValue = 40000;
			lowValue = 4000;
			variability = 5000;
		}
		else if(city.equals("Glia Bend"))
		{
			averageValue = 0;
			highValue = 8000;
			lowValue = -6000;
			variability = 6000;
			
		}
		else if(city.equals("Detroit"))
		{
			averageValue = -2000;
			highValue = 1000;
			lowValue = -2500;
			variability = 2000;
		}
		
		else if(city.equals("El Paso"))
		{
			
			averageValue = 27000;
			highValue = 35000;
			lowValue = 25000;
			variability = 20000;
		}
		else if(city.equals("Macon"))
		{
			averageValue = 0;
			lowValue = -4500;
			highValue = 5500;
			variability = 6000;
		}
		else if(city.equals("Miami"))
		{
			averageValue = 3000;
			highValue = 5000;
			lowValue = -3000;
			variability = 1500;
		}
		else if(city.equals("Nashville"))
		{
			averageValue = 17000;
			highValue = 25000;
			lowValue = 8000;
			variability = 4000;	
		}
		else if(city.equals("New Orleans"))
		{
			averageValue = -2000;
			highValue = 1000;
			lowValue = -2500;
			variability = 2000;
		}
		else if(city.equals("Topeka"))
		{
			averageValue = 0;
			lowValue = -4500;
			highValue = 5500;
			variability = 6000;
		}
		
		else if(city.equals("Twin Falls"))
		{
			
			averageValue = 3000;
			highValue = 10000;
			lowValue = -1000;
			variability = 4000;
		}
		else if(city.equals("Sacramento"))
		{
			averageValue = 13000;
			highValue = 20000;
			lowValue = 2000;
			variability = 4000;	
		}
		else if(city.equals("Seattle"))
		{
			averageValue = 20000;
			highValue = 30000;
			lowValue = 7000;
			variability = 5000;
		}
		else if(city.equals("St Louis"))
		{
			averageValue = 4000;
			highValue = 6000;
			lowValue = -2000;
			variability = 2000;
		}
		
		else
		{
			averageValue = 3000;
			lowValue = -1000;
			highValue = 4500;
			variability = 750;
		}
		
		
	if(priority == 5)
	{
	tempRand = rand.nextInt(1000000) + luck;
	
	}
	else if(priority > 5)
	{
		 tempRand = (rand.nextInt(1000000) + luck) * (18.0/17 * (priority - 5));
		
		}
	
	else
	{
			tempRand = (rand.nextInt(1000000) + luck) / (18.0/17 * (5- priority));
	}
	
	if(tempRand <= 333333)
		outcome = -1;
	else if (tempRand <= 666666)
		outcome = 0;
	else
		outcome = 1;
	
	
	if(rand.nextInt(2) == 0)
		adding = true;
	else
		adding = false;
	if(outcome == -1)
	{
		
		AmountChanged = lowValue;
		if(adding)
			AmountChanged += rand.nextInt(variability);
		else
			AmountChanged -= rand.nextInt(variability);
				
	}
	else if(outcome == 0)
	{
		AmountChanged = averageValue;
		if(adding)
			AmountChanged += rand.nextInt(variability);
		else
			AmountChanged -= rand.nextInt(variability);
		
	}
	else
	{
		AmountChanged = highValue;
		if(adding)
			AmountChanged += rand.nextInt(variability);
		else
			AmountChanged -= rand.nextInt(variability);
		
	}
	
	myTransactions.add(new transaction(company.owner, city, "Profit", AmountChanged));
	company.cash += AmountChanged;
	if(company.cash <= 0)
		return bankrupt(company);
	else
		return false;
	
	}
	
	//bankrupt sells off a company's locations randomly until they can pay off their debt. If the company runs out of locations and still has 0 or less dollars,
	//than they go bankrupt and the bankrupt function returns true. Otherwise, the bankrupt function returns false.
	public boolean bankrupt(priorityVal company)
	{
		Random myRand = new Random();
		int tempIndex = 0;
		boolean stillHope = false;
		while(company.cash <=0)
		{
			stillHope = false;
			for(int i = 0; i < allCompaniesArray.size(); ++i)
			{
				if(allCompaniesArray.get(i).owner.equals(company.owner))
					{
					stillHope = true;
					break;
					}
			}
			
			if(stillHope == false)
			{
				myTransactions.add(new transaction(company.owner, "N/A", "BANKRUPT", 0));
				return true;
			}
			tempIndex = myRand.nextInt(allCompaniesArray.size());
			
			if(allCompaniesArray.get(tempIndex).owner.equals(company.owner))
			{
				allCompaniesArray.get(tempIndex).owner = "None";
				company.cash += allCompaniesArray.get(tempIndex).returnPrice;
				myTransactions.add(new transaction(company.owner, allCompaniesArray.get(tempIndex).name, "Sell", allCompaniesArray.get(tempIndex).returnPrice));
			}
		}
		
		return false;
	}
}





