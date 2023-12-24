# ---------------------------------------------------------------------------- #

# Programme utilisé pour METTRE A JOUR les données tendances avec Selenium.
# Une fois les bdd tendances créées, lancer ce script ajoute 4 colonnes 
# pour les 4 métriques, avec comme nom "<métrique>_<DateDuJour>".
# Il faut rester proche pour résoudre les captcha.

# Pas de main, lancer le programme suffit.

# ---------------------------------------------------------------------------- #

#install.packages("RCurl")
#install.packages("XML")
library(RCurl)
library(XML)
library(stringr)

reset_listes <- function() {
  liste_likes <<- NA
  liste_nb_commentaires <<- NA
  liste_nb_signets <<- NA
  liste_partages <<- NA
  liste_user_links <<- NA
  liste_dates <<- list()
}

unit <- function(valeur) {
  # Fonction pour convertir les métriques 3.2M, 3K etc en nombre entier.
  valeur <- gsub("Share", "0", valeur, fixed = TRUE)
  valeur <- gsub("K", "e3", valeur, fixed = TRUE)
  valeur <- gsub("M", "e6", valeur, fixed = TRUE)
  as.numeric(valeur)
}

update_scrapping <- function(file_path) {
  bdd <<- read.csv(file_path, header=TRUE, sep = ';')
  
  i <- 1
  reset_listes()
  for (link in bdd$urls) {
	  print(link)
    page_obj<-getURL(link, ssl.verifypeer=F)
    page<-htmlParse(page_obj)
    Sys.sleep(1)
    print(i)
    tryCatch({
      infos_obj <- xpathSApply(
        page, 
        "//div[contains(@class, 'DivActionItemContainer')]/button/strong", 
        xmlValue
        )
      
      infos <<- ""
      for (obj in infos_obj) {
        infos <<- paste(infos, obj)
      }
      print(infos)
      infos <<- unlist(strsplit(infos, split=" "))
      print(infos)
      id <- 1
      present <- FALSE
      for (n in names(bdd)) {
	      	comparatif <- paste(str_split_1(as.character(Sys.Date()), "-"), collapse='.')
	      	if (grepl(comparatif, n)) {
		      present <- TRUE
			break
		}
	      id <- id+1
      }
      print(paste("id ", id, "i ", i, "present = ", present, "Date: ", Sys.Date()))
      print("---")

      if (present) {
      	if (is.na(bdd[i, id]) ) {
		print(paste("is na true", infos))
	      	print(bdd[i, id])
		liste_likes[i] <<- unit(infos[2])
	} else {
		liste_likes[i] <<- bdd[i, id]
	}
      	if (is.na(bdd[i, id+1])) {
		liste_nb_commentaires[i] <<- unit(infos[2+1])
	} else {
		liste_nb_commentaires[i] <<- bdd[i, id+1]
	}
	if (is.na(bdd[i, id+2])) {
		liste_nb_signets[i] <<- unit(infos[2+2])
	} else {
		liste_nb_signets[i] <<- bdd[i, id+2]
	}
	if (is.na(bdd[i, id+3])) {
		liste_partages[i] <<- unit(infos[2+3])
	} else {
		liste_partages[i] <<- bdd[i, id+3]
	}
      } else {
	liste_likes[i] <<- unit(infos[2])
      	liste_nb_commentaires[i] <<- unit(infos[3])
      	liste_nb_signets[i] <<- unit(infos[4])
      	liste_partages[i] <<- unit(infos[5])
      }
      
      
      
    }, error=function(cond) {
      print("Erreur ligne 31")
      print(cond)
      liste_likes[i] <<- NA
      liste_nb_commentaires[i] <<- NA
      liste_nb_signets[i] <<- NA
      liste_partages[i] <<- NA
    })

    if (!("user_links" %in% colnames(bdd))) {
    tryCatch({
	    link_obj <- xpathSApply(
				    page,
				    "//div[contains(@class, 'DivInfoContainer')]/a",
				    xmlGetAttr, "href")
	    s <- paste0("http://www.tiktok.com", link_obj)
	    liste_user_links[i] <<- s
    }, error=function(cond) {
	    print("can't get userlink")
	    print(cond)
	    liste_user_links[i] <<- s
    })
    }

    # Récupérer la date
    date_txt <- xpathSApply(
			    page,
			    "//span[contains(@class, 'SpanOtherInfos')]/span[3]",
			    xmlValue
			    )
    if (is.null(date_txt)) {
 	   liste_dates <<- append(liste_dates, "NA")
    } else {
	    liste_dates <<- append(liste_dates, date_txt)
	}

    
    i<-i+1
  }
  

  print(names(bdd))

	if (present) {
		print("delete")
		bdd <<- bdd[-c(id, id+1, id+2, id+3)]
		print(names(bdd))
	}


	bdd[paste('liste_likes', Sys.Date(), sep='_')] <<- liste_likes
	bdd[paste('liste_nb_commentaires', Sys.Date(), sep='_')] <<- liste_nb_commentaires
	bdd[paste('liste_nb_signets',Sys.Date(), sep='_')] <<- liste_nb_signets
	bdd[paste('liste_partages', Sys.Date(), sep='_')] <<- liste_partages
 
  if (!("dates" %in% colnames(bdd))) {
	 bdd$dates <<- unlist(liste_dates)
  }

  if (!("user_links" %in% colnames(bdd))) {
	  bdd$user_links <<- liste_user_links
  }
  
  
}

for (i in c(1, 2, 3, 4,8,10,11,12,13,14,15,16,18,19,20)) {
	update_scrapping(paste0("./data/videos_trends/v2decouverte-trends-",i,".csv"))

	write.table(x=bdd, file=paste0("./data/videos_trends/v2decouverte-trends-", i, ".csv"), sep=";", row.names = FALSE)
}

