module UnitSize

import Volume;

import lang::java::jdt::m3::Core;
import Map;
import util::Math;

import IO;

/**
 * Information:
 * moderate: > 10 && <= 50
 * risk:> 50 && <= 100
 * very high risk: >100 
 */
  public int calculateRatingForUnitSize(M3 project){
 	tmp = getUnitSizePerMethod(project);
 	
 	numbers = determinePercentagePerRisk(determineNumberPerRisk(tmp));
 	println("<numbers>");
 	return getRating(numbers);
 } 
/**
 * getRating
 * ++ => 1
 *  + => 2
 *  0 => 3
 *  - => 4
 * -- => 5
 */
public int getRating(map[str, num] numbers){
	num moderate = numbers["moderate"];
	num risk = numbers["risk"];
	num highRisk = numbers["highRisk"];
		
	if(moderate < 25 && risk == 0 && highRisk == 0){
		return 1;
	}else if (moderate < 30 && risk < 5 && highRisk == 0){
		return 2;
	}else if(moderate < 40 && risk < 10 && highRisk == 0){
		return 3;
	}else if(moderate < 50 && risk < 15 && highRisk < 5){
		return 4;
	} else {
		return 5;
	}
}
/**
 * getUnitSizePerMethod
 * Returns the loc for each method in a map
 * @returns map[loc, num] where loc = the method, num = loc
 */
private map[loc, num] getUnitSizePerMethod(M3 project){
	// This works just fine BUT it does also counts the signature and the closing } as LOC
	return (method:countFileLOC(method) | method <- methods(project));
}
/**
 * determineNumberPerRisk
 * Determine the number of different level of risk
 */
public map[str, num] determineNumberPerRisk(map[loc, num] sizes){
	result = ();
	result += ("simple":0);
	result += ("moderate": 0);
	result += ("risk": 0);
	result += ("highRisk": 0);
	
	for(x <- sizes){
		num v = sizes[x];
		if (v <= 10){
			result["simple"] += 1;
		}else if(v > 10 && v <= 50){
			result["moderate"] += 1;
		} else if (v > 50 && v <= 100){
			result["risk"] += 1;
		} else if (v > 100) {
			result["highRisk"] += 1;
		}
	}	
	return result;
}
public map[str, num] determinePercentagePerRisk(map[str, num] risks){
	num total =  risks["moderate"] + risks["risk"] + risks["highRisk"] + risks["simple"];
	
	if(total==0){
		risks["moderate"] = 0;
		risks["risk"] = 0;
		risks["highRisk"] = 0;
		return risks;
	}	
	risks["moderate"] = round((risks["moderate"] / total) * 100);
	risks["risk"] = round((risks["risk"] / total) * 100);
	risks["highRisk"] = round((risks["highRisk"] / total) * 100);
	return risks;
}