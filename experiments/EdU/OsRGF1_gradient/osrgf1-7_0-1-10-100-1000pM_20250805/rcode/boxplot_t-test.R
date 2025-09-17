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
    dplyr::filter(
        ! str_detect(img_name, "cancel"),
        ! str_detect(note, "discard")
    ) %>% 
    dplyr::mutate(
        genotype = str_replace(img_name, "DAI07_(.*)_(.*)pM_(Se|Cr)_R.*", "\\1"),
        treatment = str_replace(img_name, "DAI07_(.*)_(.*)pM_(Se|Cr)_R.*", "\\2"),
        root_type = str_replace(img_name, "DAI07_(.*)_(.*)pM_(Se|Cr)_R.*", "\\3"),
        distance = distance_from_root_tip_pixels * `resolution (um/pixel)`,
        replicate = "3",
        group = paste(genotype, treatment, sep = "_")
    ) %>% 
    dplyr::filter(treatment %in% c("0", "1000")) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(total_intensity),
        .by = "group"
    )

normality_pass <- is_normality(df0, distance_from_root_tip_pixels ~ treatment)
what_test <- ifelse(isTRUE(normality_pass), "t.test", "wilcox.test")

write.csv(df0, "./osrgf1-7_boxplot_data.csv", row.names = FALSE)

ggplot(df0, aes(treatment, distance)) +
    theme_classic() +
    labs(
        subtitle = "<i>osrgf1-7</i>",
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
        tip_length = c(0.7, 0.1),
        y_position = 800
    ) +
    scale_y_continuous(limits = c(300, 900), breaks = seq(300, 900, 200)) +
    scale_x_discrete(labels = c("0", "1")) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 24),
        plot.subtitle = element_markdown(),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        legend.position = "none",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
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




