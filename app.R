#setwd ("C:\\Users\\HP\\Desktop\\Desktop\\desk\\SNAKE DISTRIBUTIONS")
list.files()

library(shiny)
library(bslib)
library(leaflet)
library(sf)
library(dplyr)

# ==============================================================================
# SPECIES DATA
# ==============================================================================

snake_names <- c(
  "Black Mamba", "Black Necked Spitting Cobra",
  "Boomslang", "Carpet Viper", "Eastern Forest Cobra",
  "Egyptian Cobra", "Gaboon Viper", "Gold's Tree Cobra",
  "Green Mamba", "Jameson Mamba", "Large Brown Spitting Cobra",
  "Puff Adder", "Red Spitting Cobra", "Rhinoceros Viper",
  "Twig Snake", "Yellow Bellied Sea Snake"
)

# Rich metadata per species
snake_meta <- list(
  "Black Mamba" = list(
    sci      = "Dendroaspis polylepis",
    venom    = "Neurotoxic",
    length   = "2.2 – 4.2 m",
    desc     = "The longest venomous snake in Africa and one of the fastest. Grey-brown to olive with a distinctive black buccal lining. Bites are extreme medical emergencies — venom spreads rapidly via the lymphatic system causing progressive paralysis.",
    firstaid = "Immobilise the limb below heart level. Apply pressure immobilisation bandage. Do NOT cut, suck, or tourniquet. Rush to hospital — specific antivenom is essential and time-critical.",
    habitat  = "Savanna, rocky hills, open woodland",
    imgs     = c("Black Mamba.png","Black Mamba2.png","Black Mamba3.png","Black Mamba4.png")
  ),
  "Black Necked Spitting Cobra" = list(
    sci      = "Naja nigricollis",
    venom    = "Cytotoxic / Neurotoxic",
    length   = "1.2 – 2.2 m",
    desc     = "Thick-bodied with a broad head and distinct black throat bands. Can accurately spit venom up to 2.5m, aiming for the eyes. Causes severe local tissue damage and necrosis on skin contact.",
    firstaid = "If venom contacts eyes: flush immediately with large amounts of water for 15+ minutes. For bites: pressure-immobilise, transport urgently. Eye exposure can cause permanent blindness if untreated.",
    habitat  = "Savanna, grassland, agricultural areas",
    imgs     = c("Black Necked Spitting Cobra.png")
  ),
  "Boomslang" = list(
    sci      = "Dispholidus typus",
    venom    = "Hemotoxic",
    length   = "1.0 – 1.6 m",
    desc     = "Slender, arboreal snake with a rounded head and large eyes. Adults are bright green with black-edged scales. The haemotoxic venom disrupts blood clotting — onset is critically delayed, so victims may feel fine before severe systemic bleeding begins.",
    firstaid = "Seek immediate hospital care even if symptom-free — delayed coagulopathy is life-threatening. Specific Boomslang antivenom is required. Monitor for bleeding from gums, venipuncture sites and urine.",
    habitat  = "Woodland, forest edges, bushveld",
    imgs     = c("Boomslang.png","Boomslang2.png","Boomslang3.png","Boomslang4.png","Boomslang5.png")
  ),
  "Carpet Viper" = list(
    sci      = "Echis ocellatus",
    venom    = "Hemotoxic",
    length   = "0.3 – 0.6 m",
    desc     = "Small but responsible for more snakebite deaths globally than any other species. Pale brown with darker dorsal markings and keeled scales that produce a rasping warning sound. Causes severe coagulopathy and haemorrhage.",
    firstaid = "Immobilise, do not apply tourniquet. Urgent hospital care — polyvalent antivenom required. Watch for bleeding complications including intracranial haemorrhage.",
    habitat  = "Dry savanna, semi-arid scrub",
    imgs     = c("No-Image.png")
  ),
  "Eastern Forest Cobra" = list(
    sci      = "Naja subfulva",
    venom    = "Neurotoxic",
    length   = "1.5 – 2.7 m",
    desc     = "Dark brown to black with lighter ventral banding. Found in forest and forest margins of western Kenya. Spreads a narrow hood when threatened. Venom causes respiratory paralysis.",
    firstaid = "Pressure immobilisation. Urgent hospital transfer — respiratory support may be required. Polyvalent antivenom effective.",
    habitat  = "Tropical forest, forest edges",
    imgs     = c("Forest Cobra.png","Forest Cobra2.png")
  ),
  "Egyptian Cobra" = list(
    sci      = "Naja haje",
    venom    = "Neurotoxic / Cytotoxic",
    length   = "1.5 – 2.5 m",
    desc     = "Uniform dark brown or black with a broad wide hood. One of Africa's most culturally significant snakes. Highly adaptable and found in a wide range of habitats. Venom causes both neurotoxicity and tissue damage.",
    firstaid = "Pressure immobilise, keep victim calm. Polyvalent antivenom required. Monitor for swallowing and breathing difficulties.",
    habitat  = "Savanna, farmland, semi-arid areas",
    imgs     = c("Egyptian Cobra.png","Egyptian Cobra2.png")
  ),
  "Gaboon Viper" = list(
    sci      = "Bitis gabonica",
    venom    = "Cytotoxic / Hemotoxic",
    length   = "1.0 – 1.8 m",
    desc     = "The world's heaviest viper, with the longest fangs of any snake (up to 5 cm). Cryptic leaf-litter camouflage in browns, purples and yellows with distinctive horns. Venom causes severe local necrosis and systemic coagulopathy.",
    firstaid = "Do NOT apply tourniquet — fang depth makes excision futile and dangerous. Immobilise, transport urgently. Large doses of polyvalent antivenom required.",
    habitat  = "Tropical rainforest, forest floor",
    imgs     = c("No-Image.png")
  ),
  "Gold's Tree Cobra" = list(
    sci      = "Pseudohaje goldii",
    venom    = "Neurotoxic",
    length   = "1.2 – 2.4 m",
    desc     = "Slender arboreal cobra with olive-brown colouring and a small head. Raises its forebody and head when threatened. Restricted to western Kenyan forests. Neurotoxic venom though relatively few documented bites.",
    firstaid = "Pressure immobilise. Seek hospital care. Polyvalent antivenom may be effective.",
    habitat  = "Montane and lowland forest",
    imgs     = c("No-Image.png")
  ),
  "Green Mamba" = list(
    sci      = "Dendroaspis angusticeps",
    venom    = "Neurotoxic",
    length   = "1.8 – 2.5 m",
    desc     = "Slender, brilliant green arboreal snake with a narrow hood. Less aggressive than the black mamba but venom is equally serious — dendrotoxins cause rapid neuromuscular blockade.",
    firstaid = "Pressure immobilisation — do not delay. Specific or polyvalent antivenom required. Respiratory compromise can develop rapidly.",
    habitat  = "Coastal forest, dense vegetation",
    imgs     = c("No-Image.png")
  ),
  "Jameson Mamba" = list(
    sci      = "Dendroaspis jamesoni",
    venom    = "Neurotoxic",
    length   = "1.2 – 2.8 m",
    desc     = "Bright green to yellowish-green on the head and neck, tapering to a black tail. Mainly arboreal and restricted to western Kenya. Spreads a fine hood in defense. Venom is potently neurotoxic.",
    firstaid = "Pressure immobilise, transport urgently. Specific mamba antivenom or polyvalent required.",
    habitat  = "Western Kenyan forest and forest margins",
    imgs     = c("No-Image.png")
  ),
  "Large Brown Spitting Cobra" = list(
    sci      = "Naja ashei",
    venom    = "Cytotoxic",
    length   = "1.5 – 2.7 m",
    desc     = "The world's largest spitting cobra, described as a new species only in 2007. Light to dark brown. Can spit venom accurately up to 2.5m. Causes severe local cytotoxic necrosis.",
    firstaid = "Flush eyes immediately if spat at. For bites: pressure immobilise and seek urgent care. Antivenom required for systemic envenomation.",
    habitat  = "Dry savanna, coastal bushland",
    imgs     = c("Large Brown Spitting Cobra.png","Large Brown Spitting Cobra2.png","Large Brown Spitting Cobra3.png")
  ),
  "Puff Adder" = list(
    sci      = "Bitis arietans",
    venom    = "Cytotoxic / Hemotoxic",
    length   = "1.0 – 1.5 m",
    desc     = "Africa's most medically significant snake by bite frequency. Relies on camouflage and is responsible for more bites than any African species due to its sit-and-wait ambush strategy. Causes devastating local tissue necrosis and limb loss.",
    firstaid = "Immobilise immediately. Do NOT apply pressure bandage (worsens local tissue damage). Hospital urgently. Large antivenom doses may be required over several days.",
    habitat  = "Widespread — savanna, grassland, bushveld",
    imgs     = c("Puff Adder.png","Puff Adder2.png","Puff Adder3.png")
  ),
  "Red Spitting Cobra" = list(
    sci      = "Naja pallida",
    venom    = "Cytotoxic",
    length   = "0.7 – 1.2 m",
    desc     = "Striking bright red to orange-pink snake with a white underside. Can accurately spit venom at perceived eye targets. Most common cause of eye injuries from snakes in Kenya.",
    firstaid = "Immediate eye irrigation with water if spat at — irrigate for 15+ minutes. For bites: pressure immobilise and transport. Antivenom available.",
    habitat  = "Dry and semi-arid grassland, scrub",
    imgs     = c("Red Spitter.png","Red Spitter2.png","Red Spitter3.png",
                 "Red Spitter4.png","Red Spitter5.png","Red Spitter6.png","Red Spitter7.png")
  ),
  "Rhinoceros Viper" = list(
    sci      = "Bitis nasicornis",
    venom    = "Cytotoxic / Hemotoxic",
    length   = "0.7 – 1.2 m",
    desc     = "Spectacularly patterned in geometric greens, blues and yellows with distinctive multi-horned scales on the snout. A slow-moving forest floor ambush predator. Causes severe local tissue destruction.",
    firstaid = "Immobilise, do not apply pressure bandage. Urgent hospital transfer. Polyvalent antivenom required.",
    habitat  = "Tropical rainforest, swampy forest",
    imgs     = c("No-Image.png")
  ),
  "Twig Snake" = list(
    sci      = "Thelotornis capensis",
    venom    = "Hemotoxic",
    length   = "0.7 – 1.2 m",
    desc     = "Extremely slender, camouflaged as a dead twig. Has a peculiar inflatable dewlap used in threat displays. Rear-fanged and venom is haemotoxic with delayed onset — there is no specific antivenom.",
    firstaid = "Supportive care only — no antivenom available. Immediate hospital transfer critical. Monitor for signs of coagulopathy over 48+ hours.",
    habitat  = "Woodland, forest edges, bushveld",
    imgs     = c("No-Image.png")
  ),
  "Yellow Bellied Sea Snake" = list(
    sci      = "Hydrophis platurus",
    venom    = "Neurotoxic / Myotoxic",
    length   = "0.5 – 1.0 m",
    desc     = "The only fully oceanic snake, found drifting in open water along Kenya's coast. Black above and yellow below with a laterally flattened tail. Rarely bites humans unprovoked. Venom causes muscle breakdown and neurotoxicity.",
    firstaid = "Pressure immobilisation. Remove from water. Urgent hospital care — sea snake antivenom or polyvalent required. Monitor kidney function.",
    habitat  = "Open Indian Ocean, coastal waters",
    imgs     = c("No-Image.png")
  )
)

# Venom type → color mapping (for map polygon and badges)
venom_colors <- c(
  "Neurotoxic"            = "#4a8aaa",
  "Hemotoxic"             = "#b83232",
  "Cytotoxic"             = "#d4823a",
  "Cytotoxic / Hemotoxic" = "#b06040",
  "Cytotoxic / Neurotoxic"= "#7a7ab0",
  "Neurotoxic / Cytotoxic"= "#7a7ab0",
  "Neurotoxic / Myotoxic" = "#5a6aaa"
)

get_venom_color <- function(vtype) {
  if (vtype %in% names(venom_colors)) return(venom_colors[[vtype]])
  "#c8a84b"
}


# ==============================================================================
# UI
# ==============================================================================

ui <- page_navbar(
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
    "navbar-bg"         = "#040804",
    "card-bg"           = "#0d150d",
    "card-border-color" = "#1a2e1a",
    "input-bg"          = "#0a100a",
    "input-border-color"= "#1a2e1a",
    "input-color"       = "#c8dcc8",
    "form-label-color"  = "#5a7a5a"
  ),
  
  header = tags$head(tags$style(HTML('
    @import url("https://fonts.googleapis.com/css2?family=Oswald:wght@300;400;500;600&family=Source+Serif+4:wght@300;400;600&family=Fira+Mono:wght@400;500&display=swap");

    body, .bslib-page-fill { background: #080d08 !important; }

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
    .species-select { font-family: "Source Serif 4"; }

    /* ---- VENOM BADGE ---- */
    .venom-badge {
      display: inline-block;
      font-family: "Fira Mono", monospace;
      font-size: 9px; letter-spacing: 2px; text-transform: uppercase;
      padding: 3px 10px; border-radius: 2px;
      background: #1a2e1a;
    }

    /* ---- PHOTO GALLERY ---- */
    .gallery-wrap {
      position: relative;
      background: #0a100a;
      border: 1px solid #1a2e1a;
      border-radius: 2px;
      overflow: hidden;
      margin-bottom: 12px;
      user-select: none;
    }
    .gallery-wrap::after {
      content: "";
      position: absolute; bottom: 0; left: 0; right: 0; height: 50px;
      background: linear-gradient(to bottom, transparent, #0a100a);
      pointer-events: none; z-index: 1;
    }
    .gallery-img { width: 100%; height: 180px; object-fit: cover; display: block; }
    .gallery-sci {
      position: absolute; bottom: 8px; left: 12px; z-index: 2;
      font-family: "Source Serif 4"; font-style: italic; font-size: 11px; color: #5a7a5a;
    }
    .gallery-counter {
      position: absolute; top: 8px; right: 8px; z-index: 2;
      font-family: "Fira Mono"; font-size: 9px; letter-spacing: 1px;
      background: #0a100acc; color: #5a7a5a;
      padding: 2px 7px; border-radius: 2px; border: 1px solid #1a2e1a;
    }
    .gallery-nav {
      display: flex; gap: 6px; margin-top: 6px; margin-bottom: 2px;
    }
    .gallery-btn {
      flex: 1; background: #0a100a; border: 1px solid #1a2e1a;
      color: #5a7a5a; font-family: "Fira Mono"; font-size: 11px;
      padding: 4px 0; border-radius: 2px; cursor: pointer;
      transition: border-color 0.15s, color 0.15s;
      text-align: center;
    }
    .gallery-btn:hover { border-color: #c8a84b; color: #c8a84b; }
    .gallery-dots {
      display: flex; gap: 4px; justify-content: center; margin-bottom: 8px;
    }
    .gallery-dot {
      width: 5px; height: 5px; border-radius: 50%;
      background: #1a2e1a; transition: background 0.15s;
    }
    .gallery-dot.active { background: #c8a84b; }

    /* ---- STAT ROW ---- */
    .stat-item {
      background: #0a100a; border: 1px solid #1a2e1a;
      border-radius: 2px; padding: 8px 12px;
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 5px;
      transition: border-color 0.2s;
    }
    .stat-item:hover { border-color: #c8a84b33; }
    .stat-label { font-family: "Fira Mono"; font-size: 9px; letter-spacing: 2px; text-transform: uppercase; color: #5a7a5a; }
    .stat-value { font-family: "Oswald"; font-size: 14px; font-weight: 500; color: #c8dcc8; }


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

    /* ---- MAP PANEL ---- */
    #map { border-radius: 2px; }
    .leaflet-container { background: #080d08 !important; }

    /* ---- CARDS ---- */
    .card { border-radius: 2px !important; }
    .card-header {
      font-family: "Fira Mono"; letter-spacing: 2px;
      font-size: 10px; text-transform: uppercase; color: #c8a84b;
    }

    /* ---- RANGE COUNTER ---- */
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

    /* ---- SIDEBAR PANEL HEIGHT ---- */
    .sidebar-panel-content { overflow-y: auto; }
  '))),
  
  # ============================================================
  # TAB 1 — DISTRIBUTION MAP
  # ============================================================
  nav_panel("DISTRIBUTION MAP",
            layout_sidebar(
              sidebar = sidebar(
                width = 300, bg = "#040804",
                style = "border-right: 1px solid #1a2e1a; overflow-y: auto; height: 100%; padding: 12px 14px;",
                
                tags$div(class = "sidebar-label", "SPECIES"),
                selectInput("snake", NULL, choices = snake_names,
                            selected = "Puff Adder"),
                
                # Photo
                uiOutput("snake_photo_ui"),
                
                # Venom badge
                uiOutput("badges_ui"),
                
                # Stats
                tags$div(class = "sidebar-label", "VENOM PROFILE"),
                uiOutput("stats_ui"),
                
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
  
  # ============================================================
  # TAB 2 — ALL SPECIES
  # ============================================================
  nav_panel("ALL SPECIES",
            layout_columns(
              col_widths = c(12),
              
              tags$div(
                style = "display:flex; gap:10px; align-items:center; padding: 6px 0 10px 0; flex-wrap:wrap;",
                checkboxGroupInput("venom_filter", NULL,
                                   choices  = c("Neurotoxic","Hemotoxic","Cytotoxic","Mixed / Other"),
                                   selected = c("Neurotoxic","Hemotoxic","Cytotoxic","Mixed / Other"),
                                   inline   = TRUE
                ),
                tags$div(style="color:#5a7a5a; font-family:'Fira Mono'; font-size:9px; letter-spacing:2px; text-transform:uppercase; align-self:center;",
                         "FILTER BY VENOM TYPE")
              ),
              
              uiOutput("species_grid")
            )
  ),
  
  # ============================================================
  # TAB 3 — MULTI-SPECIES MAP
  # ============================================================
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
  
  # ---- Load data (same paths as original) ----
  kenya_counties <- tryCatch(
    st_transform(st_read("KE/kenya.shp", quiet=TRUE), crs=4326),
    error = function(e) NULL
  )
  
  load_snake_shp <- function(name) {
    path <- paste0(name, ".shp")
    tryCatch(st_transform(st_read(path, quiet=TRUE), crs=4326), error=function(e) NULL)
  }
  
  snake_shapes <- setNames(lapply(snake_names, load_snake_shp), snake_names)
  
  # ---- Helpers ----
  
  get_meta <- function(name) snake_meta[[name]]
  
  # ---- SIDEBAR OUTPUTS ----
  
  # ---- Photo gallery reactive state ----
  photo_idx <- reactiveVal(1)
  
  observeEvent(input$snake, { photo_idx(1) })
  
  observeEvent(input$gallery_prev, {
    m   <- get_meta(input$snake)
    n   <- length(m$imgs)
    photo_idx(max(1, photo_idx() - 1))
  })
  
  observeEvent(input$gallery_next, {
    m   <- get_meta(input$snake)
    n   <- length(m$imgs)
    photo_idx(min(n, photo_idx() + 1))
  })
  
  output$snake_photo_ui <- renderUI({
    m   <- get_meta(input$snake)
    imgs <- m$imgs
    n   <- length(imgs)
    idx <- photo_idx()
    src <- imgs[idx]
    
    # Dots
    dots <- lapply(seq_len(n), function(i) {
      tags$div(class = paste("gallery-dot", if (i == idx) "active" else ""))
    })
    
    tagList(
      tags$div(
        class = "gallery-wrap",
        tags$img(src = src, class = "gallery-img",
                 onerror = "this.src='No-Image.png'"),
        tags$div(class = "gallery-sci", tags$em(m$sci)),
        if (n > 1)
          tags$div(class = "gallery-counter", paste0(idx, " / ", n))
      ),
      if (n > 1) tagList(
        tags$div(class = "gallery-nav",
                 actionButton("gallery_prev", "\u2190 prev",
                              class = "gallery-btn",
                              style = if (idx == 1) "opacity:0.3; pointer-events:none;" else ""),
                 actionButton("gallery_next", "next \u2192",
                              class = "gallery-btn",
                              style = if (idx == n) "opacity:0.3; pointer-events:none;" else "")
        ),
        tags$div(class = "gallery-dots", dots)
      )
    )
  })
  
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
  
  output$stats_ui <- renderUI({
    m <- get_meta(input$snake)
    stat <- function(lbl, val) {
      tags$div(class = "stat-item",
               tags$span(class = "stat-label", lbl),
               tags$span(class = "stat-value", val))
    }
    tagList(
      stat("Adult length", m$length)
    )
  })
  
  output$habitat_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$p(style="font-family:'Fira Mono'; font-size:10px; color:#5a7a5a;
                  letter-spacing:1px; line-height:1.8; margin-bottom:4px;",
           m$habitat)
  })
  
  output$desc_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$p(class="species-desc", m$desc)
  })
  
  output$firstaid_ui <- renderUI({
    m <- get_meta(input$snake)
    tags$div(class="firstaid-box",
             tags$div(class="firstaid-label", "\u2b1b EMERGENCY PROTOCOL"),
             tags$div(class="firstaid-text", m$firstaid))
  })
  
  output$map_title <- renderUI({
    m  <- get_meta(input$snake)
    vc <- get_venom_color(m$venom)
    tags$div(
      style="display:flex; align-items:center; gap:10px;",
      tags$span(style="color:#c8a84b; font-family:'Fira Mono'; font-size:11px; letter-spacing:2px; text-transform:uppercase;",
                toupper(input$snake)),
      tags$span(style=paste0("color:", vc, "; font-family:'Fira Mono'; font-size:9px; letter-spacing:1px;"),
                paste0("[ ", m$venom, " ]"))
    )
  })
  
  output$range_chip_ui <- renderUI({
    shp <- snake_shapes[[input$snake]]
    if (is.null(shp)) return(NULL)
    n_polys <- nrow(shp)
    area_km  <- tryCatch(
      round(sum(as.numeric(st_area(st_transform(shp, crs=32737)))) / 1e6),
      error = function(e) "N/A"
    )
    tagList(
      tags$span(class="range-chip", paste0(n_polys, " range polygon", if(n_polys!=1)"s")),
      if (!is.na(area_km) && is.numeric(area_km))
        tags$span(class="range-chip", style="color:#3a9a6a;",
                  paste0(format(area_km, big.mark=","), " km\u00b2"))
    )
  })
  
  # ---- MAP (single species) ----
  
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = TRUE)) %>%
      addProviderTiles("CartoDB.DarkMatter",
                       options = tileOptions(opacity = 0.9)) %>%
      fitBounds(lng1=33.9, lat1=-4.68, lng2=41.9, lat2=4.62)
  })
  
  observeEvent(input$snake, {
    shp    <- snake_shapes[[input$snake]]
    m      <- get_meta(input$snake)
    vc     <- get_venom_color(m$venom)
    vc_fill <- paste0(sub("#","rgba(",vc), ",0.35)")
    
    proxy <- leafletProxy("map")
    
    proxy %>%
      clearShapes() %>%
      clearControls()
    
    if (!is.null(kenya_counties)) {
      proxy %>%
        addPolygons(data=kenya_counties, color="#1a2e1a", weight=1,
                    fill=TRUE, fillColor="#080d08", fillOpacity=0.3,
                    label=~COUNTY, labelOptions=labelOptions(
                      style=list("font-family"="Fira Mono","font-size"="11px",
                                 "background"="#0d150d","color"="#c8a84b",
                                 "border"="1px solid #1a2e1a","padding"="4px 8px")
                    ))
    }
    
    if (!is.null(shp)) {
      proxy %>%
        addPolygons(data=shp, color=vc, weight=2,
                    fillColor=vc, fillOpacity=0.3,
                    popup=paste0(
                      "<div style='font-family:Fira Mono;font-size:11px;",
                      "background:#0d150d;color:#c8dcc8;padding:8px 12px;",
                      "border:1px solid #1a2e1a;border-left:3px solid ", vc, ";'>",
                      "<div style='color:", vc, ";font-size:9px;letter-spacing:2px;",
                      "text-transform:uppercase;margin-bottom:4px;'>", m$venom, "</div>",
                      "<b>", input$snake, "</b><br>",
                      "<em style='color:#5a7a5a;font-size:10px;'>", m$sci, "</em>",
                      "</div>"
                    ),
                    highlightOptions = highlightOptions(
                      weight=3, fillOpacity=0.55, bringToFront=TRUE)
        ) %>%
        addLegend(position="bottomright",
                  colors = c(vc, "#1a2e1a"),
                  labels = c(paste0(input$snake, " range"), "County boundary"),
                  title  = NULL,
                  opacity= 0.9)
    }
  })
  
  # ---- ALL SPECIES GRID ----
  
  output$species_grid <- renderUI({
    selected_vtypes <- input$venom_filter
    
    filtered <- Filter(function(nm) {
      m <- snake_meta[[nm]]
      vt <- m$venom
      any(sapply(c("Neurotoxic","Hemotoxic","Cytotoxic"), function(v) {
        grepl(v, vt, ignore.case=TRUE) && v %in% selected_vtypes
      })) ||
        ("Mixed / Other" %in% selected_vtypes && !any(sapply(c("Neurotoxic","Hemotoxic","Cytotoxic"),
                                                             function(v) grepl(v, vt, ignore.case=TRUE))))
    }, snake_names)
    
    cards <- lapply(filtered, function(nm) {
      m  <- snake_meta[[nm]]
      vc <- get_venom_color(m$venom)
      
      tags$div(
        style = paste0("background:#0d150d; border:1px solid #1a2e1a; ",
                       "border-top:3px solid ", vc, "; border-radius:2px; ",
                       "padding:14px 16px; transition:border-color 0.2s; ",
                       "cursor:pointer;"),
        onclick = paste0("Shiny.setInputValue('jump_species','", nm, "',{priority:'event'})"),
        
        # Image — use first available
        tags$div(style="position:relative; margin:-14px -16px 10px -16px; overflow:hidden; height:100px;",
                 tags$img(src=m$imgs[1], style="width:100%; height:100%; object-fit:cover; opacity:0.75;",
                          onerror="this.style.display='none'")
        ),
        
        # Name
        tags$div(style="font-family:'Oswald'; font-size:15px; font-weight:500;
                        color:#c8dcc8; letter-spacing:1px; margin-bottom:2px;", nm),
        tags$div(style="font-family:'Source Serif 4'; font-style:italic;
                        font-size:11px; color:#5a7a5a; margin-bottom:8px;", m$sci),
        
        # Venom badge only
        tags$div(style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:10px;",
                 tags$span(class="venom-badge",
                           style=paste0("color:",vc,"; border:1px solid ",vc,"33; font-size:8px;"),
                           m$venom)
        ),
        
        # Stats — length + habitat only
        tags$div(style="display:grid; grid-template-columns:1fr 1fr; gap:4px; margin-bottom:8px;",
                 lapply(list(
                   list("Length",  m$length),
                   list("Habitat", m$habitat)
                 ), function(s) {
                   tags$div(style="background:#0a100a; border:1px solid #1a2e1a; padding:5px 8px; border-radius:2px;",
                            tags$div(style="font-family:'Fira Mono'; font-size:8px; letter-spacing:1px;
                              text-transform:uppercase; color:#5a7a5a;", s[[1]]),
                            tags$div(style="font-family:'Oswald'; font-size:12px; color:#c8dcc8;
                              margin-top:1px; line-height:1.3;", s[[2]])
                   )
                 })
        ),
        
        # First aid preview
        tags$div(style=paste0("border-left:2px solid #b83232; padding:6px 10px;",
                              "background:#0a100a; border-radius:0 2px 2px 0;"),
                 tags$div(style="font-family:'Fira Mono'; font-size:8px; letter-spacing:1px;
                          text-transform:uppercase; color:#b83232; margin-bottom:3px;",
                          "\u26a0 First Aid"),
                 tags$div(style="font-family:'Source Serif 4'; font-size:11px;
                          color:#5a7a5a; line-height:1.6;",
                          substr(m$firstaid, 1, 90), "...")
        ),
        
        # Click hint
        tags$div(style="margin-top:8px; font-family:'Fira Mono'; font-size:8px;
                        letter-spacing:1px; color:#2a4a2a; text-transform:uppercase;",
                 "\u2192 click to view on map")
      )
    })
    
    layout <- function(cards) {
      tags$div(
        style = "display:grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                  gap:12px; padding:4px 0;",
        cards
      )
    }
    
    tagList(
      tags$div(style="color:#5a7a5a; font-family:'Fira Mono'; font-size:9px;
                      letter-spacing:2px; text-transform:uppercase; padding:4px 0 10px 0;",
               paste0("SHOWING ", length(filtered), " OF ", length(snake_names), " SPECIES")),
      layout(cards)
    )
  })
  
  # Jump to map tab when card is clicked
  observeEvent(input$jump_species, {
    updateSelectInput(session, "snake", selected=input$jump_species)
    updateNavbarPage(session, inputId=NULL,
                     selected="DISTRIBUTION MAP")
  })
  
  # ---- MULTI-SPECIES MAP ----
  
  multi_colors <- c(
    "#c8a84b","#b83232","#3a9a6a","#4a8aaa","#8a6ab8",
    "#d4823a","#4a9090","#906060","#609060","#606090"
  )
  
  output$multi_map <- renderLeaflet({
    sel   <- input$multi_species
    if (length(sel) == 0) sel <- snake_names[1]
    
    m <- leaflet(options = leafletOptions(zoomControl=TRUE)) %>%
      addProviderTiles("CartoDB.DarkMatter",
                       options=tileOptions(opacity=0.9)) %>%
      fitBounds(lng1=33.9, lat1=-4.68, lng2=41.9, lat2=4.62)
    
    if (!is.null(kenya_counties)) {
      m <- addPolygons(m, data=kenya_counties,
                       color="#1a2e1a", weight=1, fill=TRUE,
                       fillColor="#080d08", fillOpacity=0.3)
    }
    
    for (i in seq_along(sel)) {
      shp <- snake_shapes[[sel[i]]]
      if (is.null(shp)) next
      col <- multi_colors[((i-1) %% length(multi_colors)) + 1]
      m <- addPolygons(m, data=shp, color=col, weight=2,
                       fillColor=col, fillOpacity=0.25, group=sel[i],
                       popup=paste0("<div style='font-family:Fira Mono;font-size:11px;",
                                    "background:#0d150d;color:#c8dcc8;padding:6px 10px;",
                                    "border-left:3px solid ", col, ";'>",
                                    "<b>", sel[i], "</b><br>",
                                    "<em style='color:#5a7a5a;font-size:10px;'>",
                                    snake_meta[[sel[i]]]$sci, "</em>",
                                    "</div>"))
    }
    
    # Legend
    if (length(sel) > 0) {
      valid_sel <- sel[!sapply(snake_shapes[sel], is.null)]
      if (length(valid_sel) > 0) {
        cols_used <- multi_colors[seq_along(valid_sel)]
        m <- addLegend(m, position="bottomright",
                       colors=cols_used, labels=valid_sel,
                       opacity=0.9)
      }
    }
    m
  })
  
}

# ==============================================================================
# RUN
# ==============================================================================

shinyApp(ui = ui, server = server)
