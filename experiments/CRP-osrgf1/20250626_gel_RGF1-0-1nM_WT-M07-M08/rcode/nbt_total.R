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
    
    hline_grob <- function(xmin, xmax, y){
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = 2)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
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
    # dplyr::mutate(
    #     is_outlier = Grubbs_test(nbt_intensity), 
    #     .by = group
    # ) %>% 
    dplyr::filter(
        # !is_outlier,
        !str_detect(img_name, "cancel")
    )

df0$group <- factor(
    df0$group, 
    levels = c("WT_0", "WT_1", "M07_0", "M07_1", "M08_0", "M08_1")
)

write.csv(df0, "./nbt_intensity.csv", row.names = FALSE)

car::Anova(aov(nbt_intensity ~ genotype * treatment, data = df0), type = 2)
anova(aov(nbt_intensity ~ genotype * treatment, data = df0))

out <- oneway_test(df0, nbt_intensity ~ group)
out$tests
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX) - 0.35
cld

ggplot(df0, aes(group, nbt_intensity, color = treatment)) +
    theme_classic() +
    labs(
        # subtitle = "Gel system, DAI7, seminal root",
        x = "OsRGF1 (nM)",
        y = "Total NBT intensity<br>(10<sup>6</sup> AU)"
    ) +
    geom_boxplot(outliers = FALSE, alpha = 0.3) +
    geom_point(
        size = 4, 
        alpha = 0.5, 
        position = position_jitter(width = 0.1)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD),
        size = 8
    ) +
    scale_x_discrete(
        labels = c("WT", "", "<i>osrgf1-7</i>", "", "<i>osrgf1-8</i>", "")
    ) +
    scale_y_continuous(limits = c(0.5, 3.5), breaks = seq(0.5, 3.5, 0.5)) +
    scale_color_manual(
        values = c("#000000", "#D55E00"),
        labels = c("Mock", "1 nM OsRGF1")
    ) +
    hline_grob(xmin = 1 - 0.3, xmax = 2 + 0.3, y = .5 - .1) +
    hline_grob(xmin = 3 - 0.3, xmax = 4 + 0.3, y = .5 - .1) +
    hline_grob(xmin = 5 - 0.3, xmax = 6 + 0.3, y = .5 - .1) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        # plot.subtitle = element_markdown(size = 18),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 5),
            size = 25,
            face = "bold",
            hjust = c(-.35, 0, .22, 0, .22, 0)
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.5, .95),
        legend.direction = "horizontal",
        legend.background = element_blank(),
        legend.title = element_blank(),
        legend.key.spacing.x = ggplot2::unit(0.05, "npc")
    )

ggsave(
    filename = "nbt_total.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)

