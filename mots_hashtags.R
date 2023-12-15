#install.packages("wordcloud")
#install.packages("tidyverse")
#install.packages("tm")
library(tm)

library(wordcloud)
library(tidyverse)
library(stringr)



hash <- list()
for (trend in c(1, 2, 3, 4,8,10,11,12,13,14,15,16,18,19,20)) {

        bdd <- read.csv(paste0("./data/videos_trends/v2decouverte-trends-", trend, ".csv"), sep=";")
	h <- bdd$hashtags
        for (i in c(1:length(h))) {
                if (!is.na(h[i])) {
                        hash <- append(hash, h[i])
                }
        }

}

hash <- paste(hash, collapse='')
hash <- str_split_1(hash, "#")
#hash <- paste(hash, collapse='')
bddh <- data.frame(hashtags = unlist(hash))
freq <- table(bddh$hashtags)
bddh <- data.frame(hashtags = names(freq), freq = as.numeric(freq))
bddhmoins1<- bddh[bddh$freq==1,]


set.seed(1234)

w <- 2000
h <- 1000
dev.new(width=w, height=h, unit="px")
jpeg(file="#_trends_all.jpeg", width=w, height = h)
par(mfrow=c(1,2))
wordcloud(words = bddh$hashtags, freq = bddh$freq, min.freq = 1, scale=c(6,2), colors=brewer.pal(8, "Dark2"))

to_remove <- bddhmoins1$hashtags
pattern <- paste(to_remove, collapse="|")
hash <- gsub(pattern, "", hash)

corpus <- Corpus(VectorSource(hash))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
#corpus <- tm_map(corpus, removeNumbers)

# Create a document-term matrix
dtm <- DocumentTermMatrix(corpus)

# Convert the document-term matrix to a data frame
word_freq <- as.data.frame(as.matrix(dtm))
# Calculate the total frequency of each word
total_freq <- colSums(word_freq)

# Create a data frame for plotting
plot_data <- data.frame(word = names(total_freq), freq = total_freq)

# Plot the histogram
barplot(plot_data$freq, names.arg = plot_data$word, col = "skyblue", main = "Word Frequency Histogram", xlab = "Words", ylab = "Frequency", cex.names = 0.7
	, cex.lab=2, cex.axis=2)
	#, xlim = c(1, 10),
	 #ylim = c(1, 10))


dev.off()



cloud_foryou <- function() {
	bdd <- read.csv2("./data/videos_trends/foryou.csv")
	#hash = str_extract_all(bdd$hashtags, "#\\w+")
	hash = str_split_1(paste(bdd$hashtags, collapse=''), "#")
	bddh <- data.frame(hashtags = unlist(hash))
	freq <- table(bddh$hashtags)
	bddh <- data.frame(hashtags = names(freq), freq = as.numeric(freq))
	set.seed(1234)
	w<-1000
	h<-1000
	dev.new(width=w, height=h, unit="px")
	jpeg(file="#_foryou.jpeg", width=w, height = h)

	wordcloud(words = bddh$hashtags, freq = bddh$freq, min.freq = 1, scale=c(3,0.5), colors=brewer.pal(8, "Dark2"))


	dev.off()

}
