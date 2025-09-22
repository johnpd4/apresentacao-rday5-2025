pacote = c("shiny", "leaflet", "dplyr", "htmltools", "leaflet", "sp", "sf", "gstat", "ggplot2",
           "terra", "leaflet.minicharts", "shinyWidgets", "plotly", "rlang", "leafsync")

bib = knitr::write_bib(pacote)

for(i in 1:length(bib)){

  write(bib[[i]], file = "~/geospaNN/apresentacoes/r_day_southstat/citacoes.bib", append = T)

}
