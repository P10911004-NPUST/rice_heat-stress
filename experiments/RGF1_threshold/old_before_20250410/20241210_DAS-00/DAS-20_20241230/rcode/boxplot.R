suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    library(tidyverse)
    source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    source("C:/jklai/github/statools/R/detect_outliers.R")
    
    theme_set(theme_bw_01)
    
    gnerate_grey_gradient <- function(n) colorRampPalette(c("grey20", "grey70"))(n)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    select(img_name, nbt_area, nbt_intensity, trim_avg_nbt, root_length) %>% 
    mutate(
        treatment = as.factor(as.numeric(str_replace(img_name, ".*_(.*)nM_.*", "\\1"))),
        nbt_intensity = nbt_intensity / 1e6,
        nbt_area = nbt_area / 1e6,
        is_cancel = str_detect(img_name, "cancel")
    ) %>% 
    filter(!is_cancel)

write.csv(df0, "total_nbt_intensity.csv", row.names = FALSE)

# # NBT area ====
# stats_res <- oneway_test(df0, nbt_area ~ treatment)
# stats_res$perform_test
# stats_res <- stats_res$result
# 
# ggplot(df0, aes(treatment, nbt_area, color = treatment)) +
#     labs(
#         subtitle = "NBT area (10<sup>6</sup> pixels)",
#         x = "OsRGF1 (nM)"
#     ) +
#     geom_boxplot() +
#     geom_point() +
#     geom_text(
#         inherit.aes = FALSE,
#         data = stats_res,
#         mapping = aes(group, letter_y_pos, label = letter),
#         size = 8
#     ) +
#     theme(
#         legend.position = "none",
#         axis.title.y = element_blank()
#     )


# Total NBT intensity ====
stats_res <- oneway_test(df0, nbt_intensity ~ treatment)
stats_res$perform_test
stats_res <- stats_res$result

ggplot(df0, aes(treatment, nbt_intensity, color = treatment)) +
    labs(
        x = "OsRGF1 (nM)",
        y = "Total NBT intensity (AU)"
    ) +
    geom_boxplot() +
    geom_point(size = 4) +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos + 5, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 80)) +
    scale_color_manual(values = colorRampPalette(c("grey70", "grey0"))(5)) +
    theme(
        text = element_text(size = 25),
        legend.position = "none",
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9))
    )

ggsave2(filename = "total_nbt_intensity.jpg", path = "./figures")




# root length ====
stats_res <- oneway_test(df0, root_length ~ treatment)
stats_res$perform_test
stats_res <- stats_res$result

ggplot(df0, aes(treatment, root_length, color = treatment)) +
    labs(
        x = "OsRGF1 (nM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot() +
    geom_point(size = 4) +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos + 5, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(10, 90), breaks = seq(10, 90, 20)) +
    scale_color_manual(values = colorRampPalette(c("grey70", "grey0"))(5)) +
    theme(
        text = element_text(size = 25),
        legend.position = "none",
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9))
    )

ggsave2(filename = "root_length.jpg", path = "./figures")



