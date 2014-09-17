#CF-Google-Geocoding
CFML wrapper for Google's Geocoding API. Using this component it's pretty easy to get the geocode (latitude/longitude) for a known address. Or, you like, provide the geocode and get the closest matching address. 

To learn more about the Geocoding API from Google checkout https://developers.google.com/maps/documentation/geocoding/. Also, any method parameters not documented to your statisfaction are probably already covered in the API documentation so check the Google docs.

Find something incorrect or want to make an addition? Just create an issue, fork, add your fixes/features and send me a pull request.

##Usage

### Init
To get started, instantiate the geocode.cfc object. You can optionally pass in 
* your API key, 
* the type of request to make (only json is supported right now),
* or overwrite the API endpoint URL.

##### Example
```cfc
geocoder = new geocode( 'xxxxxxxxx' ); // init with your Google API key
```

##### Parameters
| Name | Description | Default |
| ---- | ----------- | ------- |
| key  | Your Google API key. This is not always required by Google so [check ](https://developers.google.com/maps/documentation/geocoding/#api_key) if your use-case applies.  | _[empty string]_ |
| responsetype | Google API supports _json_ or _xml_. This component currently supports JSON only. | __json__ |
| endpoint | The Google Geocode API endpoint URL. | __[http://maps.googleapis.com...](http://maps.googleapis.com/maps/api/geocode/)__ |
_Note: if you want to use the HTTPS endpoint that's fine but you may need to import the Google SSL cert into your Java Keyring._

-------------

### getGeocode()
Performs an address lookup and returns the latitude and longitude. There are many optional parameters; I've attempted to include all those supported by the API [https://developers.google.com/.../#geocoding](https://developers.google.com/maps/documentation/geocoding/#geocoding). Note that while both __addresss__ and __components__ parameters are optional, you must pass in at least one of them to perform a valid API call.

##### Example
```cfc
coords = geocoder.getGeocode( '414 Smith St, Gonzales, TX 78629' );
```

##### Properties
| Name | Description | Default |
| ---- | ----------- | ------- |
| address | The address that you want to geocode. | _optional_ |
| components | The component filters, separated by a pipe. Each component filter consists of a component:value pair and will fully restrict the results from the geocoder. | _optional_ |
| bounds | The bounding box of the viewport within which to bias geocode results more prominently. This parameter will only influence, not fully restrict, results from the geocoder. | _optional_ |
| language | The language in which to return results. If language is not supplied, the geocoder will attempt to use the native language of the domain from which the request is sent wherever possible. | _optional_ |
| region | The region code, specified as a ccTLD ("top-level domain") two-character value. This parameter will only influence, not fully restrict, results from the geocoder. | _optional_ |
| simple | If true, we return a structure containing only essential parts of the results. If false, we return the entire API response. | __TRUE__ |

-------------

### getReverseGeocode()
Performs an address lookup. Provide a latitude, longitude string and get back address. See [https://developers.google.com/ ... /geocoding/#ReverseGeocoding](https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding).

##### Example
```cfc
addy = geocoder.getReverseGeocode( '29.5038733,-97.4438835' );
```

##### Paramaters
| Name | Description | Default |
| ---- | ----------- | ------- |
| latlng | The latitude,longitude CSV | _required_ |
| resulttype | The type of result you'd like. | _optional_ |
| locationtype | The type of location to limit results to. | _optional_ |
| simple | If true we return only the essential address and type. If false we return the entire API response. | __TRUE__ |