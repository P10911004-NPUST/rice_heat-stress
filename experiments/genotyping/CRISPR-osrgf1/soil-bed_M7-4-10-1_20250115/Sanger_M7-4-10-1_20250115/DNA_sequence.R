suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    if (!require(BiocManager)) install.packages("BiocManager", quiet = TRUE)
    if (!require(Biostrings)) BiocManager::install("Biostrings", ask = FALSE)
    if (!require(ShortRead)) BiocManager::install("ShortRead", ask = FALSE)
    if (!require(pwalign)) BiocManager::install("pwalign", ask = FALSE)
})

AtRGF1 <- Biostrings::readDNAStringSet("C:/jklai/IRGSP/AtRGF1_AT5G60810.fa", format = "fasta")
names(AtRGF1) <- "AtRGF1"

OsRGF1 <- Biostrings::readDNAStringSet("C:/jklai/IRGSP/LOC_Os02g09760.fa", format = "fasta")
names(OsRGF1) <- "OsRGF1"

file_list <- list.files("./sanger_data", pattern = "\\.seq", full.names = TRUE)

read_DNA <- function(dna_file_dir) {
    if (grepl("WT", dna_file_dir)) {
        sample_id <- "WT"
    } else {
        sample_id <- gsub(".*N7-.*-(F\\d(\\d)?).seq", "\\1", dna_file_dir)
        sample_id <- gsub("F", "R", sample_id)
        sample_id <- paste0("M07_", sample_id)
    }
    dna_seq <- paste(readLines(dna_file_dir), collapse = "")
    ret <- list(seq = dna_seq, id = sample_id)
    return(ret)
}


lst <- list()
for (i in seq_along(file_list)) 
{
    f <- read_DNA(file_list[i])
    lst[f[["id"]]] <- f[["seq"]]
}

dna <- Biostrings::DNAStringSet(unlist(lst))
dna <- dna[order(names(dna))]
dna <- c(dna, OsRGF1, AtRGF1)
print(dna)
Biostrings::writeXStringSet(dna, filepath = "./DNA_sequence.fa", format = "fasta")

res <- pwalign::pairwiseAlignment(
    pattern = dna[grepl("M07", names(dna))], 
    subject = dna[names(dna) == "WT"]
)

res <- pwalign::aligned(res)






