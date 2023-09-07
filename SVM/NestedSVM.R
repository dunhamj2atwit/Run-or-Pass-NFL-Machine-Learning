indices <- sample(nrow(SVMTrain),size=(floor(nrow(SVMTrain)/10)), replace=FALSE)
SVMTrainSample <- SVMTrain[indices,]
SVMTrainSample$typeDummyVar=as.factor(SVMTrainSample$typeDummyVar)
ModelData<-data.frame(typeDummyVar=SVMTrainSample["typeDummyVar"])

Accuracy<-vector("numeric",length(BestOrder))
MCC<-vector("numeric",length(BestOrder))
BestCost<-MCC<-vector("numeric",length(BestOrder))
for (i in 1:length(BestOrder)){
  print(i)
  ModelData<-cbind(ModelData,SVMTrainSample[BestOrder[i]])
  #linear kernel for speed, Radial basis with grid search could give better results
  StartT<-proc.time()
  SVMTune <- tune(svm, typeDummyVar~.,data=ModelData, 
                  type = "C-classification", kernel="linear",
                  ranges = list(cost = c(0.0001,0.001,0.01)),
                  tunecontrol = tune.control(sampling = "cross",cross=5,best.model = TRUE,performances = TRUE))
  
  step<-as.numeric(SVMTune$best.parameters[1]/2)
  Best1<-as.numeric(SVMTune$best.parameters[1])
  Cost2<-seq(Best1-step,Best1+step,by=step)
  
  #step<-as.numeric(SVMTune$best.parameters[1]/3)
  #Best1<-as.numeric(SVMTune$best.parameters[1])
 # Cost2<-seq(Best1-3*step,Best1+3*step,by=step)[-1]
  
  SVMTune2 <- tune(svm, typeDummyVar~.,data=ModelData, 
                  type = "C-classification", kernel="linear",
                  ranges = list(cost = Cost2),
                  tunecontrol = tune.control(sampling = "cross",cross=5,best.model = TRUE,performances = TRUE))
  
  BestCost[i]<-as.numeric(SVMTune2$best.parameters)
  print(BestCost[i])
  predictions <- predict(SVMTune2$best.model, SVMTest)
  Accuracy[i] <- sum(predictions == SVMTest$typeDummyVar) / nrow(SVMTest)
  CM <- table(predictions,SVMTest$typeDummyVar)
  TP=as.integer64(CM[1,1])
  FP=as.integer64(CM[2,1])
  FN=as.integer64(CM[1,2])
  TN=as.integer64(CM[2,2])
  MCC[i] <-  mcc(TP,FP,TN,FN)
  print(proc.time()-StartT)
}
NestedSVMResults<-data.frame(Added_Feature=BestOrder,accuracy=Accuracy)
