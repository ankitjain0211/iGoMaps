//
//  ViewController.m
//  iGoMaps
//
//  Created by Ankit on 16/10/13.
//  Copyright (c) 2013 Ankit. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController ()
{
    GMSMapView *googleMapView;
    CLLocationManager *locationManager;
    GMSCameraPosition *mapViewCamrePosition;
}

@end

@implementation ViewController

@synthesize view;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Add Google Maps
    [self updateMapView];
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
    googleMapView = [GMSMapView mapWithFrame:self.view.bounds camera:mapViewCamrePosition];
    //[self customiseTrafficeToggleSwitch];
    
    [googleMapView setMyLocationEnabled:YES];
    [googleMapView setBuildingsEnabled:YES];
    //[googleMapView setDelegate:self];
    [googleMapView setMapType:kGMSTypeNormal];
    
    [self.view addSubview:googleMapView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
