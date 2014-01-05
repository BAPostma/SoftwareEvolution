module Visual
import Maintainability;
import lang::java::m3::Core;
import vis::Figure;
import vis::Render;
import vis::KeySym;

import IO;
import List;

private M3 projectModel;

public void visualize(M3 model){
	projectModel = model;
	projectName = model.id.authority;
	
	Figure fig = vcat(
				 [
				 text("Project: " + projectName, fontSize(20), fontColor("red")),
				 sigPart(),
				 packagePart(model)
				 ], gap(20)
				 );
	render("Visualization",fig);
}

private Figure packagePart(M3 model){
	pck = packages(model);
	
	tr = tree (
		box(text("Packages"), fillColor("white")),
		[ellipse(text(x.path), 
				fillColor("white"), 
				packageClickable(x), 
				popup("Number of files: <size(filesFromPackage(model, x))>")) | x <- pck],
		std(gap(25)), std(shadow(true))
	);
	
	return box(tr, lineColor("black"), gap(20), fillColor("lightgrey"));
}
private Figure sigPart(){
	Figure linesOC = hcat(
					[
						text("Lines of code:", hsize(100)),
						box(text("++"), fillColor("green"), popup("18950"))
					], hgap(10)
					);
	Figure codeC = hcat (
					[
						text("Code complexity:", hsize(100)),
						hcat (
						[
							box(fillColor("green"), hshrink(0.69), popup("Simple: 69%")),
							box(fillColor("chartreuse"), hshrink(0.15), popup("Complex: 15%")),
							box(fillColor("orange"), hshrink(0.10), popup("More complex: 10%")),
							box(text("--"),fillColor("red"), hshrink(0.06), popup("Untestable: 6%"))
						]
						)
					], hgap(10)
					);
	Figure duplication = hcat (
						[
							text("Duplication:", hsize(100)),
							box(box(text("+"),hshrink(0.03), left(), fillColor("Chartreuse"), popup("3.482849% duplication (+)"), shadow(false))
								,fillColor("DarkSeaGreen"))
						], hgap(10)
						);
	Figure unitSize = hcat (
					[
						text("Unit size:", hsize(110)),
						hcat([
							box(fillColor("green"), hshrink(0.86), popup("Simple: 1824 (86%)")),
							box(text("+"),fillColor("chartreuse"), hshrink(0.12), popup("Moderate: 260 (12%)")),
							box(fillColor("orange"), hshrink(0.01), popup("High: 31(1%)")),
							box(fillColor("red"), hshrink(0.01), popup("Very high: 9 (~0%)"))
							]
						)
					]
					);
	return box(vcat([linesOC, codeC, duplication, unitSize], gap(15)), 
				lineColor("black"), fillColor("lightgrey"), gap(25), std(shadow(true)));
}
private FProperty packageClickable(loc package){
	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
		renderPackageOverview(package);
		return true;
	});
}
private void renderPackageOverview(loc package){
	fs = filesFromPackage(projectModel, package);
	
	render(box(text(package.path), fillColor("green")));
}
public FProperty popup(str message){
	return mouseOver(box(text(" " + message + " "), fillColor("yellow"), resizable(false)));
}
public list[loc] filesFromPackage(M3 project, loc package){
	return [ x[1] | x <- project@containment, x[0] == package ]; 
}