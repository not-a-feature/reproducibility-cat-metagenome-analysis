data_all <- read.csv("contig_size")
data_400 <- read.csv("contig_filtered")
data_400_cdhit <- read.csv("contig_filtered_cdhit")


data <- c(data_all, data_400, data_400_cdhit)
options(scipen=999)
par(mar = c(2.5, 4, 2, 4)) 
boxplot(data, log = "y",
        names=c("All contings", "Excluding < 400", "< 400 + cd-hit-est"),
        main="Contig size",
        yaxt='n')
axis(side=2,at=c(200, 463,759,883,1505,375251), las=1)
axis(side=4,at=c(400,811,1652, 375251), las=1)