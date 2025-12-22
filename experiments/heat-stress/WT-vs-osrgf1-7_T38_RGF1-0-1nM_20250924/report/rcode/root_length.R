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
        genotype = factor(genotype, levels = c("WT", "osrgf1-7")),
        RGF1 = factor(RGF1, c(0, 1)),
        group = paste(genotype, RGF1, sep = "_")
    ) %>% 
    dplyr::mutate(
        group = factor(group, levels = c("WT_0", "osrgf1-7_0", "WT_1", "osrgf1-7_1"))
    )

write.csv(df0, "plot_data.csv", row.names = FALSE)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# DAT 1 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% dplyr::filter(DAT == 1)

is_normality(df1, root_length ~ group)

out <- oneway_test(df1, root_length ~ group)
cld <- out$cld

ggplot(df1, aes(group, root_length, color = genotype)) +
    theme_classic() +
    labs(
        subtitle = "1 DAT (38&deg;C)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        size = 4, 
        alpha = 0.5,
        position = position_jitter(width = 0.1)
    ) +
    geom_signif(
        comparisons = list(
            c("WT_0", "osrgf1-7_0"),
            c("WT_1", "osrgf1-7_1")
        ),
        size = 0.7,
        textsize = 9,
        vjust = -0.5,
        test = "t.test",
        map_signif_level = pval2asterisk,
        colour = "black",
        y_position = c(80, 80),
        tip_length = c(0.05, 0.05, 0.5, 0.05)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, MIN - 5, label = N),
        size = 6
    ) +
    scale_x_discrete(
        labels = c("Mock", "", "1 nM OsRGF1", "")
    ) +
    scale_y_continuous(limits = c(40, 100)) +
    scale_color_manual(
        labels = c("WT", "<i>osrgf1-7</i>"),
        values = c("black", "grey")
    ) +
    hline_grob(1 - 0.4, 2 + 0.4, 40 - 2.5) +
    hline_grob(3 - 0.4, 4 + 0.4, 40 - 2.5) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 29),
        plot.subtitle = element_markdown(margin = ggplot2::margin(b = 15)),
        axis.title.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(
            lineheight = 1.2,
            margin = ggplot2::margin(r = 9)
        ),
        axis.text.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 9),
            hjust = c(-0.3, 0, 0.2, 0)
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        legend.background = element_blank(),
        legend.title = element_blank(),
        legend.text = element_markdown(),
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
        legend.key.spacing.x = grid::unit(0.05, "npc")
    )

ggsave(
    filename = "root_length_DAT1.jpg",
    path = "./figure",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 13,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# DAT 2 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% dplyr::filter(DAT == 2)

is_normality(df1, root_length ~ group)

out <- oneway_test(df1, root_length ~ group)
cld <- out$cld

ggplot(df1, aes(group, root_length, color = genotype)) +
    theme_classic() +
    labs(
        subtitle = "2 DAT (38&deg;C)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        size = 4, 
        alpha = 0.5,
        position = position_jitter(width = 0.1)
    ) +
    geom_signif(
        comparisons = list(
            c("WT_0", "osrgf1-7_0"),
            c("WT_1", "osrgf1-7_1")
        ),
        size = 0.7,
        textsize = 9,
        vjust = -0.5,
        test = "t.test",
        map_signif_level = pval2asterisk,
        colour = "black",
        y_position = c(85, 85),
        tip_length = c(0.4, 0.05, 0.4, 0.05)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, MIN - 5, label = N),
        size = 6
    ) +
    scale_x_discrete(
        labels = c("Mock", "", "1 nM OsRGF1", "")
    ) +
    scale_y_continuous(limits = c(40, 100)) +
    scale_color_manual(
        labels = c("WT", "<i>osrgf1-7</i>"),
        values = c("black", "grey")
    ) +
    hline_grob(1 - 0.4, 2 + 0.4, 40 - 2.5) +
    hline_grob(3 - 0.4, 4 + 0.4, 40 - 2.5) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 29),
        plot.subtitle = element_markdown(margin = ggplot2::margin(b = 15)),
        axis.title.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(
            lineheight = 1.2,
            margin = ggplot2::margin(r = 9)
        ),
        axis.text.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 9),
            hjust = c(-0.3, 0, 0.2, 0)
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        legend.background = element_blank(),
        legend.title = element_blank(),
        legend.text = element_markdown(),
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
        legend.key.spacing.x = grid::unit(0.05, "npc")
    )

ggsave(
    filename = "root_length_DAT2.jpg",
    path = "./figure",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 13,
    width = 17
)
