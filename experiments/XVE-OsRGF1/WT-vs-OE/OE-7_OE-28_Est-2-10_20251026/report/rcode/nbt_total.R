rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)
options(contrasts = c("contr.sum", "contr.poly"))

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    
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
    dplyr::filter(str_detect(img_name, "cancel", negate = TRUE)) %>%
    dplyr::mutate(
        nbt_total = nbt_total / 1e6,
        Estradiol_uM = as.character(Estradiol_uM),
        group = paste(genotype, Estradiol_uM, sep = "_")
    )

write.csv(df0, "./figure/nbt.csv", row.names = FALSE)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OE_7-8-2 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(
        genotype %in% c("WT", "XVE-OsRGF1_7-8-2"),
        Estradiol_uM %in% c("0", "2")
    ) %>% 
    dplyr::mutate(
        group = paste(genotype, Estradiol_uM, sep = "_"),
        group = factor(group, levels = c("WT_0", "WT_2",
                                         "XVE-OsRGF1_7-8-2_0", "XVE-OsRGF1_7-8-2_2"))
    ) 

# df1 <- df1 %>% 
#     dplyr::mutate(
#         is_outlier = Grubbs_test(nbt_total),
#         .by = "group"
#     ) %>% 
#     dplyr::filter(!is_outlier)

is_normality(dplyr::filter(df1, genotype == "WT"), nbt_total ~ Estradiol_uM)
is_normality(dplyr::filter(df1, genotype == "XVE-OsRGF1_7-8-2"), nbt_total ~ Estradiol_uM)

out <- oneway_test(df1, nbt_total ~ group)
out$tests
cld <- out$cld
cld <- cld %>% 
    dplyr::mutate(
        genotype = case_when(str_detect(GROUP, "WT") ~ "WT",
                             str_detect(GROUP, "XVE") ~ "XVE-OsRGF1_7-8-2",
                             TRUE ~ GROUP),
        genotype = factor(genotype, levels = c("WT", "XVE-OsRGF1_7-8-2")),
        Estradiol_uM = case_when(str_ends(GROUP, "0") ~ "0",
                              str_ends(GROUP, "2") ~ "2",
                              TRUE ~ GROUP)
    )
cld$YPOS_MAX <- cld$MAX
cld$YPOS_MIN <- cld$MIN - 7

ggplot(df1, aes(group, nbt_total, color = Estradiol_uM)) +
    theme_classic() +
    labs(
        y = "Total NBT intensity (10<sup>6</sup> AU)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    ggsignif::geom_signif(
        test = "t.test",
        comparisons = list(c("WT_0", "WT_2")),
        map_signif_level = pval2asterisk,
        textsize = 8,
        fontface = "bold",
        vjust = -0.3,
        color = "black",
        y_position = 40,
        tip_length = c(0.1, 0.05)
    ) +
    ggsignif::geom_signif(
        test = "wilcox.test",
        comparisons = list(c("XVE-OsRGF1_7-8-2_0", "XVE-OsRGF1_7-8-2_2")),
        map_signif_level = pval2asterisk,
        textsize = 8,
        fontface = "bold",
        vjust = -0.3,
        color = "black",
        y_position = 105,
        tip_length = c(0.9, 0.05)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N, color = Estradiol_uM),
        size = 7,
        show.legend = FALSE
    ) +
    scale_y_continuous(limits = c(0, 120), breaks = seq(0, 120, 20)) +
    scale_x_discrete(
        labels = c("", "WT", "", "OE7")
    ) +
    scale_color_manual(
        labels = c("Mock", "<i>&beta;</i>-Estradiol"),
        values = c("#56B4E9", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    hline_grob(1 - 0.4, 2 + 0.4, 0 - 5) +
    hline_grob(3 - 0.4, 4 + 0.4, 0 - 5) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 25,
            hjust = c(0, 1.7, 0, 1.2),
            margin = ggplot2::margin(t = 9),
            lineheight = 1.1
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
            margin = ggplot2::margin(r = 9)
        ),
        legend.position = "top",
        legend.position.inside = c(0.5, 0.95),
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 23, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0
    )

ggsave(
    filename = "nbt_total_OE07.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OE_28-3-10 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(
        genotype %in% c("WT", "XVE-OsRGF1_28-3-10"),
        Estradiol_uM %in% c("0", "10")
    ) %>% 
    dplyr::mutate(
        group = paste(genotype, Estradiol_uM, sep = "_"),
        group = factor(group, levels = c("WT_0", "WT_10",
                                         "XVE-OsRGF1_28-3-10_0", "XVE-OsRGF1_28-3-10_10"))
    ) 

# df1 <- df1 %>% 
#     dplyr::mutate(
#         is_outlier = Grubbs_test(nbt_total),
#         .by = "group"
#     ) %>% 
#     dplyr::filter(!is_outlier)

is_normality(dplyr::filter(df1, Estradiol_uM == 0), nbt_total ~ group)
is_normality(dplyr::filter(df1, Estradiol_uM == 10), nbt_total ~ group)

out <- oneway_test(df1, nbt_total ~ group)
out$tests
cld <- out$cld
cld
cld <- cld %>% 
    dplyr::mutate(
        genotype = case_when(str_detect(GROUP, "WT") ~ "WT",
                             str_detect(GROUP, "XVE") ~ "XVE-OsRGF1_28-3-10"),
        genotype = factor(genotype, levels = c("WT", "XVE-OsRGF1_28-3-10")),
        Estradiol_uM = case_when(str_ends(GROUP, "_0") ~ "0",
                                 str_ends(GROUP, "_10") ~ "10",
                                 TRUE ~ GROUP)
    )
cld$YPOS_MAX <- cld$MAX
cld$YPOS_MIN <- cld$MIN - 5

ggplot(df1, aes(group, nbt_total, color = Estradiol_uM)) +
    theme_classic() +
    labs(
        y = "Total NBT intensity (10<sup>6</sup> AU)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    ggsignif::geom_signif(
        test = "t.test",
        comparisons = list(
            c("WT_0", "WT_10"),
            c("XVE-OsRGF1_28-3-10_0", "XVE-OsRGF1_28-3-10_10")
        ),
        map_signif_level = pval2asterisk,
        textsize = 8,
        fontface = "bold",
        vjust = -0.3,
        color = "black",
        y_position = 32,
        tip_length = c(0.05, 0.05, 0.35, 0.05)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N, color = Estradiol_uM),
        size = 7,
        show.legend = FALSE
    ) +
    scale_y_continuous(limits = c(5, 40)) +
    scale_x_discrete(
        labels = c("", "WT", "", "OE28")
    ) +
    scale_color_manual(
        labels = c("Mock", "<i>&beta;</i>-Estradiol"),
        values = c("#56B4E9", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    hline_grob(1 - 0.4, 2 + 0.4, 5 - 1) +
    hline_grob(3 - 0.4, 4 + 0.4, 5 - 1) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 25,
            hjust = c(0, 1.7, 0, 1.2),
            margin = ggplot2::margin(t = 9),
            lineheight = 1.1
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
            margin = ggplot2::margin(r = 9)
        ),
        legend.position = "top",
        legend.position.inside = c(0.5, 0.95),
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 23, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0
    )

ggsave(
    filename = "nbt_total_OE28.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 17
)
