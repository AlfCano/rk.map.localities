// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog
	var varsMerge = getValue("vars_merge");
	var saveMgObj = getValue("save_mg_obj");

	// the R code to be evaluated
	var varsMerge = getValue("vars_merge");
	var saveMgObj = getValue("save_mg_obj");
	echo("objs <- strsplit(\"" + varsMerge + "\", \"\\n\")[[1]]\n");
	echo("objs <- objs[objs != \"\"]\n");
	echo("obj_list <- lapply(objs, get)\n");
	echo("## Merging...\n");
	echo("merged_map <- dplyr::bind_rows(obj_list)\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Merge Maps results")).print();
	var saveMgObj = getValue("save_mg_obj");
	echo("rk.header(\"Spatial Data Merge\")\n");
	echo("rk.print(paste(\"New object features:\", nrow(merged_map)))\n");
	//// save result object
	// read in saveobject variables
	var saveMgObj = getValue("save_mg_obj");
	var saveMgObjActive = getValue("save_mg_obj.active");
	var saveMgObjParent = getValue("save_mg_obj.parent");
	// assign object to chosen environment
	if(saveMgObjActive) {
		echo(".GlobalEnv$" + saveMgObj + " <- merged_map\n");
	}

}

