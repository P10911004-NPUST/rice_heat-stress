rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(plotly)
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")

theme_set(theme_bw_01)

def_long_short_root <- function(data, x){
    clust <- kmeans(data[x], centers = 2)
    
    v0 <- as.character(clust$cluster)
    
    v0[v0 == names(which.max(clust$centers[, 1]))] <- "long"
    v0[v0 == names(which.min(clust$centers[, 1]))] <- "short"
    
    return(v0)
}

file_list <- list.files("../", pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE)

rawdata <- file_list %>% 
    map(readxl::read_excel) %>% 
    list_rbind()

df0 <- rawdata %>% 
    mutate(
        DAT = as.numeric(str_replace(img_name, "DAT-(\\d\\d\\d)_.*", "\\1")),
        treatment = as.numeric(str_replace(img_name, ".*(\\d\\d\\d)nM_.*", "\\1"))
    ) %>% 
    mutate(
        DAT = as.factor(DAT),
        treatment = factor(treatment, levels = c("0", "1", "5", "10", "100")),
        group = treatment
    ) %>% 
    group_by(DAT, group) %>% 
    mutate(
        root_type = def_long_short_root(root_length)
    ) %>% 
    ungroup() %>%
    group_by(DAT, group, root_type) %>% 
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_intensity_trim_perc, method = "iqr")
    ) %>% 
    ungroup() %>% 
    filter(
        !is_cancel,
        !is_outlier
    )



df0 %>% 
    filter(
        DAT == 3
    ) %>% 
    ggplot(aes(root_length, fill = treatment)) +
    geom_density(alpha = 0.3)

























