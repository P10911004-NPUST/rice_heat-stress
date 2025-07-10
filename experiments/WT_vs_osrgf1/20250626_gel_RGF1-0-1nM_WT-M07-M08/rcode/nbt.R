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

df0 <- rawdata %>% 
    dplyr::mutate(
        nbt_intensity = nbt_intensity / 1e7,
        genotype = str_replace(img_name, ".*_(WT|M07|M08)_(.*)nM_.*", "\\1"),
        treatment = str_replace(img_name, ".*_(WT|M07|M08)_(.*)nM_.*", "\\2"),
        group = paste(genotype, treatment, sep = "_")
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(nbt_intensity), 
        .by = group
    ) %>% 
    dplyr::filter(
        # !is_outlier,
        !str_detect(img_name, "cancel")
    )

df0$group <- factor(
    df0$group, 
    levels = c("WT_0", "WT_1", "M07_0", "M07_1", "M08_0", "M08_1")
)

car::Anova(aov(nbt_intensity ~ genotype * treatment, data = df0), type = 2)
anova(aov(nbt_intensity ~ genotype * treatment, data = df0))

out <- oneway_test(df0, nbt_intensity ~ group)
out$tests
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)
cld

ggplot(df0, aes(group, nbt_intensity, color = treatment)) +
    theme_bw() +
    labs(
        subtitle = "Gel system, DAI7, seminal root",
        x = "OsRGF1 (nM)",
        y = "Total NBT intensity<br>(10<sup>6</sup> AU)"
    ) +
    geom_boxplot(outliers = FALSE, alpha = 0.3) +
    geom_point(alpha = 0.5, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos - 0.3, label = CLD),
        size = 8
    ) +
    scale_color_manual(
        values = c("#000000", "#D55E00"),
        labels = c("Mock", "1 nM")
    ) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        axis.title.y.left = element_markdown(),
        plot.subtitle = element_markdown(size = 18),
        legend.position = "inside",
        legend.position.inside = c(.88, .88),
        legend.direction = "vertical",
        legend.background = element_blank(),
        legend.title = element_blank(),
        legend.key.spacing.y = ggplot2::unit(.2, "cm")
    )

ggsave(
    filename = "nbt_intensity_WT.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)

