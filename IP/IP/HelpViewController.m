//
//  HelpViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "HelpViewController.h"
#import "AppDelegate.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
{
    AppDelegate *appDelegate;
}

@synthesize scrollView;
@synthesize helpLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Help";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    NSString *helpString=@"Help\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n"
    
    "This is help page!\n\n";
    
    [helpLabel setNumberOfLines:0];
    helpLabel.font=[UIFont systemFontOfSize:17];
    helpLabel.lineBreakMode=NSLineBreakByWordWrapping;
    helpLabel.text=helpString;
    
    CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:helpLabel.font, NSFontAttributeName, nil];
    
    CGSize actualSize=[helpString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    helpLabel.frame=CGRectMake(20, 20, self.view.frame.size.width-40, actualSize.height);
    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+20);
    [scrollView addSubview:helpLabel];
}

@end
