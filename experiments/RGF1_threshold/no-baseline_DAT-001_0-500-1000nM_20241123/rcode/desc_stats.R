rm(list = ls())

library(tidyverse)
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/plotools/R/utils4ggplot.R", chdir = TRUE)

rawdata <- readxl::read_excel("../root_length/OUT_NBT.xlsx")

df0 <- rawdata %>% 
    mutate(
        treatment = as.numeric(str_replace(img_name, ".*_(\\d\\d\\d\\d)nM_.*", "\\1")),
        REP = as.numeric(str_replace(img_name, ".*_R(\\d\\d)_.*", "\\1")),
        pCr = as.numeric(str_replace(img_name, ".*_pCr(\\d\\d)_.*", "\\1"))
    ) 

df0 <- df0 %>% 
    filter(!str_detect(img_name, "cancel")) %>% 
    filter(
        ( treatment == 0 & REP == 1 & pCr %in% c(2, 3, 4) ) |
        ( treatment == 0 & REP == 2 & pCr %in% c(4) ) |
        ( treatment == 0 & REP == 3 & pCr %in% c(5, 6, 8) ) |
            
        # ( treatment == 500 & REP == 1 & pCr %in% c(1, 2, 3, 4) ) |
        ( treatment == 500 & REP == 2 & pCr %in% c(7) ) |
        ( treatment == 500 & REP == 3 & pCr %in% c(2, 3, 4) ) |
            
        # ( treatment == 1000 & REP == 1 & pCr %in% c(3, 4, 5, 6) ) |
        ( treatment == 1000 & REP == 2 & pCr %in% c(2, 3, 4, 5) ) |
        ( treatment == 1000 & REP == 3 & pCr %in% c(6, 7, 8) )
    )

df0$treatment <- factor(df0$treatment, levels = c(0, 500, 1000))



stats_res <- df0 %>% oneway_test(nbt_area ~ treatment)
res <- stats_res$result
res

df0 %>% 
    ggplot(aes(treatment, nbt_area, color = treatment)) + 
    geom_boxplot(alpha = 0.1) +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = res,
        mapping = aes(group, letter_pos, label = letter),
        size = 8
    )
