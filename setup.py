#!/usr/bin/env python
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
import glob
import os
import sys

from os.path import expanduser
HOMEDIR = expanduser("~")
VERSION = '0.4.2'


includedirs = []
libdirs = []
if os.path.exists(HOMEDIR + "/local/include"): includedirs.append(HOMEDIR + '/local/include/')
if os.path.exists(HOMEDIR + "/local/lib"): libdirs.append(HOMEDIR + '/local/lib/')

if os.path.exists("/usr/local/Cellar"):
   #we are running on Mac OS X with homebrew, stuff is in specific locations:
    for pkg in ('icu4c', 'libxml2'):
        if os.path.isdir("/usr/local/Cellar/" + pkg):
            versiondir = None
            for _versiondir in sorted(glob.glob("/usr/local/Cellar/" + pkg + "/*")):
                if os.path.isdir(_versiondir): versiondir = _versiondir
            if versiondir is not None:
                if os.path.exists(versiondir + "/include"):
                    includedirs.append(versiondir + "/include")
                if os.path.exists(versiondir + "/lib"):
                    libdirs.append(versiondir + "/lib")

#add some common default paths
includedirs += ['/usr/include/', '/usr/include/libxml2','/usr/local/include/']
libdirs += ['/usr/lib','/usr/local/lib']

if 'VIRTUAL_ENV' in os.environ:
    includedirs.insert(0,os.environ['VIRTUAL_ENV'] + '/include')
    libdirs.insert(0,os.environ['VIRTUAL_ENV'] + '/lib')
if 'INCLUDE_DIRS' in os.environ:
    includedirs = list(os.environ['INCLUDE_DIRS'].split(':')) + includedirs
if 'LIBRARY_DIRS' in os.environ:
    libdirs = list(os.environ['LIBRARY_DIRS'].split(':')) + libdirs

if sys.version < '3':
    extensions = [ Extension("ucto",
                    [ "libfolia_classes.pxd", "ucto_classes.pxd", "ucto_wrapper2.pyx"],
                    language='c++',
                    include_dirs=includedirs,
                    library_dirs=libdirs,
                    libraries=['ucto','folia'],
                    extra_compile_args=['--std=c++0x'],
                    ) ]
else:
    extensions = [ Extension("ucto",
                    [ "libfolia_classes.pxd", "ucto_classes.pxd", "ucto_wrapper.pyx"],
                    language='c++',
                    include_dirs=includedirs,
                    library_dirs=libdirs,
                    libraries=['ucto','folia'],
                    extra_compile_args=['--std=c++0x'],
                    ) ]


setup(
    name = 'python-ucto',
    version = VERSION,
    author = 'Maarten van Gompel',
    author_email = "proycon@anaproy.nl",
    description = ("This is a Python binding to the tokenizer Ucto. Tokenisation is one of the first step in almost any Natural Language Processing task, yet it is not always as trivial a task as it appears to be. This binding makes the power of the ucto tokeniser available to Python. Ucto itself is a regular-expression based, extensible, and advanced tokeniser written in C++ (https://languagemachines.github.io/ucto)."),
    license = "GPL",
    keywords = "tokenizer tokenization tokeniser tokenisation nlp computational_linguistics ucto",
    url = "https://github.com/proycon/python-ucto",
    ext_modules = extensions,
    cmdclass = {'build_ext': build_ext},
    requires=['ucto (>=0.9.6)'],
    install_requires=['Cython'],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Cython",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
)
