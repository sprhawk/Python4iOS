A Python build script (with patches) for iOS
============================================

Tested for Python 2.7.5, under Xcode 4.6.3 (iOS SDK 6.1)

Usage:
-----

1. The script **build_libpython.sh** will clean current source directory (Python-2.7.5), download Python-2.7.5.tar.bz2 if not exists from python.org, and then extract the source tallball..

2. The script will first build a native (x86) Python for HOST build.

3. Build python for each i386 armv7 armv7s

4. Combine all generated .a into one universal lib, one is libpython2.7.a, the other is liball_extensions.a, which are under build/universal directory. Then the script will clean .py and .pyc files under universal directory, only preserve .pyo lib files.

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
