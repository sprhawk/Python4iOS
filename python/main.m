//
//  main.m
//  python
//
//  Created by YANG HONGBO on 2013-7-18.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import <Python.h>
#import "pythonmodules.h"
#import "twisted.h"
#import "zope_interface.h"

void init_python();
void unittest_python();

void init_python()
{
    NSString * name = [[NSBundle mainBundle] bundleIdentifier];
    Py_SetProgramName((char *)[name cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString * rootPath = [[NSBundle mainBundle] resourcePath];
    Py_SetPythonHome((char *)[rootPath cStringUsingEncoding:NSUTF8StringEncoding]);
    Py_OptimizeFlag = 1;
    Py_Initialize();
//    PyRun_SimpleString("import sys\n"
//                       "del sys.path[0]\n"
//                       "sys.path.append('')\n");
//    initselect(); //unsupported on iOS ?
    init_collections();
    inititertools();
    initoperator();
    
    init_struct();
    init_io();
    init_functools();
    inittime();
    init_socket();
    initsendmsg();
    initraiser();
    init_zope_interface_coptimizations();
}

void unittest_python()
{
    init_testcapi();//for unit_test
    PyRun_SimpleString("from test.test___all__ import test_main as t\n"
                       "t()");
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        init_python();
        unittest_python();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
