# Kenya Snake Atlas

An interactive web application for visualising the distribution of Kenya's 13 medically important snake species, built with R Shiny. Developed in partnership with KSRIC, KIPRE, and the Kenya Ministry of Health.

## Overview

Distribution shapefiles were derived from the Kenya MoH *Guidelines for the Prevention, Diagnosis and Management of Snakebite Envenoming*. The atlas provides an accessible reference for species identification, geographic range and emergency first aid protocols.

## Features

- **Distribution Map** — Select any of the 13 species to render its range as a colour-coded polygon overlay on a county-boundary base map of Kenya. Popup labels show venom type and scientific name on click.
- **Species Sidebar** — Each selection surfaces the species photograph, venom type badge, adult length, visual appearance description, habitat, ecological notes, and a colour-coded emergency first aid protocol.
- **All Species Gallery** — Browse all 13 species as cards filtered by venom category (Neurotoxic, Hemotoxic, Cytotoxic). Click any card to jump directly to that species on the distribution map.
- **Multi-Species Overlay Map** — Select up to 13 species simultaneously to compare overlapping ranges across Kenya on a single map with a colour legend.

## The 13 Species Covered

| Common Name | Scientific Name | Venom Type |
|---|---|---|
| Puff Adder | *Bitis arietans* | Cytotoxic / Hemotoxic |
| Black Mamba | *Dendroaspis polylepis* | Neurotoxic |
| Green Mamba | *Dendroaspis angusticeps* | Neurotoxic |
| Boomslang | *Dispholidus typus* | Hemotoxic |
| Red Spitting Cobra | *Naja pallida* | Cytotoxic |
| Black Necked Spitting Cobra | *Naja nigricollis* | Cytotoxic / Neurotoxic |
| Large Brown Spitting Cobra | *Naja ashei* | Cytotoxic |
| Carpet Viper | *Echis ocellatus* | Hemotoxic |
| Eastern Forest Cobra | *Naja subfulva* | Neurotoxic |
| Egyptian Cobra | *Naja haje* | Neurotoxic / Cytotoxic |
| Gaboon Viper | *Bitis gabonica* | Cytotoxic / Hemotoxic |
| Rhinoceros Viper | *Bitis nasicornis* | Cytotoxic / Hemotoxic |
| Jameson's Mamba | *Dendroaspis jamesoni* | Neurotoxic |

## Installation

Install the required R packages:

```r
install.packages(c("shiny", "bslib", "leaflet", "sf", "dplyr"))
```

## Local Setup

1. Clone or download this repository.
2. Ensure the following files are present in the project root:
   - `app.R`
   - `KE/kenya.shp` (and associated `.dbf`, `.prj`, `.shx` files) — Kenya county boundaries
   - One `.shp` set per species, named exactly as the species appears in the app (e.g. `Puff Adder.shp`)- Email steven@primateresearch.org for associated shapefiles
3. Open `app.R` in RStudio and click **Run App**, or run from the console:

```r
shiny::runApp("app.R")
```

## Deployment

The app is deployed on shinyapps.io. To publish your own instance:

```r
install.packages("rsconnect")
rsconnect::deployApp()
```

Ensure all shapefiles are included in the deployment directory — shinyapps.io only bundles files present locally at publish time.

## Data Sources

- Kenya MoH *Guidelines for the Prevention, Diagnosis and Management of Snakebite Envenoming*
- Species range shapefiles digitised from MoH distribution maps
- Visual appearance descriptions compiled from peer-reviewed literature

## Partners

| | |
|---|---|
| **KSRIC** | Kenya Snakebite Research & Intervention Centre |
| **KIPRE** | Kenya Institute of Primate Research |
| **MoH** | Ministry of Health, Kenya |

## License

See the [LICENSE](LICENSE) file for details.
