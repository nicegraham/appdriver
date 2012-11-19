//
//  DetailViewController.h
//  Automation
//
//  Created by Grace, Darragh on 15/10/2012.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
