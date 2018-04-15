//
//  IntroViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 3/9/14.
//
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController

- (IBAction)startWalkthrough:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *explanationText;
@property (strong, nonatomic) IBOutlet UIButton *showPelotoniaButton;
@property (strong, nonatomic) IBOutlet UIButton *pulllButton;

@end
