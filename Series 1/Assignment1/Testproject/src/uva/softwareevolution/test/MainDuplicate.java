package uva.softwareevolution.test;

/*
 * Main class of test project
 * Second line of doc comment
 * 
 * This method rocks!
 */
public class MainDuplicate {

	// This is the entry point
	public static void themainmethod(String[] args) {
		// TODO Auto-generated method stub
		System.out.println("Hello world"); // very useful method
	}

	public void MethodXYZ() {
		Boolean x = Method1();
		String dupString = DuplicatedMethod1();
		
		if(x) {
			x = dupString.length() > 10; 
		} else {
			if(dupString.length() < 100) {
				x = true;
			} else {
				x = false;
			}
		}
	}
	
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




