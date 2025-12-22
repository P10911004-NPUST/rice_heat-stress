rm(list = ls())
if (!is.null(dev.list())) dev.off()

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    
    asterisk <- function(pvalue){
        if (pvalue <= 0.001) return("\U002A\U002A\U002A")
        if (pvalue <= 0.01 & pvalue > 0.001) return("\U002A\U002A")
        if (pvalue <= 0.05 & pvalue > 0.01) return("\U002A")
        if (pvalue > 0.05) return(common::supsc("ns"))
    }
})

rawdata <- readxl::read_excel("../../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::mutate(
        nbt_intensity = nbt_intensity / 1e6,
        root_length_diff = root_length - root_length_control_DAT0,
        TEMP = factor(TEMP, levels = c(28, 38))
    )

t_test(df0, root_length_diff ~ TEMP)

ggplot(df0, aes(TEMP, root_length_diff)) +
    theme_bw() +
    labs(
        x = "Temperature (&deg;C)",
        y = "Root length increase (mm)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_signif(
        comparisons = list(c("28", "38")),
        test = "t.test",
        map_signif_level = asterisk,
        y_position = 21,
        textsize = 10
    ) +
    scale_y_continuous(limits = c(5, 25)) +
    theme(
        text = element_text(size = 24),
        axis.title.x.bottom = element_markdown()
    )

ggsave(
    filename = "root_length_diff.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 330,
    units = "cm",
    height = 13,
    width = 17
)
