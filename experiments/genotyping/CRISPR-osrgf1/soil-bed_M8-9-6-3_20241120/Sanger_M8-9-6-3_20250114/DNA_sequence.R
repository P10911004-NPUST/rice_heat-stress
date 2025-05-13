suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    if (!require(BiocManager)) install.packages("BiocManager", quiet = TRUE)
    if (!require(Biostrings)) BiocManager::install("Biostrings", ask = FALSE)
    if (!require(ShortRead)) BiocManager::install("ShortRead", ask = FALSE)
    if (!require(pwalign)) BiocManager::install("pwalign", ask = FALSE)
})

read_DNA <- function(dna_file_dir) {
    if (grepl("WT", dna_file_dir)) {
        sample_id <- "WT"
    } else {
        sample_id <- gsub(".*n8-.*-(F\\d(\\d)?).seq", "\\1", dna_file_dir)
        sample_id <- gsub("F", "M", sample_id)
    }
    dna_seq <- paste(readLines(dna_file_dir), collapse = "")
    ret <- list(seq = dna_seq, id = sample_id)
    return(ret)
}


AtRGF1 <- Biostrings::readDNAStringSet("C:/jklai/IRGSP/AtRGF1_AT5G60810.fa", format = "fasta")
names(AtRGF1) <- "AtRGF1"

OsRGF1 <- Biostrings::readDNAStringSet("C:/jklai/IRGSP/LOC_Os02g09760.fa", format = "fasta")
names(OsRGF1) <- "OsRGF1"

mature_OsRGF1 <- Biostrings::readDNAStringSet("./mature_OsRGF1_DNA_sequence.fa", format = "fasta")
names(mature_OsRGF1) <- "mature_OsRGF1"

OsRGF1_primers <- Biostrings::readDNAStringSet("./OsRGF1_primer_sequence.fa", format = "fasta")
names(OsRGF1_primers) <- c("CRP-OsRGF1-F", "CRP-OsRGF1-R")


file_list <- list.files("./sanger_data", pattern = "\\.seq", full.names = TRUE)

lst <- list()
for (i in seq_along(file_list)) 
{
    f <- read_DNA(file_list[i])
    lst[f[["id"]]] <- f[["seq"]]
}
lst <- lst[order(names(lst))]

dna <- Biostrings::DNAStringSet(unlist(lst))
dna <- c(dna, OsRGF1_primers, mature_OsRGF1, OsRGF1, AtRGF1)
Biostrings::writeXStringSet(dna, filepath = "./DNA_sequence.fa", format = "fasta")

res <- pwalign::pairwiseAlignment(dna[1:23], dna[24])
as.list(res)

