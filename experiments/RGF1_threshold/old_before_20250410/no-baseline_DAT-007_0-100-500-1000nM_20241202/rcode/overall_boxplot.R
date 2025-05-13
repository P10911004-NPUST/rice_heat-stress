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
        replicate = as.numeric(str_replace(img_name, ".*_R(\\d\\d)_.*", "\\1"))
    ) %>% 
    mutate(
        treatment = factor(treatment, levels = c(0, 100, 500, 1000)),
        replicate = factor(replicate, levels = 1:3),
        dummy = root_length * nbt_area
    ) %>% 
    mutate(
        root_type = def_long_short_root(root_length)
    )


df0 %>% 
    ggplot(aes(root_length, nbt_area, color = treatment)) +
    geom_point() +
    geom_smooth(se = FALSE, method = "glm") +
    scale_color_manual(values = c("grey", "#907ad6", "#4f518c", "#2c2a4a"))


for (i in c("long", "short")){
    df1 <- filter(df0, root_type == i)
    
    stats_res <- oneway_test(df1, nbt_area ~ treatment)
    stats_res$perform_test
    stats_res <- stats_res$result
    
    p1 <- df1 %>% 
        ggplot(aes(treatment, nbt_area)) +
        labs(
            subtitle = i
        ) +
        geom_boxplot() +
        geom_point() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_pos, label = letter),
            size = 8
        )
    show(p1)
}















# clust_df <- df0 %>% select(root_length, nbt_area)
# factoextra::fviz_nbclust(clust_df, FUNcluster = kmeans, method = "silhouette")
# 
# clust <- kmeans(clust_df, centers = 2)
# 
# df0$root_type <- clust$cluster
# centers <- as.data.frame(clust$centers)



















