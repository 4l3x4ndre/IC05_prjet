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
  liste_nb <<- NA
  liste_url_videos<<-NA
  liste_noms_utilisateurs<<-NA
  liste_liens_utilisateurs<<-NA
  liste_likes <<- NA
  liste_nb_commentaires <<- NA
  liste_nb_signets <<- NA
  liste_hashtags <<- NA
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
  
  nb_tmp <- remDr$findElement('xpath', "//h2/strong[contains(@style,'font-weight')]")$getElementText()
  nb_tmp <- str_remove_all(nb_tmp, " videos")
  liste_nb[1] <<- nb_tmp
  
  #liste_liens_utilisateurs[1] = nb_tmp
  #titres_tmp <- remDr$findElements('xpath', "//h2/strong[@style='font-weight:normal']")
  #titres = list()
  #for (t in titres_tmp) {
  #  titres = append(titres,t$getElementAttribute("href"))
  #}

  
  blocs <- remDr$findElements(
    'xpath', 
    "//div[contains(@class,'DivPlayerContainer')]"
    )
  i <- 1
  for (bloc in blocs) {
    print(i)
    
    au_suivant <- FALSE
    # Récupérer le nom du compte
    tryCatch({
      p<-bloc$findChildElement(
        "tag name", 
        "p"
      )
      liste_noms_utilisateurs[i] <<- p$getElementText()
    }, error=function(cond) {
      print("Erreur lors de la récupération du nom user :")
      print(cond)
      tryCatch({
        blocs <- remDr$findElements(
          'xpath', 
          "//div[contains(@class,'DivPlayerContainer')]"
        )
        j<-1
        for (b in blocs) {
          if (j<i) next
          bloc <- b
          break
        }
        
        p<-bloc$findChildElement(
          "tag name", 
          "p"
        )
        liste_noms_utilisateurs[i] <<- p$getElementText()
      }, error=function(cond) {
        au_suivant<-TRUE
        print("Encore une erreur => on passe au suivant")
        }
      )
      
      
    })
    if (au_suivant) next
    
    # Récuperer le lien du compte
    liens_tmp <- p$findChildElement(
      "xpath", 
      "./../.."
    )
    liste_liens_utilisateurs[i] <<- liens_tmp$getElementAttribute("href")
    
    # Récuperer le lien de la vidéo s'il y en a un
    ahref<-bloc$findChildElement(
      "xpath", 
      "./.."
      )
    if (length(ahref$getElementAttribute("href")) == 0) {
      liste_url_videos[i] <<- ""
    } else {
      liste_url_videos[i] <<- ahref$getElementAttribute("href")
    }
    
    # Ouvrir la vidéo (mieux que redirection)
    bloc$clickElement()
    
    # Récupérer les infos de la vidéo. 
    # Avec ce tryCatch, on essaie de les récupérer.
    # Selenium renvoit souvent des erreurs, donc pour éviter de s'arrêter à chaque
    # fois, j'utilise tryCatch qui, s'il y a une erreur, va aller dans la fonction
    # d'erreur (plus bas) puis continuer le script.
    tryCatch( {
      parent <- remDr$findElement(
        "xpath",
        "//div[contains(@class,'DivFlexCenterRow-StyledWrapper')]"
      )
      infos_obj <- parent$findElement("xpath", ".//strong")
      # infos_obj contient une string sous la forme "33M\n12M\n1M"
      # Donc on divise les infos en coupant la chaîne au niveau des \n
      infos <- strsplit(unlist(infos_obj$getElementText()), '\n')
      infos <- unlist(infos)
      liste_likes[i] <<- infos[1]
      liste_nb_commentaires[i] <<- infos[2]
      liste_nb_signets[i] <<- infos[3]
      
      # Pour le prochain tour : on réinitialise infos
      # (utile ? Pas sûr, mais parfois si)
      infos <<- NA 
      
      # Hashtags
      # Parfois, le texte est caché et il faut cliquer sur un bouton "more"
      # pour lire la description de la vidéo. Donc avec ce tryCatch on regarde
      # s'il y a un bouton (classe ButtonExpand) et on click dessus. S'il n'y
      # en a pas, R va dans la fonction erreur (parce que Selenium génère une
      # erreur si il ne trouve pas un élément). Depuis la fonction erreur,
      # R affiche un message console ("No Button") et continue.
      tryCatch({
        bouton_etendre <- remDr$findElement(
          'xpath',
          "//button[contains(@class, 'ButtonExpand')]"
        )
        bouton_etendre$clickElement()
      }, error=function(cond){print("No Button")})
      
      hashtags_obj <<- remDr$findElements(
        'xpath',
        '//div[contains(@class, "DivMainContent")]
        //div[contains(@class, "DivContainer")]
        /a/strong[contains(@class, "StrongText")]'
      )
      hashtags <<- ""
      for (h in hashtags_obj) {
        # On évite les duplicata pour une même vidéo
        if (!is.element(h$getElementText(), hashtags) && 
            h$getElementText()!="" &&
            substring(unlist(h$getElementText())[1] , 1, 1) == "#") {
          hashtags <<- paste(hashtags, h$getElementText(), collapse = " ")
          print(unlist(h$getElementText())[1])
          print(substring(unlist(h$getElementText())[1] , 1, 1) == "#")
        }
      }
      liste_hashtags[i] <<- hashtags
      hashtags <<- ""
      
      # Ferme la vidéo
      bouton_fermeture <- remDr$findElement(
        "xpath",
        "//button[contains(@class, 'ButtonBasicButtonContainer')]")
      bouton_fermeture$clickElement()
    
    
    }, # Fin Try de récupération d'info de vidéo
    error=function(cond) { # Si on n'a pas réussi à lire des infos on mets NA :
      print(cond)
      liste_likes[i] <<- NA
      liste_nb_commentaires[i] <<- NA
      liste_nb_signets[i] <<- NA
      liste_hashtags[i] <<- NA
    }
    )
    
    i<-i+1
  } # Fin boucle blocs vidéos
  
  # Création de la bdd :
  bdd <<- data.frame(
    unlist(liste_url_videos),
    unlist(liste_noms_utilisateurs),
    unlist(liste_liens_utilisateurs),
    unlist(liste_likes),
    unlist(liste_nb_commentaires),
    unlist(liste_nb_signets),
    unlist(liste_hashtags)
  )

  return (bdd)
 
} # Fin function scrap


# ATTENTION : il faut naviguer vers la page musique AVANT la fonction...
# on ne peut pas faire de boucle "pour toutes les pages musiques" pour l'instant
# car Selenium perd le focus (raison inconnue, à approfondir)
# D'où la navigation fixe vers la première page seulement :
remDr$navigate(unlist(pages_musiques)[5])

scrap()

write.table(x=bdd, file="./data/paper planes.csv", sep=";", row.names = FALSE)

