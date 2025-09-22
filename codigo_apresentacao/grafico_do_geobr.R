library(geobr)
library(dplyr)
library(ggplot2)
library(gridExtra)

br = geobr::read_country()
regioes = geobr::read_region() |> select(name_region, geom)
rs = geobr::read_state("RS")
mun = geobr::read_municipality("RS")

# par(mfrow = c(2,2))
# plot(br, main = "Brasil")
# plot(regioes, main = "Regiões")
# plot(rs$abbrev_state, main = "Rio Grande do Sul")
# plot(mun$abbrev_state, main = "Municípios do Rio Grande do Sul")

br_plot = ggplot(data = br) + geom_sf() + ggtitle("Brasil") + theme(plot.margin = unit(c(1,1,1,1), "mm"))
regioes_plot = ggplot(data = regioes, aes(fill = name_region)) + geom_sf() +
                 theme(legend.position = "none", plot.margin = unit(c(1,1,1,1), "mm")) + ggtitle("Regiões")
rs_plot = ggplot(data = rs) + geom_sf() + ggtitle("Rio Grande do Sul") + theme(plot.margin = unit(c(1,1,1,1), "mm"))
mun_plot = ggplot(data = mun, aes(fill = name_muni)) + geom_sf() +
             theme(legend.position = "none", plot.margin = unit(c(1,1,1,1), "mm")) + ggtitle("Malha municipal do RS")

plt_final = grid.arrange(br_plot, regioes_plot, rs_plot, mun_plot)

ggsave(plot = plt_final, filename = "~/geospaNN/apresentacoes/r_day_southstat/plots_geobr.png", width = 5, height = 5, dpi = 1000)