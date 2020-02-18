package carServlets;

import companyAttributes.*;
import dataProcessingObjects.*;

import java.util.*;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

//the setMap servlet is called when a user advances to the next level. It randomly selects which locations on the map
//each business business besides Universal Wheels will buy.
/**
 * Servlet implementation class setMap
 */
@WebServlet("/setMap")
public class setMap extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public setMap() {
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
		
	int tempStoreCount = 0;
	int tempIndex = 1;
	int companyIndex = 0;
	boolean continuing = true, found = false;
	ArrayList<priorityVal> myPriorities = new PriorityReader().returnPriority(request.getParameter("myPriorities"));
	ArrayList<dataEntry> allCompanies = new AllCompanyReader().getArrayData(request.getParameter("AllCompanies"));
	ArrayList<transaction> myTransactions = new ArrayList<transaction>();
	
	while(continuing)
	{
		
		if(tempStoreCount >= 3)
		{
			tempIndex += 1;
			tempStoreCount = 0;
		}
		
		found = false;
		
		if(tempIndex >= myPriorities.size())
			break;
		
		companyIndex = new Random().nextInt(allCompanies.size());
		
		if(allCompanies.get(companyIndex).purchasePrice < myPriorities.get(tempIndex).cash)
		{
			myTransactions.add(new transaction(myPriorities.get(tempIndex).owner, allCompanies.get(companyIndex).name, "Purchase", -1 * allCompanies.get(companyIndex).purchasePrice));
			myPriorities.get(tempIndex).cash -= allCompanies.get(companyIndex).purchasePrice;
			allCompanies.remove(companyIndex);
			++tempStoreCount;
		}
		else
		{
			for(int i = 0; i < allCompanies.size(); ++i)
			{
				if(allCompanies.get(i).purchasePrice < myPriorities.get(tempIndex).cash)
				{
					found = true;
					break;
				}
			}
			if(found == true)
				continue;
			else
				{
				++tempIndex;
				tempStoreCount = 0;
				}
		}
		
		
		
	
		
		if(tempIndex >= myPriorities.size())
			break;
		
		

		
	}
	Gson gson = new Gson();
	String returnString = gson.toJson(myTransactions);
	response.getWriter().println(returnString);
	return;
	}

}

