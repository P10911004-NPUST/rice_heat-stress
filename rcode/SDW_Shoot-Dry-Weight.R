suppressMessages({
    rm(list = ls()); gc()
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    library(tidyverse)
    
    source("https://github.com/P10911004-NPUST/plotools/blob/main/R/utils4ggplot.R?raw=true")
    
    theme_set(theme_bw_02)
})


rawdata <- readxl::read_excel("../img/shoot/DAT5_34-vs-38_20240702/DAT5_34-vs-38_20240702.xlsx")

df0 <- rawdata %>% 
    mutate(
        temperature = as.factor(temperature)
    )

df0 %>% 
    ggplot(aes(temperature, SDW, color = temperature)) +
    labs(
        x = "Temperature (&deg;C)",
        y = "Shoot dry weight (mg)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_signif(
        textsize = 10,
        test = "wilcox.test",
        comparisons = list(c("34", "38")),
        y_position = 250
    ) +
    scale_y_continuous(limits = c(130, 270), breaks = seq(130, 270, 20)) +
    scale_color_manual(values = c("skyblue", "red4")) +
    theme(
        legend.position = "none"
    )

ggsave(
    filename = "SDW.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)
