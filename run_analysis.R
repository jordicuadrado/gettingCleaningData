#setting own working directory
setwd("/home/jordi/Data Science Specialization/3 - Getting and Cleaning Data/Week 3/UCI HAR Dataset/")

# 1.-Merge the training and the test sets to create one data set. Also names the variables (columns) appropiately.
# - 'train/X_train.txt': Training set.
# - 'train/y_train.txt': Training labels.
# - 'test/X_test.txt': Test set.
# - 'test/y_test.txt': Test labels.
# - 'features.txt': List of all features.

#Read train and test data
trainX <- read.table("train/X_train.txt")
testX <- read.table("test/X_test.txt")

#Create "x" (train+test) data set
dataX <- rbind(trainX, testX)

#Read train and test activity ID (y) and subject (subject)
trainY <- read.table("train/y_train.txt")
testY <- read.table("test/y_test.txt")
trainSubject <- read.table("train/subject_train.txt")
testSubject <- read.table("test/subject_test.txt")

#Create "y" (train+test) data set and name the column (variable)
dataY <- rbind(trainY, testY)
names(dataY) = "activityId"
#Create "subject" (train+test) data set and name the column
dataSubject <- rbind(trainSubject, testSubject)
names(dataSubject) = "subject"

#dim(dataX) #testing only, in RStudio, the Environment tab already shows the Data frames with number of obs/variables
#[1] 10299   561
#dim(dataY)
#[1] 10299     1
#dim(dataSubject)
#[1] 10299     1

#Read features to give "column names" to the dataX data set
features <- read.table("features.txt")
#Name the features columns for convenience
names(features)[1] <- "index" #this index is the same as the Vx column in dataX, this is the way to the match indexes with feature labels.
names(features)[2] <- "labels"
#Alternatively, we can do: features <- read.table('features.txt', col.names=c('index', 'labels'))

#Assign column names to the features (dataX). The index in features$index matches the column index of dataX.
colnames(dataX) <- features$labels

#At this point, we can merge (cbind) all three data sets, but first proceed to give proper descriptive activity names (to dataY) in step #3.


# 2.-Extract only the measurements on the mean and standard deviation for each measurement. 
#Subset the columns that match -mean() or -std() by using the regexp on the column names already assigned to dataX.
#column names like meanFreq are (correctly) not catch in the regular expression (I previously opened the "features.txt" to see what is inside).
meanStdDevDataX <- dataX[ , grepl("-(mean|std)\\(\\)", names(dataX))] #Double backslash '\' needed in R to escape. In http://regexr.com/ try with only one backslash: -(mean|std)\(\)


# 3.-Uses descriptive activity names to name the activities in the data set
#Replace activity IDs (dataY) with the corresponding label in "activity_labels.txt"

#Read activity labels
activities <- read.table("activity_labels.txt")
#Name the columns for the convenience
names(activities)[1] <- "activityID" #this index is the same as the IDs found in rows of dataY
names(activities)[2] <- "activityLabel"
#Match the activityId with the labels (works kind of a JOIN)
dataY$activityId <- activities$activityLabel[dataY$activityId]

#I used the labels in "activity_labels.txt" (here: activities$activityLabel) because they are already "tidy" enough so one can understand its meaning.
#If we wanted to make it even clearer, we can use the factor function as follows:
#dataY$activityId <- factor(dataY$activity, labels=c("Walking", "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))

#Moreover, alternatively, we can use:
#dataY$activityId[activities$activityID=='1'] <- 'Walking'
#and so one for the other five activities


# 4.-Appropriately label the data set with descriptive variable names.

#Replace some abbreviations with a more descriptive word
names(dataX) <- gsub("Acc", "Acceleration", names(dataX))
names(dataX) <- gsub("Mag", "Magnitude", names(dataX))
names(dataX) <- gsub("Freq", "Frequency", names(dataX))
names(dataX) <- gsub("^t", "Time", names(dataX))
names(dataX) <- gsub("-mean\\(\\)", "Mean", names(dataX))
names(dataX) <- gsub("-std\\(\\)", "StdDev", names(dataX))


# 5.-Create a second, independent tidy data set with the average of each variable for each activity and each subject.

#Combine data sets:
dataMerged <- cbind(dataSubject, dataY, meanStdDevDataX)
#Calculate the mean of each variable for each activity and each subject by selecting the data except the "group by" info:
tidyDataset <- aggregate(dataMerged[ ,!(colnames(dataMerged) %in% c("subject", "activityId"))], by=list(dataMerged$subject, dataMerged$activityId), FUN=mean, na.rm=TRUE, na.action=NULL)
#As a result of using the aggregate function, we must rename the colnames:
names(tidyDataset)[names(tidyDataset) == 'Group.1'] = 'subject'
names(tidyDataset)[names(tidyDataset) == 'Group.2'] = 'activityLabel'
#a possible solution to avoid the renaming could be using ddply? instead of aggregate

#Output the tidy data set:
write.table(tidyDataset, "tidyDatasetAverages.txt", row.name=FALSE)
