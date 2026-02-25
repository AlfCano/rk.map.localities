local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.map.localities"
  plugin_ver <- "0.0.3"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "Tools for downloading Admin Level 2 spatial data (geodata), plus importing, exporting, and merging 'sf' objects.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.map.localities",
      license = "GPL (>= 3)"
    )
  )

  # Shared Dependencies
  dependencies_node <- rk.XML.dependencies(
    dependencies = list(rkward.min = "0.7.5"),
    package = list(
      c(name = "sf"),
      c(name = "geodata"),
      c(name = "dplyr")
    )
  )

  # =========================================================================================
  # 2. MAIN LOGIC: Download Municipalities
  # =========================================================================================

  iso_codes <- list(
      "Mexico (MEX)" = list(val = "MEX", chk = TRUE),
      "United States (USA)" = list(val = "USA"),
      "Canada (CAN)" = list(val = "CAN"),
      "Brazil (BRA)" = list(val = "BRA"),
      "Argentina (ARG)" = list(val = "ARG"),
      "Colombia (COL)" = list(val = "COL"),
      "Spain (ESP)" = list(val = "ESP"),
      "France (FRA)" = list(val = "FRA"),
      "Germany (DEU)" = list(val = "DEU"),
      "Italy (ITA)" = list(val = "ITA"),
      "United Kingdom (GBR)" = list(val = "GBR")
  )

  drp_country <- rk.XML.dropdown(label = "Select Country", id.name = "drp_iso", options = iso_codes)
  inp_custom_iso <- rk.XML.input(label = "Or custom ISO-3 Code", id.name = "inp_iso_custom", size = "small")
  inp_state <- rk.XML.input(label = "Filter by State/Region Name", id.name = "inp_state_name", required = FALSE)
  note_state <- rk.XML.text("<b>Note:</b> Type the exact name of the region (Admin Level 1) as it appears in GADM. Leave empty to download the whole country.")

  # Initial is HARDCODED "map_muni". RKWard handles the user mapping automatically.
  save_sf <- rk.XML.saveobj(label = "Save Map Object As (sf)", initial = "map_muni", id.name = "save_obj", chk = TRUE)

  main_dialog <- rk.XML.dialog(
      label = "Download Municipalities (Admin 2)",
      rk.XML.col(
          rk.XML.frame(label = "1. Select Country", drp_country, inp_custom_iso),
          rk.XML.frame(label = "2. Filter Region", note_state, inp_state),
          rk.XML.stretch(),
          save_sf
      )
  )

  js_calc_main <- rk.paste.JS(
    rk.JS.vars(drp_country, inp_custom_iso, inp_state, save_sf),

    echo("iso <- \"", drp_country, "\"\n"),
    echo("custom <- \"", inp_custom_iso, "\"\n"),
    echo("if (custom != \"\") iso <- custom\n\n"),

    echo("## 1. Download GADM Data (Level 2: Municipalities/Counties)\n"),
    echo("gadm_vect <- geodata::gadm(country = iso, level = 2, path = tempdir())\n"),
    echo("map_country_sf <- sf::st_as_sf(gadm_vect)\n\n"),

    echo("state_filter <- \"", inp_state, "\"\n"),
    echo("if (state_filter != \"\") {\n"),
    echo("  ## 2. Filter by State (NAME_1)\n"),
    echo("  map_muni <- subset(map_country_sf, NAME_1 == state_filter)\n"),
    echo("  if (nrow(map_muni) == 0) warning(paste(\"No municipalities found for state:\", state_filter, \"- Check capitalization or spelling.\"))\n"),
    echo("} else {\n"),
    echo("  map_muni <- map_country_sf\n"),
    echo("}\n\n"),

    echo("## Result is in 'map_muni'\n")
  )

  js_print_main <- rk.paste.JS(
    rk.JS.vars(save_sf),
    echo("rk.header(\"Municipalities Map Downloaded\")\n"),
    echo("rk.print(paste(\"Features downloaded:\", nrow(map_muni)))\n"),
    echo("rk.header(\"Map Columns Available (For Matching)\", level=4)\n"),
    echo("rk.print(\"Use one of these columns as the 'Map Id Column' in the Plotter plugins:\")\n"),
    echo("rk.print(names(map_muni))\n")
    # REMOVED: The manual assignment block. RKWard does .GlobalEnv$UserVar <- map_muni automatically.
  )

  # =========================================================================================
  # 3. COMPONENT: Import Spatial Data
  # =========================================================================================

  inp_file_imp <- rk.XML.browser(label = "Select Spatial File (SHP, GPKG, GEOJSON)", id.name = "browser_imp", type = "file", filter = c("*.shp", "*.gpkg", "*.geojson", "*.kml"))
  save_imp <- rk.XML.saveobj(label = "Save as R Object", initial = "imported_map", id.name = "save_imp_obj", chk = TRUE)

  dlg_imp <- rk.XML.dialog(
    label = "Import Spatial Data",
    rk.XML.col(inp_file_imp, rk.XML.stretch(), save_imp)
  )

  js_calc_imp <- rk.paste.JS(
    rk.JS.vars(inp_file_imp, save_imp),
    echo("## Import Spatial Data\n"),
    echo("imported_map <- sf::st_read(\"", inp_file_imp, "\")\n")
  )

  js_print_imp <- rk.paste.JS(
    rk.JS.vars(save_imp, inp_file_imp),
    echo("rk.header(\"Spatial Data Import\")\n"),
    echo("rk.print(paste(\"Source:\", \"", inp_file_imp, "\"))\n")
  )

  comp_imp <- rk.plugin.component("Import Spatial Data", xml = list(dialog = dlg_imp), js = list(calculate = js_calc_imp, printout = js_print_imp), hierarchy = list("plots", "Maps"), dependencies = dependencies_node)

  # =========================================================================================
  # 4. COMPONENT: Export Spatial Data
  # =========================================================================================

  var_sel_ex <- rk.XML.varselector(id.name = "vs_export")
  vars_ex <- rk.XML.varslot(label = "Select sf object to export", source = var_sel_ex, required = TRUE, classes = c("sf", "data.frame"), id.name = "var_export")
  inp_file_exp <- rk.XML.browser(label = "Save to File", id.name = "browser_exp", type = "savefile", filter = c("*.shp", "*.gpkg", "*.geojson"))
  chk_over <- rk.XML.cbox(label = "Overwrite if file exists (delete_dsn = TRUE)", id.name = "chk_over", value = "TRUE", chk = FALSE)

  dlg_exp <- rk.XML.dialog(
    label = "Export Spatial Data",
    rk.XML.row(var_sel_ex, rk.XML.col(vars_ex, inp_file_exp, chk_over, rk.XML.stretch()))
  )

  js_calc_exp <- rk.paste.JS(
    rk.JS.vars(vars_ex, inp_file_exp, chk_over),
    echo("opts <- if(\"", chk_over, "\" == \"TRUE\") list(delete_dsn = TRUE) else list()\n"),
    echo("do.call(sf::st_write, c(list(obj = ", vars_ex, ", dsn = \"", inp_file_exp, "\"), opts))\n")
  )

  comp_exp <- rk.plugin.component("Export Spatial Data", xml = list(dialog = dlg_exp), js = list(calculate = js_calc_exp), hierarchy = list("plots", "Maps"), dependencies = dependencies_node)

  # =========================================================================================
  # 5. COMPONENT: Merge Maps
  # =========================================================================================

  var_sel_mg <- rk.XML.varselector(id.name = "vs_merge")
  vars_mg <- rk.XML.varslot(label = "Select maps to merge (2 or more)", source = var_sel_mg, multi = TRUE, required = TRUE, classes = c("sf", "data.frame"), id.name = "vars_merge")
  save_mg <- rk.XML.saveobj(label = "Save merged map as", initial = "merged_map", id.name = "save_mg_obj", chk = TRUE)
  note_mg <- rk.XML.text("<b>Note:</b> Maps must have the same geometry type (e.g., Polygon) and Coordinate Reference System (CRS).")

  dlg_mg <- rk.XML.dialog(
    label = "Merge Maps",
    rk.XML.row(var_sel_mg, rk.XML.col(vars_mg, note_mg, rk.XML.stretch(), save_mg))
  )

  js_calc_mg <- rk.paste.JS(
    rk.JS.vars(vars_mg, save_mg),
    echo("objs <- strsplit(\"", vars_mg, "\", \"\\n\")[[1]]\n"),
    echo("objs <- objs[objs != \"\"]\n"),
    echo("obj_list <- lapply(objs, get)\n"),
    echo("## Merging...\n"),
    echo("merged_map <- dplyr::bind_rows(obj_list)\n")
  )

  js_print_mg <- rk.paste.JS(
    rk.JS.vars(save_mg),
    echo("rk.header(\"Spatial Data Merge\")\n"),
    echo("rk.print(paste(\"New object features:\", nrow(merged_map)))\n")
  )

  comp_mrg <- rk.plugin.component("Merge Maps", xml = list(dialog = dlg_mg), js = list(calculate = js_calc_mg, printout = js_print_mg), hierarchy = list("plots", "Maps"), dependencies = dependencies_node)

  # =========================================================================================
  # 6. Assembly
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    # MAIN COMPONENT
    xml = list(dialog = main_dialog),
    js = list(
        require = c("geodata", "sf", "dplyr"),
        calculate = js_calc_main,
        printout = js_print_main
    ),
    # SECONDARY COMPONENTS
    components = list(comp_imp, comp_exp, comp_mrg),
    pluginmap = list(
        name = "Download Municipalities",
        hierarchy = list("plots", "Maps", "Download")
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.map.localities' (v0.0.3) generated successfully.\n")
})
