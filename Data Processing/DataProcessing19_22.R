#Import/clean data, create new features, create dataframe of numerical inputs, split into test/training sets
#Resulting workspace saved in DataProcessing.RData (to skip running this script)

#this script includes 2019-2022 data for testing purposes
library(dplyr)
library(lubridate)
setwd("C:/Users/dunhamj2/Desktop/Research Coop/R_Files_For_Project")
Data19<-read.csv('play_by_play_2019.csv')
Data20<-read.csv('play_by_play_2020.csv')
Data21<-read.csv('play_by_play_2021.csv')
Data22<-read.csv('play_by_play_2022.csv')

playData=rbind(Data19,Data20,Data21,Data22)
rm(Data19)
rm(Data20)
rm(Data21)
rm(Data22)
#fix play Identifier column (contains many duplicates)
playData$play_id=1:nrow(playData)
#grab only run and pass plays
playData=playData[is.element(playData$play_type, c('pass','run')),]
#clean weird inputs
playData=playData[!(playData$two_point_attempt==1), ]
#dummy  response var
# pass=1, run=0
playData$typeDummyVar=ifelse(playData$play_type=='pass',1,0)
#change to numeric
playData$game_half=gsub("Overtime","3",playData$game_half)
playData$game_half=as.numeric(gsub("[Half]","",playData$game_half))


#additional feature creation
#seasonal dataframes (will help make other features)
YearVec=seq(2019,2022)
firstDayVec=c("2019-09-5","2020-09-10","2021-09-09","2022-09-08")

lastDayVec=c("2020-02-02","2021-02-07","2022-02-13","2023-02-12")
for (i in seq(1,4)){
  start_date=as.Date(firstDayVec[i])
  end_date=as.Date(lastDayVec[i])
  SeasonData=subset(playData, playData$game_date>=start_date)
  SeasonData=subset(SeasonData, SeasonData$game_date<=end_date)
  assign(paste("Data",as.character(YearVec[i]),sep=""),SeasonData)
}
rm(SeasonData)
#if possession team is at home or not
playData$isHome=ifelse(playData$home_team==playData$posteam,1,0)

#Teams Run to pass ratio (for current season)
#season/teams lists
SeasonDataList=list(Data2019,Data2020,Data2021,Data2022)
teams=unique(playData$posteam)
#remove before rerun
rm(P2R)
rm(play_id)
#initialize list for P2R ratio
P2R=vector("list")
play_id=vector("list")
for (i in SeasonDataList)
{
  for (j in teams)
  {
    #separate by team and year
    SeasonData=i
    SeasonData=SeasonData[SeasonData$posteam==j,]
    if (length(SeasonData$play_id)!=0)
    {
      #compute ratios
      #initialize temp Ratio var
      P2RRatio=vector("numeric",nrow(SeasonData))
      P2RRatio[1]=0
      #check progress
      print(j)
      print(unique(year(SeasonData$game_date)))
      for (k in 2:nrow(SeasonData))
      {
        #print(i)
        SelectData=SeasonData[1:k-1,]
        P2RRatio[k]=sum(SelectData$typeDummyVar==1)/(k-1)
      }
      #put back into dataframe(store in lists for now)
      #check lengths
      print(length(P2RRatio))
      print(length(SeasonData$play_id))
      print(length(P2RRatio)==length(SeasonData$play_id))
      play_id=append(play_id,SeasonData$play_id)
      P2R=append(P2R,P2RRatio)
    }
  }
}
tempDF=data.frame(matrix(ncol = 0, nrow = length(play_id)))
tempDF$Play_id=play_id
tempDF$P2R=P2R

for(i in 1:length(P2R)){
  print(i)
  id=tempDF$Play_id[i]
  n=which(playData$play_id==id)
  playData$P2R[n]=tempDF$P2R[i]
}
playData$P2R=as.numeric(playData$P2R)
#numerical Dataset
numVec=c("yardline_100","quarter_seconds_remaining","half_seconds_remaining","game_seconds_remaining",
         "game_half","drive","qtr","down","goal_to_go","ydstogo","ydsnet","shotgun","no_huddle",
         "posteam_timeouts_remaining","defteam_timeouts_remaining","posteam_score","defteam_score",                     
         "score_differential","first_down_rush","first_down_pass","first_down_penalty",                 
         "third_down_converted","third_down_failed","fourth_down_converted")
newFeatVec=c("isHome","P2R")
respVec=c("typeDummyVar")
selectVec=c(numVec,newFeatVec,respVec)
NumericalData19_22=playData[selectVec]
NumericalData19_22=na.omit(NumericalData19_22)

#split dataset
#set.seed(4444)
#sample=sample(seq_len(nrow(NumericalData19_22)),size=floor(nrow(NumericalData19_22)*.75))
#train19_22=NumericalData19_22[sample,]
#test19_22=NumericalData19_22[-sample,]

#remove Vars with colinearity issues:
colinVars=c("qtr","defteam_score","posteam_score","half_seconds_remaing","game_seconds_remaining")
NumericalData19_22<-NumericalData19_22[,!names(NumericalData19_22) %in% colinVars]

# Apply Z-score normalization to each column in the dataframe
normalize <- function(x) {
  (x - mean(x)) / sd(x)
}

normdf19_22 <- as.data.frame(lapply(NumericalData19_22[,1:(ncol(NumericalData19_22)-1)], normalize))
normdf19_22=cbind(normdf19_22,typeDummyVar=NumericalData19_22$typeDummyVar)
#normtrain19_22=na.omit(normdf19_22[sample,])
#normtest19_22=na.omit(normdf19_22[-sample,])


