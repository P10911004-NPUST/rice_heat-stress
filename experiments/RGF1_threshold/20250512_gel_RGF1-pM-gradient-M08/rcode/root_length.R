suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    if (!require("tidyverse")) install.packages("tidyverse")
    if (!require("ggtext")) install.packages("ggtext")
    if (!require("devtools")) install.packages("devtools")
    if (!require("statool")) devtools::install_github("P10911004-NPUST/statool", upgrade = "always")
})

rawdata <- readxl::read_excel("../OUT_Magnif_32X.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(!str_detect(img_name, "cancel")) %>%
    dplyr::mutate(
        DAI = str_replace(img_name, "DAI0(\\d)_.*", "\\1"),
        treatment = str_replace(img_name, ".*_(\\d{1,4})pM_.*", "\\1"),
        nbt_area = nbt_area / 1e5,
        nbt_intensity = nbt_intensity / 1e6
    )

df0$treatment <- factor(df0$treatment, levels = c("0", "1", "10", "100", "1000"))

df1 <- df0 %>% 
    dplyr::filter(DAI == "8") %>% 
    dplyr::group_by(treatment) %>% 
    dplyr::slice_max(root_length, n = 100) %>% 
    dplyr::ungroup()

out <- oneway_test(df1, root_length ~ treatment)
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)
cld

ggplot(df1, aes(treatment, root_length, color = treatment)) +
    theme_bw() +
    labs(
        x = "OsRGF1 (pM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot() +
    geom_point(position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD),
        size = 8
    ) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 20),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(),
        legend.position = "none",
        legend.position.inside = c(0.5, 0.92),
        legend.direction = "horizontal",
        legend.background = element_blank()
    )

ggsave(
    filename = "root_length.jpg", 
    device = "jpeg",
    units = "cm",
    dpi = 660,
    width = 17,
    height = 11
)
