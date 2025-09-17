rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    
    asterisk <- function(pvalue) {
        if (pvalue <= 0.001) return("\U002A\U002A\U002A")
        if (pvalue <= 0.01 & pvalue > 0.001) return("\U002A\U002A")
        if (pvalue <= 0.05 & pvalue > 0.01) return("\U002A")
        if (pvalue > 0.05) return(common::supsc("ns"))
    }
    
    hline_grob <- function(xmin, xmax, y, linewidth = 1.5) {
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
    }
})

rawdata <- readxl::read_excel("../../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        str_detect(img_name, "cancel", negate = TRUE)
    ) %>% 
    dplyr::mutate(
        nbt_total = nbt_total / 1e6,
        genotype = factor(genotype, levels = c("WT", "osrgf1-8")),
        heat = factor(paste0("T", heat), levels = c("T28", "T42")),
        RGF1 = factor(RGF1, c(0, 1)),
        # group = paste(genotype, heat, RGF1, sep = "_"),
        group = factor(
            paste(genotype, heat, RGF1, sep = "_"), 
            levels = c("WT_T28_0", "WT_T42_0",
                       "WT_T28_1", "WT_T42_1",
                       "osrgf1-8_T28_0", "osrgf1-8_T42_0",
                       "osrgf1-8_T28_1", "osrgf1-8_T42_1"))
    ) %>% 
    dplyr::mutate(
        root_length_increase = root_length - mean(DAT0_root_length),
        .by = "group"
    )

ggplot(df0, aes(group, root_length_increase, color = heat, shape = RGF1)) +
    geom_boxplot() +
    geom_point()



ggplot(df0, aes(geno_heat_RGF1, root_length_increase, color = heat)) +
    theme_bw() +
    labs(
        x = "Temperature (&deg;C)",
        y = "Root length increase (mm)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        size = 3,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MAX, label = CLD),
        size = 8
    ) +
    # scale_y_continuous(limits = c(5, 45)) +
    theme(
        text = element_text(size = 24),
        axis.title.x.bottom = element_blank()
    )

ggsave(
    filename = "root_length_increase.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 330,
    units = "cm",
    height = 13,
    width = 17
)
