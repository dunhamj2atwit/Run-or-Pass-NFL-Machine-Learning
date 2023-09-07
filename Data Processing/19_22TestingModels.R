#Testing Models on Future Data
library(rpart)
library(e1071)
library(class)
library(bit64)
mcc <- function(TP,FP,TN,FN){
  #calculate Coefficient
  num=(TP*TN-FP*FN)
  den=sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN))
  mathewsCC <- num/den
  return(mathewsCC)
}
#MCCs have overflow issues: done in desmos
#best Models of each type
LogRegress <- glm(typeDummyVar~shotgun+first_down_pass+first_down_rush,data=normtrain,family= binomial(link="logit"))
BestTree=rpart(typeDummyVar~.,data=normtrain,method="class",cp=0.0003)
  indices <- sample(nrow(normtrain),size=(floor(nrow(normtrain)/10)), replace=FALSE)
  SVMTrainSample <- normtrain[indices,]
  SVMTrainSample$typeDummyVar=as.factor(SVMTrainSample$typeDummyVar)
SVMFinal <- svm(typeDummyVar~.,data=SVMTrainSample, type = "C-classification", kernel="radial",cost=1.5,gamma=0.075)
#Results
LogPred<-round(predict(LogRegress,newdata=normdf19_22,type="response"))
  LogCM=table(LogPred,normdf19_22$typeDummyVar)
  TP=as.integer64(LogCM[1,1])
  FP=as.integer64(LogCM[2,1])
  FN=as.integer64(LogCM[1,2])
  TN=as.integer64(LogCM[2,2])
  #LogMCC<-mcc(TP,FP,TN,FN)
  LogMCC<-0.5818326
  LogACC<-sum(diag(LogCM))/sum(LogCM)
  
TreePred<-predict(BestTree,newdata=normdf19_22,type="class")
  TreeCM=table(TreePred,normdf19_22$typeDummyVar)
  TP=as.integer64(TreeCM[1,1])
  FP=as.integer64(TreeCM[2,1])
  FN=as.integer64(TreeCM[1,2])
  TN=as.integer64(TreeCM[2,2])
  #TreeMCC<-mcc(TP,FP,TN,FN)
  TreeMCC<-0.561271282554
  TreeACC<-sum(diag(TreeCM))/sum(TreeCM)
  
SVMPred<-predict(SVMFinal,newdata=normdf19_22)
  SVMCM=table(SVMPred,normdf19_22$typeDummyVar)
  TP=as.integer64(SVMCM[1,1])
  FP=as.integer64(SVMCM[2,1])
  FN=as.integer64(SVMCM[1,2])
  TN=as.integer64(SVMCM[2,2])
  #SVMMCC<-mcc(TP,FP,TN,FN)
  SVMMCC<-0.590020197366
  SVMACC<-sum(diag(SVMCM))/sum(SVMCM)
  
knnpr<-knn(normtrain[-23],normdf19_22[-23],cl=normtrain$typeDummyVar,k=85)
  KNNCM<-table(knnpr,normdf19_22$typeDummyVar)
  TP=as.integer64(KNNCM[1,1])
  FP=as.integer64(KNNCM[2,1])
  FN=as.integer64(KNNCM[1,2])
  TN=as.integer64(KNNCM[2,2])
  #KNNMCC=mcc(TP,FP,TN,FN)
  KNNMCC=0.589674656485
  KNNACC<-sum(diag(KNNCM))/sum(KNNCM)

Results19_22<-data.frame(Model=c("Logistic Regression","Decesion Tree","Support Vector Machine","KNN"),Accuracy=c(LogACC,TreeACC,SVMACC,KNNACC),MCC=c(LogMCC,TreeMCC,SVMMCC,KNNMCC))  
grid.table(Results19_22)

#Current Results
Results<-data.frame(Model=c("Logistic Regression","Decesion Tree","Support Vector Machine","KNN"),Accuracy=c(0.7963272,0.8166368,0.8030678,0.8020259),MCC=c(0.5859592,0.6222394,0.5980614,0.5953208))  
grid.table(Results)



