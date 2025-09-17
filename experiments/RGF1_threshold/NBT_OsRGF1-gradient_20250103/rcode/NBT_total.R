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
        RGF1 != 100
    ) %>% 
    dplyr::mutate(
        nbt_total = nbt_total / 1e6,
        RGF1 = factor(RGF1, levels = c(0, 0.1, 1, 10, 100)),
        is_outlier = Grubbs_test(nbt_total),
        .by = "RGF1"
    ) %>% 
    dplyr::filter(!is_outlier)

out <- oneway_test(df0, nbt_total ~ RGF1)
out$tests

cld <- out$cld
cld
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX) + 2
cld$YPOS_MIN <- cld$MIN - 2

color_palette <- colorRampPalette(c("grey60", "grey0"))(length(unique(df0$RGF1)))

ggplot(df0, aes(RGF1, nbt_total, color = RGF1)) +
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
        mapping = aes(GROUP, YPOS_MAX, color = GROUP, label = CLD),
        size = 9,
        fontface = "bold"
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, color = GROUP, label = N),
        size = 7
    ) +
    scale_y_continuous(limits = c(-1, 21), breaks = seq(0, 20, 5)) +
    scale_color_manual(values = colorRampPalette(c("grey70", "grey0"))(4)) +
    theme(
        text = element_text(size = 28, family = "sans", face = "bold"),
        legend.position = "none",
        axis.title.x.bottom = element_markdown(margin = ggplot2::margin(t = 9)),
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
