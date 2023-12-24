# ---------------------------------------------------------------------------- #

# Script utilisé pour récupérer les commentaires des vidéos tendances
# dont l'url a déjà été stockées dans la bdd de la tendance.

# ---------------------------------------------------------------------------- #



#install.packages("httr")
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

clicker_bouton <- function(path) {
	tryCatch({
	button = remDr$findElement('xpath',path )
	button$clickElement()
	}, error=function(cond) {
		print(cond)
		return (1)
	})
	return (0)

}

attendre_si_cap <- function(index=0) {
	if (index < 5) {

		index <- index + 1
		tryCatch ({
			remDr$findElement('xpath', "//div[contains(@class, 'captcha')]")
			Sys.sleep(5)
			attendre_si_cap(index)
		}, error=function(cond) {
			print("pas de captcha")
			print(cond)
		})	
	}
}

scrap <- function(url) {
	# url test : 
	#remDr$navigate("https://www.tiktok.com/@beyondthebrick/video/7255819286801861931?q=lego&t=1701602430679")


	remDr$navigate(url)

	print("J'attends...\n")
	Sys.sleep(5)
	resultat <- clicker_bouton("//div[contains(@class, 'DivCloseWrapper')]")
	remDr$executeScript("window.scrollBy(0, 1000000);")

	print("J'attends...\n")
	Sys.sleep(15)

	# Attendre si capcha
	attendre_si_cap()	


	print("Commence la récupération")
	liste <- ""
	tryCatch({
		index <- 1
		for (com in remDr$findElements('xpath', "//p[contains(@class, 'PCommentText')]/span")) 
		{
			if (com$getElementText() != "") {
				print(com$getElementText())
				liste <- paste0(liste, ' IC05 ', com$getElementText())
				#liste <- append(liste, com$getElementText())
				index<- index + 1
			}
		}
	}, error=function(cond) {
		print(cond)
		#liste<-append(liste, NA)
	})

	liste_com <<- append(liste_com, liste)


	# Essaie de récupérer les hastags
	# Avant, il faut peut être cliqué sur le bouton "more" pour afficher le texte
	clicker_bouton("//div[contains(@class, 'DivText')]//a/strong")
	
       	hash_txt <- ""
	tryCatch({
		hash_obj <- remDr$findElements(
						'xpath',
						"//div[contains(@class, 'DivText')]//a/strong"
						)
		for (hash_o in hash_obj) {
			hash_txt <- paste0(hash_txt, hash_o$getElementText())
		}
		print(paste0("Hash : ", hash_txt))
	}, error = function(cond) {
		print("can't get hashtags")
		print(cond)
	})
       liste_hashtags <<- append(liste_hashtags, hash_txt)


	

}

#args <- commandArgs(TRUE)
#if (length(args) == 0) {stop("At least one argument must be supplied")}
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")
remDr$open(silent = TRUE)
#for (index_fichier in c(args[3]:args[4])) {
for (index_fichier in c(4, 8, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20)) {
	print(index_fichier)
	tryCatch({
		bdd <- read.csv(
				paste0("./data/videos_trends/v2decouverte-trends-", index_fichier, ".csv"),
			       	sep=";"
		)
		liste_com <- list()
		liste_hashtags <- list()
		#for (u in bdd$urls[args[1]:args[2]]) {
		for (u in bdd$urls) {
			scrap(u)
		}

		tryCatch({
			print("Fini, écriture")
			print(liste_com)
			print("-----")
			print(unlist(liste_com))
			bdd$com <- unlist(liste_com)
			#bdd$com <- as.character(bdd$com)
			print(liste_hashtags)
			bdd$hashtags <- unlist(liste_hashtags)
			write.table(
				    x=bdd, 
				    file=paste0("./data/videos_trends/v2decouverte-trends-", index_fichier, "-com.csv"),
				    sep=";"
				    , row.names=FALSE
			)
		}, error=function(cond) {
			print("Can't save")
			print(cond)
		})
	}, error = function(cond) {
		print("error in process")
		print(cond)
	})
}

remDr$close()
