rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)
# options(contrasts = c("contr.sum", "contr.poly"))

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

geno_lvl <- c("WT", "osrgf1-7", "osrgf1-8", "osrgf1-15")

rawdata <- readxl::read_excel("../../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        str_detect(img_name, "cancel", negate = TRUE),
        genotype != "osrgf1-15"
    ) %>%
    dplyr::mutate(
        nbt_total = nbt_total / 1e6,
        group = paste(genotype, OsRGF1_pM, sep = "_")
    )

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Genotype comparison under mock ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>%
    dplyr::filter(OsRGF1_pM == 0)

out <- oneway_test(df1, root_length ~ genotype)
out$tests
cld <- out$cld
cld
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MIN = MIN - 5,
        YPOS_MAX = estimate_cld_pos(MAX) + 2.5
    )

df1[["genotype"]] <- factor(df1[["genotype"]], levels = geno_lvl)
df1[["genotype"]] <- droplevels(df1[["genotype"]])

ggplot(df1, aes(genotype, root_length, color = genotype)) +
    theme_classic() +
    labs(
        y = "Primary root length (mm)"
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
        position = position_jitter(width = 0.15, seed = 123)
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
    scale_y_continuous(limits = c(20, 100), breaks = seq(20, 100, 20)) +
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
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
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
    filename = "root_length_geno-compare.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 19
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Peptide gradient test with osrgf1-7 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
grp_lvl <- c(
    "WT_0", "osrgf1-7_0", "osrgf1-7_1",
    "osrgf1-7_10", "osrgf1-7_100", "osrgf1-7_1000"
)

df1 <- df0 %>% 
    dplyr::filter(
        genotype %in% c("WT", "osrgf1-7")
    )

df1$genotype <- factor(df1$genotype, levels = c("WT", "osrgf1-7"))

out <- oneway_test(df1, root_length ~ group)
out$tests
cld <- out$cld
cld
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MIN = MIN - 9,
        YPOS_MAX = estimate_cld_pos(MAX) + 6,
        genotype = str_replace(GROUP, "(.*)_(.*)", "\\1")
    )

df1$group <- factor(df1$group, levels = grp_lvl)

ggplot(df1, aes(group, root_length, color = genotype)) +
    theme_classic() +
    labs(
        x = "OsRGF1 (pM)",
        y = "Primary root length (mm)"
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
        mapping = aes(GROUP, YPOS_MIN, label = N, color = genotype),
        size = 7
    ) +
    scale_x_discrete(
        labels = c("0", "0", "1", "10", "100", "1000")
    ) +
    scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
    scale_color_manual(
        values = c("#000000", "#E69F00", "#0072B2", "#CC79A7"),
        labels = c("WT", "<i>osrgf1-7</i>"),
        guide = guide_legend(
            order = 1
        )
    ) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 28),
        axis.title.x.bottom = element_markdown(
            size = 27,
            margin = ggplot2::margin(t = 11)
        ),
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
            # hjust = 1,
            margin = ggplot2::margin(r = 11)
        ),
        legend.position = "top",
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
    filename = "root_length_peptide-gradient.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 19
)

df1 %>% 
    dplyr::select() %>% 
    write.csv("root-length_peptide-gradient.csv", row.names = FALSE)
