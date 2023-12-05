# S610 Final Project: Markov Models for Language:

We have three files

- text process: preprocess.R
- train on the text to get markov transition dataframe: training.R
- generate the text based on the model (UI): main.R
- final.R contains all the functions with the comments helped me think


We have three folders:

- `model`: contains the model (Markov transition dataframe and last word-punctuation dataframe) trained.
- `train`: contains the legal downloaded trainning text. All available novels of Sherlock Holmes.
- `book`: contains the some books professor provided for first assignment. User could train if you don't like Sherlock Holmes.

## 

run main.R in R shell by typing below command in any shell (zsh for MacOS for example)
```
R
```
and then
```
source('main.R')
```
The context you input should have at least n-1 words if you choose n-gram model.
