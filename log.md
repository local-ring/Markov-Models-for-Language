11.25
---
Markov models for language: 

A naive but sometimes amusing model for language is a Markov
model. In this model, language is assumed to be a sequence in which the next word is
drawn from a distribution that depends only on the current word. The model can be
elaborated slightly to one in which the next word depends on the current word along with
the previous m words, for some fixed value of m.
You will write functions that fit such models from text and that generate new text from the
fitted model. You can use as input text either the books we used in homework 1 or text of
your choice.

11.29
---

Train with files {pg244, pg1661} (we firstly trained on data of small size, i.e. two books, to see if the code is working well. Otherwise, we have to wait for 10 minutes until the program finish training and give us the feedback) 

n=2: <s>masterpiece (sarcastic way) </s>

Sample 1:

> Scene.” “is such a winding staircases, and the streets. “you should be nothing whatever. there was not appear to an exceeding small.” john h. for any rate.’ she bade me to love of an exceeding thinness. i only are one or hypertext form. any statements concerning tax identification number of the lid from the shuttered up. water some time to have removed it all about forty-three or else had already deeply as i had no other,’ said he; “my cabby drove fast. i fancy.” “good god!” i ran up the rolling cloud of any part of bakers, and discontinue all

Sample 2:

> Then composed himself, shrugged his story. “i shall call her, but the sunlight beneath us. we should dwell. you want, then?’ i gave a tall, stout official police to night. he squeezed out again. she left to warn you can get rid of those whom i have them with pleasure. “i’ll follow the disappearance of the streets which you gentlemen should be some most singular adventures of compliance. to mine has.” “your conversation i cried a stir, sir,” cried a moment to a wash,” remarked sherlock holmes cut himself seems to which looked round the injuries. there lay as good%

---

11.30
---

Training text used:

- A Study in Scarlet: pg244.txt
- The Sign of the Four: pg2097.txt 
- The Hound of the Baskervilles: pg2852.txt
- The Valley of Fear: pg3289.txt 

- The Adventures of Sherlock Holmes: pg1661.txt
- The Memoirs of Sherlock Holmes: pg834.txt 
- The Return of Sherlock Holmes: pg108.txt
- His Last Bow: Some Later Reminiscences of Sherlock Holmes: pg2350.txt 
- The Case-Book of Sherlock Holmes: pg69700.txt

TODO:
- train the model and store locally
- preprocess (mainly clean) the data 
- special token for start and end of a sentence:
    replace puntuation by \<s\>, \</s\>
- add a separate section to take care of punctuation
- generalize to n-gram 
    - one method: n-gram -> next word, if not exist, n-1-gram ...
    - weight for each previous words
- add laplace smoothing/ other fancy smoothing
- train and store the markov transition prob locally (hashmap in R?)
- two way for initialize given by user/pick randomly
- UI
- evaluation of model: perplexity
- use tm for text mining
- LSTM using keras maybe

12.5
---
n=3

> The papers about a hundred yards or so from the serpentine?” “no. they were paying a pound a day should be stopped.’ “‘you must speak to me that he would receive some message or remonstrance from young as to this man, stangerson?” “i did as i have good reason for leaving them was sir george burnwell is. it is really to the full project gutenberg™ license. you must return the medium on which you may demand a refund from the sierra blanco—so we shall just have time to take no notice of the same result. night was still smiling in

with input "sherlock homles":
> Sherlock holmes returned. he came home and changed my dress, again i just didn’t know what became of him.” “it seems to me that i am going mad. sometimes i think i could not say so, but he has accumulated the fruits of his companions with them? jefferson hope promptly, remembering the countersign which he held out his story. “do you remember in her interests. young mccarthy for all that. go where i liked and do not pronounce him to the deductions and your state’s laws. the foundation’s ein or federal tax identification number is 64-6221541. contributions to the conclusion

> Sherlock holmes stepped briskly into the city of ours, it is a queer case though, and i sent james off to france upon the desk?” “well, but china?” “the fish that you will find that drebber’s house was the thought had hardly listened to all they had driven the cab. \</s\> \<s\> “why does fate play such tricks with poor, helpless worms? \</s\> \<s\> now we must go back to claim me until he came to london, then, and the stars were shining coldly in a pitiable state of reaction, with every nerve of his adventure. \</s\> \<s\> ‘would to

> Sherlock  holmes  would  hurry  on,  sometimes  stop  dead,  and  once  at  our  website  which  has  occurred  to  separate  us,  i  was  surprised  to  find  the  man  who  had  had  so  far  as  the  handcuffs  clattered  upon  his  forehead.  What  are  you  doing  with  yourself,  watson.  Draw  your  chair.  It  was  of  excellent  material,  a  sort  of  eastern  divan,  upon  which  he  had  not  been  so  persistently  floating  about.  Look  out  for  that  purpose  30,000  napoleons  from  the  bank  of  france.  It  was  indeed  a  gigantic  ball  and  tossed  in  a  cab  back  to  her.  What!  Asked  holmes.  Good  god!  What!


model trained on all text:
> However, is an exit through a newspaper but that is why i want to go to a dusky red as he went indoors. May have happened since i have said, young adair was fond of her husband had not yet made up my mind that we had left him collapsed in the basket but there were footfalls outside, the door. No tricks, now, or oh, you are, by your equipment. Many were the men. None. How was it a cut with the utmost excitement not only was printed in gold on the ground with some gruffness. Possess our souls. Holmes laughed.

> Sherlock holmes cover the memoirs , the chief proof of a refined and sensitive nature. You would do such a hatred of napoleon the first green shoots upon the lawn and trees on each side, and gazed some time with it, the other side. This is a non profit 501 c 3 educational corporation organized under the terms of the night on guard over him to impose his odious vices upon a matter of love for his life, for example? I signed the certificate in due form of law. Slaney shrugged his shoulders. We approached the house in the exuberance of my face looked so peaceful if all was safe with me.

with feed "I am":
> I am a brain, watson? By the absence of a child with a wicket. But i know that you were complaining that you made me suspect, and given away you may have to say? Then, with an apology for my old companion s guidance, we made sure that you said that we do not believe in such a single cottage at the top of the most virulent kind? I brought a pack can track a trailed herring across a shire, how far we had only to follow her? As he laid the débris before me. But what we can only guess that in the evening, visiting a friend of the world, and lost our man!

with feed "I am a doctor":
> I am a doctor in his eyes, you re not going to be made, too, remarked holmes as he stared out into the midst of a reed filled lake is no better case within the little problem comes your way, you have got several thousands for them. They have scuttled the craft. But there are a weak man in some way be found at the side. The main facts of the pilgrims pale faced maiden. She got better at last, i should like to have cleared up! What sort of society. Have you in solving a problem of the country doctor.

with no feed:
> Hushed voice, staring blankly up over the trees was extinguished, and from him. Us , mark you. I will leave my bureau and brought us to drive to hampstead. Dear me, this is recent, quite recent. This ground. It may be said. 'you fool. There could be between your turning the horse, with the triphammer an absurd idea," said the girl drew a small and elegant impression left by tires