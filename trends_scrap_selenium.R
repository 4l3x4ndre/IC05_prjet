# ---------------------------------------------------------------------------- #

# Attention, ce programme n'est plus fonctionnel car les données semblent
# désormais être chargées dynamiquement. Il faut passer par Selenium 
# avec le script update_stats_videos.

# Programme utilisé pour METTRE A JOUR les données tendances.
# Une fois les bdd tendances créées, lancer ce script ajoute 4 colonnes 
# pour les 4 métriques, avec comme nom "<métrique>_<DateDuJour>".

# ---------------------------------------------------------------------------- #


library(httr)
library(jsonlite)
library(xml2)
library(magrittr)
library(whisker)
library(seleniumPipes)
library('RSelenium')
library(stringr)
remove_login_popup <- function() {
        #Sys.sleep(1)
        tryCatch({
                button = remDr$findElement('xpath', "//div[contains(@class, 'DivCloseWrapper')]")
                button$clickElement()
        }, error=function(cond) {})
}

unit <- function(valeur) {
  valeur <- gsub("Share", "0", valeur, fixed = TRUE)
  valeur <- gsub("K", "e3", valeur, fixed = TRUE)
  valeur <- gsub("M", "e6", valeur, fixed = TRUE)
  as.numeric(valeur)
}


scrap <- function(index) {
	tryCatch({
	infos <- remDr$findElements('xpath', "//div[contains(@class, 'DivActionItemContainer')]//button//strong")
	i <-0 
	for (info in infos) {
		i <- i + 1
		print(info$getElementText()[[1]])
		d <- info$getElementText()[[1]]
		if (i==1) likes<<-append(likes, unit(d))
		if (i==2) coms<<-append(coms, unit(d))
		if (i==3) sign<<-append(sign, unit(d))
		if (i==4) {
			if (d=="Share") {
				part<<-append(part, 0)
			} else {
				part<<-append(part, unit(d))
			}
		}
	}
	if (i == 0) {
		likes<<-append(likes, NA)
		coms<<-append(coms, NA)
		sign<<-append(sign, NA)
		part<<-append(part, NA)
	}
	print(likes)
	},error=function(cond){
		print(cond)
		print("ERROR")})

} # Fin function scrap



# ----------------------------------------------------
# ------------ Programme principal :  ----------------


# ------------ Initialisation driver & lists --------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")
remDr$open(silent = TRUE)


# --------------- Scrap ------------
#for (trend in c(1, 2, 3, 4,8,10,11,12,13,14,15,16,18,19,20)) {
for (trend in c(1, 2, 3, 4,8,10,11,12,13,14,15,16,18,19,20)) {
        bdd <<- read.csv(paste0("./data/videos_trends/v2decouverte-trends-", trend,".csv"), sep=";", header=TRUE)
	titles <- list()
	urls <- list()
	names <- list()
	links <- list()
	pages <- list()
	likes <- list()
	coms <- list()
	sign <- list()
	part <- list()

	for (numero_scrap in c(1:length(bdd$urls))) {
		print(bdd$urls[numero_scrap])
		remDr$navigate(bdd$urls[numero_scrap])
		Sys.sleep(2)
		print(paste("Went to url", numero_scrap))
		#Sys.sleep(10)
		#remove_login_popup()
		scrap(numero_scrap)
	}
	
	nom <- Sys.Date()
	bdd[paste('liste_likes', nom, sep='_')] <- unlist(likes)
	bdd[paste('liste_nb_commentaires', nom, sep='_')] <- unlist(coms)
	bdd[paste('liste_nb_signets',nom, sep='_')] <- unlist(sign)
	bdd[paste('liste_partages', nom, sep='_')] <- unlist(part)
	write.table(x=bdd, file=paste0("./data/videos_trends/v2decouverte-trends-", trend, ".csv"), sep=";", row.names = FALSE)

}



