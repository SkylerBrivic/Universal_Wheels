package dataProcessingObjects;
import companyAttributes.priorityVal;
import java.util.ArrayList;


//A PriorityReader takes as input a JSON string representing a JavaScript array of PriorityVals and converts it
//to a Java ArrayList of PriorityVals.
public class PriorityReader 

{

	public ArrayList<priorityVal> returnPriority(String arrayString)
	{
		if(arrayString.length() <= 3)
			return null;
		
		boolean continuing = true;
		int initialIndex = 1;
		int pipeLocation;
		String tempOwner;
		int tempBasePriority, tempLuck, cash;
		boolean status;
		priorityVal tempPriorityVal;
		ArrayList<priorityVal> answerArray = new ArrayList<priorityVal>();
		arrayString = arrayString.replace("\"", "");
		arrayString = arrayString.replace("{", "");
		arrayString = arrayString.replace("}", "");
		arrayString = arrayString.replace("[", "");
		arrayString = arrayString.replace(",", "");
		arrayString = arrayString.replace(":", "|");
		arrayString = arrayString.replace("_", " ");
		arrayString = arrayString.replace("owner", "");
		arrayString = arrayString.replace("priority", "");
		arrayString = arrayString.replace("luck", "");
		arrayString = arrayString.replace("status", "");
		arrayString = arrayString.replace("cash", "");
		
		
		while(continuing)
		{
			pipeLocation = arrayString.indexOf('|', initialIndex);
			tempOwner = arrayString.substring(initialIndex, pipeLocation);
			initialIndex = pipeLocation + 1;
			pipeLocation = arrayString.indexOf('|', initialIndex);
			tempBasePriority = Integer.parseInt(arrayString.substring(initialIndex, pipeLocation));
			initialIndex = pipeLocation + 1;
			pipeLocation = arrayString.indexOf('|', initialIndex);
			tempLuck = Integer.parseInt(arrayString.substring(initialIndex, pipeLocation));
			initialIndex = pipeLocation + 1;
			pipeLocation = arrayString.indexOf('|', initialIndex);
			status = Boolean.parseBoolean(arrayString.substring(initialIndex, pipeLocation));
			initialIndex = pipeLocation + 1;
			if(arrayString.indexOf('|', initialIndex) == -1)
			{
			continuing = false;
			pipeLocation = arrayString.indexOf(']', initialIndex);
			cash = Integer.parseInt(arrayString.substring(initialIndex, pipeLocation));	
			}
			else
			{
				pipeLocation = arrayString.indexOf('|', initialIndex);
				cash = Integer.parseInt(arrayString.substring(initialIndex, pipeLocation));
				initialIndex = pipeLocation + 1;	
			}
			tempPriorityVal = new priorityVal(tempOwner, tempBasePriority, tempLuck, status, cash);
			answerArray.add(tempPriorityVal);
				
		}
		return answerArray;
		
	}
	
}
