library(car)
#simple Model (starting with variables we thought would be important)
LogModelSimple=glm(typeDummyVar~game_seconds_remaining+half_seconds_remaining+down+ydstogo+yardline_100+score_differential+posteam_timeouts_remaining,
                   data=train,family = binomial(link="logit"))
#More general Model (All pre-play numeric variables as predictors)
LogModel=glm(typeDummyVar~.,data=train,family = binomial(link="logit"))
#check variables for colinearity
summary(LogModel)
Cor_Matrix=cor(NumericalData[,c("score_differential","qtr","game_seconds_remaining")],NumericalData)
  #high correlation between game_half,drive,qtr
  #drive has highest significance
  #co linearity issues with including score_diff and posteam_score/defteam_score
#updated Log Model
LogModel=glm(typeDummyVar~.-game_half-qtr-posteam_score-defteam_score,data=train,family = binomial(link="logit"))
#Results/confusion matrix
pred=predict(LogModel,newdata=test)
roundedPred=round(pred)
confusion_matrix=table(roundedPred, test$typeDummyVar)
confusion_matrix
#Calculate accuracy
accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
accuracy

#Compare fit of Models
  #Nested F Test
    #doing something wrong???
df1 <- df.residual(LogModel)
df2 <- df.residual(LogModelSimple)
sse1 <- sum(resid(LogModel)^2)
sse2 <- sum(resid(LogModelSimple)^2)
sse_diff <- sse2 - sse1
df_diff <- df1 - df2
f_statistic <- (sse_diff / df_diff) / (sse1 / df1)
p_value <- pf(f_statistic, df_diff, df1, lower.tail = FALSE)# Error Producing NaNs

  #Drop in Deviance
deviance_table <- anova(LogModel, LogModelSimple)
drop_in_deviance <- deviance_table$Deviance[1] - deviance_table$Deviance[2]#Full Model deviance is NA? something wrong with larger Model?



