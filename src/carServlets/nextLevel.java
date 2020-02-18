package carServlets;

import companyAttributes.priorityVal;
import dataProcessingObjects.PriorityReader;
import java.util.*;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;


//nextLevel is a servlet called when the user advances to the next level. It populates the PriorityArray with new companies, and chooses what initial
//amounts of priority luck and cash each company has.
/**
 * Servlet implementation class gameStart
 */
@WebServlet("/nextLevel")
public class nextLevel extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public nextLevel() {
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
		
		String swapVal;
		int otherIndex;
		ArrayList<priorityVal> myPriorities = new PriorityReader().returnPriority(request.getParameter("myPriority"));
	
		
		int levelNum = Integer.parseInt(request.getParameter("level"));
		String[] stringList = new String[4];
		
		if(levelNum == 1)
		{
		
			stringList[0] = "Westchester Discount Cars";
			stringList[1] = "Ford";
			stringList[2] = "Jungle Cars";
			stringList[3] = "Panther Deals";
			for(int i = 0; i < 4; ++i)
			{
				swapVal = stringList[i];
				otherIndex = new Random().nextInt(4);
				stringList[i] = stringList[otherIndex];
				stringList[otherIndex] = swapVal;
			}
			myPriorities.add(new priorityVal(stringList[0], 6, 15000, true, 200000));
			myPriorities.add(new priorityVal(stringList[1], 5, 10000, true, 150000));
			myPriorities.add(new priorityVal(stringList[2], 5, 10000, true, 150000));
			myPriorities.add(new priorityVal(stringList[3], 4, 5000, true, 100000));
			
		}
		else if(levelNum == 2)
		{
			myPriorities.get(0).cash += 100000;
			myPriorities.get(0).priority = 9;
			myPriorities.get(0).luck = 15000;
			stringList[0] = "BMW";
			stringList[1] = "Volkswagen";
			stringList[2] = "Honda";
			stringList[3] = "Subaru";
			
			for(int i = 0; i < 4; ++i)
			{
				swapVal = stringList[i];
				otherIndex = new Random().nextInt(4);
				stringList[i] = stringList[otherIndex];
				stringList[otherIndex] = swapVal;
			}
			myPriorities.add(new priorityVal(stringList[0], 7, 30000, true, 300000));
			myPriorities.add(new priorityVal(stringList[1], 5, 40000, true, 250000));
			myPriorities.add(new priorityVal(stringList[2], 5, 40000, true, 250000));
			myPriorities.add(new priorityVal(stringList[3], 3, 3000, true, 200000));	
		}
		else
		{
			myPriorities.get(0).cash += 200000;
			myPriorities.get(0).priority = 9;
			myPriorities.get(0).luck = 15000;
			stringList[0] = "Jaguar";
			stringList[1] = "Nissan";
			stringList[2] = "Toyota";
			stringList[3] = "Ram";
			
			for(int i = 0; i < 4; ++i)
			{
				swapVal = stringList[i];
				otherIndex = new Random().nextInt(4);
				stringList[i] = stringList[otherIndex];
				stringList[otherIndex] = swapVal;	
			}
			myPriorities.add(new priorityVal(stringList[0], 13, 100000, true, 500000));
			myPriorities.add(new priorityVal(stringList[1], 7, 70000, true, 400000));
			myPriorities.add(new priorityVal(stringList[2], 7, 70000, true, 400000));
			myPriorities.add(new priorityVal(stringList[3], 3, 3000, true, 200000));
		}
		
		
		
		Gson gson = new Gson();
		String returnVal = gson.toJson(myPriorities);
		response.getWriter().println(returnVal);
		return;
	}

}
