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
import sys
cimport libfolia_classes
cimport ucto_classes

UCTODATAVERSION = "0.9.1"

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
                sys.stderr.write("[python-ucto] Argument 'sentencedetection' is deprecated and has no effect, it is always enabled.\n")
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
        cdef vector[string] results = self.tok.getUTF8Sentences()
        cdef vector[string].iterator it = results.begin()
        cdef int sentencecount = len(results)
        while it != results.end():
            yield str(deref(it), 'utf-8').replace("<utt>",'')
            inc(it)

    def lowercase(self):
        return self.tok.getLowercase()

    def uppercase(self):
        return self.tok.getLowercase()

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
                if self.lowercase():
                    tokentext = tokentext.lower()
                elif self.uppercase():
                    tokentext = tokentext.upper()
                yield Token(tokentext, tokentype, role)
                inc(it)


def localpath():
    xdg_config_dir = os.environ.get("XDG_CONFIG_HOME", os.path.join(os.environ.get("HOME",""), ".config"))
    return os.environ.get("UCTODATAPATH", os.path.join(xdg_config_dir,"ucto") )

def installdata(targetdir=None, version=UCTODATAVERSION):
    if targetdir is None:
        targetdir = localpath()
    else:
        targetdir = os.path.join(targetdir,"ucto")
    if os.path.exists(targetdir):
        print(f"Uctodata configuration directory already exists: {targetdir}, refusing to overwrite, please remove it first if you want to install all data anew.", file=sys.stderr)
    else:
        tmpdir=os.environ.get("TMPDIR","/tmp")
        if os.system(f"cd {tmpdir} && mkdir -p {targetdir} && wget -O uctodata.tar.gz https://github.com/LanguageMachines/uctodata/releases/download/v{version}/uctodata-{version}.tar.gz && tar -xzf uctodata.tar.gz && cd uctodata-{version} && mv config/* {targetdir}/ && cd .. && rm -Rf uctodata-{version} && rm -Rf uctodata.tar.gz") != 0:
            raise Exception("Installation failed")
        print(f"Installation of uctodata {version} complete", file=sys.stderr)
        if os.path.isdir("/usr/share/libexttextcat"):
            if os.system(f"cd {targetdir} && wget -O textcat.cfg https://raw.githubusercontent.com/LanguageMachines/ucto/master/config/textcat.cfg") != 0:
                raise Exception("Installation of textcat.cfg failed")
        else:
            print("Language detection will not be available unless you install libexttextcat and rerun installdata()", file=sys.stderr)
















