//
//  HelpViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "HelpViewController.h"
#import "Settings.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
{
    Settings *settings;
}

@synthesize scrollView;
@synthesize helpLabel;

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
    
    self.title=@"Help";
    
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
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
}

@end
