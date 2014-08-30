//
//  SettingsViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "Settings.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    BOOL receiveMessage;
}

@synthesize receivePromptLabel;
@synthesize receiveMessagesLabel;
@synthesize receiveMessageSwitch;
@synthesize fontSizeLabel;
@synthesize fontSizeSegmentedControl;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Settings";
    
    settings=[[Settings alloc]init];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *saveButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
    switch (appDelegate.settings.fontSize)
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
    
    receivePromptLabel.textColor=appDelegate.majorColor;
    receiveMessagesLabel.textColor=appDelegate.majorColor;
    fontSizeLabel.textColor=appDelegate.majorColor;
    fontSizeSegmentedControl.tintColor=appDelegate.majorColor;
    
    [receiveMessageSwitch setOn:appDelegate.settings.receiveMessage];
    receiveMessage=appDelegate.settings.receiveMessage;
    if (settings.receiveMessage)
    {
        receiveMessagesLabel.text=@"YES";
    }
    else
    {
        receiveMessagesLabel.text=@"NO";
    }
}

- (void)saveButtonClicked
{
    switch (fontSizeSegmentedControl.selectedSegmentIndex)
    {
        case 0:
            appDelegate.settings.fontSize=14;
            break;
        case 1:
            appDelegate.settings.fontSize=18;
            break;
        case 2:
            appDelegate.settings.fontSize=22;
            break;
        default:
            break;
    }
    
    if (receiveMessage && !receiveMessageSwitch.on)
    {
        // cancel register
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // set local settings
        settings.registeredForNotification=NO;
        
        // set installation object in server
        PFInstallation *currentInstallation=[PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:settings.deviceToken];
        currentInstallation[@"receiveMessage"]=[NSNumber numberWithBool:NO];
        [currentInstallation saveInBackground];
    }
    
    if (!receiveMessage && receiveMessageSwitch.on)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                                            UIRemoteNotificationTypeAlert|
                                                                            UIRemoteNotificationTypeSound];
    }
    
    appDelegate.settings.receiveMessage=receiveMessageSwitch.on;
    [appDelegate.settings saveSettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchValueChanged:(id)sender
{
    UISwitch *senderSwitch=(UISwitch *)sender;
    if(senderSwitch.on)
    {
        receiveMessagesLabel.text=@"YES";
    }
    else
    {
        receiveMessagesLabel.text=@"NO";
    }
}

@end
