package carServlets;

import playerScore.highScore;
import java.util.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

import java.sql.*;

//getScores receives a list of sort criterian and returns a sorted list to the client of all high scores sorted by some criteria.
/**
 * Servlet implementation class getScores
 */
@WebServlet("/getScores")
public class getScores extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public getScores() {
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
	
		boolean inOrder = Boolean.parseBoolean(request.getParameter("inOrder"));
		String returnVal = "null";
		String type = request.getParameter("Type");
		String criteria = request.getParameter("Criteria");
	try
	{
		returnVal = performAction(type, criteria, inOrder);
	}
		catch (SQLException e)
	{
			
	}
	catch (ClassNotFoundException e)
	{
		
	}
	

		response.getWriter().println(returnVal);
	}

	String performAction(String type, String Criteria, boolean inOrder) throws ClassNotFoundException, SQLException
	{
		String tempName, tempDate;
		int tempStatistic;
		ArrayList<highScore> highestScores = new ArrayList<highScore>();
			Class.forName("com.mysql.jdbc.Driver");
		
	
		
		
	
	
			Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/finalProject", "root", "Placeholder");
			
		String myQuery = "Select * From " + type + " ORDER BY " + Criteria;
		
		if(Criteria.equals("completionTime"))
		{
			if(inOrder)
				myQuery += " ASC";
			else
				myQuery += " DESC";
		}
		else if(Criteria.equals("money"))
		{
			if(inOrder)
				myQuery += " DESC";
			else
				myQuery += " ASC";
			
		}
		else
		{
			if(inOrder)
				myQuery += " ASC";
			else
				myQuery += " DESC";
			
		}
		
		Statement statement = connection.createStatement();
		ResultSet resultSet;
		
		
			 resultSet = statement.executeQuery(myQuery);
		
		
		while(resultSet.next())
		{
			
			tempName = resultSet.getString(1);
			tempStatistic = Integer.parseInt(resultSet.getString(2));
			tempDate = resultSet.getString(3);
			tempDate = standardize(tempDate);
			highestScores.add(new highScore(tempName, tempStatistic, tempDate));
			
			
		}
		
		
	
	
			    
 
		Gson gson = new Gson();
		return gson.toJson(highestScores);
		
	}
	
	//standardize converts a date into a more readable format ex. 11/24/2018 11:17 AM
	String standardize(String original)
	{
		String answer;
		answer = original.substring(5, 7) + "/" + original.substring(8, 10) + "/" + original.substring(0, 4) + " ";
		int hours = Integer.parseInt(original.substring(11, 13));
		if(hours > 12)
		{
			answer += String.valueOf(hours - 12) + ":" + original.substring(14, 16) + " PM";
			return answer;
		}
		else if(hours == 12)
		{
			answer += "12:" + original.substring(14, 16) + " PM";
			return answer;
		}
		else if(hours == 0)
		{
			answer += "12:" + original.substring(14, 16) + " AM";
			return answer;
		}
		
		else
		{
			answer += String.valueOf(hours) + ":" + original.substring(14, 16) + " AM";
			return answer;
		}
	}
	
}
