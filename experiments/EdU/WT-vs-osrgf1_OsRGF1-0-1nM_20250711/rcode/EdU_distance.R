suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(ggtext)) install.packages("ggtext")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool")
})

rawdata <- readxl::read_excel("../total_intensity.xlsx")

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Mock ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df0 <- rawdata %>% 
    filter(
        str_detect(img_name, "cancel", negate = TRUE),
        root_type == "Se",
        RGF1 == 0
    ) %>% 
    mutate(
        total_intensity = total_intensity / 1e6,
        distance = distance_from_root_tip_pixels * `resolution (um/pixel)`,
        genotype = factor(genotype, levels = c("WT", "osrgf1-7", "osrgf1-8"))
    )

out <- oneway_test(df0, distance ~ genotype)
out$tests
out$cld
cld <- out$cld
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX) + 50
cld$YPOS_MIN <- cld$MIN - 50

ggplot(df0, aes(genotype, distance)) +
    theme_bw() +
    labs(
        y = "Distance from<br>root tip (<i>&micro;</i>m)"
    ) +
    geom_boxplot(outliers = FALSE, fill = NA) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1),
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MAX, label = CLD),
        size = 9
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N),
        size = 7
    ) +
    scale_x_discrete(labels = c("WT", "<i>osrgf1-7</i>", "<i>osrgf1-8</i>")) +
    scale_y_continuous(limits = c(270, 900), breaks = seq(300, 900, 200)) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 28),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(size = 27, color = "black"),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9))
    )

ggsave(
    filename = "EdU_distance.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 13,
    width = 17
)

