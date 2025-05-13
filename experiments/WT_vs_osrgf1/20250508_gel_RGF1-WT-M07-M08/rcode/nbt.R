suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require("tidyverse")) install.packages("tidyverse")
    if (!require("ggtext")) install.packages("ggtext")
    if (!require("devtools")) install.packages("devtools")
    if (!require("statool")) devtools::install_github("P10911004-NPUST/statool", upgrade = "always")
    
    hline_grob <- function(xmin, xmax, y, linewidth = 1.5){
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
    }
})

rawdata <- readxl::read_excel("../OUT_Magnif_32X.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel"),
        # root_length < 70
    ) %>%
    dplyr::mutate(
        genotype = str_replace(img_name, "DAI07_(.*)_\\dnM.*", "\\1"),
        treatment = str_replace(img_name, ".*_(\\d)nM_.*", "\\1"),
        replicate = str_replace(img_name, ".*_R0(\\d)_.*", "\\1"),
        nbt_area = nbt_area / 1000,
        nbt_intensity = nbt_intensity / 1e6
    )

df0$genotype <- factor(df0$genotype, levels = c("WT", "M07", "M08"))
df0$treatment <- factor(df0$treatment, levels = c("0", "1"))
df0$group <- with(df0, paste(genotype, treatment, sep = "_"))

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Replicate 1 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    # dplyr::group_by(group, replicate) %>% 
    # dplyr::mutate(is_outlier = Grubbs_test(nbt_area)) %>% 
    # dplyr::ungroup() %>% 
    dplyr::filter(
        root_length < 70,
        replicate == "1"
    )

out <- oneway_test(df1, nbt_area ~ group)
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)

ggplot(df1, aes(group, nbt_area, color = treatment)) +
    theme_classic() +
    labs(
        # subtitle = "Replicate 1",
        y = "NBT area (10<sup>3</sup> pixels)",
        color = "RGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point(position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(30, 150), breaks = seq(30, 150, 30)) +
    scale_x_discrete(
        labels = c(
            "<i>osrgf1-7</i>", "",
            "<i>osrgf1-8</i>", "",
            "WT", ""
        )
    ) +
    hline_grob(1 - 0.3, 2 + 0.3, 24) +
    hline_grob(3 - 0.3, 4 + 0.3, 24) +
    hline_grob(5 - 0.3, 6 + 0.3, 24) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 20),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(hjust = c(-0.1, 0, -0.1, 0, -1, 0)),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(),
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
        legend.background = element_blank()
    )

ggsave(
    filename = "nbt_area.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    width = 17,
    height = 11
)

