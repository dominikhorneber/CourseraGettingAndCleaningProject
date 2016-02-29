#loads relevant packages necessary for this R script
library(plyr)
library(dplyr)
library(tidyr)
library(data.table)

#creates R object with path for user's zip file in working directory

zipfile <- dir() %>% grep(pattern="UCI HAR Dataset", ignore.case=T, value=T)
temp <- getwd() %>% normalizePath(winslash="/") %>% paste0('/', zipfile)

#identifies files to be loaded into R based on data needs of assignment
files <- c("UCI HAR Dataset/train/subject_train.txt", "UCI HAR Dataset/train/X_train.txt", "UCI HAR Dataset/train/y_train.txt", "UCI HAR Dataset/test/subject_test.txt", "UCI HAR Dataset/test/X_test.txt", "UCI HAR Dataset/test/y_test.txt", "UCI HAR Dataset/features.txt", "UCI HAR Dataset/activity_labels.txt")

#reads data from txt files into R data tables
subjecttrain <- read.table(unz(temp, file= files[1]))
xtrain <- read.table(unz(temp, file= files[2]))
ytrain <- read.table(unz(temp, file= files[3]))
subjecttest <- read.table(unz(temp, file= files[4]))
xtest <- read.table(unz(temp, file= files[5]))
ytest <- read.table(unz(temp, file= files[6]))
features <- read.table(unz(temp, file= files[7]))

#combines test and train data tables into two large dataframes
dftest <- cbind(subjecttest, ytest, xtest)
dftrain <- cbind(subjecttrain, ytrain, xtrain)

#creates character vector for 'feature names' that will be used to label columns
featurenames <- as.character(features$V2)

#setting consistent column names adhering to name restrictions using colnames/make.names commands
#make.names command necessary to avoid 'duplicate columns' error later on
colnames(dftest) <- make.names(names=c("subjectID", "activityID", featurenames), unique=T, allow_=T)
colnames(dftrain) <- make.names(names=c("subjectID", "activityID", featurenames), unique=T, allow_=T)

#creates comprehensive dataframe containing all observations for all variables
df <- rbind(dftest, dftrain) %>% tbl_df()
#TASK 1 COMPLETED

#subsets dataframe to select only means/standard deviation variables + ID variables (subjectID, activityID)
df_extract <- select(df, subjectID, activityID, matches("mean|std"))

#TASK 2 COMPLETED

#reads activity descriptions into R and creates one character vector with all lower case activity names
activities <- read.table(unz(temp, file=files[8]))
activitynames <- activities$V2 %>% as.character() %>% tolower()
activitynames <- sub("_", " ", activitynames)

#replaces the activityID column with a descriptive activity column using mutate function
#each activityID is replaced by the respective activity by
  #subsetting the activiy names character vector with the activityID factors, thus creating a character vector with appropriate activity names of the same length as the activityID column
  #setting the character vector as a factor vector (given its role in the dataset as a factor)
  #replacing the activityID column with the newly created factor vector with respective activity names
  #renaming the activityID column into activity column
df_extract <- mutate(df_extract, activityID=factor(activitynames[df_extract$activityID]))
colnames(df_extract)[2] <- "activity"

#TASK 3 COMPLETED

#tidies variable names for measurements and adds full descriptions, replacing abbreviations with full words and unifying formatting with regards to 'dots'
names(df_extract) <- sub("^t", "time", names(df_extract))
names(df_extract) <- sub("^f", "frequency", names(df_extract))
names(df_extract) <- sub("Acc", "Accelerometer", names(df_extract))
names(df_extract) <- sub("Gyro", "Gyroscope", names(df_extract))
names(df_extract) <- sub("Mag", "Magnitude", names(df_extract))
names(df_extract) <- sub("BodyBody", "Body", names(df_extract))
names(df_extract) <- sub("Freq", "Frequency", names(df_extract))
names(df_extract) <- sub("tBody", "timeBody", names(df_extract))
names(df_extract) <- sub("gravity", "Gravity", names(df_extract))

names(df_extract) <- gsub("\\.", "", names(df_extract))

names(df_extract) <- sub("X$", "-X", names(df_extract))
names(df_extract) <- sub("Y$", "-Y", names(df_extract))
names(df_extract) <- sub("Z$", "-Z", names(df_extract))

names(df_extract) <- sub("mean", "-mean", names(df_extract))
names(df_extract) <- sub("Mean", "-mean", names(df_extract))
names(df_extract) <- sub("std", "-std", names(df_extract))
names(df_extract) <- sub("^angle", "angle-", names(df_extract))

#TASK 4 COMPLETED

#creates a second data set (.txt file) that contains the average (mean) of each measurement variable by type of activity and subject using the dplyr group_by and summarise_each functions
df_means <- group_by(df_extract, activity, subjectID) %>% summarise_each(funs(mean)) 

write.table(df_means, file="Means Dataset.txt", row.names=F)

#TASK 5 COMPLETED

#removes all R objects except the Task 1 dataframe, Task 2 dataframe, Task 5 dataframe.
Robjects <- ls()
rm(list=Robjects[c(1:2, 6:17)])
rm("Robjects")

### END ###