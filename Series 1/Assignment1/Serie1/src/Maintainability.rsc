module Maintainability

import lang::java::jdt::m3::Core;
import IO;
import List;

import Volume;
import Complexity;
import Duplication;
import UnitSize;

/**
 * number of stars: 6 - rating
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
	
	convertedCCMethods = convertCCMethodsToRisk(methodInfo);
	ccRating = getRatingForChangeability(convertRiskTableLocToPercentage(convertedCCMethods));
	println("\tComplexiting rating gathered");
	
	println("Calculating code duplication");
	tuple[int duplicates, num duplication] duplicates = duplicationRatio(project, totalLoc);
	println("Duplication calculation completed");
	str dupRating = getRatingForDuplication(duplicates);
	println("\tDuplication rating gathered");
	
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
	 println("Simple methods: <convertedCCMethods["simple"][0]>");
	 println("Moderate methods: <convertedCCMethods["more_complex"][0]>");
	 println("High risk methods: <convertedCCMethods["complex"][0]>");
	 println("Very high risk methods: <convertedCCMethods["untestable"][0]>");
	 
	 
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
	 println("--------         Duplication          ---------");
	 println("-----------------------------------------------");
	 println("Total duplicates: <duplicates.duplicates>");
	 println("Duplication %: <duplicates.duplication>");
	 println("Rating for duplication: <dupRating> stars");

	 println("-----------------------------------------------");
	 println("---------        Unit Testing         ---------");
	 println("-----------------------------------------------");
	 println("Number of asserts found: <asserts>"); 
}

public void analyze(loc project) {
	m3proj = createM3FromEclipseProject(project);
	analyze(m3proj);
}