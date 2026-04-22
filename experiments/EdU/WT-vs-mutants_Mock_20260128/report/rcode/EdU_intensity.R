rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(ggtext)
library(ggsignif)
library(statool)
library(outlying)

geno_level <- c("WT", "osrgf1-7", "osrgf1-8", "osrgf1-15")

rawdata <- readxl::read_excel("../../OUT_EdU.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel"),
        genotype != "osrgf1-15"
    ) %>% 
    dplyr::mutate(
        total_intensity = total_intensity / 1e6,
        distance_from_root_tip_um = distance_from_root_tip_pixels * `resolution (um/pixel)`
    )


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Total intensity ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(total_intensity),
        .by = "genotype"
    ) %>% 
    dplyr::filter(!is_outlier) %>% 
    dplyr::slice_max(total_intensity, n = 6, by = "genotype")

out <- oneway_test(df1, total_intensity ~ genotype)
out$tests
cld <- out$cld
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MIN = MIN - 0.7,
        YPOS_MAX = estimate_cld_pos(MAX) + 0.2
    )

df1$genotype <- factor(df1$genotype, levels = geno_level)

ggplot(df1, aes(genotype, total_intensity, color = genotype)) +
    theme_classic() +
    labs(
        y = "EdU total intensity (10<sup>6</sup> AU)"
    ) +
    geom_boxplot(
        fill = "transparent",
        size = 1,
        linewidth = 0.5,
        outliers = FALSE,
        outlier.shape = NA
    ) +
    geom_point(
        size = 5,
        alpha = 0.5,
        position = position_jitter(width = 0.15, seed = 1)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MAX, label = CLD),
        size = 11
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N, color = GROUP),
        size = 7
    ) +
    scale_x_discrete(
        labels = c("WT", "<i>osrgf1-7</i>", "<i>osrgf1-8</i>")
    ) +
    scale_y_continuous(limits = c(2, 10)) +
    scale_color_manual(
        values = c("#000000", "#E69F00", "#0072B2", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 28),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 27,
            lineheight = 1.2,
            margin = ggplot2::margin(t = 11)
        ),
        # axis.line.x.bottom = element_blank(),
        # axis.ticks.x.bottom = element_blank(),
        
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
            # hjust = 1,
            margin = ggplot2::margin(r = 11)
        ),
        legend.position = "none",
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "bold", size = 25, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0.5
    )

ggsave(
    create.dir = TRUE,
    filename = "EdU_total_intensity.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 15,
    width = 17
)

