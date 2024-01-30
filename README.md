# S610 Final Project: Markov Models for Language

by Aolong Li

We have following files

- `preprocess.R` : text process 
- `training.R`: train on the text to get markov transition dataframe:
- `main.R`: generate the text based on the model (UI): 
- `test.R`: contains test functions to validate the design 
- `final.R`: contains all the functions with the comments helped me think, the most primitive version, included for memorial. The above three are clean and free from my ramble

Also there are several explanatory files like `log.md` which records some result during the developing time, and `final_report.Rmd`.

We have three folders:

- `model`: contains pre-trained models (Markov transition dataframe and last word-punctuation dataframe).
- `train`: contains the legally downloaded trainning text. All available novels of Sherlock Holmes.
- `books`: contains the some books professor provided for first assignment. User could train if you don't like Sherlock Holmes.

## 

run main.R in R shell by typing below command in any shell (zsh for MacOS for example)
```
R
```
and then
```
source('main.R')
```
Or you can run the program directly in the R studio. The reason why you cannot use 
```
Rscript main.R
```
in the shell is that it does not support the interactive UI I designed.

Please be aware that for an n-gram model, your input context should contain a minimum of n-1 words if you would like to start with your customized context (an empty feed is also fine). You will get a warning message if you don't listen to my warm-hearted suggestion lol.

