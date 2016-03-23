
# TEST FUNCTION
# _________________________________________________________________________________________________

test <- function(models,features){
  base.model <- models$baseline 
  adv.model <- models$adv
  names.base <- subset(names(features),substr(names(features),1,1)=="b")
  names.adv <- subset(names(features),substr(names(features),1,1)=="n")
  features.base <- features[,names.base]
  features.adv <- features[,names.adv]
  base.prediction <- predict (base.model,features.base)
  adv.prediction <- predict(adv.model,features.adv)
    return(list(baseline=base.prediction,adv=adv.prediction))
}

#   predicition <- test(models = model,features = features)





