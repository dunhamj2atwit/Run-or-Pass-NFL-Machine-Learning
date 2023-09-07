library(caret)
library(rpart)
#function for Mathew Correlation Coefficient
mcc <- function(TP,FP,TN,FN){
  #calculate Coefficient
  num=(TP*TN-FP*FN)
  den=sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN))
  mathewsCC <- num/den
  return(mathewsCC)
}

#initialize alpha vector
alpha=seq(0.00005,0.015, by=0.00005)
# Split the data into k folds
k=5

n <- nrow(train)
shuffled_indices <- sample(n)
fold_size <- floor(n / k)

folds <- lapply(1:k, function(i) {
  start <- (i - 1) * fold_size + 1
  end <- i * fold_size
  train[shuffled_indices[start:end], ]
})

#initialize results
ResultMatrix=matrix(0,nrow=length(alpha),ncol=k+1)

for (K in 1:k){
  print(K)
  for (a in alpha){
    #print(a)
    Data=as.data.frame(folds[K])
    Tree=rpart(typeDummyVar~.,data=Data,method="class",cp=a)
    
    TreePred=predict(Tree,newdata=test,type="class")
    TreeCM=table(TreePred,test$typeDummyVar)
    TP=as.integer64(TreeCM[1,1])
    FP=as.integer64(TreeCM[2,1])
    FN=as.integer64(TreeCM[1,2])
    TN=as.integer64(TreeCM[2,2])
    
    ResultMatrix[which(alpha==a),K]=
      mcc(TP,FP,TN,FN)
      #sum(Tree$cptable[,"xerror"])/length(Tree$cptable[,"xerror"])#gini impurity average here???
    print(ResultMatrix[which(alpha==a),K])
  }
}

for (i in 1:length(alpha)){
  #average value for k folds
  ResultMatrix[i,k+1]=sum(ResultMatrix[i,])/k
}
#plot values
plot(ResultMatrix[1:200,6]~alpha[1:200],xlab="Alpha",ylab="Averge MCC",main= "Alpha vs. Average MCC",axes=FALSE)
axis(1, at = seq(-0.1, 0.1, by = 0.001))
axis(2, at = seq(.56, 0.63, by = 0.01))
#pick alpha/make tree
bestIndex=which(ResultMatrix[,6]==max(ResultMatrix[,6]))
bestAlpha=alpha[bestIndex]
BestTree=rpart(typeDummyVar~.,data=train,method="class",cp=bestAlpha)

plot(BestTree)
text(BestTree,pretty=1,cex = 0.7)

BaseTree <-rpart(typeDummyVar~.,data=train,method="class")
plot(BaseTree)
text(BaseTree,pretty=1)


TreePred=predict(BestTree,newdata=test,type="class")
TreeCM=table(TreePred,test$typeDummyVar)
TP=as.integer64(TreeCM[1,1])
FP=as.integer64(TreeCM[2,1])
FN=as.integer64(TreeCM[1,2])
TN=as.integer64(TreeCM[2,2])
mcc(TP,FP,TN,FN)
sum(diag(TreeCM))/sum(TreeCM)
