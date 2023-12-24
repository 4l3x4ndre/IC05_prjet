# ---------------------------------------------------------------------------- #

# Programme utilisé pour récupérer les liens des pages musiques
# à partir de la page PourToi. A fair eavant musique_avec_docker.R

# ---------------------------------------------------------------------------- #


install.packages("RSelenium")
install.packages("seleniumPipes")
install.packages("httr")
install.packages("jsonlite")
install.packages("xml2")
install.packages("magrittr")
install.packages("whisker")
install.packages("Rtools")

library(httr)
library(jsonlite)
library(xml2)
library(magrittr)
library(whisker)
library(seleniumPipes)
library('RSelenium')
library(stringr) 

###############################################################################
# Set-up Selenium :

# Démarrage d'un docker selenium avec firefox
shell('docker run -d -p 4445:4444 -p 5901:5900 selenium/standalone-firefox-debug')

# Configuration du navigateur
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")
remDr$open() # Lancement du navigateur


# Naviguer vers la page d'accueil  
remDr$navigate("https://www.tiktok.com/foryou")

# Scroller si besoin
remDr$executeScript("window.scrollBy(0,5000);")


# Fin set-up Selenium



###############################################################################
# Récupération des urls de pages musiques :

pages_musiques <- list()
for (p in remDr$findElements('xpath', "//a[contains(@href, 'music')]")) {
  url = unlist(p$getElementAttribute("href"))
  pages_musiques<-append(pages_musiques, url)
}

# Fin url musique



###############################################################################
# Set-up listes utilisées pour future dataframe :

reset_listes <- function() {
  urls<<-NA
}

# Fin listes



###############################################################################
# Début scrapping :
# 1. Pour chaque page musique
#   a. on récupère le nombre de vidéos avec cette musique (lsite_nb)
#   b. on récupère tous les blocs vidéos de la page
#   c. pour chaque blocs viédos :
#     - on récupère les infos du compte
#     - on clique dessus (mieux que de naviguer vers la page)
#     - on prend ses infos (likes, coms, signets, hashtags)


scrap <- function() {
  reset_listes()
  
  
  blocs <- remDr$findElements(
    'xpath', 
    "//div[contains(@class,'DivPlayerContainer')]"
  )
  i <- 1
  for (bloc in blocs) {
    print(i)
    
    # Récuperer le lien de la vidéo s'il y en a un
    ahref<-bloc$findChildElement(
      "xpath", 
      "./.."
    )
    if (length(ahref$getElementAttribute("href")) == 0) {
      urls[i] <<- ""
    } else {
      urls[i] <<- ahref$getElementAttribute("href")
    }
    
    
    i<-i+1
  } # Fin boucle blocs vidéos
  
  # Création de la bdd :
  bdd <<- do.call(rbind.data.frame, c(urls, row.names=FALSE))
  colnames(bdd) <<- c("urls")
  
  return (bdd)
  
} # Fin function scrap


# ATTENTION : il faut naviguer vers la page musique AVANT la fonction...
# on ne peut pas faire de boucle "pour toutes les pages musiques" pour l'instant
# car Selenium perd le focus (raison inconnue, à approfondir)
# D'où la navigation fixe vers la première page seulement :
remDr$navigate(unlist(pages_musiques)[4])

scrap()

write.table(x=bdd, file="./data/paper planes.csv", sep=";", row.names = FALSE)

