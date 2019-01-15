.. image:: http://applejack.science.ru.nl/lamabadge.php/python-ucto
   :target: http://applejack.science.ru.nl/languagemachines/

.. image:: https://zenodo.org/badge/20030361.svg
   :target: https://zenodo.org/badge/latestdoi/20030361

Ucto for Python
=================

This is a Python binding to the tokeniser Ucto. Tokenisation is one of the first step in almost any Natural Language Processing task, yet it is not always as trivial a task as it appears to be. This binding makes the power of the ucto tokeniser available to Python. Ucto itself is a regular-expression based, extensible, and advanced tokeniser written in C++ (https://languagemachines.github.io/ucto).

Installation
----------------

Easy
~~~~~~~~~~


* On **Debian/Ubuntu Linux**: check if the package ``python-ucto`` or ``python3-ucto`` is available already.
* On **Arch Linux**, use the `python-ucto-git <https://aur.archlinux.org/packages/python-ucto-git/>_` package from the Arch User Repository (AUR).
* In all other cases, for easy installation of both python-ucto as well as ucto itself, please use our LaMachine distribution (https://proycon.github.io/LaMachine)

Manual (Advanced)
~~~~~~~~~~~~~~~~~~

* Make sure to first install ucto itself (https://languagemachines.github.io/ucto) and all its dependencies.
* Install Cython if not yet available on your system: ``$ sudo apt-get cython cython3`` (Debian/Ubuntu, may differ for others)
* Clone this repository and run:  ``$ sudo python setup.py install``   (Make sure to use the desired version of python)

Advanced note: If the ucto libraries and includes are installed in a non-standard location,
you can set environment variables INCLUDE_DIRS and LIBRARY_DIRS to point to
them prior to invocation of ``setup.py install``.

Usage
---------------------

Import and instantiate the ``Tokenizer`` class with a configuration file.

.. code:: python

    import ucto
    configurationfile = "tokconfig-eng"
    tokenizer = ucto.Tokenizer(configurationfile)


The configuration files supplied with ucto are named ``tokconfig-xxx`` where
``xxx`` corresponds to a three letter iso-639-3 language code. There is also a
``tokconfig-generic`` one that has no language-specific rules. Alternatively,
you can make and supply your own configuration file. Note that for older
versions of ucto you may need to provide the absolute path, but the latest
versions will find the configurations supplied with ucto automatically. See
`here <https://github.com/LanguageMachines/uctodata/tree/master/config>`_ for a
list of available configuration in the latest version.

The constructor for the ``Tokenizer`` class takes the following keyword
arguments:

* ``lowercase`` (defaults to ``False``) -- Lowercase all text
* ``uppercase`` (defaults to ``False``) -- Uppercase all text
* ``sentenceperlineinput`` (defaults to ``False``) -- Set this to True if each
  sentence in your input is on one line already and you do not require further
  sentence boundary detection from ucto.
* ``sentenceperlineoutput`` (defaults to ``False``) -- Set this if you want
  each sentence to be outputted on one line. Has not much effect within the
  context of Python.
* ``sentencedetection`` (defaults to ``True``) -- Do sentence boundary
  detection.
* ``paragraphdetection`` (defaults to ``True``) -- Do paragraph detection.
  Paragraphs are simply delimited by an empty line.
* ``quotedetection`` (defaults to ``False``) -- Set this if you want to enable
  the experimental quote detection, to detect quoted text (enclosed within some
  sort of single/double quote)
* ``debug`` (defaults to ``False``) -- Enable verbose debug output

Text is passed to the tokeniser using the ``process()`` method, this method
returns the number of tokens rather than the tokens itself. It may be called
multiple times in sequence. The tokens
themselves will be buffered in the ``Tokenizer`` instance and can be
obtained by iterating over it, after which the buffer will be cleared:

.. code:: python

    #pass the text (a str) (may be called multiple times),
    tokenizer.process(text)

    #read the tokenised data
    for token in tokenizer:
        #token is an instance of ucto.Token, serialise to string using str()
        print(str(token))

        #tokens remember whether they are followed by a space
        if token.isendofsentence():
            print()
        elif not token.nospace():
            print(" ",end="")

The ``process()`` method takes a single string (``str`` in Python 3,
``unicode`` in Python 2), as parameter. The string may contain newlines, and
newlines are not necessary sentence bounds unless you instantiated the
tokenizer with ``sentenceperlineinput=True``.

Each token is an instance of ``ucto.Token``. It can be serialised to string
using ``str()`` (Python 3), as shown in the example above. In Python 2, use ``unicode()`` instead.

The following methods are available on ``ucto.Token`` instances:
* ``isendofsentence()`` -- Returns a boolean indicating whether this is the last token of a sentence.
* ``nospace()`` -- Returns a boolean, if ``True`` there is no space following this token in the original input text.
* ``isnewparagraph()`` -- Returns ``True`` if this token is the start of a new paragraph.
* ``isbeginofquote()``
* ``isendofquote()``
* ``tokentype`` -- This is an attribute, not a method. It contains the type or class of the token (e.g. a string like  WORD, ABBREVIATION, PUNCTUATION, URL, EMAIL, SMILEY, etc..)

In addition to the low-level ``process()`` method, the tokenizer can also read
an input file and produce an output file, in the same fashion as ucto itself
does when invoked from the command line. This is achieved using the
``tokenize(inputfilename, outputfilename)`` method:

.. code:: python

    tokenizer.tokenize("input.txt","output.txt")

Input and output files may
be either plain text, or in the `FoLiA XML format <https://proycon.github.io/folia>`_.  Upon instantiation of the ``Tokenizer`` class, there
are two keyword arguments to indicate this:

* ``xmlinput`` or ``foliainput`` -- A boolean that indicates whether the input is FoLiA XML (``True``) or plain text (``False``). Defaults to ``False``.
* ``xmloutput`` or ``foliaoutput`` -- A boolean that indicates whether the input is FoLiA XML (``True``) or plain text (``False``). Defaults to ``False``.

An example for plain text input and FoLiA output:

.. code:: python

    tokenizer = ucto.Tokenizer(configurationfile, foliaoutput=True)
    tokenizer.tokenize("input.txt", "ucto_output.folia.xml")

FoLiA documents retain all the information ucto can output, unlike the plain
text representation. These documents can be read and manipulated from Python using the
``pynlpl.formats.folia`` module, part of `PyNLPl
<https://github.com/proycon/pynlpl>`_. FoLiA is especially recommended if
you intend to further enrich the document with linguistic annotation. A small
example of reading ucto's FoLiA output using this library follows, but consult the `documentation <http://pynlpl.readthedocs.io/en/latest/folia.html>`_ for more:

.. code:: python

    import pynlpl.formats.folia
    doc = folia.Document(file="ucto_output.folia.xml")
    for paragraph in doc.paragraphs():
        for sentence in paragraph.sentence():
            for word in sentence.words()
                print(word.text(), end="")
                if word.space:
                    print(" ", end="")
            print()
        print()

Test and Example
~~~~~~~~~~~~~~~~~~~

Run and inspect ``example.py`` (Python 3) or ``example2.py`` (Python 2) for examples.








