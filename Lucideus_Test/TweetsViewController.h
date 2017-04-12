//
//  TweetsViewController.h
//  Lucideus_Test
//
//  Created by Jyoti Kumari on 11/04/17.
//  Copyright © 2017 Jyoti Kumari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import <CoreLocation/CoreLocation.h>


@interface TweetsViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>{
    
    NSMutableArray *imagesURLArray;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}
@property(nonatomic, retain) IBOutlet UICollectionView *imagesCollectionView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) IBOutlet UITextField *searchTxdFiled;
-(IBAction)searchBtnClicked:(id)sender;
@end
