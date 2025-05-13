suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool", upgrade = FALSE, quiet = TRUE)
    
    # source("https://github.com/P10911004-NPUST/statool/blob/main/R/outliers.R?raw=true")
    # source("C:/jklai/github/statool/R/outliers.R")
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    source("C:/jklai/github/plotools/R/color_palette.R")
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel")
    ) %>% 
    dplyr::mutate(
        genotype = gsub(pattern = paste(rep("(.*)", 7), collapse = "_"), replacement = "\\2", x = img_name),
        nbt_area = nbt_area / 1000
    ) %>% 
    dplyr::slice_max(root_length, n = 5, by = "genotype") %>% 
    dplyr::filter(genotype != "M15")

df0$genotype <- factor(df0$genotype, levels = c("WT", "M07", "M08"))

out <- oneway_test(df0, root_length ~ genotype)
out$tests
res <- out$cld
res$CLD_POS <- estimate_cld_pos(res$MAX)

ggplot(df0, aes(genotype, root_length, colour = genotype)) +
    labs(
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
    scale_x_discrete(
        labels = c("WT", "<i>osrgf1-7</i>", "<i>osrgf1-8</i>")
    ) +
    scale_y_continuous(limits = c(25, 55), breaks = seq(25, 55, 5)) +
    scale_color_manual(values = c("#010111", "#FF8C00", "#A034F0", "#159090")) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(size = 24)
    )

ggsave2(filename = "root_length.jpg")



