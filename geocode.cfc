/**
* @displayname CF-Google-Geocoding
* @description Provides easy access to Googles Geocoding API. See https://github.com/CreativeNotice/CF-Google-Geocoding.
* @see         https://developers.google.com/maps/documentation/geocoding/
* @author      Ryan Mueller
* @created     2014-09-03
* @accessors   true
* @output      false
*/
component {

	/**
	 * The Google API endpoint URL.
	 */
	property string endpoint;

	/**
	 * Google supports 'json' or 'xml' response types.
	 */
	property string responsetype;

	/**
	 * The address you want to geocode
	 */
	property string address;

	/**
	 * A latitude,longitude coordinates to do a reverse address request.
	 * See https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding
	 */
	property string latlng;

	/**
	 * A component filter for which you wish to obtain a geocode. The components filter will also be accepted as an optional parameter if an address is provided. 
	 * See https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
	 */
	property string components;

	/**
	 * The bounding box of the view port within which to bias geocode results more prominently.
	 * See https://developers.google.com/maps/documentation/geocoding/#Viewports
	 */
	property string bounds;

	/**
	 * Your application's API key. This key identifies your application for purposes of quota management.
	 * See https://developers.google.com/maps/documentation/geocoding/#api_key
	 */
	property string key;

	/**
	 * The language in which to return results. If language is not supplied, the geocoder will attempt to use the native language of the domain from which the request is sent wherever possible.
	 * See https://developers.google.com/maps/faq#languagesupport
	 */
	property string language;

	/**
	 * The region code, specified as a ccTLD ("top-level domain") two-character value. This parameter will only influence, not fully restrict, results from the geocoder.
	 * See https://developers.google.com/maps/documentation/geocoding/#RegionCodes
	 */
	property string region;

	/**
	 * Initializes our component default settings and allows for user preferred settings.
	 * You may pass in your API key at component initialization by passing it in the key argument. If your app will use the same key, then just insert the API key below.
	 * @displayname  Init
	 * @key          The Google API key is technically optional, but API usage counts will be applied to your IP rather than application without one.
	 * @responsetype The type of response you'd like to see from Google. Defaults to 'json'. Google supports 'json' or 'xml' types.
	 * @endpoint     The API URL.
	 * @returntype   component
	 */
	public function init( required string key='', required string responsetype='json', required string endpoint='http://maps.googleapis.com/maps/api/geocode/' ){

		// Set our parameters if their values have been passed through during initialization.
		// We have to set defaults here because CF9 or earlier doesn't use the default value of a property unless you're using ORM.
		setKey( trim(api_key) );
		setResponseType( trim(output) );
		setEndpoint( trim(endpoint_url) );

		return this;
	};

	/**
	 * Performs a reverse address lookup. Provide a latitude, longitude string and get back address(es).
	 * See https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding.
	 * @displayname  Get Address
	 * @resulttype   The type of result you'd like to see.
	 * @locationtype The type of location to look for.
	 * @simple       If true we return only the first address structure. If false we return the entire API response.
	 * @returntype   Struct
	 */
	public function getAddress( required string latlng, required string resulttype='street_address', required string locationtype='ROOFTOP', required boolean simple=TRUE ){

		// Check that we have a good latlng string
		// regex will match 40.714224,-73.961452
		if( reFind('\d+\.\d+\,\-*\d+\.\d+', trim(arguments.latlng), FALSE) ){

			setLatLng( trim(arguments.latlng) );
			setResultType( trim(arguments.resulttype) );
			setLocationType( trim(arguments.locationtype) );

			var request = doRequest();

			// @TODO: Format a simplified response
			if( arguments.simple ){
				// Simplify the raw API response before returning
				var simple = {};

				return simple;

			}else{
				// Raw API response should be returned
				return request;
			}

		}else{
			throw('Please use the correct format for LatLng. E.g. 40.714224,-73.961452');
		}
	};

	/**
	 * Performs an address lookup and returns the latitude and longitude.
	 * @address    The address that you want to geocode.
	 * @components The component filters, separated by a pipe (|). Each component filter consists of a component:value pair and will fully restrict the results from the geocoder. For more information see https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering.
	 * @bounds     The bounding box of the viewport within which to bias geocode results more prominently. This parameter will only influence, not fully restrict, results from the geocoder. See https://developers.google.com/maps/documentation/geocoding/#Viewports.
	 * @language   The language in which to return results. If language is not supplied, the geocoder will attempt to use the native language of the domain from which the request is sent wherever possible.
	 * @region     The region code, specified as a ccTLD ("top-level domain") two-character value. This parameter will only influence, not fully restrict, results from the geocoder. See https://developers.google.com/maps/documentation/geocoding/#RegionCodes.
	 * @simple     If true, we return a structure containing only the latitude and longitude. If false, we return the entire API response.
	 * @returntype Struct
	 */
	public function getGeocode( string address, string components, string bounds, string language, string region, required boolean simple=TRUE ){

	};

	private function doRequest(){};

	/**
	 * @displayname Create Final URL
	 * @hint        Returns a URL string using the property values to build a valid URL for hitting the Google Geocoding API.
	 * @returntype  String
	 */
	private function createFinalURL(){

		var url = getEndpoint() & getOutput_type() & '?';

		// Do we have an address?
		if( len( getAddress() ) ){ url &= 'address='& getAddress(); }

		// Are we passing components?
		if( len( getComponents() ) ){ url &= '&components='& getComponents(); }

		// Are we applying bounds?
		if( len( getBounds() ) ){ url &= '&bounds='& getBounds(); }

		// Passing in a language?
		if( len( getLanguage() ) ){ url &= '&language='& getLanguage(); }

		// What about a region?
		if( len( getRegion() ) ){ url &= '&region='& getRegion(); }

		// Do we have an API Key?
		if( len( getKey() ) ){ url &= '&key='& getKey(); }

		return url;
	};
}