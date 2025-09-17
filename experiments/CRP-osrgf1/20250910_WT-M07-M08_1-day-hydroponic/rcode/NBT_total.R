suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(ggtext)) install.packages("ggtext")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool")
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        str_detect(img_name, "cancel", negate = TRUE),
        DAI != 6
    ) %>% 
    dplyr::mutate(
        nbt_total = nbt_total / 1e6,
        genotype = factor(genotype, levels = c("WT", "osrgf1-7", "osrgf1-8")),
        is_outlier = Grubbs_test(nbt_total),
        .by = "genotype"
    ) %>% 
    dplyr::filter(!is_outlier)

out <- oneway_test(df0, nbt_total ~ genotype)
out$tests

cld <- out$cld
cld
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX) + 2
cld$YPOS_MIN <- cld$MIN - 3

color_palette <- colorRampPalette(c("grey60", "grey0"))(length(unique(df0$RGF1)))

ggplot(df0, aes(genotype, nbt_total)) +
    theme_bw() +
    labs(
        x = "OsRGF1 (nM)",
        y = "Total NBT intensity<br>(10<sup>6</sup> AU)"
    ) +
    geom_boxplot(
        fill = "transparent",
        outliers = FALSE
    ) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 512)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MAX, label = CLD),
        size = 9,
        fontface = "bold"
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N),
        size = 7
    ) +
    scale_y_continuous(limits = c(5, 35), breaks = seq(5, 35, 10)) +
    scale_x_discrete(labels = c("WT", "<i>osrgf1-7</i>", "<i>osrgf1-8</i>")) +
    theme(
        text = element_text(size = 28, family = "sans", face = "bold"),
        legend.position = "none",
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(face = "bold"),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9))
    )

ggsave(
    filename = "nbt_total.jpg",
    path = "./figures/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 12,
    width = 17
)
