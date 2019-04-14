## Script to read and tidy dataset
##################################


## clear out the environment
rm(list=ls()) 

## install and load relevant packages if required
if (!require("pacman")) install.packages("pacman")
p_load(reshape2, data.table, install = TRUE, update = getOption("pac_update"), character.only = FALSE)

## Get the dataset
file <- "getdata_dataset.zip"

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, file, method="curl")
}  

## Unzip the dataset
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

## Get activity labels 

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels$V2 <- as.character(activity_labels$V2)

## Get features
features <- read.table("UCI HAR Dataset/features.txt")
features$V2 <- as.character(features$V2)

## Extract only the data on mean and standard deviation
M_SD <- grep(".*mean.*|.*std.*", features$V2)
M_SD_labels <- features[M_SD,2]
M_SD_labels = gsub('-mean', 'Mean', M_SD_labels)
M_SD_labels = gsub('-std', 'Std', M_SD_labels)
M_SD_labels <- gsub('[-()]', '', M_SD_labels)


## Get the train data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[M_SD]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

## Get the test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[M_SD]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

## merge train and test data in one datasets
tot <- rbind(train, test)
colnames(tot) <- c("subject", "activity", M_SD_labels)

# turn activities & subjects into factors
tot$activity <- factor(tot$activity, levels = activity_labels[,1], labels = activity_labels[,2])
tot$subject <- as.factor(tot$subject)

tot_long <- melt(tot, id = c("subject", "activity"))
tot_M_SD <- dcast(tot_long, subject + activity ~ variable, mean)

write.table(tot_M_SD, "week4data.txt", row.names = FALSE, quote = FALSE)
