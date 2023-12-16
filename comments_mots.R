#----------Setup-------------
install.packages(c("RCurl","XML", "RSelenium", "stringr", "ggplot2" ))

library(ggplot2)

library(stringr)

library(RSelenium)

install.packages("stopwords")

library(stopwords)
#----------Init selenium-------------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")

remDr$open()

remDr$getStatus()

#----------Navigation-------------
account_link<-NA
account_link<-"https://www.tiktok.com/@politique.lucas/video/7206046785389808902?q=politique&t=1702385912180" 
  
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
    Sys.sleep(3)
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
comments_content <- list()
comments_content <- remDr$findElements("xpath", "//p[@data-e2e='comment-level-1']//span")

#----------Récup contennu-------------#
text_list <- list()
for (text in comments_content) { 
  text <- text$getElementText()
  text_list <- append(text_list, text)
}

#----------Analyse textuelle commentaires-------------

text_list <- as.character(text_list)
tokenized_text <- unlist(strsplit(text_list, "\\s+"))

toremove<-c(stopwords ("french"), stopwords("english"),",","a","le","la","de", "des", "les", "en", "sur", "à", "il", "elle", "#fyp", "comme", "d'un", "d'une", "aussi", "fait", 
            "être", "c'est", "an", "faire", "dire", "si", "qu'il", 
            "où", "tout", "plus", "encore", "déjà", "depuis",
            "ans", "entre", "n'est", "peut", "dont", "donc", 
            "ainsi", "faut","va", "donc", "tous", "alors",
            "chez", "fois", "quand", "également", "n'a", "n'y", 
            "celui", "celle", "l'un", "n'ont", 
            "l'a", "l'on","qu'on","or","d'ici","s'il","là", "dès",
            "dit","pu","six","pu","font","ceux","peut",
            "j'ai","ni","très", "lune", "lors", "puis", "etc", "tel", 
            "chaque", "ca", "veut", "toute", "quelle"
            ,"peu", "moin", "après", "bien", "deux", "trois", "oui",
            "avant", "ça", "sest", "notamment","tant","peuvent", 
            "selon", "quelque", "toujour", "avoir", "car", "beaucoup", 
            "sous", "non", "d'autre", "contre", "plusieurs", 
            "autre", "toute", "fin", "heure", 
            "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche", 
            "dans", "pas", "me", "nos", "nous", "de", "vous", "sans", "mais", "d'accord",
            "voir", "parce", "dis", "dit", 'vont', "rien", "qu'ils", "quoi", "juste",
            "pourquoi", "trop", "peux", "moins", "depuis", "sous", "t'es", "ah", "vois", 
            "vais", "vraiment", "y'a", "vas", "bla", "e", "d'être", "veux", "mois", "sen", 
            "bah", "regarde", "tiens", "complètement", "completement", "sait", "ten", "vers", 
            "+", "toutes", "|", "via", "mettre", "in", "of", "👉", "👇","➡","#fyp","#pourtoi","de","#viral","#foryou","#fypシ","le", "the",  
            "!","a","mdr","lol",".",",",";","?","et", "#fypシ゚viral","#foryoupage", "un", "même", "Même", "je", "tu", "il", "on", "Bardella", "bardella", "Jordan")

# Remove specified words
tokenized_text <- tokenized_text[!tokenized_text %in% toremove]


word_freq <- table(tokenized_text)
top_n <- 10
top_redundant_words <- names(sort(word_freq, decreasing = TRUE))[1:top_n]
print(top_redundant_words)