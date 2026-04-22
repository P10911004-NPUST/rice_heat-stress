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

geno_lvl <- c("WT", "osrgf1-7")

rawdata <- readxl::read_excel("../../OUT_NBT_20260211-161530.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(note == "ok") %>% 
    dplyr::mutate(
        nbt_total_intensity = nbt_total_intensity / 1e6,
        group = paste(genotype, OsRGF1_pM, sep = "_")
    )


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Peptide gradient test with osrgf1-7 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
grp_lvl <- c(
    "WT_0", "osrgf1-7_0", "osrgf1-7_1",
    "osrgf1-7_10", "osrgf1-7_100", "osrgf1-7_1000"
)

df1 <- df0 %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(nbt_total_intensity, sensitivity = 3),
        .by = "group"
    ) %>% 
    dplyr::filter(
        !is_outlier,
        genotype %in% geno_lvl
    ) %>% 
    dplyr::slice_max(nbt_total_intensity, n = 10, by = "group") %>%
    dplyr::select(-"is_outlier")

df1$genotype <- factor(df1$genotype, levels = geno_lvl)

out <- oneway_test(df1, nbt_total_intensity ~ group)
out$tests
cld <- out$cld
cld
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MIN = MIN - 7,
        YPOS_MAX = estimate_cld_pos(MAX) + 6,
        genotype = str_replace(GROUP, "(.*)_(.*)", "\\1")
    )

df1$group <- factor(df1$group, levels = grp_lvl)

ggplot(df1, aes(group, nbt_total_intensity, color = genotype)) +
    theme_classic() +
    labs(
        x = "OsRGF1 (pM)",
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
        size = 11,
        show.legend = FALSE
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N, color = genotype),
        size = 7,
        show.legend = FALSE
    ) +
    scale_x_discrete(
        labels = c("0", "0", "1", "10", "100", "1000")
    ) +
    scale_y_continuous(limits = c(0, 70), breaks = seq(0, 70, 10)) +
    scale_color_manual(
        values = c("#000000", "#E69F00", "#0072B2", "#CC79A7"),
        labels = c("WT", "<i>osrgf1-7</i>"),
        guide = guide_legend(
            order = 1
        )
    ) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 11)
        ),
        axis.title.y.left = element_markdown(
            lineheight = 1.2,
            margin = ggplot2::margin(r = 11)
        ),
        legend.position = "top",
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 25, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0.5
    )

ggsave(
    create.dir = TRUE,
    filename = "nbt-total_peptide-gradient.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 19
)

df1 %>% 
    dplyr::arrange(group, rep) %>% 
    write.csv("./figure/nbt-total_peptide-gradient.csv", row.names = FALSE)
