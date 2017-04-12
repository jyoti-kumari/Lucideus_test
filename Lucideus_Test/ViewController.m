//
//  ViewController.m
//  Lucideus_Test
//
//  Created by Jyoti Kumari on 11/04/17.
//  Copyright © 2017 Jyoti Kumari. All rights reserved.
//

#import "ViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TweetsViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
            //TweetsViewController *tweetsView = [[TweetsViewController alloc] initWithNibName:@"TweetsViewController" bundle:nil];
            TweetsViewController *tweetsView = [self.storyboard instantiateViewControllerWithIdentifier:@"tweetsView"];
            [self.navigationController pushViewController:tweetsView animated:YES];
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
