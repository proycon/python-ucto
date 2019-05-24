#embedsignature=True
#*****************************
# Python-ucto
#   by Maarten van Gompel
#   Centre for Language Studies
#   Radboud University Nijmegen
#
#   Licensed under GPLv3
#****************************/

from libcpp.string cimport string
from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref, preincrement as inc
from cython import address
from libc.stdint cimport *
from libcpp.utility cimport pair
import os.path
cimport libfolia_classes
cimport ucto_classes

class TokenRole:
    NOROLE                      = 0
    NOSPACE                     = 1
    BEGINOFSENTENCE             = 2
    ENDOFSENTENCE               = 4
    NEWPARAGRAPH                = 8
    BEGINQUOTE                  = 16
    ENDQUOTE                    = 32
    TEMPENDOFSENTENCE           = 64

class Token:
    def __init__(self, text, tokentype, role):
        self.text = text
        self.tokentype = tokentype
        self.role = role

    def __str__(self):
        return self.text

    def type(self):
        return self.tokentype

    def isendofsentence(self):
        return self.role & TokenRole.ENDOFSENTENCE

    def iseos(self): #for lazy people
        return self.role & TokenRole.ENDOFSENTENCE

    def isbeginofsentence(self):
        return self.role & TokenRole.BEGINOFSENTENCE

    def isnewparagraph(self):
        return self.role & TokenRole.NEWPARAGRAPH

    def isbeginofquote(self):
        return self.role & TokenRole.BEGINQUOTE

    def isendofquote(self):
        return self.role & TokenRole.ENDQUOTE

    def nospace(self):
        return self.role & TokenRole.NOSPACE


cdef class Tokenizer:
    cdef ucto_classes.TokenizerClass tok

    def __init__(self, filename, **kwargs):
        self.tok.init(filename.encode('utf-8'))
        for arg, value in kwargs.items():
            if arg == 'lowercase':
                self.tok.setLowercase(value is True)
            elif arg == 'uppercase':
                self.tok.setUppercase(value is True)
            elif arg == 'sentencedetection':
                pass #deprecated
            elif arg == 'paragraphdetection':
                self.tok.setParagraphDetection(value is True)
            elif arg == 'quotedetection':
                self.tok.setQuoteDetection(value is True)
            elif arg == 'sentenceperlineinput':
                self.tok.setSentencePerLineInput(value is True)
            elif arg == 'sentenceperlineoutput':
                self.tok.setSentencePerLineOutput(value is True)
            elif arg == 'xmlinput' or arg == 'foliainput':
                self.tok.setXMLInput(value is True)
            elif arg == 'xmloutput' or arg == 'foliaoutput':
                if 'docid' in kwargs:
                    docid = kwargs['docid']
                else:
                    docid = "untitled"
                self.tok.setXMLOutput(value is True, docid.encode('utf-8'))
            elif arg == 'debug':
                self.tok.setDebug(int(value))
            elif arg == 'docid':
                pass
            else:
                raise ValueError("No such keyword argument: " +  arg)

    def tokenize(self, str inputfile, str outputfile):
        """Run ucto from inputfile to outputfile (like command line tool)"""
        self.tok.tokenize(inputfile.encode('utf-8'), outputfile.encode('utf-8'))



    def process(self, str line):
        """Feed text to the tokeniser. This needs not be a single line."""
        self.tok.tokenizeLine(line.encode('utf-8'))

    def sentences(self):
        cdef vector[string] results = self.tok.getSentences()
        cdef vector[string].iterator it = results.begin()
        cdef int sentencecount = len(results)
        while it != results.end():
            yield str(deref(it), 'utf-8').replace("<utt>",'')
            inc(it)

    def __iter__(self):
        cdef vector[ucto_classes.Token] v
        cdef vector[ucto_classes.Token].iterator it
        while True:
            v = self.tok.popSentence()
            if v.empty():
                break
            it = v.begin()
            while it != v.end():
                tokentext = str(deref(it).texttostring(), 'utf-8')
                tokentype = str(deref(it).typetostring(), 'utf-8')
                role = deref(it).role
                yield Token(tokentext, tokentype, role)
                inc(it)

















