package dataProcessingObjects;

import companyAttributes.dataEntry;
import java.util.ArrayList;


//AllCompanyReader contains one method, getArrayData, which takes a JSON string representing a JavaScript array of dataEntrys and converts
//it to a java arrayList of data entries.
public class AllCompanyReader

{

	public ArrayList<dataEntry> getArrayData(String arrayString)
	{
		int current_position = 3;
		int pipe_location = 1;
		dataEntry tempEntry = null;
		String tempCity, tempType, tempOwner, tempPurchase, tempLocation, tempMonth;
		ArrayList<dataEntry> returnArray = null;
		if(arrayString.length() < 6)
			return returnArray;
		
		//the names of the fields of each dataEntry are replaced with pipe symbols to make subsequent processing of the string easier
		returnArray = new ArrayList<dataEntry>();
		arrayString = arrayString.replace("\"", "");
		arrayString = arrayString.replace(",", "");
		arrayString = arrayString.replace(":", "");
		arrayString = arrayString.replace("name", "|");
		arrayString = arrayString.replace("type", "|");
		arrayString = arrayString.replace("owner", "|");
		arrayString = arrayString.replace("purchasePrice", "|");
		arrayString = arrayString.replace("returnPrice", "|");
		arrayString = arrayString.replace("location", "|");
		arrayString = arrayString.replace("monthDate", "|");
		arrayString = arrayString.replace("_", " ");
		
		
		returnArray = new ArrayList<dataEntry>();
		while(arrayString.charAt(current_position) != ']' && current_position < arrayString.length())
		{
			 tempEntry = new dataEntry();
			
			pipe_location = arrayString.indexOf('|', current_position);
			tempCity = arrayString.substring(current_position, pipe_location);
			tempEntry.name = tempCity;
			current_position = pipe_location + 1;
			pipe_location = arrayString.indexOf('|', current_position);
			tempType = arrayString.substring(current_position, pipe_location);
			tempEntry.type = tempType;
			current_position = pipe_location + 1;
			pipe_location = arrayString.indexOf('|', current_position);
			tempOwner = arrayString.substring(current_position, pipe_location);
			tempEntry.owner = tempOwner;
			current_position = pipe_location + 1;
			pipe_location = arrayString.indexOf('|', current_position);
			tempPurchase = arrayString.substring(current_position, pipe_location);
			tempEntry.purchasePrice = Integer.parseInt(tempPurchase);
			current_position = pipe_location + 1;
			pipe_location = arrayString.indexOf('|', current_position);
			tempEntry.returnPrice = Integer.parseInt(arrayString.substring(current_position, pipe_location));
			current_position = pipe_location + 1;
			pipe_location = arrayString.indexOf('|', current_position);
			tempLocation = arrayString.substring(current_position, pipe_location);
			tempEntry.location = tempLocation;
			current_position = pipe_location + 1;
			pipe_location = arrayString.indexOf('}', current_position);
			tempMonth = arrayString.substring(current_position, pipe_location);
			tempEntry.monthDate = Integer.parseInt(tempMonth);
			returnArray.add(tempEntry);
			if(arrayString.charAt(pipe_location + 1) == ']')
				break;
			current_position = pipe_location + 3;
			
		}
		
		
		return returnArray;
	}
}
