rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)
options(contrasts = c("contr.sum", "contr.poly"))

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    
    hline_grob <- function(xmin, xmax, y, linewidth = 1.5) {
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
    }
})

rawdata <- readxl::read_excel("../../qPCR_OE_Hari_20251021.xlsx")

df0 <- rawdata %>% 
    dplyr::mutate(
        genotype = case_when(genotype == "XVE-OsRGF1_7-8-8" ~ "OE7",
                             genotype == "XVE-OsRGF1_28-7-3" ~ "OE28",
                             TRUE ~ genotype),
        Estradiol_uM = as.character(Estradiol_uM),
        group = paste(genotype, Estradiol_uM, sep = "_"),
        group = factor(group, levels = c("WT_0", "WT_5", "OE7_0", "OE7_5", "OE28_0", "OE28_5"))
    )

df_desc <- df0 %>% 
    dplyr::summarise(
        N = length(relative_mRNA_level),
        AVG = mean(relative_mRNA_level),
        SD = sd(relative_mRNA_level),
        .by = c("genotype", "Estradiol_uM", "group")
    ) %>% 
    dplyr::mutate(SE = SD / sqrt(N))


ggplot(df0, aes(group, relative_mRNA_level, color = Estradiol_uM)) +
    theme_classic() +
    labs(
        y = "Relative mRNA level" 
    ) +
    geom_col(
        inherit.aes = FALSE,
        data = df_desc,
        mapping = aes(group, AVG, fill = Estradiol_uM),
        color = NA,
        alpha = 0.3,
        show.legend = FALSE
    ) +
    geom_errorbar(
        inherit.aes = FALSE,
        data = df_desc,
        mapping = aes(
            x = group, 
            ymin = AVG - SE,
            ymax = AVG + SE,
            color = Estradiol_uM
        ),
        alpha = 0.7,
        width = 0.5,
        linewidth = 1,
        show.legend = FALSE
    ) +
    # geom_boxplot(
    #     outliers = FALSE,
    #     outlier.shape = NA
    # ) +
    geom_point(
        size = 3,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    scale_x_discrete(
        labels = c("WT", "", "OE7", "", "OE28", "")
    ) +
    scale_y_continuous(limits = c(0, 350), breaks = seq(0, 350, 50)) +
    scale_color_manual(
        labels = c("Mock", "<i>&beta;</i>-Estradiol"),
        values = c("#56B4E9", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    scale_fill_manual(
        labels = c("Mock", "Est"),
        values = c("#56B4E9", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    hline_grob(1 - 0.4, 2 + 0.4, 0 - 15) +
    hline_grob(3 - 0.4, 4 + 0.4, 0 - 15) +
    hline_grob(5 - 0.4, 6 + 0.4, 0 - 15) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 25,
            hjust = c(-0.13, 0, 0, 0, 0.1, 0),
            margin = ggplot2::margin(t = 9),
            lineheight = 1.1
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
            margin = ggplot2::margin(r = 9)
        ),
        legend.position = "top",
        legend.position.inside = c(0.5, 0.95),
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 23, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0
    )

ggsave(
    filename = "qPCR.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 23,
    width = 13
)


