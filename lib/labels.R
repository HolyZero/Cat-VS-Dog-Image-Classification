dir_images <- "/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/images"
setwd(dir_images)
dir_names <- list.files(dir_images)

breed_name <- rep(NA, length(dir_names))
for(i in 1:length(dir_names)){
  tt <- unlist(strsplit(dir_names[i], "_"))
  tt <- tt[-length(tt)]
  breed_name[i] = paste(tt, collapse="_", sep="")
}
cat_breed <- c("Abyssinian", "Bengal", "Birman", "Bombay", "British_Shorthair", "Egyptian_Mau",
               "Maine_Coon", "Persian", "Ragdoll", "Russian_Blue", "Siamese", "Sphynx")

iscat <- breed_name %in% cat_breed
y_cat <- as.numeric(iscat)
a <- dir_names
extension <- substr(a,nchar(a)-3,nchar(a))
mat <- which(extension==".mat")

corrupt <- c("Abyssinian_5.jpg",
             "Abyssinian_34.jpg",
             "Egyptian_Mau_14.jpg",
             "Egyptian_Mau_139.jpg",
             "Egyptian_Mau_145.jpg",
             "Egyptian_Mau_156.jpg",
             "Egyptian_Mau_167.jpg",
             "Egyptian_Mau_177.jpg",
             "Egyptian_Mau_186.jpg",
             "Egyptian_Mau_191.jpg",
             "Egyptian_Mau_129.jpg",
             "staffordshire_bull_terrier_2.jpg" ,
             "staffordshire_bull_terrier_22.jpg")

corrupt.index <- which(dir_names %in% corrupt)
bad.index <- c(mat,corrupt.index)*-1

names <- dir_names[bad.index]
labels <- y_cat[bad.index]

data <- data.frame(names=names,lables=labels)
write.csv(data, "/Users/JPC/Documents/Columbia/2nd Semester/1. Applied Data Science/2. Homeworks/Project 3/cycle3cvd-team-6/data/labels.csv")

# write(dir_names,"names.txt",sep="\n")
# write(y_cat,"class.txt", sep="\n")





