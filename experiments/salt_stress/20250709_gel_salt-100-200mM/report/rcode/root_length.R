rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)

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

rawdata <- readxl::read_excel("../../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(root_type == "Se") %>% 
    dplyr::mutate(
        salt_conc_mM = factor(salt_conc_mM, levels = c(0, 100, 200)),
        nbt_total = nbt_total / 1e6,
        group = paste(root_type, salt_conc_mM, sep = "_")
    )

write.csv(df0, "./figure/root_length.csv", row.names = FALSE)

out <- oneway_test(df0, root_length ~ salt_conc_mM)
out$tests
cld <- out$cld
print(cld[order(cld$GROUP), ])
cld$heat <- gsub(".*_(.*)_.*", "\\1", cld$GROUP)
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX) + 7
cld$YPOS_MIN <- cld$MIN - 7

for (g in unique(df0$group)) {
    df_tmp <- dplyr::filter(df0, group == g)
    print(paste0(g, ": ", is_normality(df_tmp$root_length)))
}

ggplot(df0, aes(salt_conc_mM, root_length)) +
    theme_classic() +
    labs(
        x = "NaCl treatment (mM)",
        y = "Seminal root length (mm)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        # mapping = aes(shape = genotype),
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MAX, label = CLD),
        size = 10,
        fontface = "bold"
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N),
        size = 7
    ) +
    scale_y_continuous(limits = c(0, 100)) +
    # scale_x_discrete(
    #     labels = c("", "Mock", "", "",
    #                "", "1 nM OsRGF1", "", "")
    # ) +
    # scale_color_manual(
    #     values = c("#0072B2", "#D55E00"),
    #     labels = c("30&deg;C", "40&deg;C"),
    #     guide = guide_legend(
    #         order = 1
    #     )
    # ) +
    # scale_shape_manual(
    #     values = c("circle", "diamond open"),
    #     labels = c("WT", "<i>osrgf1-7</i>"),
    #     guide = guide_legend(
    #         override.aes = list(size = 4),
    #         order = 2
    #     )
    # ) +
    # hline_grob(1 - 0.3, 4 + 0.3, 50) +
    # hline_grob(5 - 0.3, 8 + 0.3, 50) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 7)
        ),
        axis.text.x.bottom = element_markdown(
            size = 25,
            # hjust = c(0, 0.1, 0, 0, 0, 0.35, 0, 0),
            margin = ggplot2::margin(t = 7)
        ),
        # axis.line.x.bottom = element_blank(),
        # axis.ticks.x.bottom = element_blank(),
        
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
            family = "sans", face = "plain", size = 23, margin = margin(r = 6, l = 6)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 1
    )

ggsave(
    filename = "root_length.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 17
)
