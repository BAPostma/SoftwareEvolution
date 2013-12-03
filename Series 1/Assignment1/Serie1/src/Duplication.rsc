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

//  file lines line     duplicates  dup loc     dup line no
map[loc, map[str, list[tuple[loc location, int offset]]]] sources = ();

public void duplicationRatio(M3 project, num totalLoc) {
	m3Project = project;
	
	// load files into cache
	for(file <- files(m3Project)) {
		list[str] lines = readFileLines(file);
		sources = (file: ()) + sources;
		
		for(line <- lines) {
			if(/^\s$/ := line || /[\n|\r|\r\n|\t]+/i := line) continue; // skip on whitespace
			sources[file] += (line: []);
		}
	}
	
	iprintln(sources);
}

public void duplicationRatio(loc project) {
	return duplicationRatio(createM3FromEclipseProject(project), 0);
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

