module Duplication

import IO;
import String;
import List;
import Map;
import analysis::m3::AST;
import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import Volume;

M3 m3Project;

//  file lines line     duplicates  dup loc     dup line no
map[loc, map[str, list[tuple[loc location, int offset]]]] sources = ();

public void duplicationRatio(M3 project, num totalLoc) {
	m3Project = project;
	
	// load files into cache
	for(file <- files(m3Project)) {
		list[str] lines = readFileLines(file); // get the raw source lines
		sources += (file: ()); // add the file to the list of sources 
		
		for(line <- lines) {
			if(/^\s$/ := line || /^[\n|\r|\r\n|\t]+$/i := line || line == "") continue; // skip on empty lines
			sources[file] += (line: []);
		}
	}
	
	detectDuplicates();
}

public void duplicationRatio(loc project) {
	return duplicationRatio(createM3FromEclipseProject(project), 0);
}

private void detectDuplicates() {
	//list[str] foundResults = ();
	
	for(source <- sources) {
		lines = sources[source];
		for(line <- lines) {
			result = findDuplicate(line);
			
			if(result.found) {
				println("Found duplicate for: " + line);
				iprintln(result.matches);
				println();
			}
		}
	}
}

private tuple[bool found, list[tuple[loc location, int offset]] matches] findDuplicate(str line) {
	list[tuple[loc location, int offset]] duplicates = [];

	for(source <- sources) {
		lines = [ l | l:_ <- sources[source] ]; // extract a list of raw lines
		lineNr = indexOf(lines, line); // find the line number of the param in the list (1-based)
		
		if(lineNr != -1) {
			duplicates += [<source, lineNr>];
		}
	}
	
	if(size(duplicates) <= 0) {
		return <false, []>;
	} else {
		return <true, duplicates>;
	}
}

public str getRatingForDuplication(tuple[int duplicates, num duplication] result) {
	if(result.duplication <= 3) {
		return "5";
	} else if(result.duplication > 3 && result.duplication <= 5) {
		return "4";
	} else if(result.duplication > 5 && result.duplication <= 10) {
		return "3";
	} else if(result.duplication > 10 && result.duplication <= 20) {
		return "2";
	} else if(result.duplication > 20) {
		return "1";
	}
}

