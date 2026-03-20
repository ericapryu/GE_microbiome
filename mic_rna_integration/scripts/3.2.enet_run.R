# load packages
library(caret)
library(glmnet)
library(foreach)
library(doParallel)

# load in data
rna_indiv_corrected <- read.csv("../output/rna_indiv_corrected.csv", row.names = 1, header = TRUE)
micro_indiv_corrected <- read.csv("../output/micro_indiv_corrected.csv", row.names = 1, header = TRUE)

# set up parallel for loop
no_cores <- detectCores() - 1  
cl <- makeCluster(no_cores, type="FORK")  
registerDoParallel(cl)  

print(cl)

# get tuning parameters
get_best_result = function(caret_fit) {
  best = which(rownames(caret_fit$results) == rownames(caret_fit$bestTune))
  best_result = caret_fit$results[best, ]
  rownames(best_result) = NULL
  best_result <- as.data.frame(t(best_result))
}

# run
df_all <- foreach(i = colnames(micro_indiv_corrected)) %dopar% {
  # add microbe to df
  rna_mic <- rna_indiv_corrected
  rna_mic[, i] <- micro_indiv_corrected[, i]
  # build model
  control <- trainControl(method = "repeatedcv", 
                          number = 5, 
                          repeats = 5, 
                          search = "random", 
                          verboseIter = TRUE, 
                          allowParallel= TRUE) 
  # train model
  all_model <- train(as.formula(paste0("`", i, "`", "~ .")), 
                    data = rna_mic,
                    method = "glmnet", 
                    preProcess = c("center", "scale"), 
                    tuneLength = 25, 
                    trControl = control) 
  param <- get_best_result(all_model)
  colnames(param) <- i
  param[i]
  df <- as.data.frame.matrix(stats::predict(all_model$finalModel, type = "coefficients", s = all_model$bestTune$lambda))
  colnames(df) <- i
  df[i]
  return(list(param,df))
}

saveRDS(df_all, "../output/df_indiv.RDS")

stopCluster(cl)
