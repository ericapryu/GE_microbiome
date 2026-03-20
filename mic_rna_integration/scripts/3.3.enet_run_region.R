# load packages
library(caret)
library(glmnet)
library(foreach)
library(doParallel)

# load in data
rna_corr_TI <- read.csv("../output/rna_indiv_corrected_TI.csv", row.names = 1, header = TRUE)
micro_corr_TI <- read.csv("../output/micro_indiv_corrected_TI.csv", row.names = 1, header = TRUE)

rna_corr_C <- read.csv("../output/rna_indiv_corrected_C.csv", row.names = 1, header = TRUE)
micro_corr_C <- read.csv("../output/micro_indiv_corrected_C.csv", row.names = 1, header = TRUE)

rna_corr_RC <- read.csv("../output/rna_indiv_corrected_RC.csv", row.names = 1, header = TRUE)
micro_corr_RC <- read.csv("../output/micro_indiv_corrected_RC.csv", row.names = 1, header = TRUE)


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

# run TI
df_TI <- foreach(i = colnames(micro_corr_TI)) %dopar% {
  # add microbe to df
  rna_mic <- rna_corr_TI
  rna_mic[, i] <- micro_corr_TI[, i]
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

saveRDS(df_TI, "../output/df_TI.RDS")


# run C
df_C <- foreach(i = colnames(micro_corr_C)) %dopar% {
  # add microbe to df
  rna_mic <- rna_corr_C
  rna_mic[, i] <- micro_corr_C[, i]
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

saveRDS(df_C, "../output/df_C.RDS")


# run RC
df_RC <- foreach(i = colnames(micro_corr_RC)) %dopar% {
  # add microbe to df
  rna_mic <- rna_corr_RC
  rna_mic[, i] <- micro_corr_RC[, i]
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

saveRDS(df_RC, "../output/df_RC.RDS")

stopCluster(cl)
