suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(ggtext)) install.packages("ggtext")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool", upgrade = "always")
    
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    
    heatmap_gradient <- function(
        n_breaks = 30,
        color_set = c("#1d3557", "#e63946")
    ){
        colorRampPalette(color_set)(n_breaks)
    }
})

rawdata <- readxl::read_excel("../OUT_Magnif_32X.xlsx")

# genotype <- c("WT", "M07")
# RGF1 <- c("0", "OsRGF1-1nM")
# salt <- c("0", "NaCl-50mM")
# group_lvls <- paste(
#     rep(genotype, each = length(treatment)), 
#     rep(treatment, times = length(genotype)),
#     sep = "_"
# )

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel")
    ) %>% 
    dplyr::mutate(
        nbt_intensity = nbt_intensity / 1e7,
        genotype = str_replace(img_name, ".*_(WT|M07)_.*", "\\1"),
        RGF1 = str_replace(img_name, ".*_RGF1-(.*)nM_.*", "\\1"),
        salt = str_replace(img_name, ".*_NaCl-(.*)mM_.*", "\\1"),
        treatment = paste(RGF1, salt, sep = "_"),
        group = paste(genotype, treatment, sep = "_")
    ) %>% 
    dplyr::mutate(
        treatment = case_when(
            treatment == "0_0" ~ "Mock",
            treatment == "1_0" ~ "OsRGF1",
            treatment == "0_50" ~ "NaCl",
            treatment == "1_50" ~ "NaCl + OsRGF1",
        )
    )

df0$treatment <- factor(df0$treatment, levels = c("Mock", "OsRGF1", "NaCl", "NaCl + OsRGF1"))
df0$group <- factor(
    df0$group, 
    levels = c("WT_0_0", "WT_1_0", "WT_0_50", "WT_1_50",
               "M07_0_0", "M07_1_0", "M07_0_50", "M07_1_50")
)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# WT ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0

out <- oneway_test(df1, root_length ~ group)
out$tests
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)
cld

ggplot(df1, aes(group, root_length, color = treatment)) +
    theme_classic() +
    labs(
        subtitle = "Gel system, DAI6, seminal root",
        x = element_blank(),
        y = "Root length (mm)",
        color = element_blank()
    ) +
    geom_boxplot(outliers = FALSE, alpha = 0.3) +
    geom_point(alpha = 0.5, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD),
        size = 8
    ) +
    scale_x_discrete(
        labels = c(
            "", "WT", "", "",
            "", "<i>osrgf1-7</i>", "", ""
        )
    ) +
    scale_y_continuous(limits = c(50, 90)) +
    hline_grob(1 - .3, 4 + .3, 49) +
    hline_grob(5 - .3, 8 + .3, 49) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        plot.subtitle = element_markdown(size = 18),
        axis.ticks.x.bottom = element_blank(),
        axis.line.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(hjust = c(0, 0)),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        legend.position = "top",
        legend.key.spacing.x = grid::unit(0.5, "cm"),
        legend.justification.top = 1
    )

ggsave(
    filename = "root_length_WT-M07.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


