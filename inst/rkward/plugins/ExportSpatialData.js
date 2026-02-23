// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog
	var varExport = getValue("var_export");
	var browserExp = getValue("browser_exp");
	var chkOver = getValue("chk_over");

	// the R code to be evaluated
	var varExport = getValue("var_export");
	var browserExp = getValue("browser_exp");
	var chkOver = getValue("chk_over");
	echo("opts <- if(\"" + chkOver + "\" == \"TRUE\") list(delete_dsn = TRUE) else list()\n");
	echo("do.call(sf::st_write, c(list(obj = " + varExport + ", dsn = \"" + browserExp + "\"), opts))\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Export Spatial Data results")).print();

}

