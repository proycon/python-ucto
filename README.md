Ucto binding for Python
===========

This is a Python binding to the tokenizer Ucto. Tokenisation is one of the first step in almost any Natural Language Processing task, yet it is not always as trivial a task as it appears to be. This binding makes the power of the ucto tokeniser available to Python. Ucto itself is regular-expression based, extensible, and written in C++ (http://ilk.uvt.nl/ucto).

Installation
==============

 * Make sure to first install ucto itself (http://ilk.uvt.nl/ucto or from git http://github.com/proycon/ucto ) and its dependencies
 * Install Cython if not yet available on your system: ``$ sudo apt-get cython cython3`` (Debian/Ubuntu, may differ for others)
 * For Python 3 , run:  ``$ sudo setup3.py install``
 * For Python 2 , run:  ``$ sudo setup2.py install``

Test and Example
================

Run and inspect ``example.py`` (Python 3) or ``example2.py`` (Python 2) for testing and documentation.






