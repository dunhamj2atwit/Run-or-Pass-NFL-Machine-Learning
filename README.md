NFL and Machine Learning-Binary Classification on Play-by-Play Data
=========================================================
By Josh Dunham
August 17th 2023

Abstract
------------
This Summer I’ve been studying how machine learning is currently used in the National Football League and experimenting with some applications. I have been exploring different machine learning techniques to find the best model for predicting whether or not a given play will be running or passing play using play-by-play data from 2009-2018. I will be exploring a variety of binary classification methods and validation techniques for this problem. My biggest challenges were selecting the best model type and working down the huge list of initial variables into the simplest model to avoid unnecessary complexity and over-fitting. I ended up discovering the most important factors are whether or not the play starts in shotgun formation, and if the previous play was a first down as a result of a run or a pass. The optimal model type is less clear, I would personally pick logistic regression because of its speed and consistency when testing for future seasons, however there are many methods that can achieve an accuracy of roughly 80\% with no clear standouts.

Data
------------
The data set I used is from Kaggle's NFL big data bowl in 2022. This data set has 255 features for every play in the NFL between 2009 and 2018. There are 318,668 samples after removing inapplicable plays, such as kicking plays. Generally for this project, a passing play is defined at a 1, and a running play will be defined as a 0. About 58\% of the applicable plays were passing plays and the remaining 42\% were runs.  After trimming down these variables to only pre-play numerical features, with some new features created, I was left with:

| Feature      | Description  |
| ------------- |:-------------:| 
| yardline-100 | Distance from the endzone |              
| quarter-seconds-remaining | seconds remaining in the current quarter |
| half-seconds-remaining | seconds remaining in the current half |
| game-seconds-remaining | seconds remaining in the game |
| game-half | Current game half (3 for overtime) |
| drive | drive number for the current game |                 
| qtr | current quarter (5 for overtime) |
| down | current down |
| goal-to-go | binary, if the team is in a goal-down situation |      
| ydstogo | yards until the next first down or goal-line |
| ydsnet| total yards gained on the current drive |
| shotgun | binary, if the play was in shotgun formation |                 
| no-huddle |  binary, if their was a huddle before the play |
| posteam-timeouts-remaining | timeouts reaming for the possession team |
| defteam-timeouts-remaining | timeouts reaming for the defending team |
| posteam-score | Possession team current score |
| defteam-score | Defending team current score |
| score-differential |  posteam-score - defteam-score |
| first-down-rush | binary, if last play was a rushing first down |
| first-down-pass | binary, if the last play was a passing first down |
| first-down-penalty | binary, if a previous penalty lead to a first down |
| third-down-converted | binary, if the last play was a converted third down |
| third-down-failed | binary, if the last play was a failed third down |
| fourth-down-converted | binary, if the last play was a fourth down converted |
| isHome | binary, if the position team is at home |
| P2R | Pass to run ratio for each team, in each season, up to that play |
	
After checking for collinearity and multi-collinearity with a corealtion matrix and variance inflation factor, qtr, defteam_score, posteam_score, half_seconds_remaing, and game_seconds_remaining we removed.

Methods
------------
To compare Model types I first split the data into a .75/.25 training and testing set. There are several methods I used for interpreting these different models to determine which features have the highest significance and which model type performs the best.

Logistic Regression
------------
To find the optimal Logistic Regression Model I fit a series of nested, where one variable is added at a time, on the trainging set. The order to add variables was picked using forward selection.
	  	* **Forward Selection** Looking at every possible combination of features would take an insanely long time. To speed this up we can subset the amount of models to look at. I used forward selection for this problem. I started by looking at all the single variables models, and picking the feature that gives the highest testing accuracy. Next, I created a set of two feature models by taking the best performing feature from the single variable models and adding the remaining features. The second best feature is selected by picking the highest testing accuracy of all these two variable models. This is then repeated until all features are listed in order of the highest increase in testing accuracy. This ordering is one that gives us one of the best lists of 1,2,3...N(number of features) variable models without checking every single combination. There are a variety of ways to evaluate the goodness-of-fit for these nested models. These include:
		\subsubsection{Test Accuracy}
		The simplest measure of how effective a model is seeing how it preforms in predicting the testing data. First I used the "predict" function in R on each model to get the probabilities of either outcome and then round that probability to the binary 0 or 1. The testing accuracy is calculate taking the sum of correct predictions divided by total number of rows in the testing data.
		\subsubsection{Mathew's Correlation Coefficient}
		Mathew's correlation coefficient is another way to measure how well each model makes predictions on the testing data. MCC accounts for imbalances in the data by including not just correct predictions, but including True Positives, True Negatives, False Positives, and False Negatives. The value for MCC ranges between -1 and 1, where one is perfect predictions, 0 is complete random guessing, and negative one is the worst predictions. The Formula is:
		\[\text{MCC}=\frac{TP \cdot TN - FP \cdot FN}{\sqrt{(TP + FP) \cdot (TP + FN) \cdot (TN + FP) \cdot (TN + FN)}}\]
		\subsubsection{Log-Likelihood}
		Another measure of a logistic regression model's fit is the log-likelihood. Which is calculated by taking the logarithm of the likelihood formula which gives the probability of predicting the observed data. This is the measure we are maximizing when fitting logistic regression. The formula for log-likelihood on logistic regression is:
		\[\text{Log-Likelihood}=\sum(y_i \cdot \log(p_i) + (1 - y_i) \cdot \log(1 - p_i))\]
		Where $y_i$ is actual outcome in the data set and $p_i$ is the predicted probability of the outcome
		\subsubsection{Drop in Deviance}
		Drop in Deviance is a measure used to find the difference between two nested models. Where:
		\[\text{Deviance}=-2 \cdot\ \text{Log-Likelihood}\]
		\[\text{Drop-in-Deviance}=\text{Smaller Model Deviance}-\text{Larger Model Deviance}\]
		This value is equivalent to the test statistic given from the log-likelihood ratio test which can be used to generate p-values. This gives additional insight into the importance of variables in making predictions.
		\subsubsection{Akaike Information Criterion}
		Akaike Information Criterion or AIC is yet another measure of the goodness of fit of each model that rewards simpler models with fewer predictor variables. It's formula uses the deviance formula and adds a term in including the number of parameters:
		\[\text{AIC}=-2 \cdot\ \text{Log-Likelihood} + 2 \cdot \text{Number of Parameters}\]
		\subsubsection{Comparisons}%different title?***
		For these values, a better model is indicated by higher test accuracy and MCC values. As well as lower Log-likelihood and AIC. A lower drop in deviance shows a more significance improvement in the newer model. By finding large changes in these values for the nested models to is possible to determine which features have the highest significance.
		\subsubsection{Final Models}
		 A table with these values for the nested models is shown below. Some variables have been removed from this list because of co-linearity issues. A correlation matrix was used to address collinearity and variance inflation factor was used to address multi-collinearity.
		\begin{center}
			\includegraphics[scale=0.5]{ResultsTable.jpg}\\
		\end{center}
		 I settled on two models with similar accuracy. One simpler model including three parameters with slightly worse values and a more complex model with seventeen variables that preforms slightly better. The simple model features are shotgun, first\_down\_pass, and first\_down\_run. The more complex model includes these and addsthe next fourteen selections from the nested models above. These Models were picked due to the complex model having the peak testing accuracy of every model tested, and the simple model for getting extremely similar results with way fewer predictors. A table with the values for these models is shown below.
		\begin{center}
			\includegraphics[scale=0.9]{FinalResultsTable.jpg}\\
		\end{center}
		Full summary outputs for each model from R are printed below.
		\begin{center}
			\includegraphics[scale=0.78]{SimpleSummary.jpg}\\
			\textbf{Simple Model}\\
			\hfill \break
			\includegraphics[scale=0.78]{ComplexSummary.jpg}\\
			\textbf{Complex Model}
		\end{center}
	\subsection{Decision Tree}
	The next model type I tested were classification decision trees using the rpart package in R. This package decides which features gives creates the best split using Gini impurity. Which uses proportions between classes to measure purity in each potential node. Gini impurity is defined as $G=\sum_{k=1}^K \hat{p}_{mk}(1-\hat{p}_{mk})$. Where K is the number of classes and $\hat{p}_{mk}$ is the proportion of class K in the mth region (potential node). Whether or not a node is included in the tree is determined with Cost Complexity.
		\subsubsection{Cost Complexity Parameter}
		The main method I used to pick between different decision trees was testing different complexity parameters. This value determines the threshold for a node to be included in the model. A higher CP value gives a smaller tree and vice versa. This is controlled by adjusting $\alpha$ in the equation: $\text{CP}=R(T)+\alpha|T|$. Where $R(T)$ is the error rate and $|T|$ is the number of terminal nodes in the tree. I tested different $\alpha$ values using 5 fold cross validation and measuring the effectiveness of the trees with Matthew's correlation coefficient averaged over the 5 folds. A plot of the averaged MCC values vs CP values is below.
		\begin{center}
			\includegraphics[scale=0.75]{CPPlot.png}
		\end{center}
		This selected a best Cost value or "alpha" of 0.0003.
		\subsubsection{Final Models}
		The two trees, with default Cost value of 0.01 and the selected one with their testing accuracy and MCC are shown below.\\
			\begin{center}
				\includegraphics[scale=0.75]{BaseTree.jpg}\\
				\textbf{Accuracy: 0.7963272 MCC: 0.5859592 Nodes:3 }\\
				\includegraphics[scale=0.45]{BestTree.jpg}\\
				\textbf{Accuracy: 0.8182685 MCC: 0.6258103 Nodes: 51 }
			\end{center}
				
	\subsection{Support Vector Machine}
	Support Vector Machines function by finding the optimal separating hyperplane for the given dataset. The process for fitting the best SVM model on this data included: selecting the best "kernel" or boundary shape. This changes the shape of the boundary by modifying function for the hyperplane used in the optimization problem. Another choice that must be made is selecting the best "Cost" parameter, which defines how much the samples inside the margin should be penalized, as well as other parameters dependent on which kernel is selected. One thing to note is that all SVM Models are fit on a subset of the training data (1/10) due to computational limitations.
		\subsubsection{Kernel Selection}
		To explore kernel types I used default cost and kernel parameter values and used 5 fold cross validation accuracy averages to compare effectiveness on this problem. A plot of the testing accuracy averages vs kernel type is shown below:
		\begin{center}
			\includegraphics[scale=0.75]{KernelPlot.png}
		\end{center}
		I ended up exploring models with the radial basis kernel and a set of nested modeling with the same order from the logistic regression forward selection. I mainly included the linear kernel because it's results were only slightly worse and the model creation and parameter tuning is a lot faster with my limited computational resources.
		\subsubsection{Tuning}
		To tune these models I used packages in R to preform 5 fold cross validation and selected the best parameters. I was able to train all the nested models with the linear kernel since only the cost parameter needs to be selected. The Radial Kernel preforms slightly better, but the additional gamma value to be tuned requires a grid of values to calculated, taking significantly more time.
		\subsubsection{Final Models}
		A table of the nested linear kernel models and their testing accuracy are shown below, more values could be tested in the future, but the these models all selected a cost value of $0.0005$.
		\begin{center}
			\includegraphics[scale=0.75]{LinearSVMTable.jpg}
		\end{center}
		The testing accuracy maxes out after three variables are added at about 79.6\%. I was able to get slightly better performance with the radial basis of around 80.2\% (varies slightly with different samples) with a cost value of 1.5 and a gamma of 0.075. 
	\subsection{K-Nearest-Neighbors}
	KNN is  a classification method that makes decision based on the K nearest points (by euclidean distance) in the training set to guess on which class the testing set points will fall in to. Selecting the optimal value for K is the most important part of creating a KNN Model.
		\subsubsection{Selecting K}
		To select K I first tested a wide range of values on the entire training dataset. A graph showing these results are below.
		\begin{center}
			\includegraphics[scale=0.75]{Kgraph}
		\end{center}
		The highest accuracy lies somewhere between K=50 and 100, so I repeated the test in that range with 5 fold cross validation.
		\begin{center}
			\includegraphics[scale=0.75]{KgraphCV}
		\end{center}
		\subsubsection{Final Model}
		The value that preformed best in the cross validation was K=84. Since even numbers of K can have issues with ties, I tested 83,84, and 85. K=85 preformed the best with an accuracy of about 80.2\%.
	\subsubsection{Neural Network}
	I settled on using the neuralnet R package to fit these models. The main hyperparamter I will adjusting to explore different neural nets is the number of hidden layers and the number of nodes in each layer. To start, but I've currently fit two simple, one layer, one node, networks. One with all predictors and one with the three most significant. These models are trained on a $50^{th}$ of the data to increase speed.
	\begin{center}
		\includegraphics[scale=0.75]{NNsimple.jpg}\\
		\textbf{Accuracy: 0.7963398 }\\
		\includegraphics[scale=0.45]{NNcomplex.png}\\
		\textbf{Accuracy: 0.7986243  }
	\end{center}
	When testing different networks with more hidden layers/nodes, there was unfortunately no improvements; the model generally tends to do worse with more complexity. Some of the layers I tested and their testing accuracy are show in the table below. The layers column in this table represents the hidden layers shape. Where the length is the number of hidden layers and the values are the number of neurons for each layer. For example 1,2 represents a two hidden-layer network where the first layer has 1 neuron and the second has 2.
	\begin{center}
		\includegraphics{NNTable.jpg}
	\end{center}
	 I tested different cutoffs for rounding probabilities such as 0.4 and 0.6 but this didn't give any improvements either. Since these networks use the logistic activation function, the single hidden layer, single neuron model is just a logistic regression model. Because this is the best performing model, neural networks won't be included in the final results table, just logistic regression.
	\section{Results}
	Across all five model types it seems pretty clear that the features with the highest significance are shotgun, first down pass, and first down rush. what isn't quite as clear to me is which model type gives the best results. So far the best preforming model is the decision tree with a low complexity parameter, but the high number of nodes gives me some fears that the model may be over-fit. These fears seem to validated when testing these models on data from 2019-2022, the following four seasons after the kaggle data ends. The best performing model, the tree, did the worst when trying to predict data in the future. The tables with results for 2009-2018 and 2019-2022 are below. I haven't been able to fit a neural network that performs better than logistic regression so those models are excluded for now.
	\begin{figure}[h]
		\centering
		\begin{minipage}{.5\textwidth}
			\centering
				\includegraphics[scale=0.75]{CurrentResults.jpg}
		\end{minipage}%
		\begin{minipage}{.5\textwidth}
			\centering
				\includegraphics[scale=0.75]{FutureResults.jpg}
		\end{minipage}
	\end{figure}
	\section{Continued Work}
	Given the time and computational resources, there seems to quite a bit more that could be explored with these models. I am interested in exploring some trees in between the two I created to see if any simpler trees could give similar performance and give better results on future data. I'd also like to dive deeper into testing SVMs with the radial basis kernel if there is enough time for me to run those tests. Another thing that has been mentioned to me that I didn't quite have time for is exploring other ways to find the order to add variables in the nested models, such as backward selection.
	\section{References}
		\begin{thebibliography}{99}
		\footnotesize
		
		\bibitem[Kaggle]{kaggle}
		Kaggle Big Data Bowl (2022)
		\newblock \url{https://www.kaggle.com/competitions/nfl-big-data-bowl-2022/data}
		
		\bibitem[NFLScrapeR]{NFLscraper}
		NFLScrapeR
		\newblock \url{https://www.nflfastr.com/reference/fast_scraper.html}	
		
		\bibitem[ISLR2]{ISLR2}		
		An Introduction to Statistical Learning
		\newblock \url{https://hastie.su.domains/ISLR2/ISLRv2_website.pdf}	
	\end{thebibliography}
\end{document}
