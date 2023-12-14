# main.R
source("training.R")

# get the input from the user
main <- function(){
  while(TRUE){
    n <- as.integer(readline("Please enter the n: "))
    feed <- readline("Please enter your context: ")
    length <- as.integer(readline("Please enter the total length of text: "))
    new_model <- readline("Do you want to train a new model? (y/n): ")
    
    if (new_model == "y"){
      model <- train_model("train", n)
      saveRDS(model, "model/user_model.rds")
      sample <- generate_text(model, length, n, feed = feed)
      
      cat(generate_readable_text(sample))
    } else {
      # list all valid models
      models <- list.files("model", pattern = "*.rds")
      cat("The following models are available:\n")
      for (i in 1:length(models)){
        cat(models[i], "\n")
      }
      model_name <- readline("Please enter the name of the model: ")
      # load the model
      model_path <- paste0("model/", model_name)
      model <- readRDS(model_path)
      sample <- generate_text(model, length, n, feed = feed)
      cat(generate_readable_text(sample))
    }
    exit <- readline("Do you want to exit? (y/n): ")
    if (exit == "y"){
      break
    }
  }
}

generate_text <- function(model, len=50, feed = "", n = 2){
  transition_prob <- model$transition_prob
  last_word_prob <- model$last_word
  
  if (feed != ""){
    first_ngram <- tolower(feed)
    feed <- unlist(strsplit(feed, "\\s+"))
    if (length(feed) >= len){
      stop("The length of the feed is longer than the length of the text requested")
    }
    else if (length(feed) < n-1){
      stop("The length of the feed is shorter than the n-1")
    }
  }
  else {
    first_ngram <- sample(transition_prob$previous, 1)
  }
  first_ngram <- unlist(strsplit(first_ngram, "\\s+"))

  text <- character(0)
  text <- c(text, first_ngram)

  word_count <- length(text)
  i <- length(text) + 1 

  while (word_count < len | text[length(text)] != "</s>"){
    start <- i-1 - (n-2)
    end <- i-1

    previous_ngram <- text[start:end]
    previous_ngram <- paste(previous_ngram, collapse = " ")

    next_words <- transition_prob %>% 
      filter(previous == previous_ngram) 
    
    if (nrow(next_words) == 0){
      stop("You input some words not included in the training data")
    }

    current_word <- sample(next_words$current, 1, prob = next_words$prob)

  
    if (current_word != "</s>") {
      word_count <- word_count + 1
    }
    
    text <- c(text, current_word)
    i <- i + 1
  }
  
  
  for (i in 1:length(text)){
    if (text[i] == "</s>"){
        prev_word <- text[i-1]
        prev_word <- paste(prev_word, "")
        available_punctuation <- last_word_prob%>%
          filter(last_word == prev_word)
        punctuation <- sample(available_punctuation$punctuation,
                              1,
                              prob = available_punctuation$prob)
        text[i] <- punctuation
    }
  }


  return(text)
}

capitalize_first_letter <- function(text){
  text <- paste0(toupper(substr(text, 1, 1)), 
                 substr(text, 2, nchar(text)))
  return(text)
}


generate_readable_text <- function(text){
  text[1] <- capitalize_first_letter(text[1])
  for (i in 2:length(text)){
    if (text[i-1] %in% c(".", "?", "!")){
      text[i] <- capitalize_first_letter(text[i])
    }
  }

  for (i in 2:length(text)){
    if (text[i] %in% c(".", "?", "!")){
      text[i - 1] <- paste0(text[i - 1], text[i])
      text[i] <- ""
    } else {
      text[i-1] <- paste(text[i-1], "")
    } 
  }
  
  text <- paste(text, collapse = "")
  
  return(text)
}

main()
