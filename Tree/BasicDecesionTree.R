library(tree)
#use training/testing split from ldataProcessing
#Tree 1(variables we picked)
treeModel=tree(typeDummyVar~
               game_seconds_remaining+half_seconds_remaining+down+ydstogo+yardline_100+score_differential+posteam_timeouts_remaining,
               data=train)
plot(treeModel)
text(treeModel,pretty=1)
TreePred=predict(treeModel,newdata=test)
TreeCM=table(TreePred>0.5,test$typeDummyVar)
TreeCM
TreeAcc=sum(diag(TreeCM)) / sum(TreeCM)
TreeAcc
#Cv for deciding complexity
cv.tree=cv.tree(treeModel)
plot(cv.tree$size,cv.tree$dev,type="b")
#min error at highest complexity, no pruning needed.

#Tree 2
#with all numeric variables to explore other features
treeModel=rpart(typeDummyVar~.-shotgun,
               data=train,method='class',cp=0.01)
plot(treeModel)
text(treeModel,pretty=1,cex=1.75)
TreePred=predict(treeModel,newdata=test,type="class")
TreeCM=table(TreePred,test$typeDummyVar)
TreeCM
TreeAcc=sum(diag(TreeCM)) / sum(TreeCM)
TreeAcc
#Cv for deciding complexity
cv.tree=cv.rpart(treeModel)
plot(cv.tree$size,cv.tree$dev,type="b")
#min error at highest complexity, no pruning needed.