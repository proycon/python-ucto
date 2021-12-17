#*****************************
# Python-ucto
#   by Maarten van Gompel
#   Centre for Language Studies
#   Radboud University Nijmegen
#
#   Licensed under GPLv3
#****************************/

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.set cimport set
from libcpp cimport bool
from libc.stdint cimport *



cdef extern from "ucto/tokenize.h" namespace "Tokenizer":
    cdef cppclass Token:
        string texttostring()
        string typetostring()
        int role

    cdef cppclass TokenizerClass:
        bool init(string & settingsfile) except +

        bool setLowercase(bool)
        bool setUppercase(bool)
        bool setParagraphDetection(bool)
        bool setQuoteDetection(bool)
        bool setSentencePerLineOutput(bool)
        bool setSentencePerLineInput(bool)
        bool setXMLOutput(bool, string & docid)
        bool setXMLInput(bool)
        bool getLowercase()
        bool getUppercase()
        int setDebug(int)

        void tokenize(string,string) nogil
        int tokenizeLine(string &) nogil
        vector[string] getUTF8Sentences() nogil
        vector[Token] popSentence() nogil
