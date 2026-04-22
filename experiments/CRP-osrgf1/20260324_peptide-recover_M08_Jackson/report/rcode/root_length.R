rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)
# options(contrasts = c("contr.sum", "contr.poly"))

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    library(outlying)
    
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

rawdata <- readxl::read_excel("../../OUT_NBT_20260324-151131.xlsx")

df0 <- rawdata %>% 
    # dplyr::filter(note == "ok") %>% 
    dplyr::mutate(
        nbt_total_intensity = nbt_total_intensity / 1e6,
        group = factor(OsRGF1_pM, levels = c(0, 1, 10, 100, 1000))
    )


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Peptide gradient test with osrgf1-8 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(root_length, sensitivity = 3),
        .by = "group"
    ) %>% 
    dplyr::filter(!is_outlier) %>%
    # dplyr::slice_max(root_length, n = 10, by = "group") %>%
    dplyr::select(-"is_outlier")

out <- oneway_test(df1, root_length ~ group)
out$tests
cld <- out$cld
cld
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MAX = estimate_cld_pos(MAX) + 2.5,
        YPOS_MIN = MIN - 5,
        genotype = str_replace(GROUP, "(.*)_(.*)", "\\1")
    )


ggplot(df1, aes(group, root_length)) +
    theme_classic() +
    labs(
        x = "OsRGF1 (pM)",
        y = "Primary root length (mm)"
    ) +
    geom_boxplot(
        fill = "transparent",
        size = 1,
        linewidth = 0.5,
        outliers = FALSE,
        outlier.shape = NA
    ) +
    geom_point(
        size = 5,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 123)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MAX, label = CLD),
        size = 11,
        show.legend = FALSE
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, label = N),
        size = 7,
        show.legend = FALSE
    ) +
    scale_y_continuous(limits = c(20, 70), breaks = seq(20, 70, 10)) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_markdown(
            margin = ggplot2::margin(t = 11)
        ),
        axis.title.y.left = element_markdown(
            lineheight = 1.2,
            margin = ggplot2::margin(r = 11)
        ),
        legend.position = "top",
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 25, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0.5
    )

ggsave(
    create.dir = TRUE,
    filename = "root-length_peptide-gradient.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 19
)

df1 %>% 
    dplyr::arrange(group) %>% 
    write.csv("./figure/root_length_peptide-gradient.csv", row.names = FALSE)
