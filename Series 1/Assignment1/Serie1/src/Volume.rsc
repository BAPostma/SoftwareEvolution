module Volume

import lang::java::jdt::m3::Core;

import Set;
import List;
import IO;
import String;

// Test projects
//M3 smallProject = createM3FromEclipseProject(|project://SmallSql|);
//M3 bigProject = createM3FromEclipseProject(|project://hsqldb|);
//M3 testProject = createM3FromEclipseProject(|project://Tester|);

/**
 * getRatingForAnalysability
 * Return rate for LOC
 * The rate for LOC matches also the man years.
 * ++ => 1
 *  + => 2
 *  0 => 3
 *  - => 4
 * -- => 5
 */
public int getRatingForAnalysability(int numberOfLines){
	if(numberOfLines < 66000) return 1;
	else if(numberOfLines < 246000) return 2;
	else if(numberOfLines < 665000) return 3;
	else if(numberOfLines < 1310000) return 4;
	else return 5;
}

/**
 * countMethods
 * @return int - the number of methods
 */
public int countMethods(M3 project){
	return size(methods(project));
}
/**
 * countClasses
 * @return int - the number of classes
 */
public int countClasses(M3 project){
	return size(classes(project));
}
/**
 * countFiles
 * @return int - the number of files
 */
public int countFiles(M3 project){
	return size(files(project));
}
/**
 * countProjectLOC
 * Count the # of lines of code of the whole project.
 * @return int - number of loc in the project
 */
public num countProjectLOC(M3 project){
	return sum([countFileLOC(x) | x <- files(project)]); 
}
/**
 * countFileLOC
 * Count the number of lines.
 * - comments are removed before counting
 * - newlines are removed before counting
 * @param loc file: the file
 * @return int - the # of lines of code 
 */
public int countFileLOC(loc file){
	file = readFile(file);
	cleanSource = cleanCode(file);
	return size(cleanSource);
}
/**
 * cleanCode
 * Calls:
 * - removeComments
 * - removeEmptyLines
 */
public list[str] cleanCode(str lines){
	tmp = removeComments(lines);
	return removeEmptyLines(tmp);
}
/**
 * removeComment
 * Remove all the comments from the code
 * @param str lines - the lines of codes
 * @return str - lines without comments
 */
public str removeComments(str lines){
	return visit(lines){
		case /\/\*.*?\*\//s => "" // multi line
		case /\/\/.*/		=> "" // single line 
	}
}
/**
 * removeEmptyLines
 * Removes the empty lines from the code
 */
public list[str] removeEmptyLines(str lines){
	r = split("\n", lines);
	return [ x | x <- r, x != "", /^\s+$/ !:= x];	
}