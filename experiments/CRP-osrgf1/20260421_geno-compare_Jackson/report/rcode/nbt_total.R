rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)
# options(contrasts = c("contr.sum", "contr.poly"))

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    library(outlying)
    
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

geno_lvl <- c("WT", "osrgf1-7", "osrgf1-8")

rawdata <- readxl::read_excel("../../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::mutate(
        val = nbt_total_intensity / 1e6,
        grp = genotype
    )

df1 <- df0 %>% 
    dplyr::filter(
        note == "ok"
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(val, sensitivity = 3),
        .by = "grp"
    ) %>% 
    dplyr::filter(!is_outlier) %>%
    dplyr::slice_max(val, n = 5, by = "grp") %>% 
    dplyr::select(-"is_outlier") %>% 
    dplyr::mutate(
        genotype = factor(genotype, levels = geno_lvl),
        grp = factor(grp, levels = geno_lvl)
    )

out <- oneway_test(df1, val ~ grp)
out$tests
cld <- out$cld
cld
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MIN = MIN - 3.5,
        YPOS_MAX = estimate_cld_pos(MAX) + 1.5
    )


ggplot(df1, aes(grp, val, color = grp)) +
    theme_classic() +
    labs(
        y = "Total NBT intensity (10<sup>6</sup> AU)"
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
        position = position_jitter(width = 0.1, seed = 123)
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
    scale_y_continuous(limits = c(0, 40), breaks = seq(0, 40, 10)) +
    scale_color_manual(
        values = c("#000000", "#E69F00", "#0072B2", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 27,
            lineheight = 1.2,
            margin = ggplot2::margin(t = 11)
        ),
        # axis.line.x.bottom = element_blank(),
        # axis.ticks.x.bottom = element_blank(),
        
        axis.title.y.left = element_markdown(
            lineheight = 1.2,
            hjust = 1,
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
    filename = "nbt_total_geno-compare.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 19
)

