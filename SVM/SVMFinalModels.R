library(bit64)
library(e1071)
#subset training Data
indices <- sample(nrow(SVMTrain),size=(floor(nrow(SVMTrain)/10)), replace=FALSE)
SVMTrainSample <- SVMTrain[indices,]
SVMTrainSample$typeDummyVar=as.factor(SVMTrainSample$typeDummyVar)

SVMFinalBase <- svm(typeDummyVar~.,data=SVMTrainSample, type = "C-classification", kernel="radial")
  predictionsBase <- predict(SVMFinalBase, SVMTest)
  AccuracyBase <- sum(predictionsBase == SVMTest$typeDummyVar) / nrow(SVMTest)
  print(AccuracyBase)
  CMBase <- table(predictionsBase,SVMTest$typeDummyVar)
  print(CMBase)
  TP=as.integer64(CMBase[1,1])
  FP=as.integer64(CMBase[2,1])
  FN=as.integer64(CMBase[1,2])
  TN=as.integer64(CMBase[2,2])
  MCCBase <-  mcc(TP,FP,TN,FN)
  print(MCCBase)
  
  SVMTune <- tune(svm, typeDummyVar~.,data=SVMTrainSample, 
              type = "C-classification", kernel="radial",
              ranges = list(gamma = seq(0.65,0.75,by=0.05), cost = seq(1.5,1.6,by=0.025)),
              tunecontrol = tune.control(sampling = "cross",cross=5,best.model = TRUE,performances = TRUE))



StartT<-proc.time()
SVMFinal2 <- svm(typeDummyVar~.,#shotgun+first_down_pass+first_down_rush,
                 data=SVMTrainSample, type = "C-classification", kernel="radial",cost=1.5,gamma=0.075)
  predictions2 <- predict(SVMFinal2, SVMTest)
  Accuracy2 <- sum(predictions2 == SVMTest$typeDummyVar) / nrow(SVMTest)
  print(Accuracy2)
  CM2 <- table(predictions2,SVMTest$typeDummyVar)
  print(CM2)
  TP=as.integer64(CM2[1,1])
  FP=as.integer64(CM2[2,1])
  FN=as.integer64(CM2[1,2])
  TN=as.integer64(CM2[2,2])
  MCC2 <-  mcc(TP,FP,TN,FN)
  print(MCC2)
  print(proc.time()-StartT)
  