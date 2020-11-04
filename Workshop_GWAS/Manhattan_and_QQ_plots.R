rm(list = ls())
library(qqman)

db = read.table(
  "/home/manager/Day3_Practical5_GWAS/gwas_cov_pca.assoc.linear.merge.tsv", 
  sep = "\t", header = T, stringsAsFactors = F, strip.white = T
)

data.qqman =  db[db$CHR != 0, c("SNP", "CHR", "BP", "P")]

library(help="qqman")
# gwasResults             Simulated GWAS results
# manhattan               Creates a manhattan plot
# qq                      Creates a Q-Q plot
# qqman                   Create Q-Q and manhattan plots for GWAS data.
# snpsOfInterest          snpsOfInterest

dev.new()

cols1 = c("blue4", "orange3")
cols2 = c("chocolate4","black","red","chartreuse4","darkmagenta","orange","blue")

manhattan(data.qqman, main = "Manhattan Plot", ylim = c(0, 10), cex = 0.6, 
          cex.axis = 0.9, col = cols2, suggestiveline = -log10(2.5e-07), genomewideline = -log10(5e-08), 
          chrlabs = c(1:22, "X", "Y"))

qq(data.qqman$P)
