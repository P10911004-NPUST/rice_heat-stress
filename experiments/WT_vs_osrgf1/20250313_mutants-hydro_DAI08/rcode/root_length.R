suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool", upgrade = FALSE, quiet = TRUE)
    
    # source("https://github.com/P10911004-NPUST/statool/blob/main/R/outliers.R?raw=true")
    source("C:/jklai/github/statool/R/outliers.R")
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    source("C:/jklai/github/plotools/R/color_palette.R")
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        str_detect(img_name, "R01"),
        !str_detect(img_name, "cancel")
    ) %>% 
    dplyr::mutate(
        genotype = gsub(pattern = paste(rep("(.*)", 7), collapse = "_"), replacement = "\\2", x = img_name),
        nbt_area = nbt_area / 1000
    ) %>% 
    dplyr::group_by(genotype) %>% 
    dplyr::mutate(
        is_outlier = is_outlier(root_length, use_median = TRUE)
    ) %>% 
    dplyr::ungroup() %>% 
    dplyr::filter(!is_outlier)

df0$genotype <- factor(df0$genotype, levels = c("WT", "M07", "M08", "M15"))

stats_res <- oneway_test(df0, root_length ~ genotype)
stats_res$tests
stats_res <- stats_res$result
stats_res

ggplot(df0, aes(genotype, root_length, colour = genotype)) +
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
    scale_color_manual(values = discrete_4$type01) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank()
    )





