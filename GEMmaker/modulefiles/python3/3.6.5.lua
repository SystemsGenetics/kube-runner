-- -*- lua -*-
whatis("Description: Python is a widely used general-purpose, high-level programming language. This is the first program installed by JohnHadish on Kamiak, so be aware of this when using.")

prepend_path("PATH", "/usr/local/Python-3.6.5/bin")
prepend_path("LD_LIBRARY_PATH", "/usr/local/Python-3.6.5/lib")
prepend_path("CPATH", "/usr/local/Python-3.6.5/include")
prepend_path("MANPATH", "/usr/local/Python-3.6.5/man")


--[[
Compiled with: gcc 6.1.0
Build:
    $ ./configure --prefix=/usr/local/Python-3.6.5
    $ make -j20
    $ make install
    # wget https://bootstrap.pypa.io/get-pip.py
    # python get-pip.py --prefix=/usr/local/python-3.6.5
--]]

