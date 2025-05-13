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

csv_list <- list.files("../EdU/WT-vs-mutants_Mock_20250303", pattern = "\\.csv", full.names = TRUE)
if (length(csv_list) > 1) stop("More than one csv file")

rawdata <- read.csv(csv_list)

df0 <- rawdata %>% 
    dplyr::filter(!str_detect(img_name, "cancel")) %>% 
    dplyr::filter(!str_detect(img_name, "fluoromount|scan2")) %>%
    dplyr::mutate(
        genotype = gsub("(.*)_(.*)_(.*)_(.*).czi", "\\1", img_name),
        total_intensity = total_intensity / 10e6,
        thickness = slices * 2  # fixed Z-stack interval: 2 um
    ) %>% 
    dplyr::mutate(
        genotype = factor(genotype, levels = c("WT", "M07", "M08", "M15"))
    )
write.csv(df0, "./tables/EdU.csv", row.names = FALSE)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# EdU avg intensity ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, avg_intensity ~ genotype)
stats_res$tests
stats_res <- stats_res$result
stats_res

ggplot(df0, aes(genotype, avg_intensity, color = genotype)) +
    labs(
        subtitle = "EdU signal",
        y = "Average intensity (DN)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(GROUPS, MAX + 10, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(80, 210)) +
    scale_color_manual(values = c("#fb8500", "#8ecae6", "#219ebc", "#023047")) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank()
    )

ggsave2(filename = "avg_intensity.jpg", path = "./figures")


# #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# # EdU total intensity ====
# #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# stats_res <- oneway_test(df0, total_intensity ~ genotype)
# stats_res$tests
# stats_res <- stats_res$result
# stats_res
# 
# ggplot(df0, aes(genotype, total_intensity, color = genotype)) +
#     labs(
#         subtitle = "EdU signal",
#         y = "Total intensity (10<sup>6</sup> DN)"
#     ) +
#     geom_boxplot() +
#     geom_point() +
#     geom_text(
#         inherit.aes = FALSE,
#         data = stats_res,
#         mapping = aes(GROUPS, MAX + 0.1, label = CLD),
#         size = 8
#     ) +
#     scale_y_continuous(limits = c(0, 0.8)) +
#     scale_color_manual(values = c("#fb8500", "#8ecae6", "#219ebc", "#023047")) +
#     theme(
#         legend.position = "none",
#         axis.title.x.bottom = element_blank()
#     )
# 
# ggsave2(filename = "total_intensity.jpg", path = "./figures")



#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Thickness ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, thickness ~ genotype)
stats_res$tests
stats_res <- stats_res$result
stats_res

ggplot(df0, aes(genotype, thickness, color = genotype)) +
    labs(
        subtitle = "Thickness = slices &times; 2 <i>&micro;</i>m",
        y = "Thickness (<i>&micro;</i>m)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(GROUPS, MAX + 10, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(80, 160)) +
    scale_color_manual(values = c("#fb8500", "#8ecae6", "#219ebc", "#023047")) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank()
    )

ggsave2(filename = "thickness.jpg", path = "./figures")






