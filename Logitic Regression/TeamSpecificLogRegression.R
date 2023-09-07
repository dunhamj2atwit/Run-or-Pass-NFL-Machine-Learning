#log regression Models separate for each team

#create teams list
 #NOTE-Teams that have relocated during this time are new teams here-could be changed??
teams=unique(playData$posteam)
teamsAcc=vector(mode = "numeric", length = 35)
#seed for sampling
set.seed(4444)
#for loop for each team
for (i in teams){
  #team Specific Dataset
  TeamPlayData=playData[playData$posteam==i,]
  #split
  sample=sample(seq_len(nrow(TeamPlayData)),size=floor(nrow(TeamPlayData)*.75))
  train=TeamPlayData[sample,]
  test=TeamPlayData[-sample,]
  #create Model
  TeamModel=glm(typeDummyVar~
                 game_seconds_remaining+half_seconds_remaining+down+ydstogo+yardline_100+score_differential+posteam_timeouts_remaining,
               data=train)
  #Results
  TeamPred=predict(TeamModel,newdata=test)
  cm=table(TeamPred > 0.5, test$typeDummyVar)
  accuracy <- sum(diag(cm)) / sum(cm)
  #add to table
  n=which(teams==i)
  teamsAcc[n]=accuracy
}
Results=data.frame(Teams=teams,Accuracy=teamsAcc)
Results
