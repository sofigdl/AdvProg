#Load packages
install.packages("httr")
install.packages("xml2")
install.packages("magrittr")
install.packages("pbapply")
install.packages("magick")
install.packages("jsonlite")

library(httr)
library(xml2)
library(magrittr)
library(pbapply)
library(magick)
library(jsonlite)
library(tidyverse)



#base url
url_api<-"https://images-assets.nasa.gov/image/as11-40-5874/collection.json"

#Check what we get back from here
reply <- GET(url_api)
http_status(reply)
reply


#extract info from body
reply_content<-content(reply)
class(reply_content)

# create products data.frame
reply.df<-as.data.frame(t(as.data.frame(reply_content, stringsAsFactors=FALSE)), row.names=FALSE, col.names="url", stringsAsFactors=FALSE)
View(reply.df)

# get all maps from our request
dir<- paste0(tempdir(), "/API_nasa")
dir.create(dir)
reply.df[,2] <- paste0(dir, "image_", 1:nrow(reply.df), "jpg")
reply.df<-reply.df[-6,]
colnames(reply.df)<-c("url", "file")

# check for URLs that do not work properly (server issues?)
working <- !sapply(reply.df[1,], http_error, USE.NAMES = F)
reply.df <- reply.df[,working]

# download and read images
images<-mapply(x=reply.df[1,], y=reply.df[2,], function(x,y){
  catch<-GET(x,write_disk(y, overwrite = T))
  image_read(y)
})

#Write image
images <- do.call(c, images)
image_write(images, "C:/Users/chofi/Documents/2019/Maestria/Advance_Programming/AdvProg/nasa.png")
View(images)
