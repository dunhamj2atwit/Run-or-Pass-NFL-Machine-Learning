library(class)
#ran for
#K=c(1:30,seq(31,101,by=2),seq(105,300,by=5))
K=c(seq(1,30,by=5),seq(31,101,by=4),seq(105,300,by=5))
Accuracy<-vector("numeric",length(K))
MCC<-vector("numeric",length(K))

for (K in K){
startT<-proc.time()
  knnpr<-knn(normtrain[-23],normtest[-23],cl=normtrain$typeDummyVar,k=K)
  CM<-table(knnpr,normtest$typeDummyVar)
  TP=as.integer64(CM[1,1])
  FP=as.integer64(CM[2,1])
  FN=as.integer64(CM[1,2])
  TN=as.integer64(CM[2,2])
  MCC[K]=mcc(TP,FP,TN,FN)
  Accuracy[K]<-sum(diag(CM))/sum(CM)
print(K)
print(Accuracy[K])
print(proc.time()-startT)
}

KNNResults<-data.frame(K=K,Accuracy=Accuracy,MCC=MCC)
plot(KNNResults$K,KNNResults$Accuracy,main="K vs. Accuracy",xlab="K",ylab="Accuracy")
#cleaner plot
kplot<-c(seq(1,30,by=5),seq(31,101,by=4),seq(105,300,by=5))
ACCplot<-KNNResults$Accuracy[which(KNNResults$K %in% kplot)]
plot(kplot,ACCplot,main="K vs. Accuracy",xlab="K",ylab="Accuracy")

k=5

n <- nrow(normtrain)
shuffled_indices <- sample(n)
fold_size <- floor(n / k)

KNNfolds <- lapply(1:k, function(i) {
  start <- (i - 1) * fold_size + 1
  end <- i * fold_size
  normtrain[shuffled_indices[start:end], ]
})

ACCMatrix<-matrix(0,nrow=51,ncol=k+1)
for (i in 1:k){
  Data=as.data.frame(KNNfolds[i])
  print(i)
  for (K in 50:100){
    startT<-proc.time()
    index=which(50:100==K)
    knnpr<-knn(Data[-27],normtest[-27],cl=Data$typeDummyVar,k=K)
    CM<-table(knnpr,normtest$typeDummyVar)
    ACCMatrix[index,i]<-sum(diag(CM))/sum(CM)
    print(K)
    print(ACCMatrix[index,i])
    print(proc.time()-startT)
  }
}
for (j in 1:length(50:100)){
  ACCMatrix[j,6]=sum(ACCMatrix[j,])/5
}
plot(50:100,ACCMatrix[,6],main="K vs. Accuracy (5 fold CV)",xlab="K",ylab="Accuracy Average")

BestK<-50+which(ACCMatrix[,6]==max(ACCMatrix[,6]))-1
knnFinal<-knn(normtrain[-23],normtest[-23],cl=normtrain$typeDummyVar,k=BestK+1)
CM<-table(knnFinal,normtest$typeDummyVar)
FinalAccuracy<-sum(diag(CM))/sum(CM)
print(FinalAccuracy)
TP=as.integer64(CM[1,1])
FP=as.integer64(CM[2,1])
FN=as.integer64(CM[1,2])
TN=as.integer64(CM[2,2])
FinalMCC<-mcc(TP,FP,TN,FN)



