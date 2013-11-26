//
//  MapsViewController.m
//  iGoMaps
//
//  Created by Ankit on 16/10/13.
//  Copyright (c) 2013 Ankit. All rights reserved.
//

#import "MapsViewController.h"

@interface MapsViewController ()
{
    GMSMapView *googleMapView;
    CLLocationManager *locationManager;
    GMSCameraPosition *mapViewCamrePosition;
}

@property (nonatomic) SVGeocoder *geoCoder;
@property (strong,nonatomic) NSMutableArray *googleSearchResult;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

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
    
    // Initialize the array
    _googleSearchResult = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Set booking type initial to p2p
    locationManager = [[CLLocationManager alloc] init];
    
    // Location Manager set delegate
    [locationManager setDelegate:self];
    
    // Add Google Maps
    [self updateMapView];
    
    if([self isLocationServiceON])
    {
        [self currentLocation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)currentLocation
{
    // Get current location coord
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coord;
    coord = [location coordinate];
    
    if(coord.latitude != 0 && coord.longitude != 0 )
    {
        // Create a GMSCameraPosition that tells the map to display the
        // current location at zoom level 14.
        
        mapViewCamrePosition = [GMSCameraPosition cameraWithLatitude:coord.latitude
                                                           longitude:coord.longitude
                                                                zoom:14];
        [googleMapView setCamera:mapViewCamrePosition];
    }
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

#pragma mark - Create GMS MAP

- (void)updateMapView {
    
    CLLocationCoordinate2D coord;
    
    //get current Location
    locationManager.delegate = self;
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
    googleMapView.settings.myLocationButton = YES;
    [googleMapView setMyLocationEnabled:YES];
    [googleMapView setBuildingsEnabled:YES];
    [googleMapView setDelegate:self];
    [googleMapView setMapType:kGMSTypeNormal];
    
    [_mapsBgView addSubview:googleMapView];
}

#pragma mark - GMSMapViewDelegate

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    LogTrace(@"%s", __PRETTY_FUNCTION__);
    
    CGPoint point = mapView.center;
    CLLocationCoordinate2D location = [mapView.projection coordinateForPoint:point];
    
    if (self.geoCoder) {
        [self.geoCoder finish];
    }
    
    LogTrace(@"Geocoder called");
    self.geoCoder = [[SVGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.latitude ,location.longitude) completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(placemarks.count){
            NSString *savedValue=[[placemarks objectAtIndex:0] valueForKey:@"formattedAddress" ];
            NSString *savedCity = [[placemarks objectAtIndex:0] valueForKey:@"locality" ];
            NSString *subLocality = [[placemarks objectAtIndex:0] valueForKey:@"subLocality" ];
            
            LogTrace(@"Geocoder response %@ %@, %@", savedValue, savedCity, subLocality);
            _addressLabel.text = savedValue;
        }
    }];
    [self.geoCoder start];
}


#pragma mark Location Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    LogTrace(@"%s", __PRETTY_FUNCTION__);
    if ([self checkForConnection])
    {
        [manager stopUpdatingLocation];
        
        if (self.geoCoder) {
            
            
            
            [SVGeocoder reverseGeocode:CLLocationCoordinate2DMake([newLocation coordinate].latitude, [newLocation coordinate].longitude)
                            completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
                                [googleMapView setUserInteractionEnabled:YES];
                                if(placemarks.count){
                                    NSString *subLocality = [[placemarks objectAtIndex:0] valueForKey:@"subLocality" ];
                                    NSString *savedValue=[[placemarks objectAtIndex:0] valueForKey:@"formattedAddress" ];
                                    NSString *savedCity = [[placemarks objectAtIndex:0] valueForKey:@"locality" ];
                                    LogTrace(@"Geocoder response %@ %@, %@", savedValue, savedCity, subLocality);
                                }
                            }];
        }
        else
        {
            [manager stopUpdatingLocation];
        }
    }
}

#pragma mark - Location Service method

- (BOOL) isLocationServiceON
{
    if( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"To enable, please go to Settings and turn on Location Services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_googleSearchResult count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *cellIdentifier = @"resultcell";
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [_googleSearchResult objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UISearchbar Delegate 
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL isBackButton;
    
    if (range.location != NSNotFound)
    {
        // String was found
        if (range.length == 0)
        {
            isBackButton = NO;
        }
        else
        {
            isBackButton = YES;
        }
    }
    else
    {
        // String not found
        isBackButton = NO;
    }
    
    if (isBackButton)
    {
        NSMutableString *str = [NSMutableString stringWithFormat:@"%@", searchBar.text];
        LogTrace(@"str %@", [str substringToIndex:[str length]-1]);
        if ( [str length] > 1) {
            NSString *paramsString = [NSString stringWithFormat:@"location=%@&radius=%d&sensor=true&input=%@&key=%@&components=country:in",@"Bangalore", 5000, [[[str substringToIndex:[str length]-1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], KGoogleAutocompleteAPIKey];
            [self performSelector:@selector(callGoogleAutocompleteAPIForLocation:) withObject:paramsString afterDelay:0.1];
        }
        else if ([str length] > 0 && [str length] == 1){
            // On clearing text
            // Load cache data
            
        }
    }
    else
    {
        LogTrace(@"str %@", [NSString stringWithFormat:@"%@%@", searchBar.text, text]);
        NSString *str = [NSString stringWithFormat:@"%@%@", searchBar.text, text];
        if ([str length]> 0) {
            NSString *paramsString = [NSString stringWithFormat:@"location=%@&radius=%d&sensor=true&input=%@&key=%@&components=country:in",@"Bangalore", 5000, [[[NSString stringWithFormat:@"%@%@", searchBar.text, text] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], KGoogleAutocompleteAPIKey];
            [self performSelector:@selector(callGoogleAutocompleteAPIForLocation:) withObject:paramsString afterDelay:0.1];
        }
    }
    return YES;
}

#pragma mark - Localities Search API

-(void)callGoogleAutocompleteAPIForLocation:(NSString *)paramsString {
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection]
                                   currentReachabilityStatus];
    
    if(currentStatus == NotReachable)
    {
        return;
    }
    
    NSString *baseUrlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?%@", paramsString];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:baseUrlString]];
    [request setHTTPMethod:@"GET"];
    
    LogTrace(@"URL %@", baseUrlString);
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // Was the request successful ?
        if ([data length] > 0 && error == nil) {
            // Deserialize JSON response
            id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonResponse != nil && error == nil) {
                LogTrace(@"------------------------------------");
                
                NSArray *resultsArray = [[jsonResponse valueForKey:@"predictions"] valueForKey:@"description"];
                // int countValue = [resultsArray count];
                
                // Clear all previous data
                [_googleSearchResult removeAllObjects];
                
                for (int i = 0; i < [resultsArray count]; i++) {
                    [_googleSearchResult addObject:[resultsArray objectAtIndex:i]];
                }
                NSString *searchString = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([searchString length] > 0) {
                    // Add last result as typed text
                    [_googleSearchResult addObject:self.searchBar.text];
                }
                
                LogTrace(@"areaListArray %@", _googleSearchResult);
                
                LogTrace(@"------------------------------------");
            }
        }
    }];
}

#pragma mark - Check Internet Connection

// To Check Internet Connection

-(BOOL)checkForConnection
{
    NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection]
                                   currentReachabilityStatus];
    
    if(currentStatus == NotReachable)
    {
        [self showConnectonError];
        locationManager.delegate = nil;
        return NO;
    }
    else
    {
        return YES;
        //printf("Internet Connection Success");
    }
    
}

// Alert user if internet is unavilable

-(void)showConnectonError
{
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"You appear to be offline!" message:@"We were unable to connect to the network. Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


@end
