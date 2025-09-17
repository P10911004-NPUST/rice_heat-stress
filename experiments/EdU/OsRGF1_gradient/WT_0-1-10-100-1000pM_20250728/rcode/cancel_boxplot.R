suppressMessages({
    rm(list = ls())
    if ( ! is.null(dev.list())) dev.off()
    set.seed(1)
    
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    source("C:/jklai/github/plotools/R/num2asterisk.R")
})

rawdata <- readxl::read_excel("../total_intensity.xlsx")

df0 <- rawdata %>%
    dplyr::mutate(
        genotype = str_replace(img_name, "DAI07_(.*)_(.*)pM_(Se|Cr)_R.*", "\\1"),
        treatment = str_replace(img_name, "DAI07_(.*)_(.*)pM_(Se|Cr)_R.*", "\\2"),
        root_type = str_replace(img_name, "DAI07_(.*)_(.*)pM_(Se|Cr)_R.*", "\\3"),
        replicate = "3",
        group = paste(genotype, treatment, sep = "_")
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(total_intensity),
        .by = "group"
    ) %>% 
    dplyr::filter( 
        treatment %in% c("0", "1000"),
        ! str_detect(img_name, "cancel")
    )

# Replicate 3 ====
## Distance from root tip ====
normality_pass <- is_normality(df0, distance_from_root_tip_pixels ~ treatment)
what_test <- ifelse(isTRUE(normality_pass), "t.test", "wilcox.test")

ggplot(df0, aes(treatment, distance_from_root_tip_pixels)) +
    theme_bw() +
    labs(
        x = "OsRGF1 (nM)",
        y = "Distance from<br>root tip (&micro;m)"
    ) +
    geom_boxplot() +
    geom_point(
        size = 4,
        alpha = 0.3,
        position = position_jitter(width = 0.1)
    ) +
    geom_signif(
        test = what_test,
        test.args = list(
            alternative = "two.sided",
            var.equal = TRUE,
            paired = FALSE
        ),
        comparisons = list(c("0", "1000")),
        map_signif_level = asterisk,
        colour = "grey30",
        size = .5,
        textsize = 10,
        vjust = .2,
        fontface = "bold.italic",
        tip_length = c(0.6, 0.1),
        y_position = 640
    ) +
    scale_y_continuous(limits = c(200, 700), breaks = seq(200, 700, 100)) +
    scale_x_discrete(labels = c("0", "1")) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 24),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9))
    )

ggsave(
    filename = "distance_from_root_tip.jpg",
    path = "./figures",
    create.dir = TRUE,
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)

