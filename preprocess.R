# preprocess.R
setwd("/Users/aolongli/Desktop/2023-Fall/S610/S610-final-project") 
library(dplyr)
library(readr)


load_train_data <- function(directory){
  booklist <- list.files(directory, full.names=TRUE)
  train <- lapply(booklist, readr::read_file) %>% unlist()
  train_data <- paste(train, collapse = " ")
  return(train_data)
}


preprocess <- function(text){
  text <- tolower(text)
  text <- gsub("[^[:alnum:],.!?\"']", " ", text)
  return(text)
}

tokenize_words <- function(text){
  tokens <- unlist(strsplit(text, "\\s+"))
  return(tokens)
}


tokenize_sentences <- function(text){
  pattern <- "(?<!\\w\\d[.])(?<![A-Z][a-z][.])(?<=[.!?])\\s+"
  sentences <- unlist(strsplit(text, pattern, perl = TRUE))
  return(sentences)
}

add_special_token <- function(text){
  sentences <- tokenize_sentences(text)
  sentences <- lapply(sentences, function(sentence) {
    sentence <- sub("\\W+$", " </s>", sentence)
  })
  
  text <- paste(sentences, collapse = " ")
  return(text)
}
