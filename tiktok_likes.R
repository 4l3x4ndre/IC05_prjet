#----------Setup-------------
install.packages(c("RCurl","XML", "RSelenium", "stringr" ))

library(stringr)

library(RSelenium)

#----------Init selenium-------------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")

remDr$open()

remDr$getStatus()

#----------Navigation-------------

account_link<-"https://www.tiktok.com/@wolfandpig29" #<---- ici metre l'url


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

#----------Clic sur les likes-------------

tryCatch(
  {
    locked_like_btn<- remDr$findElement("xpath", "//p[@data-e2e='liked-tab']//svg")
  },
  error=function(e){
    
    like_btn<- remDr$findElement("xpath", "//p[@data-e2e='liked-tab']")
    like_btn$clickElement()
    
  }
)

#----------Scrolling-------------

for (x in 1:300) {
  
  remDr$executeScript("window.scrollBy(0,5000);")
  Sys.sleep(1)
}
scrollToEnd <- function() {
  last_height <- remDr$executeScript("return document.body.scrollHeight")
  while (TRUE) {
    remDr$executeScript("window.scrollBy(0, document.body.scrollHeight);")
    Sys.sleep(2)
    new_height <- remDr$executeScript("return document.body.scrollHeight")
    if (identical(new_height, last_height)) {
      break
    }
    last_height <- new_height
  }
}

# Utilisation de la fonction pour faire défiler jusqu'à la fin de la page
scrollToEnd()


#----------Variables-------------

likes_user <- list()
titles_likes <- list()
views_vids <- list()
  
likes_user <- remDr$findElements("xpath", "//div[@data-e2e='user-liked-item']//a")
titles_likes <- remDr$findElements("xpath", "//div[@data-e2e='user-liked-item-desc'][1]") 
views_vids <- remDr$findElements("xpath", "//div[@data-e2e='user-liked-item']//strong[@data-e2e='video-views']")


links_likes <-NA 
title_list <- NA
views_list <- NA

#----------Récupération data-------------

for (like in likes_user) { 
  link <- like$getElementAttribute("href")
  links_likes <- append(links_likes, link)
}


for (i in titles_likes) { 
  title <- i$getElementAttribute("aria-label")

  title_list <- append(title_list, title)
  
}


for (view in views_vids) {
  views_text <- view$getElementText()
  views_list <- append(views_text,views_list)
  
}

get_username <- function(url) {
  username <- str_extract(url, "(?<=@)[^/]++")
  return(username)
}

usernames <- list()
usernames <- lapply(links_likes, get_username)


# Longueur maximale parmi les trois catégories
max_length <- max(length(links_likes), length(title_list), length(views_list), length(usernames))

# Chaque catégorie a la même longueur
padList <- function(lst, len) {
  if (length(lst) < len) {
    lst <- c(lst, rep(NA, len - length(lst)))
  }
  return(lst)
}

# Remplissage chaque catégorie pour qu'elles aient la même longueur
links_likes <- padList(links_likes, max_length)
title_list <- padList(title_list, max_length)
views_list <- padList(views_list, max_length)
usernames <- padList(usernames, max_length)

#----------Création BDD csv-------------
bdd_likes <<- list()
bdd_likes <<- data.frame(unlist(links_likes), unlist(usernames), unlist(views_list), unlist(title_list))

colnames(bdd_likes) <- c('Liens','Auteurs', 'Vues', 'Titre') 

likes_csv <- paste0("likes", Sys.Date(),".csv")

write.csv(bdd_likes,likes_csv)

#----------Analyse textuelle usernames les plus like-------------

usernames <- as.character(bdd_likes[, 2])
tokenized_usernames <- unlist(strsplit(usernames, "\\s+"))

word_freq <- table(tokenized_usernames)
top_n <- 10
top_redundant_words <- names(sort(word_freq, decreasing = TRUE))[1:top_n]
print(top_redundant_words)

#----------Analyse textuelle texte le plus like-------------
titles <- as.character(bdd_likes[, 4])
tokenized_titles <- unlist(strsplit(titles, "\\s+"))



toremove<-c("’","a","le","la","de", "des", "les", "en", "sur", "à", "il", "elle", "#fyp", "comme", "d'un", "d'une", "aussi", "fait", 
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
            "!","a","mdr","lol","ce","qui",".",",",";","?","et", "#fypシ゚viral","#foryoupage","avec", "I", "love", "you","o", "u","y","v","#tiktok",
            "#الشعب_الصيني_ماله_حل😂😂",  "#اكسبلور" ,":"  , "-" ,"#parati" ,   "lo" ,  "lo"       ,  "el"  , "es"   , "l"  , "#trending", "que","un","pour","je",
            "_","est","fy", "che"   ,       "per"   ,       "è"        ,   
        "*"      ,      "una"   ,   "#neiperte"  ,"#perte" ,  "di" ,"une", "#fy","my","#CapCut" ,"#edit","é" ,"😂" , "não"  ,
        "eu" , "do"  , "to"    ,   "and"    ,  "is" ,"so" ,"this" ,"for" ,"i","that"    )


# Remove specified words
tokenized_titles <- tokenized_titles[!tokenized_titles %in% toremove]



word_freq <- table(tokenized_titles)
top_n <- 10
top_redundant_words <- names(sort(word_freq, decreasing = TRUE))[1:top_n]
print(top_redundant_words)


install.packages(c("wordcloud","tidyverse"))

library(wordcloud)
library(tidyverse)

# Création d'un data frame pour le nuage de mots
word_freq_df <- data.frame(word = names(word_freq), freq = as.numeric(word_freq))

# Générer le nuage de mots
set.seed(15621) # Pour reproduire les résultats
wordcloud(words = word_freq_df$word, freq = word_freq_df$freq, min.freq = 6, 
          scale = c(3, 0.2), colors = brewer.pal(8, "Dark2"))
title(main = "Centre d'intérêts d'une utilisateur ayant liké Ronaldo", col.main = "black", font.main = 1)               
