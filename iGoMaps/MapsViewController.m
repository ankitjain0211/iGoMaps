//
//  MapsViewController.m
//  iGoMaps
//
//  Created by Ankit on 16/10/13.
//  Copyright (c) 2013 Ankit. All rights reserved.
//

#import "MapsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SVGeocoder.h"

@interface MapsViewController ()
{
    GMSMapView *googleMapView;
    CLLocationManager *locationManager;
    GMSCameraPosition *mapViewCamrePosition;
}

@end

@implementation MapsViewController

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
	// Do any additional setup after loading the view.
    // Add Google Maps
    [self updateMapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create GMS MAP

- (void)updateMapView {
    
    CLLocationCoordinate2D coord;
    
    //get current Location
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    coord.latitude = location.coordinate.latitude;
    coord.longitude = location.coordinate.longitude;
    
    // Create a GMSCameraPosition that tells the map to display the
    // current location at zoom level 14.
    
    mapViewCamrePosition = [GMSCameraPosition cameraWithLatitude:coord.latitude
                                                       longitude:coord.longitude
                                                            zoom:14];
    googleMapView = [GMSMapView mapWithFrame:_mapsBgView.bounds camera:mapViewCamrePosition];
    //[self customiseTrafficeToggleSwitch];
    googleMapView.settings.myLocationButton = YES;
    [googleMapView setMyLocationEnabled:YES];
    [googleMapView setBuildingsEnabled:YES];
    //[googleMapView setDelegate:self];
    [googleMapView setMapType:kGMSTypeNormal];
    
    [_mapsBgView addSubview:googleMapView];
}

#pragma mark - GMSMapViewDelegate

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    
}


@end
