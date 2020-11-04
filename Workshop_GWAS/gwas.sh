: '
X    X chromosome                    -> 23
Y    Y chromosome                    -> 24
XY   Pseudo-autosomal region of X    -> 25
MT   Mitochondrial                   -> 26
...are not valid (female Y genotype, heterozygous haploid chromosome)'


############################################

cd /home/manager/TP_GWAS_course_2020

plink --bfile malaria_senegal --set-hh-missing --make-bed --out malaria_senegal_clean_1



: '
Currently, PLINK calculates the per SNP Mendel error rates at the same time as the per family 
error rates. In future releases, this may change such that the per family error rate is calculated
after SNPs failing this test have been removed. Also, using this command currently removes entire 
nuclear families on the basis of high Mendel error rates: it will often be more appropriate to 
remove particular individuals (e.g. if a second sibling shows no Mendel errors). 
For this more fine-grained procedure, use the --mendel option to generate a complete 
enumeration of error rates by family and individual and exclude individuals as desired. 
Finally, it is possible to zero out specific Mendelian inconsistencies with the option --set-me-missing. 
This should be used in conjunction with a data generation command and the --me option. 
Specifically, the --me parameters should be both to 1, in order not to exclude any particular 
SNP or individual/family, but instead to zero out only specific genotypes with Mendel errors and save 
the dataset as a new file. (Both parental and offspring genotypes will be set to missing.)'


plink --bfile malaria_senegal_clean_1 --me 1 1 --set-me-missing --make-bed --out malaria_senegal_clean

: 'remove intermediate files '
rm malaria_senegal_clean_1*

: 'matrice GRM based on the autosomal chromosomes'
gcta64  --bfile malaria_senegal_clean  --autosome  --make-grm  --out grm_matrix

: 'Generating the PCs from the GRM Matrix'
gcta64  --grm grm_matrix  --pca 20  --out principal_components

: 'Performing GWAS with a quantitative trait'
plink --bfile malaria_senegal_clean --pheno malaria_senegal.phen --linear  --covar principal_components.eigenvec --covar-number 1,2 --out gwas_cov_pca

# plink --bfile malaria_senegal_clean --pheno malaria_senegal.phen --linear --mpheno 1 --covar principal_components.eigenvec --covar-number 1,2 --out gwas_cov_pca



#****************************
# STATISTICS ****************
#****************************
: 'Missingness per individual & Missingness per marker'
plink --bfile malaria_senegal_clean --missing  --out malaria_senegal_clean

: 'Allele frequency'
plink --bfile malaria_senegal_clean --freq  --out malaria_senegal_clean

: 'Hardy-Weinberg equilibrium'
plink --bfile malaria_senegal_clean --hardy  --out malaria_senegal_clean


#***************************
: 'Unbinarize and transpose malaria_senegal bfile [ NEW ]' 
plink --bfile malaria_senegal_clean --recode transpose --tab  --out malaria_senegal_clean

: 'Counting genotype frequencies per SNP [ NEW ]'
python genotype_frequences.py --tped malaria_senegal_clean.tped --frq malaria_senegal_clean.frq


: 'Merge GWAS results, statistics and annotation'
Rscript compile_results.R --dir "$(pwd)"


: 'Draw the Manhattan and the Q-Q plots'
Rscript Manhattan_and_QQ_plots.R

open Rplots.pdf
open Rplots1.pdf
