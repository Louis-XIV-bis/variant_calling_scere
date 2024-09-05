#R script to get the values of parameters
#!/usr/bin/env Rscript

library(tibble)
library(tidyr)
library(lattice)
library(VennDiagram)


# TODO :: script à reprendre propre, bon header etc) 


annotations = read.table("../results/table_scores_merged.tsv", sep="\t", header=TRUE, na.strings=".") %>% 
  as_tibble() %>% 
  drop_na()
annotations

# num_rows_with_na <- annotation %>%
#   filter(if_any(everything(), is.na)) %>%
#   nrow()
# print(num_rows_with_na)
# = 245465

# Limits, for now the ones selected by Fanny for the 2349 data.
lim.QD = 10
lim.FS = 60
lim.MQ = 50
lim.MQRankSum = -12.5
lim.ReadPosRankSum = -8.0
lim.SOR = 3.0

## DISTRIBUTION
pdf(paste("./","FiltersDistrib.pdf",sep="_"), width= 12, height = 8)
par(mfrow=c(2,3))
plot(density(annotations$QD,na.rm=T),main=paste("QD , number of SNPs pre-filter = ",nrow(annotations),sep="") )
abline(v=lim.QD, col="red")
prop.QD=length( which(annotations$QD >lim.QD)) / nrow(annotations)
legend("top", c(paste("Filter: QD >",lim.QD,sep=""), 
                paste("Prop. pass filter = ", signif(prop.QD,3),sep="")),lty=1,col=c("red", "white"))

plot(density(annotations$FS,na.rm=T),main="FS")
abline(v=lim.FS, col="red")
prop.FS=length( which(annotations$FS <lim.FS)) / nrow(annotations)
legend("top", c(paste("Filter: FS <",lim.FS,sep=""), 
                paste("Prop. pass filter = ", signif(prop.FS,3),sep="")),lty=1,col=c("red", "white"))

plot(density(annotations$MQ,na.rm=T),main="MQ")
abline(v=lim.MQ, col="red")
prop.MQ=length( which(annotations$MQ >lim.MQ)) / nrow(annotations)
legend("top", c(paste("Filter: MQ >",lim.MQ,sep=""), 
                paste("Prop. pass filter = ", signif(prop.MQ,3),sep="")),lty=1,col=c("red", "white"))

plot(density(annotations$MQRankSum,na.rm=T),main="MQRankSum")
abline(v=lim.MQRankSum, col="red")
prop.MQRankSum=length( which(annotations$MQRankSum > lim.MQRankSum)) / sum(!is.na(annotations$MQRankSum))
legend("top", c(paste("Filter: MQRankSum >",lim.MQRankSum,sep=""), 
                paste("Prop. het. SNPs pass filter = ", signif(prop.MQRankSum,3),sep="")),lty=1,col=c("red", "white"))

plot(density(annotations$ReadPosRankSum,na.rm=T),main="ReadPosRankSum")
abline(v=lim.ReadPosRankSum, col="red")
prop.ReadPosRankSum=length( which(annotations$ReadPosRankSum >lim.ReadPosRankSum)) / sum(!is.na(annotations$ReadPosRankSum))
legend("top", c(paste("Filter: ReadPosRankSum >",lim.ReadPosRankSum, "Nb sites heterozyg =",sum(!is.na(annotations$ReadPosRankSum)),sep=""), 
                paste("Prop. het. SNPs pass filter = ", signif(prop.ReadPosRankSum,3),sep="")),lty=1,col=c("red", "white"))

plot(density(annotations$SOR,na.rm=T),main="SOR")
abline(v=lim.SOR, col="red")
prop.SOR=length( which(annotations$SOR <lim.SOR)) / nrow(annotations)
legend("top", c(paste("Filter: ReadPosRankSum <",lim.SOR,sep=""), 
                paste("Prop. pass filter = ", signif(prop.SOR,3),sep="")),lty=1,col=c("red", "white"))

dev.off()

### VENN DIAGRAM, intersect of filters
qd.pass = which(annotations$QD>lim.QD)
fs.pass = which(annotations$FS>lim.FS)
sor.pass = which(annotations$SOR > lim.SOR)
mq.pass = which(annotations$MQ < lim.MQ)
mqrs.pass= which(annotations$MQRankSum < lim.MQRankSum)
rprs.pass= which(annotations$ReadPosRankSum < lim.ReadPosRankSum)

x = venn.diagram(
  x=list(qd.pass, mq.pass,sor.pass,mqrs.pass,rprs.pass),
  category.names = c("QD" , "MQ", "SOR","MQRanksSum", "ReadPosRankSum"),
  fill = c("blue","darkgreen","orange","yellow","red"),
  output=TRUE,
  filename = "Venn_5params_Filters"
)
x
