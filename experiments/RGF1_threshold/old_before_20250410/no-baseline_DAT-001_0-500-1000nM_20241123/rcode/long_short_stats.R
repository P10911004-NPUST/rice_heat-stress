rm(list = ls())
set.seed(1)
if (!is.null(dev.list())) dev.off()

library(tidyverse)
library(plotly)
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/plotools/R/utils4ggplot.R", chdir = TRUE)
source("../../../../rcode/utils.R")

theme_set(theme_bw_01)

rawdata <- readxl::read_excel("../root_length/OUT_NBT.xlsx")

df0 <- rawdata %>% 
    mutate(
        treatment = as.numeric(str_replace(img_name, ".*_(\\d\\d\\d\\d)nM_.*", "\\1")),
        REP = as.numeric(str_replace(img_name, ".*_R(\\d\\d)_.*", "\\1")),
        pCr = as.numeric(str_replace(img_name, ".*_pCr(\\d\\d)_.*", "\\1"))
    ) %>% 
    mutate(
        root_type = def_long_short_root(root_length)
    ) %>% 
    filter(
        !str_detect(img_name, "cancel|tiny") &
        !( treatment == 0 & REP == 1 & pCr == 2 ) &
        !( treatment == 1000 & REP == 1 & pCr == 6 )
        
    )

df0$treatment <- factor(df0$treatment, levels = c(0, 500, 1000))
df0$dummy <- df0$nbt_area * df0$root_length

# Dummy ====
short_root_length <- df0 %>% 
    filter(root_type == "short") %>% 
    oneway_test(dummy ~ treatment)

short_root_length <- short_root_length$result

ggplotly(
    df0 %>% 
        filter(root_type == "short") %>% 
        ggplot(aes(treatment, dummy, color = treatment, labels = img_name)) +
        geom_boxplot() +
        geom_point() +
        geom_text(
            inherit.aes = FALSE,
            data = short_root_length,
            mapping = aes(group, letter_pos, label = letter),
            size = 8
        )
)

# NBT intensity ====
short_nbt_intensity <- df0 %>% 
    filter(root_type == "short") %>% 
    oneway_test(nbt_intensity ~ treatment)

short_nbt_intensity <- short_nbt_intensity$result

df0 %>% 
    filter(root_type == "short") %>% 
    ggplot(aes(treatment, nbt_intensity, color = treatment)) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = short_nbt_intensity,
        mapping = aes(group, letter_pos, label = letter),
        size = 8
    )


# NBT area ====
short_nbt_area <- df0 %>% 
    filter(root_type == "short") %>% 
    oneway_test(nbt_area ~ treatment)

short_nbt_area <- short_nbt_area$result

df0 %>% 
    filter(root_type == "short") %>% 
    ggplot(aes(treatment, nbt_area, color = treatment)) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = short_nbt_area,
        mapping = aes(group, letter_pos, label = letter),
        size = 8
    )


# Average NBT area ====
short_avg_nbt <- df0 %>% 
    filter(root_type == "short") %>% 
    oneway_test(trim_avg_nbt ~ treatment)

short_avg_nbt <- short_avg_nbt$result

df0 %>% 
    filter(root_type == "short") %>% 
    ggplot(aes(treatment, trim_avg_nbt, color = treatment)) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = short_avg_nbt,
        mapping = aes(group, letter_pos, label = letter),
        size = 8
    )

