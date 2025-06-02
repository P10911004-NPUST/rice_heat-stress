suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(ggtext)) install.packages("ggtext")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install("P10911004-NPUST/statool")
})

rawdata <- readxl::read_excel("../OUT_Magnif_32X.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel")
    ) %>% 
    dplyr::mutate(
        treatment = str_replace(img_name, ".*_(.*)pM_.*", "\\1"),
        root_type = str_extract(img_name, "Se|Cr")
    )

df0$treatment <- factor(df0$treatment, levels = c("0", "10", "100", "1000", "10000"))
df0$root_type <- factor(df0$root_type, levels = c("Se", "Cr"))


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Seminal root
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df_seminal <- df0 %>% 
    dplyr::filter(root_type == "Se")

out <- oneway_test(df_seminal, root_length ~ treatment)
out
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)

ggplot(df_seminal, aes(treatment, root_length, color = treatment)) +
    theme_bw() +
    labs(
        subtitle = "Gel system, DAI10, <i>osrgf1-7</i>, seminal root",
        x = "OsRGF1 (pM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(alpha = 0.7) +
    geom_point(alpha = 0.7, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD, color = GROUP),
        size = 8
    ) +
    scale_color_grey(start = .5, end = 0) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        plot.subtitle = element_markdown(size = 18),
        legend.position = "none"
    )

ggsave(
    filename = "root_length_Se.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Crown root
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df_crown <- df0 %>% 
    dplyr::filter(root_type == "Cr")

out <- oneway_test(df_crown, root_length ~ treatment)
out
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)

ggplot(df_crown, aes(treatment, root_length, color = treatment)) +
    theme_bw() +
    labs(
        subtitle = "Gel system, DAI10, <i>osrgf1-7</i>, crown root",
        x = "OsRGF1 (pM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(alpha = 0.7) +
    geom_point(alpha = 0.7, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD, color = GROUP),
        size = 8
    ) +
    scale_color_grey(start = .5, end = 0) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        plot.subtitle = element_markdown(size = 18),
        legend.position = "none"
    )

ggsave(
    filename = "root_length_Cr.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)

