rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(plotly)
source("C:/jklai/github/statools/R/oneway_test.R")
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

# Takes only specific RGF1 concentration
df1 <- df0 %>% 
    filter(treatment == 100)

corr_df <- correlation::correlation(data = df1, select = "root_length", select2 = "nbt_area")
r_val <- round(corr_df$r, 3)
p_val <- num2asterisk(corr_df$p)

## Correlation plot ====
df1 %>% 
    ggplot(aes(root_length, nbt_area)) +
    labs(
        subtitle = sprintf("%s nM RGF1 (r = %s<sup>%s</sup>)", unique(df1$treatment), r_val, p_val), 
        x = "Root length (mm)", 
        # y = "Avg NBT intensity<br>(DN / pixels)"
        y = "NBT area (pixels)"
    ) +
    ggplot2::geom_point(aes(color = root_type), size = 2, alpha = 0.7) +
    ggplot2::geom_smooth(method = "lm", se = FALSE, color = "black", alpha = 0.1) +
    # scale_x_continuous(limits = c(15, 85)) +
    # scale_y_continuous(limits = c(180, 210)) +
    theme(legend.position = "none")

ggsave(
    filename = "corr_plot.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    height = 12,
    width = 17,
    dpi = 330
)

# Takes only long roots
df1 <- df0 %>% 
    filter(root_type == "long")

stats_res <- df1 %>% 
    oneway_test(nbt_intensity ~ group, use_art = TRUE)

stats_res <- stats_res$result


# subtitle_text <- sprintf("NBT area (pixels) &rarr; %s roots", unique(df1$root_type))
# subtitle_text <- sprintf("Avg NBT intensity (DN / pixels) &rarr; %s roots", unique(df1$root_type))
subtitle_text <- sprintf("Total NBT intensity (DN) &rarr; %s roots", unique(df1$root_type))

df1 %>% 
    ggplot(aes(group, nbt_intensity, color = group)) +
    labs(subtitle = subtitle_text, x = "RGF1 (nM)") +
    geom_point() +
    geom_boxplot(outliers = FALSE) +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(group, letter_y_pos - 15, label = letter),
        size = 8
    ) +
    theme(
        legend.position = "none",
        axis.title.y = element_blank()
    )

ggsave(
    filename = "boxplots.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    height = 12,
    width = 17,
    dpi = 330
)







