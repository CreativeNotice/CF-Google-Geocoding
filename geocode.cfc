/**
* Provides easy access to Googles Geocoding API. See https://developers.google.com/maps/documentation/geocoding/ for API instructions.
* Copyright (C) 2014 Ryan Mueller. Released under The MIT License (MIT). 
* Contribute to this project at https://github.com/CreativeNotice/CF-Google-Geocoding.
* @displayname CF-Google-Geocoding
* @author      Ryan Mueller
* @created     2014-09-03
*/
component accessors='true' {

	/**
	 * The Google API endpoint URL.
	 */
	property string endpoint;

	/**
	 * Google supports 'json' or 'xml' response types.
	 * Note: At the time of this writing, this component only supports JSON.
	 */
	property string response_type;

	/**
	 * Google allows several address types to be requested
	 * https://developers.google.com/maps/documentation/geocoding/#Types
	 */
	property string result_type;

	/**
	 * You can send Google a pipe (|) delimited list of locations types to limit results too.
	 * https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding
	 */
	property string location_type;

	/**
	 * The address you want to geocode
	 */
	property string address;

	/**
	 * A latitude,longitude coordinates to do a reverse address request.
	 * See https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding
	 */
	property string lat_lng;

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
	property string api_key;

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
	 * Initializes our component default settings or user preferred settings.
	 * You may pass in your API key at component initialization by passing it in the api_key argument. If your app will use the same key, then just insert the API key below.
	 * If you're using the HTTPS URL for the API endpoint, you may need to add Google's SSL certificate to your java keyring.
	 * @displayname   Init
	 * @key           The Google API key is technically optional, but API usage counts will be applied to your IP rather than application without one.
	 * @response_type The type of response you'd like to see from Google. Defaults to 'json'. Google supports 'json' or 'xml' types.
	 * @endpoint      The API URL.
	 */
	public component function init( string api_key, required string response_type='json', required string endpoint='http://maps.googleapis.com/maps/api/geocode/' ){

		// Set our parameters if their values have been passed through during initialization.
		// We have to set defaults here because CF9 or earlier doesn't use the default value of a property unless you're using ORM.
		if( structKeyExists(arguments, 'api_key') && len(arguments.api_key) ){ variables.api_key = arguments.api_key; }
		variables.response_type = arguments.response_type;
		variables.endpoint      = arguments.endpoint;

		return this;
	};

	/**
	 * Performs an address lookup. Provide a latitude, longitude string and get back address(es).
	 * See https://developers.google.com/maps/documentation/geocoding/#ReverseGeocoding.
	 * @displayname   Get Reverse Geocode
	 * @lat_lng       The latitude,longitude CSV
	 * @result_type   The type of result you'd like to see.
	 * @location_type The type of location to limit results to.
	 * @simple        If true we return only the essential address and type. If false we return the entire API response.
	 */
	public struct function getReverseGeocode( required string lat_lng, string result_type, string location_type, required boolean simple=TRUE ){

		// Check that we have a good lat_lng string
		// regex would match 40.714224,-73.961452
		if( reFind('\d+\.\d+\,\-*\d+\.\d+', arguments.lat_lng, FALSE) ){

			// Store the latitude and longitude we're to look up
			variables.lat_lng = arguments.lat_lng;
			
			// Store the optional parameters if provided
			if( structKeyExists(arguments, 'result_type') && len(arguments.result_type) )    { variables.result_type   = arguments.result_type; }
			if( structKeyExists(arguments, 'location_type') && len(arguments.location_type) ){ variables.location_type = arguments.location_type; }

			// Do the API request
			var request  = makeApiRequest();

			// We'll store our response in this structure
			var response = {};

			// If we're requested a simplified format then build it in the request structure
			if( arguments.simple ){

				// Simplify the raw API response before returning
				var simple_struct = {
					'formatted_address' = request.results[1].formatted_address,
					'location_type'     = request.results[1].types[1]
				};

				response = simple_struct;

			}else{
				// Simplified response was NOT requested so let's just return the raw API response
				response = request;
			}

			return response;

		}else{
			throw('Please use the correct format for lat_lng. E.g. 40.714224,-73.961452');
		}
	};

	/**
	 * Performs an address lookup and returns the latitude and longitude.
	 * @address    The address that you want to geocode.
	 * @components The component filters, separated by a pipe (|). Each component filter consists of a component:value pair and will fully restrict the results from the geocoder. For more information see https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering.
	 * @bounds     The bounding box of the viewport within which to bias geocode results more prominently. This parameter will only influence, not fully restrict, results from the geocoder. See https://developers.google.com/maps/documentation/geocoding/#Viewports.
	 * @language   The language in which to return results. If language is not supplied, the geocoder will attempt to use the native language of the domain from which the request is sent wherever possible.
	 * @region     The region code, specified as a ccTLD ("top-level domain") two-character value. This parameter will only influence, not fully restrict, results from the geocoder. See https://developers.google.com/maps/documentation/geocoding/#RegionCodes.
	 * @simple     If true, we return a structure containing only essential parts of the results. If false, we return the entire API response.
	 */
	public struct function getGeocode( string address, string components, string bounds, string language, string region, required boolean simple=TRUE ){

		// Check that we have either an address or components argument
		if( structKeyExists(arguments, 'address') || structKeyExists(arguments, 'components') ){

			// Store the optional parameters if provided
			if( structKeyExists(arguments, 'address') && len(arguments.address) )      { variables.address    = arguments.address; }
			if( structKeyExists(arguments, 'components') && len(arguments.components) ){ variables.components = arguments.components; }
			if( structKeyExists(arguments, 'bounds') && len(arguments.bounds) )        { variables.bounds     = arguments.bounds; }
			if( structKeyExists(arguments, 'language') && len(arguments.language) )    { variables.language   = arguments.language; }
			if( structKeyExists(arguments, 'region') && len(arguments.region) )        { variables.region     = arguments.region; }

			// Do the API request
			var request  = makeApiRequest();

			// We'll store our response in this structure
			var response = {};

			// If we're requested a simplified format then build it in the request structure
			if( arguments.simple ){

				// Simplify the raw API response before returning
				var simple_struct = {
					'formatted_address' = request.results[1].formatted_address,
					'location'          = request.results[1].geometry.location,
					'location_type'     = request.results[1].geometry.location_type
				};

				response = simple_struct;

			}else{
				// Simplified response was NOT requested so let's just return the raw API response
				response = request.result;
			}

			return response;

		}else{
			throw('You must provide either an address or component filter string in order to perform a geocode request.');
		}
	};

	/**
	 * Performs the API http request. 
	 * Remember if you're using the HTTPS URL for the API, you may need to add Google's SSL certificate to your java keyring.
	 * @displayname Do Request
	 */
	private struct function makeApiRequest(){

		var http = new http();
		http.setMethod( 'get' );
		http.setCharset( 'utf-8' );
		http.setUrl( createFinalURL() );

		var response = DeserializeJSON( http.send().getPrefix().filecontent );

		if( response.status == 'OK' ){
			return response;
		}else{
			// See https://developers.google.com/maps/documentation/geocoding/#StatusCodes
			var addl_error_msg = (structKeyExists(response,'error_message')) ? ' - '& response.error_message: '';
			throw('There was a non-OK response from Google: '& response.status & addl_error_msg);
		}
	};

	/**
	 * Returns a URL string using the property values to build a valid URL for hitting the Google Geocoding API.
	 * @displayname Create Final URL
	 */
	private string function createFinalURL(){

		var url = variables.endpoint & variables.response_type & '?';

		// Do we have an address?
		if( structKeyExists(variables, 'address') ){ url &= 'address='& variables.address; }

		// Do we have a lat,lng pair?
		if( structKeyExists(variables, 'lat_lng') ){ url &= 'latlng='& variables.lat_lng; }

		// Are we passing components?
		if( structKeyExists(variables, 'components') ){ url &= '&components='& variables.components; }

		// Are we applying bounds?
		if( structKeyExists(variables, 'bounds') ){ url &= '&bounds='& variables.bounds; }

		// Passing in a language?
		if( structKeyExists(variables, 'language') ){ url &= '&language='& variables.language; }

		// What about a region?
		if( structKeyExists(variables, 'region') ){ url &= '&region='& variables.region; }

		// What about a location type?
		if( structKeyExists(variables, 'location_type') ){ url &= '&location_type='& variables.location_type; }

		// What about a result type?
		if( structKeyExists(variables, 'result_type') ){ url &= '&result_type='& variables.result_type; }

		// Do we have an API Key?
		if( len(variables.api_key) ){ url &= '&key='& variables.api_key; }

		return url;
	};
}