package carServlets;

import companyAttributes.dataEntry;
import companyAttributes.priorityVal;
import dataProcessingObjects.*;

import java.util.*;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;


//DecisionServ receives as input a PriorityArray of all Companies, an AllCompanies array listing who owns which business, a number representing which
//decision the user is considering, and a letter representing what choice the user chose. DecisionServ calculates if the user chose the correct
//choice or not, and alters the user's (and other company's) luck, priority, and cash accordingly. DecisionServ then returns an updated PriorityArray
//to the client, which indicates the success or failure of the user's choice via the status of Universal Wheels (Universal Wheels is always the first
//entry in the PriorityArray, and each entry in the priorityArray has a status entry. A status of true for Universal Wheels means the user made the right
//decision, and false means the user made the wrong decision).

/**
 * Servlet implementation class DesicionServ
 */
@WebServlet("/DecisionServ")
public class DecisionServ extends HttpServlet {
	private static final long serialVersionUID = 1L;
     ArrayList<priorityVal> PriorityArray;
     ArrayList<dataEntry> AllCompaniesArray;
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DecisionServ() {
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
		int decision =  Integer.parseInt(request.getParameter("decisionNumber"));
		char letter = request.getParameter("decisionChoice").charAt(0);
		
		letter = Character.toUpperCase(letter);
		String AllString = request.getParameter("allCompanies");
		AllCompaniesArray = new AllCompanyReader().getArrayData(AllString);
		
		//converting JSON Strings to a PriorityArray and AllCompaniesArray
		String PriorityString = request.getParameter("priorityArray");
		PriorityArray = new PriorityReader().returnPriority(PriorityString);
		
		int initialProbability = 0;
		Gson gson = new Gson();
		String returnString;
		
		switch(decision)
		{
		case 1: 		
			int numCompaniesOwned = numOwned(AllCompaniesArray, "Universal Wheels");
			//if more than 3 companies are owned by Universal Wheels, there is a 55% chance that buying TV ads is the right decision.
			//otherwise, there is a 70% chance that buying TV ads is the right decision
			if(numCompaniesOwned >=3)
				probabilityEvaluator(55, letter);
			else
				probabilityEvaluator(70, letter);
			
			if(PriorityArray.get(0).status == true)
			{
				if(letter == 'A')
					{
					
					PriorityArray.get(0).luck += 20000;
					PriorityArray.get(0).priority += 1;
					}
				else
					{
					PriorityArray.get(0).luck += 5000;
					}
			}
			else
			{
				if(letter == 'A')
					{
					
					PriorityArray.get(0).luck -= 5000;
					
					}
				else
					{
					PriorityArray.get(0).luck -= 20000;
					if(PriorityArray.get(0).priority > 1)
					PriorityArray.get(0).priority -= 1;
					}
			}
			if(letter == 'A')
				PriorityArray.get(0).cash = PriorityArray.get(0).cash - 10000;
			else
				PriorityArray.get(0).cash = PriorityArray.get(0).cash - 5000;
			
			break;
			
		case 2: 
			//if more business (by purchase cost) that Universal Wheels owns are in the north, then there is a 90% chance that they should take Romano's offer.
			//otherwise, there is a 10% chance that they should take Romano's offer
			int northCounter = 0, southCounter = 0;
			String cityName;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					cityName = AllCompaniesArray.get(i).name;
					if(cityName.equals("Ardsley") || cityName.equals("Elmsford") || cityName.equals("Tuckahoe") || cityName.equals("Mount Vernon") || cityName.equals("Portchester") || cityName.equals("New Rochelle") || cityName.equals("Mamaroneck") || cityName.equals("Scarsdale") || cityName.equals("Valhalla") || cityName.equals("White Plains") || cityName.equals("Yonkers"))
						southCounter += AllCompaniesArray.get(i).purchasePrice;
					else
						northCounter += AllCompaniesArray.get(i).purchasePrice;
				}
			}
				
			if(northCounter > southCounter)
					probabilityEvaluator(90, letter);
					
			else if(northCounter < southCounter)
					probabilityEvaluator(10, letter);
					
			else
					probabilityEvaluator(50, letter);	
				
			if(PriorityArray.get(0).status == true)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).priority +=1;
					PriorityArray.get(0).luck += 5000;
					PriorityArray.get(0).cash -=15000;
				}
				else
				{
				
					PriorityArray.get(0).luck += 5000;
				}
			}
				else
				{
					
				if(letter == 'A')
				{
					PriorityArray.get(0).luck -= 10000;
					PriorityArray.get(0).cash -= 15000;
			}
				else
				{
					PriorityArray.get(0).priority -= 1;
					PriorityArray.get(0).luck -= 10000;
					
				}
				
				
			
		}
		break;
		
		//if the user owns more factories than stores (by value), then there is a 65 % chance that making a deal with Scrap Metal Co.
		//is a good idea. Otherwise, there is a 35% chance that making a deal with Scrap Metal Co. is a good idea
		case 3:
			int storeCounter = 0, factoryCounter = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(AllCompaniesArray.get(i).type.equals("Factory"))
					factoryCounter += AllCompaniesArray.get(i).purchasePrice;
					else
						storeCounter += AllCompaniesArray.get(i).purchasePrice;
				}
			}
				
			if(storeCounter > factoryCounter)
				probabilityEvaluator(35, letter);
					
			else if(factoryCounter > storeCounter)
				probabilityEvaluator(65, letter);
					
			else
				probabilityEvaluator(50, letter);
			
				
			if(PriorityArray.get(0).status == true)
			{
				
				if(letter == 'A')
				{
				PriorityArray.get(0).luck += 5000;	
				PriorityArray.get(0).cash -= 10000;
				
				}
				
				
			}
			else
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 10000;
					
				}
				else
				{
					PriorityArray.get(0).luck -= 5000;
				}
				
				
			}
		break;
		
		case 4:
			//if Universal Wheels owns 60 % or more of all businesses by value in Westchester, then there is a 65 % chance that 
			//giving in to all demands is a good idea. Otherwise, there is a 35% chance that giving into all demands is a good idea. If the user
			//chooses choice A, that increases the probability that choice A will be correct by 10 %
			int totalWestchester = 0, yourWestchester = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).location.equals("Westchester"))
					totalWestchester += AllCompaniesArray.get(i).purchasePrice;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					yourWestchester += AllCompaniesArray.get(i).purchasePrice;
				
			}
			if(yourWestchester * 1.0 / totalWestchester >= 0.60)
				initialProbability = 65;
			else
				initialProbability = 35;
			
			if(letter == 'A')
				initialProbability += 10;
			
			probabilityEvaluator(initialProbability, letter);
			
			if(PriorityArray.get(0).status == true)
			{	
				if(letter == 'A')
					{
					PriorityArray.get(0).cash -= 25000;
					PriorityArray.get(0).priority += 1;
					PriorityArray.get(0).luck += 5000;
					}
				else if (letter == 'B')
				{
					PriorityArray.get(0).cash -= 12500;
					PriorityArray.get(0).luck += 5000;
				}
				else
				{
					PriorityArray.get(0).priority -=1;
					PriorityArray.get(0).luck -= 20000;
					
				}
			}
			else
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 25000;
					PriorityArray.get(0).luck -= 5000;
				}
				else if(letter == 'B')
				{
					PriorityArray.get(0).cash -= 12500;
					PriorityArray.get(0).luck -= 7500;
				}
				else
				{
					PriorityArray.get(0).luck += 5000;
				}
				
				
				
			}
			break;
	
		case 5:
			//if Scarsdale is owned by Universal Wheels, there is a 92% chance that partnering with West Side Taxi is a good idea. Also, if the
			//user owns 4 or more locations near Scarsdale or owns more than 50% of the total value of nearby locations, there is an 80% chance that
			//partnering with West Side Taxi is a good idea. Otherwise, there is a 20% chance that partnering with West Side Taxi is a good idea.
			int numPlaces = 0,  totalValue = 0, myValue = 0;
			boolean scarsdaleOwned = false;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String myCity = AllCompaniesArray.get(i).name;
				if(myCity.equals("Scarsdale") || myCity.equals("Ardsley") || myCity.equals("New Rochelle") || myCity.equals("Tuckahoe") || myCity.equals("Mount Vernon") || myCity.equals("White Plains") || myCity.equals("Mamaroneck"))
				{
					totalValue += AllCompaniesArray.get(i).purchasePrice;
					if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					{
						myValue += AllCompaniesArray.get(i).purchasePrice;
						++numPlaces;
					}
					
				}
				if(myCity.equals("Scarsdale") && AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					scarsdaleOwned = true;
			}
			
			if(scarsdaleOwned)
				probabilityEvaluator(92, letter);
			else if(numPlaces >= 4 || (myValue * 1.0) / totalValue > 0.50)
				probabilityEvaluator(80, letter);
			else
				probabilityEvaluator(20, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash += 50000;
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).luck += 25000;
					PriorityArray.get(0).priority += 1;
				}
				else
				{
					PriorityArray.get(0).luck -= 30000;
					PriorityArray.get(0).priority -= 3;
				}
				
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).luck += 30000;
					PriorityArray.get(0).priority += 2;
					
					for(int i = 1; i < PriorityArray.size(); ++i)
					{
						if(PriorityArray.get(i).owner.equals("Panther Deals"))
						{
							PriorityArray.get(i).luck -= 400000;
							PriorityArray.get(i).priority -= 3;
							break;
							
						}
					}
					
				}
				else
				{
					
					PriorityArray.get(0).luck -= 10000;
					
				}
				
			}
			
			
			break;
		case 6:
			
			//if Universal Wheels has less than $50,000, there is a 40% chance that having a sale is a good idea. Otherwise, there is a 60% chance
			//that having the sale is a good idea.
			if(PriorityArray.get(0).cash < 50000)
				probabilityEvaluator(40, letter);
			else
				probabilityEvaluator(60, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 10000;
				if(PriorityArray.get(0).status == true)
					PriorityArray.get(0).priority += 1;
				else
					PriorityArray.get(0).luck -= 2000;
					
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).luck += 5000;
				}
				else
					PriorityArray.get(0).luck -= 5000;
			}
			
			
			break;
			
		case 7:
			//if Universal Wheels owns less than or equal to 35% of all Westchester factories by cost, then there is a 65 % chance
			//that partnering with Tesla is a good idea. Otherwise, there is a 35% chance that partnering with Tesla is a good idea.
			
			int your_factories = 0, all_factories = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).type.equals("Factory"))
				{
					all_factories += AllCompaniesArray.get(i).purchasePrice;
					if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
						your_factories += AllCompaniesArray.get(i).purchasePrice;
				}
			}
				if( your_factories * 1.0 / all_factories <= 0.35)
					probabilityEvaluator(65, letter);
				else
					probabilityEvaluator(35, letter);
				
				if(PriorityArray.get(0).status == true)
				{
					if( letter == 'A')
					{
						PriorityArray.get(0).luck += 35000;
						PriorityArray.get(0).priority += 3;
						for(int i = 1; i < PriorityArray.size(); ++i)
							{
							PriorityArray.get(i).luck -= 20000;
							PriorityArray.get(i).priority -= 1;
							}
						
					}
					else
					{
						PriorityArray.get(0).luck += 15000;
						PriorityArray.get(0).priority += 1;
						for(int i = 1; i < PriorityArray.size(); ++i)
						{
							if(PriorityArray.get(i).owner.equals("Jungle Cars"))
								{
								PriorityArray.get(i).luck -= 400000;
								PriorityArray.get(i).priority -= 3;
								break;
								}
								
						}
						
						
					}
				}
					else
					{
					if(letter == 'A')
					{
						PriorityArray.get(0).luck -= 10000;
						PriorityArray.get(0).priority -= 1;
						for(int i = 1; i < PriorityArray.size(); ++i)
						{
							if(PriorityArray.get(i).owner.equals("Jungle Cars"))
							{
								PriorityArray.get(i).luck -= 400000;
								PriorityArray.get(i).priority -= 3;
								break;
							}
						}
						
						
					}
					else
					{
						PriorityArray.get(0).luck -= 10000;
						for(int i = 1; i < PriorityArray.size(); ++ i)
							PriorityArray.get(i).luck += 10000;
						
						
					}
						
					}
				
				break;
				
		case 8:
			//if Universal Wheels owns Mount Vernon, then building the field is the correct choice. Otherwise, 
			//building the field is the wrong choice.
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
			if(AllCompaniesArray.get(i).name.equals("Mount Vernon"))
			{
				
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					
					if(letter == 'A')
						{
						PriorityArray.get(0).cash -= 50000;
						PriorityArray.get(0).status = true;
						PriorityArray.get(0).priority += 3;
						PriorityArray.get(0).luck += 25000;
						break;
						}
					else
					{
					PriorityArray.get(0).status = false;
					PriorityArray.get(0).luck -= 10000;
					break;	
						
					}
				}
				else
				{
					
					if(letter == 'A')
					{
						PriorityArray.get(0).cash -= 50000;
						PriorityArray.get(0).status = false;
						PriorityArray.get(0).luck -= 7000;
						break;	
					}
					else
					{
						PriorityArray.get(0).status = true;
						PriorityArray.get(0).luck += 10000;
						PriorityArray.get(0).priority += 1;
						for(int index = 1; index < PriorityArray.size(); ++index)
						{
							if(PriorityArray.get(index).owner.equals("Ford"))
							{
								PriorityArray.get(index).luck -= 400000;
								PriorityArray.get(index).priority -= 3;
								break;
							}
						}
						break;
						
					}	
				}	
			
			}
			}
			break;
			
		case 9:
			//if Universal Wheels owns Ardsley, then there is an 80% chance that building the monster truck is the correct choice. Else if
			//Universal Wheels owns more than 50% of all Westchetser factories, there is a 70% chance that building the monster truck is a good idea.
			//else, there is a 30% chance that building the monster truck is a good idea.
			
			if(owns(PriorityArray.get(0).owner, "Ardsley"))
			{
				probabilityEvaluator(80, letter);
			}
			else
			{
			if(percentOwned("Universal Wheels", "Factory") > 0.50)	
			{
				probabilityEvaluator(70, letter);
			}
			else
				probabilityEvaluator(30, letter);
			}
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash += 50000;
				
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 4;
					PriorityArray.get(0).luck += 100000;
				}
				else
					{
					PriorityArray.get(0).priority -= 2;
					PriorityArray.get(0).luck -= 50000;
					}
				
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					for(int index = 1; index < PriorityArray.size(); ++index)
					{
						if(PriorityArray.get(index).owner.equals("Westchester Discount Cars"))
						{
							PriorityArray.get(index).luck -= 400000;
							PriorityArray.get(index).priority -= 3;
							break;
						}
					}
					PriorityArray.get(0).luck += 10000;
					PriorityArray.get(0).priority += 1;
				}
				else
				{
					
					PriorityArray.get(0).luck -= 25000;
					PriorityArray.get(0).priority -= 1;
				}
				
				
			}
			break;
			
		case 10:
			//if Universal Wheels owns 50% or more of all companies in the South East of Westchester by value, then there is
			//a 75% chance that buying the rental cars is a good idea. Otherwise, there is a 25% chance that buying the rental cars is a good idea.
			int totalSouthEast = 0, yourSouthEast = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).name.equals("Scarsdale") || AllCompaniesArray.get(i).name.equals("Mamaroneck") || AllCompaniesArray.get(i).name.equals("Portchester") || AllCompaniesArray.get(i).name.equals("White Plains") || AllCompaniesArray.get(i).name.equals("Mount Vernon") || AllCompaniesArray.get(i).name.equals("New Rochelle"))
				{
					totalSouthEast += AllCompaniesArray.get(i).purchasePrice;
					if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
						yourSouthEast += AllCompaniesArray.get(i).purchasePrice;
				}
			}
			
			if(yourSouthEast * 1.0 / totalSouthEast >= 0.50)
			probabilityEvaluator(75, letter);
			else
			probabilityEvaluator(25, letter);
			
			if(PriorityArray.get(0).status == true)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 30000;
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 5000;
					
					for(int i = 1; i < PriorityArray.size(); ++i)
					{
						PriorityArray.get(i).priority -= 1;
					}
				}
				else
				{
					PriorityArray.get(0).luck += 10000;
				}
			}
			else
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 30000;
					PriorityArray.get(0).priority -= 2;
					PriorityArray.get(0).luck -= 5000;
					for(int i = 1; i < PriorityArray.size(); ++i)
					{
						PriorityArray.get(i).priority += 1;
					}
				}
				else
				{
					PriorityArray.get(0).luck -= 5000;
				}
				
				
			}
			break;
		
		case 11:
			//if Universal Wheels owns Buffalo, then there is a 95% chance that giving the discount is a good idea.
			//otherwise, there is a 99% chance that giving the discount is a good idea.
			boolean hasBuffalo = false;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).name.equals("Buffalo"))
				{
					if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
						hasBuffalo = true;
					break;
				}
			}
			if(hasBuffalo)
				probabilityEvaluator(95, letter);
			else
				probabilityEvaluator(99, letter);
			
			if(letter == 'A')
			{
				if(PriorityArray.get(0).status == true)
				{
					changePrioritySpecific("Universal Wheels", 2, 25000);
					changePrioritySpecific("Subaru", -2, -25000);
				}
				else
				{
					changePrioritySpecific("Universal Wheels", -7, -150000);
				}
				
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					changePrioritySpecific("Universal Wheels", 1, 30000);
				}
				else
					changePrioritySpecific("Universal Wheels", -3, -25000);
				
				
			}
			break;
		case 12:
			//The initial probability of building the buses being a good idea is 50%. If Universal Wheels owns Albany,
			//then the probability of building the buses being a good idea goes up by 20 %. Else the probability that building
			//the buses is a good idea drops by 20 %. Also, if 50% or more of the total value of Universal Wheel's business locations if in factories,
			//then the probability that building the buses is a good idea goes up by 20%. Else, the probability that building the buses is a good idea
			//goes down by 20%.
			
			boolean hasAlbany = false;
			int myFactory = 0, myTotal = 0, myProbability = 50;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).name.equals("Albany") && AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					hasAlbany = true;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					{
					myTotal += AllCompaniesArray.get(i).purchasePrice;
					
					if(AllCompaniesArray.get(i).type.equals("Factory"))
						myFactory += AllCompaniesArray.get(i).purchasePrice;
					}
			}
			if(hasAlbany)
				myProbability += 20;
			else
				myProbability -= 20;
			if(myFactory * 1.0 / myTotal >= 0.50)
				myProbability += 20;
			else
				myProbability -=20;
			
			probabilityEvaluator(myProbability, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash += 50000;
				
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 10000;
					changePriority(-2, -15000);
				}
				else
				{
					PriorityArray.get(0).priority -= 6;
					PriorityArray.get(0).luck -= 50000;
				}
				
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).luck += 50000;
					PriorityArray.get(0).priority += 3;
					changePriority(-2, -20000);
				}
				else
				{
					PriorityArray.get(0).luck -= 20000;
					PriorityArray.get(0).priority -= 2;
					
				}
				
				
			}
			break;
		
		case 13:
			//if the user owns more locations with sunny pictures than cloudy pictures, there is an 110% chance that selling the solar cars is a good idea.
			//if the user owns more cloudy locations, than there is an 110% chance that selling solar cars is a bad idea.
			int mySunnyCounter = 0, myCloudyCounter = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String mainCity = AllCompaniesArray.get(i).name;
				
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
						{
					if(mainCity.equals("Albany") || mainCity.equals("Brooklyn") || mainCity.equals("Buffalo") || mainCity.equals("Ithaca") || mainCity.equals("Jamestown") || mainCity.equals("Mechanicville") || mainCity.equals("New Rochelle") || mainCity.equals("Plattsburgh") || mainCity.equals("Queens") || mainCity.equals("Scarsdale") || mainCity.equals("Somers") || mainCity.equals("Valhalla") || mainCity.equals("White Plains"))
						++myCloudyCounter;
					else
						++mySunnyCounter;
					
						}
				
			}
			
			if(myCloudyCounter > mySunnyCounter)
				probabilityEvaluator(-110, letter);
			else if(mySunnyCounter > myCloudyCounter)
				probabilityEvaluator(110, letter);
			else
				probabilityEvaluator(50, letter);
			
			if(PriorityArray.get(0).status == true)
			{
				
					PriorityArray.get(0).priority += 3;
					PriorityArray.get(0).luck += 30000;
					changePriority(-2, -30000);

			}
			else
			{
				PriorityArray.get(0).priority -= 3;
				PriorityArray.get(0).luck -= 30000;
			}
			break;
			
		case 14:
			//if Universal Wheels owns Rochester, then sponsoring the racer is correct. Otherwise, it is wrong.
			boolean hasRochester = false;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).name.equals("Rochester"))
				{
					if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
						hasRochester = true;
					break;
				}
			}
			if(hasRochester)
				probabilityEvaluator(110, letter);
			else
				probabilityEvaluator(-110, letter);
			
			if(letter == 'A')
				{
				PriorityArray.get(0).cash -= 25000;
				
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 3;
					PriorityArray.get(0).luck += 25000;
					changePriority(-2, -10000);
				}
				else
				{
					PriorityArray.get(0).priority -= 3;
					PriorityArray.get(0).luck -= 25000;
					
				}
				}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 3;
					PriorityArray.get(0).luck += 25000;
				}
				else
				{
					PriorityArray.get(0).priority -= 3;
					PriorityArray.get(0).luck -= 25000;
					changePrioritySpecific("BMW", 3, 25000);
					
				}	
			}
			break;
				
		case 15:
			//the probability that buying the ice cream trucks is a good idea is -10% if Universal Wheels owns no locations in NYC, 35% if Universal Wheels
			//owns one location in NYC, 70% if Universal Wheels owns 2 locations in NYC, and 110% if the user owns 3 or more locations in NYC.
			int newYorkCounter = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(AllCompaniesArray.get(i).name.equals("Brooklyn") || AllCompaniesArray.get(i).name.equals("Bronx") || AllCompaniesArray.get(i).name.equals("Manhattan") || AllCompaniesArray.get(i).name.equals("Staten Island") || AllCompaniesArray.get(i).name.equals("Queens"))
						++newYorkCounter;
					
				}
				
			}
			if(newYorkCounter == 0)
				probabilityEvaluator(-10, letter);
			else if(newYorkCounter == 1)
				probabilityEvaluator(35, letter);
			else if(newYorkCounter == 2)
				probabilityEvaluator(70, letter);
			else
				probabilityEvaluator(110, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 50000;
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 10;
					PriorityArray.get(0).luck += 20000;
					changePriority(-4, -35000);
				}
				else
				{
					PriorityArray.get(0).priority -= 2;
					PriorityArray.get(0).luck -= 30000;
				}
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 1;
					PriorityArray.get(0).luck += 20000;
				}
				else
				{
					PriorityArray.get(0).priority -= 1;
					PriorityArray.get(0).luck -= 20000;
				}
				
				
			}
			
			break;
		
		//if Universal Wheels owns $600,000 or more worth of factories, then renting the space is a good idea. Otherwise, it
		//is a bad idea.
		case 16:
			int factCounter = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels") && AllCompaniesArray.get(i).type.equals("Factory"))
				{
					factCounter += AllCompaniesArray.get(i).purchasePrice;
				}
				
			}
			
			if(factCounter >= 600000)
				probabilityEvaluator(110, letter);
			else
				probabilityEvaluator(-10, letter);
			
			if(PriorityArray.get(0).status == true)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash += 10000;
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 25000;
				}
				else
				{
					PriorityArray.get(0).luck += 30000;
				}
				
			}
			else
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash += 10000;
					PriorityArray.get(0).priority -= 2;
					PriorityArray.get(0).luck -= 35000;				
					}
				else
				{
					PriorityArray.get(0).priority -= 3;
					PriorityArray.get(0).luck -= 20000;
				}
			}
			
		
				
			
			break;
			
		case 17:
		//if Universal Wheels owns more locations in urban areas than rural areas, than there is a 90% chance that starting the website is a
			//good idea. Otherwise, there is a 30% chance that starting the website is a good idea.
			int myIndustrialized = 0, myRural = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String placeName = AllCompaniesArray.get(i).name;
				
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels") && AllCompaniesArray.get(i).location.equals("New York"))
				{
					if(placeName.equals("Manhattan") || placeName.equals("Bronx") || placeName.equals("Poughkeepsie") || placeName.equals("Albany") || placeName.equals("Queens") || placeName.equals("Brooklyn") || placeName.equals("Staten Island") || placeName.equals("Long Island") || placeName.equals("Syracuse") || placeName.equals("Rochester") || placeName.equals("Troy") || placeName.equals("Buffalo"))
						myIndustrialized += AllCompaniesArray.get(i).purchasePrice;
					else
						myRural += AllCompaniesArray.get(i).purchasePrice;
					
				}
			}
				if(myIndustrialized > myRural)
					probabilityEvaluator(90, letter);
				else
					probabilityEvaluator(30, letter);
				
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 100000;
					if(PriorityArray.get(0).status == true)
					{
						PriorityArray.get(0).priority += 7;
						PriorityArray.get(0).luck += 45000;
						changePriority(-3, -40000);
					}
					else
					{
						PriorityArray.get(0).priority += 2;
						PriorityArray.get(0).luck -= 40000;
					}
				}
				else
				{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 15000;
					changePriority(-1, -5000);
				}
				else
				{
					PriorityArray.get(0).priority -= 4;
					PriorityArray.get(0).luck -= 20000;
				}
					
					
				}
			break;
			
			
		case 18:
			//if Universal Wheels owns more rugged places (by value) in New York than flat ones, then there is a 90% chance that building the
			//new tires is a good idea. Otherwise, there is a 10% chance that building the new tires is a good idea.
			int myRugged = 0, myFlat = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String terrLocation = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).location == "New York" && AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
				if(terrLocation.equals("Poughkeepsie") || terrLocation.equals("Albany") || terrLocation.equals("Ithaca") || terrLocation.equals("Newburgh") || terrLocation.equals("Olean") || terrLocation.equals("Mechanicville") || terrLocation.equals("Plattsburgh") || terrLocation.equals("Watertown") || terrLocation.equals("Tupper Lake"))
					myRugged += AllCompaniesArray.get(i).purchasePrice;
				else
					myFlat += AllCompaniesArray.get(i).purchasePrice;
				}
			}
			
			if(myRugged > myFlat)
				probabilityEvaluator(90, letter);
			else
				probabilityEvaluator(10, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 25000;
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck += 30000;
					changePriority(-4, -25000);
				}
				else
				{
					PriorityArray.get(0).priority -= 3;
					PriorityArray.get(0).luck -= 25000;
				}
				
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 10000;
					changePriority(-2, -15000);
				}
				else
				{
					PriorityArray.get(0).priority -= 3;
					PriorityArray.get(0).luck -= 30000;
				}
				
			}
			
			break;
			
			
			//if the user owns a larger number of properties (by value) in areas with crime rates below the average crime rate for the United States, then choosing to
			//do nothing is the correct answer. Otherwise, choosing to install the security system is the correct answer.	
		case 19:
			int mySafe = 0, myCrime = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String myTown = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(myTown.equals("Elmsford") || myTown.equals("Ardsley") || myTown.equals("Ossining") || myTown.equals("Valhalla") || myTown.equals("Armonk") 
							|| myTown.equals("Bedford") || myTown.equals("Yorktown") || myTown.equals("Mt Kisco") || myTown.equals("Scarsdale")
							|| myTown.equals("Somers") || myTown.equals("Peekskill") || myTown.equals("North Salem") || myTown.equals("Mamaroneck") || myTown.equals("Tuckahoe")
							|| myTown.equals("Mohegan Lake") || myTown.equals("Queens") || myTown.equals("Staten Island") || myTown.equals("Long Island"))
						mySafe += AllCompaniesArray.get(i).purchasePrice;
					else
						myCrime += AllCompaniesArray.get(i).purchasePrice;
				}
			}
			
			if(mySafe > myCrime)
				probabilityEvaluator(-10, letter);
			else
				probabilityEvaluator(110, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 130000;
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck += 50000;
					changePriority(-5, -50000);
				}
				else
				{
					PriorityArray.get(0).priority -= 1;
					PriorityArray.get(0).luck -= 25000;
				}
				
			}
			else
			{
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 3;
					PriorityArray.get(0).luck += 35000;
					changePriority(-5, -50000);
				}
				else
				{
					PriorityArray.get(0).priority -= 3;
					PriorityArray.get(0).luck -= 50000;
				}
				
				
			}
			
			break;
			
		//If Universal Wheels owns more properties from places that favor big cars, then building the big car has a 75 % chance of being the right answer.
		//Otherwise, building the big car has a 25% chance of being the right answer.
		case 20: 
			int mySmall = 0, myBig = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String myTown = AllCompaniesArray.get(i).name;
				
				if(myTown.equals("Yonkers") || myTown.equals("Valhalla") || myTown.equals("Portchester") || myTown.equals("Scarsdale") || myTown.equals("Somers") || myTown.equals("Tuckahoe")
						|| myTown.equals("Albany") || myTown.equals("Ithaca") || myTown.equals("Olean") || myTown.equals("Mechanicville") || myTown.equals("Jamestown") || myTown.equals("Tupper Lake")
						|| myTown.equals("Rochester") || myTown.equals("Buffalo"))
					myBig += AllCompaniesArray.get(i).purchasePrice;
				else
					mySmall = AllCompaniesArray.get(i).purchasePrice;
			}
			
			if(myBig > mySmall)
				probabilityEvaluator(75, letter);
			else
				probabilityEvaluator(25, letter);
			
			PriorityArray.get(0).cash -= 60000;
			
			if(PriorityArray.get(0).status == true)
			{
				PriorityArray.get(0).priority += 3;
				PriorityArray.get(0).luck += 30000;
				changePriority(-4, -32000);
			}
			else
			{
				PriorityArray.get(0).priority -= 2;
				PriorityArray.get(0).luck -= 30000;
				changePriority(2, 16000);
			}
			
			break;
		case 21: 
			//if you own more rural businesses by value than urban businesses and chose to build the truck, then you chose right.
			//if you have more urban businesses than rural ones and chose to build the truck, you have a 30 % chance of being right.
			//if you have more rural businesses than urban ones and chose not to build the truck, you have a 30% chance of having chosen right.
			//if you have more urban businesses than rural ones and chose not to build the truck, then you have a 70% chance of having chosen correctly.
			int myRuralCounter = 0, myUrbanCounter = 0;
			String myCity;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				myCity = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(myCity.equals("Boston") || myCity.equals("Chicago") || myCity.equals("Philadelphia") || myCity.equals("Detroit") || myCity.equals("Los Angeles") || myCity.equals("Miami") || myCity.equals("Sacramento") || myCity.equals("Seattle"))
				
					myUrbanCounter += AllCompaniesArray.get(i).purchasePrice;
				
				else if(myCity.equals("Dallas") || myCity.equals("Denver") || myCity.equals("El Paso") || myCity.equals("Fargo") || myCity.equals("Glia Bend") || myCity.equals("Las Vegas") || myCity.equals("Macon") || myCity.equals("Nashville") || myCity.equals("New Orleans") || myCity.equals("St Louis") || myCity.equals("Topeka") || myCity.equals("Twin Falls"))
						myRuralCounter += AllCompaniesArray.get(i).purchasePrice;
						
				}		
				
				
			}
			
			if(myRuralCounter >= myUrbanCounter && letter == 'A')
			{
				PriorityArray.get(0).status = true;
				PriorityArray.get(0).cash -= 30000;
				PriorityArray.get(0).luck += 30000;
				PriorityArray.get(0).priority += 1;
			}
			else if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 30000;
				probabilityEvaluator(30, letter);
				if(PriorityArray.get(0).status == true)
				{
				PriorityArray.get(0).luck += 30000;
				PriorityArray.get(0).priority += 1;
					
				}
				
			}
			else
			{
				if(myRuralCounter > myUrbanCounter)
					probabilityEvaluator(30, letter);
				else
					probabilityEvaluator(70, letter);
				
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).luck += 15000;
					PriorityArray.get(0).priority += 1;
				}
				else
				{
					PriorityArray.get(0).luck -= 15000;
					PriorityArray.get(0).priority -=1;
				}
				
				
			}
			break;
		case 22:
			//if you own New Orleans, Topeka or St. Louis, you have an 100% chance of having chosen correctly.
			//Otherwise, if you own a larger share of NorthEast stores than SouthWest businesses, you have a 30 % chance that
			//partnering with Arty is a good idea. If you own more South West Businesses, than you have a 70% chance that partnering
			//with Arty is a good idea.
			
			int northEastCount = 0, southWestCount = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String UScity = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(UScity.equals("Boston") || UScity.equals("Chicago") || UScity.equals("Detroit") || UScity.equals("Philadelphia") || UScity.equals("Macon") || UScity.equals("Miami") || UScity.equals("Nashville"))
						northEastCount += AllCompaniesArray.get(i).purchasePrice;
					else if(UScity.equals("Los Angeles") || UScity.equals("Las Vegas") || UScity.equals("Dallas") || UScity.equals("Denver") || UScity.equals("Fargo") || UScity.equals("Glia Bend") || UScity.equals("El Paso") || UScity.equals("Twin Falls") || UScity.equals("Sacramento") || UScity.equals("Seattle"))
						southWestCount += AllCompaniesArray.get(i).purchasePrice;
					else if(UScity.equals("New Orleans") || UScity.equals("Topeka") || UScity.equals("St Louis"))
					{
						PriorityArray.get(0).cash -= 70000;
						PriorityArray.get(0).status = true;
						PriorityArray.get(0).priority += 2;
						PriorityArray.get(0).luck += 40000;
						returnString = gson.toJson(PriorityArray);
						response.getWriter().println(returnString);
						return;
					}
							
				}
			}
			
			if(northEastCount > southWestCount)
				probabilityEvaluator(30, letter);
			else if(southWestCount > northEastCount)
				probabilityEvaluator(70, letter);
			else
				probabilityEvaluator(50, letter);
			
			if(PriorityArray.get(0).status == true)
			{
				PriorityArray.get(0).cash -= 70000;
				PriorityArray.get(0).priority += 3;
				PriorityArray.get(0).luck += 35000;
				changePriority(-2, -25000);
			}
			else
			{
				PriorityArray.get(0).cash -= 70000;
				PriorityArray.get(0).priority -= 1;
				PriorityArray.get(0).luck -= 10000;	
			}
			break;
			
		case 23:
			//if more than 50 % of your companies are factories or you own 25% or more of all factories, then building the train is right
			//and not building it is wrong. Else, building the train is wrong and not building the train is right.
			int myFactories = 0, myCompanies = 0, allFactories = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).location.equals("Outside New York"))
				{
					if(AllCompaniesArray.get(i).type.equals("Factory"))
					{
						allFactories += AllCompaniesArray.get(i).purchasePrice;
						if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
							myFactories += AllCompaniesArray.get(i).purchasePrice;
							myCompanies += AllCompaniesArray.get(i).purchasePrice;
					}
					else if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
						myCompanies += AllCompaniesArray.get(i).purchasePrice;
					
					
				}
				
			}
			if(myFactories * 1.0 / myCompanies > 0.50 || myFactories * 1.0 / allFactories >= 0.25)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).status = true;
					PriorityArray.get(0).cash -= 200000;
					PriorityArray.get(0).luck += 50000;
					PriorityArray.get(0).priority += 5;
					changePriority(-3, -30000);
				}
				else
				{
					PriorityArray.get(0).status = false;
					PriorityArray.get(0).luck -= 5000;
					PriorityArray.get(0).priority -= 2;
				}
			}
			else
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).status = false;
					PriorityArray.get(0).cash -= 200000;
					PriorityArray.get(0).luck += 5000;
					PriorityArray.get(0).priority += 1;
				}
				else
				{
					PriorityArray.get(0).status = true;
					PriorityArray.get(0).luck += 12000;
					PriorityArray.get(0).priority += 2;
					changePriority(-1, -10000);
				}
				
				
				
			}
			break;
			
		case 24:
			 //if the user chose to partner with the cowboys and had a Texas location or didn't have a Texas or Philly location, then they chose right.
			//if the user chose to partner with the cowboys and had a Philly location and no Texas location, then they chose wrong.
			//if the user chose to not partner with the Cowboys and owned Philadelphia, then they chose right.
			//if the user chose to not partner with the cowboys and owned a Texas store but not Philadelphia, then they chose wrong. If the
			//user didn't partner with the cowboys and doesn't own locations in Texas or Philadelphia, there's a 50-50 chance that they chose right
			
			boolean hasPhilly = false, hasTexas = false;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				if(AllCompaniesArray.get(i).name.equals("Philadelphia") && AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					hasPhilly = true;
				if((AllCompaniesArray.get(i).name.equals("El Paso") || AllCompaniesArray.get(i).name.equals("Dallas")) && AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					hasTexas = true;
			}
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 400000;
				if(hasTexas || ((!hasTexas) && (!hasPhilly)))
				{
					PriorityArray.get(0).status = true;
					PriorityArray.get(0).priority += 8;
					PriorityArray.get(0).luck += 80000; 
					changePriority(-4, -30000);
				}
				else if(hasPhilly)
				{
					PriorityArray.get(0).status = false;
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 5000;
				}
				
			}
			else
			{
				if(hasPhilly)
				{
					PriorityArray.get(0).status = true;
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 5000;
				}
				else if(hasTexas)
				{
					PriorityArray.get(0).status = false;
					PriorityArray.get(0).priority -= 5;
					PriorityArray.get(0).luck -= 100000;
					
					for(int i = 0; i < PriorityArray.size(); ++i)
				
				{
					if(PriorityArray.get(i).owner.equals("Toyota"))
					{
						PriorityArray.get(i).priority += 4;
						PriorityArray.get(i).luck += 40000;
						break;
					}
				}
					
				}
				else
				{
					probabilityEvaluator(50, letter);
					if(PriorityArray.get(0).status == true)
					{
						PriorityArray.get(0).priority += 2;
						PriorityArray.get(0).luck += 10000;
					}
					else
					{
						PriorityArray.get(0).luck -= 2000;
						PriorityArray.get(0).priority -= 1;
					}
				}
				
			}
			
			break;
			
		case 25:
			//if the user chose to recall the cars, there's an 100% chance that they chose correctly.
			//if the user chose not to recall the cars, there's a 50% chance that they chose correctly.
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash -= 500000;
				PriorityArray.get(0).status = true;
				PriorityArray.get(0).luck += 100000;
				PriorityArray.get(0).priority += 3;
				changePriority(-2, -30000);
			}
			else
			{
				probabilityEvaluator(50, letter);
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).luck += 50000;
					PriorityArray.get(0).priority += 1;
				}
				else
				{
					PriorityArray.get(0).luck -= 250000;
					PriorityArray.get(0).priority -= 8;
				}
				
			}
			break;
		case 26: 
			//if Universal Wheels owns 60% or more of all locations in the game by value, then there's an 80% chance that
			//outsourcing is a good idea. Otherwise, there's a 20% chance that outsourcing is a good idea.
			int myLocations = 0, allLocations = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				allLocations += AllCompaniesArray.get(i).purchasePrice;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					myLocations += AllCompaniesArray.get(i).purchasePrice;
			}
		
			if(myLocations * 1.0 / allLocations >= 0.60)
				probabilityEvaluator(20, letter);
			else
				probabilityEvaluator(80, letter);
			
			if(letter == 'B')
				PriorityArray.get(0).cash -= 150000;
			
			if(PriorityArray.get(0).status == true)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).priority += 4;
					PriorityArray.get(0).luck += 100000;
				}
				else
				{
					PriorityArray.get(0).priority += 7;
					PriorityArray.get(0).luck += 150000;
					changePriority(-2, -30000);
				}
				
			}
			else
			{
				
				if(letter == 'A')
				{
					PriorityArray.get(0).priority += 1;
					PriorityArray.get(0).luck -= 5000;
				}
				else
				{
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck -= 150000;
					changePriority(2, 30000);
				}
				
				
			}
			break;
			
		case 27:
			//if the user owns 75% or more of all businesses in the game by value, then no matter what, they chose correctly.
			//If not, then if they choose to pay the fine they have a 70% chance of that being the right decision and a 50% chance that
			//paying the bribe is the right decision. However, if they get the bad outcome from paying the bribe, then they will immediately lose
			//the game
			
			int universalValue = 0, allValue = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				allValue += AllCompaniesArray.get(i).purchasePrice;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
					universalValue += AllCompaniesArray.get(i).purchasePrice;
				
			}
			
			if(universalValue * 1.0 / allValue >= 0.75)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).status = true;
					PriorityArray.get(0).cash -= 300000;
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck += 70000;
				}
				else
				{
					PriorityArray.get(0).status = true;
					PriorityArray.get(0).cash -= 50000;
					PriorityArray.get(0).priority += 1;
					PriorityArray.get(0).luck += 10000;
					
				}
				
				
			}
			else
			{
				if(letter == 'A')
					probabilityEvaluator(70, letter);
				else
					probabilityEvaluator(50, letter);
				
				if(PriorityArray.get(0).status == true)
				{
					if(letter == 'A')
					{
						PriorityArray.get(0).cash -= 300000;
						PriorityArray.get(0).priority += 5;
						PriorityArray.get(0).luck += 70000;	
					}
					else
					{
						PriorityArray.get(0).cash -= 50000;
						PriorityArray.get(0).priority += 1;
						PriorityArray.get(0).luck += 10000;	
					}
					
				}
				else
				{
					if(letter == 'A')
					{
						PriorityArray.get(0).cash -= 300000;
						PriorityArray.get(0).priority += 1;
						PriorityArray.get(0).luck += 10000;
					}
					else
					{
						PriorityArray.get(0).cash -= 50000;
						PriorityArray.get(0).priority -= 1000;
						PriorityArray.get(0).luck -= 1000000;
					}
				}
				
			}
			break;
			
		case 28: 
			//if the user owns more wealthy locations (by value) than poorer locations at the federal level, then there is an 85% chance that building
			//a Rose Plaza shop is a good idea. Otherwise, there is a 15% chance that building the Rose Plaza shop is a good idea.
			int yourRich = 0, yourPoor = 0;
			
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String placeName = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(placeName.equals("Ankang China") || placeName.equals("Boston") || placeName.equals("Las Vegas") || placeName.equals("Miami") || placeName.equals("Sacramento") || placeName.equals("Seattle"))
						yourRich += AllCompaniesArray.get(i).purchasePrice;
					else if(placeName.equals("Chicago") || placeName.equals("Philadelphia") || placeName.equals("Detroit") || placeName.equals("New Orleans") || placeName.equals("Topeka"))
						yourPoor += AllCompaniesArray.get(i).purchasePrice;
					
				}
				
			}
			
			if(yourRich * 1.0 / yourPoor >= 1)
			{
				probabilityEvaluator(85, letter);
			}
			else
				probabilityEvaluator(15, letter);
			
			if(PriorityArray.get(0).status == true)
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 750000;
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck += 40000;
					changePriority(-3, -30000);
				}
				else
				{
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 25000;
				}
			}
			else
			{
				if(letter == 'A')
				{
					PriorityArray.get(0).cash -= 750000;
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck -= 50000;
				}
				else
				{
					PriorityArray.get(0).priority -= 2;
					PriorityArray.get(0).luck -= 50000;
					changePriority(2, 25000);
				}
				
				
				
			}
			break;
			
		case 29:
			//if the player owns more rural locations by value at the federal level than urban ones, then there is an 80% chance that building
			//the construction vehicles is a good idea. Otherwise, there is a 20% chance that building the construction vehicles is a good idea.
			int myRuralTotal = 0, myUrbanTotal = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String city_name = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(city_name.equals("Rose Plaza") || city_name.equals("Boston") || city_name.equals("Philadelphia") || city_name.equals("Los_Angeles")
						||	city_name.equals("Chicago") || city_name.equals("Detroit")  || city_name.equals("Denver") || city_name.equals("Miami") 
							 || city_name.equals("Sacramento") || city_name.equals("Seattle"))
						++myUrbanTotal;
					
					else if(city_name.equals("Las Vegas") || city_name.equals("Fargo") || city_name.equals("St Louis") || city_name.equals("Nashville") 
							|| city_name.equals("Dallas") || city_name.equals("EL Paso") || city_name.equals("Glia Bend") || city_name.equals("Macon") 
							|| city_name.equals("Topeka") || city_name.equals("Twin Falls") || city_name.equals("New Orleans"))
						++myRuralTotal;
					
				}
			}
				
				if(myRuralTotal >= myUrbanTotal)
					probabilityEvaluator(80, letter);
				else
					probabilityEvaluator(20, letter);
				
				if(letter == 'A')
				{		PriorityArray.get(0).cash -= 300000;
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck += 70000;
					changePriority(-1, -10000);
				}
				else
				{
					PriorityArray.get(0).priority -= 1;
					PriorityArray.get(0).luck += 5000;
				}
				
			}
				else
				{
					if(PriorityArray.get(0).status == true)
					{
						PriorityArray.get(0).priority += 1;
						PriorityArray.get(0).luck += 15000;
						changePriority(-1, -5000);
					}
					else
					{
						PriorityArray.get(0).priority -= 2;
						PriorityArray.get(0).luck -= 15000;
						changePriority(1, 5000);
					}
					
					
				}
				
			break;
		
		case 30:
			//if the user owns a majority (by value) of their federal level businesses in states which are in favor of increased spending, then there
			//is a 90% chance that partnering with the Department of Defense is a good idea. Otherwise, there is a 10% chance that partnering with
			//the Department of Defense is a good idea.
			
			int myHawks = 0, myDoves = 0;
			for(int i = 0; i < AllCompaniesArray.size(); ++i)
			{
				String township = AllCompaniesArray.get(i).name;
				if(AllCompaniesArray.get(i).owner.equals("Universal Wheels"))
				{
					if(township.equals("Boston") || township.equals("Los Angeles") || township.equals("Chicago") || township.equals("Detroit") || township.equals("Denver") || township.equals("Miami") || township.equals("Sacramento") || township.equals("Seattle"))
						myDoves += AllCompaniesArray.get(i).purchasePrice;
					else if(township.equals("Dallas") || township.equals("Fargo") || township.equals("Glia Bend") || township.equals("El Paso") || township.equals("Macon") || township.equals("Nashville") || township.equals("New Orleans") || township.equals("Topeka")
						|| township.equals("Twin Falls") || township.equals("St Louis"))
					myHawks += AllCompaniesArray.get(i).purchasePrice;
					
				}
			}
			if(myHawks >= myDoves)
				probabilityEvaluator(90, letter);
			else
				probabilityEvaluator(10, letter);
			
			if(letter == 'A')
			{
				PriorityArray.get(0).cash += 350000;
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority = 10;
					PriorityArray.get(0).luck += 200000;
					changePriority(-5, -100000);
				}
				else
				{
					PriorityArray.get(0).priority += 2;
					PriorityArray.get(0).luck += 50000;
				}
			}
			else
			{
				
				if(PriorityArray.get(0).status == true)
				{
					PriorityArray.get(0).priority += 5;
					PriorityArray.get(0).luck += 100000;
				}
				else
				{
					PriorityArray.get(0).priority -= 8;
					PriorityArray.get(0).luck -= 40000;
					changePriority(3, 50000);
				}
			}
			
			break;
		}
			
		
			
		
		returnString = gson.toJson(PriorityArray);
		response.getWriter().println(returnString);
		
	}
//numOwned returns the number of companies owned by the company (which is passed in as name)
	public int numOwned(ArrayList<dataEntry> AllCompanies, String name)
	{
		int counter = 0;
		
		for(int i = 0; i < AllCompanies.size(); ++i)
		{
			if(AllCompanies.get(i).owner.equals(name))
				++counter;
		}
		
		return counter;
		
	}
	//percentOwned returns the percent of all businesses of a certain type owned by owner.
	public double percentOwned(String owner, String type)
	{
		int companyCounter = 0, allCounter = 0;
		
		for(int i = 0; i < AllCompaniesArray.size(); ++i)
		{
			if(AllCompaniesArray.get(i).type.equals(type))
			{
				allCounter += AllCompaniesArray.get(i).purchasePrice;
				if(AllCompaniesArray.get(i).owner.equals(owner))
				companyCounter += AllCompaniesArray.get(i).purchasePrice;
				
			}
			
		}
		
		return (1.0 * companyCounter / allCounter);
		
	}
	//returns true if the company specified by owner owns the city passed in, and false otherwise.
	public boolean owns(String owner, String city)
	{
		for(int i = 0; i < AllCompaniesArray.size(); ++i)
		{
			if(AllCompaniesArray.get(i).name.equals(city))
			{
				if(AllCompaniesArray.get(i).owner.equals(owner))
					return true;
				else return false;
			}
		}
		
		return false;
		
	}
	
	//prob1 is percent probability in numeric form of choice A being right. (ex. 35 for 35 %) letter represents the user's choice
	//This function changes the status of Universal Wheels in the PriorityArray.
	public void probabilityEvaluator(int prob1, char letter)
	{
		int initialProb = prob1 * 10000;
		initialProb -= new Random().nextInt(1000000);
		
		if(initialProb >= 0)
		{
			if(letter == 'A')
				PriorityArray.get(0).status = true;
			else
				PriorityArray.get(0).status = false;
			
			return;
		}
		else
		{
			if(letter == 'A')
				PriorityArray.get(0).status = false;
			else
				PriorityArray.get(0).status = true;
			return;
			
		}
		
	}
	
	//changePriority alters the luck and priority of every company besides Universal Wheels by the specified amount.
	public void changePriority(int priorityChange, int luckChange)
	{
		for(int i = 1; i < PriorityArray.size(); ++i)
		{
			PriorityArray.get(i).priority += priorityChange;
			PriorityArray.get(i).luck += luckChange;
		}
	}
	
	//changePrioritySpecific alters the priority and luck of the company specified by owner.
	public void changePrioritySpecific(String owner, int priorityChange, int luckChange)
	{
		for(int i = 0; i < PriorityArray.size(); ++i)
		{
			if(PriorityArray.get(i).owner.equals(owner))
			{
				PriorityArray.get(i).priority += priorityChange;
				PriorityArray.get(i).luck += luckChange;
				return;
			}
		}
		
	}
	
	
	
}
