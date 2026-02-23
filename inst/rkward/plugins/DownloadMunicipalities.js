// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(geodata)\n");	echo("require(sf)\n");	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog
	var drpIso = getValue("drp_iso");
	var inpIsoCustom = getValue("inp_iso_custom");
	var inpStateName = getValue("inp_state_name");
	var saveObj = getValue("save_obj");

	// the R code to be evaluated
	var drpIso = getValue("drp_iso");
	var inpIsoCustom = getValue("inp_iso_custom");
	var inpStateName = getValue("inp_state_name");
	var saveObj = getValue("save_obj");
	echo("iso <- \"" + drpIso + "\"\n");
	echo("custom <- \"" + inpIsoCustom + "\"\n");
	echo("if (custom != \"\") iso <- custom\n\n");
	echo("## 1. Download GADM Data (Level 2: Municipalities/Counties)\n");
	echo("gadm_vect <- geodata::gadm(country = iso, level = 2, path = tempdir())\n");
	echo("map_country_sf <- sf::st_as_sf(gadm_vect)\n\n");
	echo("state_filter <- \"" + inpStateName + "\"\n");
	echo("if (state_filter != \"\") {\n");
	echo("  ## 2. Filter by State (NAME_1)\n");
	echo("  map_muni <- subset(map_country_sf, NAME_1 == state_filter)\n");
	echo("  if (nrow(map_muni) == 0) warning(paste(\"No municipalities found for state:\", state_filter, \"- Check capitalization or spelling.\"))\n");
	echo("} else {\n");
	echo("  map_muni <- map_country_sf\n");
	echo("}\n\n");
	echo("## Result is in 'map_muni'\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Download Municipalities results")).print();
	var saveObj = getValue("save_obj");
	echo("rk.header(\"Municipalities Map Downloaded\")\n");
	echo("rk.print(paste(\"Features downloaded:\", nrow(map_muni)))\n");
	echo("rk.header(\"Map Columns Available (For Matching)\", level=4)\n");
	echo("rk.print(\"Use one of these columns as the 'Map Id Column' in the Plotter plugins:\")\n");
	echo("rk.print(names(map_muni))\n");
	//// save result object
	// read in saveobject variables
	var saveObj = getValue("save_obj");
	var saveObjActive = getValue("save_obj.active");
	var saveObjParent = getValue("save_obj.parent");
	// assign object to chosen environment
	if(saveObjActive) {
		echo(".GlobalEnv$" + saveObj + " <- map_muni\n");
	}

}

