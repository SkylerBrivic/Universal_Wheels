<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import ="com.google.gson.*" %>



<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
 <script type = "text/javascript" src = "http://code.jquery.com/jquery-1.10.0.min.js">
</script>
<script>
//a dataEntry object represents a particular location on the map and its associated properties of name (city name) type (either store or factory),
//the name of its owner, its purchase price, its return price, its location within the United States (either Westchester, New York, or Outside New York) and the day of the month it was purchased on.
class dataEntry {
	constructor(name, type, owner, purchasePrice, returnPrice, location, monthDate)
	{
		this.name = name;
		this.type = type;
		this.owner = owner;
		this.purchasePrice = purchasePrice;
		this.returnPrice = returnPrice;
		this.location = location;
		this.monthDate = monthDate;
		
	}
	
}

//a priorityVal object represents a company's name, its associated priority (long-term luck), its luck (short-term luck), a status (used to determine if the last decision resulted in a positive
//or negative outcome for Universal Wheels), and an amount of cash.
class priorityVal {
	constructor(owner, priority, luck, status, cash)
	{
		this.owner = owner;
		this.priority = priority;
		this.luck = luck;
		this.status = status;
		this.cash = cash;
	}
}

//a transaction object stores an owner (who is affected by the transaction), a city that the transaction occurs on, a type of transaction, and a cost
//associated with the transaction (which can be positive to represent a gain in money and negative to represent a loss)
class transaction {
	constructor(owner, city, type, cost)
	{
		this.owner = owner;
		this.city = city;
		this.type = type;
		this.cost = cost;
	}
}

//a highScore object stores a username, a statistic (either a completion time or an amount of money), and a datetime that the score was set on
class highScore{
	constructor(username, statistic, dateSet)
	{
		this.username = username;
		this.statistic = statistic;
		this.dateSet = dateSet;
	}
}


//this function is called when the submit button is clicked on the page that returns information about each business that the user requests.
//the function prevents the page from being reloaded, and also calls the servlet companyStatServ to proccess the user's request for information about
//each business location

$(document).ready(function(){
$("#submit").click(function(event)
		{ 
	
	
	event.preventDefault();
		var City = $("#City").val();
		var new_array = [];
		var Results = [];	
		var InorderSort;
		if(City != undefined && City != null && City.length > 0)
		City = City.toString();
		else
			City = "All";
		
	        var Type = $("#Type").val();
	        if(Type != undefined && Type != null && Type.length > 0)
	    		Type = Type.toString();
	        else
	        	Type = "All";
	        
	        var Owner = $("#Owner").val();
	        if(Owner != undefined && Owner != null && Owner.length > 0)
	    		Owner = Owner.toString();
	        else
	        	Owner = "All";
	        
	        var Cost = $("#Cost").val();
	        if(Cost != undefined && Cost != null && Cost.length > 0)
	        	Cost = Cost.toString();
	        else
	        	Cost = "All";
	        
	        var Location = $("#Location").val();
	        if(Location != undefined && Location != null && Location.length > 0)
	    		Location = Location.toString();
	        else
	        	Location = "All";
	        
	        var Day = $("#Day").val();
	        if(Day != undefined && Day != null && Day.length > 0)
	    		Day = Day.toString();
	        else
	        	Day = "All";
	        
	        var sortType = $('#Sort').val();
	        if (sortType == undefined || sortType == null)
	        	sortType = "None";
	        
	        if(document.getElementById("InorderSort").checked == true)
	        	 InorderSort = true;
	        else
	        	InorderSort = false;
	        
	        console.log(AllCompanies);
	        if(level == 1)
	        	{
	        	for(var i = 0; i < AllCompanies.length; ++i)
	        	
	        		if(AllCompanies[i].location == 'Westchester')
	        			new_array.push(AllCompanies[i]);
	        	}
	        else if(level == 2)
	        	{
	        	for(var i = 0; i < AllCompanies.length; ++i)
	        	
	        		if(AllCompanies[i].location == 'Westchester' || AllCompanies[i].location == 'New York')
	        			new_array.push(AllCompanies[i]);
	        	}
	        else
	        	new_array = AllCompanies;
	        
	         new_array = JSON.stringify(new_array);
	      
	        
	        
	        $.ajax({
	            url: 'companyStatServ',
	            type: 'POST',
	            data: {
	                'City':City,
	                'Type':Type,
	                'Owner':Owner,
	                'Cost': Cost,
	                'Location':Location,
	                'Day':Day,
	                'sortType':sortType,
	                'myArray': new_array,
	                'Forward': InorderSort
	            },
	            success: function(data) {
	            	if(data != "null") 
	            	Results = JSON.parse(data);
	                databaseLoad(Results);
	                document.getElementsByClassName("databaseSearchMenu")[0].style.display = "none";
	                inSearch = false;
	            },
	            failure: function(data) {
	                alert('Update Failed');
	                inSearch = false;
	            }
	        });	
		 
	});
		
		
});
	
//this function prevents the high score submit button from reloading the page and prevents the high score sort button from reloading the page.

$(document).ready(function () {
	  // Listen to click event on the submit button
	  $('#button').submit(function (e) {

	    e.preventDefault();
	  });
	  $('#sortButton').submit(function (e) {
		  e.preventDefault();
	  });
	  
	  });
 </script>
 
 <script>
 //inTime represents which set of highscores to load (time scores are loaded if inTime is true. Otherwise, money scores are loaded)
var inTime = true;
//the PriorityArray stores the names and attributes of each company, and is set to contain the value of Universal Wheels before the game starts
var PriorityArray = [];

PriorityArray.push(new priorityVal("Universal Wheels", 5, 10000, true, 150000));

//the AllCompanies array stores the name and attributes of each business location in the game.
var AllCompanies = [];

//the level stores how far in the game the player is. 0 means the game hasn't started, 1 is the Westchester level, 2 is the New York level, and 3 is the USA level.
var level = 0;

//All business locations (except the two hidden ones) are pushed onto the AllCompanies array. Each business location is given an initial owner of "None"
//and an initial purchase date of -1

AllCompanies.push(new dataEntry("Albany", "Store", "None", 45000, 30000, "New York", -1));
AllCompanies.push(new dataEntry("Ardsley", "Store", "None", 65000, 35000, 'Westchester', -1));
AllCompanies.push(new dataEntry("Armonk", "Factory", "None", 150000, 130000, 'Westchester', -1));
AllCompanies.push(new dataEntry('Bedford', 'Factory', 'None', 28000, 14000, 'Westchester', -1));
AllCompanies.push(new dataEntry('Boston', 'Store', 'None', 270000, 220000, 'Outside New York', -1));
AllCompanies.push(new dataEntry("Bronx", "Factory", "None", 230000, 180000, "New York", -1));
AllCompanies.push(new dataEntry("Brooklyn", "Factory", "None", 270000, 230000, "New York", -1));
AllCompanies.push(new dataEntry("Buffalo", "Store", "None", 55000, 40000, "New York", -1));
AllCompanies.push(new dataEntry("Chicago", "Store", "None", 180000, 90000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Dallas", "Store", "None", 550000, 400000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Denver", "Store", "None", 350000, 200000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Detroit", "Factory", "None", 10000, 2000, "Outside New York", -1));
AllCompanies.push(new dataEntry("El Paso", "Factory", "None", 400000, 300000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Elmsford", "Factory", "None", 170000, 120000, "Westchester", -1));
AllCompanies.push(new dataEntry("Fargo", "Factory", "None", 480000, 350000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Glia Bend", "Factory", "None", 100000, 60000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Ithaca", "Store", "None", 70000, 35000, "New York", -1));
AllCompanies.push(new dataEntry("Jamestown", "Factory", "None", 250000, 200000, "New York", -1));
AllCompanies.push(new dataEntry("Las Vegas", "Factory", "None", 2100000, 1700000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Long Island", "Store", "None", 100000, 75000, "New York", -1));
AllCompanies.push(new dataEntry("Los Angeles", "Store", "None", 210000, 150000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Macon", "Store", "None", 40000, 5000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Mamaroneck", "Store", "None", 15000, 12000, "Westchester", -1));
AllCompanies.push(new dataEntry("Manhattan", "Store", "None", 485000, 200000, "New York", -1));
AllCompanies.push(new dataEntry("Mechanicville", "Factory", "None", 170000, 130000, "New York", -1));
AllCompanies.push(new dataEntry("Miami", "Store", "None", 55000, 30000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Mohegan Lake", "Factory", "None", 35000, 20000, "Westchester", -1));
AllCompanies.push(new dataEntry("Mount Vernon", "Store", "None", 10000, 1000, "Westchester", -1));
AllCompanies.push(new dataEntry("Mt Kisco", "Store", "None", 120000, 90000, 'Westchester', -1));
AllCompanies.push(new dataEntry("Nashville", "Factory", "None", 280000, 200000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Newburgh", "Store", "None", 25000, 20000, "New York", -1));
AllCompanies.push(new dataEntry("New Orleans", "Store", "None", 10000, 5000, "Outside New York", -1));
AllCompanies.push(new dataEntry("New Rochelle", "Store", "None", 50000, 30000, 'Westchester', -1));
AllCompanies.push(new dataEntry("Niagara Falls", "Store", "None", 200000, 120000, "New York", -1));
AllCompanies.push(new dataEntry("North Salem", "Store", "None", 10000, 5000, "Westchester", -1));
AllCompanies.push(new dataEntry("Olean", "Factory", "None", 60000, 40000, "New York", -1));
AllCompanies.push(new dataEntry("Ossining", "Factory", "None", 35000, 5000, "Westchester", -1));
AllCompanies.push(new dataEntry("Peekskill", "Factory", "None", 20000, 10000, "Westchester", -1));
AllCompanies.push(new dataEntry("Philadelphia", "Store", "None", 35000, 20000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Plattsburgh", "Store", "None", 30000, 20000, "New York", -1));
AllCompanies.push(new dataEntry("Portchester", "Store", "None", 7000, 300, "Westchester", -1));
AllCompanies.push(new dataEntry("Poughkeepsie", "Store", "None", 65000, 50000, "New York", -1));
AllCompanies.push(new dataEntry("Queens", "Factory", "None", 310000, 200000, "New York", -1));
AllCompanies.push(new dataEntry("Rochester", "Factory", "None", 240000, 180000, "New York", -1));
AllCompanies.push(new dataEntry("Sacramento", "Store", "None", 250000, 200000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Scarsdale", "Store", "None", 180000, 140000, "Westchester", -1));
AllCompanies.push(new dataEntry("Seattle", "Factory", "None", 310000, 260000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Staten Island", "Store", "None", 150000, 100000, "New York", -1));
AllCompanies.push(new dataEntry("St Louis", "Store", "None", 65000, 40000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Somers", "Factory", "None", 45000, 35000, "Westchester", -1));
AllCompanies.push(new dataEntry("Syracuse", "Store", "None", 20000, 15000, "New York", -1));
AllCompanies.push(new dataEntry("Topeka", "Store", "None", 40000, 30000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Troy", "Store", "None", 45000, 30000, "New York", -1));
AllCompanies.push(new dataEntry("Tuckahoe", "Store", "None", 40000, 20000, "Westchester", -1));
AllCompanies.push(new dataEntry("Tupper Lake", "Factory", "None", 400000, 300000, "New York", -1));
AllCompanies.push(new dataEntry("Twin Falls", "Factory", "None", 130000, 90000, "Outside New York", -1));
AllCompanies.push(new dataEntry("Valhalla", "Store", "None", 40000, 25000, "Westchester", -1));
AllCompanies.push(new dataEntry("Watertown", "Factory", "None", 170000, 130000, "New York", -1));
AllCompanies.push(new dataEntry("White Plains", "Store", "None", 70000, 50000, "Westchester", -1));
AllCompanies.push(new dataEntry("Yonkers", 'Store', 'None', 50000, 35000, "Westchester", -1));
AllCompanies.push(new dataEntry("Yorktown", "Store", "None", 25000, 17000, "Westchester", -1));

//the decisionsHappened array stores which decisions the user has already made
var decisionsHappened =  [];

//this game is 50 fps
 var frame_counter = 0
 var day_num = 1;
 var months = 0;
 var years = 0;
 
 //inDescription keeps track of if the user is in a business description or not, UpdateClock indicates whether or not time is passing, and mapLocation indicates which map the user is in
 var inDescription = false;
 var inSearch = false;
 var UpdateClock = false;
 var TimerVar;
 var mapLocation = "Westchester";
 //level_1_timestamp and level_2_timestamp are the times that the user completed levels 1 and 2 respectively.
 var level_1_timestamp = 0;
 var level_2_timestamp = 0;
 
 
 
 //totalDays returns the total number of in-game days that have passed since the game was started
 function totalDays()
 {
	 return ((years * 365) + (months * 30) + day_num);
 }
 
 //startGame is called when the player selects the start game option on the main menu
 function startGame()
  {
	 //the decisionsHappened array is initialized such that all spots are set to false (meaning none have happened yet)
	 for(var i = 0; i < 30; ++i)
		 decisionsHappened.push(false);
	 document.getElementsByClassName("mainWindow")[0].style.display = "none";
	 UpdateClock = true;
	 inDescription = false;
	  document.getElementsByClassName("WestchesterWindow")[0].style.display = "inline";
	  document.getElementById("Timer1").innerHTML = "Years: " + years + " Months: " + months + " Days: " + day_num;

	  document.getElementById("PurchaseID1").innerHTML = ("Total Cash: $" + numToComma(PriorityArray[0].cash));
	  nextLevel();
	  $(document).ready(function(){
		 for(var i = 0; i < AllCompanies.length; ++i)
			{
			 
			 if(AllCompanies[i].owner == "None" && AllCompanies[i].type == "Store" && AllCompanies[i].location == "Westchester")
				 document.getElementsByClassName(AllCompanies[i].name.replace(/ /g, "_") + "_Dot")[0].style.backgroundColor = "red";
				
			else if(AllCompanies[i].owner == "None" && AllCompanies[i].type == "Factory" && AllCompanies[i].location == "Westchester")
				document.getElementsByClassName(AllCompanies[i].name.replace(/ /g, "_") + "_Square")[0].style.backgroundColor = "purple";
					
			}
	  });
	  //this timer allows for time to pass, with the moveTime function being called every 1/50th of a second (making the game effectively 50 fps)
	  TimerVar = setInterval(moveTime, 20);
	  
	  
  }
 
 //the nextLevel function takes the player to the next level
 function nextLevel()
 {
	 $( document ).ready(function() {
	 level = level + 1;
	 var PriorityString = JSON.stringify(PriorityArray);
	 var tempArray = [];
	 var transactionArray = [];

	 //the nextLevel servlet is called to change which companies are currently in the game and the priority and luck of Universal Wheels
	 $.ajax({
         url: 'nextLevel',
         type: 'POST',
         data: {
        	 "level": level.toString(),
        	 "myPriority":PriorityString
        	
         },
     	success: function(data)
     	{
     		 PriorityArray = JSON.parse(data);
     		 
     		 if(level == 1)
     			 for(var i = 0; i < AllCompanies.length; ++i)
     				 {
     				 if(AllCompanies[i].location == "Westchester")
     					 tempArray.push(AllCompanies[i]);
     				 }
     			 else if(level == 2)
     				 for(var i = 0; i < AllCompanies.length; ++i)
     					 {
     					 if(AllCompanies[i].location == "New York")
     						 tempArray.push(AllCompanies[i]);
     					 }
     			 else
     					for(var i = 0; i < AllCompanies.length; ++i)
     						{
     						if(AllCompanies[i].location == "Outside New York")
     							tempArray.push(AllCompanies[i]);
     						}
     			
     			
     			 var allCompanyString = JSON.stringify(tempArray);
     			 PriorityString = JSON.stringify(PriorityArray);
     			 
     			 //the setMap servlet is called after the nextLevel servlet, and sets which places the new companies that are added to the game for this level will buy
     			 $.ajax({
     		         url: 'setMap',
     		         type: 'POST',
     		         data: {
     		        	 "AllCompanies": allCompanyString,
     		        	 "myPriorities":PriorityString
     		        	
     		         },
     		     	success: function(data)
     		     	{
     		        	 transactionArray = JSON.parse(data);
     		        	 mapUpdate(transactionArray);
     		     	}
     			 
     			 }
     		         );
        	 
     	},
     	
        failure: function(data) {
            alert('An error has occured');
            
        }
	 
	 }
         );
	 
	 
 });
 }
 
 //mapUpdate is called whenever there is a possibility that the ownership of a business location may have changed, and the function
 //ensures that all locations are updated to the right color and visibility. (this function is called after the player advances to the next level)
 //transactionArray is an array of transactions (such as buying and selling businesses) which have occured.
 
 function mapUpdate(transactionArray)
 {
	for(var priorityIndex = 0; priorityIndex < PriorityArray.length; ++priorityIndex)
		{
		for(var transactionIndex = 0; transactionIndex < transactionArray.length; ++transactionIndex)
			{
			if(transactionArray[transactionIndex].owner == PriorityArray[priorityIndex].owner)
				{
				PriorityArray[priorityIndex].cash += transactionArray[transactionIndex].cost;
				setInvisible(transactionArray[transactionIndex].city, transactionArray[transactionIndex].owner);
				
				}
			}
		
		
		
		}
	
	
	
	
 }
 
 //setInvisible is called to set a new owner for each location on the map that a company has purchased. It is called only when
 //the player advances to a new level and the other companies all purchase locations.
 
 //once the correct location is found, the owner is set to being the specified owner, the monthDate is set to 0, and the dots on the map are reloaded.
 function setInvisible(cityName, owner)
 {
	
	 
	 for(var i = 0; i < AllCompanies.length; ++i)
	 {
	 if(cityName == AllCompanies[i].name)
		 {
		 
		 AllCompanies[i].owner = owner;
		 AllCompanies[i].monthDate = 0;
		 break;
		 }
	 }
	
	 reloadDots();
	 
	 
 }
 
//moveTime is the function that advances the in-game timer. It uses a frame counter to keep track of how many frames have passed, and if  
 //UpdateClock is true and this is the 50th frame, then the clock advances by one.
 
 //This function also updates the time and cash box at the bottom of the screen to have the right values in it.
 function moveTime()
 {

	  if(years >= 15)
		{
		 gameTimeOutLoad();
		 return;
		}
	 
	 if(UpdateClock == true && frame_counter % 50 == 0)
	 {
	 frame_counter = 1; 
	 
	 if(day_num >= 30)
		 {
		 if(months >= 12)
			 {
			 ++years; months = 0; day_num = 0;
			 }
		 
		 else
		 {
		 ++months;
		 day_num = 0;
		 }
		 } 
		 else
			 {
			 ++day_num;
			 }
		 
		
		timeServFunct();
	
	 }
	 else if(UpdateClock == true)
		 ++frame_counter;
	
	 if(mapLocation == "Westchester")
	 {
		 document.getElementById("Timer1").innerHTML = "Years: " + years + " Months: " + months + " Days: " + day_num;
		 document.getElementById("PurchaseID1").innerHTML = ("Total Cash: $" + numToComma(PriorityArray[0].cash));
	 }
	 else if( mapLocation == "New York")
		 {
		 document.getElementById("Timer2").innerHTML = "Years: " + years + " Months: " + months + " Days: " + day_num;
		 document.getElementById("PurchaseID2").innerHTML = ("Total Cash: $" + numToComma(PriorityArray[0].cash));
		 
		 }
	 else
		 {
		 document.getElementById("Timer3").innerHTML = "Years: " + years + " Months: " + months + " Days: " + day_num;
		 document.getElementById("PurchaseID3").innerHTML = ("Total Cash: $" + numToComma(PriorityArray[0].cash)); 
		 }
	
	 
	
 }
 
 //this function determines if and when a particular decision will become available for the user.
 //most of the decisions will become available when a certain number of days have passed, and the player has either enough
 //cash to participate in the decision or a company which is a part of the decision is still in business
 function decisionTiming()
 {
	 
	 if(decisionsHappened[0] == false && level == 1 && totalDays() >= 25 && PriorityArray[0].cash > 10000)
		 openDecision(0);
		 
	 
	 else if(decisionsHappened[1] == false && level == 1 && totalDays() >= 60 && PriorityArray[0].cash > 15000) 
		 openDecision(1);
		
	 
	 else if(decisionsHappened[2] == false && level == 1 && totalDays() >= 120 && PriorityArray[0].cash > 10000)
		openDecision(2);
	 
	 else if(decisionsHappened[3] == false && level == 1 && totalDays() >= 190 && PriorityArray[0].cash > 25000)
		 openDecision(3);
	 
	 
	 else if(decisionsHappened[4] == false && level == 1 && totalDays() >= 250 && inBusiness("Panther Deals"))
		 openDecision(4);
	
	 
	 else if(decisionsHappened[5] == false && level == 1 && totalDays() >= 290 && PriorityArray[0].cash > 10000)
		openDecision(5);
	 
	 
	 else if(decisionsHappened[6] == false && level == 1 && totalDays() >= 340 && inBusiness("Jungle Cars"))
	 	openDecision(6);
	 
	 
	 else if(decisionsHappened[7] == false && level == 1 && totalDays() >= 390 && inBusiness("Ford") && PriorityArray[0].cash > 50000)
		 openDecision(7);
	
	 
	 else if (decisionsHappened[8] == false && level == 1 && totalDays() >= 450 && inBusiness("Westchester Discount Cars"))
		 openDecision(8);
	 
	 
	 else if(decisionsHappened[9] == false && level == 1 && totalDays() >= 500 && PriorityArray[0].cash > 30000)
		 openDecision(9);
	
	 else if(decisionsHappened[10] == false && level == 2 && totalDays() - level_1_timestamp >= 30 && inBusiness("Subaru"))
		 openDecision(10);
	 
	 else if(decisionsHappened[11] == false && level == 2 && totalDays() - level_1_timestamp >= 70)
		 openDecision(11);
	 
	 else if(decisionsHappened[12] == false && level == 2 && totalDays() - level_1_timestamp >= 110)
		 openDecision(12);
	 
	 else if(decisionsHappened[13] == false && level == 2 && totalDays() - level_1_timestamp >= 180 && inBusiness("BMW"))
		 openDecision(13);
	 
	 else if (decisionsHappened[14] == false && level == 2 && totalDays() - level_1_timestamp >= 240 && PriorityArray[0].cash > 50000)
		 openDecision(14);
	 
	 else if(decisionsHappened[15] == false && level == 2 && totalDays() - level_1_timestamp >= 300 && numFactories() >= 1)
		 openDecision(15);
	 
	 else if(decisionsHappened[16] == false && level == 2 && totalDays() - level_1_timestamp >= 360 && PriorityArray[0].cash > 100000)
		 openDecision(16);
	 
	 else if(decisionsHappened[17] == false && level == 2 && totalDays() - level_1_timestamp >= 425 && PriorityArray[0].cash > 25000)
		 openDecision(17);
	 
	 else if(decisionsHappened[18] == false && level == 2 && totalDays() - level_1_timestamp >= 475 && PriorityArray[0].cash > 130000)
		 openDecision(18);
	 
	 else if(decisionsHappened[19] == false && level == 2 && totalDays() - level_1_timestamp >= 525 && PriorityArray[0].cash > 60000)
		 openDecision(19);
	 
	 else if(decisionsHappened[20] == false && level == 3 && totalDays() - level_2_timestamp >= 35 && PriorityArray[0].cash > 30000 && inBusiness("Ram"))
		 openDecision(20);
	 
	 else if(decisionsHappened[21] == false && level == 3 && totalDays() - level_2_timestamp >= 75 && PriorityArray[0].cash > 70000)
		 openDecision(21);
	  
	 else if(decisionsHappened[22] == false && level == 3 && totalDays() - level_2_timestamp >= 150 && PriorityArray[0].cash > 200000)
		 openDecision(22);
	 
	 else if(decisionsHappened[23] == false && level == 3 && totalDays() - level_2_timestamp >= 220 && PriorityArray[0].cash > 400000 && inBusiness("Toyota"))
		 openDecision(23);
	 
	 else if(decisionsHappened[24] == false && level == 3 && totalDays() - level_2_timestamp >= 270 && PriorityArray[0].cash > 500000)
		 openDecision(24);
	 
	 else if(decisionsHappened[25] == false && level == 3 && totalDays() - level_2_timestamp >= 350 && PriorityArray[0].cash > 150000 && mapLocation == "Outside New York")
		 openDecision(25);
	 
	 else if(decisionsHappened[26] == false && level == 3 && totalDays() - level_2_timestamp >= 400 && PriorityArray[0].cash > 300000)
	 	openDecision(26);
	 	
	 else if(decisionsHappened[27] == false && level == 3 && totalDays() - level_2_timestamp >= 450 && PriorityArray[0].cash > 750000 && mapLocation == "Outside New York")
	 	openDecision(27);
	 
	 else if(decisionsHappened[28] == false && level == 3 && totalDays() - level_2_timestamp >= 500 && PriorityArray[0].cash > 300000)
		 openDecision(28);
	 
	 else if(decisionsHappened[29] == false && level == 3 && totalDays() - level_2_timestamp >= 550)
		 openDecision(29);
	 
	 
 }

 //openDecision is called to bring up a decision when the decisionTiming function determines that the time has come for particular decision to come up
 function openDecision(num)
 {
	 decisionsHappened[num] = true;
	 UpdateClock = false;
	 inDescription = true;
	 document.getElementById("Choice_" + (num + 1).toString()).style.display = "inline";
	 
 }
 
 //numFactories returns the number of factories owned by Universal Wheels
 function numFactories()
 {
	 var counter = 0;
	 
	 for(var i = 0; i < AllCompanies.size(); ++i)
		 {
		 if(AllCompanies[i].owner == "Universal Wheels" && AllCompanies[i].type == "Factory")
			 ++counter;
		 }
	 
	 return counter;
 }
 
 //timeServFunct calls the processTime servlet to update the profits and loses that each company has had occur on the one
 //month anniversary of when the company purchased the business. The timeServFunct then calls UpdateCompanies and reloadDots to update the map 
 //and company statuses, followed by checking to see if the user should advance to the next level. Lastly, the function checks if the user should be given a decision
 function timeServFunct()
 {
	 var transactionArray = [];
	 var PriorityString = JSON.stringify(PriorityArray);
	 var myArray = [];
	 if(level == 1)
		 {
		 for(var i = 0; i < AllCompanies.length; ++i)
			 {
			 if(AllCompanies[i].location == "Westchester")
				 myArray.push(AllCompanies[i]);
			 }
		 
		 }
	 else if(level == 2)
	 {
		 for(var i = 0; i < AllCompanies.length; ++i)
			 {
			 if(AllCompanies[i].location == "Westchester" || AllCompanies[i].location == "New York")
				 myArray.push(AllCompanies[i]);
			 }
		 
		 }
	 else
		 myArray = AllCompanies;
		 
	 var CompanyString = JSON.stringify(myArray);
	 $.ajax({
         url: 'processTime',
         type: 'POST',
         data: {
        	 "CompanyList": CompanyString,
        	 "PriorityArray":PriorityString,
        	 "day": day_num.toString()
         },
     	success: function(data)
     	{
        	 transactionArray = JSON.parse(data);
        	 updateCompanies(transactionArray);
        	 reloadDots();	 
        	 checkLevel();
        	 decisionTiming();
        	 
        	 
     	}
	 
	 }
         );
	 
	 
 }
 
 //the reloadDots function updates the visibility and color of the dots and squares on the current map screen
 function reloadDots()
 {	
	 if(mapLocation == "Westchester")
	{
		 for(var i = 0; i < AllCompanies.length; ++i)
		{
		if(AllCompanies[i].location == "Westchester")
			{
			var tempName = AllCompanies[i].name.replace(/ /g, "_");
			
			if(AllCompanies[i].type == "Store")
				tempName += "_Dot";
			else
				tempName += "_Square";
			
			
			if(AllCompanies[i].owner == "None" || AllCompanies[i].owner == "Universal Wheels")
			{
				document.getElementsByClassName(tempName)[0].style.display = "inline";
			}
			else
			document.getElementsByClassName(tempName)[0].style.display = "none";
			
			
			
			}
		
		
		
		}
	}
	 else if(mapLocation == "New York")
		{
			 for(var i = 0; i < AllCompanies.length; ++i)
			{
			if(AllCompanies[i].location == "New York")
				{
				var tempName = AllCompanies[i].name.replace(/ /g, "_");
				
				if(AllCompanies[i].type == "Store")
					tempName += "_Dot";
				else
					tempName += "_Square";
				
				
				if(AllCompanies[i].owner == "None" || AllCompanies[i].owner == "Universal Wheels")
				document.getElementsByClassName(tempName)[0].style.display = "inline";
				else
				document.getElementsByClassName(tempName)[0].style.display = "none";
				
				
				
				}
			
			
			
			}
		}
	 else 
		{
			 for(var i = 0; i < AllCompanies.length; ++i)
			{
			if(AllCompanies[i].location == "Outside New York")
				{
				var tempName = AllCompanies[i].name.replace(/ /g, "_");
				
				if(AllCompanies[i].type == "Store")
					tempName += "_Dot";
				else
					tempName += "_Square";
				
				
				if(AllCompanies[i].owner == "None" || AllCompanies[i].owner == "Universal Wheels")
				document.getElementsByClassName(tempName)[0].style.display = "inline";
				else
				document.getElementsByClassName(tempName)[0].style.display = "none";
				
				
				
				}
			
			
			
			}
		}
	 
 }
 
 //updateCompanies updates the priorityArray of companies and the ownership of companies in the AllCompanies array. If the user has gone 
 //bankrupt, then this function calls the gameover function
 function updateCompanies(transactionArray)
 {
	 
	 for(var i = 0; i < transactionArray.length; ++i)
		 {
		 if(transactionArray[i].type == "Profit")
			 {
			 for(var temp = 0; temp < PriorityArray.length; ++temp)
				 {
				 if(PriorityArray[temp].owner == transactionArray[i].owner)
					 {
					 PriorityArray[temp].cash += transactionArray[i].cost;
					
					 }
				 }
			 }
		 else if(transactionArray[i].type == "Sell")
			 {
			
			 
			 for(var temp = 0; temp < AllCompanies.length; ++temp)
				 {
				 
				 var tempName = AllCompanies[temp].name.replace(/ /g, "_");
				 if(AllCompanies[temp].name == transactionArray[i].city)
					 {
					if(AllCompanies[temp].owner == "Universal Wheels" && AllCompanies[temp].type == "Store")
						{
						document.getElementsByClassName(tempName + "_Dot")[0].style.backgroundColor = "red";
						}
					else if(AllCompanies[temp].owner == "Universal Wheels" && AllCompanies[temp].type == "Factory")
						{
						document.getElementsByClassName(tempName + "_Square")[0].style.backgroundColor = "purple";
						}
					 AllCompanies[temp].owner = "None";
					 AllCompanies[temp].monthDate = -1;
					 
					 }
				 }
			 for(var temp = 0; temp < PriorityArray.length; ++temp)
				 {
				 if(PriorityArray[temp].owner == transactionArray[i].owner)
					 {
					 PriorityArray[temp].cash += transactionArray[i].cost;
					 
					 }
				 }
			 
			 }
		 else if(transactionArray[i].type == "Purchase")
			 {
			 for(var temp = 0; temp < AllCompanies.length; ++temp)
				 {
				 
				 if(AllCompanies[temp].name == transactionArray[i].city)
					 {
					 AllCompanies[temp].owner = transactionArray[i].owner;
					 AllCompanies[temp].monthDate = day_num;
					 
					 }
				 }
			 for(var temp = 0; temp < PriorityArray.length; ++temp)
				 {
				 
				 if(PriorityArray[temp].owner == transactionArray[i].owner)
					 {
					 PriorityArray[temp].cash += transactionArray[i].cost;
					
					 }
				 
				 }
			 
			 }
		 else if(transactionArray[i].type == "BANKRUPT")
			 {
			 if(transactionArray[i].owner == "Universal Wheels")
			 {
				 bankruptGameOver();
			  	return;
			 }
			 
		 	for(var temp = 0; temp < PriorityArray.length; ++temp)
		 		{
		 		if(PriorityArray[temp].owner == transactionArray[i].owner)
		 			{
		 			PriorityArray.splice(temp, 1);
		 			
		 			}
		 		}
		 }
		 }
	 
	 
 }
 //bankruptGameOver is called when the player goes bankrupt, and loads the BankruptWindow.
 function bankruptGameOver()
 {
	 UpdateClock = false;
	 inDescription = true;
	 document.getElementsByClassName("BankruptWindow")[0].style.display = "inline";
	 
	 
 }
 
 //gameBankrupt is called to take the user from the BankruptWindow to the game over screen
 function gameBankrupt()
 {
	 document.getElementsByClassName("BankruptWindow")[0].style.display = "none";
	 gameOver();
 }
 //gameOver loads the GameOverWindow and ends the game if the player loses
function gameOver()
{
	if(mapLocation == "Westchester")
		 document.getElementsByClassName("WestchesterWindow")[0].style.display = "none";
		 else if(mapLocation == "New York")
		document.getElementsByClassName("NewYorkWindow")[0].style.display = "none";
		 else
		document.getElementsByClassName("FederalWindow")[0].style.display = "none";
	
	UpdateClock = false;
	document.getElementsByClassName("GameOverWindow")[0].style.display = "inline";
	resetGame();
	return;
}


//dataReturn returns a user from the table of information about each business location to the map screen
 function dataReturn()
 {
	 
	 if(inSearch == false)
	{
		 document.getElementsByClassName("databaseWindow")[0].style.display = "none";
		
		 
		 if(mapLocation == "Westchester")
		 document.getElementsByClassName("WestchesterWindow")[0].style.display = "inline";
		 else if(mapLocation == "New York")
		document.getElementsByClassName("NewYorkWindow")[0].style.display = "inline";
		 else
		document.getElementsByClassName("FederalWindow")[0].style.display = "inline";
		 
		 UpdateClock = true;
		 reloadDots();
	 }
 }
 
//openDescription opens up the description of each place that the user clicks on. 
 function openDescription(IDname, type, owner, monthlyTax, purchasePrice, returnPrice, location)
 {
	 
	 $(document).ready(function()
		 {
		 
		 var mainElement = document.getElementById(IDname);	 
	 
		if(inDescription == false)
			{
				inDescription = true;
				UpdateClock = false;
		
				mainElement.style.display = "inline";
		
				if(isOwned(IDname) == false)
				 {
			
					mainElement.getElementsByTagName("img")[0].src = "images/" + IDname + ".jpg";
					mainElement.getElementsByClassName("Company_Status")[0].innerHTML = "Price: $" + numToComma(purchasePrice) + " Monthly Tax: $" + numToComma(monthlyTax);
					mainElement.getElementsByClassName("transactionButton")[0].innerHTML = "Purchase";
					mainElement.getElementsByClassName("transactionButton")[0].onclick = function()
					{	
					buyItem(IDname, type, owner, purchasePrice, returnPrice, location);
					}
				 }
		
			else
				{
			mainElement.getElementsByTagName("img")[0].src = "images/" + IDname + "_Alt.jpg";
			mainElement.getElementsByClassName("Company_Status")[0].innerHTML = "You already own this. You can sell it for $" + numToComma(returnPrice);
			mainElement.getElementsByClassName("transactionButton")[0].innerHTML = "Sell";
			mainElement.getElementsByClassName("transactionButton")[0].onclick = function()
			{
				sellItem(IDname, returnPrice, type);
			}
			
				}
		 
				}
		
 		})
 }
 
 //numToComma converts a number to a string which is seperated by commas after every three digits.
 function numToComma(origNum)
 {
	 var returnString = origNum.toString();
	
	 if(returnString.length <= 3)
		 return returnString;
	 
	 var tempCounter = 1;
	 for(var current_position = returnString.length - 1; current_position >= 0; --current_position)
		 {
		 if(tempCounter % 3 == 0 && current_position != 0)
			 {
			 returnString = returnString.substring(0, current_position) + "," + returnString.substring(current_position);
			 }
		 ++tempCounter;
		 }
	 
	 return returnString;
 }
 
 //isOwned returns true if Universal Wheels opens a particular location (passed in as IDname) and false otherwise
 function isOwned(IDname)
 {
	
		IDname = IDname.replace(/_/g," ");
		for(var index = 0; index < AllCompanies.length; ++index)
		{
			if(AllCompanies[index].name == IDname)
					{
				if(AllCompanies[index].owner == "Universal Wheels")
					return true;
				else
					return false;
					}
		}
		return false;
		
	
	 
 }
 

 //cancel allows a user to return from a purchase decision, sell decision, location description, or decision outcome box back to the main
 //map screen, with time passing again
 function cancel(IDname)
 {
	 UpdateClock = true;
	 inDescription = false;
	 document.getElementById(IDname).style.display = "none";
 }
 
 
 //buyItem allows the user to purcahse a location if they have enough money (it changes the owner in AllCompanies to Unviersal Wheels
//and decreases the amount of cash Universal Wheels has in the PriorityArray) and updates the map accordingly. If the user can't afford the
//location, then a box informing them of their lack of money comes up.
 function buyItem(IDname, type, owner, purchasePrice, returnPrice, location)
 {
	 document.getElementById(IDname).style.display = "none";
	 
	
	 if(purchasePrice >= PriorityArray[0].cash)
	 {
		document.getElementById("Broke").style.display = "inline";
		
	 }
	 
	 else
	{
		PriorityArray[0].cash -= purchasePrice;
		document.getElementById("Success").style.display = "inline";
	
		if(type == "Store")
		document.getElementsByClassName(IDname + "_Dot")[0].style.backgroundColor = "gold";
		else
		document.getElementsByClassName(IDname + "_Square")[0].style.backgroundColor = "gold";
		
		var tempName = IDname.replace(/_/g, " ");
		for(var i = 0; i < AllCompanies.length; ++i)
			{
			if(AllCompanies[i].name == tempName)
				{
				AllCompanies[i].owner = owner;
				AllCompanies[i].monthDate = day_num;
				break;
				}
			
			
			
			}
	 }
	 
 }
 //sellItem allows a user to sell back a business location. The function changes the owner of the business location to none, adds the return
 //price of the location to Unviersal Wheel's cash, and updates the map accordingly
function sellItem(IDname, returnPrice, type)
	{
	document.getElementById(IDname).style.display = "none";
	var tempName = IDname.replace(/_/g, " ");
	for(var i = 0; i < AllCompanies.length; ++i)
		{
		if(tempName == AllCompanies[i].name)
			{
			AllCompanies[i].owner = "None";
			AllCompanies[i].monthDate = -1;
			}
		}
	
	PriorityArray[0].cash += parseInt(returnPrice);
	if(type == "Store")
	document.getElementsByClassName(IDname + "_Dot")[0].style.backgroundColor = "red";
	else
	document.getElementsByClassName(IDname + "_Square")[0].style.backgroundColor = "purple";
	
	
	document.getElementById("Sold").style.display = "inline";
		
	}
 
 
//databasePageLoad creates an array of all locations the user has access to at their current level, and then
//passes this array to the databaseLoad function to display the information about each location in the table
function databasePageLoad(ClassName)
{
	if(inDescription == true)
		return;
	UpdateClock = false;
	document.getElementsByClassName(ClassName)[0].style.display = "none";
	document.getElementsByClassName("databaseWindow")[0].style.display = "inline";
	var myArray = [];
	if(level == 1)
	{	for(var i = 0; i < AllCompanies.length; ++i)
			if(AllCompanies[i].location == 'Westchester')
				myArray.push(AllCompanies[i]);
	}
	else if(level == 2)
		{
		for(var i = 0; i < AllCompanies.length; ++i)
			if(AllCompanies[i].location == 'New York' || AllCompanies[i].location == 'Westchester')
				myArray.push(AllCompanies[i]);
		}
	else
		myArray = AllCompanies;
	
	databaseLoad(myArray);
}

//databaseLoad displays information about the businesses currently available to the user when they first click on the Business Information
//section from a map
function databaseLoad(myArray)
{
	var mainTable = document.getElementById("mainTableBody");
	mainTable.innerHTML = "";

	if(myArray == undefined || myArray == null || myArray.length == 0)
		{
		return;
		}
	
	
	
	
	for(var index = 0; index < myArray.length; ++index)
		{
		
		var row = mainTable.insertRow();
		var cell1 = row.insertCell(0);
		var cell2 = row.insertCell(1);
		var cell3 = row.insertCell(2);
		var cell4 = row.insertCell(3);		
		var cell5 = row.insertCell(4);
		var cell6 = row.insertCell(5);
		
		
		
		cell1.innerHTML = myArray[index].name;
		cell2.innerHTML = myArray[index].type;
		cell3.innerHTML = myArray[index].owner;
		cell4.innerHTML = "$" + numToComma(myArray[index].purchasePrice);
		cell5.innerHTML = myArray[index].location;
		if(myArray[index].monthDate == -1)
			cell6.innerHTML = "N/A";
		else
			
		cell6.innerHTML = myArray[index].monthDate;
		
		}
	
}

//openProperties determines which options the user can select to sort the locations in the business location list by at a given point in time.
//The criteria available is based off of the type of entries in the PriorityArray and AllCompaniesArray
	function openProperties()
	{
		var myArray = [];
		var resultString = "";
		
		
		
		if(level == 1)
			{
			
			document.getElementById("Location").innerHTML = "<option  value = 'All'>All</option><option  value = 'Westchester'>Westchester</option>"

			for(var i = 0; i < AllCompanies.length; ++i)
			
				if(AllCompanies[i].location == "Westchester")
					myArray.push(AllCompanies[i]);
			}
		
		
		else if(level == 2)
			{
			document.getElementById("Location").innerHTML = "<option  value = 'All'>All</option><option  value = 'Westchester'>Westchester</option><option  value = 'New York'>New York State</option>"

			for(var i = 0; i < AllCompanies.length; ++i)
				if(AllCompanies[i].location == "Westchester" || AllCompanies[i].location == "New York")
					myArray.push(AllCompanies[i]);
			}
			
		else
			{
			document.getElementById("Location").innerHTML = "<option  value = 'All'>All</option><option  value = 'Westchester'>Westchester</option><option  value = 'New York'>New York State</option><option  value = 'Outside New York'>Outside New York</option>";
			myArray = AllCompanies;
			}
		
		
		for(var i = 0; i < myArray.length; ++i)
		{
		resultString = resultString + "<option  value = '" + myArray[i].name + "'>" + myArray[i].name + "</option>";
		}
		
	document.getElementsByClassName('databaseSearchMenu')[0].style.display = "inline";
	document.getElementById("City").innerHTML = "<option  value = 'All'>All</option>" + resultString;
	
	resultString = "";
	for(var i = 0; i < PriorityArray.length; ++i)
		{
		resultString = resultString + "<option value = '" + PriorityArray[i].owner + "'>" + PriorityArray[i].owner + "</option>";
		}
	
	document.getElementById("Owner").innerHTML = "<option  value = 'All'>All</option>" + resultString;
	inSearch = true;
	
	}
	

	
//databaseOpenInitial is used to call the getScores servlet, which returns the high score information requested by the user (or the default high score
//list if the user doesn't request anything
	function databaseOpenInitial(type, sortCriteria, inOrder)
	{
		if(inOrder == true)
			inOrder = "true";
		else
			inOrder = "false";
		var dataArray = [];
		var myBody;
		if(type == "fastestTime")
			document.getElementById("dataHead").innerHTML = "<tr><th width = '5%'></th><th width = '20%'>Name</th><th width = '15%'>Completion Time</th><th width = '15%'>Date Set</th></tr>";
		else
				document.getElementById("dataHead").innerHTML = "<tr><th width = '5%'></th><th width = '20%'>Name</th><th width = '15%'>Final Amount of Cash</th><th width = '15%'>Date Set</th></tr>";
				
		myBody = document.getElementById("dataBody");
		
		$.ajax({
	         url: 'getScores',
	         type: 'POST',
	         data: {
	        	"Type" : type,
	        	"Criteria" : sortCriteria,
	        	"inOrder" : inOrder
	        	
	         },
	     	success: function(data)
	     	{
	     		myBody.innerHTML = "";
	        	 dataArray = JSON.parse(data);
	        	for(var i = 0; i < dataArray.length; ++i)
	        		{
	        		var row = myBody.insertRow();
	        		var cell1 = row.insertCell(0);
	        		cell1.style.width = "5%";
	        		var cell2 = row.insertCell(1);
	        		cell2.style.width = "20%";
	        		var cell3 = row.insertCell(2);
	        		cell3.style.width = "15%";
	        		var cell4 = row.insertCell(3);
	        		cell4.style.width = "15%";
	        	
	        		
	        		
	        		var myScore = parseInt(dataArray[i].statistic)
	        		
	        		cell1.innerHTML = i + 1;
	        		cell2.innerHTML = dataArray[i].username;
	        		
	        		if(inTime == true)
	        		cell3.innerHTML = Math.floor((myScore / 365)) + " Years " + Math.floor((myScore % 360/ 30)) 
	        		+ " Months " + Math.floor((myScore % 30)) + " Days";
	        		else
	        		cell3.innerHTML = "$" + numToComma(myScore);
	        		
	        		cell4.innerHTML = dataArray[i].dateSet;
	        		
	        		}
	        	 
	        	 
	     	}
		 
		 }
	         );
				
		
		
		
	}
	//decisionPost is called when a user selects a decision, and calls the DecisionServ servlet to determine what the outcome of the user's choice is
	//additionally, the function checks if the user selected decision 26 choice B or decision 28 choice A, since these had the Ankang China location and the
	//Rose Plaza locations to the map respectively
	function decisionPost(decisionNumber, decisionChoice)
	{
		
		document.getElementById("Choice_" + decisionNumber).style.display = "none";
		AllString = JSON.stringify(AllCompanies);
		PriorityString = JSON.stringify(PriorityArray)
		 $.ajax({
	            url: 'DecisionServ',
	            type: 'POST',
	            data: {
	                'decisionNumber': decisionNumber,
	                'decisionChoice': decisionChoice,
	            	'allCompanies':  AllString,
	            	'priorityArray': PriorityString
	            },
	            success: function(data) 
	            {
	            PriorityArray = [];
	            PriorityArray = JSON.parse(data);
	            if(decisionNumber == 26 && decisionChoice == 'B')
            		{
	            	AllCompanies.push(new dataEntry("Ankang China", "Factory", "Universal Wheels", 150000, 100000, "Outside New York", day_num));	
	            	document.getElementsByClassName("Ankang_China_Square")[0].style.display = "inline";
	            	document.getElementsByClassName("Ankang_China_Square")[0].style.backgroundColor = "gold";
            		}
	            else if(decisionNumber == 28 && decisionChoice == 'A')
	            	{
	            	AllCompanies.push(new dataEntry("Rose Plaza", "Store", "Universal Wheels", 750000, 500000, "Outside New York", day_num));
	            	document.getElementsByClassName("Rose_Plaza_Dot")[0].style.display = "inline";
	            	document.getElementsByClassName("Rose_Plaza_Dot")[0].style.backgroundColor = "gold";
	            	}
	           
	            if(PriorityArray[0].status == true)
	            	{
	            	document.getElementById("Choice_" + decisionNumber + decisionChoice + "_Success").style.display = "inline";	
	            	}
	            else
	            	{
	            	document.getElementById("Choice_" + decisionNumber + decisionChoice + "_Failure").style.display = "inline";
	            	}
	            
	            
	            
	            
	            	
	            },
	            failure: function(data) {
	                alert('An error has occured');
	                
	            }
	        });	
		
		
		
	}
	
	//mainData is called to load the high scores page from the main menu when the user selects the high scores option
	function mainData()
	{
		document.getElementsByClassName("mainWindow")[0].style.display = "none";
		document.getElementsByClassName("HighScoresWindow")[0].style.display = "inline";
		var x = document.getElementsByClassName("HighScoresWindow")[0];
		x.getElementsByClassName("rectangleButton")[1].innerHTML = "Money High Scores";
		x.getElementsByTagName("h3")[0].innerHTML = "Time High Scores:";
		document.getElementById("dataHead").innerHTML = "";
		document.getElementById("dataBody").innerHTML = "";
		databaseOpenInitial("fastestTime", "completionTime", true);
		inTime = true;
	}
	
	//loadNy opens the New York map and closes the Westchester map
	function loadNY()
	{
		if(inDescription == true)
			return;
		
		document.getElementsByClassName("WestchesterWindow")[0].style.display = "none";
		document.getElementsByClassName("NewYorkWindow")[0].style.display = "inline";
		mapLocation = "New York";
		reloadDots();
		
	}

	//enterWestchester closes the New York map and opens the Westchester map
	function enterWestchester()
	{
		if(inDescription == true)
			return;
		
		document.getElementsByClassName("NewYorkWindow")[0].style.display = "none";
		document.getElementsByClassName("WestchesterWindow")[0].style.display = "inline";
		mapLocation = "Westchester";
		reloadDots();
		
	}
	
	//openPriority is called when the user clicks on the Company Statistics tab in the databseWindow.
	//openPriority closes the databaseWindow and opens up the PriorityWindow. It also displays a table of information
	//about the current statistics of each company
	
	function openPriority()
	{
		if(inSearch == true)
			return;
		document.getElementsByClassName("databaseWindow")[0].style.display = "none";
		document.getElementsByClassName("PriorityWindow")[0].style.display = "inline";
		
		document.getElementById("PriorityTable").innerHTML = "";
		var mainTable = document.getElementById("PriorityTable")
		for(var index = 0; index < PriorityArray.length; ++index)
		{
		
		var row = mainTable.insertRow();
		var cell1 = row.insertCell(0);
		var cell2 = row.insertCell(1);
		var cell3 = row.insertCell(2);
		var cell4 = row.insertCell(3);	
		var cell5 = row.insertCell(4);
		
		
		
		cell1.innerHTML = PriorityArray[index].owner;
		cell2.innerHTML = "$" + numToComma(PriorityArray[index].cash);
		cell3.innerHTML = numStores(PriorityArray[index].owner);
		cell4.innerHTML = numFactories(PriorityArray[index].owner);
		cell5.innerHTML = "$" + numToComma(totalValue(PriorityArray[index].owner));
	
		}
		
	}
	//inBusiness returns true if the owner specified by its parameter has not gone bankrupt yet, and false otherwise
	function inBusiness(owner)
	{
		for(var i = 0; i < PriorityArray.length; ++i)
			if(PriorityArray[i].owner == owner)
				return true;
		return false;
			
	}
	//numStores returns the number of stores owned by owner
	function numStores(owner)
	{
		var answer = 0;
		for(var i = 0; i < AllCompanies.length; ++i)
		{
			if(AllCompanies[i].owner == owner && AllCompanies[i].type == "Store")
				++answer;
		}
		return answer;
	}
	
	//numFactories returns the number of factories owned by owner
	function numFactories(owner)
	{
		var answer = 0;
		for(var i = 0; i < AllCompanies.length; ++i)
			{
			if(AllCompanies[i].owner == owner && AllCompanies[i].type == "Factory")
				++answer;
			}
		return answer;
	}
	
	//totalValue returns the total cost of all the businesses owned by owner (in terms of purchase price)
	function totalValue(owner)
	{
		var answer = 0;
		
		for(var i = 0; i < AllCompanies.length; ++i)
			{
			if(AllCompanies[i].owner == owner)
				answer += AllCompanies[i].purchasePrice;
			}
		return answer;
	}
	
	//showRules loads the rules section of the game when the user selects the rules option on the main menu
	function showRules()
	{
		document.getElementsByClassName("mainWindow")[0].style.display = "none";
		document.getElementsByClassName("RulesWindow")[0].style.display = "inline";
		
	}
	
	//ReturnHome closes the rules window and opens the main menu window back up
	function ReturnHome() 
	{ 
		document.getElementsByClassName('RulesWindow')[0].style.display = 'none'; 
		document.getElementsByClassName('mainWindow')[0].style.display = 'inline';
	}
	
	//checkLevel determines whether or not the user shoudl be able to advance to the next level. nextlevel() is called if the user
	//meets the criteria to advance to the next level.
	function checkLevel()
	{
		var myCompanyCounter = 0;
		var allCompanyCounter = 0;
		 
		if(level == 1)
		{
			for(var i = 0; i < AllCompanies.length; ++i)
			{
			if(AllCompanies[i].location == "Westchester")
				{
				allCompanyCounter += AllCompanies[i].purchasePrice;
				if(AllCompanies[i].owner == "Universal Wheels")
				myCompanyCounter += AllCompanies[i].purchasePrice;
				
				}	
			}
			
			//if the company owns all businesses in Wetshcetser or owns 60 % or more of all businsses (in terms of purchase price) after a year
			//or more of in-game time has passed, then the player can advance to the next level (the New York level)
			if(allCompanyCounter - myCompanyCounter == 0 || (((myCompanyCounter * 1.0)/allCompanyCounter >= 0.60)))
				{
				nextLevel();
				level_1_timestamp = (years * 365) + (months * 30) + day_num;
				var x = document.getElementsByClassName("WestchesterWindow")[0];
				x.getElementsByClassName("mapButton")[0].style.display = "inline";
				document.getElementsByClassName("WestchesterWindow")[0].style.display = "none";
				document.getElementsByClassName("NewYorkWindow")[0].style.display = "inline";
				mapLocation = "New York";
				reloadDots();
				inDescription = true;
				UpdateClock = false;
				document.getElementsByClassName("Level1Won")[0].style.display = "inline";
				return;
				
				}
			
		}
		
		else if(level == 2 && mapLocation == "New York")
			{
			for(var i = 0; i < AllCompanies.length; ++i)
			
				{
				if(AllCompanies[i].location == "New York")
					{
					allCompanyCounter += AllCompanies[i].purchasePrice;
					if(AllCompanies[i].owner == "Universal Wheels")
						myCompanyCounter += AllCompanies[i].purchasePrice;
					}
				
				}
		if(allCompanyCounter - myCompanyCounter == 0 || (((myCompanyCounter * 1.0)/allCompanyCounter >= 0.65)))
			{
			nextLevel();
			level_2_timestamp = (years * 365) + (months * 30) + day_num;
			var x = document.getElementsByClassName("NewYorkWindow")[0];
			x.getElementsByClassName("mapButton")[0].style.display = "inline";
			document.getElementsByClassName("NewYorkWindow")[0].style.display = "none";
			document.getElementsByClassName("FederalWindow")[0].style.display = "inline";
			mapLocation = "Outside New York";
			reloadDots();
			inDescription = true;
			UpdateClock = false;
			document.getElementsByClassName("Level2Won")[0].style.display = "inline";
			return;
			
			}
			}
		else if(level == 3 && mapLocation == "Outside New York")
			{
			for(var i = 0; i < AllCompanies.length; ++i)
				
			{
			if(AllCompanies[i].location == "Outside New York")
				{
				allCompanyCounter += AllCompanies[i].purchasePrice;
				if(AllCompanies[i].owner == "Universal Wheels")
					myCompanyCounter += AllCompanies[i].purchasePrice;
				}
			
			}
	if(allCompanyCounter - myCompanyCounter == 0 || (((myCompanyCounter * 1.0)/allCompanyCounter >= 0.65)))
		{
		UpdateClock = false;
		document.getElementsByClassName("FederalWindow")[0].style.display = "none";
		document.getElementsByClassName("highScoreLoadPage")[0].style.display = "inline";
		return;
		
		}
			
			
			
			
			}
		
	}
	
	//cancelClass is used to close a window which is specified by a class (as opposed to an ID)
	function cancelClass(className)
	{
		 UpdateClock = true;
		 inDescription = false;
		 document.getElementsByClassName(className)[0].style.display = "none";
		
	}
	//gameTimeOutLoad opens up the timeOutWindow when the user runs out of time and has gotten gameover.
	function gameTimeOutLoad()
	{
		UpdateClock = false;
		inDescription = true;
		document.getElementsByClassName("timeOutWindow")[0].style.display = "inline";
	}
	
	//gameTimwOut closes the timeOutWindow and calls the gameOver function
	function gameTimeOut()
	{
		document.getElementsByClassName("timeOutWindow")[0].style.display = "none";
		gameOver();
		
	}
	//otherEnterNY closes the federalWindow and opens the NewYorkWindow
	function otherEnterNY()
	{
		if(inDescription == true)
			return;
		
		document.getElementsByClassName("FederalWindow")[0].style.display = "none";
		document.getElementsByClassName("NewYorkWindow")[0].style.display = "inline";
		mapLocation = "New York";
		reloadDots();

	}
	
	//enterFederal closes the New York window and opens the Federal Window
	function enterFederal()
	{
	if(inDescription == true)
		return;
		
	document.getElementsByClassName("NewYorkWindow")[0].style.display = "none";
	document.getElementsByClassName("FederalWindow")[0].style.display = "inline";
	mapLocation = "Outside New York";
	reloadDots();
		
	}
//priorityMap returns a user from the map of company statistics to the map they were in when they opened up the company and location statistics
	function priorityMap()
	{
	inSearch = false;
	inDescription = false;
	UpdateClock = true;
	document.getElementsByClassName("PriorityWindow")[0].style.display = "none";
	if(mapLocation == "Westchester")
	document.getElementsByClassName("WestchesterWindow")[0].style.display = "inline";
	else if(mapLocation == "New York")
	document.getElementsByClassName("NewYorkWindow")[0].style.display = "inline";
	else
	document.getElementsByClassName("FederalWindow")[0].style.display = "inline";
	reloadDots();
		
	}

//priorityReturn closes the PriorityWindow and opens the databaseWindow
	function priorityReturn()
	{
	document.getElementsByClassName("PriorityWindow")[0].style.display = "none";
	document.getElementsByClassName("databaseWindow")[0].style.display = "inline";
		
	}
	
	//sort scores proccesses sort information for the high scores list requested by the user. Once the parameters for the 
	//sort are determined, sortScores calls databaseOpenInitial to actually load the scores from the database and to update the page
	function sortScores()
	{
		var InorderSort;
		  var sortCriteria = $('#databaseSort').val();
	      if (sortCriteria == undefined || sortCriteria == null)
	      	{
	    	  if(inTime == true)
	    		  sortCriteria = "completionTime";
	    	  else
	    		  sortCriteria = "money";
	      	}
	      
	      if(document.getElementById("First-To-Last").checked == true)
	      	 InorderSort = true;
	      else
	      	InorderSort = false;

		var type;
		
		if(inTime == true)
			type = "fastestTime";
		else
			type = "mostMoney";
		
		document.getElementsByClassName("sortWindow")[0].style.display = "none";
		inSearch = false;
		databaseOpenInitial(type, sortCriteria, InorderSort);
	}

	//homeReturn returns the user to the main menu from the high scores window
	function homeReturn()
	{
	if(inSearch == true)
		{
		inSearch = false;
		document.getElementsByClassName("sortWindow")[0].style.display = "none";
		}
		document.getElementsByClassName("HighScoresWindow")[0].style.display = "none";
		document.getElementsByClassName("mainWindow")[0].style.display = "inline";
		inTime = true;
		
	}
	//decisionGameOver loads the GameOver function when game over occurs as a result of decision 27
	function decisionGameOver()
	{
		document.getElementById("Choice_27B_Failure").style.display = "none";
		gameOver();
	}
	//gameOverReturn returns the user from the GameOverWindow to the mainWindow
	function gameOverReturn()
	{
		document.getElementsByClassName("GameOverWindow")[0].style.display = "none";
		document.getElementsByClassName("mainWindow")[0].style.display = "inline";
	}
	//swapTable switches the HighScoreWindow from displaying information about money high scores to informaiton
	//about time high scores or vice versa
	function swapTable()
	{
		
		if(inSearch == true)
			{
			inSearch = false;
			document.getElementsByClassName("sortWindow")[0].style.display = "none";
			
			}
		var x;
		
		if(inTime == true)
			{
			x = document.getElementsByClassName("HighScoresWindow")[0];
			x.getElementsByClassName("rectangleButton")[1].innerHTML = "Time High Scores";
			x.getElementsByTagName("h3")[0].innerHTML = "Money High Scores:";
			document.getElementById("dataHead").innerHTML = "";
			document.getElementById("dataBody").innerHTML = "";
			databaseOpenInitial("mostMoney", "money", true);
			}
		else
			{
			x = document.getElementsByClassName("HighScoresWindow")[0];
			x.getElementsByClassName("rectangleButton")[1].innerHTML = "Money High Scores";
			x.getElementsByTagName("h3")[0].innerHTML = "Time High Scores:";
			document.getElementById("dataHead").innerHTML = "";
			document.getElementById("dataBody").innerHTML = "";
			databaseOpenInitial("fastestTime", "completionTime", true);
			
			
			
			}
		
		inTime = !inTime;
		
		}
		
	//sortLoad opens up the sort window for the high scores with the appropriate sort criterian depending on whether the user is
	//looking at the time high scores or the money high scores (using the inTime variable to determine this, which is true if the player is in the time high scores)
	function sortLoad()
	{
		if(inSearch == false)
		{
			inSearch = true;
		
		document.getElementsByClassName("sortWindow")[0].style.display = "inline";
		if(inTime == true)
			document.getElementById("databaseSort").innerHTML = "<option value = 'completionTime'>Completion Time</option><option value = 'username'>Name</option><option value = 'dateSet'>Date</option>";
		else
			document.getElementById("databaseSort").innerHTML = "<option value = 'money'>Amount of Money</option><option value = 'userName'>Name</option><option value = 'dateSet'>Date</option>";	
		}
		else
			{
			inSearch = false;
			document.getElementsByClassName("sortWindow")[0].style.display = "none";
			}
			
	}
	
	//databaseVerify verifies that the user entered in a valid username and password. It then calls the setScore servlet, which either adds the score
	//to the database or returns with an ExitCode of 2 if the user provided an incorrect password for the username. If the score was succesfully added to
	//the database, then the congratulations page is closed and the high scores window is opened.
	
	function databaseVerify()
	{
		var letters = /[a-zA-Z ]+/;
		var userName = $("#userName").val();
		var password = $("#password").val();
		
		if(userName.length < 3)
			{
			document.getElementById("feedback").innerHTML = "Username must be at least 3 characters long.";
			return;
			}
		if(userName.length > 30)
			{
			document.getElementById("feedback").innerHTML = "Username cannot be more than 30 characters long.";
			return;
			}
		for(var i = 0; i < userName.length; ++i)
			{
			if(userName[i] == ' ')
				{
				document.getElementById("feedback").innerHTML = "Username may not contain spaces in it.";
				return;
				}
			if(userName[i] == '\'')
			{
				document.getElementById("feedback").innerHTML = "Username may not contain the character " + userName[i];
				return;
			}
			if(userName[i] == '\"')
				{
				document.getElementById("feedback").innerHTML = "Username may not contain the character " + userName[i];
				return;
				}
			if(userName[i] == '\\')
				{
				document.getElementById("feedback").innerHTML = "Username may not contain the character " + userName[i];
				return;
				}
			}
		
		if(letters.test(userName) == false)
			{
			document.getElementById("feedback").innerHTML = "Username must have at least one alphabetical letter in it.";
			return;
			}
		var letters = /^[a-zA-Z0-9\-_\./=\+~ ]+$/;
		if(letters.test(userName) == false)
			{
			document.getElementById("feedback").innerHTML = "Invalid characters found in username. Please try again.";
			return;
			}
		if(password.length < 6)
			{
			document.getElementById("feedback").innerHTML = "Password must be at least 6 characters long.";
			return;
			}
		
		if(password.length > 50)
			{
			document.getElementById("feedback").innerHTML = "Password cannot be more than 50 characters long.";
			return;
			}
		if(letters.test(password) == false)
			{
			document.getElementById("feedback").innerHTML = "Invalid characters found in password please try again";
			return;
			}
		
			
		 $.ajax({
	         url: 'setScore',
	         type: 'POST',
	         data: {
	             'userName' : userName,
	         	 'password' : password,
	         	 'cash' : PriorityArray[0].cash.toString(),
	         	 'time' : ((365 * years ) + (30 * months) + day_num).toString()
	         },
	         success: function(data) {
	         	var exitCode = Number(data);
	         	if(exitCode == 2)
	         		{
	         		document.getElementById("feedback").innerHTML = "This username was previously used with a different password. If you're the one who made this username, then please try entering in your password again. Otherwise, select a different username.";
	         		return;
	         		}
	         	document.getElementsByClassName("highScoreLoadPage")[0].style.display = "none";
	        	 document.getElementsByClassName("HighScoresWindow")[0].style.display = "inline";
	        	 databaseOpenInitial("fastestTime", "completionTime", true);
	        	 resetGame();
	        	 
	         },
	         failure: function(data) {
	             alert('An error occured');
	       
	         }
	     });
		 
		
		 return;
		
	}
	
	//flip_on_mouseover flips a given city's dot or square to being the right color (based on whether it is a store or factory) when the user hover's over its dot/square
	//with the mouse. Stores are colored green on mouseover, while factories are colored black on mouseover.
	function flip_on_mouseover(IDname, isStore)
	{
		if(isStore == true)
		 document.getElementsByClassName(IDname)[0].style.backgroundColor =  "green";
		else
			document.getElementsByClassName(IDname)[0].style.backgroundColor = "black";
		 
	}

	//cancelData closes the business location search window.
	function cancelData()
	{
		document.getElementsByClassName('databaseSearchMenu')[0].style.display = "none";
		inSearch = false;
		
		}
	
	//flip_on_mouseout flips a given city's dot or square to being the right color, based on whether it is owned by Universal Wheels,
	//owned by nobody, or a store or factory. The function performs this action when the user moves the mouse outside of a dot or square.
	//places owned by Universal Wheels are flipped to gold on mouseout. Stores not owned by Universal Wheels are flipped to red on mouseout,
	//while factories not owned by Universal Wheels are flipped to purple on mouseout (locations owned by other companies are not displayed on the map).
	function flip_on_mouseout(IDname, isStore)
	{
		 if(isOwned(IDname) == true)
		{
			if(isStore == true)	
			document.getElementsByClassName(IDname + "_Dot")[0].style.backgroundColor = "gold"; 
			else
			document.getElementsByClassName(IDname + "_Square")[0].style.backgroundColor = "gold";
		}
		 else
			 {
			 if(isStore == true)
			 document.getElementsByClassName(IDname + "_Dot")[0].style.backgroundColor = "red";
			 else
			document.getElementsByClassName(IDname + "_Square")[0].style.backgroundColor = "purple";
			 }
	}
	//this function is called so the user can play again once they finish the game or get gameover
	function resetGame()
	{
		
		clearTimeout(TimerVar);
		months = 0; years = 0; day_num = 1;
		PriorityArray = [];
		PriorityArray.push(new priorityVal("Universal Wheels", 5, 10000, true, 150000));
		while(AllCompanies[AllCompanies.length - 1].name == "Ankang China" || AllCompanies[AllCompanies.length - 1].name == "Rose Plaza")
			AllCompanies.pop();
		
		for(var i = 0; i < AllCompanies.length; ++i)
			{
			AllCompanies[i].owner = "None";
			AllCompanies[i].monthDate = -1;
			
			}
		
		level = 0;
		mapLocation = "Westchester";
		decisionsHappened = [];
	
		
	}
</script>

 
<style>
h3{text-align: center; font-size: 1.404vw;}

.mainWindow{position: absolute; margin-left: 13%; width: 75vw; height: 50vw; 
background-color: LightYellow; border: 0.61vw solid blue;}
.HighScoresWindow{position: absolute; display: none; margin-left: 13%; width: 75vw; height: 50vw; background-color: lightYellow; overflow-y: scroll; border: 0.61vw solid blue;}
.FederalWindow{position: absolute; display: none; margin-left: 13%; width: 75vw; height: 50vw; 
background-color: black; border: 0.61vw solid blue;}
.WestchesterWindow{position: absolute; display: none; margin-left: 13%; width: 75vw; height: 50vw; background-color: black; border: 0.61vw solid blue;}
.NewYorkWindow{position: absolute; display: none; margin-left: 13%; width: 75vw; height: 50vw; background-color: black; border: 0.61vw solid blue;}
.GameOverWindow{position: absolute; display: none; margin-left: 13%; width: 75vw; height: 50vw; background-color: lightYellow; border: 0.61vw solid blue;}

.titleText{color: Crimson; text-align: center; font-size: 2.63vw; font-family: "Heveltica";}
.authorText{color: black; text-align: center; font-size: 1.2vw; font-family: "Heveltica";}
.mainTitleText{background-color: red; color: white; text-align: center; 
font-size: 1.2vw; font-family: Heveltica; margin-left: 25%; margin-right: 25%;}
.mainMenuLinks{border-radius: 1.52vw; height: 2.42vw; background-color: blue; color: white; 
text-align: center; font-size: 1vw; font-family: Arial; margin-left: 25%; margin-right: 25%;}
.databaseButton{border-radius: 1.52vw; font-size: 1.4vw; padding-left: 1.5vw; padding-top: 0.6vw; cursor: pointer; position: absolute; top: 0.5vw; right: 0.3vw; width: 12vw; height: 2vw; color: white; background-color: red; }
.databaseButton:hover{background-color: orange;}
.databaseWindow{display: none; position: absolute; margin-left: 13%; width: 75vw; height: 50vw; overflow-y: scroll; background-color: lightYellow; border: 0.61vw solid blue;}
.PriorityWindow{display: none; position: absolute; margin-left: 13%; width: 75vw; height: 50vw; overflow-y: scroll; background-color: lightYellow; border: 0.61vw solid blue;}
.databaseTable{margin-left: 1vw; margin-top: 8vw; width: 73vw; position: relative; height: 48vw; overflow-y: scroll; background-color: white;}
.RulesWindow{position: absolute; display: none; margin-left: 13%; width: 75vw; height: 50vw; background-color: LightYellow; border: 0.61vw solid blue;}
.blue{position:absolute; background-color: LightSkyBlue; width: 70vw; height: 40vw; margin-left: 1vw; margin-top: 5vw; color: Maroon; padding-left: 1vw; padding-right: 1vw;}
.mainMenuLinks:hover{background-color: red;}
.rectangleButton{z-index: 1; padding-left: 2vw; padding-right: 2vw; padding-top: 1vw; display: inline-block; background-color: red; height: 2.5vw; font-size: 1.5vw; text-align: center; color: white; margin-top: 0vw; cursor: pointer;}
.banner{display: inline-block; background-color: red; z-index: 0; width: 75vw; position: absolute; height: 3.5vw;}
.rectangleButton:hover{background-color: orange;}
.dot{z-index: 0; width: 0.61vw; height: 0.61vw; border-radius: 0.61vw; background-color: red; position: absolute; cursor: pointer;}
.databaseSearchMenu{z-index: 1; padding-left: 5vw; padding-right: 0.5vw; position: absolute; overflow-y: scroll; display: none; width: 65vw; height: 20vw; top: 20vw; left: 2.3vw; background-color: LightSkyBlue;}
.sortWindow{z-index: 1; padding-left: 0.4vw; padding-right: 0.5vw; position: absolute; overflow-y: scroll; display: none; width: 15vw; height: 15vw; top: 3.5vw; right: 0vw; background-color: LightSkyBlue;}
.highScoreLoadPage{position: absolute; display: none; margin-left: 13%; width:75vw; height: 50vw; overflow-y: scroll; background-color: lightYellow; border:0.61vw solid blue;}
.square{z-index: 0; width: 0.61vw; height: 0.61vw; background-color: purple; position: absolute; cursor: pointer;}
.timeBox{color: red; font-family: Heveltica; font-size: 1.4vw;}

.statBox{text-align: center; padding-left: 0.49vw; width: 25vw; height: 4.24vw;  position: absolute; bottom: 0vw; right: 0vw; background-color: white;
 border: 0.182vw solid black; z-index: 2;}


.NewYorkDot{top: 21vw; right: 7.5vw;}
.specialDot{z-index: 0; width: 0.80vw; height: 0.80vw; border-radius: 0.80vw; background-color: black; position: absolute; cursor: pointer;}
.specialDot:hover{background-color: SaddleBrown;}
.WestchesterDot{top: 43vw; right: 18vw;}
#Broke{display: none; z-index: 1; padding-left: 0.61vw; padding-right: 0.61vw;  text-align: center;
display: none; background-color: blue; width: 25vw; color: white; height: 6vw; position: absolute; top: 30vw; right: 35vw; padding-top: 1vw; font-size: 1.2vw;}
#Success{z-index: 1; padding-left: 0.61vw; padding-right: 0.61vw; display: none; text-align: center; 
background-color: blue; width: 25vw; color: white; height: 6vw; position: absolute; top: 30vw; right: 35vw; padding-top: 1vw; font-size: 1.2vw;}
#Sold{z-index: 1; padding-left: 0.61vw; padding-right: 0.61vw; display: none; text-align: center; font-size: 1.2vw;
background-color: blue; width: 25vw; color: white; height: 6vw; position: absolute; top:30vw; right: 35vw; padding-top: 1vw;}
.purchaseClass{color: red; font-family: Heveltica; font-size: 1.4vw;}
.Level1Won{background-color: blue; width: 35vw; padding-left: 2vw; padding-right: 2vw; color: white; height: 15vw; display: none; position: absolute; top: 22vw; right: 28vw; padding-top: 1vw; font-size: 1.2vw; z-index: 4;}
.Level2Won{background-color: blue; width: 35vw; padding-left: 2vw; padding-right: 2vw; color: white; height: 15vw; display: none; position: absolute; top: 22vw; right: 28vw; padding-top: 1vw; font-size: 1.2vw; z-index: 4;}
.timeOutWindow{background-color: blue; width: 35vw; padding-left: 2vw; padding-right: 2vw; color: white; height: 15vw; display: none; position: absolute; top: 22vw; right: 28vw; padding-top: 1vw; font-size: 1.2vw; z-index: 4;}
.BankruptWindow{background-color: blue; width: 35vw; padding-left: 2vw; padding-right: 2vw; color: white; height: 15vw; display: none; position: absolute; top: 22vw; right: 28vw; padding-top: 1vw; font-size: 1.2vw; z-index: 4;}
.Los_Angeles_Dot{top: 31.3vw; right: 59.8vw;}
.Dallas_Dot{bottom: 11vw; left: 43.5vw;}
.Detroit_Square{top: 23.6vw; right: 16.6vw;}
.Mohegan_Lake_Square{top: 7vw; right: 50vw;}
.Elmsford_Square{bottom: 20vw; left: 25vw;}
.St_Louis_Dot{bottom: 19.8vw; right: 24vw;}
.Denver_Dot{top: 27vw; right: 41vw;}
.Ossining_Square{bottom: 30vw; left: 21.5vw;}
.tooltiptext{z-index: 1; padding-left: 0.5vw; padding-right: 0.5vw; padding-bottom: 0.5vw; display: none; 
background-color: blue; width: 30vw; color: white; height: 39.5vw; position: absolute; top: 5vw; right: 23vw; overflow-y: scroll; overflow-x: scroll; font-size: 1.2vw;}
.decisiontext{z-index: 2; padding-left: 2vw; padding-right: 2vw; padding-bottom: 0.5vw; display: none; background-color: black; width: 40vw; 
height: 25vw; color: white; position: absolute; top: 20vw; right: 30vw; padding-top: 1vw; overflow-x: scroll; overflow-y: scroll; font-size: 1.2vw;}
.mapButton{float: left; color: red; padding-top: 0.5vw; font-size: 1.5vw; padding-bottom: 0.5vw; padding-left: 2vw; padding-right: 2vw; color: white; background-color: red; top: 0.5vw; left: 0.5vw; cursor: pointer; position: absolute; display: none;}
.mapButton:hover{background-color: orange;}
.Manhattan_Dot{top: 46.5vw; right: 19.5vw;}
.Glia_Bend_Square{bottom: 14vw; left: 23vw;}
.Seattle_Square{left: 17.8vw; top: 12.7vw;}
.El_Paso_Square{bottom: 10.3vw; left: 30.8vw;}
.Macon_Dot{bottom: 11.8vw; right: 15vw;}
.Twin_Falls_Square{top: 21.3vw; left: 22.9vw;}
.Yonkers_Dot{bottom: 6.5vw; left: 15vw;}
.Sacramento_Dot{bottom: 23vw; left: 15vw;}

.Rose_Plaza_Dot{right: 8.8vw; top: 27.5vw;}
.Nashville_Square{bottom: 18.6vw; right: 19.8vw;}
.Ardsley_Dot{bottom: 15vw; left: 23vw;}
.Company_Status{color: white;}
.Chicago_Dot{top: 24.2vw; right: 21.7vw;}
.New_Rochelle_Dot{bottom:6vw; left: 28.5vw;}
.Mt_Kisco_Dot{top: 16vw; left: 37vw;}
.Portchester_Dot{bottom: 14.7vw; left: 45.5vw;}
.Philadelphia_Dot{top: 25.2vw; right: 7.1vw;}
.Valhalla_Dot{bottom: 21.5vw; left: 30vw;}
.Bedford_Square{bottom: 34vw; left: 52vw;}
.North_Salem_Dot{bottom: 45vw; right: 16vw;}
.Yorktown_Dot{bottom: 45vw; left: 25vw;}
.Scarsdale_Dot{bottom: 10vw; left: 30vw;}
.Fargo_Square{top:17.8vw; right: 32.1vw;}
.Las_Vegas_Square{top: 31vw; right: 53.6vw;}
.Somers_Square{bottom: 44vw; left: 43vw;}
.Boston_Dot{top: 21.2vw; right: 3.5vw;}
.New_Orleans_Dot{bottom: 6.6vw; right: 22.7vw;}
.Armonk_Square{bottom: 24.5vw; left: 39vw;}
.Mamaroneck_Dot{bottom: 7vw; right: 40vw;}
.Topeka_Dot{top: 29vw; right: 30vw;}
.Miami_Dot{bottom: 2.2vw; right: 9.8vw;}
.Mount_Vernon_Dot{bottom: 5vw; left: 24vw;}
.White_Plains_Dot{bottom: 15.4vw; left: 34vw;}
.Tuckahoe_Dot{bottom: 10vw; left: 23vw;}
.Peekskill_Square{bottom: 41vw; left: 11.5vw;}
.Ankang_China_Square{left: 5vw; top: 20vw;}
.transactionButton{ bottom: 5vw; border-radius: 1.52vw; width: 11.25vw;  padding-top: 0.7vw; color: white;
height: 2.5vw; font-size: 1.52vw; background-color: red; margin-right: 1.82vw; text-align: center; cursor: pointer; float: left;}
.transactionButton:hover{background-color: orange;}
.cancelButton{color: white; bottom: 5vw; border-radius: 1.52vw; width: 11.25vw;  padding-top: 0.7vw;
height: 2.5vw; font-size: 1.52vw; background-color: red; margin-right: 1.82vw; text-align: center; cursor: pointer; float: right;}
.cancelButton:hover{background-color: orange;}
.pointer{cursor:pointer;}

.Jamestown_Square{bottom: 17.5vw; left: 5.5vw;}
.Plattsburgh_Dot{top: 6vw; right: 15.5vw;}
.Syracuse_Dot{top: 20.5vw; right:41vw;}

.Buffalo_Dot{top: 24.5vw; left: 8.8vw;}
.Troy_Dot {top: 24vw; right:21vw;}
.Rochester_Square{top: 21vw; right: 54.2vw;}
.Queens_Square{bottom: 2vw; right: 18vw;}
.Poughkeepsie_Dot{top: 34vw; right: 19vw;}

.Brooklyn_Square{bottom: 1.5vw; right:19.7vw;}
.Bronx_Square{bottom: 4vw; right: 19vw;}
.Newburgh_Dot {top: 37vw; right: 21.5vw;}
.Staten_Island_Dot{bottom: 0.7vw; right: 21.5vw;}
.Long_Island_Dot {bottom: 3vw; right: 12vw;}
.Ithaca_Dot{top: 28vw; right: 43vw;}
.Niagara_Falls_Dot {top: 19.5vw; right: 67.35vw;}
.Olean_Square{top: 32vw; right: 61vw;}
.Mechanicville_Square{top: 22vw; right:20vw;}
.Albany_Dot{top: 24vw; right: 18vw;}
.Watertown_Square{top: 12vw; right: 39vw;}
.Tupper_Lake_Square{top: 10vw; right: 27vw;}

</style>
<title>Universal Wheels</title>
</head>

	<body style = "background-color: silver">
		<h1 class = "titleText">Universal Wheels</h1>
		<h3 class = "authorText">by Skyler Brivic &amp; Alice Webb</h3>
		
		<!-- mainWindow is the container that holds the main menu, which contains buttons to start the game, view the rules, and to view high scores -->
		<div class = "mainWindow">
			<h1 style = "margin-bottom: 4vw;" class = "mainTitleText">Universal Wheels</h1>
			 <div style = "margin-bottom: 3vw;" onclick="startGame()" class = "mainMenuLinks pointer mainMenuText">Start Game</div>
			 <div style = "margin-bottom: 3vw;" onclick = "showRules()" class = "mainMenuLinks pointer mainMenuText">Instructions</div>
			<div onclick = "mainData()" class = "mainMenuLinks pointer mainMenuText">High Scores</div>
 

		</div>
  <!-- The GameOverWindow loads when the user loses the game. -->
  <div class = "GameOverWindow">
  <div class = "banner">
  <div class = "rectangleButton" onclick = "gameOverReturn()">Return to Main Menu</div>
  </div>
  <h1 style = "text-align: center; margin-top: 4vw; color: Blue;">Game Over</h1>
  <h2 style = "color: Maroon; margin-top: 5vw; padding-left: 5vw; padding-right: 5vw;">It looks like things didn't work out quite as you intended. The car industry can be a rough place, so don't be too discouraged. Better luck next time!</h2>
  </div>
  
  <!--  timeOutWindow loads when the user runs out of time and the game is over -->
  <div class = "timeOutWindow">
  <h3>Out of Time!</h3>
  <p>You tried to become a dominating force in the car industry, but unfortunately you missed your opportunity to become the best in the world. Try to move a little bit faster next time!</p>
  <div class = "transactionButton" onclick = "gameTimeOut()">OK</div>
  </div>
  
  <div class = "BankruptWindow">
  <h3>Out of Cash!</h3>
  <p>Despite your best efforts, Universal Wheels has gone bankrupt! It's OK. The car business isn't for everyone. Just make sure that if you ever try to start your own business
  again, you take what you learned from this experience to do a better job!</p>
  <div class = "transactionButton" onclick = "gameBankrupt()">OK</div>
  </div>
  
  <!-- The RulesWindow is the container that lists the rules of the game when clicked on from the main manu -->
  <div class = "RulesWindow">
  <div class = "banner">
  <div class = "rectangleButton" onclick = "ReturnHome()">Return</div>
  </div>
  <div class = "blue"><p>Welcome to the wonderful world of cars! After receiving a large inheritance from your great aunt Florence, you find yourself in the perfect position to finally
  open your very own business. Since cars have always been your passion, you decide that you would like to launch your very own car company.</p>
  <p>The road ahead is sure to be paved with tough decisions. You will have to decide where the best places are to open your car stores and factories. Additionally, you're going to have
  to find a way to overpower your competitors if you want to become a powerhouse company. For now, you can only set up businesses in Westchester, since you lack the infrastructure to set up
  business locations across New York state. However, as you become more profitable, you may eventually be able to expand outside of Westchester, and eventually outside of New York as well!</p>
  <p>With the aim of expanding to every corner of the known universe, you adopt the name Universal Wheels as the name for your car company. Now get out there and go fight for control
  of the car industry!</p></div>
  
  </div>
  
  
  <!-- Level1Won is a container which displays text to the user when they beat level 1 -->
  <div class = "Level1Won">
  <p>Congratulations! You have become the most powerful car company in Westchester County! In fact, you have become so powerful that you can now expand outside of Westchester County and
  purchase locations Outside of Westchester. It's a big world out there, but I'm sure you can handle it. Just follow your instincts, make good decisions, and never give up. Good luck!</p>
  <div class = "transactionButton" onclick = "cancelClass('Level1Won')" style = "margin-left: 10vw;">I'm Ready!</div>
  </div>
  
  <!-- Level2Won is a container which displays text to the user when they beat level 2 -->
  <div class = "Level2Won">
  <p>Congratulations! You have become the most powerful car company in New York State! You are now ready to expand to the final frontier: locations outside of New York.
  It's a brave new world out there, but you've proven courageous so far, so I'm sure you can handle it!</p>
  <div class = "transactionButton" onclick = "cancelClass('Level2Won')" style = "margin-left: 10vw;">Let's Do This!</div>
  </div>
  
  <!-- Each decision the user must make has its own window, which displays a prompt (ex. Choice_1 is the ID of the first decision).
  Each decision has choices A and B associated with it (and for some choices C). When a choice is clicked on, decisionPost is called, which calls 
  the DecisionServ servlet to evaluate what the outcome of the user's choice was. Then the prompt window is closed and the outcome window is opened,
  which has an ID with the choice number, letter and either success or failure (ex. picking letter A of Choice_1 and getting the bad outcome would
  open up the window with the ID Choice_1A_Failure. Both the prompts and the outcomes are a part of the class decisiontext, and each choice has a potential
  good outcome and a potential bad outcome based on what companies Universal Wheels owns and how much money Universal Wheels has. The internal logic for evaluating whether each decision is
  a good decision or a bad decision is unique for each decision, although it is based on what logically makes the most sense.  -->
  
  <div id = "Choice_1" class = "decisiontext">
  <h3>Choose Carefully!</h3>
  	<p>After saving up your money carefully, you finally have enough cash to launch an ad campaign for Universal Wheels. You plan to
  	air a series of ads on local TV to help spread the word about your low deals and reliable products. However, your cousin Rick who works for an advertising agency has agreed
  	to put up billboards of your company around town for half the price of what it would cost to shoot and air the TV commercials. What would you like to do? </p>
  	<p>A: Launch the TV ad campaign (-$10,000)</p>
  	<p>B: Put up billboards around Westchester (-$5,000)</p>
  	<div class = "rectangleButton" onclick = "decisionPost(1, 'A')">TV ad campaign</div>
  	<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(1, 'B')" style = "float: right;">Billboards</div>
  </div>
	

<div id = "Choice_1A_Success" class = "decisiontext">
<h3>A star is born!</h3>
<p>The public is really starting to take notice of your company thanks to your vigorous TV ad campaign. Even people who don't usually pay attention to car companies
are starting to know your name, and that kind of publicity is just something that money can't buy! Expect to see an increase in sales over the next few weeks.</p>
<div class = "transactionButton" onclick = "cancel('Choice_1A_Success')">Okay</div>
</div>

<div id = "Choice_1A_Failure" class = "decisiontext">
<h3>Nursing Home TV Star</h3>
<p>Well, the ad campaign doesn't seem to have gone quite as well as you imagined. Most young people these days only watch TV on Netflix, and the network
decided to only air your commercials on Friday nights. The only people who saw your ads were shutins (who probably don't drive much) and people living 
in nursing homes (who also don't drive). Don't be surprised if sales for the next month are down a bit from before - nobody wants to buy a car
from a company whose ads only air in between infomercials!</p>
<div class = "transactionButton" onclick = "cancel('Choice_1A_Failure')">Okay</div>
</div>

<div id = "Choice_1B_Success" class = "decisiontext">
<h3>Talk of the Town</h3>
<p>Your cousin really knows his stuff. All of your billboards were put along major highways that have lots of stop and go traffic during rush hour. Thousands of commuters each day
can now see your company's name while they sit in traffic waiting to get to work. Expect a huge boost in sales in the weeks to come.</p>
<div class = "transactionButton" onclick = "cancel('Choice_1B_Success')">Okay</div>
</div>

<div id = "Choice_1B_Failure" class = "decisiontext">
<h3>"Trust starts with truth and ends with truth"</h3>
<p>Your cousin was not a good person to trust with any large amount of money. As soon as you sent him the cash, he immediately skipped town. Afterwards he started dodging your
phone calls, and when you went to his apartment no one was there. When the press heard about this, it caused a firestorm of accusations about your competence as the owner of 
Universal Wheels. Namely, the press wants to know why you would give someone so much money without even getting a contract? Expect your sales to be hit and hit hard over
the next few weeks, but if you can ride out this storm, you'll have become all the stronger because of it.</p>
<div class = "transactionButton" onclick = "cancel('Choice_1B_Failure')">Okay</div>
</div>

<div id = "Choice_2" class = "decisiontext">
<h3>Deal or no Deal</h3>
<p>As you walk out of company headquarters late at night, you are approached by Anthony Romano. Romano says that he runs
a loccal "business," and would like to start encouraging his workers to buy your cars. However, he can only make this work
if you agree to sell your cars to his men at a reduced rate. Romano is the leader of the local Mafia, and is in charge of at least 1,000
 people throughout Northern Westchester. What would you like to do?</p>
 <p>A: Give Romano and his men a discount (-$15,000)</p>
 <p>B: Decline to give Romano a discount (-$0)</p>
 <div class = "rectangleButton" onclick = "decisionPost(2, 'A')">Pay Romano</div>
 <div class = "rectangleButton" onclick = "decisionPost(2, 'B')" style = "float: right;">Decline Romano's Offer</div>
</div>

<div id = "Choice_2A_Success" class = "decisiontext">
<h3>Business is Booming</h3>
<p>"Okay, you can have the discount" you say to Romano. His eyes light up. "Don't worry, with how many cars you'll sell, you'll be making way
more money than you could have ever dreamed of making without us." You hope he's right. The next day you instruct salesman at your store to give
anyone who comes in and asks for the "Romano Family Discount" 10% off on their purchase. Over the next few weeks, your stores in Northern Westchester see a 
50% increase in sales. Romano really kept his word! When the end-of-month profit reports come in, expect to see some good news.</p>
<div class = "transactionButton" onclick = "cancel('Choice_2A_Success')">Okay</div>
</div>

<div id = "Choice_2A_Failure" class = "decisiontext">
<h3>Corruption, Corruption, Corruption</h3>
<p>You have a bad feeling about Romano, but you decide to trust him just this once. "Okay, you can have the discount" you say to Romano.
His eyes light up. "Don't worry, with how many cars you'll sell, you'll be making way more money than you could ever have dreamed of making without us."
You hope so. Days later, you see the headline "Universal Corruption" appear in the daily news. it turns out, an undercover reporter caught wind of the discount,
posed as a member of Romano's crew, and purchased a car for 10% off. Your company is now known as the business that favors the mob, and Romano's men
are reluctant to come back to your store for fear of being seen by the police who are now patrolling your businesses daily. What on earth have you gotten
yourself into?!?!?!?</p>
<div class = "transactionButton" onclick = "cancel('Choice_2A_Failure')">Okay</div>
</div>

<div id = "Choice_2B_Success" class = "decisiontext">
<h3>Temptation Resisted</h3>
<p>You have no intention of getting mixed up in the criminal underworld. "Sorry Mr. Romano," you begin, "but I just don't feel comfortable making that
kind of deal at this moment." Romano smiles gingerly in dissapointment. "Ah well. That's alright. Call me if you ever change your mind." Romano
proceeds to hand you his business card. The next day, Romano is arrested on charges of extortion, blackmail, and conspiracy to commit fraud for his
many questionable "business" ventures. Every penny of cash given to Romano or paid by Romano is scrutinized by the police. However, since you never
made a deal with Romano, you have nothing to worry about. What a lucky break!</p>
<div class = "transactionButton" onclick = "cancel('Choice_2B_Success')">Okay</div>
</div>

<div id = "Choice_2B_Failure" class = "decisiontext">
<h3>Nice Guys Finish Last!</h3>
<p>You pause for a moment contemplating this decision. "Sorry Mr. Romano, I just don't feel comfortable getting into this kind of agreement right now."
Romano frowns. "This is a mistake. Businesses that don't have our protection tend to have all sorts of accidents happen to them, accidents that wouldn't
happen if they were part of the family. I'll be seeing you around." With that, he slinks back into the shadows and out of sight. Over the next 3 days,
4 of your delivery trucks have their tires slashed, and one of your stores has 5 cars stolen from it overnight. Well, I guess it's true what they say:
revenge is a dish best served cold.</p>
<div class = "transactionButton" onclick = "cancel('Choice_2B_Failure')">Okay</div>
</div>

<div id = "Choice_3" class = "decisiontext">
<h3>Wrestling with the Big Dogs</h3>
<p>After weeks of effort, your company's chief strategist has managed to secure an appointment with the head of Scrap Metal Co., the number
1 collector of metal for industrial processing on the east coast. Scrap Metal Co. agrees to enter into a contract with you to purchase their metal products
at a discounted rate. But, there's a catch. Your business must agree to exclusively use the metal from Scrap Metal, and you cannot purchase metal from any other company
for at least a year. Scrap Metal also expects an initial investment of $10,000 to seal the deal. Is this partnership a good idea?</p>
<p>A. Sign the contract with Scrap Metal Co. (-$10,000)</p>
<p>B. Keep things the way they are (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(3, 'A')">Sign the Contract</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(3, 'B')">Don't sign the contract</div>
</div>

<div id = "Choice_3A_Success" class = "decisiontext">
<h3>King of the Scrap</h3>
<p>The deal with Scrap Metal Co. has paid dividends and then some! Manufacturing costs at your factory are now down 30%. Hopefully, the decrease in costs
will lead to an increase in profit for you over the next month!</p>
<div class = "transactionButton" onclick = "cancel('Choice_3A_Success')">Okay</div> 
</div>

<div id = "Choice_3A_Failure" class = "decisiontext">
<h3>Drawing the Short Straw</h3>
<p>Scrap Metal Co. is a reputable company. However, the deal you made with them has not helped your business due to the fact that your company isn't manufacturing
very much. In the end, the deal has effectively cost you $10,000 with no gain in revenue. Well, at least you'll remember this the next time an important
decision comes up for the company!</p>
<div class = "transactionButton" onclick = "cancel('Choice_3A_Failure')">Okay</div>
</div>

<div id = "Choice_3B_Success" class = "decisiontext">
<h3>Slow and Steady Wins the Race</h3>
<p>The deal is tempting, but you'd better leave things as is. Profits continue to climb steadily for your business over the next few weeks. No gain, no loss.</p>
<div class = "transactionButton" onclick = "cancel('Choice_3B_Success')">Okay</div>
</div>

<div id = "Choice_3B_Failure" class = "decisiontext">
<h3>Haste Makes Waste</h3>
<p>You decide you'd better go with your gut and stick with the metal companies you already have. Bad choice. Within a few weeks, your biggest steel source,
Metals Worldwide goes bankrupt. You are left scrambling to keep your many factories operational as you look for alternative sources of metal. Ultimately,
you have to buy steel from other companies for more than you'd like to spend in order to keep business going at your stores. Tough break.</p>
<div class = "transactionButton" onclick = "cancel('Choice_3B_Failure')">Okay</div>
</div>

<div id = "Choice_4" class = "decisiontext">
<h3>Workers of the World Unite!</h3>
<p>Some of the workers in your company have begun forming a union in order to improve their working conditions.
They allege that Universal Wheels isn't paying them enough money for the amount of work they're doing, and that they should be given higher salaries
as a result. You don't think that raising their salaries would hurt your business's profit very much, but at the same time, their salaries are average 
for the field, and you don't won't to come across as a weak leader. What would you like to do?</p>
<p>A. Raise your employee's salaries and allow the union to continue (-$25,000)</p>
<p>B. Refuse to allow the union but agree to raise employee salaries by half of their demands (-$12,500)</p>
<p>C. Crush the union and anyone associated with it (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(4, 'A')">Agree to all demands</div> <br> <br>
<div class = "rectangleButton" onclick = "decisionPost(4, 'B')">Raise Salaries by 1/2 Requested Amount</div> <br> <br>
<div class = "rectangleButton" onclick = "decisionPost(4, 'C')">Crush the Union</div>
</div>


<div id = "Choice_4A_Success" class = "decisiontext">
<h3>A Dollar Well Spent</h3>
<p>Your decision has really paid off. Morale at your company has improved, and your salesman have
been working harder than ever as a result. With the labor dispute settled, you can rest easy
that your business will continue to grow and prosper</p>
<div class = "transactionButton" onclick = "cancel('Choice_4A_Success')">Okay</div>
</div>

<div id = "Choice_4B_Success" class = "decisiontext">
<h3>A Dollar Well Spent</h3>
<p>Your decision has really paid off. Morale at your company has improved, and your salesman have
been working harder than ever as a result. With the labor dispute settled, you can rest easy
that your business will continue to grow and prosper</p>
<div class = "transactionButton" onclick = "cancel('Choice_4B_Success')">Okay</div>
</div>

<div id = "Choice_4A_Failure"  class = "decisiontext">
<h3>Not All Roads Lead to Rome...</h3>
<p>You agreed to raise their salaries, but your workers are still unhappy. Emboldened by your latest concession,
the Universal Union (as they've so named themselves) is now pushing for time off for childcare and for
increased medical insurance coverage. It looks like your profits are going to be down for the next few months...</p>
<div class = "transactionButton" onclick = "cancel('Choice_4A_Failure')">Okay</div>
</div>

<div id = "Choice_4B_Failure" class = "decisiontext">
<h3>Not All Roads Lead to Rome...</h3>
<p>You agreed to raise their salaries, but your workers are still unhappy. Emboldened by your latest concession,
the Universal Union (as they've so named themselves) is now pushing for time off for childcare and for
increased medical insurance coverage. It looks like your profits are going to be down for the next few months...</p>
<div class = "transactionButton" onclick = "cancel('Choice_4B_Failure')">Okay</div>
</div>

<div id = "Choice_4C_Success" class = "decisiontext">
<h3>"It is better to be feared than loved"</h3>
<p>You are the ruler of this company, and you will not allow yourself to be seen as weak. With an iron fist, you break the union apart.
Members of the union are told that they will be fired if they don't break up, and scatter like mice soon after. Business returns as usual,
and profits continue normally. Nicely done!</p>
<div class = "transactionButton" onclick = "cancel('Choice_4C_Success')">Okay</div>
</div>

<div id = "Choice_4C_Failure" class = "decisiontext">
<h3>What goes around comes around</h3>
<p>You won't let yourself be bossed around by your subordinates! You fire all the lead union organizers in your company and threaten to fire
anyone who tries to make another union. Bad idea. Pretty soon, a lawsuit for unlawful termination results in the workers you fired all getting
returned to their jobs with an added compensation for their troubles. The union is now even louder than ever, and is trying to force
you to resign as CEO of the company. Furthermore, the total costs for legal fees and compensation to employees wrongly fired totaled $50,000!
It would have cost a lot less and been a lot less hassle to just pay the union off...</p>
<div class = "transactionButton" onclick = "cancel('Choice_4C_Failure')">Okay</div>
</div>

<div id = "Choice_5" class = "decisiontext">
<h3>Universal Taxis</h3>
<p>West Side Taxi is starting to run low on working vehicles. In desperate need of new cars, they have offered to pay you $50,000 to rent a fleet of your
 cars to use as taxis for the next 2 weeks. The company says that they will mainly just drive people to the Hartsdale train station right outside of Scarsdale,
 and most of their customers live within a few miles of there, so your cars can be resold as used after you give them to the company. However, you want to make
 sure that you can properly monitor the company to make sure that they don't go over your mileage limit. What would you like to do?</p>
 <p>A. Rent the cars (+$50,000)</p>
 <p>B. Do Nothing (+$0)</p>
 <div class = "rectangleButton" onclick = "decisionPost(5, 'A')">Rent the Cars</div>
 <div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(5, 'B')">Do Nothing</div>
 </div>
 
 <div id = "Choice_5A_Success" class = "decisiontext">
 <h3>A Westside Love Story</h3>
 <p>True to their word, West Side Taxi didn't drive your cars very far, and returned them after 2 weeks. The increase in people seeing your cars is likely to bring more
 attention to your company, so expect an improvement in sales in the next few weeks.</p>
 <div class = "transactionButton" onclick = "cancel('Choice_5A_Success')">Okay</div>
 </div>
 
 <div id = "Choice_5B_Success" class = "decisiontext">
 <h3>Dodging A Bullet</h3>
 <p>West Side Taxi is already on the brink of total collapse due to being replaced by Uber, so you don't want to get tangled up in their affairs. Panther Deals on the other
 hand enthusiastically agreed to supply a large number of rentals to West Side Taxi in exchange for repayment at a later date by West Side Taxi. However, before that repayment could come,
 West Side Taxi filed for bankruptcy, and defaulted on all of its payments to other businesses. Good thing you didn't get mixed up with them!</p>
 <div class = "transactionButton" onclick = "cancel('Choice_5B_Success')">Okay</div>
 </div>
 
 <div id = "Choice_5A_Failure" class = "decisiontext">
 <h3>Tossed to the Sharks</h3>
 <p>Though your company tried its best to monitor West Side Taxi's use of your cars, your employees apparently did not do a good enough job keeping watch. West Side Taxi drivers went 
 way over their allotted mileage for your cars, and with how ripped up the inside of the cars are, you'll be lucky if you can resell them for anything at all. </p>
 <div class = "transactionButton" onclick = "cancel('Choice_5A_Failure')">Okay</div>
 </div>
 
 <div id = "Choice_5B_Failure" class = "decisiontext">
 <h3>Missing Your Ride</h3>
 <p>After you decline their offer, West Side Taxi decides to rent some cars from a more well-known company at a higher cost. They end up using the cars exactly as they said they would,
 and the company makes a pretty penny off of West Side Taxi's deal. Better luck next time!</p>
 <div class = "transactionButton" onclick = "cancel('Choice_5B_Failure')">Okay</div>
 </div>

<div id = "Choice_6" class = "decisiontext">
<h3>Keep Up The Pace!</h3>
<p>With the Christmas season gearing up, most of the major car companies in Westchester are now selling their cars at discounted rates.
The most extreme companies are selling their products at 25 % off, while the more conservative ones are selling their products at only 5% off.
Would you like to sell your cars at 20% off for a holiday sale? Or do you think that you would make more money if you leave your prices as is.</p>
<p>A. Start the Sale (-$10,000)</p>
<p>B. Do Nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(6, 'A')">Start Sale</div>
<div class = "rectangleButton" style = "float:right;" onclick = "decisionPost(6, 'B')">Do Nothing</div>
</div>
		
<div id = "Choice_6A_Success" class = "decisiontext">
<h3>T'is The Season To Be Jolly</h3>
<p>It's Christmas time for Universal Wheels! Your quarterly profit reports have come in, and your company has had a record-breaking quarter.
The sale on cars seems to have really attracted a lot of new customers. Expect to see a lot more business in the next few weeks as customers
take their new Universal Wheels cars to your autoshops, mechanics, and stores.</p>
<div class = "transactionButton" onclick = "cancel('Choice_6A_Success')">Okay</div>
</div>

<div id = "Choice_6A_Failure" class = "decisiontext">
<h3>Swing and A Miss</h3>
<p>You can at least take consolation in the fact that the Christmas sale wasn't a total failure: You did sell more cars than you did in the previous 3 months.
However, the loss of revenue from the discount in sales price was greater than the increase in money you got from your increased sales. What a bummer.</p>
<div class = "transactionButton" onclick = "cancel('Choice_6A_Failure')">Okay</div>
</div>

<div id = "Choice_6B_Success" class = "decisiontext">
<h3>"It is great wealth to a soul to live frugally with a contented mind"</h3>
<p>Sales have been up this month. It looks like you didn't need to have a sale to get people eager to buy new cars for the holidays (all the commercials
on TV do a good enough job of that as is). Additionally, your prices are already much lower than your competitors, so you have no need to lower your prices
further to compete. It looks like this year is going to be a green Christmas for Universal Wheels!</p>
<div class = "transactionButton" onclick = "cancel('Choice_6B_Success')">Okay</div>
</div>

<div id = "Choice_6B_Failure" class = "decisiontext">
<h3>Coal All Around</h3>
<p>Whoever told you that discounts won't affect customer sales should be fired from your marketing team. Immediately. Sales are way down for the month,
as your competitors have leap-frogged over you with their low prices and flashy "Christmas Sale" signs. It would take a Christmas miracle to finish in
the green this quarter!</p>
<div class = "transactionButton" onclick = "cancel('Choice_6B_Failure')">Okay</div>
</div>


<div id = "Choice_7" class = "decisiontext">
<h3>Back to the Future</h3>
<p>Earlier this week, you were contacted by the head of sales at Tesla. Tesla has finally decided to start selling their cars to car dealerships, and has offered to create a business deal with you whereby they would manufacture electric cars (for a cost) and you would
sell the cars at your stores. If you don't feel that you have very much factory output going on, this could be a great opportunity. Otherwise, you may as well just stick with what you know.</p>
<p>A. Partner with Tesla (-$0)</p>
<p>B. Keep Things as is (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(7, 'A')">Create the partnership</div>
<div class = "rectangleButton" style = "float: right; " onclick = "decisionPost(7, 'B')">Do Nothing</div>
</div>

<div id = "Choice_7A_Success" class = "decisiontext">
<h3>Leading the Way into the Future</h3>
<p>The Tesla cars you have been selling have become a big hit! Furthermore, the cost to purchase cars from Tesla for sale is much lower than what it would have cost to make your own
electric car factory and sell the cars yourself. It's always nice to be early to the next big market!</p>
<div class = "transactionButton" onclick = "cancel('Choice_7A_Success')">Okay</div>
</div>

<div id = "Choice_7B_Success" class = "decisiontext">
<h3>King of Business</h3>
<p>You consider the offer, but ultimately realize that electric cars are expensive and unpopular, so you're probably better off not selling them. Next month, it emerges that Tesla was
only offering to sell cars to companies across the country because their hybrid cars were selling so poorly that they hoped to find an easy way to get rid of them. Unfortunately for Jungle Cars,
they took the bait hook line and sinker, and are now floundering as a result. It's not clear how much longer they can stay in business, but it is clear that you won't have to worry too much about them
from here on out.</p>
<div class = "transactionButton" onclick = "cancel('Choice_7B_Success')">Okay</div>
</div>

<div id = "Choice_7A_Failure" class = "decisiontext">
<h3>Back to the Scrapyard</h3>
<p>Tesla may have exaggerated the value of the cars they were selling to you. It turns out that customers don't really want to pay more money for a car that has less horse power
than your standard gas-guzzling car. You have stopped buying new shipments from Tesla, but it may take a while to undo the damage that has been done to your brand name. Nevertheless, 
at least your business is doing better than Jungle Cars. Jungle Cars decided to replace all of their cars with Tesla, and are now hemorrhaging money as a result. Well, I guess the old
adage rings true: It could always be worse.</p>
<div class = "transactionButton" onclick = "cancel('Choice_7A_Failure')">Okay</div>
</div>

<div id = "Choice_7B_Failure" class = "decisiontext">
<h3>Missing the Boat</h3>
<p>You're going to be kicking yourself for missing out on this opportunity. Tesla cars are now selling better than ever, and Tesla has raised the price of acquiring their cars
for sale by a large amount to any newcoming companies eager to cash in on their success. Well, at least there's always next time.</p>
<div class = "transactionButton" onclick = "cancel('Choice_7B_Failure')">Okay</div>
</div>

<div id = "Choice_8" class = "decisiontext">
<h3>Giving back to the Community</h3>
<p>The once prosperous park known as Memorial Field has fallen into disrepair. In desperate need of funding for repairs, the city council of Mount Vernon has asked if any companies would
be willing to supply funding for the project in exchange for being able to rename the field after their company. Would you like to step up to the plate, and to help create "Universal Wheels Field?"</p>
<p>Choice A. Pay for the park (-$50,000)</p>
<p>Choice B. Do nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(8, 'A')">Pay for Park</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(8, 'B')">Do Nothing</div>
</div>

<div id = "Choice_8A_Success" class = "decisiontext">
<h3>Treat Others the Way You'd Want to be Treated</h3>
<p>The community really appreciates your effort. Universal Wheels Field is packed on the weekends, with kids playing baseball, groups of teenagers playing football, and plenty of adults
lounging around in the sun. Additionally, the park has helped draw a lot of attention to your business, leading to lots of new customers coming on down to Mount Vernon's Universal Wheel's shop
which they previously weren't aware existed. Nicely done!</p>
<div class = "transactionButton" onclick = "cancel('Choice_8A_Success')">Okay</div>
</div>

<div id = "Choice_8B_Success" class = "decisiontext">
<h3>Slow and Steady wins the Race</h3>
<p>Ford Field is still under construction. The government of Mount Vernon is at a loss as to how to explain the loss of the money given to them by Ford, and the justice department
is preparing to indict the mayor of Mount Vernon on charges of corruption and theft of taxpayer money. Thank god you didn't get involved in that mess!</p>
<div class = "transactionButton" onclick = "cancel('Choice_8B_Success')" >Okay</div>
</div>

<div id = "Choice_8A_Failure" class = "decisiontext">
<h3>A Thankless Job</h3>
<p>The government of Mount Vernon was not as responsible as you had assumed. The mayor is unable to explain where the money you gave him went, and the park still
lies in ruins. Your company has sued the Mount Vernon government to get your money back, but it will probably cost more to sue than the amount of money you'll get back.</p>
<div class = "transactionButton" onclick = "cancel('Choice_8A_Failure')">Okay</div>
</div>

<div id = "Choice_8B_Failure" class = "decisiontext">
<h3>Giving Promotes Good Health</h3>
<p>As the largest company in Mount Vernon, it's embarrassing that Universal Wheels was one of the few companies in the city to not at least
make a donation for the field. This has generated a lot of negative press for your company, so sales may be down in the next few months.</p>
<div class = "transactionButton" onclick = "cancel('Choice_8B_Failure')">Okay</div>
</div>

<div id = "Choice_9" class = "decisiontext">
<h3>A Monster Deal!</h3>
<p>After a group of Ardsley parents pooled their money together, they were finally able to raise enough funds to purchase a monster truck for the
Ardsley Little League team. This truck will help attract outsiders to the games, and will act as the "mascot" for The Ardsley Monsters. Instead of paying $100,000 to a reputable
monster truck company (plus the costs of manufacturing the monster truck), the Ardsley parents have approached you offering $50,000 in exchange for the construction
of a monster truck. Your company has created plenty of pickup trucks, but no monster trucks. Would you like to accept this offer?</p>
<p>A. Build the Monster Truck (+$50,000)</p>
<p>B. Decline the Offer (+$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(9, 'A')">Build the Monster Truck</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(9, 'B')">Do Nothing</div>
</div>

<div id = "Choice_9A_Success" class = "decisiontext">
<h3>Monstrous Success!</h3>
<p>The Ardsley little league home crowd is really enjoying the monster truck. When it does its wheelies and spins, it never fails to get the crowd reved up.
Building the monster truck helped your company get an article printed about it from the local newspaper, the Enterprise. Expect business to be booming in the next
few weeks.</p>
<div class = "transactionButton" onclick = "cancel('Choice_9A_Success')">Okay</div>
</div>

<div id = "Choice_9B_Success" class = "decisiontext">
<h3>With Great Power Comes Great Responsibility</h3>
<p>You would like to accept the Ardsley parent's offer, but you don't feel that your manufacturing team is up for the task of designing and creating a monster truck.
As a result, the Ardsley parents get Westchester Discount Cars to build the monster truck for them instead. It turns out that Westchester Discount Cars also wasn't well suited
to the challenge. During a little league game, while performing a stunt, an axle and wheel broke off of the monster truck, and the truck missed crashing into the bleachers filled with spectators by only 2 feet. 
Westchester Discount Cars is now being sued for multiple vehicle safety violations, and appears to be nearing bankruptcy. It's important to always know your limitations!</p>
<div class = "transactionButton" onclick = "cancel('Choice_9B_Success')">Okay</div>
</div>

<div id = "Choice_9A_Failure" class = "decisiontext">
<h3>Slipping and Sliding</h3>
<p>You tried your best to construct the monster truck. In the end, you were able to finish it, but the truck can barely go above 20 miles per hour, and makes for a pretty rocky ride.
The Ardsley parents are furious with you, claiming that your company scammed them by giving them a non-functional car. This does not bode well for your company's public image.</p>
<div class = "transactionButton" onclick = "cancel('Choice_9A_Failure')">Okay</div>
</div>

<div id = "Choice_9B_Failure" class = "decisiontext">
<h3>A Monster Missed Opportunity</h3> 
<p>Though the offer is tempting, you don't believe your company has what it takes to build a monster truck. The Ardsley parents instead
pay $100,000 for a reputable company to make their car. The monster truck is a big hit in Ardsley, and has even gotten an article written about it in
the local newspaper, The Enterprise. It's too bad that Universal Wheels couldn't capitalize on this good publicity!</p>
<div class = "transactionButton" onclick = "cancel('Choice_9B_Failure')">Okay</div>
</div>

<div id = "Choice_10" class = "decisiontext">
<h3>To be King for a Day</h3>
<p>After much delay, Tekrot University has finally opened its doors. The 300 acre college finds itself located in Harrison, in the lower east corner
of Westchester. With all of the new college students entering the area looking for cars, you have yourself perfectly positioned to enter into
the car rental business. Would you like to purchase some rental cars to get started?</p>
<p>A. Purchase the Rental Cars (-$30,000)</p>
<p>B. Do Nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(10, 'A')">Purchase Rentals</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(10, 'B')">Do Nothing</div>
</div>

<div id = "Choice_10A_Success" class = "decisiontext">
<h3>The best 4 Wheels of Your Life</h3>
<p>To think, some people say that millennials can't do anything right! Your company has made thousands of rentals since you purchased
a fleet of rental cars. The college kids really like having a way that they can drive from their sleepy college town to the middle of Manhattan
on Saturday nights. Good work!</p>
<div class = "transactionButton" onclick = "cancel('Choice_10A_Success')">Okay</div>
</div>

<div id = "Choice_10A_Failure" class = "decisiontext">
<h3>4 Years of Debt</h3>
<p>It turns out that some of the teens were a bit more reckless with the rental cars than you thought. Three of them were in fact so
reckless that they got drunk and hit and killed an elderly woman while driving one of your rentals. Now your company is under intense
scrutiny as the media is uncovering the lack of oversight at your company when determining whether or not to rent a car. Expect more lawsuits
and legal fees to arise from the family of the victim, in addition to the large legal fees you've already had to pay. And God help you if it 
turns out that anybody else was injured as a result of your company's negligence. </p>
<div class = "transactionButton" onclick = "cancel('Choice_10A_Failure')">Okay</div>
</div>

<div id = "Choice_10B_Success" class = "decisiontext">
<h3>A foolish man bites, a wise man waits</h3>
<p>You decide that you don't want to have the extra liability of renting cars to teenagers. Besides, your company is already profitable enough as is.
Two of the kids from Tekrot are arrested after hitting and severely injuring a man with their car while driving under the influence. The teens had rented a car,
 from a different car company near the college. That was a close call!</p>
<div class = "transactionButton" onclick = "cancel('Choice_10B_Success')">Okay</div>
</div>

<div id = "Choice_10B_Failure" class = "decisiontext">
<h3>Those who win never wait, and those who wait never win</h3>
<p>Ever since the school year started, you've really been lagging behind your competitors in sales. The fact that most of the other car
companies near the college have rental cars and you don't has really turned away a lot of potential costumers. This financial quarter may
be a tough one for Universal Wheels.</p>
<div class = "transactionButton" onclick = "cancel('Choice_10B_Failure')">Okay</div>
</div> 

<div id = "Choice_11" class = "decisiontext">
<h3>The King of Lake Erie</h3>
<p>The Buffalo market has proven loyal to Universal Wheels so far, but you have still been unable to break Subaru's lead in the area. In an attempt to gain an edge,
your chief of marketing has come up with an idea to boost sales. For the next two months, your company will offer people the Buffalo metropolitan area the chance
to gain a discount on any car they purchase. However, it comes with a catch: If the Bills win the Super Bowl this year, then anyone who bought cars bought during this time period (which lasts until
about 2 months before the super bowl) will receive a refund of 35% off on their car. However, if the Bills don't win, then they don't get any refund, and have to continue paying for the car
like normal. Your lead cost-risk analysis manager estimates a 1% or less chance that the Bills win the super bowl this year. What would you like to do?</p>
<p>A. Offer the Discount (-$0)</p>
<p>B. Do Nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(11, 'A')">Offer the Discount</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(11, 'B')">Do Nothing</div>
</div>

<div id = "Choice_11A_Success" class = "decisiontext">
<h3>Leaders of the Pack</h3>
<p>With how unlikely it is that the Bills will win the super bowl this year, you decide to go for it on 4th and short, and launch the discount.
At the end of the season, the Bills have gone 6-10 and missed the playoffs, but Universal Wheels has seen a 50% increase in their sales in the Buffalo
metropolitan area, and is starting to overtake Subaru as the most dominant car company in the region. And to think, some people claim that the Buffalo Bills
can't do anything right!</p>
<div class = "transactionButton" onclick = "cancel('Choice_11A_Success')">Okay</div>
</div>

<div id = "Choice_11B_Success" class = "decisiontext">
<h3>By the Skin of Your Teeth</h3>
<p>Your company really dodged a bullet on this one. The bills just earned their first Super Bowl victory in franchise history, defying all the "expert's"
predictions at the start of the year. If you had made the discount offer, your company would have lost millions of dollars. Thank god for your restraint!</p>
<div class = "transactionButton" onclick = "cancel('Choice_11B_Success')">Okay</div>
</div>

<div id = "Choice_11A_Failure" class = "decisiontext">
<h3>The Buffalo Curse</h3>
<p>Your not going to believe this one. The Bills pulled off an improbable season, defying expert predictions week by week, until they eventually won the AFC East.
After this, they blew away all the competition in the playoffs to win their franchise's first super bowl. Your company is really in trouble now. Even though sales
have been up in the last few months, you are expected to lose hundreds of thousands of dollars giving out discounts/refunds to your buffalo area customers, who bought
your cars en masse when they saw how well the Bills were doing. It looks like no matter what, the curse of Buffalo lives on!</p>
<div class = "transactionButton" onclick = "cancel('Choice_11A_Failure')">Okay</div>
</div>

<div id = "Choice_11B_Failure" class = "decisiontext">
<h3>Punting on First and Goal</h3>
<p>The Bills had yet another mediocre season, finishing with a record of 7-9. Your overly conservative play-calling style has cost your company the chance
to make a fortune off of hopeful die-hard Bills fans. Now you can only watch as Subaru continues to rake in the profits of the Buffalo metropolitan area.
Just your luck!</p>
<div class = "transactionButton" onclick = "cancel('Choice_11B_Failure')">Okay</div>
</div>

<div id = "Choice_12" class = "decisiontext">
<h3>Pushing Through</h3>
<p>Fed up with their city's school buses which frequently stall during snowstorms, the city of Albany has turned to you hoping that you can manufacture
school buses for the city's public schools. This is a big responsibility. You need to be capable of producing vehicles that can drive up steep icy slopes without slipping,
and can withstand being crashed into without the occupants of the vehicle being seriously injured. Is Universal Wheels up for the challenge?</p>
<p>A. Sign the Contract with Albany (+$50,000)</p>
<p>B. Decline the Offer (+$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(12, 'A')">Sign the Contract</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(12, 'B')">Decline the Offer</div>
</div>

<div id = "Choice_12A_Success" class = "decisiontext">
<h3>Break on Through</h3>
<p>Your school buses have been the remedy that the city of Albany has been looking for to cure its schools bus maladies. Able to easily climb up snowy hills and with powerful brakes
able to maintain traction with even the iciest roads, you've really come through for the children of Albany. Expect a lot more people in the area to take notice of your company's powerful,
durable vehicles!</p>
<div class = "transactionButton" onclick = "cancel('Choice_12A_Success')">Okay</div>
</div>

<div id = "Choice_12B_Success" class = "decisiontext">
<h3>Gaining Your Footing Back</h3> 
<p>Winter this year has been truly treacherous. Even the best school buses in upstate New York have been slipping and sliding, struggling to take the kids to and from school. A lot of car companies
have even had to pay compensation to the school districts for the inability of their vehicles to make it through the snow (as specified in their contracts). It's a good thing
that Universal Wheels wasn't involved in this!</p>
<div class = "transactionButton" onclick = "cancel('Choice_12B_Success')">Okay</div>
</div>

<div id = "Choice_12A_Failure" class = "decisiontext">
<h3>Stuck</h3>
<p>While your school buses would have been sufficient for most winters, this was no ordinary winter. On one particularly slippery day, over 2 inches of ice formed on the roads. A school bus
made by your company lost control and crashed into Albany Elementary School. Luckily, nobody was hurt, but the building was seriously damaged in the process, and Universal Wheels is mandated by
their contract with the school to pay compensation for any damages caused by their vehicles being unable to handle the snow. This is gonna hurt your bank account!</p>
<div class = "transactionButton" onclick = "cancel('Choice_12A_Failure')">Okay</div>
</div>

<div id = "Choice_12B_Failure" class = "decisiontext">
<h3>Slipping Behind</h3>
<p>Your company has been sliding backwards in sales for the last two months in Albany. It's a shame that you don't have some extra way to make money selling vehicles in the area,
such as manufacturing school buses...</p>
<div class = "transactionButton" onclick = "cancel('Choice_12B_Failure')">Okay</div>
</div>

<div id = "Choice_13" class = "decisiontext">
<h3>Driving through History</h3>
<p>They said it could never be done. Then again, the naysayers of the world were never the ones who made history. After much research, your lead engineering team has discovered a way to create a solar
powered car! The car will use energy from the sun to move, using fuel only when there is no sun outside. This innovation has the potential to completely upend the car industry as you know it. Would you like
to start selling your solar cars in stores?</p>
<p>A. Start selling the Cars (+$0)</p>
<p>B. Don't sell them (+$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(13, 'A')">Sell the Cars</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(13, 'B')">Don't sell the Cars</div>
</div>

<div id = "Choice_13A_Success" class = "decisiontext">
<h3>Walking on Sunshine</h3>
<p>Your solar cars have become a big hit! People from all over the state are buying them up to avoid having to pay the high costs of gasoline.
Time magazine even did a feature article on your company's cars, calling your company "A sustainable business model for the future." Nicely done!</p>
<div class = 'transactionButton' onclick = "cancel('Choice_13A_Success')">Okay</div>
</div>

<div id = "Choice_13B_Success" class = "decisiontext">
<h3>When the Rainclouds Come</h3>
<p>Though the prospect is tempting, you don't want to chance your company's future on some untested new car model. You decide to wait until the technology is more developed
before manufacturing your own solar cars. It's a good thing you did. Further testing of your cars in the winter shows that their ability to absorb sunlight in the winter is extremely poor,
rendering the solar portion of the car's power source essentially unusable. Patience is the key to success in this industry!</p>
<div class = "transactionButton" onclick = "cancel('Choice_13B_Success')">Okay</div>
</div>

<div id = "Choice_13A_Failure" class = "decisiontext">
<h3>Burning Up</h3>
<p>Your solar cars are a joke. Numerous people have posted Youtube videos showing themselves driving only 10 miles in your car on a partly sunny day before they run out of fuel and
are stuck in the middle of the road. People from especially cold areas have been hit the most by your design flaws, and people from all over the state are demanding refunds. It looks
like your company is going to be losing some money for the next few weeks.</p>
<div class = "transactionButton" onclick = "cancel('Choice_13A_Failure')">Okay</div>
</div>

<div id = "Choice_13B_Failure" class = "decisiontext">
<h3>Sunburned</h3>
<p>Other car companies were quick to catch wind of your idea of solar cars, and before you knew it, solar cars were the fastest selling car on the market. You started to make your own solar cars
to compete with the other companies, but your late start to the party has left you scrambling to catch up. In the car industry, timing really is everything!</p>
<div class = "transactionButton" onclick = "cancel('Choice_13B_Failure')">Okay</div>
</div>

<div id = "Choice_14" class = "decisiontext">
<h3>On Your Mark! Get Set...</h3>
<p>The annual Rochester Auto Race is approaching quickly, and the drivers have been gearing up for a competitive event. The competition is expected to draw an attendance in the
tens of thousands, and the winner of the competition will receive a crown of olive leaves and $200,000. Tom Patterson has had a falling out with his previous sponsor, and so has turned to Universal Wheels
looking for a company to front him the $25,000 he needs to compete in the race. In return for paying this cost, you will be able to put the Universal Wheels logo on his car, and he will wear a race suit with the Universal
Wheels logo on it. Do you want to accept this offer?</p>
<p>A. Sponsor the Car (-$25,000)</p>
<p>B. Do Nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(14, 'A')">Sponsor the Car</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(14, 'B')">Do Nothing</div>
</div>

<div id = "Choice_14A_Success" class = "decisiontext">
<h3>Zooming into View</h3>
<p>Tom Patterson won first prize at the Rochester Auto Race! After a photo finish against his arch rival Derick Carlson, his car (and your logo) have been appearing in
sports replays over the course of the last week. Expect this good publicity to generate to an increase in sales over the next few weeks.</p>
<div class = "transactionButton" onclick = "cancel('Choice_14A_Success')">Okay</div>
</div>

<div id = "Choice_14B_Success" class = "decisiontext">
<h3>Photo Finish</h3>
<p>Tom Patterson was not the man you or the media thought he was. After being accused of attacking and putting into a coma another man in a drunken bar fight, Patterson
has been temporarily suspended from all upcoming races pending the outcome of his case. He'll be lucky if he gets to watch the Rochester race from the grand stands,
as opposed to on a TV inside a cell. It's a good thing you didn't get involved in this trainwreck!</p>
<div class = "transactionButton" onclick = "cancel('Choice_14B_Success')">Okay</div>
</div>

<div id = "Choice_14A_Failure" class = "decisiontext">
<h3>Going Up In Flames</h3>
<p>Tom Patterson was not the man you or the media thought he was. After being accused of attacking and putting into a coma another man in a drunken bar fight, Patterson
has been temporarily suspended from all upcoming races pending the outcome of his case. His Universal Wheels logo adorned car will go unused, and you are unlikely to be able to 
get the money back that you used to sponsor his car. What a tough break!</p>
<div class = "transactionButton" onclick = "cancel('Choice_14A_Failure')">Okay</div>
</div>

<div id = "Choice_14B_Failure" class = "decisiontext">
<h3>Skipped Over</h3>
<p>Tom Patterson took home first place in the annual Rochester Auto Race. You can only watch with regret as his BMW logo adorned car gets all the airtime on replays of the event.
Patterson is 0-7 in the last 7 years of racing in the Rochester Auto Race, so don't feel too bad if you didn't think that Patterson would actually win!</p>
<div class = "transactionButton" onclick = "cancel('Choice_14B_Failure')">Okay</div>
</div>

<div id = "Choice_15" class = "decisiontext">
<h3>Breaking A Sweat</h3>
<p>With the summer heat wave reaching its peak, New York City residents are desperate for some kind of cold to break the heat. Your chief marketing strategist has an idea that Universal Wheels
could manufacture a series of cheap ice cream trucks, which they could then sell to opportunistic ice cream vendors throughout New York City. Does Universal Wheels have what it takes to create a fleet of ice
cream trucks to service the Big Apple?</p>
<p>A. Build the Ice Cream Trucks (-$50,000 for manufacturing costs)</p>
<p>B. Do nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(15, 'A')">Build the Ice Cream Trucks</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(15, 'B')">Do Nothing</div>
</div>

<div id = "Choice_15A_Success" class = "decisiontext">
<h3>The Ice Cold Taste of Success</h3>
<p>Your ice cream trucks are speeding through every corner of the five boroughs. It seems like no matter how fast you sell your ice cream trucks, demand for them just keeps increasing. 
Not only that, but the kids of New York City are really starting to like Universal Wheels cars now. Just you wait for the car sales increase that will happen in 13 years when these kids
are old enough to drive!</p>
<div class = "transactionButton" onclick = "cancel('Choice_15A_Success')">Okay</div>
</div>

<div id = "Choice_15B_Success" class = "decisiontext">
<h3>Staying Cool</h3>
<p>The summer heat wave broke sooner than you expected, and its been humid and raining for much of the last two weeks. It's a good thing you didn't waste time manufacturing any ice cream trucks! After all,
who would want to buy ice cream out when its raining?</p>
<div class = "transactionButton" onclick = "cancel('Choice_15B_Success')">Okay</div>
</div>

<div id = "Choice_15A_Failure" class = "decisiontext">
<h3>Burnt Out</h3>
<p>The summer heat wave broke within a few days of Universal Wheels beginning to manufacture ice cream trucks. Sales have been excruciatingly slow for the ice cream mobiles, and don't expect
things to be any better when the winter comes. It looks like Universal Wheels is just going to have to eat the loss this quarter! </p>
<div class = "transactionButton" onclick = "cancel('Choice_15A_Failure')">Okay</div>
</div>

<div id = "Choice_15B_Failure" class = "decisiontext">
<h3>Melted</h3>
<p>With no end to the summer heat wave in sight, a large number of car companies have been able to make a quick buck by manufacturing ice cream trucks... A large number of car companies
that does not include Universal Wheels! Unfortunately, it looks like your company is too late now to have a chance to capitalize on this business before the summer ends. What a bummer!</p>
<div class = "transactionButton" onclick = "cancel('Choice_15B_Failure')">Okay</div>
</div>

<div id = "Choice_16" class = "decisiontext">
<h3>Spacing Out</h3>
<p>With property taxes on the rise throughout New York, businesses have been hard pressed to find affordable warehouses to store their goods. One particular business, Carlton
Cleaning Supplies inc. is currently looking to rent out space from a company to store their supplies for later shipment. The CEO of Carlton has offered Universal Deals $10,000 in
exchange for leasing part of one of your factories to them for storage space for a month. Carlton promises that they intend to use only a small unused corner of your factory, and will not
impede your regular business activities. How would you like to proceed?</p>
<p>A. Accept the Offer (+$10,000)</p>
<p>B. Decline the Offer (+$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(16, 'A')">Accept the Offer</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(16, 'B')">Decline the Offer</div>
</div>

<div id = "Choice_16A_Success" class = "decisiontext">
<h3>Warehouse King</h3>
<p>True to their word, Carlton only utilized a small portion of your available factory space to store its goods. At the end of the month, Carlton vacated your factory as promised,
without slowing down your manufacturing. Other companies have took note of your storage services, and are now asking if they can rent space from you as well. It looks like you'll now
have an extra source of cash each month!</p>
<div class = "transactionButton" onclick = "cancel('Choice_16A_Success')">Okay</div>
</div>

<div id = "Choice_16B_Success" class = "decisiontext">
<h3>Witholding Space</h3>
<p>A few weeks after approaching you with it's business offer, Carlton Cleaning Supplies Inc. was raided by the DEA, who discovered that the whole company was a front for money
laundering for drugs. All of Carltons cleaning's business associates are now under investigation, which fortunately does not include Universal Wheels!</p>
<div class = "transactionButton" onclick = "cancel('Choice_16B_Success')">Okay</div>
</div>

<div id = "Choice_16A_Failure" class = "decisiontext">
<h3>The Odd Couple</h3>
<p>You aren't sure what Carlton defines a small amount of space as, but they have really started to encroach on your factory's manufacturing space. In fact, they have taken up so much space
that it's slowing down your production of cars. At least you got some money from it, and Carlton will be out of your hair by the end of the month anyways...</p>
<div class = "transactionButton" onclick = "cancel('Choice_16A_Failure')">Okay</div>
</div>

<div id = "Choice_16B_Failure" class = "decisiontext">
<h3>Reservations for Failure</h3>
<p>Over the course of the next 2 months, you find that your factories are producing more than enough products to sell to all your customers. It's a shame that there isn't some extra way
that you can make money off of your factories!</p>
<div class = "transactionButton" onclick = "cancel('Choice_16B_Failure')">Okay</div>
</div>

<div id = "Choice_17" class = "decisiontext">
<h3>On the Web</h3>
<p>It's no secret that brick and mortar stores are going out of style as online stores are growing in popularity. Unlike many other industries, the car industry has proven much more resistant to this
change, though change must always come eventually. Keeping this in mind, your media and marketing relations advisor has suggested that Universal Wheels design an online car store. This store would let customers
preorder for car supplies to be delivered to their house, and would even let them select and reserve a car to purchase, which they could then buy at their local Universal Wheels store. It will cost an estimated $100,000
to pay a team of web programmers to design this site. What do you think? Should Universal Wheels go online?</p>
<p>A. Go Online (-$100,000)</p>
<p>B. Stay Offline (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(17, 'A')">Go Online</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(17, 'B')">Stay Offline</div>
</div>

<div id = "Choice_17A_Success" class = "decisiontext">
<h3>Going Virtual</h3>
<p>Your new website is a big hit. The ease with which people can purchase goods online is something that sets Universal Wheels a part from all of your competitors in the industry. Great choice!</p>
<div class = "transactionButton" onclick = "cancel('Choice_17A_Success')">Okay</div>
</div>

<div id = "Choice_17B_Success" class = "decisiontext">
<h3>The Old School</h3>
<p>You may not be the most technologically advanced car company in the industry, but you have something which you know a website could never replace: high-quality customer service
from real people. You dismiss the idea of building an online store, and continue with your current model of making all of your sales in physical stores.</p>
<div class = "transactionButton" onclick = "cancel('Choice_17B_Success')">Okay</div>
</div>

<div id = "Choice_17A_Failure" class = "decisiontext">
<h3>Too Much, Too Fast</h3>
<p>The idea of buying car products online has not really caught on with the public. Whether you were too quick or whether online car stores are a bad idea, your online store has been a dud, and it
has not helped you increase sales at all. Hopefully, as the industry evolves, it will become a usefull assset in the future!</p>
<div class = "transactionButton" onclick = "cancel('Choice_17A_Failure')">Okay</div>
</div>

<div id = "Choice_17B_Failure" class = "decisiontext">
<h3>Too Little, Too Slow</h3>
<p>Apparently, you weren't the only car company considering creating online stores. Several of your competitors have just set up their own online shops, which have quickly become
high profit businesses. It's a shame that you weren't quick enough to beat them to the punch. Now, you can only watch from the sidelines as your competitors rake in the profits
of virtual business.</p>
<div class = "transactionButton" onclick = "cancel('Choice_17B_Failure')">Okay</div>
</div>

<div id = "Choice_18" class = "decisiontext">
<h3>The World of Tires</h3>
<p>There's nothing more frustrating than being on your way to an important place and getting a flat tire. Your technology development department has come up with a way to fix this issue.
Using new Teflon-Seal technology, your technicians have designed a tire that can resist most puncture wounds that a tire could encounter, and which stays inflated 3 times longer than the standard
car tire. It's possible that the decrease in the sale of tires that would result from selling such long-lasting tires could hurt business for you, but its all possible that your high quality tires
could lead to an increase in your company's sales. Will you push the tire industry to the next step forward?</p>
<p>A. Sell the New Tires (-$25,000 for manufacturing costs)</p>
<p>B. Do Nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(18, 'A')">Sell the New Tires</div>
<div class = "rectangleButton" onclick = "decisionPost(18, 'B')">Do Nothing</div>
</div>

<div id = "Choice_18A_Success" class = "decisiontext">
<h3>Rolling Over the Competition</h3>
<p>Your tires are unstoppable! With a level of quality that is unmatched by any other company, you have been able to gain a decisive edge in the tire industry, and of course,
all your new cars are also made with these tires. Expect an overall increase in sales over the next few months.</p>
<div class = "transactionButton" onclick = "cancel('Choice_18A_Success')">Okay</div>
</div>

<div id = "Choice_18B_Success" class = "decisiontext">
<h3>Test Before You Run</h3>
<p>Further analysis from your company's accountants shows that the projected revenue from selling the new tires would be less than the revenue obtained from continuing to sell the
current car. It turns out that flat tires are very important ingredients to your company's tire sales. You want to provide good quality products, but not products that are so good that they
will hurt your sales!</p>
<div class = "transactionButton" onclick = "cancel('Choice_18B_Success')">Okay</div>
</div>

<div id = "Choice_18A_Failure" class = "decisiontext">
<h3>Rolled Over</h3>
<p>Your tires are as strong as an ox! but maybe they're a little too strong... Sales for tires have been down for the last 2 months, as less and less people
are getting flat tires, leading to lower overal profit from your sale of tires. I guess it's true what they say: everything must be done in moderation!</p>
<div class = 'transactionButton' onclick = "cancel('Choice_18A_Failure')">Okay</div>
</div>

<div id = "Choice_18B_Failure" class = "decisiontext">
<h3>Falling Flat</h3>
<p>In recent weeks, some of your customers have begun to complain about what they preceive as poor quality on the part of your tires. It turns out that other companies were paying your workers
to divulge the results of your research program, and have begun selling their own invinsible tires. Your own tires now look weak by comparison, which has severely crippled your tire sales. It just goes to show,
you never know who you can trust these days!</p>
<div class = "transactionButton" onclick = "cancel('Choice_18B_Failure')">Okay</div>
</div>

<div id = "Choice_19" class = "decisiontext">
<h3>Self-Defense</h3>
<p>Several of your stores have been burglarized over the past 3 weeks by theives. On each night, the theives stole several of your supplies, and also stole the seats out of one of your
cars! To combat this your head of company security is reccomending that you have a security system installed at each Universal Wheels stores and factories. This system would scan each room for
intruders, and call the police when a break-in is in progress. However, installing the system in all of your stores and factories may be a bit pricy. On the other hand, can you really put
a price on safety?</p>
<p>A. I Cannot Put a Price on Safety (-$130,000)</p>
<p>B. Actually, I Think I Can Put A Price On Safety (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(19, 'A')">Install the Security System</div>
<div class = "rectangleButton" onclick = "decisionPost(19, 'B')">Don't Install the Security System</div>
</div>

<div id = "Choice_19A_Success" class = "decisiontext">
<h3>Red-Handed!</h3>
<p>With the help of your security system you were able to apprehend a thief who was attempting to steal one of your car's radios. Police searched the man's house, and 
found all of the material that has been stolen from your company over the last 3 weeks. It turns out, this man had memorized the security procedures of your company, and 
was using his knowledge of them to steal from Universal Wheels locations accross the state. The reign of terror is finally over!</p>
<div class = "transactionButton" onclick = "cancel('Choice_19A_Success')">Okay</div>
</div>

<div id = "Choice_19B_Success" class = "decisiontext">
<h3>Problem Solved!</h3>
<p>Though you'd like to install the security systems, you know that they're unlikely to be worth the cost. Fortunately for you, the rash of thefts suddenly stops,
and business resumes as usual. What a lucky break!</p>
<div class = "transactionButton" onclick = "cancel('Choice_19B_Success')">Okay</div>
</div>

<div id = "Choice_19A_Failure" class = "decisiontext">
<h3>Waiting For Godot</h3>
<p>You wait for the thief to be apprehended, but suddenly, he stops showing up at your locations. Now your expensive security system is just collecting dust,
and you're no closer to finding your stolen goods than you were before this all started. Well, I guess sometimes crime really does pay!</p>
<div class = "transactionButton" onclick = "cancel('Choice_19A_Failure')">Okay</div>
</div>

<div id = "Choice_19B_Failure" class = "decisiontext">
<h3>Thwarted!</h3>
<p>The friday morning after you install the security systems, your employees arrive at work and find that an entire car is missing from your shop! In its place is a note scrawled
in pencil, with the only thing written on it being "Thanks for the new car." How does this kind of thing even happen?!?!?!?</p>
<div class = "transactionButton" onclick = "cancel('Choice_19B_Failure')">Okay</div>
</div>

<div id = "Choice_20" class = "decisiontext">
<h3>Iron Car</h3>
<p>Universal Wheels has just been selected to appear on an episode of Fox's new TV series Iron Car. The show features cars performing death-defying stunts, and showing off their 
capabilities. Though some have criticsed the show as being little more than an hour long car commercial, others have taken an interest in watching the stunts, and are regularly tuning in each 
Wednesday night. For your challenge, you need to design a full-sized car that can be controlled by a remote controll. The car will drive out of an airplane, and then parachute down to safety. After this, it
will drive up a ramp and jump over a canyon. For it's last stunt, the car will drive up a final ramp and go through a flaming hoop before coming to a stop in front of the judges. The car that peforms the challenge the fastest
(without being destroyed) will be declared the winner of the "Iron Car Award." How would you like to approach this challenge?</p>
<p>A. Design a big car capable of withstanding big impacts (-$60,000)</p>
<p>B. Design a small car capable of making big jumps ($60,000)</p>
<div class = "rectangleButton" onclick = "decisionPost(20, 'A')">Build the Big Car</div>
<div class = "rectangleButton" onclick = "decisionPost(20, 'B')">Build the Small Car</div>
</div>

<div id = "Choice_20A_Success" class = "decisiontext">
<h3>Blasting Through</h3>
<p>On the day of the challenge, your pickup truck used its 150 foot wide parachute to safely land next to the canyon. It followed this up by jumping over the canyon. Lastly,
it went through the flaming loop and landed on the other side. The force of landing knocked the rear bumper off the car, but the car stayed otherwsie intact. Since your car
was the only one to finish the challenge at all, Universal Wheels took home the Iron Car trophy! You can be sure that this publicity will translate to a lot of new customers
for Universal Wheels!</p>
<div class = "transactionButton" onclick = "cancel('Choice_20A_Success')">Okay</div>
</div>

<div id = "Choice_20B_Success" class = "decisiontext">
<h3>Floating Through</h3>
<p>On the day of the challenge, your lightweight car used its 50 foot wide parachute to gently float down to safety on the ground. From there, it was able to cross the canyon
and make it through the flaming loop without a scratch on it. All of the other cars were destroyed when they parachuted in, as their parachute could not support the car's weight.
As the only company to succesfully to complete the challenege, Universal Wheels took home the Iron Car trophy. You can be sure that this publicity will translate to a lot of new
customers for Universal Wheels!</p>
<div class = "transactionButton" onclick = "cancel('Choice_20B_Success')">Okay</div>
</div>

<div id = "Choice_20A_Failure" class = "decisiontext">
<h3>Blown to Bits</h3>
<p>On the day of the challenge, your car fell out of the airplane, and fell, and fell some more, until it eventually crash landed on the ground and was destroyed on impact.
It would seem that your car was a bit too bulky to be supported by its parachute. If its any consolation, only one of the companies was able to complete the challenge, and how
many people really watch Wednesday night television anyways?</p>
<div class = "transactionButton" onclick = "cancel('Choice_20A_Failure')">Okay</div>
</div>

<div id = "Choice_20B_Failure" class = "decisiontext">
<h3>Crumpled</h3>
<p>On the day of the challenge, your car was able to make a safe landing from the airplane. However, when it landed from jumping over the canyon, the rear axle of the car was destroyed from the impact
of the landing. Unfortunately, your car just wasn't durable enough to withstand all the impacts it needed to be able to endure to win the Iron Car Challenege. But don't be too upset. It's not like
anybody watches Wednesday night TV anyways!</p>
<div class = "transactionButton" onclick = "cancel('Choice_20B_Failure')">Okay</div>
</div>

<div id = "Choice_21" class = "decisiontext">
<h3>Ramming into the Competition</h3>
<p>Ram has taken the car industry by storm with the new Ram H120. This pickup truck is able to climb up hills that are over 28 degrees steep, and can move through mud
just as easily as it can travel on the road. A lot of companies are scrambling now to make their own pickup truck to compete with Ram, to stop them from fully dominating the market.
What do you think? Should Universal Wheels start desigining a more powerful pickup truck to compete with Ram? Or would it be unlikely that your customers would be interested in buying it?</p>
<p>A. Build the Truck (-$30,000)</p>
<p>B. Do Nothing (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(21, 'A')">Build the Truck</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(21, 'B')">Do Nothing</div>
</div>


<div id = "Choice_21A_Success" class = "decisiontext">
<h3>Anytime, Anywhere</h3>
<p>Introducing the new Universal B17 Driver! This vehicle is built like a tank, and can climb up 30 degree steep hills, and even has a propulsion system attached to the back bumper so that it can
move through water. With this car, you're prepared for anything! Get them now, because we're selling out of them quickly!</p>
<div class = "transactionButton" onclick = "cancel('Choice_21A_Success')">Okay</div>
</div>

<div id = "Choice_21B_Success" class = "decisiontext">
<h3>Feeling the Pulse of the Crowd</h3>
<p>Generally speaking, most of your customers don't need to drive up a mountain and then down through a swamp in order to get to work each day. Most of them just take I-80 for about
30 minutes and then arrive. No need to waste time designing a car that you can't sell.</p>
<div class = "transactionButton" onclick = "cancel('Choice_21B_Success')">Okay</div>
</div>

<div id = "Choice_21A_Failure" class = "decisiontext">
<h3>Left Behind in the Mud</h3>
<p>Though you mad a valient effort to build a more powerful car, you were unable to break Ram's domination of the market. The main issue was that not enough of your customers were
interested in buying your pickup truck for you to really have any chance of competing with the big pickup truck companies. Well, at least you know this information for the future!</p>
<div class = "transactionButton" onclick = "cancel('Choice_21A_Failure')">Okay</div>
</div>

<div id = "Choice_21B_Failure" class = "decisiontext">
<h3>Through Sludge and High Water</h3>
<p>Ram is breaking your back in sales this quarter. Though your customers like your high-quality products, your lack of a good alternative to Ram's pickup truck has made
your customers who need pickup trucks turn to Ram. Unfortunately, these pickup truck owners comprise a majority of your clientelle. At least you know this information for next time!</p>
<div class = "transactionButton" onclick = "cancel('Choice_21B_Failure')">Okay</div>
</div>

<div id = "Choice_22" class = "decisiontext">
<h3>Moving On Up</h3>
<p>Uncle Arty's Moving Company is really on the up and up. They've already become the biggest moving company in Arizona, California, and Texas, and they're rapidly making a push Eastwards.
Uncle Arty himself has recently approached you asking if Universal Wheels can manufacture moving trucks for his company. At the same time, Move Masters, the
powerful company based out of Indiana has also approached you asking if they can partner up with your company to manufacture moving trucks in order to help with the company's westward push. Since the two businesses are competing for the same
locations in the center of the country, they will only work with you if you don't work for the other company. Who would you like to sign with?</p>
<p>A. Make a Deal with Arty (-$70,000 for manufacturing costs)</p>
<p>B. Make a Deal with Move Masters (-$70,000 for manufacturing costs)</p>
<div class = "rectangleButton" onclick = "decisionPost(22, 'A')">Partner With Arty</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(22, 'B')">Partner with Move Masters</div>
</div>

<div id = "Choice_22A_Success" class = "decisiontext">
<h3>The Heartland</h3>
<p>Arty's new desert-tough moving trucks have allowed them to open up a surge of new locations throughout the great plains and the midwest. In fact, Arty's has expanded so much that 
they're even starting to encroach on territory in Move Master's home state of Indiana (embarressing as that is). It looks like you picked the right horse in this race.</p>
<div class = "transactionButton" onclick = "cancel('Choice_22A_Success')">Okay</div>
</div>

<div id = "Choice_22B_Success" class = "decisiontext">
<h3>To Arizona!</h3>
<p>Arty's Empire is beggining to buckle under the weight of Move Master's rapid expansion. Move Master's has already seized control of most of the market in Oklahoma and Texas, and is starting
to make a push into Uncle Arty's homestate of Arizona. It looks like you picked the right horse in this race!</p>
<div class = "transactionButton" onclick = "cancel('Choice_22B_Success')">Okay</div>
</div>

<div id = "Choice_22A_Failure" class = "decisiontext">
<h3>Dust In the Wind</h3>
<p>It would seem your company was not very experienced at manufacturing trucks for desert travel. The sand from the desert has left many an Arty's moving truck stalled on the side of the road,
with angry families wondering where their furniture went. Forget about expansion. Arty's is now being pushed out of their own state by Move Masters, since nobody wants to hire a company
who can't guarantee that their furniture will arrive on time. I guess this wasn't your best business decision...</p>
<div class = "transactionButton" onclick = "cancel('Choice_22A_Failure')">Okay</div>
</div>

<div id = "Choice_22B_Failure" class = "decisiontext">
<h3>Stuck In The Snow</h3>
<p>It would seem that your company was not very experienced at manufacturing trucks for winter road conditions. The ice and snow of the midwest and North East has left your Move Master
trucks scattered across the roads, derailed and waiting for a tow truck. Arty's is now knocking at your front door, since nobody wants to hire a company to move their furniture that
can't drive in a snowstorm. I guess this wasn't your best business decision...</p>
<div class = "transactionButton" onclick = "cancel('Choice_22B_Failure')">Okay</div>
</div>

<div id = "Choice_23" class = "decisiontext">
<h3>Universal Trains</h3>
<p>In the recent months, you've noticed that Amtrack has been extremely unreliable in transporting metal from metal processing plants to your factories. Their trains often get stuck, or will
inexcliably stall along the railroad tracks for several hours at a time. After thinking about this issue for a long time, you realize that Universal Wheels could build their own train for the purpose of
transporting materials. That way, you could cut out the middleman, and be in direct control of your supply lines. Of course, trains don't come cheap, so this decision would cost you a pretty penny. What do you think?
Is it worth it to spend a sizeable amount of money to ensure that your factories always have the materials they need to continue manufacutring?</p>
<p>A. Build The Train (-$200,000)</p>
<p>B. Keep using Amtrack (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(23, 'A')">Build the Train</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(23, 'B')">Keep Using Amtrack</div>
</div>

<div id = "Choice_23A_Success" class = "decisiontext">
<h3>Rolling into Business</h3>
<p>Factory output is up by 150% ever since you built your own train to transport materials. In fact, business is doing so well that your competitors are even starting to slip behind you ever so slightly,
fading off into your rear view mirror. If you keep making good business decisions like this, then I'm sure you'll have no trouble becoming the most powerful car company in the country.</p>
<div class = "transactionButton" onclick = "cancel('Choice_23A_Success')">Okay</div>
</div>

<div id = "Choice_23B_Success" class = "decisiontext">
<h3>I'm Willing to Wait For It</h3>
<p>While it's tempting to just build your own train and be done with it, you know that the costs of manufacturing a train would exceed the amount of extra money you would earn from manufacturing output.
For now, you decide to just suck it up and hope that Amtrack gets better over time. You only have so much cash, so it's important to make sure you're spending your money in the right places!</p>
<div class = "transactionButton" onclick = "cancel('Choice_23B_Success')">Okay</div>
</div>

<div id = "Choice_23A_Failure" class = "decisiontext">
<h3>Building Bridges You Don't Need</h3>
<p>Your train has improved the reliability of your factory's manufacturing. However, the large cost of building a train probably didn't do much to offset the small gain
in revenue from increased factory output, since you were already producing about as many cars as people were buying from you. Nevertheless, its possible that if demand increases at a future point, then 
this decision may turn out to be a good idea! We'll just have to wait and see.</p>
<div class = "transactionButton" onclick = "cancel('Choice_23A_Failure')">Okay</div>
</div>

<div id = "Choice_23B_Failure" class = "decisiontext">
<h3>Derailed</h3>
<p>Train service continues to remain inefficient and ineffective to your factories. Some car stores throughout the country are starting to sell out of your cars because demand for them
is exceeding the amount that you can produce, even though you could be producing more if you could receive your materials on time. You have no choice but to watch with frustration as other companies
who have more cars available leap frog over you in sales this quarter. Curse you Amtrack!!!!!!!</p>
<div class = "transactionButton" onclick = "cancel('Choice_23B_Failure')">Okay</div>
</div>

<div id = "Choice_24" class = "decisiontext">
<h3>America's Car</h3>
<p>After much effort, your company's marketing team was finally able to negotiate a deal with Dallas Cowboys owner Jerry Jones to launch a series of TV ads saying that Universal Wheels
is the "official vehicle of the Dallas Cowboys." This ad will begin airing during NFL games, starting with next Sunday's intense showdown between the Philadelphia Eagles and the Cowboys,
which in all liklihood will determine who wins the NFC East. Would you like to sign the contract?</p>
<p>A: Choice A: Sign the Contract ($-400,000)</p>
<p>B. Choice B. Don't Sign the Contract (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(24, 'A')">Sign the Contract</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(24, 'B')">Don't Sign the Contract</div>
</div> 

<div id = "Choice_24A_Success" class = "decisiontext">
<h3>Rolling with the 'Boys</h3>
<p>Its amazing how increasing recognition of your brand can make such a huge difference in sales! Business has been booming in the days following the game, with an especially big increase in sales in Texas.
Also, since the Cowboys defeated the Eagles, the cowboys are sure to attract an even larger audience for their next game, which means more viewers will see your ads! Great work!</p>
<div class = "transactionButton" onclick = "cancel('Choice_24A_Success')">Okay</div>
</div>

<div id = "Choice_24B_Success" class = "decisiontext">
<h3>Playing it Safe</h3>
<p>You think about the decision more, and then decide that you don't really have much of a crowd in the Dallas/general Texas area, so you'd best not affiliate with such
a love/hate team as the cowboys are. Business continues to grow steadily after the Eagles win on Sunday. No harm, no foul.</p>
<div class = "transactionButton" onclick = "cancel('Choice_24B_Success')">Okay</div>
</div>

<div id = "Choice_24A_Failure" class = "decisiontext">
<h3>Fly, Eagles Fly</h3>
<p>Whether consciously or not, your decision seems to have really alienated a lot of fans in Pennsylvania. Sales for your company's cars are way down through the whole D.C.-New York region,
and the increase in sales in Texas has been modest at best. Nevertheless, all publicity is good publicity for business, so given enough time, you should still see a noticeable increase
in sales nationwide.</p>
<div class = "transactionButton" onclick = "cancel('Choice_24A_Failure')">Okay</div>
</div>

<div id = "Choice_24B_Failure" class = "decisiontext">
<h3>Cowboy Nation</h3>
<p>Jerry Jones was really annoyed that you wasted his time negotiating a contract but then chickened out at the last second. Instead, Jerry Jones signed a deal with Toyota to be the official
car of the Cowboys, which has led to a noticeable surge in the sale of Toyota's cars. It looks like you got sacked on this decision.</p>
<div class = "transactionButton" onclick = "cancel('Choice_24B_Failure')">Okay</div>
</div>

<div id = "Choice_25" class = "decisiontext">
<h3>What Would You Do?</h3>
<p>Late in the testing of one of your new car models, you discover that about one in a million of your cars have a defect that prevents the car's airbags from deploying. Your company's
statisticians tell you that there's a 0.3 % chance that anybody will ever be affected by this design flaw, but that if you try to search through all the cars to weed out the flawed ones
(or scrap all the cars you've made so far) than it will cost you at least $500,000. It's your call. Do you want to put the cars on the market as is, or scrap the new Asidian car model you've made
and start building a new batch of cars from scratch?</p>
<p>A. Start Over (-$500,000)</p>
<p>B. Sell the Cars As Is (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(25, 'A')">Start Over</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(25, 'B')">Don't Make Any Changes</div>
</div>

<div id = "Choice_25A_Success" class = "decisiontext">
<h3>Keeping Up With the Crowd</h3>
<p>Well, it was a lot of work, but you finally managed to replace all of the new cars you made with a newer car model without the defect. It may have cost a lot of money,
but you can rest assured that all of your customers are safe, and you aren't gambling with the future of your company.</p>
<div class = "transactionButton" onclick = "cancel('Choice_25A_Success')">Okay</div>
</div>

<div id = "Choice_25B_Success" class = "decisiontext">
<h3>So Far so Good...</h3>
<p>As of yet, nobody has complained about your cars airbag defects. It would appear that it's gone unnoticed... for now!</p>
<div class = "transactionButton" onclick = "cancel('Choice_25B_Success')">Okay</div>
</div>

<div id = "Choice_25A_Failure" class = "decisiontext">
 <h3>Keeping Up With the Crowd</h3>
<p>Well, it was a lot of work, but you finally managed to replace all of the new cars you made with a newer car model without the defect. It may have cost a lot of money,
but you can rest assured that all of your customers are safe, and you aren't gambling with the future of your company.</p>
<div class = "transactionButton" onclick = "cancel('Choice_25A_Failure')">Okay</div>
</div>


<div id = "Choice_25B_Failure" class = "decisiontext">
<h3>Actions Have Consequences</h3>
<p>Last Friday night, a couple was driving home from dinner, when they were struck and killed by another driver. Police at the scene noticed that the airbags did not deploy in their
Universal Wheels Asidian Car, despite having been installed correctly. This prompted a massive media investigation, which unearthed the startling revelation that your company knew about
the flaw in the cars, but chose to release them anyways. The media is saying you put money over family's lives, and several high profile politicians are calling for your resignation as
CEO of Universal Wheels. Furthermore, you have had to recall all Asidian car models, which has caused your revenue for the year to plummet, and you haven't even begun to see how sales
will be affected by this negative press. If you can avoid going bankrupt for the next month, you should count yourself lucky.</p>
<div class = "transactionButton" onclick = "cancel('Choice_25B_Failure')">Okay</div>
</div>

<div id = "Choice_26" class = "decisiontext">
<h3>Find A Way or Make A Way</h3>
<p>It's hard to compete against other companies when all of your products cost more than theirs. Universal Wheels has tried to cut costs, but the high costs of manufacturing
in the states leaves you unable to compete with companies who produce their cars in cheap factories in China. Your least valuable plant is currently costing the company on average $20,000
per month to keep a float, which has been a persistent drain on your profits. Yesterday, you received an offer from the Eastern Sun Factory Liason Corporation. They have offered to sell
you a car factory (which is no longer being used by its original owner) in Shaanxi province, China. This leaves you with a viable way to replace your ailing American factory, although
closing it would also put 5,000 people out of work. What would you like to do?</p>
<p>A. Stick with America (-$0)</p>
<p>B. Outsource to China (-$150,000)
<div class = "rectangleButton" onclick = "decisionPost(26, 'A')">Made in America</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(26, 'B')">Made in China</div>
</div>

<div id = "Choice_26A_Success" class = "decisiontext">
<h3>American Born, American Raised</h3>
<p>You will not betray your factory workers by moving their jobs overseas! Your management team redoubles their efforts to make the struggling factory cost-effective. In the end,
they manage to find a way to get the factory so that it is slightly profitable. Every little improvmenet counts! And your workers are greatful that you have kept their jobs. Furthermore,
unlike the other big car companies, you can have the big Made in America sticker on each of your cars, which is sure to attract many patriotic customers.</p>
<div class = "transactionButton" onclick = "cancel('Choice_26A_Success')">Okay</div>
</div>

<div id = "Choice_26B_Success" class = "decisiontext">
<h3>The Jewel of the East</h3>
<p>Fortunately, you were able to keep the opening of your Chinese factory a secret from your employees at the closing plant. They were still upset, but didn't receive anywhere near as much
media attention as they would if it was discovered that you had shipped their jobs overseas. Meanwhile, your chinese factory has turned out to be incredibly lucrative. The factory costs half the cost
to operate as a similary sized American factory would, and produces 30% more output. You're competing with the big dogs of the industry now, so expect profits to rise in the next few weeks.</p>
<div class = "transactionButton" onclick = "cancel('Choice_26B_Success')">Okay</div>
</div>

<div id = "Choice_26A_Failure" class = "decisiontext">
<h3>"My only regret is that I have but one life to give for my country"</h3>
<p>This company was born in America, and in America it will stay! Your company gets a lot of positive press for their decision to keep their ailing American factory open and
to not outsource factory jobs to China. Nevertheless, profits at the plant haven't improved much, and its still causing you a net loss each month. At least your company can
pridefully put a Made in America sticker on each of their cars. That will be sure to attract a lot of patriotic customers to Universal Wheels!</p>
<div class = "transactionButton" onclick = "cancel('Choice_26A_Failure')">Okay</div>
</div>

<div id = "Choice_26B_Failure" class = "decisiontext">
<h3>Betrayl</h3>
<p>Your company's decision has caused an uproar among your workers. The media has also been heavily critizing the move to China, with many calling it a betrayl of your workers. Although
your public image may have taken a hit from this, your company has been doing a lot better financially this month. Production is way up and costs are much lower. It's still not quite clear
how this decision will affect your company's profits in the weeks to come. Only time can tell...</p>
<div class = "transactionButton" onclick = "cancel('Choice_26B_Failure')">Okay</div>
</div>


<div id = "Choice_27" class = "decisiontext">
<h3>A Green Touch</h3>
<p>An EPA inspector has recently observed your factories, and has found that the amount of carbon dioxide that they are emitting is above the quotas set by the Clean Air Act of 1970.
Your company will have to pay significant legal fees as punishment for exceeding their pollution allowances. However, the EPA inspector has told you that you may be able to work something
out with him, whereby he wouldn't have to report his findings to the EPA, and could give you a passing rating. This would come in exchange for a fee. The offer is tempting, but would you really
want to be seen by the public accepting bribes? What do you say in response to the offer?</p>
<p>A. "I'll pay the EPA fine." (-$300,000)</p>
<p>B. "Forget about the EPA. We can keep this our little secret!" (-$50,000)</p>
<div class = "rectangleButton" onclick = "decisionPost(27, 'A')">Pay the EPA Fine</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(27, 'B')">Pay the Bribe</div>
</div>

<div id = "Choice_27A_Success" class = "decisiontext">
<h3>Triumph</h3>
<p>Disgusted by what you've just seen, you immediately call up the EPA's department of corporate responsibility to report that one of their employeed just attempted to solicit a bribe from you.
The EPA acts quickly, firing the rouge employee within two days, and within a week, he is facing federal charges of conspiracy to commit bribery. The public has taken note of your upright and moral
stance against corruption, which has resulted in a noticeable improvement to your public image.</p>
<div class = "transactionButton" onclick = "cancel('Choice_27A_Success')">Okay</div>
</div>

<div id = "Choice_27B_Success" class = "decisiontext">
<h3>What They Don't Know, Won't Hurt Them!</h3>
<p>You slip a wad of cash into the palm of the corrupt EPA official's hand. "Well then, " the official begins " it looks like Universal Wheels stayed inside its emissions quota for the year. Good work!"
He smirks as he walks away. Nobody has found out about what happened, so for the time being, it looks like you're in the clear. In the meantime, lower your emissions levels to prevent a situation like
this from ever happening again!</p>
<div class = "transactionButton" onclick = "cancel('Choice_27B_Success')">Okay</div>
</div>

<div id = "Choice_27A_Failure" class = "decisiontext">
<h3>Holding Back</h3>
<p>You would like to just pay the official off and be done with it, but you know that you can't risk the PR disaster that would happen if anyone ever found out about what you did.
As such, you suck it up and pay the hefty EPA fine. It hurts your profit for the year by a sizeable amount, but it's not worth risking losing everything you've worked so hard to build
at your time as the CEO of Universal Wheels.</p>
<div class = "transactionButton" onclick = "cancel('Choice_27A_Failure')">Okay</div>
</div>

<div id = "Choice_27B_Failure" class = "decisiontext">
<h3>Game Over</h3>
<p>You have a shaky feeling in your stomach, but you don't want to risk having an unprofitable quarter after paying off the EPA, and having to sell back one of your properties as a result.
You hand the EPA official the money. "Now get out of here," you whisper quietly. The EPA official smiles as he trots away. Next week, you look out the window of your bedroom and see a flurry of news vehicles
and helicopters swirling around your house. It turns out that the EPA official got drunk and told one of his coworkers about his daring money-making venture. You frantically call your lawyer, who informs you that
you are at risk of serving up to 2 years in federal prison for corruption of a public official. Your heart sinks. You push past the media trucks to get to work. When you arrive, you are told by your vice president
that the board of trustees has voted to remove you as the CEO of the company effective immediately. You are disconsolate. It just goes to show, corruption never pays!</p>
<div class = "transactionButton" onclick = "decisionGameOver()">I Understand</div>
</div>

<div id = "Choice_28" class = "decisiontext">
<h3>Rose Plaza</h3>
<p>Rose Plaza, the new high end luxuary mall being developed in Washington D.C. is nearing completion. After hearing of your company's interest in expanding into the D.C. market, Sam Platsberg, the owner
of Rose Plaza, has offered to let you construct your own luxuary car shop inside the mall. This could be a huge money making venture for your company, so you're going to have to pay at least $750,000 to build the shop.
How would you like to proceed?</p>
<p>A. Build the Car Shop (-$750,000)</p>
<p>B. Decline the Offer (-$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(28, 'A')">Build the Shop</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(28, 'B')">Decline the Offer</div>
</div>

<div id = "Choice_28A_Success" class = "decisiontext">
<h3>In Bloom</h3>
<p>Your Rose Plaza business has really blossomed into a beautiful new location. Tourists from around the world flock to Rose Gardens, and gaze in awe at your 20 foot tall fountain and siliver rimmed cars as they eat their cinnabons.
It's all smooth sailing from here!</p>
<div class = "transactionButton" onclick = "cancel('Choice_28A_Success')">Okay</div>
</div>

<div id = "Choice_28B_Success" class = "decisiontext">
<h3>Late Bloomer</h3>
<p>Tempting as it may be, your company just can't afford to spend money so recklessly as to build an over the top luxuary car shop. While choosing to do nothing isn't a flashy decision that will bring customers toy our door,
you have managed to gain the favor of your stock holders, who were hoping you wouldn't sign the contract. Investment in your business has gone up over the last 2 weeks, which may be more helpful to business than the luxuary
car store would have been anwyways.</p>
<div class = "transactionButton" onclick = "cancel('Choice_28B_Success')">Okay</div>
</div>

<div id = "Choice_28A_Failure" class = "decisiontext">
<h3>Wilting</h3>
<p>Your Rose Plaza location has managed to attract a large number of tourists and interested car customers to visit your shop, but it has not been enough to offset the financial bombshell
of the amount of money you had to invest to open the place. Your investors seem to agree, and stock prices in your company have dropped by 5 % in the last month. Hopefully, if you play your cards right,
your business can rebound from this, and can turn Rose Plaza into a store of growth and renewal.</p>
<div class = "transactionButton" onclick = "cancel('Choice_28A_Failure')">Okay</div>
</div>

<div id = "Choice_28B_Failure" class = "decisiontext">
<h3>In Need of a Thaw</h3>
<p>D.C. sales of Universal Wheels cars have been down ever since Rose Plaza opened its doors. The few car businesses who did decide to open up shop in Rose Plaza have seen a tremendous increase in publicity,
which has made it a lot harder to attract costumers to your store. However, the stores at Rose Garden have tremendous tax rates, so you may ultimately end up getting the last laugh over your
fiscally irresponsible competitors.</p>
<div class = "transactionButton" onclick = "cancel('Choice_28B_Failure')">Okay</div>
</div>

<div id = "Choice_29" class = "decisiontext">
<h3>Buldozing the Competition</h3>
<p>The fastest growing automobile market for the year has been construction vehicles. However, since Universal Wheels does not produce any construction vehicles, you have
been unable to capitalize on this trend. You could however choose to start constructing and selling construction vehicles at your stores around the country. You just have to make
sure that your stores are located in areas that are likely to have a growing need for construction!</p>
<p>A. Build a Line of Construction Vehicles (-$300,000)</p>
<p>B. Do Nothing ($-0)</p>
<div class = "rectangleButton" onclick = "decisionPost(29, 'A')">Build the Vehicles</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(29, 'B')">Do Nothing</div>
</div>

<div id = "Choice_29A_Success" class = "decisiontext">
<h3>Steamrolling Ahead!</h3>
<p>Your new line of construction vehicles has been selling out of stores coast to coast! It seems like construction companies can't purchase your cement trucks, buldozers, and steamrollers as
fast as you can make them. This is going to be one smooth quarter coming up!</p>
<div class = "transactionButton" onclick = "cancel('Choice_29A_Success')">Okay</div>
</div>

<div id = "Choice_29B_Success" class = "decisiontext">
<h3>Know Your Audience</h3>
<p>While it may be tempting to spice things up and try a new thing, you know your customers, and you know that there isn't much demand among your customers for heavy-duty
construction vehicles. It's for the best that you didn't try to force anything anyways, since the growth of the construction vehicle industry has stalled, with many claiming
that the bubble for the industry has burst. It's a good thing that Universal Wheels didn't end up popping!</p>
<div class = "transactionButton" onclick = "cancel('Choice_29B_Success')">Okay</div>
</div>

<div id = "Choice_29A_Failure" class = "decisiontext">
<h3>Rolled Over</h3>
<p>Your entry into the construction business has not been as lucrative as you initially hoped. Demand for construction vehicles in urbanized metropilitan areas as nowhere near as high as it is in
rural areas, and without a large enough base of rural costumers, you are unable to sell very many of your construction vehicles except on rare occasions to large construction congolomerates
who want a few spare buldozers. What a tough break!</p>
<div class = "transactionButton" onclick = "cancel('Choice_29A_Failure')">Okay</div>
</div>

<div id = "Choice_29B_Failure" class = "decisiontext">
<h3>Missing Your Ride</h3>
<p>The construction market has continued to steadily grow over the last few months, but your company has not been a part of this growth. For now, you can only look on from the
sidelines as other, faster companies capitalize on the high demand for construction vehicles. Well, you can't win 'em all!</p>
<div class = "transactionButton" onclick = "cancel('Choice_29B_Failure')">Okay</div>
</div>

<div id = "Choice_30" class = "decisiontext">
<h3>Defending Your Business!</h3>
<p>Seeing the durability of your pickup trucks in the South West desert, the Department of Defense has approached you asking if you can help produce tanks for the US military.
This is a big responsibility. People's lives will be on the line if you do a bad job designing the tanks. Would you like to serve your country, and enter into the
military vehicles market?</p>
<p>A. Sign a Contract with the Department of Defense (+$350,000 from the military for the tanks)</p>
<p>B. Politely Decline the Offer (+$0)</p>
<div class = "rectangleButton" onclick = "decisionPost(30, 'A')">Sign the Contract</div>
<div class = "rectangleButton" style = "float: right;" onclick = "decisionPost(30, 'B')">Decline the Offer</div>
</div>

<div id = "Choice_30A_Success" class = "decisiontext">
<h3>Blasting Away the Competition</h3>
<p>Your Universal Wheel's tanks are a hit with the army! All the experience that your engineers have had over the years designing cars and trucks has prepared them for this
moment, and boy did they come through big. Universal Wheel's is quickly on pace to become the biggest tank supplier to the US army, owing in part to the tank's durability
speed and versatility. Nicely done!</p>
<div class = "transactionButton" onclick = "cancel('Choice_30A_Success')">Okay</div>
</div>

<div id = "Choice_30B_Success" class = "decisiontext">
<h3>The Best Offence is a Good Defence</h3>
<p>Though the deal is tempting, you don't want to risk your company putting out a subpar tank for use by the military. You decide to just play it safe and keep selling
to your customers back home. When your company gains more manufacturing experience, then you can start creating military vehicles.</p>
<div class = "transactionButton" onclick = "cancel('Choice_30B_Success')">Okay</div>
</div>

<div id = "Choice_30A_Failure" class = "decisiontext">
<h3>Friendly Fire</h3>
<p>The contract you've signed with the defense department may have added a steady source of income to your company's weekly earnings, but it may have had some unintended
consequences on the home front. Many of your customers feel uncomftorable supporting a company who also creates weapons, and some have even accused your company of being
an agent of the military-industrial complex, seeking to profit off of war. Hopefuly, the increase in sales from your decision will offset any potential loss in cutomers
due to the contract.</p>
<div class = "transactionButton" onclick = "cancel('Choice_30A_Failure')">Okay</div>
</div>

<div id = "Choice_30B_Failure" class = "decisiontext">
<h3>Hiding in the Trenches</h3>
<p>For the next few months, you can't help but watch as other military vehicle companies see tremendous periods of growth and development. Meanwhile, Universal Wheels seems to have
expanded as much as it can in the States, and your profits and expenses have started to equalize, resulting in stagnation. You've guided this company through thick and thin, through the mountains
and the valleys, so you should be able to find some way to pull Universal Wheels back out of this rut.</p>
<div class = "transactionButton" onclick = "cancel('Choice_30B_Failure')">Okay</div>
</div>

<!-- Broke window is displayed when a user tries to purchase a location but has insufficient funds -->
		<div id = "Broke">Sorry! You don't have enough money to buy this.
				<div onclick = "cancel('Broke')" class = "cancelButton" style = "margin-left: 7vw; margin-top: 0.91vw; float: none;">Okay</div>
			</div>
	
	<!-- Success window is displayed when a user succcesfully purchases a location -->
			<div id = "Success">Congratulations on your new purchase!
				<div onclick = "cancel('Success')" class = "cancelButton" style = "margin-left: 7vw; float:none; margin-top: 0.91vw;">Continue</div>
			</div>
	
	<!-- Sold window is displayed when a user sells one of their properties -->
			<div id = "Sold">Congratulations on selling back your property!
				<div onclick = "cancel('Sold')" class = "cancelButton" style = "margin-left: 7vw; margin-top: 0.91vw; float: none;">Continue</div>
			</div>
		
		<!-- The WestchesterWindow contains the map of Westchester County, which forms the setting for the game's first level -->
		<div class = "WestchesterWindow">
		<img src = "images/Westchester.jpg" alt = "Westchester" style = "width: 75vw; height: 50vw;">
		<div class = "mapButton" onclick = "loadNY()">New York Map</div>
		<div class = "databaseButton" onclick = "databasePageLoad('WestchesterWindow')">See all Businesses</div>
		
		<!-- Each Map window has its own statBox div inside of it, where the amount of money Universal Wheels owns and how many in-game days have passed since
		the game started are listed -->
		
		<div class = "statBox">
				<div class = "purchaseClass" id ="PurchaseID1"></div>
				<div class = "timeBox" id = "Timer1"></div>
			</div>
		
				<!-- The following 20 divs control where dots and squares are outputted on the map of Westchester. the onclick attribute of each div is
				set such that clicking on the icon calls the openDescription fucntion, which will load a certain description (based on which dot or square
				the user clicked on  -->
				
		<div onmouseover = "flip_on_mouseover('Ardsley_Dot', true)" onmouseout = "flip_on_mouseout('Ardsley', true)" onclick = "openDescription('Ardsley', 'Store', 'Universal Wheels', '15000', '65000', '35000')" class = "dot Ardsley_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Armonk_Square', false)" onmouseout = "flip_on_mouseout('Armonk', false)" onclick = "openDescription('Armonk', 'Factory', 'Universal Wheels', 12000, 150000, 130000, 'Westchester')" class = "square Armonk_Square"></div>
		<div onmouseover = "flip_on_mouseover('Bedford_Square', false)" onmouseout = "flip_on_mouseout('Bedford', false)" onclick = "openDescription('Bedford', 'Factory', 'Universal Wheels', 3500, 28000, 14000, 'Westchester')" class = "square Bedford_Square"></div>
		<div onmouseover = "flip_on_mouseover('Elmsford_Square', false)" onmouseout = "flip_on_mouseout('Elmsford', false)" onclick = "openDescription('Elmsford', 'Factory', 'Universal Wheels', '7500', '170000', '120000')" class = "square Elmsford_Square"></div>
		<div onmouseover = "flip_on_mouseover('Mamaroneck_Dot', true)" onmouseout = "flip_on_mouseout('Mamaroneck', true)" onclick = "openDescription('Mamaroneck', 'Store', 'Universal Wheels', 600, 15000, 12000, 'Westchester')" class = "dot Mamaroneck_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Mohegan_Lake_Square', false)" onmouseout = "flip_on_mouseout('Mohegan_Lake', false)" onclick = "openDescription('Mohegan_Lake', 'Factory', 'Universal Wheels', 180, 35000, 20000, 'Westchester')" class = "square Mohegan_Lake_Square"></div>
		<div onmouseover = "flip_on_mouseover('Mount_Vernon_Dot', true)" onmouseout = "flip_on_mouseout('Mount_Vernon', true)" onclick = "openDescription('Mount_Vernon', 'Store', 'Universal Wheels', 300, 10000, 1000, 'Westchester')" class = "dot Mount_Vernon_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Mt_Kisco_Dot', true)" onmouseout = "flip_on_mouseout('Mt_Kisco', true)" onclick = "openDescription('Mt_Kisco', 'Store', 'Universal Wheels', 600, 120000, 90000, 'Westchester')" class = "dot Mt_Kisco_Dot"></div>
		<div onmouseover = "flip_on_mouseover('New_Rochelle_Dot', true)" onmouseout = "flip_on_mouseout('New_Rochelle', true)" onclick = "openDescription('New_Rochelle', 'Store', 'Universal Wheels', 500, 50000, 30000, 'Westchester')" class = "dot New_Rochelle_Dot"></div>
		<div onmouseover = "flip_on_mouseover('North_Salem_Dot', true)" onmouseout = "flip_on_mouseout('North_Salem', true)" onclick = "openDescription('North_Salem', 'Store', 'Universal Wheels', 400, 10000, 5000, 'Westchester')" class = "dot North_Salem_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Ossining_Square', false)" onmouseout = "flip_on_mouseout('Ossining', false)" onclick = "openDescription('Ossining', 'Factory', 'Universal Wheels', 2000, 35000, 5000, 'Westchester')" class = "square Ossining_Square"></div>
		<div onmouseover = "flip_on_mouseover('Peekskill_Square', false)" onmouseout = "flip_on_mouseout('Peekskill', false)" onclick = "openDescription('Peekskill', 'Factory', 'Universal Wheels', 400, 20000, 10000, 'Westchester')" class = "square Peekskill_Square"></div>
		<div onmouseover = "flip_on_mouseover('Portchester_Dot', true)" onmouseout = "flip_on_mouseout('Portchester', true)" onclick = "openDescription('Portchester', 'Store', 'Universal Wheels', '50', '7000', '300', 'Westchester')" class = "dot Portchester_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Scarsdale_Dot', true)" onmouseout = "flip_on_mouseout('Scarsdale', true)" onclick = "openDescription('Scarsdale', 'Store', 'Universal Wheels', 15000, 180000, 140000, 'Westchester')" class = "dot Scarsdale_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Somers_Square', false)" onmouseout = "flip_on_mouseout('Somers', false)" onclick =  "openDescription('Somers', 'Factory', 'Universal Wheels', 800, 45000, 35000, 'Westchester')" class = "square Somers_Square"></div>
		<div onmouseover = "flip_on_mouseover('Tuckahoe_Dot', true)" onmouseout = "flip_on_mouseout('Tuckahoe', true)" onclick = "openDescription('Tuckahoe', 'Store', 'Universal Wheels', 1500, 40000, 20000, 'Westchester')" class = "dot Tuckahoe_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Valhalla_Dot', true)" onmouseout = "flip_on_mouseout('Valhalla', true)" onclick = "openDescription('Valhalla', 'Store', 'Universal Wheels', 2500, 40000, 25000, 'Westchester')" class = "dot Valhalla_Dot"></div>		
		<div onmouseover = "flip_on_mouseover('White_Plains_Dot', true)" onmouseout = "flip_on_mouseout('White_Plains', true)" onclick = "openDescription('White_Plains', 'Store', 'Universal Wheels', 900, 70000, 50000, 'Westchester')" class = "dot White_Plains_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Yonkers_Dot', true)" onmouseout = "flip_on_mouseout('Yonkers', true)" onclick = "openDescription('Yonkers', 'Store', 'Universal Wheels', '7000', '50000', '35000', 'Westchester')" class = "dot Yonkers_Dot"></div>
		<div onmouseover = "flip_on_mouseover('Yorktown_Dot', true)" onmouseout = "flip_on_mouseout('Yorktown', true)" onclick = "openDescription('Yorktown', 'Store', 'Universal Wheels', 500, 25000, 17000, 'Westchester')" class = "dot Yorktown_Dot"></div>
		
		<!-- Each location description is in the class tooltiptext. Additionally, each one lists the name of the location, an image for the location,
		and a brief description of the location. This is then followed by some attributes of the location (such as Tax). The Company_Status class is where
		openDescription outputs either the price of purchasing or the price of selling the store (depending on whether or not the user owns it).
		The transactionButton div is where openDescription sets the BuyItem() or SellItem() function to be called when the user clicks on it (based on
		whether or not the user owns that location). Additionally, openDescription decides which image to load for the description based on whether or not
		the user owns the location or not (if the user owns the location, the image with the suffix _Alt added to it is loaded instead) -->
		
		<div id = "Yonkers" class = "tooltiptext">
		<h3>Yonkers</h3>
		<img src = "images/Yonkers.jpg" alt = "Yonkers" style = "width: 23vw; height: 15vw; padding-left: 3.7vw;">
		<p>A cozy spot in downtown Yonkers. Sell tires and car accesories here, and use this spot as a stepping stone to expand out of Westchester county.</p>
		<p>Value: 3/5 Cost: 2/5 Tax: 4/5 Accesibility: 4/5</p> <p>Overall: 4/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Yonkers')" class = "cancelButton">Cancel</div>
		</div>
		
		
		
		<div id = "Elmsford" class = "tooltiptext">
		<h3>Elmsford</h3>
		<img src = "images/Elmsford.jpg" alt = "Elmsford" style = "width: 23vw; height: 15vw; padding-left: 3.8vw;">
		<p>A medium sized location with just enough space to maunfacture your very own cars! The perfect place to enter the car manufacting business!</p>
		<p>Value: 5/5 Cost: 4/5 Tax: 4/5 Accesibility: 5/5</p><p>Overall: 5/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Elmsford')" class = "cancelButton">Cancel</div>
		</div>
		
		
		
		<div id = "Ardsley" class = "tooltiptext">
		<h3>Ardsley</h3>
		<img src = "images/Ardsley.jpg" alt = "Ardsley" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>This abandoned auto-body shop provides the perfect location for opening your very own auto-body shop. Located smack-dab in the middle of downtown Ardsley, this
		place is sure to attract a lot of costumers!</p>
		<p>Value: 3/5 Cost: 2/5 Tax: 5/5 Accesibility: 5/5</p><p>Overall: 3/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>	
		<div onclick = "cancel('Ardsley')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Ossining" class = "tooltiptext">
		<h3>Ossining</h3>
		<img src = "images/Ossining.jpg" alt = "Ossining" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>Originally built in the 1830s, this brick and mortar building has remained unoccupied ever since it was leveled by hurricane Sandy. Bring life back to the building, and bring 
		your car manufacturing activities here.</p>
		<p>Value: 4/5 Cost: 2/5 Tax: 2/5 Accesibility: 4/5</p><p> Overall: 5/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Ossining')" class = "cancelButton">Cancel</div>
		</div>
	
		<div id = "Valhalla" class = "tooltiptext">
		<h3>Valhalla</h3>
		<img src = "images/Valhalla.jpg" alt = "Valhalla" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>I know, I know, it doesn't look like much. BUT, in the car business, looks aren't everything. This store is only 0.8 miles away
		from Westchester Community College. All the students needing repairs and inspections are right at your fingertips. And the best part is? The college is a commuter school!</p>
		<p>Value: 5/5 Cost: 3/5 Tax: 3/5 Accesibility: 5/5</p><p>Overall: 5/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Valhalla')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Armonk" class = "tooltiptext">
		<h3>Armonk</h3>
		<img src = "images/Armonk.jpg" alt = "Armonk" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>A vast, undeveloped parcel of land in northern Armonk awaits an entrapenaur to turn it into something great. Become that entrapeneur, and turn
		this vacant land into a car-making powerhouse!</p>
		<p>Value: 3/5 Cost: 5/5 Tax: 5/5 Accesibility: 2/5</p><p>Overall: 2/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>		
		<div onclick = "cancel('Armonk')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Bedford" class = "tooltiptext">
		<h3>Bedford</h3>
		<img src = "images/Bedford.jpg" alt = "Bedford" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>This factory finds itself at the intersection of the metro north rail lines and a sleepy small town to the north. It would make a nice outpost
		where you could manufacture tires and axels </p>
		<p>Value: 3/5 Cost: 2/5 Tax: 4/5 Accesibility: 3/5</p><p>Overall: 3/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Bedford')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Portchester" class = "tooltiptext">
			<h3>Portchester</h3>
			<img src = "images/Portchester.jpg" alt = "Portchester" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
			<p>This store may be a bit rundown, but Portchester's convenient location on the New York-Connecticuit border allows you the opportunity to introduce your business to those outside
			of New York. A great opportunity for expanding outside of Westchester!</p>
			<p>Value: 1/5 Cost: 1/5 Tax: 1/5 Accesibility: 3/5</p><p>Overall: 1/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('Portchester')" class = "cancelButton">Cancel</div>	
		</div>
	
		<div id = "White_Plains" class = "tooltiptext">
			<h3>White Plains</h3>
			<img src = "images/White_Plains.jpg" alt = "White Plains" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
			<p>Every good business needs an administrative center from which it can coordinate its actions. This office building provides the perfect
			location for you and your staff to plan logistical operations and answer questions from costumers on the phone</p>
			<p>Value: 4/5 Cost: 3/5 Tax: 3/5 Accesibility: 5/5 </p><p>Overall: 4/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('White_Plains')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Yorktown" class = "tooltiptext">
		<h3>Yorktown</h3>
		<img src = "images/Yorktown.jpg" alt = "Yorktown" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>This sunlit store finds itself located on the northernmost edge of westchester. It will be sure to attract a lot of costumers
		who plan to make the long drive to upstate New York!</p>
		<p>Value: 4/5 Cost: 2/5 Tax: 2/5 Accesibility: 1/5 </p><p>Overall: 3/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Yorktown')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Mt_Kisco" class = "tooltiptext">
		<h3> Mt Kisco</h3>
		<img src = "images/Mt_Kisco.jpg" alt = "Mt. Kisco" style = "width: 25vw; height: 15vw; padding-left: 3vw;">
		<p>The lush greenery of Mt. Kisco provides the perfect space to sell cars in. And with a view like this, who wouldn't want to shop here?</p>
		<p>Value: 4/5 Cost: 4/5 Tax: 2/5 Accesibility: 3/5 </p><p>Overall: 4/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Mt_Kisco')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "New_Rochelle" class = "tooltiptext">
		<h3>New Rochelle</h3>
		<img src = "images/New_Rochelle.jpg" alt = "New Rochelle" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>This cavernous car service shop finds itself located in the heart of downtown New Rochelle. Expect to see many out-of-towners
		stopping by to get their car inspected while they play glow in the dark mini golf at nearby new Roc City.</p>
		<p>Value: 3/5 Cost: 3/5 Tax: 1/5 Accesibility: 5/5 </p><p>Overall: 3/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('New_Rochelle')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Scarsdale" class = "tooltiptext">
		<h3>Scarsdale</h3>
		<img src = "images/Scarsdale.jpg" alt = "Scarsdale" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>Located on prime real estate on Central Avenue, this store is sure to get a lot of traffic. Now's your chance to sell
		a large volume of cars in a high priced area. Good luck! </p>
		<p>Value: 5/5 Cost: 4/5 Tax: 5/5 Accesibility: 5/5 </p><p>Overall: 5/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Scarsdale')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Somers" class = "tooltiptext">
		<h3>Somers</h3>
		<img src = "images/Somers.jpg" alt = "Somers" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>This building was first built in the 1820's, and was used as a local blacksmith shop. Now that the store is unoccupied, it would make
		the perfect location to make and sell hood ornaments. And the historic charm of the building is sure to attract many potential customers!</p>
		<p>Value: 4/5 Cost: 2/5 Tax: 2/5 Accesibility: 2/5 </p><p>Overall: 3/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Somers')" class = "cancelButton">Cancel</div>
		</div>
		
		
		<div id = "Peekskill" class = "tooltiptext">
		<h3>Peekskill</h3>
		<img src = "images/Peekskill.jpg" alt = "Peekskill"	style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>Though the buildings in this complex are referred to as the Hat Factory, don't be misled! This building is perfectly well suited for manufacutring car motors,
		tires, and windshields. </p>
		<p> Value: 2/5 Cost: 2/5 Tax: 1/5 Accesibility: 2/5 </p><p>Overall: 2/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Peekskill')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "North_Salem" class = "tooltiptext">
		<h3>North Salem</h3>
		<img src = "images/North_Salem.jpg" alt = "North Salem" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>A quiet auto body shop located in scenic northern Westhchester. It won't get a lot of traffic, but it also won't cost
		you much to own either. </p>
		<p>Value: 2/5 Cost: 1/5 Tax: 1/5 Accesibility: 1/5 </p><p>Overall: 2/5 </p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('North_Salem')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Mamaroneck" class = "tooltiptext">
		<h3>Mamaroneck</h3>
		<img src = "images/Mamaroneck.jpg" alt = "Mamaroneck" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>A quaint little car repair shop in the outskirts of Mamaroneck. What this location lacks in resources, it makes up for with
		heart, grit, and patriotism. A combo the locals will be sure to enjoy!</p>
		<p>Value: 3/5 Cost: 1/5 Tax: 2/5 Accesibility: 4/5</p><p>Overall: 3/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Mamaroneck')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Mount_Vernon" class = "tooltiptext">
		<h3>Mount Vernon</h3>
		<img src = "images/Mount_Vernon.jpg" alt = "Mount Vernon" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>Located on the outskirts of Mount Vernon, this car-repair shop has the potential to attract customers from the Bronx, which
		is only 2 miles away from this store. However, this area is somewhat abandoned, so don't expect too many customers...</p>
		<p>Value: 2/5 Cost: 1/5 Tax: 1/5 Accesibility: 1/5 </p><p>Overall: 1/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Mount_Vernon')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Tuckahoe" class = "tooltiptext">
		<h3>Tuckahoe</h3>
		<img src = "images/Tuckahoe.jpg" alt = "Tuckahoe" style = "width: 27vw; height: 15VW; padding-left: 1.5vw;">
		<p>A humongous auto repair shop located in prime real estate in Tuckahoe. This is sure to be a popular destination for those
		who live in the nearby area and own cars (which is most of the people who live nearby). A great investment!</p>
		<p>Value: 5/5 Cost: 4/5 Tax: 3/5 Accesibility: 5/5 </p><p>Overall: 5/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Tuckahoe')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Mohegan_Lake" class = "tooltiptext">
		<h3>Mohegan Lake</h3>
		<img src = "images/Mohegan_Lake.jpg" alt = "Mohegan Lake" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>Mohegan Lake: Where land is cheap and factories are abundant. This abandoned warehouse will serve as the perfect location for you
		to open a factory manufacturing mufflers and hubcaps for cars. And with property taxes this low, what more could you ask for?</p>
		<p>Value 5/5 Cost: 3/5 Tax: 1/5 Accesibility: 1/5</p> <p>Overall: 5/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Mohegan_Lake')" class = "cancelButton">Cancel</div>
		</div>
		
		</div>

<!-- NewYorkWindow contains the map of New York state which makes up the setting for the second level of the game -->
<div class = "NewYorkWindow">
<div><img src = "images/NewYorkMap.jpg" alt = "New York" style = "width: 75vw; height: 50vw;"></div>
<div class = "specialDot WestchesterDot" onclick = "enterWestchester()"></div>
<div class = "mapButton" onclick = "enterFederal()">US Map</div>
<div class = "databaseButton" onclick = "databasePageLoad('NewYorkWindow')">See all Businesses</div>
<div class = "statBox" style = "left: 0vw;">
				<div class = "purchaseClass" id ="PurchaseID2"></div>
				<div class = "timeBox" id = "Timer2"></div>
			</div>
			
			<div onmouseover = "flip_on_mouseover('Albany_Dot', true)" onmouseout = "flip_on_mouseout('Albany', true)" onclick = "openDescription('Albany', 'Store', 'Universal Wheels', 1500, 45000, 30000, 'New York')" class = "dot Albany_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Manhattan_Dot', true)" onmouseout = "flip_on_mouseout('Manhattan', true)" onclick = "openDescription('Manhattan', 'Store', 'Universal Wheels', '10000', '485000', '200000', 'New York')" class = "dot Manhattan_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Bronx_Square', false)" onmouseout = "flip_on_mouseout('Bronx', false)" onclick ="openDescription('Bronx', 'Factory', 'Universal Wheels', 7000, 230000, 180000, 'New York')" class = "square Bronx_Square"></div>
			<div onmouseover = "flip_on_mouseover('Queens_Square', false)" onmouseout = "flip_on_mouseout('Queens', false)" onclick ="openDescription('Queens', 'Factory', 'Universal Wheels', 10000, 310000, 200000, 'New York')" class = "square Queens_Square"></div>					
			<div onmouseover = "flip_on_mouseover('Newburgh_Dot', true)" onmouseout = "flip_on_mouseout('Newburgh', true)" onclick ="openDescription('Newburgh', 'Store', 'Universal Wheels', 1000, 25000, 20000, 'New York')" class = "dot Newburgh_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Brooklyn_Square', false)" onmouseout = "flip_on_mouseout('Brooklyn', false)" onclick ="openDescription('Brooklyn', 'Factory', 'Universal Wheels', 10000, 270000, 230000, 'New York')" class = "square Brooklyn_Square"></div>
			<div onmouseover = "flip_on_mouseover('Staten_Island_Dot', true)" onmouseout = "flip_on_mouseout('Staten_Island', true)" onclick ="openDescription('Staten_Island', 'Store', 'Universal Wheels', 2000, 150000, 100000, 'New York')" class = "dot Staten_Island_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Long_Island_Dot', true)" onmouseout = "flip_on_mouseout('Long_Island', true)" onclick ="openDescription('Long_Island', 'Store', 'Universal Wheels', 3000, 100000, 75000, 'New York')" class = "dot Long_Island_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Ithaca_Dot', true)" onmouseout = "flip_on_mouseout('Ithaca', true)" onclick ="openDescription('Ithaca', 'Store', 'Universal Wheels', 750, 70000, 35000, 'New York')" class = "dot Ithaca_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Niagara_Falls_Dot', true)" onmouseout = "flip_on_mouseout('Niagara_Falls', true)" onclick ="openDescription('Niagara_Falls', 'Store', 'Universal Wheels', 3000, 200000, 120000, 'New York')" class = "dot Niagara_Falls_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Olean_Square', false)" onmouseout = "flip_on_mouseout('Olean', false)" onclick ="openDescription('Olean', 'Factory', 'Universal Wheels', 1500, 60000, 40000, 'New York')" class = "square Olean_Square"></div>
			<div onmouseover = "flip_on_mouseover('Mechanicville_Square', false)" onmouseout = "flip_on_mouseout('Mechanicville', false)" onclick ="openDescription('Mechanicville', 'Factory', 'Universal Wheels', 1200, 170000, 130000, 'New York')" class = "square Mechanicville_Square"></div>
			<div onmouseover = "flip_on_mouseover('Jamestown_Square', false)" onmouseout = "flip_on_mouseout('Jamestown', false)" onclick ="openDescription('Jamestown', 'Factory', 'Universal Wheels', 2000, 250000, 200000, 'New York')" class = "square Jamestown_Square"></div>
			<div onmouseover = "flip_on_mouseover('Plattsburgh_Dot', true)" onmouseout = "flip_on_mouseout('Plattsburgh', true)" onclick ="openDescription('Plattsburgh', 'Store', 'Universal Wheels', 250, 30000, 20000, 'New York')" class = "dot Plattsburgh_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Syracuse_Dot', true)" onmouseout = "flip_on_mouseout('Syracuse', true)" onclick ="openDescription('Syracuse', 'Store', 'Universal Wheels', 300, 20000, 15000, 'New York')" class = "dot Syracuse_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Troy_Dot', true)" onmouseout = "flip_on_mouseout('Troy', true)" onclick ="openDescription('Troy', 'Store', 'Universal Wheels', 500, 45000, 30000, 'New York')" class = "dot Troy_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Rochester_Square', false)" onmouseout = "flip_on_mouseout('Rochester', false)" onclick ="openDescription('Rochester', 'Factory', 'Universal Wheels', 2000, 240000, 180000, 'New York')" class = "square Rochester_Square"></div>
			<div onmouseover = "flip_on_mouseover('Buffalo_Dot', true)" onmouseout = "flip_on_mouseout('Buffalo', true)" onclick ="openDescription('Buffalo', 'Store', 'Universal Wheels', 1000, 55000, 40000, 'New York')" class = "dot Buffalo_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Poughkeepsie_Dot', true)" onmouseout = "flip_on_mouseout('Poughkeepsie', true)" onclick = "openDescription('Poughkeepsie', 'Store', 'Universal Wheels', 1000, 65000, 50000, 'New York')" class = "dot Poughkeepsie_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Watertown_Square', false)" onmouseout = "flip_on_mouseout('Watertown', false)" onclick = "openDescription('Watertown', 'Factory', 'Universal Wheels', 2500, 170000, 130000, 'New York')" class = "square Watertown_Square"></div>
			<div onmouseover = "flip_on_mouseover('Tupper_Lake_Square', false)" onmouseout = "flip_on_mouseout('Tupper_Lake', false)" onclick = "openDescription('Tupper_Lake', 'Factory', 'Universal Wheels', 2500, 400000, 300000, 'New York')" class = "square Tupper_Lake_Square"></div>
	
	<div id = "Manhattan" class = "tooltiptext">
				<h3>Manhattan</h3>
				<img src = "images/Manhattan.jpg" alt = "NYC" style = "width: 20vw; height: 14vw; padding-left: 4.7vw;">
				<p>The view from the 75th floor of the One World Trade Center is something that you can't get anywhere else in New York. With a bird's eye view over the rest of the city,
				this spot makes the perfect location to establish a headquarters for your company. Be sure to buy this space before someone else gets their hands on it!</p><p>Value: 5/5 Cost: 5/5 Tax: 5/5 Accesibility: 5/5</p> <p>Overall: 5/5</p>
				<p class = "Company_Status"></p>
				<div class = "transactionButton"></div>
				<div onclick = "cancel('Manhattan')" class = "cancelButton">Cancel</div>
			</div>	
			
			<div id = "Bronx" class = "tooltiptext">
		<h3>Bronx</h3>
	<img src = "images/Bronx.jpg" alt = "BX" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>Originally built in the 1930's, this unnocupied chemical factory makes the perfect location for manufacturing antifreeze, engine lubricant, and brake fluid.
A world of new markets awaits you, but only if you decide to take the first step inside!</p><p>Value: 5/5 Cost: 4/5 Tax: 4/5 Accesibility: 5/5</p> <p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Bronx')" class = "cancelButton">Cancel</div>
	</div>		
	
<div id = "Poughkeepsie" class = "tooltiptext">
<h3>Poughkeepsie</h3>
<img src = "images/Poughkeepsie.jpg" alt = "Poughkeepsie" style = "width: 25vw; height: 13vw; padding-left: 2.5vw;">
<p>For a long time, it appeared that businesses would never return to the city of Poughkeepsie. Fortunately, the rumors of Poughkeepsie's death were greatly exagerated, and companies are now filing back into the city
to open up their shops. Get in on this expanding market by buying your own auto shop in the heart of downtown Poughkeepsie! </p><p>Value: 3/5 Cost: 3/5 Tax: 2/5 Accesibility: 4/5</p><p>Overall: 3/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Poughkeepsie')" class = "cancelButton">Cancel</div>
</div>

<div id = "Albany" class = "tooltiptext">
<h3>Albany</h3>
<img src = "images/Albany.jpg" alt = "Albany" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>This sleepy auto-repair shop offers those traveling to and from Albany a chance to have their cars serviced before they ride on North to the
Adriondack Mountains or down South towards the Hudson Valley. The wear and tear of these trips is sure to attract a wide range of costumers!</p><p>Value: 2/5 Cost: 2/5 Tax: 1/5 Accesibility: 3/5</p><p>Overall: 3/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Albany')" class = "cancelButton">Cancel</div>
</div>

<div id = "Queens" class = "tooltiptext">
	<h3>Queens</h3>
	<img src = "images/Queens.jpg" alt = "Queens" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>A massive insutrial factory which finds itself next to a major highway. This factory has enough space to manufacture about 50,000 cars per year.
This is one opportunity that you just can't afford to pass up!</p><p>Value: 5/5 Cost: 5/5 Tax: 5/5 Accesibility: 5/5</p><p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Queens')" class = "cancelButton">Cancel</div>
	</div>		
	

<div id = "Newburgh" class = "tooltiptext">
	<h3>Newburgh</h3>
	<img src = "images/Newburgh.jpg" alt = "Newburgh" style = "width: 17vw; height: 13vw; padding-left: 6.5vw;">
<p>This car service station isn't going to win any awards for size, but the loyalty that the residents of Newburgh have for their hometown businesses should
help generate a steady stream of sales. Use this spot to perform inspections, sell lug wrenches and other car tools, and provide the city of Newburgh with
a high quality car shop.</p><p>Value: 2/5 Cost: 2/5 Tax: 1/5 Accesibility: 2/5</p><p>Overall: 2/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Newburgh')" class = "cancelButton">Cancel</div>
	</div>	

	
	<div id = "Brooklyn" class = "tooltiptext">
	<h3>Brooklyn</h3>
	<img src = "images/Brooklyn.jpg" alt = "Brooklyn" style = "width: 17vw; height: 15vw; padding-left: 6.5vw;">
<p>A massive warehouse overlooking the East River, this building provides plenty of space for setting up a scrap metal recycling plant. Remember: if you can convert scrap metal into
metal that's usable in car production, you can cut manufacutring costs by 30%! A can't miss opportunity!</p><p>Value: 5/5 Cost: 4/5 Tax: 5/5 Accesibility: 5/5</p> <p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Brooklyn')" class = "cancelButton">Cancel</div>
	</div>	


<div id = "Staten_Island" class = "tooltiptext">
	<h3>Staten Island</h3>
	<img src = "images/Staten_Island.jpg" alt = "Staten Island" style = "width: 25vw; height: 17vw; padding-left: 2.5vw;">
<p>Car deals abound! This bulding provides plenty of space for you to sell your cars to the eager Staten Island market. Hop on in, before
you miss the boat.</p><p>Value: 3/5 Cost: 3/5 Tax: 2/5 Accesibility: 4/5</p><p>Overall: 4/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Staten_Island')" class = "cancelButton">Cancel</div>
	</div>		
	

<div id = "Long_Island" class = "tooltiptext">
	<h3>Long Island</h3>
	<img src = "images/Long_Island.jpg" alt = "Long_Island" style = "width: 20vw; height: 13vw; padding-left: 5vw;">
<p>Customer Service is the first and foremost pillar of any good business. This Long Island office building offers the perfect space for your customer service
representatives to answer questions from customers, negotiate business deals with prospective clients, and spread the good word about your high quality products.</p><p>Value: 3/5 Cost: 3/5 Tax: 3/5 Accesibility: 4/5</p><p>Overall: 3/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Long_Island')" class = "cancelButton">Cancel</div>
	</div>		



<div id = "Ithaca" class = "tooltiptext">
	<h3>Ithaca</h3>
	<img src = "images/Ithaca.jpg" alt = "Ithaca" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>Also known as "The Crossroads of New York," Ithaca provides the perfect stopping place for weary travelers from all over the state. Give them the car service they need,
and provide your services to the community of Itahaca.</p><p>Value: 3/5 Cost: 3/5 Tax: 1/5 Accesibility: 3/5</p> <p>Overall: 3/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Ithaca')" class = "cancelButton">Cancel</div>
	</div>		
	


<div id = "Niagara_Falls" class = "tooltiptext">
	<h3>Niagara Falls</h3>
	<img src = "images/Niagara_Falls.jpg" alt = "Niagara Falls" style = "width: 20vw; height: 13vw; padding-left: 5vw;">
<p>Sure, sure, this building may be a bit expensive for its size, but don't let the price fool you: any store in Niagara Falls is good business! This is
a land where IHOP charges $17 for pancakes and hotels charge $500 per night. Even if the purchase price is high, the tourism of this region is sure to make
Niagara Falls a cash cow for your company.</p><p>Value: 5/5 Cost: 4/5 Tax: 4/5 Accesibility: 4/5</p> <p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Niagara_Falls')" class = "cancelButton">Cancel</div>
	</div>		
	

<div id = "Olean" class = "tooltiptext">
	<h3>Olean</h3>
	<img src = "images/Olean.jpg" alt = "Olean" style = "width: 25vw; height: 17vw; padding-left: 2.5vw;">
<p>This vacant windshield wiper factory is looking for a new owner. The perfect opportunity to expand into yet another car market!</p><p>Value: 3/5 Cost: 2/5 Tax: 2/5 Accesibility: 1/5</p> <p>Overall: 3/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Olean')" class = "cancelButton">Cancel</div>
	</div>		
		
	
<div id = "Mechanicville" class = "tooltiptext">
	<h3>Mechanicville</h3>
	<img src = "images/Mechanicville.jpg" alt = "Mechanicville" style = "width: 20vw; height: 16vw; padding-left: 5vw;">
<p>The water turbines connected to this building enable much of its energy needs to be supplied from cheap hydropower. Take advantage
of this prime real estate to develop a sustainable car manufacutring powerhouse!</p><p>Value: 4/5 Cost: 3/5 Tax: 2/5 Accesibility: 3/5</p> <p>Overall: 4/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Mechanicville')" class = "cancelButton">Cancel</div>
	</div>		
	
	
<div id = "Jamestown" class = "tooltiptext">
	<h3>Jamestown</h3>
	<img src = "images/Jamestown.jpg" alt = "Jamestown" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>This car assembly palace finds itself located on the western edge of New York. Land here is cheap compared to elsewhere in the state, making this the perfect
location to purchase for manufacturing your cars!</p><p>Value: 4/5 Cost: 3/5 Tax: 2/5 Accesibility: 3/5</p> <p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Jamestown')" class = "cancelButton">Cancel</div>
	</div>		
	


<div id = "Plattsburgh" class = "tooltiptext">
	<h3>Plattsburgh</h3>
	<img src = "images/Plattsburgh.jpg" alt = "Plattsburgh" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>Those traveling up into the green mountains of Vermont will be greatful to have the chance to stop here and fill up their tires with air and
have their cars tuned up. A location worth investing in!</p><p>Value: 2/5 Cost: 2/5 Tax: 1/5 Acceisibility: 2/5 </p> <p>Overall: 2/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Plattsburgh')" class = "cancelButton">Cancel</div>
	</div>		
	
<div id = "Watertown" class = "tooltiptext">
<h3>Watertown</h3>
<img src = "images/Watertown.jpg" alt = "Watertown" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>This cube-shaped car factory provides a spacious environment for manufacturing tires. Don't be a square! Invest in thhis factory now!</p><p>Value: 4/5 Cost: 3/5 Tax: 3/5 Accesibility: 2/5</p><p>Overall: 4/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Watertown')" class = "cancelButton">Cancel</div>
</div>

<div id = "Tupper_Lake" class = "tooltiptext">
<h3>Tupper Lake</h3>
<img src = "images/Tupper_Lake.jpg" alt = "Tupper Lake" style = "width: 23vw; height: 13vw; padding-left: 3.5vw;">
<p>The rolling plains and snow-tipped mountains of the Adriondacks form the backdrop of this ginormous manufacturing site. This building contains
enough space to manufacture more than 200,000 cars per year. And with prices this cheap and land this beautiful, what more could you possible ask for?</p><p>Value: 5/5 Cost: 5/5 Tax: 3/5 Accesibility: 2/5</p><p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Tupper_Lake')" class = "cancelButton">Cancel</div>
</div>
	
	
<div id = "Syracuse" class = "tooltiptext">
	<h3>Syracuse</h3>
	<img src = "images/Syracuse.jpg" alt = "Syracuse" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
<p>This property has fallen on hard times... Fortunately, you can easily purchase this location for a low cost, demolish the building on it, and put
your own car-repair shop up here for a fraction of the cost of buying a pre-existing car shop.</p><p>Value: 1/5 Cost: 2/5 Tax: 2/5 Accesibility: 2/5 </p> <p>Overall: 1/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Syracuse')" class = "cancelButton">Cancel</div>
	</div>		
	


<div id = "Troy" class = "tooltiptext">
	<h3>Troy</h3>
	<img src = "images/Troy.jpg" alt = "Troy" style = "width: 20vw; height: 12vw; padding-left: 5vw;">
<p>Though this building was a major storage facility of cotton for the city of Troy in the early 1900's, it has since fallen into disuse.
The governemnt of Troy is even considering having the building demolished if nobody purchases it soon. This is where you come in. Use the space 
inside this building to make a museum about the history of cars whose unique appearence will attract visitors from around the world!</p><p>Value: 5/5 Cost: 3/5 Tax: 1/5 Accesibility: 4/5</p> <p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Troy')" class = "cancelButton">Cancel</div>
	</div>		
	


<div id = "Rochester" class = "tooltiptext">
	<h3>Rochester</h3>
	<img src = "images/Rochester.jpg" alt = "Rochester" style = "width: 25vw; height: 12vw; padding-left: 2.5vw;">
<p>These two adjacent factory buildings are bundled into this rare offer to purchase two factories for the cost of one! Double the manufacturing
means double the revenue, so be sure to purchase this lot before one of your competitors can get their hands on it!</p><p>Value: 5/5 Cost: 4/5 Tax: 2/5 Accesibility: 4/5</p><p>Overall: 5/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Rochester')" class = "cancelButton">Cancel</div>
	</div>		
	


<div id = "Buffalo" class = "tooltiptext">
	<h3>Buffalo</h3>
	<img src = "images/Buffalo.jpg" alt = "Buffalo" style = "width: 22vw; height: 13vw; padding-left: 4vw;">
<p>Those looking to bare the harsh Buffalo winters will be in need of a nearby car shop providing high-quality cars. This shop
is the perfect location to sell all-wheel drive cars and pickup trucks to the residents of Buffalo, and to keep traffic moving through this busy city!</p><p>Value: 3/5 Cost: 2/5 Tax: 2/5 Accesibility: 3/5</p><p>Overall: 3/5</p>
<p class = "Company_Status"></p>
<div class = "transactionButton"></div>
<div onclick = "cancel('Buffalo')" class = "cancelButton">Cancel</div>
	</div>	
			
				
</div>

<!-- FederalWindow contains the map of the United States which forms the setting for the third and last level of the game -->
		<div class = "FederalWindow">
			<div><img src = "images/US.jpg" alt = "US" style = "width: 75vw; height: 50vw;"></div>
		<div class = "statBox" style = "left: 0vw;">
				<div class = "purchaseClass" id ="PurchaseID3"></div>
				<div class = "timeBox" id = "Timer3"></div>
			</div>
			<div class = "specialDot NewYorkDot" onclick = "otherEnterNY()"></div>
		
		
			<div class = "databaseButton" onclick = "databasePageLoad('FederalWindow')">See all Businesses</div>
	
			<div onmouseover = "flip_on_mouseover('Ankang_China_Square', false)" onmouseout = "flip_on_mouseout('Ankang_China', false)" style = "display: none;" onclick = "openDescription('Ankang_China', 'Factory', 'Universal Wheels', 50, 150000, 100000, 'Outside New York')" class = "square Ankang_China_Square"></div>
			<div onmouseover = "flip_on_mouseover('Rose_Plaza_Dot', true)" style = "display: none;" onmouseout = "flip_on_mouseout('Rose_Plaza', true)" onclick = "openDescription('Rose_Plaza', 'Store', 'Universal Wheels', 4000, 750000, 500000, 'Outside New York')" class = "dot Rose_Plaza_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Boston_Dot', true)" onmouseout = "flip_on_mouseout('Boston', true)" onclick = "openDescription('Boston', 'Store', 'Universal Wheels', 3000, 270000, 220000, 'Outside New York')" class = "dot Boston_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Philadelphia_Dot', true)" onmouseout = "flip_on_mouseout('Philadelphia', true)" onclick = "openDescription('Philadelphia', 'Store', 'Universal Wheels', 1000, 35000, 20000, 'Outside New York')" class = "dot Philadelphia_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Los_Angeles_Dot', true)" onmouseout = "flip_on_mouseout('Los_Angeles', true)" onclick = "openDescription('Los_Angeles', 'Store', 'Universal Wheels', '2000', '210000', '150000', 'Outside New York')" class = "dot Los_Angeles_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Las_Vegas_Square', false)" onmouseout = "flip_on_mouseout('Las_Vegas', false)" onclick = "openDescription('Las_Vegas', 'Factory', 'Universal Wheels', 25000, 2100000, 1700000, 'Outside New York')" class = "square Las_Vegas_Square"></div>
			<div onmouseover = "flip_on_mouseover('Chicago_Dot', true)" onmouseout = "flip_on_mouseout('Chicago', true)" onclick = "openDescription('Chicago', 'Store', 'Universal Wheels', '3000', '180000', '90000', 'Outside New York')" class = "dot Chicago_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Dallas_Dot', true)" onmouseout = "flip_on_mouseout('Dallas', true)" onclick = "openDescription('Dallas', 'Store', 'Universal Wheels', 4000, 550000, 400000, 'Outside New York')" class = "dot Dallas_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Denver_Dot', true)" onmouseout = "flip_on_mouseout('Denver', true)" onclick = "openDescription('Denver', 'Store', 'Universal Wheels', '1000', '350000', '200000', 'Outside New York')" class = "dot Denver_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Fargo_Square', false)" onmouseout = "flip_on_mouseout('Fargo', false)" onclick = "openDescription('Fargo', 'Factory', 'Universal Wheels', 1200, 480000, 350000, 'Outside New York')" class = "square Fargo_Square"></div>
			<div onmouseover = "flip_on_mouseover('Glia_Bend_Square', false)" onmouseout = "flip_on_mouseout('Glia_Bend', false)" onclick = "openDescription('Glia_Bend', 'Factory', 'Universal Wheels', '800', '100000', '60000', 'Outside New York')" class = "square Glia_Bend_Square"></div>
			<div onmouseover = "flip_on_mouseover('Detroit_Square', false)" onmouseout = "flip_on_mouseout('Detroit', false)" onclick = "openDescription('Detroit', 'Factory', 'Universal Wheels', '100', '10000', '2000', 'Outside New York')" class = "square Detroit_Square"></div>
			<div onmouseover = "flip_on_mouseover('El_Paso_Square', false)" onmouseout = "flip_on_mouseout('El_Paso', false)" onclick = "openDescription('El_Paso', 'Factory', 'Universal Wheels', '1000', '400000', '300000', 'Outside New York')" class = "square El_Paso_Square"></div>
			<div onmouseover = "flip_on_mouseover('Macon_Dot', true)" onmouseout = "flip_on_mouseout('Macon', true)" onclick = "openDescription('Macon', 'Store', 'Universal Wheels', '700', '40000', '5000', 'Outside New York')" class = "dot Macon_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Miami_Dot', true)" onmouseout = "flip_on_mouseout('Miami', true)" onclick = "openDescription('Miami', 'Store', 'Universal Wheels', 500, 55000, 30000, 'Outside New York')" class = "dot Miami_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Nashville_Square', false)" onmouseout = "flip_on_mouseout('Nashville', false)" onclick = "openDescription('Nashville', 'Factory', 'Universal Wheels', 800, 280000, 200000, 'Outside New York')" class = "square Nashville_Square"></div>
			<div onmouseover = "flip_on_mouseover('New_Orleans_Dot', true)" onmouseout = "flip_on_mouseout('New_Orleans', true)" onclick = "openDescription('New_Orleans', 'Store', 'Universal Wheels', 500, 10000, 5000, 'Outside New York')" class = "dot New_Orleans_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Topeka_Dot', true)" onmouseout = "flip_on_mouseout('Topeka', true)" onclick = "openDescription('Topeka', 'Store', 'Universal Wheels', 700, 40000, 30000, 'Outside New York')" class = "dot Topeka_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Twin_Falls_Square', false)" onmouseout = "flip_on_mouseout('Twin_Falls', false)" onclick = "openDescription('Twin_Falls', 'Factory', 'Universal Wheels', '600', '130000', '90000', 'Outside New York')" class = "square Twin_Falls_Square"></div>
			<div onmouseover = "flip_on_mouseover('Sacramento_Dot', true)" onmouseout = "flip_on_mouseout('Sacramento', true)" onclick = "openDescription('Sacramento', 'Store', 'Universal Wheels', 2000, 250000, 200000, 'Outside New York')" class = "dot Sacramento_Dot"></div>
			<div onmouseover = "flip_on_mouseover('Seattle_Square', false)" onmouseout = "flip_on_mouseout('Seattle', false)" onclick = "openDescription('Seattle', 'Factory', 'Universal Wheels', 2500, 310000, 260000, 'Outside New York')" class = "square Seattle_Square"></div>
			<div onmouseover = "flip_on_mouseover('St_Louis_Dot', true)" onmouseout = "flip_on_mouseout('St_Louis', true)" onclick = "openDescription('St_Louis', 'Store', 'Universal Wheels', 800, 65000, 40000, 'Outside New York')" class = "dot St_Louis_Dot"></div>
			
			
			
			<div id = "Los_Angeles" class = "tooltiptext">
				<h3>Los Angeles</h3>
				<img src = "images/Los_Angeles.jpg" alt = "LA" style = "width: 15vw; height: 15vw; padding-left: 7.5vw;">
				<p>A thriving and beautiful city full of people eager to move on with their day. Fulfill their dreams by giving them a car that will always let them do that. </p>
				<p> Value: 4/5   Cost: 3/5  Tax: 3/5 Accesibility: 5/5 </p> <p>Overall: 4/5</p>
				<p class = "Company_Status"></p>
				<div class = "transactionButton"></div>
				<div onclick = "cancel('Los_Angeles')"  class = "cancelButton">Cancel</div>
		
			</div>
			
	
	<div id = "Ankang_China" class = "tooltiptext">
	<h3> Ankang, China</h3>
	<img src = "images/Ankang_China.jpg" alt = "Ankang" style = "width: 25vw; height: 13vw; padding-left: 2.5vw;">
	<p> Located in the southern corner of Shaanxi province, this factory finds itself positioned at the exact geographic center of China. Since the factory is located
	in the western triangle special economic zone, labor is cheap and the land is both plentiful and reasonably priced. A must have opportunity for any car company
	looking to dominate the entire market!</p>
	<p>Value: 5/5 Cost: 2/5 Tax: 1/5 Accesibility: 2/5 </p><p>Overall: 5/5</p>
	<p class = "Company_Status"></p>
	<div class = "transactionButton"></div>
	<div class = "cancelButton" onclick = "cancel('Ankang_China')">Cancel</div>
	</div>
	
	<div id = "Rose_Plaza" class = "tooltiptext">
	<h3>Rose Plaza, Washington D.C.</h3>
	<img src = "images/Rose_Plaza.jpg" alt = "Rose_Plaza" style = "width: 25vw; height: 12vw; padding-left: 2.5vw;">
	<p>The gorgeous flowers and fountains of the Rose Plaza mall attract visitors from all accross the country, and the world. Become a part of this enchanted land by building a car
	shop in one of our many open store locations. You'd better buy them quickly, because this offer won't be around when other businesses catch word of our opening, and by then, the tourists
	will all be flocking to them instead of you!</p>
	<p>Value: 5/5 Cost: 5/5 Tax: 4/5 Accesibility: 5/5 </p><p>Overall: 5/5</p>
	<p class = "Company_Status"></p>
	<div class = "transactionButton"></div>
	<div class = "cancelButton" onclick = "cancel('Rose_Plaza')">Cancel</div>
	</div>
		
	<div id = "Las_Vegas" class = "tooltiptext">
	<h3>Las Vegas</h3>
	<img src = "images/Las_Vegas.jpg" alt = "Las Vegas" style = "width: 25vw; height: 17vw; padding-left: 2vw;">
	<p>A sprawling swarth of land in the Mojave desert about 20 minutes away from Las Vegas. You have the potential to build the largest car factory in the world here.
	I know that you've been given many other choices for places to buy so far, but this one here is really the most valuable to the success of your company - obtain this
	land at all costs, and become the most powerful car company on earth!</p>
	<p class = "Company_Status"></p>
	<div class = "transactionButton"></div>
	<div onclick = "cancel('Las_Vegas')" class = "cancelButton">Cancel</div> 
	</div>
	
	<div id = "Boston" class = "tooltiptext">
	<h3>Boston</h3>
	<img src = "images/Boston.jpg" alt = "Boston" style = "width: 25vw; height: 18vw; padding-left: 3vw;">
	<p>In recent years, companies accross the country have been moving their offices and stores to Boston. Now's your chance to do the same.
	The Boston metropolitan area is ripe with commuters looking to buy new cars. Set up a car shop here, and give these commuters the car of their dreams.</p>
	<p class = "Company_Status"></p>
	<div class = "transactionButton"></div>
	<div onclick = "cancel('Boston')" class = "cancelButton">Cancel</div>
	</div>
	
			<div id = "Chicago" class = "tooltiptext">
				<h3>Chicago</h3>
				<img src = "images/Chicago.jpg" alt = "Chicago" style = "width: 15vw; height: 15vw; padding-left: 7.5vw;">
				<p>A historic city which has fallen on tough times. Help turn things around by taking your business to the city</p>
				<p>Value: 4/5 Cost: 3/5 Tax: 4/5 Accesibility: 4/5</p> <p>Overall: 4/5</p>
				<p class = "Company_Status"></p>
				<div class = "transactionButton"></div>
				<div onclick = "cancel('Chicago')" class = "cancelButton">Cancel</div>
			</div>	
			
			<div id = "Dallas" class = "tooltiptext">
			<h3>Dallas</h3>
			<img src = "images/Dallas.jpg" alt = "Dallas" style = "width: 25vw; height: 13vw; padding-left: 2.5vw;">
			<p>A rental car here, a rental car there, rental cars eveyrwhere! They say that everything is bigger in Texas, and the rental car lots are no exception.
			With an airport only 1/2 mile away, this lot is prime real estate for travelers looking to get their hands on a car to start exploring the lone star state with.
			A can't miss opportunity for your company!</p>
			<p>Value: 5/5 Cost: 5/5 Tax: 5/5 Accesibility: 5/5</p><p>Overall: 5/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('Dallas')" class = "cancelButton">Cancel</div>
			</div>
			
			<div id = "Denver" class = "tooltiptext">
				<h3>Denver</h3>
				<img src = "images/Denver.jpg" alt = "Denver" style = "width: 15vw; height: 15vw; padding-left: 7.5vw;">
				<p>Located at the foot of the snowy rocky mountains, this city occupies a rugged landscape in a spread out area: Perfect for selling cars in!</p>
				<p>Value: 5/5 Cost: 5/5 Tax: 2/5 Accesibility: 2/5</p><p>Overall: 5/5</p> 
				<p class = "Company_Status"></p>
				<div class = "transactionButton"></div>
				<div onclick = "cancel('Denver')" class = "cancelButton">Cancel</div>
			</div>
			
			
			<div id = "Glia_Bend" class = "tooltiptext">
				<h3>Glia Bend</h3>
				<img src = "images/Glia_Bend.jpg" alt = "Glia" style = "width: 15vw; height: 15vw; padding-left: 7.5vw;">
				<p>A vast open plain, located at the heart of the desert in Arizona. Plenty of open space and small property taxes.
				 However, shipping materials from here is going to prove costly... </p>
				 <p>Value: 4/5 Cost: 3/5 Tax: 2/5 Accesability: 1/5</p><p>Overall: 4/5</p>
				 <p class = "Company_Status"></p>
				 <div class = "transactionButton"></div>
				 <div onclick = "cancel('Glia_Bend')" class = "cancelButton">Cancel</div>
			</div>
			
			
			<div id = "Detroit" class = "tooltiptext">
				<h3>Detroit</h3>
				<img src = "images/Detroit.jpg" alt = "Detroit" style = "width: 15vw; height: 15vw; padding-left: 7.5vw;">
				<p>A once prosperous car manufacturing city now lies in ruins. Help rebuild the city by bringing the car factories back to Detroit! </p>
				 <p>Value: 2/5 Cost: 1/5 Tax: 1/5 Accesability: 3/5</p><p>Overall: 2/5</p>
				 <p class = "Company_Status"></p>
				 <div class = "transactionButton"></div>
				 <div onclick = "cancel('Detroit')" class = "cancelButton">Cancel</div>
			</div>
		
		
			<div id = "El_Paso" class = "tooltiptext">
				<h3>El Paso</h3>
				<img src = "images/El_Paso.jpg" alt = "El Paso" style = "width: 15vw; height: 15vw; padding-left: 7.5vw;">
				<p>A vast, open field at the foot of El Paso. If you build a large factory here, it could become the powerhouse of your whole company. Do NOT pass this chance up!</p>
				<p>Value: 5/5 Cost: 5/5 Tax: 2/5 Accesibility: 4/5</p><p>Overall: 5/5</p>
				<p class = "Company_Status"></p>
				<div class = "transactionButton"></div>
				<div onclick = "cancel('El_Paso')" class = "cancelButton">Cancel</div>
			
			</div>

			
			<div id = "Macon" class = "tooltiptext">
				<h3>Macon, Georgia</h3>
				<img src = "images/Macon.jpg" alt = "Macon" style = "width: 30vw; height: 10vw;">
				<p>A small car store in a sleepy village in central Georgia. It may not be the busiest place to open a store,
				but the locals are always friendly and loyal. If you want a steady supply of customers at all times of the year, then
				this is the place to buy!</p>
				<p>Value: 2/5 Cost: 2/5 Tax: 1/5 Accesibility: 3/5 </p><p>Overall: 2/5</p>
				<p class = "Company_Status"></p>
				<div class = "transactionButton"></div>
				<div onclick = "cancel('Macon')" class = "cancelButton">Cancel</div>
			</div>
			
			<div id = "Miami" class = "tooltiptext">
			<h3>Miami</h3>
			<img src = "images/Miami.jpg" alt = "Miami" style = "width: 22vw; height: 15vw; padding-left: 5vw;">
			<p>The Miami market is heating up right now! Capitalize on this by opening up shop right here in the heart of downtown Miami.</p>
			<p>Value: 3/5 Cost: 3/5 Tax: 2/5 Accesibility: 5/5</p><p>Overall: 5/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('Miami')" class = "cancelButton">Cancel</div>
			</div>
			
			<div id = "Nashville" class = "tooltiptext">
			<h3>Nashville</h3>
			<img src = "images/Nashville.jpg" alt = "Nashville" style = "width: 25vw; height: 17vw; padding-left: 2.5vw;">
			<p>This factory provides the perfect location for manufacturing cars. With cheap prices, large amounts of land, and a great city to surround it, what
			more could you possible want?</p>
			<p>Value: 5/5 Cost: 4/5 Tax: 3/5 Accesibility: 5/5 </p><p>Overall: 5/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('Nashville')" class = "cancelButton">Cancel</div>
			</div>
			
			<div id = "New_Orleans" class = "tooltiptext">
			<h3>New Orleans</h3>
			<img src = "images/New_Orleans.jpg" alt = "New Orleans" style = "width: 28vw; height: 14vw; padding-left: 1vw;">
			<p>Some car shops just want to take you for a ride. But not this one! What you see is what you get. Customers can come here for AC service, oil changes, 
			and vehicle repairs. That's it. This location will be sure to attract no-nonsense car owners who want their car serviced quickly and effeciently.</p>
			<p>Value: 1/5 Cost: 1/5 Tax: 2/5 Accesibility: 3/5</p><p>Overall: 2/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('New_Orleans')" class = "cancelButton">Cancel</div>
			</div>
			
			<div id = "Topeka" class = "tooltiptext">
	<h3>Topeka</h3>
	<img src = "images/Topeka.jpg" alt = "Topeka" style = "width: 22vw; height: 16vw; padding-left: 4vw">
	<p>This quaint little store finds itself located right in the heart of the geographical center of the US. It may not get a lot of traffic, but business is business,
	and the locals will definitely come and use your store.</p>
	<p>Value: 3/5 Cost: 3/5 Tax: 2/5 Accesibility: 2/5</p><p>Overall: 2/5</p>
	<p class = "Company_Status"></p>
	<div class = "transactionButton"></div>
	<div onclick = "cancel('Topeka')" class = "cancelButton">Cancel</div>
	</div>
	
			<div id = "Philadelphia" class = "tooltiptext">
			<h3>Philadelphia</h3>
			<img src = "images/Philadelphia.jpg" alt = "Philadelphia" style = "width: 25vw; height: 17vw; padding-left: 2vw;">
			<p>Roll on in to this cozy auto body shop in down town Philadelphia. What it lacks for in style it makes it for with great location and low taxes!</p>
			<p>Value: 2/5 Cost: 2/5 Tax: 1/5 Accesibility: 4/5</p><p>Overall: 2/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('Philadelphia')" class = "cancelButton">Cancel</div>
			</div>
			
	
		<div id = "Seattle" class = "tooltiptext">
		<h3>Seattle</h3>
		<img src = "images/Seattle.jpg" alt = "Seattle" style = "width: 25vw; height: 20vw; padding-left: 2.5vw;">
		<p>This unused warehouse will make a nice location for manufacturing cars. And the plentiful starbucks located throughout Seattle will be sure
		to attract lots of employees eager to work here!</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Seattle')" class = "cancelButton">Cancel</div>
		</div>
		
			<div id = "St_Louis" class = "tooltiptext">
			<h3>St Louis</h3>
			<img src = "images/St_Louis.jpg" alt = "St. Louis" style = "width: 20vw; height: 15vw; padding-left: 5vw;">
			<p>The gateway to the midwest: St. Louis. Its also the gateway into the midwest highways and road systems. Expect lots of travelers
			to visit your store here as they pause at this crossroads city before continuing on their way.</p>
			<p>Value: 3/5 Cost: 3/5 Tax: 2/5 Accesibility: 5/5</p><p>Overall: 3/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('St_Louis')" class = "cancelButton">Cancel</div>
			</div>
		
		<div id = "Twin_Falls" class = "tooltiptext">
			<h3>Twin Falls, Idaho</h3>
			<img src = "images/Twin_Falls.jpg" alt = "Twin Falls" style = "width: 23vw; height: 15vw; padding-left: 3.5vw;">
			<p>The wide open plains of Idaho offer the perfect space for building a car factory. Create your next factory in this picturesque landscape</p>
			<p>Value: 3/5 Cost: 3/5 Tax: 1/5 Accesibality: 1/5 </p><p>Overall: 3/5</p>
			<p class = "Company_Status"></p>
			<div class = "transactionButton"></div>
			<div onclick = "cancel('Twin_Falls')" class = "cancelButton">Cancel</div> 
		</div>
			
		<div id = "Sacramento" class = "tooltiptext">
		<h3>Sacramento</h3>
		<img src = "images/Sacramento.jpg" alt = "Sacramento" style = "width: 27vw; height: 14vw; padding-left: 1.5vw;">
		<p>Located at the corner of a busy intersection, this shop is the last stop after leaving sacramento before entering the desert. Expect a lot of
		weary travelers to come by looking to have their cars repaired from the harsh desert terrain.</p>
		<p>Value: 4/5 Cost: 4/5 Tax: 4/5 Accesibility: 5/5 </p><p>Overall: 4/5</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Sacramento')" class = "cancelButton">Cancel</div>
		</div>
		
		<div id = "Fargo" class = "tooltiptext">
		<h3>Fargo</h3>
		<img src = "images/Fargo.jpg" alt = "Fargo" style = "width: 27vw; height: 15vw; padding-left: 1.5vw;">
		<p>A massive industrial complex located under blue skies in rural North Dakota. A quiet place, and one which sells land for lower prices than 
		you could get on the east or west coasts. Build a great car factory here, and make it the powerhouse of your company.</p>
		<p class = "Company_Status"></p>
		<div class = "transactionButton"></div>
		<div onclick = "cancel('Fargo')" class = "cancelButton">Cancel</div>
		</div>
			
		</div>
		
		<!-- databaseWindow is the window which contains the table of information about each business location in the game. -->
		<div class = "databaseWindow">
		<div class = "banner">
			<div onclick = "dataReturn()" class = "rectangleButton">Return to Map</div>
			<div onclick = "openPriority()" class = "rectangleButton">Company Statistics</div>
			<div class = "rectangleButton" onclick = "openProperties()">Search Data</div>
			</div>
			
			<!-- databaseSearchMenu is the window which contains the sortCriteria for the user to sort the informatio about
			each business location. the OpenProperties() function determines what specific sort criteria the user can select -->
			
				<div id = "databaseSearchMenu" class = "databaseSearchMenu">
					<p style = "color: red; font-size: 1.4vw;">&emsp;&nbsp;&emsp;&emsp;City:&emsp;&emsp;&nbsp;&nbsp;Type:&nbsp;&nbsp;&nbsp;&emsp;&emsp;&nbsp;&nbsp;Owner:&emsp;&emsp;&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;
					Cost:&emsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Location:&nbsp;&emsp;Date:</p>
					<form>
						
						
						<select style= "font-size: 0.8vw; margin-left: 2.5vw;" id = "City" multiple name = "City">
											
						</select>			
						
						
						<select style = "font-size: 0.8vw;" id = "Type" multiple name = "Type">
							<option value = "All">All</option>
							<option value = "Store">Stores</option>
							<option value = "Factory">Factories</option>
						</select> 
						
					
						<select style = "font-size: 0.8vw;" id = "Owner" multiple name= "Owner">
						
							
						</select> 
						
						
						<select style = "font-size: 0.8vw;" id = "Cost" multiple name ="Cost">
							<option value = "All">All</option>
							<option value = "50000"> &le; $50,000</option>
							<option value = "100000"> &gt; $50,000 &le; $100,000</option>
							<option value = "300000"> &gt; $100,000 &le; $300,000</option>
							<option value = "500000">&gt; $300,000 &le; $500,000</option>
							<option value = "1000000">&gt; $500,000</option>
						</select>  
						
						
						<select style = "font-size: 0.8vw;" id = "Location" multiple name="Location">
							
						</select> 
						
						
						<select style = "font-size: 0.8vw;" id = "Day" multiple name = "Day">
							<option  value = "All">All</option>
							<option  value = "4">0-4</option>
							<option  value = "9">5-9</option>
							<option value = "14">10-14</option>
							<option  value = "19">15-19</option>
							<option  value = "24">20-24</option>
							<option  value = "30">25-30</option>
						</select> 
						
						
						<br><br>
						
						<span style = "color: red; font-size: 1.4vw;">Sort By: </span><select style = "font-size: 0.8vw; margin-right: 2.5vw;" id = "Sort" name = "Sort">
							<option  value = "None">None</option>
							<option  value = "City">City</option>
							<option  value = "Type">Type</option>
							<option  value = "Owner">Owner</option>
							<option  value = "Cost">Cost</option>
							<option  value = "Location">Location</option>
							<option  value = "Day of Month">Day of Month</option>
						</select>
						
						<span style = "color: red; font-size: 1.4vw">In Order</span><input type ="radio" name = "sort-order" id = "InorderSort" checked = "checked" value = "In Order">
						&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<span style = "color: red; font-size: 1.4vw">Reverse Order</span><input type = "radio" name = "sort-order" value = "Reverse Order">
						<br><br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;
						<input id = "submit" type = "submit">
						<div onclick = "cancelData()" class = "cancelButton" style = "margin-right: 5vw; bottom: 1vw;">Cancel</div>
						
					</form>
				
				
				</div>
				<!-- this table is where the table of information about each business location is outputted inside of the databaseWindow -->
				
				<div class = "databaseTable">
					<table border = "2" style = "width: 100%;">
						<thead>
							<tr>
								<th>City</th>
								<th>Type of Business</th>
								<th>Owner</th>
								<th>Cost</th>
								<th>Location Within America</th>
								<th>Day of Month Purchased On</th>
							</tr>
						</thead>
						<tbody id = "mainTableBody">
							
						</tbody>
					
					</table>
				
				</div>
	
			</div>
		<!-- PriorityWindow is the window that lists information about each company in the game -->
		<div class = "PriorityWindow">
		<div class = "banner">
		<div class = "rectangleButton" onclick = "priorityMap()">Return to Map</div>
		<div class = "rectangleButton" onclick = "priorityReturn()">Return to Business Table</div>
		</div>
			<div class = "databaseTable">
					<table border = "2" style = "width: 100%;">
						<thead>
							<tr>
								<th>Name</th>
								<th>Total Cash</th>
								<th>Number of Stores</th>
								<th>Number of Factories</th>
								<th>Total Value of all Properties</th>
							</tr>
						</thead>
						<tbody id = "PriorityTable">
							
						</tbody>
					
					</table>
				
				</div>
		</div>
			
			<!-- HighScoreLoadPage is the window displayed when a user beats the game, which prompts them to enter in a highscore for the highscore database -->
			<div class = "highScoreLoadPage" style = "padding-left: 1vw; padding-right: 1vw;">
				<h3 style = "color: Maroon; font-size: 30px;">Congratulations!</h3>
				<p>You have become the most powerful car company in America! Through your shrewd planning,
				and decision making, you have come to dominate the industry. Other businesses can only watch with
				envy as you rake in all of the profits and sales.</p>
				<p>Would you like to enter in your name to the high score chart? If so, then enter in a name below. If you want to update a score you got earlier,
				then enter in the name you used originally, and then enter in your password to update your score. Otherwise, if the name you want has already been taken by
				someone else than you must select a different name</p>
				<p style = "font-size: 12px; font-weight: bold;">Note: your name must not contain spaces, be at least 3 characters long, and have at least one letter character in it. You must type in
				a password which is at least 6 characters in length to go with your name. This password is the only way to update a score you set earlier, so be sure to write this down!</p><br>
				
				<form>
					Name:
					<input id = "userName" type = "text" name = "userName">
					<br><br>
					
					Password:
					<input id = "password" type = "password" name = "password">
					<br><br>
					
				
				<input id = "button" type = "button" onclick = "databaseVerify()" value = "Submit">
				<p style = "color: red;" id = "feedback"></p>
				</form> 
			
			
			
			</div>
			
			<!-- The HighScoresWindow is the window that displays the highscores set by other players -->
			<div class = "HighScoresWindow">
				<div class = "banner">
				<div style = "float: left;" class = "rectangleButton" onclick = "sortLoad()">Sort</div>
				<div class = "rectangleButton" style = "margin-left: 22vw;" onclick = "swapTable()">Money High Scores</div>
				<div style = "float: right;" class = "rectangleButton" onclick = "homeReturn()">Return to Home Page</div>
				</div>
				<br><br><h3 style = "font-size: 25px; color: maroon; text-align: center;">Time High Scores:</h3>
				
				<table style = "margin: auto; background-color: white; width: 72.5vw;" border = "1">
					<thead id = "dataHead">	
					</thead>
					<tbody id = "dataBody">
					
					</tbody>
				</table>
			
			
			<!-- The sortWindow is the window that lists the sort criteria for the high scores in the HighScoresWindow -->
			<div class = "sortWindow">
				<form>
				<h3 style = "color: maroon;">Sort By:</h3>
					Criteria: <select id = "databaseSort" name = "Sort By: ">
						
					</select><br>
					First to Last: <input type = "radio" name = "sort-type" id = "First-To-Last" value = "First-To-Last" checked = "checked">
					<br>Last to First: <input type = "radio" name = "sort-type" value = "Last-To-First"><br>
					<input id = "sortButton" type = "button" onclick = "sortScores()" value = "Submit">
				</form>
			
			</div>
			</div>
	</body>
</html>


