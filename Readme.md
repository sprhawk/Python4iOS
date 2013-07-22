A Python build script (with patches) for iOS
============================================

Tested for Python 2.7.5, under Xcode 4.6.3 (iOS SDK 6.1)

Default Modules:
All standard modules bundled with Python 2.7.5 (Almost, except that the module requirement is not supported under iOS, eg, socketmodule, which uses select it seems not supported under iOS)

Third party modules:
zope.interface and Twisted ( no RPC/portmap supported )

> before you use any loadable module, you must call its initXXX function to load it by default

Usage:
-----

1. The script **build_libpython.sh** will clean current source directory (Python-2.7.5), download Python-2.7.5.tar.bz2 if not exists from python.org, and then extract the source tallball..

2. The script will first build a native (x86) Python for HOST build.

3. Build python for each i386 armv7 armv7s

4. Combine all core specific architecture .a into one universal lib, libpython2.7.a, which are under build/universal directory. Then the script will clean .py and .pyc files under universal directory, only preserve .pyo lib files.

    > All .c files under Modules are combined and archived as separated .a files. There are two reasons, one is that in normal building process, some modules (eg, cmathmodule and mathmodule) share some same code base (eg, the two modules share _math.c), and the all .c files it needs are linked togther into one .so file (that is, cmathmodule.c and _math.c are linked into cmathmodule.so, and mathmodule.c and _math.c are linked into mathmodule.so), the .SOs are loaded dynamically. But due to our static linking, the originally linking process will archive duplicated module (_math.c) multiple times, which will cause "duplicate sympols" error.

    > The other reason is, some modules have own depends (such as sqlite, openssl, etc), if there is a big .a file, when your project has a -all_load linker flag, you will be crazy to satisfy all the libs requirements.

    > The drawback to the solution is any time you want to add some support to a module, you will add the module .a file by yourself, it may be tedious work.

    > And dependencies between modules must be satisfied by yourself either.


5. Now, you can copy libpython2.7.a, all include headers, all lib/python2.7/* into your own iOS project, and add header files into your search path, add .a files into your build phrase, depends on your need, add your required modules into your Bundle.
    See $7 for details about c extensions.
    (Or you can use package.sh to bundle all libpython, twisted, zope.interface to pythonlib directory which is used in python.xcodeproj)
6. Initialize your Python environment:

    ```objc
    NSString * rootPath = [[NSBundle mainBundle] resourcePath];
    Py_SetPythonHome((char *)[rootPath cStringUsingEncoding:NSUTF8StringEncoding]);
    Py_OptimizeFlag = 1; //If you are using .pyo files
    Py_Initialize();
    ```

7. About extensions:
    When/before a c module/extension is imported by Python, an initXXX() function need to be called. Because all lib here are static, we must call them by your self. 

8. build_zope_interface.sh and build_twisted.sh are for zope.interface and Twisted lib respectively.

9. Enjoy Python on iOS!


Known Issues
============
1. Cannot use socket module under iOS (unsupported ?)
2. Automatically generated initsocket() is wrong, should be init_socket();
3. Many libs for sqlite module are named incorrectly, eg, sqlitemodule as libmodule.a, etc
4. Missing init_struct()
5. All unit tests for Python are included into the lib, but in a production mode, they are not required. Need a option to remove unit test code out of pakcage
6. Cannot suppress warning of "32-bit absolute address out of range"


TODO:
======
Modules: PIL


About how I build the scripts(in Chinese): http://blog.yang.me/2013/07/22/690/
