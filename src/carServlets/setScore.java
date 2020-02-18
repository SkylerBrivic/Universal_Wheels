package carServlets;

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


import java.sql.*;

//setScore is called for two purposes: to determine the validity of a user's password (assuming the username already exists),
//and (if the user's credentials were all valid) to update the high score database to include any high scores set by the user.
/**
 * Servlet implementation class setScore
 */
@WebServlet("/setScore")
public class setScore extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public setScore() {
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
	
	//return value of 0 means success and new username created.
	//return value of 1 means success and existing record updated (if record was broken)
	//return value of 2 means username already existed but password was wrong
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		boolean newName = true;
		
		int tempTime, tempCash;
		String userName = request.getParameter("userName");
		String password = request.getParameter("password");
		String tempUser, tempPassword;
		int cash = Integer.parseInt(request.getParameter("cash"));
		int time = Integer.parseInt(request.getParameter("time"));
		
		try{
			Class.forName("com.mysql.jdbc.Driver");
		}
		catch(ClassNotFoundException e)
		{
			
		}
	

	
	

try(Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/finalProject", "root", "Placeholder"))
		
{
	

	
	Statement statement = connection.createStatement();
	ResultSet resultSet = statement.executeQuery("Select * from Users");
	
	while(resultSet.next())
	{
	tempUser = resultSet.getString(1);
	tempPassword = resultSet.getString(2);
	
	if(userName.equals(tempUser))
	{
		if(tempPassword.equals(password))
			{
			newName = false;
			response.getWriter().println("1");
			break;
			}
		else
		{
			newName = false;
			response.getWriter().println("2");
			return;
		}
	}
		
		
	}
	
	//if this is the user's first time submitting a high score, add their name and password into the user's table,
	//and add their times and money to the time high scores and money high scores tables respectively.
	if(newName == true)
		{
		statement.executeUpdate("Insert into Users Values( '" + userName + "', '" + password + "')");
		statement.executeUpdate("Insert into fastestTime Values( '" + userName + "', " + String.valueOf(time) + ", Now())");
		statement.executeUpdate("Insert into mostMoney Values( '" + userName + "', " + String.valueOf(cash) + ", Now())");
		response.getWriter().println("0");
		return;
		}
	
	resultSet = statement.executeQuery("Select completionTime from fastestTime where username = '" + userName + "'");
	resultSet.next();
	tempTime = Integer.parseInt(resultSet.getString(1));
	//if user beat the game faster than before, than update their time high score.
	if(time < tempTime)
	{
		statement.executeUpdate("UPDATE fastestTime SET completionTime = " + String.valueOf(time) + ", dateSet = Now() where userName = '" + userName + "'");
	}
	resultSet = statement.executeQuery("Select money from mostMoney where username = '" + userName + "'");
	resultSet.next();
	tempCash = Integer.parseInt(resultSet.getString(1));
	//if the user beat the game with more cash than before, than update their cash high score.
	if(cash > tempCash)
	{
		statement.executeUpdate("UPDATE mostMoney set money = " + String.valueOf(cash) + ", dateSet = Now() where userName = '" + userName + "'");
	}
	
	
	}
		
catch(SQLException e)
{
	   
}

	return;	
	}


}

