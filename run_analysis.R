#Load necessary libraries
library(dplyr)
library(readr)
library(reshape2)

#Read relevant text data and convert them to data frames
features <- read.table("./UCI HAR Dataset/features.txt")
activity_label <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("activityid", "activityname"))
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = features$V2)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names="activityid")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = features$V2)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names="activityid")
activity_test <- arrange(join(y_test, activity_label), activityid)
activity_train <- arrange(join(y_train, activity_label), activityid)

#Merge into two datasets(test and train) with only the measurements on the mean and standard deviation
test <- cbind(subject_test, activity_test, x_test[,grep("mean|std", colnames(x_test))])
train <- cbind(subject_train, activity_train, x_train[,grep("mean|std", colnames(x_train))])

#merge test and train data sets
data <- rbind(test, train)

#Make column names more descriptive
colnames(data) <- gsub(x = colnames(data), pattern = "(\\.)|(\\.\\.\\.)", replacement = "_")
colnames(data) <- gsub(x = colnames(data), pattern = "__", replacement = "")
colnames(data) <- gsub(x = colnames(data), pattern = "BodyBody", replacement = "Body")
colnames(data) <- gsub(x = colnames(data), pattern = "^t", replacement = "Time_")
colnames(data) <- gsub(x = colnames(data), pattern = "^f", replacement = "Freq_")

id_labels <- c("subject", "activityid", "activityname")
data_labels <- setdiff(colnames(data), id_labels)
melt <- melt(data, id=id_labels, measure.vars = data_labels)

#create column with the average of each variable for each activity and each subject
tidy <- dcast(melt, activityname + subject ~ variable, mean)

#write modified data set into text file
write.table(tidy, file="./run_analysis.txt", row.names = FALSE)