# Snake-Distributions
This project aims to visualize the distribution of various snake species across Kenya using R

## Overview

Geographical maps were recreated from the Kenya MoH Guidelines for Prevention Diagnosis and Management of Snakebite Envenoming. It provides an interactive web application where you can select a specific snake species to view its distribution on a map along with relevant information and images.

## Installation and Setup

To run the application locally, follow these steps:
Install the required libraries using the following commands in RStudio:
   ```R
   install.packages(c("shiny", "leaflet", "sf", "dplyr", "png", "grid"))
   ```
Run the R script (`app.R`) in RStudio to launch the Shiny application.

## Usage

Upon launching the application, you will be presented with a map of Kenya with county boundaries outlined. On the sidebar, you can select a specific snake species from the dropdown menu.

- **Snake Selection**: Choose a snake species from the dropdown menu.
- **Snake Distribution**: The map will display the distribution area of the selected snake species in red.
- **Snake Information**: Below the selection menu, you will find information about the selected snake species, including its description and an image.

## Data Sources
-Kenya MoH Guidelines for Prevention Diagnosis and Management of Snakebite Envenoming.

## License
see the [LICENSE]file for details.
