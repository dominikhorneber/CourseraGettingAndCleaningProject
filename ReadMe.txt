READ ME for R script run_analysis.

The R script was designed to compute the results of an experiment on Human Activity Recognition Using Smartphones and complete the following five tasks:

1) Reads the experiment results and merges all into one data set.
2) Extract from the data set the measurements on the mean and standard deviation for each measurement.
3) Inserts descriptive activity names into the dataset to name the activities done by the participants in the experiment.
4) Appropriately labels the data set with descriptive variable names.
5) Creates a new data set with the averages of mean and standard deviation measurements for each subject of the experiment and each activity undertaken by each subject. 

The dataset created in Task 5) can be read into R using the following code where filepath is the combination of the respective working directory of the user and the filename "Means Dataset.txt":

	dataset <- read.table(filepath, header=T)
	View(dataset)

The accompanying codebook ("codebook.pdf") was created using the memisc package and subsequently manually edited.

To function, the R script requires the following non-standard packages: plyr, dplyr, tidyr, data.table, memisc 

Note: The R script assumes that the downloaded dataset is saved in the user's working directory and that its name contains 'UCI HAR Dataset'.

======================================

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

======================================

The findings of the experiment are accessible online (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) in a zip archive consisting of txt-files with processed sensor readings and explanatory txt-files:

- 'README.txt' - explaining the overall structure of the dataset and experiment background

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

Sub-folders contain further txt files with raw data that are not necessary for the actions performed by this R script. 

======================================

The R script is pasted below with descriptions of each step taken (#...) followed by the relevant R code:

#loads relevant packages necessary for this R script
library(plyr)
library(dplyr)
library(tidyr)
library(data.table)
library(memisc)

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
#make.names command necessary to avoid 'duplicate columns' error that appears otherwise when using rbind to bind the two datasets together
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

======================================

The author of the R script is grateful for the advice provided by David Hood on the blog post accessible here: <https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/> (Accessed 2016/02/28)












