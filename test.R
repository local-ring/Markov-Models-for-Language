setwd("/Users/aolongli/Desktop/2023-Fall/S610/S610-final-project") 
source("preprocess.R")
source("training.R")


# load necessary libraries
library(testthat)
library(dplyr)

# read the data of trained model
model <- readRDS("model/sh_model.rds")
transition_prob <- model$transition_prob
last_word <- model$last_word

# test the transition probability is correct
# - if all of the transition probability is between 0 and 1
# - if the sum of probabilities from the same previous state is 1

test_that("all transition probabilities are between 0 and 1", {
  expect_true(all(transition_prob$prob >= 0 & transition_prob$prob <= 1))
})

test_that("sum of probabilities for each previous state is 1", {
  summed_probs <- transition_prob %>%
    group_by(previous) %>%
    summarise(sum_prob = sum(prob))
  
  expect_true(all(abs(summed_probs$sum_prob - 1) < .Machine$double.eps^0.5))
})


# test the last word probability is correct
# - if all of the probabilities are between 0 and 1
# - if the sum of probabilities is 1

test_that("all last word probabilities are between 0 and 1", {
  expect_true(all(last_word$prob >= 0 & last_word$prob <= 1))
})

test_that("last word probabilities are valid", {
  expect_true(all(last_word$prob >= 0 & last_word$prob <= 1))
  
  summed_last_word_probs <- last_word %>%
    group_by(last_word) %>%
    summarise(sum_prob = sum(prob))
  
  expect_true(all(abs(summed_last_word_probs$sum_prob - 1) < .Machine$double.eps^0.5))
})


test_that("tokenize_words splits text into words correctly", {
  test_text <- "This is a test."
  expected_output <- c("This", "is", "a", "test.")
  expect_equal(tokenize_words(test_text), expected_output)
})

test_that("tokenize_sentences splits text into sentences correctly", {
  test_text <- "This is a sentence. And another one!"
  expected_output <- c("This is a sentence.", "And another one!")
  expect_equal(tokenize_sentences(test_text), expected_output)
})

test_that("generate_n_grams generates correct n-grams", {
  tokens <- c("This", "is", "a", "test")
  n <- 2
  expected_output <- list(c("This", "is"), c("is", "a"), c("a", "test"))
  expect_equal(generate_n_grams(tokens, n), expected_output)
})





