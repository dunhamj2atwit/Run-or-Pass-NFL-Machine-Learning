library(e1071)
library(bit64)
#function for Mathew Correlation Coefficient
mcc <- function(TP,FP,TN,FN){
  #calculate Coefficient
  num=(TP*TN-FP*FN)
  den=sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN))
  mathewsCC <- num/den
  return(mathewsCC)
}

#Data setup
SVMTrain<-normtrain
SVMTest<-normtest
SVMTest$typeDummyVar[which(SVMTest$typeDummyVar==0)]=-1
SVMTrain$typeDummyVar[which(SVMTrain$typeDummyVar==0)]=-1
#split into k folds
k=5

n <- nrow(SVMTrain)
shuffled_indices <- sample(n)
fold_size <- floor(n / k)

SVMfolds <- lapply(1:k, function(i) {
  start <- (i - 1) * fold_size + 1
  end <- i * fold_size
  SVMTrain[shuffled_indices[start:end], ]
})
#intialize cost vector/result matrices
Kernel<-c("linear", "polynomial", "radial","sigmoid")
ACCMatrix<-matrix(0,nrow=length(Kernel),ncol=k+1)
MCCMatrix<-matrix(0,nrow=length(Kernel),ncol=k+1)
for (K in 1:k){
  Data=as.data.frame(SVMfolds[K])
  #take subset for speed
  indices <- sample(nrow(Data),size=(floor(nrow(Data)/5)), replace=FALSE)
  Data <- Data[indices,]
  print(K)
  print(nrow(Data))
  for (i in 1:length(Kernel)){
    #Create Model
    StartT<-proc.time()
    SVMModel<-svm(typeDummyVar~.,data=Data, type = "C-classification", kernel=Kernel[i],cost=1)
    #Results
    predictions <- predict(SVMModel, SVMTest)
    #Accuracy
    ACCMatrix[i,K] <- sum(predictions == SVMTest$typeDummyVar) / nrow(SVMTest)
    #MCC
    CM1 <- table(predictions,SVMTest$typeDummyVar)
    TP=as.integer64(CM1[1,1])
    FP=as.integer64(CM1[2,1])
    FN=as.integer64(CM1[1,2])
    TN=as.integer64(CM1[2,2])
    MCCMatrix[i,K] <-  mcc(TP,FP,TN,FN)
    print(ACCMatrix[i,K])
    print(MCCMatrix[i,K])
    print(proc.time()-StartT)
  }
}
#Average Values
for (j in 1:length(Kernel)){
  ACCMatrix[j,k+1]=sum(ACCMatrix[j,])/k
  MCCMatrix[j,k+1]=sum(MCCMatrix[j,])/k
}
#results plots
x<-1:4
plot(ACCMatrix[,k+1]~x,main="Kernel Type vs Accuracy (subset of Data)",xlab="Kernel Type",ylab="Accuracy Ave over 5 Folds",axes=FALSE)
axis(2)
axis(1, at = 1:4,
     labels = Kernel)
plot(MCCMatrix[,k+1]~x,main="Kernel Type vs MCC (subset of Data)",xlab="Kernel Type",ylab="MCC Ave over 5 Folds")#axes=FALSE)
