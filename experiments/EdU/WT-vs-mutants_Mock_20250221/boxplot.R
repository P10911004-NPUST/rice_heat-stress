if (!require(pak)) install.packages("pak")
if (!require(statool)) pak::pak("P10911004-NPUST/statool")
library(statool)
library(tidyverse)
library(ggtext)

estimate_cld_pos <- estimate_letter_pos <- function(x)
{
    MAX <- base::max(x)
    letter_pos <- x + ((base::ceiling(base::max(MAX) * 1.15) - base::max(x)) * 0.66)
    return(letter_pos)
}

rawdata <- read.csv("./total_intensity.csv")

df0 <- rawdata %>% 
    dplyr::filter(area < 50000) %>% 
    dplyr::mutate(
        genotype = stringr::str_replace(img_name, "(.*)_(.*)_(.*)_(.*).czi", "\\1"),
        total_intensity = total_intensity / 1000000
    ) %>% 
    dplyr::mutate(
        genotype = factor(genotype, levels = c("WT", "M07", "M08", "M15"))
    )

# Total intensity ====
stats_res <- oneway_test(df0, total_intensity ~ genotype)
stats_res$tests
stats_res <- stats_res$result
stats_res <- stats_res %>% 
    dplyr::mutate(letter_pos = estimate_letter_pos(MAX) - 0.22)

ggplot(df0, aes(genotype, total_intensity, color = genotype)) +
    theme_bw() +
    labs(
        y = "Total EdU intensity (10<sup>6</sup>)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(GROUPS, letter_pos, label = CLD),
        size = 8
    ) +
    theme(
        axis.title = element_markdown(family = "sans", face = "bold", size = 20),
        axis.text = element_markdown(family = "sans", face = "bold", size = 16),
        legend.position = "none",
        axis.title.x = element_blank(),
    )


# Avg intensity ====
stats_res <- oneway_test(df0, avg_intensity ~ genotype)
stats_res$tests
stats_res <- stats_res$result
stats_res <- stats_res %>% 
    dplyr::mutate(letter_pos = estimate_letter_pos(MAX))

ggplot(df0, aes(genotype, avg_intensity, color = genotype)) +
    theme_bw() +
    labs(
        y = "Average EdU intensity"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(GROUPS, letter_pos, label = CLD),
        size = 8
    ) +
    theme(
        axis.title = element_markdown(family = "sans", face = "bold", size = 20),
        axis.text = element_markdown(family = "sans", face = "bold", size = 16),
        legend.position = "none",
        axis.title.x = element_blank(),
    )
