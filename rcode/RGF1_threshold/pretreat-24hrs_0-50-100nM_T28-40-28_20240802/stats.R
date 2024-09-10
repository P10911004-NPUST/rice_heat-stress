suppressMessages({
    rm(list = ls()); gc()
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    library(tidyverse)
    library(factoextra)
    library(ARTool)
    
    source("https://github.com/P10911004-NPUST/statools/blob/main/R/detect_outliers.R?raw=true")
    source("https://github.com/P10911004-NPUST/statools/blob/main/R/oneway_test.R?raw=true")
    source("https://github.com/P10911004-NPUST/plotools/blob/main/R/utils4ggplot.R?raw=true")
    
    theme_set(theme_bw_01)
})

gradient_colors <- c("#dabfff", "#907ad6", "#4f518c", "#2c2a4a")

# Load data ====
file_list <- list.files(
    path = "../../../img/root_length/RGF1_threshold/pretreat-24hrs_0-50-100nM_T28-40-28_20240802", 
    pattern = "\\.xlsx$", 
    full.names = TRUE, 
    recursive = TRUE
)

rawdata <- file_list %>% 
    map(readxl::read_excel) %>% 
    list_rbind()

# Tidy-up ====
df0 <- rawdata %>%  
    mutate(
        DAT = str_replace(img_name, "^DAT(\\d(\\d)?)_.*", "\\1"),
        sample_id = str_replace(img_name, ".*_R(\\d(\\d)?)_.*", "\\1"),
        treatment = str_replace(img_name, ".*_((\\d)?(\\d)?(\\d))nM_.*", "\\1"),
        group = factor(paste(DAT, treatment, sep = "_"))
    ) %>% 
    mutate(
        DAT = factor(DAT, levels = c(0, 1, 3, 6)),
        treatment = factor(treatment, levels = c(0, 50, 100)),
        group = factor(group, levels = c("0_0", "0_50", "0_100", "1_0", "1_50", "1_100"))
    ) %>% 
    group_by(DAT, treatment) %>% 
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier_nbt = detect_outliers(nbt_intensity_per_area, method = "iqr"),
        is_outlier_area = detect_outliers(nbt_area, method = "iqr"),
        is_outlier_length = detect_outliers(root_length, method = "iqr")
    ) %>% 
    ungroup() %>% 
    filter(!is_outlier_nbt, !is_outlier_area, !is_outlier_length, !is_cancel)

# Clustering ====
clust <- factoextra::fviz_nbclust(
    x = df0[c("root_length", "nbt_intensity_per_area")],
    FUNcluster = kmeans,
    method = "silhouette",
    k.max = 10
)

km <- kmeans(df0[c("root_length", "nbt_intensity_per_area")], 2)
clust <- km$cluster
# clust[clust == which.max(km$centers)] <- "long"
# clust[clust == which.min(km$centers)] <- "short"

df0$cluster <- factor(clust)

df0 %>% 
    ggplot(aes(root_length, nbt_intensity_per_area, color = cluster)) +
    facet_wrap( ~ group) +
    geom_point()


stats_res <- df0 %>% 
    filter(cluster == 2) %>% 
    oneway_test(nbt_intensity_per_area ~ group) %>% 
    .$results

plotly::ggplotly(
    df0 %>% 
        filter(cluster == 2) %>% 
        ggplot(aes(group, nbt_intensity_per_area, color = treatment)) +
        geom_point() +
        geom_boxplot() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_y_pos - 20, label = letter),
            size = 8
        )
        # geom_signif(
        #     test = "t.test",
        #     comparisons = list(
        #         c("0_0", "1_0"),
        #         c("0_50", "1_50"),
        #         c("0_100", "1_100")
        #     )
        # ) +
        # scale_y_continuous(limits = c(160, 220))
)




# DAT0: Control (Mock + 38&deg;C) ====
## Average NBT intensity ====
stats_res <- df0 %>% 
    filter(DAT == 0) %>% 
    oneway_test(nbt_intensity_per_area ~ group) %>% 
    .$results

df0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 20, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank(),
        plot.subtitle = element_markdown()
    )


# DAT5: Treatment (RGF1 + 38&deg;C) ====
## Average NBT intensity ====
stats_res <- df0 %>% 
    filter(DAT == 5) %>% 
    oneway_test(nbt_intensity_per_area ~ group) %>% 
    .$results

df0 %>% 
    filter(DAT == 5) %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "DAT5 (Treatment &rarr; RGF1 + 38&deg;C)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 20, label = letter),
        size = 8
    ) +
    # scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank(),
        plot.subtitle = element_markdown()
    )



# DAT10: Treatment (RGF1 + 38&deg;C) ====
## Average NBT intensity ====
stats_res <- df0 %>% 
    filter(DAT == 10) %>% 
    oneway_test(nbt_intensity_per_area ~ group) %>% 
    .$results

df0 %>% 
    filter(DAT == 10) %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "DAT10 (Treatment &rarr; RGF1 + 30&deg;C)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 20, label = letter),
        size = 8
    ) +
    # scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
    theme(
        legend.position = "none",
        axis.title.x.bottom = element_blank(),
        plot.subtitle = element_markdown()
    )










#Correlation (root_length vs average_nbt) ====
corr <- df0 %>% 
    filter(DAT == 0) %>% 
    group_by(group) %>% 
    correlation::correlation(
        select = "root_length",
        select2 = "nbt_intensity_per_area"
    ) %>%
    as_tibble() %>% 
    ungroup()

df0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(root_length, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
        x = "Root length (mm)",
        y = "Average NBT intensity<br>(DN / pixels)"
    ) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    theme(
        legend.position = "right",
        legend.direction = "vertical",
        legend.position.inside = c(0.5, 0.9),
        legend.title = element_blank(),
        plot.subtitle = element_markdown()
    )




