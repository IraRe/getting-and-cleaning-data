# assuming that the course data (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) was 
# downloaded and unzipped into your working directory

train_datatable <- read.table("./UCI HAR Dataset/train/X_train.txt")
test_datatable <- read.table("./UCI HAR Dataset/test/X_test.txt")

# 1) merge the training and the test sets in one data set
all_data <- rbind(test_datatable, train_datatable)

varnames <- read.table("./UCI HAR Dataset/features.txt")
names(all_data) <- varnames$V2
# as names contain non-valid characters in R, they have to be made valid before further processing
valid_col_names <- make.names(names=names(data), unique = TRUE, allow_ = TRUE)
names(all_data) <- valid_col_names

# 2) select mean and standard deviation for each measurement
selected_data <- select(data, contains("mean", ignore.case = TRUE), contains("std", ignore.case = TRUE))

# load activity labels
test_activities <- read.table("./UCI HAR Dataset/test/y_test.txt")
train_activities <- read.table("./UCI HAR Dataset/train/y_train.txt")
all_activities <- rbind(test_activities, train_activities)

named_activities <- mutate(all_activities, descriptive_name = 
                                   ifelse(V1 == 1, "WALKING", 
                                          ifelse(V1 == 2, "WALKING_UPSTAIRS", 
                                                 ifelse(V1 == 3, "WALKING_DOWNSTAIRS", 
                                                        ifelse(V1 == 4, "SITTING", 
                                                               ifelse(V1 == 5, "STANDING", "LAYING"))))))
# 3) and 4) use descriptive activity names to name the activities in the data set
named_data <- cbind(named_activities$descriptive_name, selected_data)
# first column now contains nonvalid character $ in its name, so I cannot use the dplyr-rename function here
named_data <- mutate(named_data, activity = named_activities$descriptive_name)
named_data <- select(named_data, -starts_with('named_activities'))

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subject <- rbind(subject_test, subject_train)
named_data <- cbind(named_data, subject)
rename(named_data, subject = V1)

# 5) create data set with the average for each variable for each subject and each activity
by_subject_and_activity <- group_by(named_data, subject, activity, add = TRUE)
tidy_data <- summarise_each(by_subject_and_activity, funs(mean))

# remove the dots in the variable names
names(tidy_data) <- sub("\\.\\.\\.","",names(tidy_data))
names(tidy_data) <- sub("\\.\\.","",names(tidy_data))

write.table(tidy_data, file="tidy_data.txt", row.names = FALSE)
