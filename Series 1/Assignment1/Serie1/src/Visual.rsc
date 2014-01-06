module Visual
import Maintainability;
import lang::java::m3::Core;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::java::m3::Registry;
import IO;
import List;
import Map;

private M3 projectModel;
private map[loc, tuple[num cc, num asserts, num lines]] methodInfo;

public void visualize(M3 model, map[loc, tuple[num cc, num asserts, num lines]] methodInformation){
	projectModel = model;
	methodInfo = methodInformation;
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
	ds = projectModel@declarations;
	
	// The methods in this package!
	ms = [ d | f <- fs, d <- ds, d[1].path == f.path, isMethod(d[0])];
	
	list[Figure] lijst = [];
	tuple[num cc, num asserts, num lines] inf;
	for(m <- ms){
		inf = methodInfo[m[0]];
		lijst+= box(size(10), 
					popup(m[0].path + "\nLOC: <inf.lines>\nCC: <inf.cc>"), 
					editOnClick(m[0]),
					fillColorForCC(inf.cc));
	}
	render(
		vcat(
		[
			text("Method overview for package: " + package.path, fontColor("red"), fontSize(20)),
			hcat(
				[
					text("Legenda:"),
					box(text("++"), size(20), fillColor("green")),
					box(text("+"), size(20), fillColor("chartreuse")),
					box(text("-"), size(20), fillColor("orange")),
					box(text("--"), size(20), fillColor("red"))
				], std(resizable(false)), std(gap(10))
			),
			box(
					pack(lijst, std(gap(5)))
				)
		], std(gap(10))
		)
	);
}
public FProperty fillColorForCC(num cc){
	str c = "green";
	
	if(cc <= 10){
		c = "green"; 
	} else if ( cc > 10 && cc <= 20){
		c = "chartreuse";
	} else if ( cc > 20 && cc <= 50){
		c = "orange";
	} else {
		c = "red";
	}
	
	return fillColor(c);
}
public FProperty editOnClick(loc toEdit){
	return onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
                edit(resolveJava(toEdit)); 
                return true;
        	});
}
public FProperty popup(str message){
	return mouseOver(box(text(" " + message + " "), fillColor("yellow"), resizable(false)));
}
public list[loc] filesFromPackage(M3 project, loc package){
	return [ x[1] | x <- project@containment, x[0] == package ]; 

}