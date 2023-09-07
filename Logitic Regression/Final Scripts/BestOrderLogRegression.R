#Run after forwardSelection for expanded results
ModelData<-train[c("typeDummyVar",BestOrder[1])]
otherVars<-BestOrder[-1]

accuracy <- vector("numeric",length(otherVars)+1)
mathewsCC <- vector("numeric",length(otherVars)+1)
LogLikelihood=vector("numeric",length(otherVars)+1)
AIC=vector("numeric",length(otherVars)+1)
drop_in_deviance <- vector("numeric",length(otherVars)+1)
drop_in_deviance[1]=NA
P_value=vector("numeric",length(otherVars)+1)
P_value[1]=NA 

#iterate through variables
for (i in otherVars){
  #index
  print(which(otherVars==i))
  index=which(otherVars==i)
  #create Models
  Model1=glm(typeDummyVar~.,data=ModelData, family = binomial(link="logit"))
  ModelData=cbind(ModelData,train[i])
  Model2=glm(typeDummyVar~.,data=ModelData, family = binomial(link="logit"))
  #calculate accuracy
  pred=round(predict(Model1,newdata = test,type="response"))
  accuracy[index]=sum(pred==test$typeDummyVar)/nrow(test)
  #Mathews correlation coefficient
  cm=table(pred,test$typeDummyVar)
  #convert to integer64 for overflow issues
  TP=as.integer64(cm[1,1])
  FP=as.integer64(cm[2,1])
  FN=as.integer64(cm[1,2])
  TN=as.integer64(cm[2,2])
  mathewsCC[index]=mcc(TP,FP,TN,FN)
  #calculate drop in deviance
  drop_in_deviance[index+1]=deviance(Model1)-deviance(Model2)
  #log-Likelihood
  predicted_probs1 <- Model1$fitted.values
  loglike1=sum(ModelData$typeDummyVar * log(predicted_probs1) + (1 - ModelData$typeDummyVar) * log(1 - predicted_probs1))
  LogLikelihood[index]=loglike1   
  P_value[index+1] <- 1 - pchisq(drop_in_deviance[index+1], df=1)#some are =0, Precision issue???
  #AIC
  AIC[index]=Model1$aic
}
#fill in for final models
#last model acc
finalpred=round(predict(Model2,newdata = test,type="response"))
accuracy[length(otherVars)+1]=sum(finalpred==test$typeDummyVar)/nrow(test)
#last model mcc
cm=table(finalpred,test$typeDummyVar)
#convert to integer64 for overflow issues
TP=as.integer64(cm[1,1])
FP=as.integer64(cm[2,1])
FN=as.integer64(cm[1,2])
TN=as.integer64(cm[2,2])
mathewsCC[length(otherVars)+1]=mcc(TP,FP,TN,FN)
#Last Model Log-like
predicted_probs2 <- Model2$fitted.values
LogLikelihood[length(otherVars)+1]=sum(ModelData$typeDummyVar * log(predicted_probs2) + (1 - ModelData$typeDummyVar) * log(1 - predicted_probs2))
#Last Model AIC
AIC[length(otherVars)+1]=Model2$aic
#dataframe to view results
LogResults=data.frame(Added_Variable=BestOrder,Accuracy=accuracy,Mathews_Correlation_Coefficient=mathewsCC,
                      Log_Likelihood=LogLikelihood,AIC=AIC,Test_statistic_and_Drop_in_Deviance=drop_in_deviance,P_Value=P_value)

