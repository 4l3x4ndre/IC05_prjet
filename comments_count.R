#----------Setup-------------
install.packages(c("RCurl","XML", "RSelenium", "stringr", "ggplot2" ))

library(ggplot2)

library(stringr)

library(RSelenium)

#----------Init selenium-------------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")

remDr$open()

remDr$getStatus()

#----------Navigation-------------
account_link<-NA
account_link<-"https://www.tiktok.com/@raphael_metivet/video/7213843034193153286" 
  
remDr$navigate(account_link)

Sys.sleep(3)

#----------Fermeture onglet inscription-------------
tryCatch(
  {
    closeButton <- remDr$findElement("xpath","//input[@data-e2e='modal-close-inner-button']")
    closeButton$clickElement()
  },
  error=function(e){
    print("Pas de pop-up")
  }
)

#----------Scrolling-------------

#for (x in 1:20) {

# remDr$executeScript("window.scrollBy(0,5000);")
#Sys.sleep(2)
#}
scrollToEnd <- function() {
  last_height <- remDr$executeScript("return document.body.scrollHeight")
  while (TRUE) {
    remDr$executeScript("window.scrollBy(0, document.body.scrollHeight);")
    Sys.sleep(1)
    new_height <- remDr$executeScript("return document.body.scrollHeight")
    if (identical(new_height, last_height)) {
      break
    }
    last_height <- new_height
  }
}

# Utilisation de la fonction pour faire défiler jusqu'à la fin de la page
scrollToEnd()

#----------Variables-------------#
comments_time <- list()
comments_time <- remDr$findElements("xpath", "//span[@data-e2e='comment-time-1']")

#----------Conversion des dates au même format-------------#
convert_to_date <- function(date_str) {
  date_str <- date_str[[1]]
  if (grepl("^\\d+d ago$", date_str)) {
    days_ago <- as.numeric(gsub("[^0-9]", "", date_str))
    return(Sys.Date() - days_ago)
  } 
  
  if (grepl("^\\d+w ago$", date_str)) {
    weeks_ago <- as.numeric(gsub("[^0-9]", "", date_str))
    return(Sys.Date() - weeks_ago * 7)
  } 
  
  if (grepl("^\\h+w ago$", date_str)) {
    return(Sys.Date())  
  } 
  
  if (grepl("^\\d{1,2}-\\d{1,2}$", date_str)) {
    components  <- unlist(strsplit(date_str, "-"))
    if (length(components) == 2) {
      month <- as.integer(components[1])
      day <- as.integer(components[2])
      year <- as.integer(format(Sys.Date(), "%Y"))
      return(as.Date(paste(year, month, day, sep = "-")))
    }
  }

  return(NA)

}

#----------Récup dates-------------#
time_list <- list()

time_list <- lapply(comments_time, function(time) {
  time_text <- time$getElementText()
  as.Date(convert_to_date(time_text))
})

time_list <- unlist(time_list)
time_list <-as.Date(time_list)

print(time_list)

#----------Occurences-------------#
occurences <- table(unlist(time_list))
occurences <- as.data.frame(table(unlist(time_list)))
colnames(occurences) <- c('Date','Nbcomments') 
print(occurences)

# Création d'un graphique à barres
ggplot(occurences, aes(x = Date, y = Nbcomments)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  labs(title = "Evolution des Commentaires", x = "Jour", y = "Nb de commentaires") +
  theme_minimal()