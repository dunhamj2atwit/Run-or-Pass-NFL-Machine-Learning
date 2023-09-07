library(neuralnet)
library(gtools)
library(gridExtra)
samp<-sample(nrow(normtrain),size=(floor(nrow(normtrain)/50)), replace=FALSE)
normtrainSample<-normtrain[samp,]

#elem <- 1:4
#perms <- permutations(4, 2, elem)
#layers <- list(1,2,3,4,perms[1,],perms[2,],perms[3,],perms[4,],perms[5,],perms[6,],
               #perms[7,],perms[8,],perms[9,],perms[10,],perms[11,],perms[12,])
layers<-list(c(1),c(2),c(10),c(30),c(1,1),c(2,2),c(10,10),c(30,30))

#ACCComplex <- vector("numeric",length(layers))
#ACCSimple <- vector("numeric",length(layers))
  #all vars
  StartT<-proc.time()
  i=1
    nnComplex<-neuralnet(typeDummyVar~.,
                         data=normtrainSample,
                         hidden=layers[[i]],
                         linear.output = FALSE, 
                         act.fct = "logistic",
                         stepmax=1e7)
    pred<-round(predict(nnComplex,newdata=normtest))
    CM<-table(pred,normtest$typeDummyVar)
    ACCComplex[i]<-sum(diag(CM))/sum(CM)
  print(ACCComplex[i])
  print(proc.time()-StartT)
  
#softplus <- function(x) log(1+exp(x))
#relu <- function(x) sapply(x, function(z) max(0,z))
  
ACCSimple <- vector("numeric",8)
ACCSimple4 <- vector("numeric",8)
ACCSimple6 <- vector("numeric",8)
for (i in 1:length(layers)){
  #important vars
  StartT<-proc.time()
  print(layers[[i]])
    nnSimple<-neuralnet(typeDummyVar~.,#shotgun+first_down_pass+first_down_rush,
                        data=normtrainSample,
                        hidden=layers[[i]],
                        linear.output = FALSE, 
                        act.fct = "logistic",
                        stepmax=1e7)
    #plot(nnSimple)
    pred<-predict(nnSimple,newdata=normtest)
    print(pred[1:20])
    roundPred<-round(pred)
    roundPred4<-ifelse(pred<=0.4,0,1)
    roundPred6<-ifelse(pred<=0.6,0,1)
    roundPred<-round(pred)
    CM<-table(roundPred,normtest$typeDummyVar)
    CM4<-table(roundPred4,normtest$typeDummyVar)
    CM6<-table(roundPred6,normtest$typeDummyVar)
    #print(CM)
    ACCSimple[i]<-sum(diag(CM))/sum(CM)
    ACCSimple4[i]<-sum(diag(CM4))/sum(CM4)
    ACCSimple6[i]<-sum(diag(CM6))/sum(CM6)
  print(ACCSimple[i])
  print(ACCSimple4[i])
  print(ACCSimple6[i])
  print(proc.time()-StartT)
}


NNResults<-data.frame(Layers=c('1','2','10','30','1,1','2,2','10,10','30,30'),Accuracy=ACCSimple)
grid.table(NNResults)
