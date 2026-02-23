local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.map.localities"
  plugin_ver <- "0.0.1"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "Downloads Admin Level 2 (Municipalities/Counties) spatial data using the 'geodata' package.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.map.localities",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # 2. COMPONENT: Download Municipalities
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

  # State/Region Filter
  inp_state <- rk.XML.input(label = "Filter by State/Region Name", id.name = "inp_state_name", required = FALSE)
  note_state <- rk.XML.text("<b>Note:</b> Type the exact name of the region (Admin Level 1) as it appears in GADM. Leave empty to download the whole country.")

  # Output
  # Rule #3: Initial name is "map_muni"
  save_sf <- rk.XML.saveobj(label = "Save Map Object As (sf)", initial = "map_muni", id.name = "save_obj", chk = TRUE)

  # Dialog
  main_dialog <- rk.XML.dialog(
      label = "Download Municipalities (Admin 2)",
      child = rk.XML.col(
          rk.XML.frame(label = "1. Select Country",
              drp_country,
              inp_custom_iso
          ),
          rk.XML.frame(label = "2. Filter Region",
              note_state,
              inp_state
          ),
          rk.XML.stretch(),
          save_sf
      )
  )

  # JS Logic
  js_calc <- '
    var iso = getValue("drp_iso");
    var custom = getValue("inp_iso_custom");
    if (custom && custom !== "") { iso = custom; }

    var state = getValue("inp_state_name");

    echo("## 1. Download GADM Data (Level 2: Municipalities/Counties)\\n");
    echo("gadm_vect <- geodata::gadm(country = \\"" + iso + "\\", level = 2, path = tempdir())\\n");
    echo("map_country_sf <- sf::st_as_sf(gadm_vect)\\n\\n");

    if (state !== "") {
        echo("## 2. Filter by State (NAME_1)\\n");
        echo("map_muni <- subset(map_country_sf, NAME_1 == \\"" + state + "\\")\\n");
        echo("if (nrow(map_muni) == 0) warning(\\"No municipalities found for state: " + state + ". Check capitalization or spelling.\\")\\n");
    } else {
        echo("map_muni <- map_country_sf\\n");
    }
  '

  js_print <- '
    echo("rk.header(\\"Municipalities Map Downloaded\\")\\n");
    echo("rk.print(paste(\\"Features downloaded:\\", nrow(map_muni)))\\n");

    echo("rk.header(\\"Map Columns Available (For Matching)\\", level=4)\\n");

    // FIX: Escaped the single quotes around Map Id Column using backslash (\\\'...\\\')
    echo("rk.print(\\"Use one of these columns as the \\\'Map Id Column\\\' in the Plotter plugins:\\")\\n");

    echo("rk.print(names(map_muni))\\n");

    echo("rk.header(\\"Preview Data\\", level=4)\\n");
    echo("rk.print(head(map_muni[, c(\\"NAME_1\\", \\"NAME_2\\")]))\\n");

    // FIX: Applied Golden Rule #3 (Simple assignment matching the saveobj contract)
    if (getValue("save_obj.active")) {
        echo(getValue("save_obj") + " <- map_muni\\n");
    }
  '

  # =========================================================================================
  # 3. Assembly
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = main_dialog),
    js = list(
        require = c("geodata", "sf", "dplyr"),
        calculate = js_calc,
        printout = js_print
    ),
    pluginmap = list(
        name = "Download Municipalities",
        hierarchy = list("plots", "Maps"),
        # Use a safe ID
        po_id = "rk_map_localities"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.map.localities' (v0.0.1) generated successfully.\n")
})
