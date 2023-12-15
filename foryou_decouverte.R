#install.packages("crayon")
library(crayon)

library(httr)
library(jsonlite)
library(xml2)
library(magrittr)
library(whisker)
library(seleniumPipes)
library('RSelenium')
library(stringr)

unit <- function(valeur) {
  valeur <- gsub("Share", "0", valeur, fixed = TRUE)
  valeur <- gsub("K", "e3", valeur, fixed = TRUE)
  valeur <- gsub("M", "e6", valeur, fixed = TRUE)
  as.numeric(valeur)
}

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


# ----------------------------------------------------
# ------------ Programme principal :  ----------------


# ------------ Initialisation driver & lists --------
remDr <- remoteDriver( port = 4445L, browserName = "firefox", version="1")
remDr$open(silent = TRUE)
remDr$navigate("https://tiktok.com/foryou")


bdd <- data.frame()
urls <- list()
names <- list()
likes <- list()
coms <- list()
signets <- list()
partages <- list()
descriptions <- list()
hashtags <- list()

for (i in c(1:3)) {
	Sys.sleep(3)
        remDr$executeScript("window.scrollBy(0,1000000);")
}
clicker_bouton("//div[contains(@class, 'DivCloseWrapper')]")

blocs <- remDr$findElements('xpath',
			    "//div[contains(@class, 'DivContentContainer')]")
print(length(blocs))
i <- 1
for (bloc in blocs) {
	
	#tryCatch ({	
	#	c <- TRUE
	#	while (c) {
	#		captchas <- remDr$findElement('xpath', "//div[contains(@class, 'captcha')]")
	#		i <- 0
	#		for (cap in captchas) {i
	#			print(" ############### CAPTCHA !!! ################### ")
	#			i <- i + 1
	#		}
	#		if (i == 0) c <- FALSE
	#		Sys.sleep(0.1)
	#	}
	#}, error=function(cond){})
	
	#if (i == 5)break 
	print(paste0("nouveau bloc: ", i))
	tryCatch({

		can_scrap <- TRUE
		final_url <- ""
		url <- ""
		tryCatch({
			video <- bloc$findChildElement("xpath", ".//div[contains(@class, 'DivVideoCardContainer')]")
			video$clickElement()
			url <<-  remDr$getCurrentUrl()
			Sys.sleep(2)
			Sys.sleep(3)
			if (url != "https://www.tiktok.com/foryou") {
			       if (!(url %in% urls)) {
				       #urls <<- append(urls, url)
				       final_url <<- url
				} else {
					#urls <<- append(urls, "")
					final_url <<- "NA"
			       }
			} else {
				print("FALSE ", url)
				can_scrap <<- FALSE
			}
			print(urls)
			remDr$findElement('xpath', "//button[contains(@class, 'ButtonBasicButtonContainer')]")$clickElement()
			Sys.sleep(0.5)
		}, error=function(cond){
			print("no url")
			#urls <<- append(urls, "--")
			final_url <<- "NA"
		})

		if (can_scrap) {
		name_obj <- bloc$findChildElement('xpath',
						  ".//a[contains(@class, 'StyledLink-StyledAuthorAnchor')]")
		names <- append(names, name_obj$getElementText())

		infos_obj <- bloc$findChildElements('xpath',
						   ".//div[contains(@class, 'DivActionItemContainer ')]//strong")

		index <- 1
		for (info in infos_obj) {
			if (index == 1) likes <- append(likes, unit(info$getElementText()))
			if (index == 2) coms <- append(coms, unit(info$getElementText()))
			if (index == 3) signets <- append(signets, unit(info$getElementText()))
			if (index == 4) partages <- append(partages, unit(info$getElementText()))
			index <- index + 1
		}

		tryCatch({
			button = bloc$findChildElement('xpath',
							".//button[contains(@class, 'ButtonExpand')]")
			button$clickElement()
			print("clicked!")
		}, error=function(cond) {})

		txt <- ""
		tryCatch({
			desc_obj <- bloc$findChildElement('xpath', ".//div[contains(@class, 'DivText')]//div[contains(@class, 'DivText')]//div[contains(@class, 'DivContainer')]")
			print(desc_obj$getElementText()[[1]])
			#vec <- desc_obj$getElementText()
			txt <<- desc_obj$getElementText()[[1]]
			#if (txt == "") txt <<- desc_obj$getElementText()[[1]]
		}, error=function(cond){
			#print("here")
			#spans <- bloc$findChildElemets('xpath',
			#	".//div[contains(@class, 'DivText')]//div[contains(@class, 'DivText')]//div[contains(@class, 'DivContainer')]//span")
			
			#for (span in spans) {
			#	txt <- paste0(txt, span$getElementText())
			#}
			#descriptions <- append(descriptions, txt)
		})
		txt1 <- str_split_1(txt, "#")[1]
		descriptions <- append(descriptions, txt1)
		print("txt:")
		print(txt)
		print("----")

		if (txt != "") {
			vec <- str_split_1(txt, "#")
			print(vec)
			if (length(vec) > 1) {hashtags <- append(hashtags, paste(vec[c(2:length(vec))], collapse="# "))
			} else {hashtags <- append(hashtags, "-")}

		} else {
			hashtags <- append(hashtags, "-")
		}

		urls <<- append(urls, final_url)
		} # can_scrap
	}, error=function(cond) {
		print(cond)
	})


	



	#bloc$clickElement()
	#Sys.sleep(1)
	#urls <- append(urls, remDr$getContentUrl())
	
	#closeButteon <- remDr$findElement('xpath', "//button[contains(@class, 'ButtonBasicButtonContainer')]")
	#closeButton$clickElement()
	#Sys.sleep(1)


	i <- i + 1
}


print(urls)
print(descriptions)
print(hashtags)
bdd <- data.frame(unlist(names), unlist(likes), unlist(coms), unlist(signets), unlist(partages), unlist(descriptions), unlist(hashtags), unlist(urls))
names(bdd) <- c("names", "likes", "coms", "signets", "partages", "descriptions", "hashtags", "urls")
write.table(x=bdd[, c(1, 2,3,4,5, 6, 7, 8)], file="bdd_test.csv", sep=";", row.names=FALSE)
