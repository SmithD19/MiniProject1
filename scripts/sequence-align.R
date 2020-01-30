### This script will gather all the accession numbers for our species

# Species here under scientific name
ncbi_spp <- read_csv("data/resolved-ncbi-species.csv")

# Load functions
source("scripts/genbank-scraping.R")

# Scrape genbank
co1_accession <- scrape.genbank(ncbi_spp$scientificname, "COI")
its2_accession <- scrape.genbank(ncbi_spp$scientificname, "internal transcribed spacer 2")

# Write fasta sequences ---------------------------------------------------

library(ape)

co1_dna <- read.GenBank(co1_accession$COI, seq.names = co1$Species)

its2_dna <- read.GenBank(its2_accession$`internal transcribed spacer 2`, seq.names = its2_accession$Species)

write.FASTA(co1_dna, "data/co1-raw.fasta")

write.FASTA(its2_dna, "data/its2-raw.fasta")


# Bioconducture - msa -----------------------------------------------------

library(msa)

co1_sequences <- readAAStringSet("data/co1-fasta.fasta")

co1_alignment <- msa(co1_sequences, method = "Muscle")

its2_sequences <- readAAStringSet("data/its2-fasta.fasta")

its2_alignment <- msa(its2_sequences, method = "Muscle")

# msaprettyprint would be nice here
msaPrettyPrint(co1_alignment)

co1_alignment_2 <- msaConvert(co1_alignment, type = "seqinr::alignment")

# Distance matrix - seqinr ------------------------------------------------

library(seqinr)

co1_mat <- dist.alignment(co1_alignment_2, "identity")


# Phylogeny - ape ---------------------------------------------------------

library(ape)

co1_tree <- nj(co1_mat)

plot(co1_tree, main = "Phylogenetic Tree of COI in Mosquitoes")


