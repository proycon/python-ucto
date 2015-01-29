#!/usr/bin/env python
from distutils.core import setup, Extension
from Cython.Distutils import build_ext
import glob
import os
import sys

from os.path import expanduser
HOMEDIR = expanduser("~")
VERSION = '0.2'

if sys.version < '3':
    extensions = [ Extension("ucto",
                    [ "ucto_classes.pxd", "ucto_wrapper2.pyx"],
                    language='c++',
                    include_dirs=[HOMEDIR + '/local/include/','/usr/include/', '/usr/include/libxml2','/usr/local/include/' ],
                    library_dirs=[HOMEDIR + '/local/lib/','/usr/lib','/usr/local/lib'],
                    libraries=['ucto','folia'],
                    pyrex_gdb=True
                    ) ]

    setup(
        name = 'python-ucto',
        version = VERSION,
        ext_modules = extensions,
        cmdclass = {'build_ext': build_ext},
        requires=['ucto (>=0.8.0)'],
        classifiers=[
            "Development Status :: 4 - Beta",
            "Topic :: Text Processing :: Linguistic",
            "Programming Language :: Cython",
            "Programming Language :: Python :: 2.6",
            "Programming Language :: Python :: 2.7",
            "Operating System :: POSIX",
            "Intended Audience :: Developers",
            "Intended Audience :: Science/Research",
            "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        ],
    )
else:
    extensions = [ Extension("ucto",
                    [ "ucto_classes.pxd", "ucto_wrapper.pyx"],
                    language='c++',
                    include_dirs=[HOMEDIR + '/local/include/','/usr/include/', '/usr/include/libxml2','/usr/local/include/' ],
                    library_dirs=[HOMEDIR + '/local/lib/','/usr/lib','/usr/local/lib'],
                    libraries=['ucto','folia'],
                    pyrex_gdb=True
                    ) ]

    setup(
        name = 'python-ucto',
        version = VERSION,
        ext_modules = extensions,
        cmdclass = {'build_ext': build_ext},
        requires=['ucto (>=0.8.0)'],
        classifiers=[
            "Development Status :: 4 - Beta",
            "Topic :: Text Processing :: Linguistic",
            "Programming Language :: Cython",
            "Programming Language :: Python :: 3",
            "Operating System :: POSIX",
            "Intended Audience :: Developers",
            "Intended Audience :: Science/Research",
            "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        ],
    )
