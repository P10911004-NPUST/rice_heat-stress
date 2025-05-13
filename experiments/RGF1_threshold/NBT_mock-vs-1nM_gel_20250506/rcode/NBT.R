suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    options(contrasts = c("contr.sum", "contr.poly"))
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install("P10911004-NPUST/statool", upgrade = FALSE, quiet = TRUE)
})

rawdata <- readxl::read_excel("../OUT_Magnif_20X.xlsx")

df0 <- rawdata %>% 
    dplyr::mutate(
        genotype = factor(genotype, levels = c("M07", "M08")),
        treatment = factor(treatment, levels = c(0, 1)),
        group = paste(genotype, treatment, sep = "_")
    ) 

# Filter out outliers
if (FALSE) {
    df0 <- df0 %>% 
        dplyr::group_by(group) %>% 
        dplyr::mutate(is_outlier = Grubbs_test(nbt_intensity)) %>% 
        dplyr::ungroup() %>% 
        dplyr::filter(!is_outlier)
}

aov_mod <- aov(avg_nbt ~ genotype * treatment, df0)
anova(aov_mod)
# car::Anova(aov_mod, type = 3)


ggplot(df0, aes(group, nbt_area)) +
    geom_boxplot(alpha = 0.7) +
    geom_point(position = position_jitter(width = 0.1))



out <- oneway_test(df0, avg_nbt ~ group)
out$cld

