rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(plotly)
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")
source("../../../../rcode/utils.R")

theme_set(theme_bw_01)

rawdata <- readxl::read_excel("../root_length/OUT_NBT.xlsx")

df0 <- rawdata %>% 
    mutate(
        treatment = as.numeric(str_replace(img_name, ".*_(\\d{4})nM_.*", "\\1")),
        replicate = as.numeric(str_replace(img_name, ".*_R(\\d\\d)_.*", "\\1")),
        pCr = as.numeric(str_replace(img_name, ".*_pCr(\\d\\d)_.*", "\\1"))
    ) %>% 
    mutate(
        treatment = factor(treatment, levels = c(0, 100, 500, 1000)),
        replicate = factor(replicate, levels = 1:3)
    )

long_thin_roots <- df0 %>% 
    filter(
        !(treatment == 0 & replicate == 1 & pCr %in% c(6:8, 11)),
        !(treatment == 0 & replicate == 2 & pCr %in% c(5:9, 15, 16)),
        !(treatment == 0 & replicate == 3 & pCr %in% c(2:9, 11:14)),
        
        !(treatment == 1000 & replicate == 1 & pCr %in% c(5, 7:11)),
        !(treatment == 1000 & replicate == 2 & pCr %in% c(2:6, 9, 10)),
        !(treatment == 1000 & replicate == 3 & pCr %in% c(6:14)),
        
    ) %>% 
    filter(treatment %in% c(0, 1000))


stat_res <- oneway_test(long_thin_roots, nbt_area ~ treatment)
stat_res <- stat_res$result
long_thin_roots %>% 
    ggplot(aes(treatment, nbt_area)) +
    geom_boxplot() +
    geom_point()




