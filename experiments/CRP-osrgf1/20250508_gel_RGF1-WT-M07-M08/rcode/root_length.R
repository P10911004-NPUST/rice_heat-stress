suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require("tidyverse")) install.packages("tidyverse")
    if (!require("ggtext")) install.packages("ggtext")
    if (!require("devtools")) install.packages("devtools")
    if (!require("statool")) devtools::install_github("P10911004-NPUST/statool", upgrade = "always")
    
    source("C:/jklai/github/datatool/R/df_reshape.R")
    
    hline_grob <- function(xmin, xmax, y, linewidth = 1.5){
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
    }
})

rawdata <- readxl::read_excel("../OUT_Magnif_32X.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel"),
    ) %>%
    dplyr::mutate(
        genotype = str_replace(img_name, "DAI07_(.*)_\\dnM.*", "\\1"),
        treatment = str_replace(img_name, ".*_(\\d)nM_.*", "\\1"),
        replicate = str_replace(img_name, ".*_R0(\\d)_.*", "\\1"),
        nbt_area = nbt_area / 1000,
        nbt_intensity = nbt_intensity / 1e6
    )

df0$genotype <- factor(df0$genotype, levels = c("WT", "M07", "M08"))
df0$treatment <- factor(df0$treatment, levels = c("0", "1"))
df0$group <- with(df0, paste(genotype, treatment, sep = "_"))

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Replicate 1 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(
        replicate == "1"
    )

out <- oneway_test(df1, root_length ~ group)
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)

ggplot(df1, aes(group, root_length, color = treatment)) +
    theme_classic() +
    labs(
        # subtitle = "Replicate 1",
        y = "Root length (mm)",
        color = "RGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point(position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos + 2, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(20, 100), breaks = seq(20, 100, 20)) +
    scale_x_discrete(
        labels = c(
            "<i>osrgf1-7</i>", "",
            "<i>osrgf1-8</i>", "",
            "WT", ""
        )
    ) +
    scale_color_manual(values = c("#000000", "#D55E00")) +
    scale_fill_manual(values = c("#000000", "#D55E00")) +
    hline_grob(1 - .35, 2 + .35, 17) +
    hline_grob(3 - .35, 4 + .35, 17) +
    hline_grob(5 - .35, 6 + .35, 17) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 24),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(size = 24, hjust = c(.17, 0, .17, 0, -.45, 0)),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(),
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
        legend.background = element_blank()
    )

ggsave(
    filename = "root_length.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    width = 17,
    height = 11
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Replicate 2 & 3 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df2 <- df0 %>% 
    dplyr::filter(
        replicate %in% c("2", "3")
    )

out <- oneway_test(df2, root_length ~ group)
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)

ggplot(df2, aes(group, root_length, color = treatment)) +
    theme_classic() +
    labs(
        subtitle = "Replicate 2",
        y = "Root length (mm)",
        color = "RGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point(position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos + 2, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(20, 100), breaks = seq(20, 100, 20)) +
    scale_x_discrete(
        labels = c(
            "<i>osrgf1-7</i>", "",
            "<i>osrgf1-8</i>", "",
            "WT", ""
        )
    ) +
    hline_grob(1 - 0.3, 2 + 0.3, 18) +
    hline_grob(3 - 0.3, 4 + 0.3, 18) +
    hline_grob(5 - 0.3, 6 + 0.3, 18) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 20),
        plot.subtitle = element_text(hjust = 1),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(hjust = c(-0.1, 0, -0.1, 0, -1, 0)),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
        legend.background = element_blank()
    )


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Salt stress simulation ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
if (FALSE){
    df0 <- data.frame(
        WT_mock = rnorm(10, 60, 3),
        WT_RGF1 = rnorm(10, 55, 4),
        WT_salt = rnorm(10, 40, 3),
        WT_both = rnorm(10, 52, 5),
        mut_mock = rnorm(10, 57, 3),
        mut_RGF1 = rnorm(10, 60, 5),
        mut_salt = rnorm(10, 30, 5),
        mut_both = rnorm(10, 40, 5)
    ) %>% 
        wide_to_long(
            cols = colnames(.), 
            keys_name = "group", 
            vals_name = "root_length"
        )
    
    df0$genotype <- gsub("(.*)_(.*)", "\\1", df0$group)
    
    df0$treatment <- gsub("(.*)_(.*)", "\\2", df0$group)
    df0$treatment <- factor(df0$treatment, levels = c("mock", "RGF1", "salt", "both"))
    
    df0$group <- factor(
        x = df0$group,
        levels = c(
            "WT_mock", "WT_RGF1", "WT_salt", "WT_both",
            "mut_mock", "mut_RGF1", "mut_salt", "mut_both"
        )
    )
    
    out <- oneway_test(df0, root_length ~ group)
    cld <- out$cld
    cld$cld_pos <- estimate_cld_pos(cld$MAX)
    
    ggplot(df0, aes(group, root_length, color = treatment)) +
        labs(
            subtitle = "<i>This is NOT real data, only for illustration</i>",
            y = "Root length (mm)",
            color = element_blank()
        ) +
        theme_classic() +
        geom_boxplot() +
        geom_point(position = position_jitter(width = .1)) +
        geom_text(
            inherit.aes = FALSE,
            data = cld,
            mapping = aes(GROUP, cld_pos, label = CLD),
            size = 8
        ) +
        scale_y_continuous(limits = c(20, 90)) +
        scale_x_discrete(
            labels = c(
                "", "WT", "", "",
                "", "<i>osrgf1</i>", "", ""
            )
        ) +
        scale_color_manual(values = c("#000000", "#E69F00", "#0072B2", "#CC79A7")) +
        hline_grob(1 - .35, 4 + 0.3, 18) +
        hline_grob(5 - .35, 8 + 0.3, 18) +
        theme(
            text = element_text(family = "sans", face = "bold", size = 24),
            plot.subtitle = element_markdown(color = "grey50", size = 18, hjust = -.8),
            axis.title.x.bottom = element_blank(),
            axis.text.x.bottom = element_markdown(
                size = 24,
                hjust = c(0, -.2, 0, 0, 0, .2, 0, 0)
            ),
            axis.line.x.bottom = element_blank(),
            axis.ticks.x.bottom = element_blank(),
            legend.position = "inside",
            legend.position.inside = c(0.5, .93),
            legend.direction = "horizontal",
            legend.background = element_blank()
        )
    
    ggsave(
        filename = "salt_stress.jpg",
        device = "jpeg",
        dpi = 660,
        units = "cm",
        width = 17,
        height = 11
    )
}

