module Complexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import Volume;
import util::Math;

public num cyclometicComplexityProject(M3 project){
	// Collect values for all methods
	map[loc, num] complexityMethods = (); 
	for(method <- methods(project)){
		complexityMethods += (method:cyclometicComplexityPerMethod(method, project));
	}
	histo = convertCCMethodsToRisk(complexityMethods);
	
	return getRatingForChangeability(histo);
}
/**
 * getRatingForChangeability
 * Return rate for CC
 * ++ => 1
 *  + => 2
 *  0 => 3
 *  - => 4
 * -- => 5
 */
public int getRatingForChangeability(map[str, tuple[num, num]] risk){
	num moderate = risk["more_complex"][1];
	num highRisk = risk["complex"][1];
	num veryHighRisk = risk["untestable"][1];
	
	if(moderate <= 25 && highRisk == 0 && veryHighRisk == 0){
		return 1;
	}else if (moderate <= 30 && highRisk <= 5 && veryHighRisk == 0){
		return 2;
	}else if (moderate <= 40 && highRisk <= 10 && veryHighRisk == 0){
		return 3;
	} else if (moderate <= 50 && highRisk <= 15 && veryHighRisk <= 5){
		return 4;
	} else {
		return 5;
	}
}
public map[str, tuple[num, num]] convertCCMethodsToRisk(map[loc, num] methods){
	result = ();
	result += ("simple": <0,0>); // <count, loc>
	result += ("more_complex":<0,0>);
	result += ("complex":<0,0>);
	result += ("untestable":<0,0>);
	
	for(key <- methods){
		num v = methods[key];
		int n = countFileLOC(key);
		println(n);
		if(v <= 10){
			result["simple"][0] += 1;
			result["simple"][1] += n;
		} else if (v >= 11 && v <= 20){
			result["more_complex"][0] += 1;
			result["more_complex"][1] += n;
		} else if(v >= 21 && v <= 50){
			result["complex"][0] += 1;
			result["complex"][1] += n;
		} else {
			result["untestable"][0] += 1;
			result["untestable"][1] += n;
		}
	}
	return convertRiskTableLocToPercentage(result);
}
/**
 * convertRiskTableLocToPercentage
 * Convert absolute number to %.
 * LOC is calculated based on the input.
 * @param toConvert - map[risk, tuple[count, loc]]
 * @return toConvert - map[risk, tuple[count, %]]
 */
private map[str, tuple[num,num]] convertRiskTableLocToPercentage(map[str, tuple[num, num]] toConvert){
	num totalLOC = 0;
	totalLOC += toConvert["simple"][1] + toConvert["more_complex"][1];
	totalLOC += toConvert["complex"][1] + toConvert["untestable"][1];
	
	toConvert["simple"][1] = round((toConvert["simple"][1] / totalLOC) * 100);
	toConvert["more_complex"][1] = round((toConvert["more_complex"][1] / totalLOC) * 100);
	toConvert["complex"][1] = round((toConvert["complex"][1] / totalLOC) * 100);
	toConvert["untestable"][1] = round((toConvert["untestable"][1] / totalLOC) * 100);
	
	return toConvert;
		
}
public int cyclometicComplexityPerMethod(loc method, project){
	ast = getMethodASTEclipse(method, model = project);
	count = 1;
	
	// TODO:: determine if switch counts for 1 or that (all cases and the default count for 1 each)
	visit(ast){
		case \if(_,_) : 					count += 1;
		case \if(_,_,_):					count += 1;
		case \conditional(_,_,_):			count += 1;
		case \case(_) : 					count += 1;
		case \defaultCase():				count += 1;
		case \while(_,_):					count += 1;
		case \do(_,_):						count += 1;
		case \for(_,_,_):					count += 1;
		case \for(_,_,_,_):					count += 1;
		case \foreach(_,_,_):				count += 1;
		case \continue():					count += 1;
		case \break():						count += 1;
		case \try(_,_):						count += 1;
		case \try(_,_,_):					count += 1;
		case \throw(_):						count += 1;
		case \return():						count += 1;
		case \return(_):					count += 1;
	}
	return count;
}