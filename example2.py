#!/usr/bin/env python

import ucto

text = """To be or not to be, that's the question. This is a test to tokenise. We can span
multiple lines!!! The number 6 is Mr Li's favourite. We can't stop yet.

This is the next paragraph. And so it ends"""


#Set a file to use as tokeniser rules, this one is for English, other languages are available too:
settingsfile = "tokconfig-en"

#Initialise the tokeniser, options are passed as keyword arguments, defaults:
#   lowercase=False,uppercase=False,sentenceperlineinput=False,
#   sentenceperlineoutput=False,
#   sentencedetection=True, paragraphdetection=True, quotedetectin=False,
#   debug=False
tokenizer = ucto.Tokenizer(settingsfile)

#pass the text (may be called multiple times),
tokenizer.process(text)

#read the tokenised data
for token in tokenizer:
    #token is an instance of ucto.Token, serialise to string using str()
    print "[" + unicode(token).encode('utf-8') + "]",

    #tokens remember whether they are followed by a space
    if token.isendofsentence():
        print
    elif not token.nospace():
        print " ",

    #the type of the token (i.e. the rule that build it) is available as token.type

#we can continue with more text:
tokenizer.process("This was not enough. We want more text. More sentences are better!!!")

#there is a high-levelinterface to iterate over sentences as string, with all tokens space-separated:
for sentence in tokenizer.sentences():
    print sentence.encode('utf-8')













