module TestVis

import IO;
import String;
import List;
import analysis::m3::AST;
import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;

import vis::Figure;
import vis::Render;

private map[str, num] cocs;

public void Visualise() {
	cocs = ("Main": 12.5,
			"BusinessLogic": 63,
			"UI": 10,
			"Unit Testing": 15
			);
	
	render(buildGfx());
}

private value buildGfx() {
	value w = wedge(fillColor("green"));

	return w;
}