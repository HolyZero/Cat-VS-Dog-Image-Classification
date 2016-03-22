setwd("~/Documents/cycle3cvd-team-6")
check <- read.table(file = "data/annotations/list.txt", sep = " ", skip = 5)

ind <- as.factor(check[,3])
summary(ind)
save(ind, file = "data/index.RDS")
