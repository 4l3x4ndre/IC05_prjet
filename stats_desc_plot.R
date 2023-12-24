# ---------------------------------------------------------------------------- #

# Programme utilisé pour générer les graphiques. Il suffit de lancer une 
# fonction pour que l'image correspondante soit enregistrée.

# ---------------------------------------------------------------------------- #



# ----------------- Plot les coms en fonction des likes pour les foryou ------------------
foryou_likes_coms <- function() {
	dev.new(width=1920, height=1080, unit="px")
	jpeg(file=paste0("foryouboxplots", ".jpeg"), width=1920, height=1080)
	labels <- c("likes", "coms")

	bdd <- read.csv("./data/videos_trends/foryou.csv", sep=";")

	bddtoplot <- data.frame(bdd$likes, bdd$coms)
	names(bddtoplot) <- c("likes", "coms")

	plot(x=bddtoplot$likes, y=bddtoplot$coms, xlab="Nombre likes", ylab="Nombre commentaires", ylim=c(0, 100000),xlim=c(0, 5000000))
	title("Nombre commentaires en fonction nombre likes")
	dev.off()


}

#  ---------------------- Rassembler toutes les trends ---------------------
likes <- list()
coms<-list()
partages<- list()
signets <- list()
for (trend in c(1, 2, 3, 4,8,10,11,12,13,14,15,16,18,19,20)) {

	bdd <- read.csv(paste0("./data/videos_trends/v2decouverte-trends-", trend, ".csv"), sep=";")	
	index_base <- 11
	l <- bdd[,index_base]
	c <- bdd[,index_base+1]
	p <- bdd[,index_base+2]
	s <- bdd[,index_base+3]
	for (i in c(1:length(l))) {
		if (!is.na(l[i]) & !is.na(c[i])) {
			likes <- append(likes, l[i])
			coms <- append(coms, c[i])
			partages <- append(partages, p[i])
			signets <- append(signets, s[i])
		}
	}

}


# ---------------- Fonction Test ---------------
plotter <- function(path, x, y, maxx, maxy, c) {
	dev.new(width=2000, height=2000, unit="px")
	jpeg(file=path, width=3000, height = 2000)

	plot(na.omit(x), na.omit(y), pch=16, cex=2,col=c, ylim=c(0, maxy),xlim=c(0, maxx))
	dev.off()
}
#plotter("trends_likesComs_seul.jpeg", likes, coms, 200,200, "blue")





bdd <- read.csv("./data/videos_trends/foryou.csv", sep=";")
bddtoplot <- data.frame(bdd$likes, bdd$coms)






# ------------- Afficher les signets en fonction des coms  ------------
signetsVcoms <- function() {
        w <-1920
        h <- 1080
        dev.new(width=w, height=h, unit="px")
        jpeg(file="comsVsignets_foryou&trends.jpeg", width=w, height = h)
        #par(mfrow=c(1,3))
	print(bdd[,c("coms", "signets")])
        x1 <- na.omit(bdd$coms)
        y1 <- na.omit(bdd$signets)
        x2 <- na.omit(coms)
        y2 <- na.omit(signets)
	print(unlist(x2))
	print(max(unlist(x2)))
        dev.new(width=w, height=h, unit="px")
        jpeg(file="comsVsignets_foryou&trends1.jpeg", width=w, height = h)
        plot(x1, y1, pch=16, cex=2,col="red",  xlab="Coms", ylab="Signets", cex.lab=2, cex.axis=2) #,ylim=c(0, 100000),xlim=c(0, 5000000)
	#axis(2, cex.axis=2)
	legend(1, 2500000, legend=c("foryou", "trends"), fill=c("red", "blue"), cex=1.5)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()

        dev.new(width=w, height=h, unit="px")
        jpeg(file="comsVsignets_foryou&trends2.jpeg", width=w, height = h)
        #plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 10000),xlim=c(0, 1000000), xlab="Coms", ylab="Signets")
        plot(x1, y1, pch=16, cex=2,col="red",  xlab="Coms", ylab="Signets",ylim=c(0, 25000),xlim=c(0, 25000), cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()

        w <-1920
        h <- 1920
        dev.new(width=w, height=h, unit="px")
        jpeg(file="comsVsignets_foryou&trends3.jpeg", width=w, height = h)
        #plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 1000),xlim=c(0, 1000), xlab="Coms", ylab="Signets")
        plot(x1, y1, pch=16, cex=2,col="red",  xlab="Coms", ylab="Signets",ylim=c(0, 5000),xlim=c(0, 5000), cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()

        w <-1920
        h <- 1920
        dev.new(width=w, height=h, unit="px")
        jpeg(file="comsVsignets_foryou&trends4.jpeg", width=w, height = h)
        #plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 200),xlim=c(0, 200), xlab="Coms", ylab="Signets")
        plot(x1, y1, pch=16, cex=2,col="red",  xlab="Coms", ylab="Signets",ylim=c(0, 300),xlim=c(0, 300), cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()
}
#signetsVcoms()

# ------------- Afficher les signets en fonction des likes ------------
signetsVlikes <- function() {
        w <-1920
        h <- 1080
        dev.new(width=w, height=h, unit="px")
        jpeg(file="likesVsignets_foryou&trends.jpeg", width=w, height = h)
        #par(mfrow=c(1,3))
        x1 <- na.omit(bdd$likes)
        y1 <- na.omit(bdd$signets)
        x2 <- na.omit(likes)
        y2 <- na.omit(signets)
        dev.new(width=w, height=h, unit="px")
        jpeg(file="likesVsignets_foryou&trends1.jpeg", width=w, height = h)
        plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 100000),xlim=c(0, 5000000), xlab="Likes", ylab="Signets", cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()

        dev.new(width=w, height=h, unit="px")
        jpeg(file="likesVsignets_foryou&trends2.jpeg", width=w, height = h)
        plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 10000),xlim=c(0, 1000000), xlab="Likes", ylab="Signets", cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()

        w <-1920
        h <- 1920
        dev.new(width=w, height=h, unit="px")
        jpeg(file="likesVsignets_foryou&trends3.jpeg", width=w, height = h)
        plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 1000),xlim=c(0, 1000), xlab="Likes", ylab="Signets", cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()

        w <-1920
        h <- 1920
        dev.new(width=w, height=h, unit="px")
        jpeg(file="likesVsignets_foryou&trends4.jpeg", width=w, height = h)
        plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 200),xlim=c(0, 200), xlab="Likes", ylab="Signets", cex.lab=2, cex.axis=2)
        points(x2, y2, col="blue", cex=2, pch=16)
        dev.off()
}
#signetsVlikes()

# ------------- Afficher les partages en fonction des likes ------------
partagesVlikes <- function() {
	w <-1920 
	h <- 1080
	dev.new(width=w, height=h, unit="px")
	jpeg(file="likesVpartages_foryou&trends.jpeg", width=w, height = h)
	#par(mfrow=c(1,3))
	x1 <- na.omit(bdd$likes)
	y1 <- na.omit(bdd$partages)
	x2 <- na.omit(likes)
	y2 <- na.omit(partages)
	dev.new(width=w, height=h, unit="px")
	jpeg(file="likesVpartages_foryou&trends1.jpeg", width=w, height = h)
	plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 100000),xlim=c(0, 5000000), xlab="Likes", ylab="Partages", cex.lab=2, cex.axis=2)
	points(x2, y2, col="blue", cex=2, pch=16)
	dev.off()

	dev.new(width=w, height=h, unit="px")
	jpeg(file="likesVpartages_foryou&trends2.jpeg", width=w, height = h)
	plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 10000),xlim=c(0, 1000000), xlab="Likes", ylab="Partages", cex.lab=2, cex.axis=2)
	points(x2, y2, col="blue", cex=2, pch=16)
	dev.off()

	w <-1920 
	h <- 1920
	dev.new(width=w, height=h, unit="px")
	jpeg(file="likesVpartages_foryou&trends3.jpeg", width=w, height = h)
	plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 1000),xlim=c(0, 1000), xlab="Likes", ylab="Partages", cex.lab=2, cex.axis=2)
	points(x2, y2, col="blue", cex=2, pch=16)
	dev.off()

	w <-1920 
	h <- 1920
	dev.new(width=w, height=h, unit="px")
	jpeg(file="likesVpartages_foryou&trends4.jpeg", width=w, height = h)
	plot(x1, y1, pch=16, cex=2,col="red", ylim=c(0, 200),xlim=c(0, 200), xlab="Likes", ylab="Partages", cex.lab=2, cex.axis=2)
	points(x2, y2, col="blue", cex=2, pch=16)
	dev.off()
}
#partagesVlikes()
