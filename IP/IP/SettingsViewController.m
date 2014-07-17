//
//  SettingsViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController
{
    Settings *settings;
}

@synthesize receiveMessagesLabel;
@synthesize receiveMessageSwitch;
@synthesize fontSizeSegmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
    self.title=@"Settings";
    
    settings=[[Settings alloc]init];
    
    switch (settings.fontSize)
    {
        case 14:
            fontSizeSegmentedControl.selectedSegmentIndex=0;
            break;
        case 18:
            fontSizeSegmentedControl.selectedSegmentIndex=1;
            break;
        case 22:
            fontSizeSegmentedControl.selectedSegmentIndex=2;
            break;
        default:
            break;
    }
    
    [receiveMessageSwitch setOn:settings.receiveMessage];
    if (settings.receiveMessage)
    {
        receiveMessagesLabel.text=@"YES";
    }
    else
    {
        receiveMessagesLabel.text=@"NO";
    }
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
}

- (void)saveButtonClicked
{
    [settings saveSettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchValueChanged:(id)sender
{
    UISwitch *senderSwitch=(UISwitch *)sender;
    if(senderSwitch.on)
    {
        settings.receiveMessage=YES;
        receiveMessagesLabel.text=@"YES";
    }
    else
    {
        settings.receiveMessage=NO;
        receiveMessagesLabel.text=@"NO";
    }
}

- (IBAction)segmentControlValueChanged:(id)sender
{
    if([sender selectedSegmentIndex]==0)
    {
        settings.fontSize=14;
    }
    else if([sender selectedSegmentIndex]==1)
    {
        settings.fontSize=18;
    }
    else
    {
        settings.fontSize=22;
    }
}

@end
