rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()
set.seed(1)

source("../../../../rcode/utils.R")
source("C:/jklai/github/statools/R/oneway_test.R")
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")

theme_set(theme_bw_01)

rawdata <- readxl::read_excel("../shoot_dry_weight_DAT-010.xlsx")

df0 <- rawdata %>% 
    mutate(
        purpose = case_when(
            sample_id %in% 1:12 ~ "protect",
            sample_id %in% 13:24 ~ "recover"
        ),
        treatment = case_when(
            sample_id %in% c(1:3, 13:15) ~ 0,
            sample_id %in% c(4:6, 16:18) ~ 1,
            sample_id %in% c(7:9, 19:21) ~ 5,
            sample_id %in% c(10:12, 22:24) ~ 10,
        )
    ) %>% 
    mutate(
        SDW = `SDW (mg)`,
        treatment = factor(treatment, levels = c(0, 1, 5, 10)),
        group = treatment
    )

for (i in unique(df0$purpose)){
    df1 <- df0 %>% 
        filter(purpose == i)
    
    stats_res <- oneway_test(df1, SDW ~ group)
    stats_res <- stats_res$result
    
    df1 %>% 
        ggplot(aes(group, SDW, color = treatment)) +
        labs(
            subtitle = "DAT10",
            x = "RGF1 (nM)",
            y = "SDW (mg)"
        ) +
        geom_point() +
        geom_boxplot() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_y_pos, label = letter),
            size = 8
        ) +
        theme(
            legend.position = "none"
        )
    
    ggsave(
        filename = sprintf("SDW_DAT10_%s.jpeg", i),
        path = "./",
        device = "jpeg",
        units = "cm",
        dpi = 330,
        height = 12,
        width = 17
    )
}

