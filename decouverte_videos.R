# ---------------------------------------------------------------------------- #

# Ce script était initialement utilisé pour parcourir la page PourToi, en
# récupérer les urls des pages musiques (fonction decouverte_musique), puis 
# les parcourir pour récupérer les données des vidéos. 
# Finalement, le script a été modifié pour parcourir les vidéos trends.
# Les traces de la version initiale (musique) ont été gardées et sont présentes
# en commentaire.

# ---------------------------------------------------------------------------- #



#install.packages("magrittr")
#install.packages("whisker")
#install.packages("Rtools")
#install.packages("stringr")
#install.packages("RSelenium")
#install.packages("seleniumPipes")

library(httr)
library(jsonlite)
library(xml2)
library(magrittr)
library(whisker)
library(seleniumPipes)
library('RSelenium')
library(stringr) 

decouverte_musique <- function () {
	remDr$navigate("https://www.tiktok.com/foryou")

	print("Now scrolling...")
	remDr$executeScript("window.scrollBy(0,50000);")

	pages_musiques <- list()
	for (p in remDr$findElements('xpath', "//a[contains(@href, 'music')]")) {
	  tmp_url = unlist(p$getElementAttribute("href"))
	  pages_musiques<-append(pages_musiques, tmp_url)
	}
	print("Fetched urls")
 }

remove_login_popup <- function() {
  # Fonction pour retirer le popup login. Il suffit de l'appeler
  # pour l'enlever.
  
	Sys.sleep(3)
  tryCatch({
    button = remDr$findElement('xpath', "//div[contains(@class, 'DivCloseWrapper')]")
    button$clickElement()
  }, error=function(cond) {
          print(cond)
          return (1)
  })
  return (0)

}


scrap <- function(index) {
  #remDr$navigate(unlist(pages_musiques)[index]) # pour scraper les pages musiques

  # Récupérer le nom de la musique qui sera le nom du fichier csv
  tmp_nom=toString(index)
  tryCatch({
    tmp_nom = remDr$findElement(
      'xpath',
      "//h2[contains(@class,'H2ShareSubTitle')]/a"
      )$getElementText()
  }, error=function(cond) {
      print(cond)
  })
  print(tmp_nom)

	print("Sleeping before scroll")

	Sys.sleep(10)
	#remDr$executeScript("window.scrollBy(0,1000000);")
	Sys.sleep(8)
	#remDr$executeScript("window.scrollBy(0,1000000);")
	Sys.sleep(2)
	#remDr$executeScript("window.scrollBy(0,1000000);")
  blocs <- remDr$findElements(
    'xpath',
    "//div[contains(@class,'DivItemContainerForSearch')]"
  )
    #.//div[contains(@class,'DivPlayerContainer')]"
  
  i <- 1

  print(length(unlist(blocs)))

  for (bloc in blocs) {
	  print("index")
    print(i)

  	# Récuperer le lien de la vidéo s'il y en a un. 
	# Si oui, essaie aussi de récupérer les infos.
	tryCatch({
	    ahref<-bloc$findChildElement(
	      "xpath",
	      #"./.."
	      ".//div[contains(@class, 'DivContainer')]//a"
	    )
	    ahref_content <- ahref$getElementAttribute("href")
	    print(ahref_content)
	    if (length(ahref_content) != 0 && !(ahref_content %in% urls)) {
	    	urls <<- append(urls, ahref$getElementAttribute("href"))
	

		    # Essaie de récupérer le user name
		    tryCatch ({
			    user_tmp <<- bloc$findChildElement("xpath", ".//p[contains(@class, 'PUniqueId')]")
			    names <<- append(names, user_tmp$getElementText())
		    }, error = function(cond) {
			    print("Can't get username\n")
			    print(cond)
			    names <<- append(names, NA)
		    })
	
		    # Essaie de récupérer le user link
		    tryCatch ({
			    #link_tmp <<- bloc$findChildElement("xpath", ".//a[contains(@class, 'StyledLink')]")
			    link_tmp <<- bloc$findChildElement("xpath", ".//div[contains(@class,'DivPlayLine')]//a")
	    		    print(link_tmp$getElementAttribute("href"))
			    links <<- append(links, link_tmp$getElementAttribute("href"))
		    }, error = function(cond) {
			    print("Can't get username\n")
			    print(cond)
			    links <<- append(links, NA)
		    })

  		titles <- append(titles, tmp_nom)

		

	}

	}, error=function(cond)  {
		print("Can't find the video link, passes this video")
		print(cond)
	})
    i<-i+1
  } # Fin boucle blocs vidéos

  # Création de la bdd :
  tryCatch({
	  print("Resultats")
	  print(urls)
	  print(names)
	  print(links)
	  bdd<<- data.frame(unlist(urls), unlist(names), unlist(links))
	  names(bdd) = c("urls", "names", "user_links")
	  write.table(x=bdd, file=paste0("./data/","v2decouverte-trends-", index, ".csv"), sep=";", row.names = FALSE)
  }, error=function(cond) {
	  print("can't save\n")
	  print(cond)
  })

  #remDr$close()  

  return (bdd)

} # Fin function scrap


# ----------------------------------------------------
# ------------ Programme principal :  ----------------


# ------------ Initialisation driver & lists --------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")
remDr$open(silent = TRUE)

# ------------- Utiliser ce script pour initialiser la recherche de musique ------------
# decouverte_musique()
#tryCatch({
#	bdd <- read.csv("./data/data.csv", sep=";")
#	print("Got a bdd!")
#	titles <- bdd$titles
#	urls <- bdd$urls
#	names <- bdd$names
#	links <- bdd$user_links
#}, error=function(cond) {
#	print("Error in reading")
#	print(cond)
#})


# --------------- Sans musiques : cherche la bdd avec les liens des trends -----------
tryCatch({
	bdd_tmp <- read.csv("./data/trends.csv")
	print("Reading from trend.csv")
	pages <- bdd_tmp$Lien
}, error=function(cond) {
	print("can't read")
	print(cond)
})

print(pages)
bdd <<- data.frame()

# --------------- Scrap ------------
numero_scrap <- 1
for (page in unlist(pages)[14:20]) {
	remDr$navigate(page)
  titles <- list()
  urls <- list()
  names <- list()
  links <- list()
  pages <- list()

  # On attend, on enlève le popup, on scrap, puis on passe à la suviante.

	print("Went to url")
	Sys.sleep(10)
	remove_login_popup()
	scrap(numero_scrap)
	numero_scrap <- numero_scrap + 1

}

remDr$close()
