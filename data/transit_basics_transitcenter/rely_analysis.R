#read in MBTA performance csv file
rawdata <- read.csv(file="./TDashboardData_reliability_20160301-20160331.csv", head=TRUE,sep=",")
View(rawdata)

#Select Peak Service rows for the Green Line
data <- rawdata[which (rawdata$PEAK_OFFPEAK_IND =="Peak Service (Weekdays 6:30-9:30AM, 3:30PM-6:30PM)"),]
View(data)

#Remove columns of data we don't need
data <- data[c("SERVICE_DATE", "ROUTE_OR_LINE", "ROUTE_TYPE","STOP","OTP_NUMERATOR","OTP_DENOMINATOR")]

#Select only the Green Line data
data <- data[which (data$ROUTE_TYPE=='Green Line'),]

#Remove and extra spaces
data$STOP <- trimws(data$STOP,which = c("right"))

#Find the reliability at each station
#Divide the numerator (people who has to wait too long) by the denominator (all riders).
data$rely <- data$OTP_NUMERATOR / data$OTP_DENOMINATOR
#This is the percentage of people who had to wait. 1 - this ratio is the percentage of people who didn't.
data$rely <- 1 - data$rely
#Round by 2
data$rely <- round(data$rely, digits=4)
View(data)


# Spot Check
# Select March 30 into one variable
avgMarch30 = data[which(data$SERVICE_DATE == '30-MAR-2016'),]
View(avgMarch30)
#Get the average reliability for March 30
avgMarch30 = mean(avgMarch30$rely) * 100

#Get the average reliability for March 1-30
avgMarchLast30   = mean(data$rely) * 100


#read in the MBTA station location data
#Select only the Green Line data
#Change the name of Station to Stop to match the other dataframe
rawlocs <- read.csv("./mbta_stations.csv")
locs = rawlocs
View(locs)
names(locs)[names(locs) == 'STATION'] <- 'STOP'
locs$STOP <- as.character(locs$STOP) 


#join the location data to the reliability file
#Select only the columns need
joindata <- merge(x = data, y = locs, by ="STOP", all.x=TRUE)
joindata <- joindata[c("STOP","SERVICE_DATE","ROUTE_TYPE","rely","stop_lat","stop_lon")]

View(joindata)

#export the data to a csv file
write.csv(joindata, "./joindata.csv")

