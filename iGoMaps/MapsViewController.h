//
//  MapsViewController.h
//  iGoMaps
//
//  Created by Ankit on 16/10/13.
//  Copyright (c) 2013 Ankit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SVGeocoder.h"

@interface MapsViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *mapsBgView;

@end
