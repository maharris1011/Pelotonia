//
//  IntroViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 3/9/14.
//
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

@synthesize showPelotoniaButton;

- (NSDate *)cutoffDate {
    // original string
    NSString *str = [NSString stringWithFormat:@"2018-04-04"];
    
    // convert to date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    NSDate *dte = [dateFormat dateFromString:str];
    NSLog(@"Date: %@", dte);
    return dte;
}

- (BOOL)shouldShowPelotoniaButton
{
    NSDate *today = [NSDate date];
    NSDate *cutoff = [self cutoffDate];
    
    return ([today compare:cutoff] == NSOrderedAscending ? true : false);
}

- (void)showHidePelotoniaButton
{
    self.showPelotoniaButton.hidden = ([self shouldShowPelotoniaButton] ? NO : YES);
}

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
    
    [self showHidePelotoniaButton];
    self.explanationText.text = @"For the 10-year anniversary of Pelotonia, we are releasing a" \
    " new application called PULLL. The Pelotonia app will be retired on May 4th, 2018.";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate

{
    return NO;
    
}

#pragma mark -- UI Actions
- (IBAction)startWalkthrough:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pulllButtonClick:(id)sender {
    // open up the "tell me about pulll" window
    [self gotoPull];
}

- (void)gotoPull {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.pulll.org"] options:@{} completionHandler:nil];
}

@end
