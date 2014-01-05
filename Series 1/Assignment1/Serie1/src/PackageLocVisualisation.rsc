module PackageLocVisualisation

import IO;
import String;
import List;
import analysis::m3::AST;
import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import util::Math;
import vis::Figure;
import vis::Render;

import UnitSize;
import Volume;

public void Visualise() {
	//M3 proj = createM3FromEclipseProject(|project://Series1%20Testproject/|);
	M3 proj = createM3FromEclipseProject(|project://smallsql0.21_src/|);
	//M3 proj = createM3FromEclipseProject(|project://hsqldb-2.3.1/|);
	
	list[Figure] packageFigures = [];
	
	num totalLoc = countProjectLOC(proj);
		
	for(package <- packages(proj)) {
		int packageLoc = getPackageLoc(proj, package);
		if(packageLoc <= 0) continue;
		num percentage = (packageLoc / totalLoc) * 100;
		if(percentage < 1) percentage = 1;
		percentage *= 2; // multiply to give each 1/100 part a reasonable size in pixels
		
		Figure fig = box(size(percentage, percentage), fillColor(arbColor()), mouseOver(box(text("<package.path> | LOC: <packageLoc>"), fillColor("lightGray")))); 
		packageFigures += fig;
	}
	
	render(tree(box(text("Packages")), packageFigures, std(gap(20))));
}

private int getPackageLoc(M3 proj, loc location) {
	elems = elements(proj, location);
	
	set[loc] classes = {};
	
	for(elem <- elems) {
		if(isCompilationUnit(elem)) {
			for(el <- elements(proj, elem)) {
				if(isClass(el)) {
					classes += el;
				}
			}
		}
	}
	
	int packageLoc = 0;
	for(cl <- classes) {
		packageLoc += countFileLOC(cl);
	}
	
	//DEBUG line
	//println("Loc for package <location.path> is <packageLoc>");
	return packageLoc;
}


