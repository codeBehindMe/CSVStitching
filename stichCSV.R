# stich CSV files together


print("This function will stich together CSV files outputted by the japanese VPO units. It will ignore ALM logs.")

#check if x variable exists then error out if it does
if (exists("x")) {

      stop("variable named x is already define. Remove this variable using remove(x) prior to proceeding.")   
}


require("tcltk") #this gives interactive folder selection

zFile <- file.choose(new = FALSE) #choose the zip file to be extracted

exDir <- tk_choose.dir(getwd(),"Select folder to unzip the files") # choose where the extracts need to go

if (is.na(exDir) == TRUE){
      stop("User cancelled extract directory selection")
}

#make a sub folder so that the data will be inside this folder
#make a unique id for the folder so that it will not clash

require(uuid)
exDirNew <- paste(exDir,substr(UUIDgenerate(TRUE),1,7),sep='/')
#unzip the file
unzip(zFile,exdir=exDirNew)

#set the working directory to the extracted directory
setwd(exDirNew)

files <- as.vector(NULL)

#contains the directories in our data folder
dirs <- list.dirs(exDirNew)

x <- as.vector(NULL) #container for filenames + path

# get and set the filenames and paths of directories and files
for(dir in dirs){
      
      for(file in list.files(dir)){
            x <- c(x,paste(dir,file,sep='/'))
      }
      
}

#filter items with .csv extention
require(sqldf)

df_ <- as.data.frame(x) #instatialize data frame

df_ <- sqldf("SELECT * FROM df_ WHERE x LIKE '%.csv'") # check csv selection (although this may have been routed differently)

df_ <- sqldf("SELECT * FROM df_ WHERE x NOT LIKE '%ALMLog%'") #remove alarm log csv

fullCSV_ <- data.frame()
fullCSV_ <- NULL  #instantialize in nullify full CSV container

for (path in 1:length(df_[,1])){
      
      tempCSV_ <- read.csv(as.character(df_[path,1]),header=FALSE)
      
      if (is.null(fullCSV_)){
            fullCSV_ <- tempCSV_
      }
      
      names(fullCSV_) <- names(tempCSV_)
     
      fullCSV_ <- rbind(fullCSV_,tempCSV_)
      
      remove(tempCSV_)
}

#delete temporary csv files
unlink(exDirNew,recursive=TRUE)

# write the output file
write.csv(fullCSV_,file=paste(exDirNew,"fullCSV.csv",sep="/"),row.names=F)

print(c("Full CSV file written to: ",paste(exDirNew,"fullCSV.csv",sep="/"))) #alert user

remove(df_,fullCSV_,dir,dirs,exDir,exDirNew,file,files,path,x,zFile) #remove temporary variables.
