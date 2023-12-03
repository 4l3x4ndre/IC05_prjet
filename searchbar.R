#----------setup-------------
install.packages(c("RCurl","XML", "RSelenium", "stringr" ))

library(RSelenium)

#----------init selenium-------------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")

remDr$open()

remDr$getStatus()

#----------navigation-------------

remDr$navigate("https://www.tiktok.com/foryou")

Sys.sleep(3)
tryCatch(
  {
    closeButton <- remDr$findElement("xpath", "//input[@data-e2e='modal-close-inner-button']")
    closeButton $clickElement()
  },
  error=function(e){
    print("Pas de pop-up")
  }
)
#----------detection navbar-------------

searchBar <- remDr$findElement("xpath", "//input[@data-e2e = 'search-user-input']")
searchBar$clickElement()

#----------récuperation des trends-------------

trends <- remDr$findElements("xpath", "//li[@data-e2e = 'search-transfer-guess-search-item']")


# Initialisation des listes pour stocker les titres et les liens des tendances
titre_trends <- list()
liens_trends <- list()
nb_trend = 1 


# Boucle à travers les tendances avec ouverture des liens (ne mmarche pas)

# for (trend in trends) { 
# 
#   # Trouver l'élément <h4> dans la tendance actuelle
#   h4_element <- trend$findElement("xpath", ".//h4")
#   
#   # Récupérer le texte du <h4>
#   titre <- h4_element$getElementText()
#   
#   # Ajouter le titre à la liste
#   titre_trends <- append(titre_trends, titre)
#   
#   nb_trend = nb_trend+1 
#   
#   # Effectuer l'action pour ouvrir le lien dans un nouvel onglet en maintenant la touche CONTROL enfoncée
#   trend$sendKeysToElement(list(key = "Control", key = "t"))
#   # Passage à la nouvelle fenêtre
#   remDr$switchToWindow(remDr$getWindowHandles()[nb_trend])
#   
#   # Récupération de l'URL de la nouvelle fenêtre
#   lien_trend <- remDr$getCurrentUrl()
#   liens_trends <- append(liens_trends, lien_trend)
# 
#   # Retour à la fenêtre d'origine
#   remDr$switchToWindow(remDr$getWindowHandles()[1])
# }


#Boucle récuperation des titres des trends + liens

for (trend in trends) { 

    # Trouver l'élément <h4> dans la tendance actuelle
    h4_element <- trend$findElement("xpath", ".//h4")

    # Récupérer le texte du <h4>
    titre <- h4_element$getElementText()

    # Ajouter le titre à la liste
    titre_trends <- append(titre_trends, titre)
    
    faux_lien <- paste0("https://www.tiktok.com/search?q=",titre)
    
    liens_trends <- append (liens_trends, faux_lien)
  }



 bdd <<- data.frame(unlist(titre_trends),unlist(liens_trends)) 
 colnames(bdd) <- c('Trend','Lien') 
 
 nom_csv <- paste0("trend", Sys.Date(),".csv")
 
 write.csv(bdd,nom_csv)
 