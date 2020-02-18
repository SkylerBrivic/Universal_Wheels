package companyAttributes;

//objects of type priorityVal store an owner, a priority (long-term luck), luck (short-term luck), a status (the result of the last decision, 
//with true indicating success and false indicating a bad choice by the user), and cash.
public class priorityVal 
{
	
	public String owner;
	public int priority;
	public int luck;
	public boolean status;
	public int cash;
	
	public priorityVal(String new_owner, int new_priority, int new_luck, boolean new_status, int new_cash)
	{
		owner = new_owner;
		priority = new_priority;
		luck = new_luck;
		status = new_status;
		cash = new_cash;
	}
	public priorityVal()
	{
		owner = "";
		priority = 0;
		luck = 0;
		status = true;
		cash = 0;
	}
}
