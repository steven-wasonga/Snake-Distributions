library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(png)
library(grid)

# Load Kenyan Counties shapefile
kenya_counties <- st_read("KE/kenya.shp")

# Load snake distribution shapefiles
snake_shapefiles <- list.files(path = ".", pattern = "\\.shp$", full.names = TRUE)
snake_data <- lapply(snake_shapefiles, st_read)

# Name each element in the list after the snake species
snake_names <- c("Black Mamba", "Black Necked Spitting Cobra",
                 "Boomslang", "Carpet Viper", "Eastern Forest Cobra",
                 "Egyptian Cobra", "Gaboon Viper", "Gold's Tree Cobra",
                 "Green Mamba", "Jameson Mamba", "Large Brown Spitting Cobra",
                 "Puff Adder", "Red Spitting Cobra", "Rhinoceros Viper",
                 "Twig Snake", "Yellow Bellied Sea Snake")
names(snake_data) <- snake_names

# Store image paths for each snake species
snake_images <- list(
  "Black Mamba" = "Black Mamba.png",
  "Black Necked Spitting Cobra" = "Black Necked Spitting Cobra.png",
  "Boomslang" = "Boomslang.png",
  "Carpet Viper" = "No-Image.png",
  "Eastern Forest Cobra" = "No-Image.png",
  "Egyptian Cobra" = "Egyptian Cobra.png",
  "Gaboon Viper" = "No-Image.png",
  "Gold's Tree Cobra" = "No-Image.png",
  "Green Mamba" = "No-Image.png",
  "Jameson Mamba" = "No-Image.png",
  "Large Brown Spitting Cobra" = "Large Brown Spitting Cobra.png",
  "Puff Adder" = "Puff Adder.png",
  "Red Spitting Cobra" = "Red Spitter.png",
  "Rhinoceros Viper" = "No-Image.png",
  "Twig Snake" = "No-Image.png",
  "Yellow Bellied Sea Snake" = "No-Image.png"
)

# Descriptions for each snake
snake_descriptions <- c(
  "Dendroaspis polylepis:The longest venomous snake in Africa, with an average length of 2.2–4.2m. It is heavily built, colored greyish brown or olive brown with a black buccal lining. In defense, it rears up, distending a small hood, opening its mouth, and hissing. Bites from this snake are serious medical emergencies due to the venom's rapid spread in the body.",
  "Naja nigricollis:The average length is 1.2–2.2m. Its color varies from yellowish-brown to olive-brown or black, with black bands on the throat and ventral area. The snake is thick-bodied with a broad head. In defense, it raises its forebody, spreads a broad hood, and hisses. The venom is both cytotoxic and neurotoxic.",
  "Dispholidus typus:With an average length of 1.0–1.6m, this snake has a bright green body with black interstitial skin in adults. Its head is bluntly rounded with a distinct canthus rostralis and large round pupils. The venom is haemotoxic, affecting blood clotting.",
  "Echis ocellatus: This snake averages 0.3–0.6m in length, with a pale brown body, darker brown dorsal markings, and a white belly. It has a stout body with keeled dorsal scales and coils to produce a rasping sound when threatened. The venom is highly haemotoxic.",
  "Naja subfulva: With an average length of 1.5–2.7m, its body is dark brown to black with lighter bands on the ventral side. In defense, it raises its forebody, spreads a narrow hood, and the venom is neurotoxic, causing respiratory paralysis.",
  "Naja haje:This snake averages 1.5–2.5m in length and is usually a uniform dark brown or black, but can also be yellowish-brown. Its head is large and broad with a distinct neck. In defense, it spreads a wide hood and hisses loudly. The venom is neurotoxic and cytotoxic.",
  "Bitis gabonica:With an average length of 1.0–1.8m, it has a heavy, thick body with a broad head and distinctive horn-like structures above the nostrils. The color pattern includes browns, yellows, and purples. The venom is cytotoxic and haemotoxic.",
  "Pseudohaje goldii: Averaging 1.2–2.4m in length, it has a slender body with a long, thin tail, usually olive to dark brown. The head is small with a rounded snout, and in defense, it raises its head and forebody off the ground. The venom is neurotoxic.",
  "Dendroaspis angusticeps: This snake averages 1.8–2.5m in length, with a slender, bright green body sometimes with a yellowish tint. Its head is distinct from the neck, and in defense, it spreads a narrow hood. The venom is neurotoxic, affecting the nervous system.",
  "Dendroaspis jamesoni: Averaging 1.2-2.8m in length, in Kenya, the snake appears bright green to yellowish-green on the head and neck tapering to a black tail with scales edged in black. This species is mainly arboreal, and in defense, it spreads a fine hood. (Only found in Western Kenya)",
  "Naja ashei: With an average length of 1.5–2.7m, its color ranges from light to dark brown with a paler underside. It is thick-bodied with a broad head and can spit venom up to 2.5 meters. The venom is cytotoxic.",
  "Bitis arietans: Averaging 1.0–1.5m in length, it has a heavy, thick body with a broad, flat head. The color pattern includes browns and grays with chevron-like markings. The venom is cytotoxic and haemotoxic.",
  "Naja pallida: Averaging 0.7–1.2m in length, its body is bright red to pink with a pale underside. In defense, it spreads a narrow hood and can spit venom. The venom is cytotoxic.",
  "Bitis nasicornis:  Averaging 0.7–1.2m in length, it has bright, colorful patterns of greens, blues, and yellows with distinctive horn-like structures. The venom is cytotoxic and haemotoxic.",
  "Thelotornis capensis: Averaging 0.7–1.2m in length, its body is very slender with a pointed snout, usually grey or brown with a pale underside. The venom is haemotoxic but less dangerous to humans.",
  "Hydrophis platurus: Averaging 0.5–1.0m in length, its body is slender with black and yellow banding. This snake is fully marine and found in the open ocean. The venom is neurotoxic, affecting the nervous system."
)

# Ensure all shapefiles use the same CRS
kenya_counties <- st_transform(kenya_counties, crs = st_crs(4326))
snake_data <- lapply(snake_data, st_transform, crs = st_crs(4326))

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-color: #000;
        color: #fff;
      }
      .well {
        background-color: #333;
        border-color: #444;
      }
      .form-control {
        background-color: #222;
        color: #fff;
        border-color: #444;
      }
      .btn, .btn:hover, .btn:active, .btn:focus {
        background-color: #444;
        border-color: #555;
      }
      #map {
        height: calc(100vh - 80px) !important;
      }
      .snake-img {
        width: 200px;
        height: auto;
      }
      .logo {
        position: absolute;
        bottom: 50px;
        left: 450px;
        width: 50px;
      }
.snake-description {
    color: #ccc;
    font-size: 14px;
    margin-top: 5px;
    word-wrap: break-word;
    white-space: normal;
}


    "))
  ),
  titlePanel(HTML("<h1 style='text-align: center;'>Snake Distribution in Kenya</h1>")),
  sidebarLayout(
    sidebarPanel(
      selectInput("snake", "Choose a snake species:", choices = snake_names),
      uiOutput("snake_images"),  # This will dynamically display images
      div(class = "snake-description", uiOutput("snake_description"))  # Display description text
    ),
    mainPanel(
      leafletOutput("map", width = "100%", height = "100%"),
      absolutePanel(
        tags$img(src = "ksric.png", class = "logo"), 
        fixed = TRUE
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    selected_snake <- snake_data[[input$snake]]
    
    leaflet() %>%
      addTiles(
      ) %>%
      addPolygons(data = kenya_counties, color = "black", weight = 1, fill=FALSE) %>%
      addPolygons(data = selected_snake, color = "red", weight = 1, fillOpacity = 0.5) %>%
      fitBounds(
        lng1 = 33.9098987, lat1 = -4.6775046, # Southwest corner of Kenya
        lng2 = 41.899578, lat2 = 4.62         # Northeast corner of Kenya
      )
  })
  
  output$snake_images <- renderUI({
    # Get the image path for the selected snake species
    image <- snake_images[[input$snake]]
    
    # Create an img element to display the image
    img_tag <- tags$img(src = image, class = "snake-img")
    
    # Return the img element
    img_tag
  })
  
  output$snake_description <- renderUI({
    # Get the index of the selected snake
    snake_index <- which(snake_names == input$snake)
    
    # Return the corresponding description
    div(snake_descriptions[snake_index])
  })
}

# Run the app
shinyApp(ui, server)

