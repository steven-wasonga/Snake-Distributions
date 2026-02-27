library(shiny)
library(bslib)
library(leaflet)
library(sf)
library(dplyr)

# ==============================================================================
# SPECIES DATA — 13 medically important Kenyan snakes
# ==============================================================================

snake_names <- c(
  "Puff Adder",
  "Black Mamba",
  "Green Mamba",
  "Boomslang",
  "Red Spitting Cobra",
  "Black Necked Spitting Cobra",
  "Large Brown Spitting Cobra",
  "Carpet Viper",
  "Eastern Forest Cobra",
  "Egyptian Cobra",
  "Gaboon Viper",
  "Rhinoceros Viper",
  "Jameson Mamba"
)

snake_meta <- list(
  "Puff Adder" = list(
    sci        = "Bitis arietans",
    venom      = "Cytotoxic / Hemotoxic",
    length     = "1.0 – 1.5 m",
    appearance = "Stocky body with a broad triangular head. Sandy tan to dark brown with 18–22 dark chevron bands across the back; belly pale yellow. Strongly keeled scales give a rough, matte texture.",
    desc       = "Africa's most medically significant snake by bite frequency. Relies on camouflage and a sit-and-wait ambush strategy. Causes devastating local tissue necrosis and potential limb loss.",
    firstaid   = "Immobilise immediately. Do NOT apply pressure bandage (worsens local tissue damage). Hospital urgently. Large antivenom doses may be required over several days.",
    habitat    = "Widespread — savanna, grassland, bushveld",
    img        = "https://i.ibb.co/v4vNN1xZ/Puff-Adder-jpg.jpg"
  ),
  "Black Mamba" = list(
    sci        = "Dendroaspis polylepis",
    venom      = "Neurotoxic",
    length     = "2.2 – 4.2 m",
    appearance = "Long, slender body with a narrow coffin-shaped head. Colour is olive to gunmetal grey — never truly black. Diagnostic: inky-black buccal lining revealed during threat display.",
    desc       = "Africa's longest venomous snake and one of the fastest. Bites are extreme emergencies — venom spreads rapidly via the lymphatic system causing progressive paralysis.",
    firstaid   = "Immobilise the limb below heart level. Apply pressure immobilisation bandage. Do NOT cut, suck, or tourniquet. Rush to hospital — specific antivenom is essential and time-critical.",
    habitat    = "Savanna, rocky hills, open woodland",
    img        = "https://i.ibb.co/MkMwJfQx/Black-Mamba-jpg.jpg"
  ),
  "Green Mamba" = list(
    sci        = "Dendroaspis angusticeps",
    venom      = "Neurotoxic",
    length     = "1.8 – 2.5 m",
    appearance = "Slender arboreal snake with a narrow head and large eyes. Brilliant bright green dorsally, yellowish-green ventrally. Long prehensile tail; smooth glossy scales.",
    desc       = "Less aggressive than the black mamba but equally dangerous. Dendrotoxins cause rapid neuromuscular blockade — respiratory failure can develop within hours of a bite.",
    firstaid   = "Pressure immobilisation — do not delay. Specific or polyvalent antivenom required. Respiratory compromise can develop rapidly.",
    habitat    = "Coastal forest, dense vegetation",
    img        = "https://i.ibb.co/7xZ2kc64/Green-Mamba-jpg.jpg"
  ),
  "Boomslang" = list(
    sci        = "Dispholidus typus",
    venom      = "Hemotoxic",
    length     = "1.0 – 1.6 m",
    appearance = "Slender tree snake with an egg-shaped head and unusually large eyes. Males bright green with black-edged scales; females brown to olive. Smooth scales; long thin tail.",
    desc       = "Haemotoxic venom disrupts clotting with critically delayed onset — victims may feel fine before life-threatening systemic bleeding begins. No pressure bandage; specific antivenom required.",
    firstaid   = "Seek immediate hospital care even if symptom-free — delayed coagulopathy is life-threatening. Specific Boomslang antivenom is required. Monitor for bleeding from gums and urine.",
    habitat    = "Woodland, forest edges, bushveld",
    img        = "https://i.ibb.co/KxQmPHLw/Boomslang-jpg.jpg"
  ),
  "Red Spitting Cobra" = list(
    sci        = "Naja pallida",
    venom      = "Cytotoxic",
    length     = "0.7 – 1.2 m",
    appearance = "Striking coral-red to orange-pink body with a creamy-white underside. Many individuals show a dark sub-ocular throat band. Rounded hood; smooth, glossy scales.",
    desc       = "Can accurately spit venom up to 2.5 m, targeting eyes. Most common cause of snake-related eye injuries in Kenya. Bites cause severe local necrosis.",
    firstaid   = "Immediate eye irrigation with water if spat at — irrigate for 15+ minutes. For bites: pressure immobilise and transport. Antivenom available.",
    habitat    = "Dry and semi-arid grassland, scrub",
    img        = "https://i.ibb.co/cSLGp9qf/Red-Spitting-Cobra-jpg.jpg"
  ),
  "Black Necked Spitting Cobra" = list(
    sci        = "Naja nigricollis",
    venom      = "Cytotoxic / Neurotoxic",
    length     = "1.2 – 2.2 m",
    appearance = "Thick-bodied with a broad flattened head and wide hood. Brown to dark grey dorsally; pale ventrally. Diagnostic: broad black throat band visible when hood is spread.",
    desc       = "Spits venom accurately up to 2.5 m. Causes severe local tissue damage and necrosis; eye contact risks permanent blindness without immediate irrigation.",
    firstaid   = "If venom contacts eyes: flush immediately with large amounts of water for 15+ minutes. For bites: pressure-immobilise, transport urgently.",
    habitat    = "Savanna, grassland, agricultural areas",
    img        = "https://i.ibb.co/Jwp88Tzc/Black-Necked-Spitting-Cobra-jpg.jpg"
  ),
  "Large Brown Spitting Cobra" = list(
    sci        = "Naja ashei",
    venom      = "Cytotoxic",
    length     = "1.5 – 2.7 m",
    appearance = "Heavy-bodied; the world's largest spitting cobra. Uniform light to dark brown, lacking distinct markings. Broad head with a wide powerful hood; pale yellowish-cream ventrally.",
    desc       = "Described as a new species only in 2007. Spits cytotoxic venom accurately up to 2.5 m, causing severe local necrosis. Found primarily in northern and coastal Kenya.",
    firstaid   = "Flush eyes immediately if spat at. For bites: pressure immobilise and seek urgent care. Antivenom required for systemic envenomation.",
    habitat    = "Dry savanna, coastal bushland",
    img        = "https://i.ibb.co/N6c12NzZ/Large-Brown-jpg.jpg"
  ),
  "Carpet Viper" = list(
    sci        = "Echis ocellatus",
    venom      = "Hemotoxic",
    length     = "0.3 – 0.6 m",
    appearance = "Small but stout viper with a pear-shaped head and large eyes. Sandy-brown with oval darker dorsal blotches giving a carpet-like pattern. Keeled scales produce a rasping warning sound.",
    desc       = "Responsible for more snakebite deaths globally than any other species. Small size and cryptic pattern make it easy to overlook. Causes severe coagulopathy and haemorrhage.",
    firstaid   = "Immobilise, do not apply tourniquet. Urgent hospital care — polyvalent antivenom required. Watch for bleeding complications including intracranial haemorrhage.",
    habitat    = "Dry savanna, semi-arid scrub",
    img        = "https://i.ibb.co/szwpcdx/Carpet-Viper.webp"
  ),
  "Eastern Forest Cobra" = list(
    sci        = "Naja subfulva",
    venom      = "Neurotoxic",
    length     = "1.5 – 2.7 m",
    appearance = "Jet black to dark brown dorsally with contrasting pale cream-yellow banded underside — alternating ventral bands are the key ID feature. Narrow elongated hood; smooth iridescent scales.",
    desc       = "Large cobra of western Kenyan forests. Venom causes respiratory paralysis — without treatment, death can occur within hours. Spreads a narrow hood when threatened.",
    firstaid   = "Pressure immobilisation. Urgent hospital transfer — respiratory support may be required. Polyvalent antivenom effective.",
    habitat    = "Tropical forest, forest edges",
    img        = "https://i.ibb.co/VYmMtz4c/Forest-Cobra-jpg.jpg"
  ),
  "Egyptian Cobra" = list(
    sci        = "Naja haje",
    venom      = "Neurotoxic / Cytotoxic",
    length     = "1.5 – 2.5 m",
    appearance = "Large, heavy-bodied cobra with a broad rounded head and wide hood. Uniform dark brown to yellowish-brown dorsally; pale yellowish ventrally with a dark throat band when hooded.",
    desc       = "One of Africa's most culturally significant snakes. Highly adaptable across habitats. Venom causes both neurotoxicity and tissue damage — a potentially lethal combination.",
    firstaid   = "Pressure immobilise, keep victim calm. Polyvalent antivenom required. Monitor for swallowing and breathing difficulties.",
    habitat    = "Savanna, farmland, semi-arid areas",
    img        = "https://i.ibb.co/Y4JVc796/Egyptian-Cobra.jpg"
  ),
  "Gaboon Viper" = list(
    sci        = "Bitis gabonica",
    venom      = "Cytotoxic / Hemotoxic",
    length     = "1.0 – 1.8 m",
    appearance = "World's heaviest viper. Patterned in interlocking geometric shapes of brown, purple, pink and yellow mimicking leaf litter. Flat triangular head with small horn-like protrusions; fangs up to 5 cm.",
    desc       = "Possesses the longest fangs of any snake. Near-perfect leaf-litter camouflage means it is easily trodden on. Venom causes severe necrosis and systemic coagulopathy.",
    firstaid   = "Do NOT apply tourniquet — fang depth makes excision futile and dangerous. Immobilise, transport urgently. Large doses of polyvalent antivenom required.",
    habitat    = "Tropical rainforest, forest floor",
    img        = "https://i.ibb.co/zH2G4sqf/Gaboon-Viper-jpg.jpg"
  ),
  "Rhinoceros Viper" = list(
    sci        = "Bitis nasicornis",
    venom      = "Cytotoxic / Hemotoxic",
    length     = "0.7 – 1.2 m",
    appearance = "Vivid mosaic of blue-green, purple, crimson and yellow geometric shapes. Most distinctive feature: 2–3 multi-pointed horn scales projecting from the snout. Short, stout body; strongly keeled scales.",
    desc       = "Spectacularly patterned forest floor ambush predator. Causes severe local tissue destruction; the vivid pattern provides near-perfect camouflage among damp leaf litter.",
    firstaid   = "Immobilise, do not apply pressure bandage. Urgent hospital transfer. Polyvalent antivenom required.",
    habitat    = "Tropical rainforest, swampy forest",
    img        = "https://i.ibb.co/PsSrTSMp/Rhinoceros-Viper-jpg.jpg"
  ),
  "Jameson Mamba" = list(
    sci        = "Dendroaspis jamesoni",
    venom      = "Neurotoxic",
    length     = "1.2 – 2.8 m",
    appearance = "Slender arboreal mamba. Bright lime-green on the head and neck, grading to olive along the body with a distinctively black-tipped tail — the key ID feature. Smooth glossy scales; narrow elongated head.",
    desc       = "Restricted to western Kenyan forest. Potently neurotoxic venom; the distinctive black tail tip distinguishes it from other Kenyan mambas. Mainly arboreal and fast-moving.",
    firstaid   = "Pressure immobilise, transport urgently. Specific mamba antivenom or polyvalent required.",
    habitat    = "Western Kenyan forest and forest margins",
    img        = "https://i.ibb.co/S4fqGpJF/Jamesons-Mamba.png"
  )
)

# Venom type → color
venom_colors <- c(
  "Neurotoxic"             = "#4a8aaa",
  "Hemotoxic"              = "#b83232",
  "Cytotoxic"              = "#d4823a",
  "Cytotoxic / Hemotoxic"  = "#b06040",
  "Cytotoxic / Neurotoxic" = "#7a9ba6",
  "Neurotoxic / Cytotoxic" = "#7a7ab0",
  "Neurotoxic / Myotoxic"  = "#5a6aaa"
)

get_venom_color <- function(vtype) {
  if (vtype %in% names(venom_colors)) return(venom_colors[[vtype]])
  "#c8a84b"
}


# ==============================================================================
# LOAD SHAPEFILES ONCE AT STARTUP
# ==============================================================================

kenya_counties <- tryCatch(
  st_transform(st_read("KE/kenya.shp", quiet = TRUE), crs = 4326),
  error = function(e) NULL
)

load_snake_shp <- function(name) {
  path <- paste0(name, ".shp")
  tryCatch(st_transform(st_read(path, quiet = TRUE), crs = 4326), error = function(e) NULL)
}

snake_shapes <- setNames(lapply(snake_names, load_snake_shp), snake_names)

# ==============================================================================
# UI
# ==============================================================================

ui <- page_navbar(
  id = "main_nav",
  title = tags$span(
    style = "font-family: 'Oswald', sans-serif; letter-spacing: 4px; font-size: 15px;
             color: #c8a84b; font-weight: 400; text-transform: uppercase;",
    "\u2620 KENYA SNAKE ATLAS"
  ),
  window_title = "Kenya Snake Distribution Atlas",
  
  theme = bs_theme(
    version       = 5,
    bg            = "#080d08",
    fg            = "#c8dcc8",
    primary       = "#c8a84b",
    secondary     = "#1a2e1a",
    success       = "#3a9a6a",
    danger        = "#b83232",
    warning       = "#d4823a",
    info          = "#4a8aaa",
    base_font     = font_google("Source Serif 4"),
    heading_font  = font_google("Oswald"),
    code_font     = font_google("Fira Mono"),
    "navbar-bg"          = "#040804",
    "card-bg"            = "#0d150d",
    "card-border-color"  = "#1a2e1a",
    "input-bg"           = "#0a100a",
    "input-border-color" = "#1a2e1a",
    "input-color"        = "#c8dcc8",
    "form-label-color"   = "#5a7a5a"
  ),
  
  header = tagList(
    tags$head(
      tags$meta(
        `http-equiv` = "Content-Security-Policy",
        content = "default-src 'self'; img-src * data: blob:; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; script-src 'self' 'unsafe-inline' 'unsafe-eval'; connect-src *;"
      ),
      tags$style(HTML('
    @import url("https://fonts.googleapis.com/css2?family=Oswald:wght@300;400;500;600&family=Source+Serif+4:wght@300;400;600&family=Fira+Mono:wght@400;500&display=swap");

    body, .bslib-page-fill { background: #080d08 !important; }

    /* ---- LOGO BAR ---- */
    .logo-bar {
      display: flex; align-items: center; justify-content: center;
      gap: 28px; padding: 10px 20px 8px 20px;
      background: #f4f0e8;
      border-bottom: 2px solid #d8d0bc;
    }
    .logo-bar img {
      height: 44px; width: auto;
      object-fit: contain; opacity: 0.92;
      filter: drop-shadow(0 0 6px #c8a84b22);
      transition: opacity 0.2s;
    }
    .logo-bar img:hover { opacity: 1; }
    .logo-divider {
      width: 1px; height: 36px; background: #c8c0a8;
    }

    .nav-tabs .nav-link {
      color: #5a7a5a !important; border-color: transparent !important;
      font-family: "Fira Mono"; letter-spacing: 2px; font-size: 11px; text-transform: uppercase;
    }
    .nav-tabs .nav-link.active {
      color: #c8a84b !important;
      border-bottom: 2px solid #c8a84b !important;
      background: transparent !important;
    }

    /* ---- SIDEBAR ---- */
    .sidebar-label {
      font-family: "Fira Mono", monospace;
      font-size: 9px; letter-spacing: 3px; text-transform: uppercase;
      color: #c8a84b; margin: 18px 0 8px 0;
      border-bottom: 1px solid #1a2e1a; padding-bottom: 5px;
    }

    /* ---- VENOM BADGE ---- */
    .venom-badge {
      display: inline-block;
      font-family: "Fira Mono", monospace;
      font-size: 9px; letter-spacing: 2px; text-transform: uppercase;
      padding: 3px 10px; border-radius: 2px;
      background: #1a2e1a;
    }


    /* ---- STAT ROW ---- */
    .stat-item {
      background: #0a100a; border: 1px solid #1a2e1a;
      border-radius: 2px; padding: 8px 12px;
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 5px;
    }
    .stat-label { font-family: "Fira Mono"; font-size: 9px; letter-spacing: 2px; text-transform: uppercase; color: #5a7a5a; }
    .stat-value { font-family: "Oswald"; font-size: 14px; font-weight: 500; color: #c8dcc8; }

    /* ---- APPEARANCE ---- */
    .appearance-text {
      font-family: "Source Serif 4"; font-size: 12px; line-height: 1.8;
      color: #7a9a7a; background: #0a100a;
      border: 1px solid #1a2e1a; border-left: 3px solid #c8a84b55;
      padding: 10px 14px; border-radius: 0 2px 2px 0;
      margin-bottom: 4px;
    }

    /* ---- DESCRIPTION ---- */
    .species-desc {
      font-family: "Source Serif 4"; font-size: 12.5px; line-height: 1.75;
      color: #8aaa8a; margin-bottom: 10px;
    }

    /* ---- FIRST AID ---- */
    .firstaid-box {
      background: #0a100a; border-left: 3px solid #b83232;
      padding: 10px 14px; border-radius: 0 2px 2px 0;
      margin-top: 8px;
    }
    .firstaid-label {
      font-family: "Fira Mono"; font-size: 9px; letter-spacing: 2px;
      text-transform: uppercase; color: #b83232; margin-bottom: 6px;
    }
    .firstaid-text {
      font-family: "Source Serif 4"; font-size: 12px; line-height: 1.7;
      color: #8aaa8a;
    }

    /* ---- SELECTIZE ---- */
    .selectize-control .selectize-input {
      background: #0a100a !important; border-color: #1a2e1a !important;
      color: #c8dcc8 !important; font-family: "Source Serif 4"; font-size: 13px;
    }
    .selectize-control .selectize-dropdown {
      background: #0d150d !important; border-color: #1a2e1a !important; color: #c8dcc8 !important;
    }
    .selectize-control .selectize-dropdown-content .option:hover,
    .selectize-control .selectize-dropdown-content .option.active {
      background: #1a2e1a !important;
    }

    /* ---- FILTER CHECKBOXES ---- */
    .shiny-input-checkboxgroup .checkbox label {
      font-family: "Fira Mono"; font-size: 10px; letter-spacing: 1px;
      text-transform: uppercase; color: #5a7a5a;
    }

    /* ---- SCROLLBAR ---- */
    ::-webkit-scrollbar { width: 4px; height: 4px; }
    ::-webkit-scrollbar-track { background: #080d08; }
    ::-webkit-scrollbar-thumb { background: #1a2e1a; border-radius: 2px; }

    /* ---- MAP ---- */
    #map { border-radius: 2px; }
    .leaflet-container { background: #080d08 !important; }

    /* ---- CARDS ---- */
    .card { border-radius: 2px !important; }
    .card-header {
      font-family: "Fira Mono"; letter-spacing: 2px;
      font-size: 10px; text-transform: uppercase; color: #c8a84b;
    }

    /* ---- RANGE CHIP ---- */
    .range-chip {
      display: inline-block;
      font-family: "Fira Mono"; font-size: 9px; letter-spacing: 1px;
      text-transform: uppercase; padding: 2px 8px; border-radius: 2px;
      background: #1a2e1a; color: #c8a84b; border: 1px solid #2a4a2a;
    }

    /* ---- IRS sliders ---- */
    .irs--shiny .irs-bar { background: #c8a84b; border-color: #c8a84b; }
    .irs--shiny .irs-handle { background: #c8a84b; }
    .irs--shiny .irs-single { background: #1a2e1a; font-family: "Fira Mono"; font-size: 10px; }
    .irs--shiny .irs-line { background: #1a2e1a; }

    /* ---- LEGEND ---- */
    .info.legend {
      background: #0d150d !important; border: 1px solid #1a2e1a !important;
      color: #c8dcc8 !important; font-family: "Fira Mono"; font-size: 10px;
      border-radius: 2px !important; padding: 8px 12px !important;
    }
  '))),
    tags$div(
      class = "logo-bar",
      tags$img(src = "https://i.ibb.co/Kx0cs6TM/ksric-logo.png",
               alt = "KSRIC", title = "Kenya Snake Research & Information Centre"),
      tags$div(class = "logo-divider"),
      tags$img(src = "https://i.ibb.co/DD6LbNr9/kipre-logo.png",
               alt = "KIPRE", title = "Kenya Institute for Public Research"),
      tags$div(class = "logo-divider"),
      tags$img(src = "https://i.ibb.co/23Wz5xdQ/moh-logo.png",
               alt = "MoH", title = "Ministry of Health Kenya")
    )
  ),
  
  # ==========================================================
  # TAB 1 — DISTRIBUTION MAP
  # ==========================================================
  nav_panel("DISTRIBUTION MAP",
            layout_sidebar(
              sidebar = sidebar(
                width = 300, bg = "#040804",
                style = "border-right: 1px solid #1a2e1a; overflow-y: auto; height: 100%; padding: 12px 14px;",
                
                tags$div(class = "sidebar-label", "SPECIES"),
                selectInput("snake", NULL, choices = snake_names, selected = "Puff Adder"),
                
                # Venom badge
                uiOutput("badges_ui"),
                
                # Stat row — length only
                uiOutput("stats_ui"),
                
                # APPEARANCE (replaces old Venom Profile content)
                tags$div(class = "sidebar-label", "APPEARANCE"),
                uiOutput("appearance_ui"),
                
                tags$div(class = "sidebar-label", "HABITAT"),
                uiOutput("habitat_ui"),
                
                tags$div(class = "sidebar-label", "DESCRIPTION"),
                uiOutput("desc_ui"),
                
                tags$div(class = "sidebar-label", "\u26a0 FIRST AID"),
                uiOutput("firstaid_ui"),
                
                tags$div(style = "height: 20px;")
              ),
              
              card(
                full_screen = TRUE,
                style = "background:#0d150d; border:1px solid #1a2e1a; height: calc(100vh - 80px);",
                card_header(
                  layout_columns(
                    col_widths = c(8, 4),
                    uiOutput("map_title"),
                    tags$div(style = "text-align:right; display:flex; gap:6px; justify-content:flex-end; align-items:center;",
                             uiOutput("range_chip_ui"))
                  ),
                  style = "background:#0a100a; border-bottom:1px solid #1a2e1a;"
                ),
                leafletOutput("map", width = "100%", height = "100%")
              )
            )
  ),
  
  # ==========================================================
  # TAB 2 — ALL SPECIES
  # ==========================================================
  nav_panel("ALL SPECIES",
            layout_columns(
              col_widths = c(12),
              
              tags$div(
                style = "display:flex; gap:10px; align-items:center; padding: 6px 0 10px 0; flex-wrap:wrap;",
                checkboxGroupInput("venom_filter", NULL,
                                   choices  = c("Neurotoxic","Hemotoxic","Cytotoxic","Mixed / Other"),
                                   selected = c("Neurotoxic","Hemotoxic","Cytotoxic","Mixed / Other"),
                                   inline   = TRUE),
                tags$div(style = "color:#5a7a5a; font-family:'Fira Mono'; font-size:9px; letter-spacing:2px; text-transform:uppercase; align-self:center;",
                         "FILTER BY VENOM TYPE")
              ),
              
              uiOutput("species_grid")
            )
  ),
  
  # ==========================================================
  # TAB 3 — MULTI-SPECIES MAP
  # ==========================================================
  nav_panel("MULTI-SPECIES MAP",
            layout_columns(
              col_widths = c(12),
              tags$div(
                style = "padding: 6px 0 10px 0; color:#5a7a5a; font-family:'Fira Mono'; font-size:9px; letter-spacing:2px; text-transform:uppercase;",
                "SELECT SPECIES TO OVERLAY — MAX 5 RECOMMENDED"
              ),
              layout_columns(
                col_widths = c(3, 9),
                
                card(
                  style = "background:#0d150d; border:1px solid #1a2e1a;",
                  card_header("SELECT SPECIES",
                              style = "background:#0a100a; border-bottom:1px solid #1a2e1a;"),
                  checkboxGroupInput("multi_species", NULL,
                                     choices  = snake_names,
                                     selected = c("Puff Adder","Black Mamba","Red Spitting Cobra"))
                ),
                
                card(
                  full_screen = TRUE,
                  style = "background:#0d150d; border:1px solid #1a2e1a;",
                  card_header("OVERLAPPING RANGES",
                              style = "background:#0a100a; border-bottom:1px solid #1a2e1a;"),
                  leafletOutput("multi_map", width = "100%", height = "560px")
                )
              )
            )
  )
)

# ==============================================================================
# SERVER
# ==============================================================================

server <- function(input, output, session) {
  
  
  get_meta <- function(name) snake_meta[[name]]
  
  # ---- Photo ----
  # ---- Venom badge ----
  output$badges_ui <- renderUI({
    m  <- get_meta(input$snake)
    vc <- get_venom_color(m$venom)
    tags$div(
      style = "display:flex; gap:8px; flex-wrap:wrap; margin-bottom:10px;",
      tags$span(class = "venom-badge",
                style = paste0("color:", vc, "; border:1px solid ", vc, "44;"),
                paste0("\u25cf  ", m$venom))
    )
  })
  
  # ---- Adult length stat ----
  output$stats_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$div(class = "stat-item",
             tags$span(class = "stat-label", "Adult length"),
             tags$span(class = "stat-value", m$length))
  })
  
  # ---- Appearance description + inline photo ----
  output$appearance_ui <- renderUI({
    m <- get_meta(input$snake)
    tagList(
      tags$div(class = "appearance-text", m$appearance),
      tags$div(
        style = "margin-top: 10px; margin-bottom: 4px; border-radius: 2px;
                 border: 1px solid #1a2e1a; line-height: 0;",
        tags$img(
          src    = m$img,
          width  = "100%",
          height = "200",
          style  = "object-fit: cover; display: block; opacity: 0.88; max-width: 100%;",
          referrerpolicy = "no-referrer",
          onerror = "this.parentElement.style.display='none'"
        )
      )
    )
  })
  
  # ---- Habitat ----
  output$habitat_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$p(style = "font-family:'Fira Mono'; font-size:10px; color:#5a7a5a;
                    letter-spacing:1px; line-height:1.8; margin-bottom:4px;",
           m$habitat)
  })
  
  # ---- Description ----
  output$desc_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$p(class = "species-desc", m$desc)
  })
  
  # ---- First Aid ----
  output$firstaid_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$div(class = "firstaid-box",
             tags$div(class = "firstaid-label", "\u2b1b EMERGENCY PROTOCOL"),
             tags$div(class = "firstaid-text", m$firstaid))
  })
  
  # ---- Map header title ----
  output$map_title <- renderUI({
    m  <- get_meta(input$snake)
    vc <- get_venom_color(m$venom)
    tags$div(
      style = "display:flex; align-items:center; gap:10px;",
      tags$span(style = "color:#c8a84b; font-family:'Fira Mono'; font-size:11px; letter-spacing:2px; text-transform:uppercase;",
                toupper(input$snake)),
      tags$span(style = paste0("color:", vc, "; font-family:'Fira Mono'; font-size:9px; letter-spacing:1px;"),
                paste0("[ ", m$venom, " ]"))
    )
  })
  
  # ---- Range chip ----
  output$range_chip_ui <- renderUI({
    shp <- snake_shapes[[input$snake]]
    if (is.null(shp)) return(NULL)
    n_polys <- nrow(shp)
    area_km <- tryCatch(
      round(sum(as.numeric(st_area(st_transform(shp, crs = 32737)))) / 1e6),
      error = function(e) NA
    )
    tagList(
      tags$span(class = "range-chip", paste0(n_polys, " range polygon", if (n_polys != 1) "s")),
      if (!is.na(area_km) && is.numeric(area_km))
        tags$span(class = "range-chip", style = "color:#3a9a6a;",
                  paste0(format(area_km, big.mark = ","), " km\u00b2"))
    )
  })
  
  # ---- Single-species map ----
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = TRUE)) %>%
      addProviderTiles("CartoDB.DarkMatter", options = tileOptions(opacity = 0.9)) %>%
      fitBounds(lng1 = 33.9, lat1 = -4.68, lng2 = 41.9, lat2 = 4.62)
  })
  
  observeEvent(input$snake, {
    shp <- snake_shapes[[input$snake]]
    m   <- get_meta(input$snake)
    vc  <- get_venom_color(m$venom)
    
    proxy <- leafletProxy("map")
    proxy %>% clearShapes() %>% clearControls()
    
    if (!is.null(kenya_counties)) {
      proxy %>%
        addPolygons(data = kenya_counties, color = "#1a2e1a", weight = 1,
                    fill = TRUE, fillColor = "#080d08", fillOpacity = 0.3,
                    label = ~COUNTY,
                    labelOptions = labelOptions(
                      style = list("font-family" = "Fira Mono", "font-size" = "11px",
                                   "background" = "#0d150d", "color" = "#c8a84b",
                                   "border" = "1px solid #1a2e1a", "padding" = "4px 8px")))
    }
    
    if (!is.null(shp)) {
      proxy %>%
        addPolygons(data = shp, color = vc, weight = 2,
                    fillColor = vc, fillOpacity = 0.3,
                    popup = paste0(
                      "<div style='font-family:Fira Mono;font-size:11px;",
                      "background:#0d150d;color:#c8dcc8;padding:8px 12px;",
                      "border:1px solid #1a2e1a;border-left:3px solid ", vc, ";'>",
                      "<div style='color:", vc, ";font-size:9px;letter-spacing:2px;",
                      "text-transform:uppercase;margin-bottom:4px;'>", m$venom, "</div>",
                      "<b>", input$snake, "</b><br>",
                      "<em style='color:#5a7a5a;font-size:10px;'>", m$sci, "</em>",
                      "</div>"),
                    highlightOptions = highlightOptions(weight = 3, fillOpacity = 0.55, bringToFront = TRUE)) %>%
        addLegend(position = "bottomright",
                  colors   = c(vc, "#1a2e1a"),
                  labels   = c(paste0(input$snake, " range"), "County boundary"),
                  title    = NULL, opacity = 0.9)
    }
  })
  
  # ---- All species grid ----
  output$species_grid <- renderUI({
    selected_vtypes <- input$venom_filter
    
    filtered <- Filter(function(nm) {
      m  <- snake_meta[[nm]]
      vt <- m$venom
      any(sapply(c("Neurotoxic", "Hemotoxic", "Cytotoxic"), function(v) {
        grepl(v, vt, ignore.case = TRUE) && v %in% selected_vtypes
      })) ||
        ("Mixed / Other" %in% selected_vtypes &&
           !any(sapply(c("Neurotoxic", "Hemotoxic", "Cytotoxic"),
                       function(v) grepl(v, vt, ignore.case = TRUE))))
    }, snake_names)
    
    cards <- lapply(filtered, function(nm) {
      m  <- snake_meta[[nm]]
      vc <- get_venom_color(m$venom)
      
      tags$div(
        style = paste0("background:#0d150d; border:1px solid #1a2e1a; ",
                       "border-top:3px solid ", vc, "; border-radius:2px; ",
                       "padding:14px 16px; transition:border-color 0.2s; cursor:pointer;"),
        onclick = paste0("Shiny.setInputValue('jump_species','", nm, "',{priority:'event'})"),
        
        # Image
        tags$div(style = "position:relative; margin:-14px -16px 10px -16px; overflow:hidden; height:100px;",
                 tags$img(src   = m$img,
                          style = "width:100%; height:100%; object-fit:cover; opacity:0.75;",
                          referrerpolicy = "no-referrer",
                          onerror = "this.style.display='none'")),
        
        # Name & scientific
        tags$div(style = "font-family:'Oswald'; font-size:15px; font-weight:500;
                          color:#c8dcc8; letter-spacing:1px; margin-bottom:2px;", nm),
        tags$div(style = "font-family:'Source Serif 4'; font-style:italic;
                          font-size:11px; color:#5a7a5a; margin-bottom:8px;", m$sci),
        
        # Venom badge
        tags$div(style = "display:flex; gap:6px; flex-wrap:wrap; margin-bottom:10px;",
                 tags$span(class = "venom-badge",
                           style = paste0("color:", vc, "; border:1px solid ", vc, "33; font-size:8px;"),
                           m$venom)),
        
        # Stats
        tags$div(style = "display:grid; grid-template-columns:1fr 1fr; gap:4px; margin-bottom:8px;",
                 lapply(list(
                   list("Length",  m$length),
                   list("Habitat", m$habitat)
                 ), function(s) {
                   tags$div(style = "background:#0a100a; border:1px solid #1a2e1a; padding:5px 8px; border-radius:2px;",
                            tags$div(style = "font-family:'Fira Mono'; font-size:8px; letter-spacing:1px;
                                     text-transform:uppercase; color:#5a7a5a;", s[[1]]),
                            tags$div(style = "font-family:'Oswald'; font-size:12px; color:#c8dcc8;
                                     margin-top:1px; line-height:1.3;", s[[2]]))
                 })),
        
        # First aid preview
        tags$div(style = paste0("border-left:2px solid #b83232; padding:6px 10px;",
                                "background:#0a100a; border-radius:0 2px 2px 0;"),
                 tags$div(style = "font-family:'Fira Mono'; font-size:8px; letter-spacing:1px;
                          text-transform:uppercase; color:#b83232; margin-bottom:3px;",
                          "\u26a0 First Aid"),
                 tags$div(style = "font-family:'Source Serif 4'; font-size:11px;
                          color:#5a7a5a; line-height:1.6;",
                          substr(m$firstaid, 1, 90), "...")),
        
        # Click hint
        tags$div(style = "margin-top:8px; font-family:'Fira Mono'; font-size:8px;
                          letter-spacing:1px; color:#2a4a2a; text-transform:uppercase;",
                 "\u2192 click to view on map")
      )
    })
    
    tagList(
      tags$div(style = "color:#5a7a5a; font-family:'Fira Mono'; font-size:9px;
                        letter-spacing:2px; text-transform:uppercase; padding:4px 0 10px 0;",
               paste0("SHOWING ", length(filtered), " OF ", length(snake_names), " SPECIES")),
      tags$div(
        style = "display:grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                 gap:12px; padding:4px 0;",
        cards
      )
    )
  })
  
  observeEvent(input$jump_species, {
    updateSelectInput(session, "snake", selected = input$jump_species)
    updateNavbarPage(session, inputId = "main_nav", selected = "DISTRIBUTION MAP")
  })
  
  # ---- Multi-species map ----
  multi_colors <- c(
    "#c8a84b","#b83232","#3a9a6a","#4a8aaa","#8a6ab8",
    "#d4823a","#4a9090","#906060","#609060","#606090",
    "#a0a040","#a04080","#40a080"
  )
  
  output$multi_map <- renderLeaflet({
    sel <- input$multi_species
    if (length(sel) == 0) sel <- snake_names[1]
    
    m <- leaflet(options = leafletOptions(zoomControl = TRUE)) %>%
      addProviderTiles("CartoDB.DarkMatter", options = tileOptions(opacity = 0.9)) %>%
      fitBounds(lng1 = 33.9, lat1 = -4.68, lng2 = 41.9, lat2 = 4.62)
    
    if (!is.null(kenya_counties)) {
      m <- addPolygons(m, data = kenya_counties,
                       color = "#1a2e1a", weight = 1, fill = TRUE,
                       fillColor = "#080d08", fillOpacity = 0.3)
    }
    
    for (i in seq_along(sel)) {
      shp <- snake_shapes[[sel[i]]]
      if (is.null(shp)) next
      col <- multi_colors[((i - 1) %% length(multi_colors)) + 1]
      m <- addPolygons(m, data = shp, color = col, weight = 2,
                       fillColor = col, fillOpacity = 0.25, group = sel[i],
                       popup = paste0("<div style='font-family:Fira Mono;font-size:11px;",
                                      "background:#0d150d;color:#c8dcc8;padding:6px 10px;",
                                      "border-left:3px solid ", col, ";'>",
                                      "<b>", sel[i], "</b><br>",
                                      "<em style='color:#5a7a5a;font-size:10px;'>",
                                      snake_meta[[sel[i]]]$sci, "</em></div>"))
    }
    
    valid_sel <- sel[!sapply(snake_shapes[sel], is.null)]
    if (length(valid_sel) > 0) {
      cols_used <- multi_colors[seq_along(valid_sel)]
      m <- addLegend(m, position = "bottomright",
                     colors = cols_used, labels = valid_sel, opacity = 0.9)
    }
    m
  })
}

# ==============================================================================
# RUN
# ==============================================================================
shinyApp(ui = ui, server = server)
