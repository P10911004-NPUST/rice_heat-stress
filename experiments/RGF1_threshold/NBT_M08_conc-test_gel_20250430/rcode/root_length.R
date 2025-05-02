suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool", upgrade = FALSE, quiet = TRUE)
    
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    source("C:/jklai/github/plotools/R/color_palette.R")
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_Magnif_10X.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel")
    ) %>% 
    dplyr::mutate(
        treatment = str_replace(img_name, ".*_(\\d)nM_.*", "\\1"),
        nbt_area = nbt_area / 1000
    )

df0$treatment <- factor(df0$treatment, levels = c("0", "2", "4", "6", "8"))

out <- oneway_test(df0, root_length ~ treatment)
out$tests
res <- out$cld
res$CLD_POS <- estimate_cld_pos(res$MAX)

ggplot(df0, aes(treatment, root_length, colour = treatment)) +
    labs(
        x = "OsRGF1 (nM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = res,
        mapping = aes(GROUP, CLD_POS, label = CLD),
        size = 8
    ) +
    theme(
        legend.position = "none",
        axis.text.x.bottom = element_markdown(size = 24)
    )

ggsave2(filename = "root_length.jpg")



