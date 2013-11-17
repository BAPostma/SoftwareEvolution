package uva.softwareevolution.test;

/*
 * Main class of test project
 * Second line of doc comment
 * 
 * This method rocks!
 */
public class Main {

	// This is the entry point
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		System.out.println("Hello world"); // very useful method
	}

	/*
	 * Some commented out code below
	 */
	
	/*
	this is commented
	
	out code in a multi
	
	line code block
	*/
	
	public Boolean Method1() {
		String string1;
		string1 = "Hello world";
		string1 = string1 + " " + "Foobar";
		int len = string1.length();
		int treshold = 10;
		
		if(len <= treshold) {
			return true;
		} else {
			return false;
		}
	}
	
	public String DuplicatedMethod1() {
		String string1;
		string1 = "Hello world";
		string1 = string1 + " " + "Foobar";
		int len = string1.length();
		int treshold = 10;
		
		if(len <= treshold) {
			return "true";
		} else {
			return "false";
		}
	}
}




