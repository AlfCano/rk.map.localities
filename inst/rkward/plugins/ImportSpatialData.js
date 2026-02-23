// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog
	var browserImp = getValue("browser_imp");
	var saveImpObj = getValue("save_imp_obj");

	// the R code to be evaluated
	var browserImp = getValue("browser_imp");
	var saveImpObj = getValue("save_imp_obj");
	echo("## Import Spatial Data\n");
	echo("imported_map <- sf::st_read(\"" + browserImp + "\")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Import Spatial Data results")).print();
	var saveImpObj = getValue("save_imp_obj");
	var browserImp = getValue("browser_imp");
	echo("rk.header(\"Spatial Data Import\")\n");
	echo("rk.print(paste(\"Source:\", \"" + browserImp + "\"))\n");
	//// save result object
	// read in saveobject variables
	var saveImpObj = getValue("save_imp_obj");
	var saveImpObjActive = getValue("save_imp_obj.active");
	var saveImpObjParent = getValue("save_imp_obj.parent");
	// assign object to chosen environment
	if(saveImpObjActive) {
		echo(".GlobalEnv$" + saveImpObj + " <- imported_map\n");
	}

}

