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

map[loc,str] fileCache = ();

map[loc,value] firstOccurrences = ();
map[loc,value] occurrences = ();
bool foundADuplicate = false;

public tuple[int duplicates, num duplication] duplicationRatio(M3 project, num totalLoc) {
	m3Project = project;
	
	// load files into cache
	for(file <- files(m3Project)) {
		// create a map of locations associated with the file contents
		str lines = readFile(file);
		fileCache = (file: lines) + fileCache;
	}
	
	// traverse the files and check each file's methods for duplicates
	for(file <- files(m3Project)) {
		//println("Checking <file>...");
		processFileMethods(file);
	}
	
	//println("Found originals:");
	//iprintln(firstOccurrences);
	
	//println("Found duplicates:");
	//iprintln(occurrences);
	
	// Calculate end-result percentage
	int duplicates = size([ k | k:_ <- firstOccurrences ]) + size([ k | k:_ <- occurrences ]);
	num projectLoc = totalLoc;
	num percentage = (duplicates / projectLoc) * 100;
		
	tuple[int duplicates, num duplication] returnValue = <duplicates, percentage>;
	return returnValue;
}

private void processFileMethods(loc file) {
	M3 m3File = createM3FromFile(file);
	
	set[loc] methods = { m | m <- methods(m3File) };
	
	for(method <- methods) {
		sourceLines = readFileLines(method);
		
		findDuplicates(sourceLines, file);
		
		if(foundADuplicate) {
			// if a duplicate was found, add the 'original' to the list of firstOccurrences
			firstOccurrences = (method: toCleanString(sourceLines)) + firstOccurrences;
		}
		
		foundADuplicate = false; // reset after processing every method
	}
}

private void findDuplicates(list[str] source, loc original) {
	int rowIndex = 0;
	list[str] section = getNextSection(source, rowIndex);
	
	int sectionsFoundCount = 0;
	int duplicatesFoundCount = 0;
	while(size(section) > 0) {
		str excerpt = toCleanString(section);
		int intersections = findInAllFiles(excerpt, original);
		
		if(intersections > 0) {
			foundADuplicate = true;
			occurrences = (original: excerpt) + occurrences;
			rowIndex += 7;
		} else {
			rowIndex += 1;
		}
		
		section = getNextSection(source, rowIndex);
	}
}

private int findInAllFiles(str sourceExcerpt, loc original) {
	for(file <- fileCache) {
		str lines = fileCache[file];
		
		list[int] intersection = findAll(lines, sourceExcerpt);
		int intersections = size(intersection);
		
		if(intersections > 0) { // && file != original) {
			return intersections; // return number of duplicates found
		}
	}
	
	return 0;
}

private list[str] getNextSection(list[str] source, int rowIndex) {
	int numElements = size(source);
	int startIndex = rowIndex;	
	int endIndex = startIndex + 7;
	
	if(numElements <= 7 || startIndex >= numElements || startIndex >= endIndex || endIndex >= numElements) return [];
	
	return [ retVal | retVal <- source[startIndex..(endIndex + 1)] ];
}

private str toCleanString(list[str] input) {
	str retVal = "";
	
	for(i <- input) {
		retVal += i + "\r\n";
	}
	
	return retVal;
}

public str getRatingForDuplication(tuple[int duplicates, num duplication] result) {
	if(result.duplication <= 3) {
		return "++";
	} else if(result.duplication > 3 && result.duplication <= 5) {
		return "+";
	} else if(result.duplication > 5 && result.duplication <= 10) {
		return "o";
	} else if(result.duplication > 10 && result.duplication <= 20) {
		return "-";
	} else if(result.duplication > 20) {
		return "--";
	}
}

