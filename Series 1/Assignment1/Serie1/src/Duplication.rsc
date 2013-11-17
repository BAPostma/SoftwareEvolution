module Duplication

import IO;
import String;
import List;
import analysis::m3::AST;
import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import Volume;

M3 m3Project;

public num duplicationRatio(loc project) {
	m3Project = createM3FromEclipseProject(project);
	
	if(isEmpty(m3Project)) return 0;
	
	int duplicates = 0;
	for(file <- files(m3Project)) {
		duplicates += processMethods(file);
	}
	
	num projectLoc = countProjectLOC(m3Project);
	num percentage = (duplicates / projectLoc) * 100;
	
	println("Duplicates: <duplicates>");
	println("Total LOC: <projectLoc>");
	println("Percentage duplicate: <percentage>");
	
	return percentage; // % of total project
}

private int processMethods(loc file) {
	M3 m3File = createM3FromFile(file);
	
	set[loc] methods = { m | m <- methods(m3File) };
	
	int duplicationCount = 0;
	for(method <- methods) {
		sourceLines = readFileLines(method);
		int duplicates = findDuplicates(sourceLines);
		duplicationCount += duplicates;
	}
	
	return duplicationCount;
}

private int findDuplicates(list[str] source) {
	int rowIndex = 0;
	list[str] section = getNextSection(source, rowIndex);
	
	int foundCount = 0;
	while(size(section) > 0) {
		// find in project
		int intersections = findInAllFiles(toCleanString(section));
		
		// if found, increment counter for this section
		if(intersections > 0) {
			foundCount += intersections;
		}
		
		rowIndex += 1;
		section = getNextSection(source, rowIndex);
	}
	
	return foundCount;
}

private int findInAllFiles(str sourceExcerpt) {
	for(file <- files(m3Project)) {
		str lines = readFile(file);
				
		list[int] intersection = findAll(lines, sourceExcerpt);
		if(size(intersection) > 0) {
			return size(intersection);
		}
	}
	return 0;
}

private list[str] getNextSection(list[str] source, int rowIndex) {
	int numElements = size(source);
	int startIndex = rowIndex;	
	int endIndex = (numElements <= 6) || (startIndex + 7 >= numElements) ? numElements - 1 : startIndex + 6;
	
	if(startIndex > numElements || startIndex > endIndex) return [];
		
	return [retVal | retVal <- source[startIndex..(endIndex + 1)] ];
}

//private str extractMethodBody(str source) {
//	return visit(source) {
//		case /.*\{/si => ""
//		case /^(public|private|protected).*\{[\r|\n|\r\n]?$/si => ""
//	}
//}

private str toCleanString(list[str] input) {
	str retVal = "";
	
	for(i <- input) {
		retVal += i;
	}
	
	return retVal;
}



