# first we need to import the data for training

setwd("/Users/aolongli/Desktop/2023-Fall/S610/S610-final-project") 
library(dplyr)

# read the data from the folder 
# directory is the directory of the folder
load_train_data <- function(directory){
  # first we need to get the directory of training folder
  booklist <- list.files(directory, full.names=TRUE)
  
  # read the data from book in the booklist
  train <- lapply(booklist, readr::read_file) %>% unlist()
  train_data <- paste(train, collapse = " ")
  return(train_data)
}


# we should preprocess the data, turn it into lowercase
# also, I want to remove any non-alphanumeric characters except for punctuation
# , . ! ?

preprocess <- function(text){
  text <- tolower(text)
  text <- gsub("[^[:alnum:],.!?]", " ", text)
  return(text)
}

tokenize_words <- function(text){
  # not sure if we need to split it with \\s+ or \\W+
  # now I think it would be more general to use \\s+ so that we keep
  # the punctuation. but let us start with the \\W+ first 
  tokens <- unlist(strsplit(text, "\\s+"))
  return(tokens)
}


tokenize_sentences <- function(text){
  # split text into sentences with punctuation
  pattern <- "(?<!\\w\\d[.])(?<![A-Z][a-z][.])(?<=[.!?])\\s+"
  sentences <- unlist(strsplit(text, pattern, perl = TRUE))
  return(sentences)
}

a <- tokenize_sentences("This is a sentence containing Mr. feet 2.3 life. ha!")
print(a)

last_word_p <- function(text) {
  # first we need to split the text into sentences
  sentences <- tokenize_sentences(text)
  # create a dataframe to store the last word of each sentence and its punctuation
  sentence_endings <- lapply(sentences, function(sentence) {
    # extract the last word
    last_word <- sub("\\W+$", "", sentence)
    last_word <- tail(unlist(strsplit(last_word, "\\s+")), 1)
    last_word <- paste(last_word, "")
    
    punctuation <- regmatches(sentence, regexpr("\\W+$", sentence))
    
    data.frame(last_word = last_word, 
               punctuation = punctuation, 
               stringsAsFactors = FALSE)
  })
  
  df <- do.call(rbind, sentence_endings)
  
  tran_df <- df %>% 
    group_by(last_word, punctuation) %>%  
    summarise(count = n(), .groups = 'drop') %>% # count occurrences of each combination
    group_by(last_word) %>% # normalize to get the transition probability
    mutate(prob = count/sum(count)) %>% 
    ungroup() %>% 
    select(last_word, punctuation, prob)
  
  return(tran_df)
}

add_special_token <- function(text){
  # add start and end tokens to each sentence
  # first we need to split the text into sentences
  sentences <- tokenize_sentences(text)
  
  # add start and end tokens to each sentence
  sentences <- lapply(sentences, function(sentence) {
    # paste("<s>", sentence, "</s>")
    # replace the last punctuation with </s>
    sentence <- sub("\\W+$", " </s>", sentence)
  })
  
  text <- paste(sentences, collapse = " ")
  return(text)
}


# now we need to get the n_gram transition probability, 
# i.e. P(w_i|w_i-1, w_i-2, ..., w_i-n)
# first we need to get the n_grams
generate_n_grams <- function(tokens, n=2){
  # generate the n_grams (w_i-n + 1, w_i-n+1, ..., w_i)
  n_grams <- lapply(1:(length(tokens)-n+1), function(i) tokens[i:(i+n-1)])
  
  # we divide the n_grams into n-1 words and the last word 
  # the last word is the word we want to predict
  n_grams <- lapply(n_grams, function(x) list(x[1:(n-1)], x[n]))
  
  # flatten the vector for future computation of transition probability
  n_grams <- lapply(n_grams, function(n_gram) {
    c(paste(n_gram[[1]], collapse = " "),
      n_gram[[2]])
  })
  
  return(n_grams)
}


# now we get the transition probability of the words for the markov model
generate_transition_prob <- function(n_grams){
  # we need to set up a table to store the transition probability
  # the row is the previous n-1 words, the column is the current word
  # the value is the transition probability
  
  # df <- data.frame(matrix(0, nrow = 0, ncol = 0))
  
  # now we populate the df with x[1:(n-1)] as previous, x[n] as current
  df <- do.call(rbind, lapply(n_grams, function(x) {
    data.frame(previous = x[1], current = x[2])
  }))
  
  # now we need to get the transition probability
  # we need to group by previous and current, and then get the count
  # for each group
  transition_prob <- df %>% 
    group_by(previous, current) %>%  
    summarise(count = n(), .groups = 'drop') %>% # count occurrences of each combination
    group_by(previous) %>% # normalize to get the transition probability
    mutate(prob = count/sum(count)) %>% 
    ungroup() %>% 
    select(previous, current, prob)
  
  return(transition_prob)
}


# now we can train the model using the functions above
train_model <- function(directory, n=2){
  # first we need to get the text and preprocess it
  train_data <- load_train_data(directory)
  text <- preprocess(train_data)
  
  # get the ending words and punctuation df
  last_word <- last_word_p(text)
  
  # add start and end tokens to each sentence
  
  text <- add_special_token(text)
  tokens <- tokenize_words(text)
  
  ##### now we are going to get the transition probability ####
  
  # then we need to generate the n_grams
  n_grams <- generate_n_grams(tokens, n)
  
  # then we need to get the transition probability
  transition_prob <- generate_transition_prob(n_grams)
  
  model <- list(transition_prob = transition_prob, 
                last_word = last_word)
  
  return(model)
}

generate_text <- function(model, len, feed = "", n = 2){
  # first we need to get the transition probability
  transition_prob <- model$transition_prob
  last_word_prob <- model$last_word
  
  # then we need to get the first word
  # if the user feed some context, we use the context as the first ngram
  # if not, we randomly sample the first word
  if (feed != ""){
    first_ngram <- tolower(feed)
    if (length(feed) >= len){
      stop("The length of the feed is longer than the length of the text requested")
    }
  }
  else {
    first_ngram <- sample(transition_prob$previous, 1)
  }
  
  # first split the first ngram into words
  first_ngram <- unlist(strsplit(first_ngram, "\\s+"))
  
  text <- character(0)
  text <- c(text, first_ngram)
  
  # then we need to get the rest of the text
  word_count <- length(text)
  i <- length(text) + 1 # the index of the next word
  
  while (word_count < len | text[length(text)] != "</s>"){
    # get the previous n-1 words
    
    start <- i-1 - (n-2)
    end <- i-1
    
    previous_ngram <- text[start:end]
    previous_ngram <- paste(previous_ngram, collapse = " ")
    
    
    # get the possible next words at i-th position
    next_words <- transition_prob %>% 
      filter(previous == previous_ngram) 
    
    # get the current word
    current_word <- sample(next_words$current, 1, prob = next_words$prob)
    
    
    if (current_word != "</s>") {
      word_count <- word_count + 1
    }
    
    # add the current word to the text
    text <- c(text, current_word)
    i <- i + 1
  }
  
  ### remove end token with punctuation ###
  print(text)
  
  for (i in 1:length(text)){
    if (text[i] == "</s>"){
      prev_word <- text[i-1]
      print(prev_word)
      prev_word <- paste(prev_word, "")
      available_punctuation <- last_word_prob%>%
        filter(last_word == prev_word)
      print(available_punctuation)
      punctuation <- sample(available_punctuation$punctuation,
                            1,
                            prob = available_punctuation$prob)
      text[i] <- punctuation
    }
  }
  
  ###
  
  return(text)
}



# now we need to print the text, a readable version
# we will capitalize the first letter of the first word and the words after
# the punctuation. 
# Also, we add space between the words 
# if the next word is a punctuation, no need to add a space.

capitalize_first_letter <- function(text){
  text <- paste0(toupper(substr(text, 1, 1)), 
                 substr(text, 2, nchar(text)))
  return(text)
}


generate_readable_text <- function(text){
  # first we need to capitalize the first letter of the first word
  text[1] <- capitalize_first_letter(text[1])
  
  # then we need to capitalize the first letter of the word after the punctuation
  for (i in 2:length(text)){
    if (text[i-1] %in% c(".", "?", "!")){
      text[i] <- capitalize_first_letter(text[i])
    }
  }
  
  # then we need to add space between the words
  # if the next word is a punctuation, no need to add a space.
  for (i in 2:length(text)){
    if (text[i] %in% c(".", "?", "!")){
      text[i - 1] <- paste0(text[i - 1], text[i])
      text[i] <- ""
    } else {
      text[i-1] <- paste(text[i-1], "")
    } 
  }
  
  # return plain text as a string
  text <- paste(text, collapse = "")
  
  return(text)
}

basic_model <- train_model("train", 3)
# now we can use the model to generate the text
sample <- generate_text(basic_model, 100, n=3, feed = "i am a")
sample
cat(generate_readable_text(sample))

# save the model
saveRDS(basic_model, "basic_model.rds")