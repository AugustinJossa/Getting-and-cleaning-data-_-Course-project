library(reshape2)
library(data.table)

#Download the dataset
filename <- "getdata_dataset.zip"
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}


# Load and format activity and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# Select mean & standard deviation
features_ok <- grep(".*mean.*|.*std.*", features[,2])
features_ok.names <- features[features_ok,2]


#Format features
features_ok.names = gsub('-mean', 'Mean', features_ok.names)
features_ok.names = gsub('-std', 'Std', features_ok.names)
features_ok.names <- gsub('[-()]', '', features_ok.names)


# Create databases
train_data <- read.table("UCI HAR Dataset/train/X_train.txt")[features_ok]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train_data)

test_data <- read.table("UCI HAR Dataset/test/X_test.txt")[features_ok]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test_data)

data <- rbind(train, test)
colnames(data) <- c("subject", "activity", features_ok.names)


# Format activities & subjects into factors
data$activity <- factor(data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
data$subject <- as.factor(data$subject)


# Create final database
data_melted <- melt(data, id = c("subject", "activity"))
data_mean <- dcast(data_melted, subject + activity ~ variable, mean)

write.table(data_mean, "tidy.txt", row.names = FALSE, quote = FALSE)
