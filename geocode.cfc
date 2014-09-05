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
	 * @hint The Google API endpoint URL.
	 */
	property string endpoint;

	/**
	 * @hint Google supports 'json' or 'xml' response types.
	 */
	property string output_type;

	/**
	 * @hint The address you want to geocode
	 */
	property string address;

	/**
	 * @hint A component filter for which you wish to obtain a geocode. The components filter will also be accepted as an optional parameter if an address is provided. 
	 * @see  https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
	 */
	property string components;

	/**
	 * @hint The bounding box of the view port within which to bias geocode results more prominently.
	 * @see  https://developers.google.com/maps/documentation/geocoding/#Viewports
	 */
	property string bounds;

	/**
	 * @hint Your application's API key. This key identifies your application for purposes of quota management.
	 * @see  https://developers.google.com/maps/documentation/geocoding/#api_key
	 */
	property string key;

	/**
	 * @hint The language in which to return results. If language is not supplied, the geocoder will attempt to use the native language of the domain from which the request is sent wherever possible.
	 * @see  https://developers.google.com/maps/faq#languagesupport
	 */
	property string language;

	/**
	 * @hint The region code, specified as a ccTLD ("top-level domain") two-character value. This parameter will only influence, not fully restrict, results from the geocoder.
	 * @see  https://developers.google.com/maps/documentation/geocoding/#RegionCodes
	 */
	property string region;

	/**
	 * @displayname Init
	 * @hint        Initializes our component default settings and allows for user preferred settings.
	 * @returntype  component
	 */
	public function init( string key, string output_type, string endpoint, string address, string latlng, string components, string language, string region, string bounds ){
		
		// You may set your Google application API Key here or pass it through at initialization.
		// Using an API key is optional but allows for API usage limits to be applied per application not per IP.
		// https://developers.google.com/maps/documentation/geocoding/#api_key
		var api_key = (structKeyExists(arguments,'key') && len(arguments.key)) ? trim(arguments.key) : 'XXXXXXXXXXXXXXXX';

		// Some defaults
		// We have to set defaults here because CF9 or earlier doesn't use the default value of a property unless you're using ORM.
		// https://bugbase.adobe.com/index.cfm?event=bug&id=3041756
		var output       = (structKeyExists(arguments,'output_type') && len(arguments.output_type)) ? trim(arguments.output_type) : 'json';
		var endpoint_url = (structKeyExists(arguments,'endpoint') && len(arguments.endpoint)) ? trim(arguments.endpoint) : 'http://maps.googleapis.com/maps/api/geocode/';


		// Set our parameters if their values have been passed through during initialization.
		setKey(api_key);
		setOutput_type(output);
		setEndpoint(endpoint_url);

		if( structKeyExists(arguments,'address') )   { setAddress( trim(arguments.address) ); }
		if( structKeyExists(arguments,'latlng') )    { setAddress( trim(arguments.latlng) ); }
		if( structKeyExists(arguments,'components') ){ setAddress( trim(arguments.components) ); }
		if( structKeyExists(arguments,'language') )  { setAddress( trim(arguments.language) ); }
		if( structKeyExists(arguments,'region') )    { setAddress( trim(arguments.region) ); }
		if( structKeyExists(arguments,'bounds') )    { setAddress( trim(arguments.bounds) ); }

		return this;
	};

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