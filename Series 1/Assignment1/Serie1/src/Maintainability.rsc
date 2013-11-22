module Maintainability

import lang::java::jdt::m3::Core;
import IO;
import List;

import Volume;
import Complexity;
import UnitSize;

/**
 * number of starts: 6 - rating
 * ++ => 1
 * ..
 * -- => 5
 */
public void analyze(M3 project){
	println("-----------------------------------------------");
	println("--------- SIGs Maintainability Index  ---------");
	println("-----------------------------------------------");
	
	println("Start counting LOC");
	// Calculate LOC
	totalLoc = countProjectLOC(project);
	ratingLoc = getRatingForAnalysability(totalLoc);
	println("Ready counting LOC");
	
	println("Calculating Cyclometic Complexity");
	methodInfo = ccMethodsInfo(project);
	println("\tMethod information gathered");
	
	ccRating = getRatingForChangeability(convertCCMethodsToRisk(methodInfo));
	println("\tComplexiting rating gathered");
	
	asserts = sum([methodInfo[m].asserts | m <- methodInfo]);
	println("Unit testing rating gathered");
	
	println("Unit size determination started");
	map[loc, num] _nr = ();
	for(m <- methodInfo){ _nr += (m:methodInfo[m].lines);}
	numberPerRisk = determineNumberPerRisk(_nr);
	ratingUnitSize = getRating(determinePercentagePerRisk(numberPerRisk));
	println("Unit size determination finished");
	
	/**
	 * Print results
	 */
	 println("-----------------------------------------------");
	 println("---------         Volume              ---------");
	 println("-----------------------------------------------");
	 println("Total LOC: <totalLoc>");
	 println("Rating for volume: <6 - ratingLoc> stars");
	 
	 println("-----------------------------------------------");
	 println("---------         Complexity          ---------");
	 println("-----------------------------------------------");
	 println("Rating for complexity: <6 - ccRating> stars");
	 
	 println("-----------------------------------------------");
	 println("---------         Unit Size           ---------");
	 println("-----------------------------------------------");
	 println("Number of methods per category:");
	 println("\tSimple: <numberPerRisk["simple"]>");
	 println("\tModerate: <numberPerRisk["moderate"]>");
	 println("\tHigh: <numberPerRisk["risk"]>");
	 println("\tVery high: <numberPerRisk["highRisk"]>");
	 println("Rating for unit size: <6 - ratingUnitSize> stars");

	 println("-----------------------------------------------");
	 println("---------        Unit Testing         ---------");
	 println("-----------------------------------------------");
	 println("Number of asserts found: <asserts>"); 
}