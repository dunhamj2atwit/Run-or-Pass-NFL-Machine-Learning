Predictors<-setdiff(colnames(train),c(colinVars,"typeDummyVar"))
#collinearity in DataProcessing.R
BestOrder<-character()

TotalPreds<-length(Predictors)
Results<-vector("list",TotalPreds)
for (P in 1:TotalPreds){
  print(P)
  accuracy<-vector("numeric",length(Predictors))
  
  for (i in 1:length(Predictors)){
    #define formula
    independantVars<-Predictors[i]
      if(P>1){
        for (j in 2:P){
        independantVars<-paste(independantVars,BestOrder[j-1],sep="+")
      }}
    Formula<-as.formula(paste("typeDummyVar~",independantVars,sep=""))
    #print(Formula)
    #Model
    Model<-glm(formula = Formula,data=train,family=binomial(link="logit"))
    pred=round(predict(Model,newdata = test,type="response"))
    accuracy[i]=sum(pred==test$typeDummyVar)/nrow(test)
  }
#update
index<-which(accuracy==max(accuracy))
#print(length(index))
  if(length(index)>1){
    index<-sample(index,1)
  }
BestOrder<-append(BestOrder,Predictors[index])
  BestOrderVec<-BestOrder
  PredictorsVec<-Predictors
  accuracyVec<-accuracy
  if(length(Predictors)>=length(BestOrder)){
    BestOrderVec<-c(BestOrder,rep("Empty",times=abs(length(PredictorsVec)-length(BestOrderVec))))
  }else{
    PredictorsVec<-c(Predictors,rep("Empty",times=abs(length(PredictorsVec)-length(BestOrderVec))))
    accuracyVec<-c(accuracy,rep(0,times=abs(length(Predictors)-length(BestOrder))))
  }
Results[[P]]<-data.frame(Best_Order=BestOrderVec,Predictors=PredictorsVec,Accuracy=accuracyVec)
#print(length(BestOrder))
Predictors = Predictors[-c(which(Predictors==BestOrder[P]))]
#print(length(Predictors))
}

FinalACC<-vector("numeric",length(BestOrder))
for (j in 1:length(BestOrder)){
  FinalACC[j]=max(Results[[j]]$Accuracy)
}
FinalResults<-data.frame(Variable_Added=BestOrder,Accuracy=FinalACC)
FinalTable<-grid.table(FinalResults)


BestOrder<-c("shotgun","first_down_pass","first_down_rush","goal_to_go","isHome","drive","ydsnet","posteam_timeouts_remaining",
             "score_differential","down","ydstogo","defteam_timeouts_remaining","game_half","yardline_100","first_down_penalty",
             "no_huddle","fourth_down_converted","third_down_converted","quarter_seconds_remaining","half_seconds_remaining","P2R",
             "third_down_failed")
