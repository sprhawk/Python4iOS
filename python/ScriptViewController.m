//
//  ScriptViewController.m
//  python
//
//  Created by YANG HONGBO on 2013-7-21.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "ScriptViewController.h"
#import <Python.h>

@interface ScriptViewController ()

@end

@implementation ScriptViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)evaluate:(id)sender {
    const char * string = [self.scriptTextView.text cStringUsingEncoding:NSUTF8StringEncoding];
    PyRun_SimpleString(string);
}
@end
