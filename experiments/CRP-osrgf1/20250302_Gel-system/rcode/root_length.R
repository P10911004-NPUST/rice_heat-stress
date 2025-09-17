suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool")
    if (!require(tidyverse)) install.packages("tidyverse")
    
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    sapply(list.files("C:/jklai/github/statool/R", pattern = "\\.R", full.names = TRUE), source)
    
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(!str_detect(img_name, "cancel")) %>% 
    dplyr::mutate(
        genotype = gsub("(.*)_(.*)_(.*)_(.*)_(.*)_(.*)_(.*)", "\\2", img_name),
        nbt_intensity = nbt_intensity / 10e6,
        nbt_area = nbt_area / 1000
    ) %>% 
    dplyr::mutate(
        genotype = factor(genotype, levels = c("WT", "M07", "M08", "M15"))
    )
write.csv(df0, "./tables/root_length.csv", row.names = FALSE)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# EdU avg intensity ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, root_length ~ genotype)
stats_res$tests
stats_res <- stats_res$result
stats_res

ggplot(df0, aes(genotype, root_length, color = genotype)) +
    labs(
        y = "Root length (mm)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(GROUPS, MAX + 10, label = CLD),
        size = 8
    ) +
    # scale_y_continuous(limits = c(80, 210)) +
    scale_color_manual(values = c("#fb8500", "#8ecae6", "#219ebc", "#023047")) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank()
    )

ggsave2(filename = "root_length.jpg", path = "./figures")

