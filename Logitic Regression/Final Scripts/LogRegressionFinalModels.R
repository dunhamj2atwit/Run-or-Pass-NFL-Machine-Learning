#Final Log Regression Models
#Final Models
predvars=BestOrder[1]
for (i in 2:17){
  predvars<-paste(predvars,BestOrder[i],sep="+")
}
FormulaComplex<-as.formula(paste("typeDummyVar~",predvars,sep=""))
FinalModelComplex <- glm(FormulaComplex,data=train,family= binomial(link="logit"))
FinalModelSimple <- glm(typeDummyVar~shotgun+first_down_pass+first_down_rush,data=train,family= binomial(link="logit"))

FinalACC <- vector("numeric",2)
mathewsCCFinal <- vector("numeric",2)
loglikeFinal <- vector("numeric",2)

finalModelpredComplex <- round(predict(FinalModelComplex,newdata = test,type="response"))
FinalACC[1] <- sum(finalModelpredComplex==test$typeDummyVar)/nrow(test)

finalModelpredSimple <- round(predict(FinalModelSimple,newdata = test,type="response"))
FinalACC[2] <- sum(finalModelpredSimple==test$typeDummyVar)/nrow(test)

finalcmComplex=table(finalModelpredComplex,test$typeDummyVar)
TP=as.integer64(finalcmComplex[1,1])
FP=as.integer64(finalcmComplex[2,1])
FN=as.integer64(finalcmComplex[1,2])
TN=as.integer64(finalcmComplex[2,2])
mathewsCCFinal[1]=mcc(TP,FP,TN,FN)

finalcmSimple=table(finalModelpredSimple,test$typeDummyVar)
TP=as.integer64(finalcmSimple[1,1])
FP=as.integer64(finalcmSimple[2,1])
FN=as.integer64(finalcmSimple[1,2])
TN=as.integer64(finalcmSimple[2,2])
mathewsCCFinal[2]=mcc(TP,FP,TN,FN)

predicted_probsFinalComplex <- FinalModelComplex$fitted.values
loglikeFinal[1]=sum(train$typeDummyVar * log(predicted_probsFinalComplex) + (1 - train$typeDummyVar) * log(1 - predicted_probsFinalComplex))

predicted_probsFinalSimple <- FinalModelSimple$fitted.values
loglikeFinal[2]=sum(train$typeDummyVar * log(predicted_probsFinalSimple) + (1 - train$typeDummyVar) * log(1 - predicted_probsFinalSimple))

FinalResults=data.frame(Type = c("Complex Model","Simple Model"), Accuracy=FinalACC, Mathews_Correlation_Coefficient = mathewsCCFinal,Log_Likelihood=loglikeFinal, AIC = c(FinalModelComplex$aic,FinalModelSimple$aic))
