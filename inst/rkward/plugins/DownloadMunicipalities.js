// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(geodata)\n");	echo("require(sf)\n");	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var iso = getValue("drp_iso");
    var custom = getValue("inp_iso_custom");
    if (custom && custom !== "") { iso = custom; }

    var state = getValue("inp_state_name");

    echo("## 1. Download GADM Data (Level 2: Municipalities/Counties)\n");
    echo("gadm_vect <- geodata::gadm(country = \"" + iso + "\", level = 2, path = tempdir())\n");
    echo("map_country_sf <- sf::st_as_sf(gadm_vect)\n\n");

    if (state !== "") {
        echo("## 2. Filter by State (NAME_1)\n");
        echo("map_muni <- subset(map_country_sf, NAME_1 == \"" + state + "\")\n");
        echo("if (nrow(map_muni) == 0) warning(\"No municipalities found for state: " + state + ". Check capitalization or spelling.\")\n");
    } else {
        echo("map_muni <- map_country_sf\n");
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Download Municipalities results")).print();

    echo("rk.header(\"Municipalities Map Downloaded\")\n");
    echo("rk.print(paste(\"Features downloaded:\", nrow(map_muni)))\n");

    echo("rk.header(\"Map Columns Available (For Matching)\", level=4)\n");

    // FIX: Escaped the single quotes around Map Id Column using backslash (\'...\')
    echo("rk.print(\"Use one of these columns as the \'Map Id Column\' in the Plotter plugins:\")\n");

    echo("rk.print(names(map_muni))\n");

    echo("rk.header(\"Preview Data\", level=4)\n");
    echo("rk.print(head(map_muni[, c(\"NAME_1\", \"NAME_2\")]))\n");

    // FIX: Applied Golden Rule #3 (Simple assignment matching the saveobj contract)
    if (getValue("save_obj.active")) {
        echo(getValue("save_obj") + " <- map_muni\n");
    }
  
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

