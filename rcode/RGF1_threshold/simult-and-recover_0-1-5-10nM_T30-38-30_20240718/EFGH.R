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
file_list <- list.files("../../../img/root_length/RGF1_threshold/", pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE)

rawdata <- file_list %>% 
    map(readxl::read_excel) %>% 
    list_rbind()

# Tidy-up ====
df0 <- rawdata %>%  
    mutate(
        DAT = str_replace(img_name, "^DAT(\\d(\\d)?)_.*", "\\1"),
        sample_id = as.numeric(str_replace(img_name, ".*_R(\\d(\\d)?)_.*", "\\1")),
        group = case_when(
            sample_id %in% c(1, 2, 3) ~ "A",
            sample_id %in% c(4, 5, 6) ~ "B",
            sample_id %in% c(7, 8, 9) ~ "C",
            sample_id %in% c(10, 11, 12) ~ "D",
            sample_id %in% c(13, 14, 15) ~ "E",
            sample_id %in% c(16, 17, 18) ~ "F",
            sample_id %in% c(19, 20, 21) ~ "G",
            sample_id %in% c(22, 23, 24) ~ "H",
            TRUE ~ NA_character_
        ),
        RGF1 = case_when(
            group %in% c("A", "E") ~ "0", 
            group %in% c("B", "F") ~ "1", 
            group %in% c("C", "G") ~ "5", 
            group %in% c("D", "H") ~ "10", 
            TRUE ~ NA_character_
        )
    ) %>% 
    group_by(DAT, group) %>% 
    mutate(
        is_outlier = detect_outliers(
            nbt_intensity_per_area, 
            method = "iqr"
        ),
        is_cancel = str_detect(img_name, "cancel")
    ) %>% 
    ungroup() %>% 
    filter(
        group %in% c("E", "F", "G", "H"),
        !is_cancel,
        !is_outlier
    ) %>% 
    mutate(
        group = as.factor(group),
        DAT = as.factor(DAT)
    )

# DAT 0 ====
stats_res <- df0 %>% 
    filter(DAT == 0) %>% 
    oneway_test(., nbt_intensity_per_area ~ group) %>% 
    .$results

df0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
        x = "RGF1 treatment (nM)",
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
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    scale_y_continuous(limits = c(170, 210)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )

ggsave(filename = "DAT0_EFGH.jpeg")

# DAT 5 ====
df_DAT <- df0 %>% 
    filter(DAT == 5)

## Clustering ====
clust <- factoextra::fviz_nbclust(
    x = df_DAT[c("root_length")],
    FUNcluster = kmeans,
    method = "silhouette",
    k.max = 5
)
clust <- kmeans(df_DAT[c("root_length")], 2)

df_DAT$cluster <- as.factor(clust$cluster)

df_DAT %>% 
    ggplot(aes(root_length, nbt_intensity_per_area, color = cluster)) +
    labs(
        subtitle = "DAT5 (Treatment &rarr; RGF1 + 38&deg;C)",
        x = "Root length",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    # scale_x_continuous(limits = c(10, 65)) +
    # scale_y_continuous(limits = c(150, 205)) +
    theme(
        legend.position = "top",
        legend.margin = margin(5, 0, 0, 0),
        plot.subtitle = element_markdown()
    )

ggsave(filename = "DAT5_EFGH_clusters.jpeg")

### Cluster 1 ====
clust_df <- df_DAT %>% 
    filter(cluster == 1)

stats_res <- clust_df %>% 
    oneway_test(., nbt_intensity_per_area ~ group) %>% 
    .$results

clust_df %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "Cluster 1",
        x = "RGF1 treatment (nM)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 15, label = letter),
        size = 8
    ) +
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    scale_y_continuous(limits = c(150, 220)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT5_EFGH_multcomp_clust01.jpeg")

### Cluster 2 ====
clust_df <- df_DAT %>% 
    filter(cluster == 2)

stats_res <- clust_df %>% 
    oneway_test(., nbt_intensity_per_area ~ group) %>% 
    .$results

clust_df %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "Cluster 2",
        x = "RGF1 treatment (nM)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 15, label = letter),
        size = 8
    ) +
    # scale_x_discrete(labels = c(0, 1, 5, 10)) +
    # scale_y_continuous(limits = c(150, 220)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT5_EFGH_multcomp_clust02.jpeg")


# DAT 10 ====
df_DAT <- df0 %>% 
    filter(DAT == 10)

## Clustering ====
clust <- factoextra::fviz_nbclust(
    x = df_DAT[c("root_length")],
    FUNcluster = kmeans,
    method = "silhouette",
    k.max = 5
)
clust <- kmeans(df_DAT[c("root_length")], 2)

df_DAT$cluster <- as.factor(clust$cluster)

df_DAT %>% 
    ggplot(aes(root_length, nbt_intensity_per_area, color = cluster)) +
    labs(
        subtitle = "DAT10 (Recovery &rarr; RGF1 + 30&deg;C)",
        x = "Root length",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    scale_x_continuous(limits = c(0, 100)) +
    scale_y_continuous(limits = c(180, 210)) +
    theme(
        legend.position = "top",
        legend.margin = margin(5, 0, 0, 0),
        plot.subtitle = element_markdown()
    )

ggsave(filename = "DAT10_EFGH_clusters.jpeg")

### Cluster 1 ====
clust_df <- df_DAT %>% 
    filter(cluster == 1)

#### NBT intensity ====
stats_res <- clust_df %>% 
    oneway_test(., nbt_intensity_per_area ~ group) %>% 
    .$results

clust_df %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "Cluster 1",
        x = "RGF1 treatment (nM)",
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
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    scale_y_continuous(limits = c(180, 220)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT10_EFGH_clust01_NBT.jpeg")

#### Root length ====
stats_res <- clust_df %>% 
    oneway_test(., root_length ~ group) %>% 
    .$results

clust_df %>% 
    ggplot(aes(group, root_length, color = group)) +
    labs(
        subtitle = "Cluster 1",
        x = "RGF1 treatment (nM)",
        y = "Root length (mm)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos, label = letter),
        size = 8
    ) +
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    # scale_y_continuous(limits = c(180, 220)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT10_EFGH_clust01_root-length.jpeg")


### Cluster 2 ====
clust_df <- df_DAT %>% 
    filter(cluster == 2)

#### NBT intensity ====
stats_res <- clust_df %>% 
    oneway_test(., nbt_intensity_per_area ~ group) %>% 
    .$results

clust_df %>% 
    ggplot(aes(group, nbt_intensity_per_area, color = group)) +
    labs(
        subtitle = "Cluster 2",
        x = "RGF1 treatment (nM)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 22, label = letter),
        size = 8
    ) +
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    scale_y_continuous(limits = c(180, 210)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT10_EFGH_clust02_NBT.jpeg")

#### Root length ====
stats_res <- clust_df %>% 
    oneway_test(., root_length ~ group) %>% 
    .$results

clust_df %>% 
    ggplot(aes(group, root_length, color = group)) +
    labs(
        subtitle = "Cluster 2",
        x = "RGF1 treatment (nM)",
        y = "Root length (mm)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos, label = letter),
        size = 8
    ) +
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    # scale_y_continuous(limits = c(180, 210)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT10_EFGH_clust02_root-length.jpeg")

