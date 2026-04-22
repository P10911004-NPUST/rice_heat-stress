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
grp_lvl <- c("WT_0", "WT_200", "osrgf1-7_0", "osrgf1-7_200", "osrgf1-8_0", "osrgf1-8_200")

rawdata <- readxl::read_excel("../../OUT_NBT_20260415-163953.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(note == "ok") %>%
    dplyr::mutate(
        val = nbt_total_intensity / 1e6,
        grp = paste(genotype, OsRGF1_pM, sep = "_"),
        genotype = factor(genotype, levels = geno_lvl),
        OsRGF1_pM = as.factor(OsRGF1_pM),
        grp = factor(grp, levels = grp_lvl)
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(val, sensitivity = 3),
        .by = "grp"
    ) %>% 
    # dplyr::filter(!is_outlier) %>%
    # dplyr::slice_max(val, n = 10, by = "grp") %>% 
    dplyr::select(-"is_outlier")

is_normality(df0, val ~ grp)

out <- oneway_test(df0, val ~ grp)
print(out$tests)
cld <- out$cld
print(cld)
cld <- cld %>% 
    dplyr::mutate(
        YMAX_POS = estimate_cld_pos(MAX),
        YMIN_POS = MIN - 5,
        genotype = str_replace(GROUP, "(.*)_(.*)", "\\1"),
        OsRGF1_pM = str_replace(GROUP, "(.*)_(.*)", "\\2")
    )


ggplot(df0, aes(grp, val, color = genotype)) +
    theme_classic() +
    labs(
        x = "OsRGF1 (200 pM)",
        y = "NBT total intensity (10<sup>6</sup>AU)"
    ) +
    geom_boxplot(
        alpha = 0.7,
        outliers = FALSE,
        outlier.shape = NA
    ) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YMIN_POS, label = N, color = genotype),
        size = 7,
        show.legend = FALSE
    ) +
    ggsignif::geom_signif(
        test = "t.test",
        # test.args = list(alternative = "greater"),
        comparisons = list(
            c("WT_200", "WT_0"),
            c("osrgf1-7_200", "osrgf1-7_0"),
            c("osrgf1-8_200", "osrgf1-8_0")
        ),
        map_signif_level = pval2asterisk,
        textsize = 7,
        fontface = "bold",
        color = "black",
        vjust = -0.5,
        y_position = 32,
        tip_length = c(0.05, 0.05, 0.05, 0.05, 0.45, 0.05)
    ) +
    # scale_x_discrete(
    #     labels = c("WT", "", "<i>osrgf1-7</i>", "", "<i>osrgf1-8</i>", "")
    # ) +
    scale_x_discrete(
        labels = rep(c("&minus;", "&plus;"), times = 3)
    ) +
    scale_y_continuous(limits = c(0, 40)) +
    scale_color_manual(
        values = c("#000000", "#E69F00", "#0072B2", "#CC79A7"),
        labels = c("WT", "<i>osrgf1-7</i>", "<i>osrgf1-8</i>")
    ) +
    hline_grob(1 - 0.3, 2 + 0.3, 0 - 1.5) +
    hline_grob(3 - 0.3, 4 + 0.3, 0 - 1.5) +
    hline_grob(5 - 0.3, 6 + 0.3, 0 - 1.5) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 9)
        ),
        axis.text.x.bottom = element_markdown(
            size = 30,
            margin = ggplot2::margin(t = 7),
            # lineheight = 1.1,
            # hjust = c(-0.6, 0, 0, 0, 0, 0)
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
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
    filename = "nbt-total_peptide-recover.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 19
)


df0 %>% 
    dplyr::arrange(grp) %>% 
    dplyr::select(genotype, OsRGF1_pM, nbt_total_intensity) %>% 
    write.csv("./figure/nbt-total_peptide-recover.csv", row.names = FALSE)

