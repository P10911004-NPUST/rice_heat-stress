suppressMessages({
    rm(list = ls()); gc()
    if (!is.null(dev.list())) dev.off()
    
    library(tidyverse)
    library(ggsignif)
    source("https://github.com/P10911004-NPUST/statools/blob/main/R/oneway_test.R?raw=true")
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    source("C:/jklai/github/plotools/R/color_palette.R")
    
    theme_set(theme_bw_01)
})


rawdata <- readxl::read_excel("../img/NBT/OUT_DAT0_34-vs-38_20240627.xlsx")

df0 <- rawdata %>% 
    filter(!str_detect(img_name, "cancel")) %>% 
    mutate(
        TEMP = str_replace(img_name, ".*T(\\d\\d).*", "\\1")
    )

normality <- df0 %>% is_normal(nbt_intensity_per_area ~ TEMP)

ggplot(df0, aes(TEMP, nbt_intensity_per_area, color = TEMP)) +
    labs(x = "Temperature (&deg;C)", y = "Average NBT intensity") +
    geom_boxplot() +
    geom_point() +
    geom_signif(
        comparisons = list(c("34", "38")),
        test = ifelse(normality, "t.test", "wilcox.test"),
        map_signif_level = num2asterisk,
        y_position = 210,
        tip_length = 0
    ) +
    scale_y_continuous(limits = c(180, 220), n.breaks = 5) +
    scale_color_manual(values = heatmap_gradient(n_breaks = 2)) +
    theme(
        legend.title = element_blank(),
        legend.direction = "vertical",
        legend.position = "inside",
        legend.position.inside = c(0.9, 0.88)
    )


df0 %>% 
    filter(TEMP == "38") %>% 
    ggplot(aes(root_length, nbt_intensity_per_area)) +
    geom_point() +
    geom_smooth(method = "lm")


T34 <- df0 %>% 
    filter(TEMP == "34")

corr_T34 <- Hmisc::rcorr(T34$root_length, T34$nbt_intensity_per_area)


T38 <- df0 %>% 
    filter(TEMP == "38")

corr_T38 <- Hmisc::rcorr(T38$root_length, T38$nbt_intensity_per_area)


corr_T34$r
corr_T34$P
corr_T38$r
corr_T38$P







