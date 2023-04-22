#!/usr/bin/env python
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize
import platform
import os
import sys

VERSION = '0.6.5' #ensure UCTODATAVERSION in ucto_wrapper.pyx is accurate


includedirs = []
libdirs = []

if platform.system() == "Darwin":
    #we are running on Mac OS X (with homebrew hopefully), stuff is in specific locations:
    if platform.machine().lower() == "arm64":
        libdirs.append("/opt/homebrew/lib")
        includedirs.append("/opt/homebrew/include")
        libdirs.append("/opt/homebrew/icu4c/lib")
        includedirs.append("/opt/homebrew/icu4c/include")
        libdirs.append("/opt/homebrew/libxml2/lib")
        includedirs.append("/opt/homebrew/libxml2/include")
        includedirs.append("/opt/homebrew/libxml2/include/libxml2")
    else:
        libdirs.append("/usr/local/opt/icu4c/lib")
        includedirs.append("/usr/local/opt/icu4c/include")
        libdirs.append("/usr/local/opt/libxml2/lib")
        includedirs.append("/usr/local/opt/libxml2/include")
        includedirs.append("/usr/local/opt/libxml2/include/libxml2")
        #libdirs.append("/usr/local/opt/libtextcat/lib")
        #includedirs.append("/usr/local/opt/libtextcat/include/libtextcat")


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

if platform.system() == "Darwin":
    extra_options = ["--stdlib=libc++",'-D U_USING_ICU_NAMESPACE=1']
else:
    extra_options = ['-D U_USING_ICU_NAMESPACE=1']

extensions = cythonize([ Extension("ucto",
                [ "libfolia_classes.pxd", "ucto_classes.pxd", "ucto_wrapper.pyx"],
                language='c++',
                include_dirs=includedirs,
                library_dirs=libdirs,
                libraries=['ucto','folia'],
                extra_compile_args=['--std=c++0x'] + extra_options,
                ) ], compiler_directives={"language_level": "3"})


setup(
    name = 'python-ucto',
    version = VERSION,
    author = 'Maarten van Gompel',
    author_email = "proycon@anaproy.nl",
    description = ("This is a Python binding to the tokenizer Ucto. Tokenisation is one of the first step in almost any Natural Language Processing task, yet it is not always as trivial a task as it appears to be. This binding makes the power of the ucto tokeniser available to Python. Ucto itself is a regular-expression based, extensible, and advanced tokeniser written in C++ (https://languagemachines.github.io/ucto)."),
    license = "GPLv3",
    keywords = "tokenizer tokenization tokeniser tokenisation nlp computational_linguistics ucto",
    url = "https://github.com/proycon/python-ucto",
    ext_modules = extensions,
    cmdclass = {'build_ext': build_ext},
    requires=['ucto (>=0.29)'],
    install_requires=['Cython'],
    data_files = [("sources",["ucto_wrapper.pyx"])],
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Cython",
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
)
