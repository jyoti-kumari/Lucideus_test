//
//  TweetsViewController.m
//  Lucideus_Test
//
//  Created by Jyoti Kumari on 11/04/17.
//  Copyright © 2017 Jyoti Kumari. All rights reserved.
//

#import "TweetsViewController.h"
#import <TwitterKit/TwitterKit.h>


@interface TweetsViewController ()

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    imagesURLArray = [[NSMutableArray alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    

    
    
    }

#pragma mark service call method implementation

-(void)requestMethodCalled:(NSString*)hashTagStr{
    [_activityIndicatorView startAnimating];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [DateFormatter stringFromDate:[NSDate date]];
    NSLog(@"Error: %@", dateString);
    
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    
    NSDictionary *params;
    if (currentLocation != nil) {
        NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        NSString *geocodeStr = [NSString stringWithFormat:@"%@,%@,100km", latitude, longitude];
        
        params  = @{@"q" : hashTagStr, @"geocode" : geocodeStr,  @"until" : dateString};
    }
    else{
        params  = @{@"q" : hashTagStr,  @"until" : dateString};
    }
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                NSLog(@"%@", json);
                
                [imagesURLArray removeAllObjects];
                
                NSArray *statusesArray = [json objectForKey:@"statuses"];
                for (int i = 0; i < statusesArray.count; i++) {
                    if ([[[statusesArray objectAtIndex:i] objectForKey:@"entities"] objectForKey:@"media"]) {
                        [imagesURLArray addObject:[[[[[statusesArray objectAtIndex:i] objectForKey:@"entities"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"media_url_https"]];
                    }
                    
                }
                [self.imagesCollectionView reloadData];
                NSLog(@"%@", imagesURLArray);
                
                if (imagesURLArray.count == 0) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"No result found with the Hash tag." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* okButton = [UIAlertAction
                                               actionWithTitle:@"Ok"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                               }];
                    
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
            [_activityIndicatorView stopAnimating];
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [_activityIndicatorView stopAnimating];
    }
    

}

-(IBAction)searchBtnClicked:(id)sender{
    [self requestMethodCalled:[NSString stringWithFormat:@"#%@", _searchTxdFiled.text]];
    [_searchTxdFiled resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}



#pragma mark  delegate and datasource method implementations

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return imagesURLArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"imageCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *hashTagImageView = (UIImageView *)[cell viewWithTag:100];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[cell viewWithTag:200];
    
    hashTagImageView.image = nil;
    

    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [imagesURLArray objectAtIndex:indexPath.row]]];
        
        [activityIndicatorView startAnimating];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            hashTagImageView.image = [UIImage imageWithData:data];
            [activityIndicatorView stopAnimating];
        });
    });
    
    
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImageView *hashTagImageView = (UIImageView *)[cell viewWithTag:100];
    
    hashTagImageView.image = nil;
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations[[locations count] -1];
    currentLocation = newLocation;
    NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    
    if (currentLocation != nil) {
        NSLog(@"latitude: %@", latitude);
        NSLog(@"longitude: %@", longitude);
              }else {
                  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
                  
                  UIAlertAction* okButton = [UIAlertAction
                                             actionWithTitle:@"Ok"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 //Handle your yes please button action here
                                             }];
                  
                  [alert addAction:okButton];
                  [self presentViewController:alert animated:YES completion:nil];
              }
              
    }




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
