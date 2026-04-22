library(tidyverse)
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/statools/R/thresholding.R")
source("C:/jklai/github/statools/R/utils.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")
source("../../../../rcode/utils.R")

set.seed(1)
theme_set(theme_bw_01)

# Read data ====
rawdata <- readxl::read_excel("../root_length/OUT_WT_vs_osrgf1-1_20241014.xlsx")


# Tidy ====
df0 <- rawdata %>% 
    mutate(
        genotype = str_replace(img_name, "(.*)_R\\d\\d_.*", "\\1"),
        genotype = case_when(
            str_detect(genotype, "F7") ~ "#7_4_10",
            str_detect(genotype, "F8") ~ "#8_9_6_3",
            TRUE ~ genotype
        ),
        genotype = factor(genotype, levels = c("WT", "#8_9_6_3", "#7_4_10")),
        nbt_area = nbt_area / 1000
    ) %>% 
    group_by(genotype) %>% 
    filter(
        !detect_outliers(nbt_area),
        !str_detect(img_name, "_cancel_"),
        # genotype != "#7_4_10"
    ) %>% 
    ungroup()


# Define long short root ====
df0 <- df0 %>% 
    group_by(genotype) %>%
    mutate(
        root_type = def_long_short_root(root_length)
        # root_type = case_when(
        #     root_length > otsu_threshold(root_length) ~ "long",
        #     root_length <= otsu_threshold(root_length) ~ "short",
        #     TRUE ~ NA_character_
        # )
    ) %>% 
    ungroup() %>%
    group_by(genotype, root_type) %>% 
    filter(!detect_outliers(nbt_area), !detect_outliers(avg_nbt)) %>% 
    ungroup()

df0 %>% 
    group_by(genotype, root_type) %>% 
    count()

# Root types ====
for ( i in unique(df0$root_type) ) {
    df1 <- df0 %>% 
        filter(root_type == i)
    
    ## NBT area ====
    stats <- oneway_test(df1, nbt_area ~ genotype)
    stats_res <- stats$result
    
    df1 %>% 
        ggplot(aes(genotype, nbt_area, color = genotype)) +
        labs(
            subtitle = "NBT area (&times;1000 pixels)"
        ) +
        geom_boxplot() +
        geom_point() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_pos, label = letter),
            size = 8
        ) +
        theme(
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x.bottom = element_markdown(size = 22),
            legend.position = "none"
        )
    
    ggsave2(
        filename = sprintf("nbt_area_%s.jpg", i),
        path = "./figures/"
    )
    
    ## Avg NBT intensity ====
    stats <- oneway_test(df1, avg_nbt ~ genotype)
    stats_res <- stats$result
    
    df1 %>% 
        ggplot(aes(genotype, avg_nbt, color = genotype)) +
        labs(
            subtitle = "Average NBT intensity (&times;10<sup>6</sup> DN)"
        ) +
        geom_boxplot() +
        geom_point() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_pos, label = letter),
            size = 8
        ) +
        theme(
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x.bottom = element_markdown(size = 22),
            legend.position = "none"
        )
    
    ggsave2(
        filename = sprintf("avg_nbt_%s.jpg", i),
        path = "./figures/"
    )
    
    ## Root length ====
    stats <- oneway_test(df1, root_length ~ genotype)
    stats_res <- stats$result
    
    df1 %>% 
        ggplot(aes(genotype, root_length, color = genotype)) +
        labs(
            subtitle = "Root length (mm)"
        ) +
        geom_boxplot() +
        geom_point() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_pos, label = letter),
            size = 8
        ) +
        theme(
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x.bottom = element_markdown(size = 22),
            legend.position = "none"
        )
    
    ggsave2(
        filename = sprintf("root_length_%s.jpg", i),
        path = "./figures/"
    )
}













