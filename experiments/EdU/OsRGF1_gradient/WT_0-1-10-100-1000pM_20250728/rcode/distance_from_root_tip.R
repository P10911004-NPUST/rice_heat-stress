suppressMessages({
    rm(list = ls())
    if ( ! is.null(dev.list()) ) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(devtools)) install.packages("devtools")
    if (!require(ggtext)) install.packages("ggtext")
    if (!require(ggsignif)) install.packages("ggsignif")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool")
    
    pval2asterisk <- function(x)
    {
        vapply(
            x,
            function(`_`)
            {
                if (`_` <= 0.001) return("\U273D\U273D\U273D")
                if (`_` <= 0.01 & `_` > 0.001) return("\U273D\U273D")
                if (`_` <= 0.05 & `_` > 0.01) return("\U273D")
                if (`_` > 0.05) return("ns")
            },
            FUN.VALUE = character(1)
        )
    }
})

rawdata <- readxl::read_excel("../total_intensity.xlsx")

df0 <- rawdata %>% 
    filter(
        str_detect(img_name, "cancel", negate = TRUE),
        note != "discard",
        RGF1 %in% c(0, 1000)
    ) %>% 
    mutate(
        total_intensity = total_intensity / 1e6,
        distance = distance_from_root_tip_pixels * `resolution (um/pixel)`,
        RGF1 = as.factor(RGF1 / 1000)
    )

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Distance from root tip ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
normality_pass <- is_normality(df0, distance ~ RGF1)
what_test <- ifelse(isTRUE(normality_pass), "t.test", "wilcox.test")

out <- oneway_test(df0, distance ~ RGF1)
cld <- out$cld

ggplot(df0, aes(RGF1, distance)) +
    theme_bw() +
    labs(
        y = "Distance from<br>root tip (<i>&micro;</i>m)"
    ) +
    geom_boxplot(outliers = FALSE, fill = NA) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    geom_signif(
        test = what_test,
        test.args = list(
            alternative = "two.sided",
            var.equal = TRUE,
            paired = FALSE
        ),
        comparisons = list(c("0", "1")),
        map_signif_level = pval2asterisk,
        colour = "grey30",
        size = 1,
        textsize = 8,
        fontface = "bold",
        vjust = -0.2,
        tip_length = c(0.6, 0.05),
        y_position = 1070
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, MIN - 90, label = N),
        size = 6
    ) +
    scale_y_continuous(limits = c(250, 1200), breaks = seq(300, 1200, 300)) +
    scale_x_discrete(labels = c("Mock", "1 nM OsRGF1")) +
    # annotation_custom(
    #     grob = grid::textGrob(
    #         label = "OsRGF1",
    #         gp = grid::gpar(
    #             fontfamily = "sans",
    #             fontsize = 25, 
    #             fontface = "bold"
    #         )
    #     ),
    #     xmin = -0.9,
    #     xmax = 1,
    #     ymin = -10,
    #     ymax = 300
    # ) +
    # coord_cartesian(clip = "off") +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 12),
            size = 27,
            face = "bold",
            colour = "black"
        )
    )

ggsave(
    filename = "distance_from_root_tip.jpg",
    path = "./figures",
    create.dir = TRUE,
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Total EdU intensity ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
normality_pass <- is_normality(df0, total_intensity ~ RGF1)
what_test <- ifelse(isTRUE(normality_pass), "t.test", "wilcox.test")

out <- oneway_test(df0, total_intensity ~ RGF1)
cld <- out$cld

ggplot(df0, aes(RGF1, total_intensity)) +
    theme_bw() +
    labs(
        y = "Total EdU intensity<br>(10<sup>6</sup> AU)"
    ) +
    geom_boxplot(outliers = FALSE, fill = NA) +
    geom_point(
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    geom_signif(
        test = what_test,
        test.args = list(
            alternative = "two.sided",
            var.equal = TRUE,
            paired = FALSE
        ),
        comparisons = list(c("0", "1")),
        map_signif_level = pval2asterisk,
        colour = "grey30",
        size = 1,
        textsize = 8,
        fontface = "bold",
        vjust = -0.2,
        tip_length = c(.05, .05),
        y_position = 4.1
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, MIN - 0.6, label = N),
        size = 6
    ) +
    scale_y_continuous(limits = c(-0.3, 5), breaks = seq(0, 5, 1)) +
    scale_x_discrete(labels = c("Mock", "1 nM OsRGF1")) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 12),
            size = 27,
            face = "bold",
            colour = "black"
        )
    )

ggsave(
    filename = "EdU_total.jpg",
    path = "./figures",
    create.dir = TRUE,
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)
