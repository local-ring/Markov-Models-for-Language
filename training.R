# training.R
source("preprocess.R")

last_word_p <- function(text) {
  sentences <- tokenize_sentences(text)
  sentence_endings <- lapply(sentences, function(sentence) {
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
    summarise(count = n(), .groups = 'drop') %>% 
    group_by(last_word) %>% 
    mutate(prob = count/sum(count)) %>% 
    ungroup() %>% 
    select(last_word, punctuation, prob)
  
  return(tran_df)
}

generate_n_grams <- function(tokens, n=2){
  n_grams <- lapply(1:(length(tokens)-n+1), function(i) tokens[i:(i+n-1)])
  
  n_grams <- lapply(n_grams, function(x) list(x[1:(n-1)], x[n]))
  
  n_grams <- lapply(n_grams, function(n_gram) {
    c(paste(n_gram[[1]], collapse = " "),
      n_gram[[2]])
  })
  
  return(n_grams)
}

generate_transition_prob <- function(n_grams){
  df <- do.call(rbind, lapply(n_grams, function(x) {
    data.frame(previous = x[1], current = x[2])
  }))

  transition_prob <- df %>% 
    group_by(previous, current) %>%  
    summarise(count = n(), .groups = 'drop') %>% 
    group_by(previous) %>%
    mutate(prob = count/sum(count)) %>% 
    ungroup() %>% 
    select(previous, current, prob)
  
  return(transition_prob)
}


train_model <- function(directory, n=2){
  train_data <- load_train_data(directory)
  text <- preprocess(train_data)

  last_word <- last_word_p(text) 

  text <- add_special_token(text)
  tokens <- tokenize_words(text)

  n_grams <- generate_n_grams(tokens, n)
  transition_prob <- generate_transition_prob(n_grams)
  
  model <- list(transition_prob = transition_prob, 
                last_word = last_word)
  
  return(model)
}