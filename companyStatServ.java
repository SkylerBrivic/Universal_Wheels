package carServlets;

import companyAttributes.dataEntry;
import dataProcessingObjects.AllCompanyReader;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.*;

import com.google.gson.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * Servlet implementation class companyStatServ
 */
@WebServlet("/companyStatServ")
public class companyStatServ extends HttpServlet {
	private static final long serialVersionUID = 1L;
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public companyStatServ() {
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
		
		
		
		boolean continuing = false;
		String arrayString = request.getParameter("myArray");
		AllCompanyReader reader = new AllCompanyReader();
		
		//Converting arrayString into an ArrayList of dataEntry objects representing all business locations currently
		//available to the player
		ArrayList<dataEntry> allDataArray = reader.getArrayData(arrayString);
		ArrayList<dataEntry> returnDataArray = new ArrayList<dataEntry>();
		
		String CitiesString = request.getParameter("City");
		String TypeString = request.getParameter("Type");
		String OwnerString = request.getParameter("Owner");
		String CostString = request.getParameter("Cost");
		String LocationString = request.getParameter("Location");
		String DayString = request.getParameter("Day");
		
		//creating arrays of Strings that store all of the sort criteria selected by the user
		String[] CitiesArray = CitiesString.split(",");
		String[] TypeArray = TypeString.split(",");
		String[] OwnerArray = OwnerString.split(",");
		String[] CostArray = CostString.split(",");
		String[] LocationArray = LocationString.split(",");
		String[] DayArray = DayString.split(",");
		
		
		if(allDataArray == null)
		{
			response.getWriter().println("null");
			return;
		}
	
			
		//for each criteria, options within a particular category are or'd (either one can be true to add the item to the list) and
		//are and'ed with criteria in other categories. Ex. If Ardsley and Bedford are selected under city name and Universal Wheels is selected as
		//the owner, then the list would return each location owned by Universal Wheels which is either Ardsley or Bedford (at most, Ardsley and Bedford
		//at least, 0 entries
		
		for(int index = 0; index < allDataArray.size(); ++index)
		{
			continuing = false;
			
			for(int tempIndex = 0; tempIndex < CitiesArray.length; ++tempIndex)
			{
				if(allDataArray.get(index).name.equals(CitiesArray[tempIndex]) || CitiesArray[tempIndex].equals("All"))
				{
					continuing = true;
					break;
				}
				
			}
			if(continuing == false)
				continue;
			
			continuing = false;
			
			for(int tempIndex = 0; tempIndex < TypeArray.length; ++tempIndex)
			{
				if(allDataArray.get(index).type.equals(TypeArray[tempIndex]) || TypeArray[tempIndex].equals("All"))
				{
					continuing = true;
					break;
				}
				
			}
			
			if(continuing == false)
				continue;
			
			continuing = false;
			
			for(int tempIndex = 0; tempIndex < OwnerArray.length; ++tempIndex)
			{
				
				if(allDataArray.get(index).owner.equals(OwnerArray[tempIndex]) || OwnerArray[tempIndex].equals("All"))
				{
					continuing = true;
					break;
				}
				
			}
			
			if(continuing == false)
				continue;
			
			continuing = false;
			
			
			for(int tempIndex = 0; tempIndex < CostArray.length; ++tempIndex)
			{
				if(CostArray[tempIndex].equals("All"))
				{
					continuing = true;
					break;
				}
				
				if(CostArray[tempIndex].equals("50000") && allDataArray.get(index).purchasePrice <= 50000)
				{
				
					continuing = true;
					break;
				}
				
					
				
				if(CostArray[tempIndex].equals("100000") && allDataArray.get(index).purchasePrice > 50000 && allDataArray.get(index).purchasePrice <= 100000)
				{
				
					continuing = true;
					break;	
				}
				
				if(CostArray[tempIndex].equals("300000") && allDataArray.get(index).purchasePrice > 100000 && allDataArray.get(index).purchasePrice <= 300000)
				{
					continuing = true;
					break;
				}
			
				if(CostArray[tempIndex].equals("500000") && allDataArray.get(index).purchasePrice > 300000 && allDataArray.get(index).purchasePrice <= 500000)
				{
					continuing = true;
					break;
				}
			
			if(CostArray[tempIndex].equals("1000000") && allDataArray.get(index).purchasePrice > 500000)
				{
					continuing = true;
					break;
				}
			
			
		}
		
	if(continuing == false)
		continue;
	
	continuing = false;
	
	
	for(int tempIndex = 0; tempIndex < LocationArray.length; ++tempIndex)
		{
		if(allDataArray.get(index).location.equals(LocationArray[tempIndex]) || LocationArray[tempIndex].equals("All"))
		{
			continuing = true;
			break;
		}
		
		}
	if(continuing == false)
		continue;
	
	continuing = false;
	
	for(int tempIndex = 0; tempIndex < DayArray.length; ++tempIndex)
	{
		if(DayArray[tempIndex].equals("All"))
		{
			continuing = true;
			break;
		}
		
		if(DayArray[tempIndex].equals("4") && allDataArray.get(index).monthDate <= 4 && allDataArray.get(index).monthDate >= 0)
		{
		
			continuing = true;
			break;
		}
		
			
		
		if(DayArray[tempIndex].equals("9") && allDataArray.get(index).monthDate > 4 && allDataArray.get(index).monthDate <= 9)
		{
		
			continuing = true;
			break;	
		}
		
		if(DayArray[tempIndex].equals("14") && allDataArray.get(index).monthDate > 9 && allDataArray.get(index).monthDate <= 14)
		{
			continuing = true;
			break;
		}
	
		if(DayArray[tempIndex].equals("19") && allDataArray.get(index).monthDate > 14 && allDataArray.get(index).monthDate <= 19)
		{
			continuing = true;
			break;
		}
	
	if(DayArray[tempIndex].equals("24") && allDataArray.get(index).monthDate > 19 && allDataArray.get(index).monthDate <= 24)
		{
			continuing = true;
			break;
		}
	if(DayArray[tempIndex].equals("30") && allDataArray.get(index).monthDate > 24)
	{
		continuing = true;
		break;
	}
	}
	
	if(continuing == false)
		continue;
	continuing = false;
	returnDataArray.add(allDataArray.get(index));
		}	
		
		boolean sortInOrder;
		String sortCriteria = request.getParameter("sortType");
		if(request.getParameter("Forward").equals("true"))
				sortInOrder = true;
		else
			sortInOrder = false;
		
		//Collections.sort is called on on the returnDataArray using a particular comparator (one for each criteria exists).
		//if the reverse option is selected, then Collections.reverse is called on the array after it is sorted.
		
		if(sortCriteria != "None")
		{
			if(sortCriteria.equals("City"))
			{
					Collections.sort(returnDataArray, new CitySort());
					if(sortInOrder == false)
						Collections.reverse(returnDataArray);
				
			}
			else if(sortCriteria.equals("Type"))
			{
				Collections.sort(returnDataArray, new TypeSort());
				if(sortInOrder == false)
					Collections.reverse(returnDataArray);
			}
			else if(sortCriteria.equals("Owner"))
			{
				Collections.sort(returnDataArray,  new OwnerSort());
				if(sortInOrder == false)
				{
					Collections.reverse(returnDataArray);
				}
			}
			else if(sortCriteria.equals("Cost"))
			{
				
				Collections.sort(returnDataArray, new CostSort());
				if(sortInOrder == false)
				{
					Collections.reverse(returnDataArray);
				}
				
			}
			else if(sortCriteria.equals("Location"))
			{
				Collections.sort(returnDataArray, new OwnerSort());
				if(sortInOrder == false)
					Collections.reverse(returnDataArray);
			}
			
			else
			{
				Collections.sort(returnDataArray,  new MonthSort());
				if(sortInOrder == false)
					Collections.reverse(returnDataArray);
			}
			
			
			
		}
		//converting the returnDataArray ArrayList to a JSON String and sending this JSON string back to the client.
		Gson gson = new Gson();
		String jsonInString = gson.toJson(returnDataArray);
		response.getWriter().println(jsonInString);
			
		return;
	         }

	
	
	//CitySort compares by city name alphabetically
	class CitySort implements Comparator<dataEntry>
	{

		@Override
		public int compare(dataEntry o1, dataEntry o2)
		{
			return (o1.name).compareTo(o2.name);
		}
	
	
	}
	//typeSort compares by type (factories before stores)
	class TypeSort implements Comparator<dataEntry>
	{
	@Override
	public int compare(dataEntry o1, dataEntry o2)
	{
		return (o1.type).compareTo(o2.type);
	}
		
}
	//OwnerSort compares by owner name alphabetically
	class OwnerSort implements Comparator<dataEntry>
	{
		@Override
		public int compare(dataEntry o1, dataEntry o2)
		{
			return (o1.owner).compareTo(o2.owner);
		}
		
		
	}
	//LocationSort compares by location name alphabetically
	class LocationSort implements Comparator<dataEntry>
	{
		@Override
		public int compare(dataEntry o1, dataEntry o2)
		{
			return (o1.location).compareTo(o2.location);
		}
		
	}
	
	//CostSort compares by purchase Price, with the lower prices going first
	class CostSort implements Comparator<dataEntry>
	{
		
		@Override
		public int compare(dataEntry o1, dataEntry o2)
		{
			return o1.purchasePrice - o2.purchasePrice;
		}
	}
	
	//MonthSort compares by monthDate, with locations purchased on earlier days in the month
	//appearing first
	
	class MonthSort implements Comparator<dataEntry>
	{
		
		@Override
		public int compare(dataEntry o1, dataEntry o2)
		{
			return o1.monthDate - o2.monthDate;
		}
		
		
	}

}
