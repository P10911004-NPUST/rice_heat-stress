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
        group %in% c("A", "B", "C", "D"),
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

ggsave(filename = "DAT0_ABCD.jpeg")

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
    scale_x_continuous(limits = c(10, 65)) +
    scale_y_continuous(limits = c(150, 205)) +
    theme(
        legend.position = "top",
        legend.margin = margin(5, 0, 0, 0),
        plot.subtitle = element_markdown()
    )

ggsave(filename = "DAT5_ABCD_clusters.jpeg")

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
ggsave(filename = "DAT5_ABCD_multcomp_clust01.jpeg")

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
    scale_x_discrete(labels = c(0, 1, 5, 10)) +
    scale_y_continuous(limits = c(150, 220)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )
ggsave(filename = "DAT5_ABCD_multcomp_clust02.jpeg")


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

ggsave(filename = "DAT10_ABCD_clusters.jpeg")

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
ggsave(filename = "DAT10_ABCD_multcomp_clust01.jpeg")

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
ggsave(filename = "DAT10_ABCD_multcomp_clust02.jpeg")




# stats_res <- df_DAT %>% 
#     oneway_test(., nbt_intensity_per_area ~ group) %>% 
#     .$results
# 
# df_DAT %>% 
#     ggplot(aes(group, nbt_intensity_per_area, color = group)) +
#     labs(
#         subtitle = "DAT5 (Treatment &rarr; RGF1 + 38&deg;C)",
#         x = "RGF1 treatment (nM)",
#         y = "Average NBT intensity<br>(DN / pixel)"
#     ) +
#     geom_point() +
#     geom_boxplot() +
#     geom_text(
#         inherit.aes = FALSE,
#         data = stats_res,
#         mapping = aes(group, letter_y_pos - 20, label = letter),
#         size = 8
#     ) +
#     scale_x_discrete(labels = c(0, 1, 5, 10)) +
#     # scale_y_continuous(limits = c(170, 210)) +
#     scale_color_manual(values = gradient_colors) +
#     theme(
#         legend.position = "none",
#         plot.subtitle = element_markdown()
#     )
# 
# 
# 
# 
# # # Correlation ====
# # corr_df <- df0 %>% 
# #     group_by(DAT, group) %>% 
# #     correlation::correlation(
# #         select = "root_length",
# #         select2 = "nbt_intensity_per_area"
# #     ) %>% 
# #     ungroup() %>% 
# #     as_tibble() %>% 
# #     mutate(
# #         signif = num2asterisk(p)
# #     )
# 
# # Clustering ====
# clust_df <- df0 %>% 
#     filter(DAT != 0) %>% 
#     select(root_length, nbt_intensity_per_area)
# 
# clust <- factoextra::fviz_nbclust(
#     x = clust_df,
#     FUNcluster = kmeans,
#     method = "silhouette",
#     k.max = 5
# )
# 
# clust <- kmeans(clust_df, 2)
# 
# df0$cluster <- as.factor(clust$cluster)
# 
# df0 %>% 
#     ggplot(aes(root_length, nbt_intensity_per_area, color = cluster)) +
#     geom_text(aes(label = group))
# 
# 
# stats_res <- df0 %>% 
#     filter(DAT == 5) %>% 
#     filter(cluster == 1) %>% 
#     oneway_test(., nbt_intensity_per_area ~ group) %>% 
#     .$results
# 
#  
#     
# protective <- df0 %>% 
#     filter(group %in% c("A", "B", "C", "D"))
# 
# protective %>% 
#     ggplot(aes(root_length, nbt_intensity_per_area, color = group)) +
#     geom_point(size = 2) +
#     scale_color_manual(values = gradient_colors)
# 
# recovery <- df0 %>% 
#     filter(group %in% c("E", "F", "G", "H"))
# 
# recovery %>% 
#     group_by(DAT, group) %>% 
#     correlation::correlation(
#         select = root_length,
#         select2 = nbt_intensity_per_area
#     ) %>% 
#     as_tibble()
# 
# recovery %>% 
#     filter(DAT == 0) %>%
#     ggplot(aes(root_length, nbt_intensity_per_area, color = group)) +
#     geom_point(size = 2) +
#     scale_color_manual(values = gradient_colors)
# 
# 
# # # Pre-hoc ====
# # m <- art(nbt_intensity_per_area ~ group * DAT + (1|sample_id), data = df0)
# # anova(m)
# # 
# # art.con(m, "group:DAT", adjust = "holm") %>% 
# #     summary()
# 
# # DAT0: Control (Mock + 38&deg;C) ====
# ## Average NBT intensity ====
# stats_res <- df0 %>% 
#     filter(DAT == 0) %>% 
#     oneway_test(nbt_intensity_per_area ~ group) %>% 
#     .$results
# 
# df0 %>% 
#     filter(DAT == 0) %>% 
#     ggplot(aes(group, nbt_intensity_per_area, color = group)) +
#     labs(
#         subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
#         y = "Average NBT intensity<br>(DN / pixel)"
#     ) +
#     geom_point() +
#     geom_boxplot() +
#     geom_text(
#         inherit.aes = FALSE,
#         data = stats_res,
#         mapping = aes(group, letter_y_pos - 20, label = letter),
#         size = 8
#     ) +
#     scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
#     theme(
#         legend.position = "none",
#         axis.title.x.bottom = element_blank(),
#         plot.subtitle = element_markdown()
#     )
# 
# 
# # DAT5: Treatment (RGF1 + 38&deg;C) ====
# ## Average NBT intensity ====
# stats_res <- df0 %>% 
#     filter(DAT == 5) %>% 
#     oneway_test(nbt_intensity_per_area ~ group) %>% 
#     .$results
# 
# df0 %>% 
#     filter(DAT == 5) %>% 
#     ggplot(aes(group, nbt_intensity_per_area, color = group)) +
#     labs(
#         subtitle = "DAT5 (Treatment &rarr; RGF1 + 38&deg;C)",
#         y = "Average NBT intensity<br>(DN / pixel)"
#     ) +
#     geom_point() +
#     geom_boxplot() +
#     geom_text(
#         inherit.aes = FALSE,
#         data = stats_res,
#         mapping = aes(group, letter_y_pos - 20, label = letter),
#         size = 8
#     ) +
#     # scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
#     theme(
#         legend.position = "none",
#         axis.title.x.bottom = element_blank(),
#         plot.subtitle = element_markdown()
#     )
# 
# 
# 
# # DAT10: Treatment (RGF1 + 38&deg;C) ====
# ## Average NBT intensity ====
# stats_res <- df0 %>% 
#     filter(DAT == 10) %>% 
#     oneway_test(nbt_intensity_per_area ~ group) %>% 
#     .$results
# 
# df0 %>% 
#     filter(DAT == 10) %>% 
#     ggplot(aes(group, nbt_intensity_per_area, color = group)) +
#     labs(
#         subtitle = "DAT10 (Treatment &rarr; RGF1 + 30&deg;C)",
#         y = "Average NBT intensity<br>(DN / pixel)"
#     ) +
#     geom_point() +
#     geom_boxplot() +
#     geom_text(
#         inherit.aes = FALSE,
#         data = stats_res,
#         mapping = aes(group, letter_y_pos - 20, label = letter),
#         size = 8
#     ) +
#     # scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
#     theme(
#         legend.position = "none",
#         axis.title.x.bottom = element_blank(),
#         plot.subtitle = element_markdown()
#     )
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# #Correlation (root_length vs average_nbt) ====
# corr <- df0 %>% 
#     filter(DAT == 0) %>% 
#     group_by(group) %>% 
#     correlation::correlation(
#         select = "root_length",
#         select2 = "nbt_intensity_per_area"
#     ) %>%
#     as_tibble() %>% 
#     ungroup()
# 
# df0 %>% 
#     filter(DAT == 0) %>% 
#     ggplot(aes(root_length, nbt_intensity_per_area, color = group)) +
#     labs(
#         subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
#         x = "Root length (mm)",
#         y = "Average NBT intensity<br>(DN / pixels)"
#     ) +
#     geom_point() +
#     geom_smooth(method = "lm", se = FALSE) +
#     theme(
#         legend.position = "right",
#         legend.direction = "vertical",
#         legend.position.inside = c(0.5, 0.9),
#         legend.title = element_blank(),
#         plot.subtitle = element_markdown()
#     )
# 
# 
# 
# 
