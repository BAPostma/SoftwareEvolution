module Maintainability

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import analysis::m3::Registry;
import IO;
import List;

import Volume;
import Complexity;
import Duplication;
import UnitSize;

// Ripped from RASCAL and modified to exclude junit/test files
// So, thanks to the developers of Rascal! :-)
public M3 createM3FromProject(loc project) {
  setEnvironmentOptions(classPathForProject(project), sourceRootsForProject(project));
  compliance = getProjectOptions(project)["org.eclipse.jdt.core.compiler.compliance"];
  // Filter out test / junit files!
  theFiles = [x | x <- sourceFilesForProject(project), /test/i !:= x.path || /junit/i !:= x.path];
  result = composeJavaM3(project, { createM3FromFile(f, javaVersion=compliance) | loc f <- theFiles});
  registerProject(project, result);
  return result;
}

/**
 * number of stars: 6 - rating
 * ++ => 1
 * ..
 * -- => 5
 * Create a M3 model with the method createM3FromProject(loc) from this module!
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
	int dupRating = getRatingForDuplication(duplicates);
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
	m3proj = createM3FromProject(project);
	analyze(m3proj);
}