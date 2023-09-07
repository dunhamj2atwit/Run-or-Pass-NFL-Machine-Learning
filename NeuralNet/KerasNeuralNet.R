library(keras)
library(tidyverse)

X_train <- train %>% 
  select(shotgun,first_down_rush,first_down_pass) %>% 
  scale()
y_train <- to_categorical(train$typeDummyVar)

X_test <- test %>% 
  select(shotgun,first_down_rush,first_down_pass) %>% 
  scale()
y_test <- to_categorical(test$typeDummyVar)

modelnn <- keras_model_sequential() 
modelnn %>%
  layer_dense(units = 256, activation = 'relu', input_shape = ncol(X_train)) %>% 
  layer_dropout(rate = 0.4) %>% 
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 2, activation = 'sigmoid')

history <- modelnn %>% compile(
  loss = 'binary_crossentropy',
  optimizer = 'adam',
  metrics = c('accuracy')
)

modelnn %>% fit(
  X_train, y_train, 
  epochs = 100, 
  batch_size = 5,
  validation_split = 0.25
)

modelnn %>% evaluate(X_test, y_test)
#issues starting here
accuracy <- function (pred,truth)
   mean(drop(pred)==drop(truth))

predictions <- modelnn %>% predict(X_test) %>% `>`(0.5) %>% k_cast("int32")  %>%  accuracy(test$typeDummyVar)


table(factor(predictions, levels=min(test$typeDummyVar):max(test$typeDummyVar)),factor(test$typeDummyVar, levels=min(test$typeDummyVar):max(test$typeDummyVar)))

plot(history$metrics$loss, main="Model Loss", xlab = "epoch", ylab="loss", col="orange", type="l")
lines(history$metrics$val_loss, col="skyblue")
legend("topright", c("Training","Testing"), col=c("orange", "skyblue"), lty=c(1,1))

plot(history$metrics$acc, main="Model Accuracy", xlab = "epoch", ylab="accuracy", col="orange", type="l",xlim=c(0,100),ylim=c(.78,.85))
lines(history$metrics$val_acc, col="skyblue")
legend("topleft", c("Training","Testing"), col=c("orange", "skyblue"), lty=c(1,1))
