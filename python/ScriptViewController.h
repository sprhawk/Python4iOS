//
//  ScriptViewController.h
//  python
//
//  Created by YANG HONGBO on 2013-7-21.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScriptViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *scriptTextView;
- (IBAction)evaluate:(id)sender;

@end
