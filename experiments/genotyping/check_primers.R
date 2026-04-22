library(DECIPHER)

dna <- readDNAStringSet("C:/jklai/IRGSP/osa1_r7.asm.fa")
primers <- c("GGATCGATGAACAGCAGTGTA", "TAACTGGAAGCTGAGAGCCTGA")

lst0 <- list()

for (i in seq_along(dna))
{
    amplicons <- AmplifyDNA(
        primers = primers, 
        myDNAStringSet = dna[i], 
        maxProductSize = 600,
        annealingTemp = 56,
        P = 100e-6,
        includePrimers = FALSE
    )
    
    lst0[[i]] <- amplicons
}

names(lst0) <- names(dna)

# amplicons <- AmplifyDNA(
#     primers = primers, 
#     myDNAStringSet = dna[5], 
#     maxProductSize = 600,
#     annealingTemp = 56,
#     P = 100e-6,
#     includePrimers = FALSE
# )
# 
# amplicons



