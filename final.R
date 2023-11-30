# first we need to import the data for training

setwd("/Users/aolongli/Desktop/2023-Fall/S610/final") 
library(dplyr)

# read the data from the folder 
# directory is the directory of the folder
load_train_data <- function(directory){
  # first we need to get the directory of training folder
  booklist <- list.files(directory, full.names=TRUE)
  
  # read the date from book in the booklist
  train <- lapply(booklist, readr::read_file) %>% unlist()
  train_data <- paste(train, collapse = " ")
  # not sure if we need to split it with \\s+ or \\W+
  # now I think it would be more general to use \\s+ so that we keep
  # the punctuation. but let us start with the \\W+ first 
  tokens <- unlist(strsplit(train_data, "\\s+"))
  return(tokens)
}


# we should preprocess the data, turn it into lowercase
# for generating purpose, we can change it back if necessary

preprocess <- function(text){
  text <- tolower(text)
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
  # first we need to get the tokens
  tokens <- load_train_data(directory)
  
  # then we need to preprocess the tokens
  tokens <- preprocess(tokens)
  
  # then we need to generate the n_grams
  n_grams <- generate_n_grams(tokens, n)
  
  # then we need to get the transition probability
  transition_prob <- generate_transition_prob(n_grams)
  
  return(transition_prob)
}

baby_model <- train_model("train", 2)
# now we can use the model to generate the text

generate_text <- function(model, length){
  # first we need to get the transition probability
  transition_prob <- model
  
  # then we need to get the first word
  first_word <- sample(transition_prob$previous, 1)
  
  # then we need to get the second word
  second_word <- sample(transition_prob %>% 
                          filter(previous == first_word) %>% 
                          select(current) %>% 
                          unlist(), 1)
  
  # then we need to get the text
  text <- c(first_word, second_word)
  
  # then we need to get the rest of the text
  for (i in 3:length){
    # get the previous word
    previous_word <- text[i-1]
    
    # get the possibe next words
    next_words <- transition_prob %>% 
      filter(previous == previous_word) %>%
      select(current, prob)
    
    # get the current word
    current_word <- sample(next_words$current, 1, prob = next_words$prob)
    
    # add the current word to the text
    text <- c(text, current_word)
  }
  
  return(text)
}

sample <- generate_text(baby_model, 100)
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
      text[i-1] <- paste(text[i-1], sep = "")
    } else {
      text[i-1] <- paste(text[i-1], sep = " ")
    }
  }
  
  # then we need to add space between the last word and the punctuation
  text[length(text)] <- paste(text[length(text)], sep = "")
  
  return(text)
}

cat(generate_readable_text(sample))



