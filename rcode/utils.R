

RGF1_colors_gradient <- c("#dabfff", "#907ad6", "#4f518c", "#2c2a4a")

clust <- function(data, .col = NULL, nbclust = 2){
    res <- list()
    ifelse(is.null(.col), df0 <- data, df0 <- data[c(.col)])
    
    res[["opt.nclust"]] <- factoextra::fviz_nbclust(df0, FUNcluster = kmeans)
    res[["results"]] <- kmeans(df0, centers = nbclust)
    
    return(res)
}




opt_nclust <- function(
        data,
        vars = NULL
){
    if (!is.null(vars)) df0 <- data[[vars]]
    
    opt_nclust <- lapply(
        X = c("silhouette", "wss", "gap_stat"),
        FUN = function(fns) {
            factoextra::fviz_nbclust(
                x = df0, 
                FUNcluster = kmeans, 
                method = fns
            )
        }
    )
    
    return(opt_nclust)
} 


def_long_short_root <- function(data, x){
    clust <- kmeans(data[x], centers = 2)
    
    v0 <- as.character(clust$cluster)
    
    v0[v0 == names(which.max(clust$centers[, 1]))] <- "long"
    v0[v0 == names(which.min(clust$centers[, 1]))] <- "short"
    
    return(v0)
}
