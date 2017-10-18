import ballerina.lang.system;
import ballerina.net.http;
import org.wso2.ballerina.connectors.twitter;
import ballerina.test;

string tweetId;

function init () (twitter:ClientConnector) {
    twitter:ClientConnector twitterConnector;
    string consumerKey = system:getEnv("CONSUMER_KEY");
    string consumerSecret = system:getEnv("CONSUMER_SECRET");
    string accessToken = system:getEnv("ACCESS_TOKEN");
    string accessTokenSecret = system:getEnv("ACCESS_TOKEN_SECRET");
    twitterConnector = create twitter:ClientConnector(consumerKey, consumerSecret, accessToken, accessTokenSecret);
    return twitterConnector;
}


function testTweet () {
    twitter:ClientConnector twitterConnector = init();
    http:Response response = twitterConnector.tweet ("#ballerina");
    json jsonResponse = response.getJsonPayload();
    int status = response.getStatusCode();
    string value = (string)jsonResponse.text;
    tweetId = (string)jsonResponse.id_str;
    system:println("TweetID------- - " + tweetId);
    test:assertIntEquals(status, 200, "Tweet Failed");
    test:assertStringEquals(value, "#ballerina", "Incorrect Tweet");
    system:println("===testTweet completed===");
}


function testSearch () {
    twitter:ClientConnector twitterConnector = init();
    http:Response response = twitterConnector.search ("#ballerina");
    int status = response.getStatusCode();
    test:assertIntEquals(status, 200, "Search Failed");
    system:println("===testSearch completed===");
}


function testRetweet () {
    twitter:ClientConnector twitterConnector = init();
    http:Response response = twitterConnector.retweet (tweetId);
    int status = response.getStatusCode();
    test:assertIntEquals(status, 200, "Retweet Failed");
    system:println("===testRetweet completed===");
}


function testUnretweet () {
    twitter:ClientConnector twitterConnector = init();
    http:Response response = twitterConnector.unretweet (tweetId);
    json jsonResponse = response.getJsonPayload();
    int status = response.getStatusCode();
    string value = (string)jsonResponse.text;
    test:assertIntEquals(status, 200, "Unretweet Failed");
    test:assertStringEquals(value, "#ballerina", "Unretweet Failed");
    system:println("===testUnRetweet completed===");
}


function testShowStatus () {
    twitter:ClientConnector twitterConnector = init();
    http:Response response = twitterConnector.showStatus (tweetId);
    json jsonResponse = response.getJsonPayload();
    int status = response.getStatusCode();
    string value = (string)jsonResponse.text;
    test:assertIntEquals(status, 200, "ShowStatus Failed");
    test:assertStringEquals(value, "#ballerina", "ShowStatus Failed");
    system:println("===testShowStatus completed===");
}


function testDestroyStatus () {
    twitter:ClientConnector twitterConnector = init();
    http:Response response = twitterConnector.destroyStatus (tweetId);
    json jsonResponse = response.getJsonPayload();
    int status = response.getStatusCode();
    string value = (string)jsonResponse.text;
    test:assertIntEquals(status, 200, "DestroyStatus Failed");
    test:assertStringEquals(value, "#ballerina" , "DestroyStatus Failed");
    system:println("===testDestroyStatus completed===");
}