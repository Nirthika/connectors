package org.wso2.ballerina.connectors.twitter;

import ballerina.net.http;
import ballerina.net.uri;
import ballerina.util;

@Description{ value : "Twitter client connector."}
@Param{ value : "consumerKey: The consumer key of the Twitter account."}
@Param{ value : "consumerSecret: The consumer secret of the Twitter account."}
@Param{ value : "accessToken: The access token of the Twitter account."}
@Param{ value : "accessTokenSecret: The access token secret of the Twitter account."}
public connector ClientConnector (string consumerKey, string consumerSecret, string accessToken, string accessTokenSecret) {

    http:ClientConnector tweeterEP = create http:ClientConnector("https://api.twitter.com", {});

    @Description{ value : "Update the authenticated user's current status."}
    @Param{ value : "status: The text of status update"}
    @Return{ value : "Response object."}
    action tweet(string status) (http:Response) {
        http:Request request = {};
        map parameters = {};
        string urlParams;
        string tweetPath = "/1.1/statuses/update.json";
        status = uri:encode(status);
        parameters["status"] = status;
        urlParams = "status=" + status;

        constructRequestHeaders(request, "POST", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);
        tweetPath = tweetPath + "?" + urlParams;

        http:Response response = tweeterEP.post(tweetPath, request);

        return response;
    }

    @Description{ value : "Retweet a tweet."}
    @Param{ value : "id: The numerical ID of the desired status."}
    @Return{ value : "Response object."}
    action retweet(string id) (http:Response) {
        http:Request request = {};
        map parameters = {};

        string tweetPath = "/1.1/statuses/retweet/" + id + ".json";
        constructRequestHeaders(request, "POST", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);

        http:Response response = tweeterEP.post(tweetPath, request);

        return response;
    }

    @Description{ value : "Untweet a retweeted status."}
    @Param{ value : "id: The numerical ID of the desired status."}
    @Return{ value : "Response object."}
    action unretweet(string id) (http:Response) {
        http:Request request = {};
        map parameters = {};

        string tweetPath = "/1.1/statuses/unretweet/" + id + ".json";
        constructRequestHeaders(request, "POST", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);

        http:Response response = tweeterEP.post(tweetPath, request);

        return response;
    }

    @Description{ value : "Search for tweets."}
    @Param{ value : "query: Query string to retrieve the related tweets."}
    @Return{ value : "Response object."}
    action search(string query) (http:Response) {
        http:Request request = {};
        map parameters = {};
        string urlParams;
        string tweetPath = "/1.1/search/tweets.json";
        query = uri:encode(query);
        parameters["q"] = query;
        urlParams = "q=" + query;
        constructRequestHeaders(request, "GET", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);
        tweetPath = tweetPath + "?" + urlParams;

        http:Response response = tweeterEP.get(tweetPath, request);

        return response;
    }

    @Description{ value : "Retrive a single status."}
    @Param{ value : "id: The numerical ID of the desired status."}
    @Return{ value : "Response object."}
    action showStatus(string id) (http:Response) {
        string urlParams;
        http:Request request = {};
        map parameters = {};

        string tweetPath = "/1.1/statuses/show.json";
        parameters["id"] = id;
        urlParams = "id=" + id;
        constructRequestHeaders(request, "GET", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);
        tweetPath = tweetPath + "?" + urlParams;

        http:Response response = tweeterEP.get(tweetPath, request);

        return response;
    }

    @Description{ value : "Distroy a status."}
    @Param{ value : "id: The numerical ID of the desired status."}
    @Return{ value : "Response object."}
    action destroyStatus(string id) (http:Response) {
        http:Request request = {};
        map parameters = {};

        string tweetPath = "/1.1/statuses/destroy/" + id + ".json";
        constructRequestHeaders(request, "POST", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);

        http:Response response = tweeterEP.post(tweetPath, request);

        return response;
    }

    @Description{ value : "Retrive closest trend locations."}
    @Param{ value : "lat: Latitude of the location."}
    @Param{ value : "long: Longitude of the location"}
    @Return{ value : "Response object."}
    action getClosestTrendLocations(string lat, string long) (http:Response) {
        string urlParams;
        http:Request request = {};
        map parameters = {};

        string tweetPath = "/1.1/trends/closest.json";
        parameters["lat"] = lat;
        urlParams = urlParams + "&lat=" + lat;
        parameters["long"] = long;
        urlParams = urlParams + "&long=" + long;
        constructRequestHeaders(request, "GET", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);
        tweetPath = tweetPath + "?" + urlParams.subString(1, urlParams.length());

        http:Response response = tweeterEP.get(tweetPath, request);

        return response;
    }

    @Description{ value : "Retrive top trends by place."}
    @Param{ value : "locationId: The Yahoo! Where On Earth ID of the location to return trending information for."}
    @Return{ value : "Response object."}
    action getTopTrendsByPlace(string locationId) (http:Response) {
        string urlParams;
        http:Request request = {};
        map parameters = {};

        string tweetPath = "/1.1/trends/place.json";
        parameters["id"] = locationId;
        urlParams = "id=" + locationId;
        constructRequestHeaders(request, "GET", tweetPath, consumerKey, consumerSecret, accessToken,
                            accessTokenSecret, parameters);
        tweetPath = tweetPath + "?" + urlParams;

        http:Response response = tweeterEP.get(tweetPath, request);

        return response;
    }
}

function constructRequestHeaders(http:Request request, string httpMethod, string serviceEP, string consumerKey,
                                 string consumerSecret, string accessToken, string accessTokenSecret, map parameters) {
    int index;
    string paramStr;
    string key;
    string value;

    string timeStamp = currentTime().toString();
    string nonceString = util:uuid();
    serviceEP = "https://api.twitter.com" + serviceEP;

    parameters["oauth_consumer_key"] = consumerKey;
    parameters["oauth_nonce"] = nonceString;
    parameters["oauth_signature_method"] = "HMAC-SHA1";
    parameters["oauth_timestamp"] = timeStamp;
    parameters["oauth_token"] = accessToken;
    parameters["oauth_version"] = "1.0";

    string[] parameterKeys = parameters.keys();
    string[] sortedParameters = parameterKeys.sort();
    while (index < lengthof sortedParameters){
        key =  sortedParameters[index];
        value, _ = (string) parameters[key];
        paramStr = paramStr + key + "=" + value + "&";
        index = index + 1;
    }
    paramStr = paramStr.subString(0, paramStr.length() - 1);
    string baseString = httpMethod + "&" + uri:encode(serviceEP) + "&" + uri:encode(paramStr);
    string keyStr = uri:encode(consumerSecret) + "&" + uri:encode(accessTokenSecret);
    string signature = util:getHmac(baseString, keyStr, "SHA1");
    string oauthHeaderString = "OAuth oauth_consumer_key=\"" + consumerKey +
                "\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"" + timeStamp +
                "\",oauth_nonce=\"" + nonceString + "\",oauth_version=\"1.0\",oauth_signature=\"" +
                uri:encode(signature) + "\",oauth_token=\"" + uri:encode(accessToken) + "\"";

    request.setHeader("Authorization", oauthHeaderString.unescape());
}