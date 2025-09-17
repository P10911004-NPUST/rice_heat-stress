rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)

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
    
    hline_grob <- function(xmin, xmax, y, linewidth = 1.5){
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
    dplyr::mutate(
        nbt_intensity = nbt_intensity / 1e6,
        root_length_increase = root_length - DAT0_root_length,
        genotype = factor(genotype, levels = c("WT", "osrgf1-7")),
        heat = factor(heat, levels = c(28, 38)),
        group = paste(genotype, paste0("T", heat), sep = "_")
    )


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Root length DAT 0
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
out <- oneway_test(df0, DAT0_root_length ~ group)
out$tests
cld <- out$cld
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX)
cld


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Root length DAT 1
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
out <- oneway_test(df0, root_length ~ group)
out$tests
cld <- out$cld
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX)
cld


out <- oneway_test(df0, root_length_increase ~ group)
out$tests
cld <- out$cld
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX) + 3
cld

ggplot(df0, aes(group, root_length_increase, color = heat)) +
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
