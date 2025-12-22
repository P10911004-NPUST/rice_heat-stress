rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)
options(contrasts = c("contr.sum", "contr.poly"))

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

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# WT ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
WT <- df0 %>% 
    dplyr::filter(genotype == "WT") %>% 
    dplyr::mutate(group = paste(heat, RGF1, sep = "_")) %>% 
    dplyr::mutate(is_outlier = Grubbs_test(nbt_total), .by = "group") %>% 
    dplyr::filter(!is_outlier)

is_normal <- is_normality(WT, nbt_total ~ group)
if (is_normal)
{
    aov_mod <- stats::aov(nbt_total ~ heat * RGF1, data = WT)
    car::Anova(aov_mod, type = 3)
} else {
    aov_mod <- ARTool::art(nbt_total ~ heat * RGF1, data = WT)
    anova(aov_mod)
}


out <- oneway_test(WT, nbt_total ~ group)
out$tests
cld <- out$cld
cld





