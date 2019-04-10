
#include <ESP8266WiFi.h>      //includes library for ESP8266 wifi connectivity
#include <ESP8266HTTPClient.h>// includes library for ESP8266 web browsing capabilities
#include <ArduinoJson.h>      // library for JSON parser

const char* ssid = "University of Washington";    // variable containing ssid for wifi connection
const char* pass = "";    // variable containing password for wifi connection
String ingredients = "tomato,onions"; // must be comma seperated list of ingredients
typedef struct { // data structure (name: value pairs) that holds values for Metropolitan weather data
  String title;
  String url;
  String ing;
} RecipeData;

typedef struct { // data structure (name: value pairs) that holds values for Metropolitan weather data
  String q;
  String a;
} TriviaData;
 
RecipeData dinner; // creates RecipeDatadata structure named dinner
TriviaData trivia;// creates a TriviaData structure name trivia;
void setup() {
  Serial.begin(115200);
  delay(10);

  // Serial output communicating the file uploded to the arduino and the date it was compiled
  Serial.print("This board is running: ");
  Serial.println(F(__FILE__));
  Serial.print("Compiled: ");
  Serial.println(F(__DATE__ " " __TIME__));
  Serial.print("Connecting to "); Serial.println(ssid);

  // Begins wifi connection
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pass);

  // Checks against wifi status to tell when the Arduino is connected to the internet
  // prints dots in Serial while Arduino is NOT connected
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println(); Serial.println("WiFi connected"); Serial.println();// Prints notification of connection to Serial
  Serial.print("Your ESP has been assigned the internal IP address "); 
  Serial.println(WiFi.localIP()); // Prints local IP address

  getTrivia();
  getRecipes(ingredients); // Calls getRecipe(); function passes in ingredient list

  Serial.println("Tonight's Special is " + dinner.title);
  Serial.println("your question for the night is " + trivia.q);
}

void loop() {
}

// function that retrieves trivia information
void getTrivia() {
  String apiCall = "http://jservice.io/api/random"; //Assembles the URL for the recipepuppy API
  HTTPClient theClient; // initializes browser
  theClient.begin(apiCall);//Navigates broswer to webpage
  int httpCode = theClient.GET();//makes a GET request
  if (httpCode > 0) {
    if (httpCode == HTTP_CODE_OK) {//Checks whether the GET request was successful
      String payload = theClient.getString();
      payload.remove(0,1);
      int len = payload.length() - 1;
      payload.remove(len); //cleans up payload for JSON parsing
      DynamicJsonBuffer jsonBuffer;//initializs JSON parser
      JsonObject& root = jsonBuffer.parseObject(payload);//Parses String payload as a JSON object stored in root variable
      if (!root.success()) {//Checks whether parse was successful, prints error message to Serial
        Serial.println("parseObject() failed in getAlbum().");
         return;
      }
      
      trivia.q = root["question"].as<String>();
      trivia.a = root["answer"].as<String>(); 
    }
  }
}

void getRecipes(String ingredients) {
  HTTPClient theClient; // initializes browser
  String apiCall = "http://www.recipepuppy.com/api/?i=" + ingredients; //Assembles the URL for the recipepuppy API
  theClient.begin(apiCall);//navigates to recipes API
  int httpCode = theClient.GET();//
  if (httpCode > 0) {
    if (httpCode == HTTP_CODE_OK) {//Checks whether the GET request was successful
      String payload = theClient.getString();
      DynamicJsonBuffer jsonBuffer;//initializs JSON parser
      JsonObject& root = jsonBuffer.parseObject(payload);//Parses String payload as a JSON object stored in root variable
      if (!root.success()) {//Checks whether parse was successful, prints error message to Serial
        Serial.println("parseObject() failed in getMet().");
        return;
      }
      JsonObject& recipe = root["results"][random(10)];
      dinner.title = recipe["title"].as<String>();
      dinner.url = recipe["href"].as<String>();                 ///Populates the conditions MetData
      dinner.ing = recipe["ingredients"].as<String>();                 ///structure with the corresponding
                                                                      ///JSON values 
    }
  }
  else {
    Serial.printf("Something went wrong with connecting to the endpoint in getRecipe().");//Checks whether parse was successful, prints error message to Serial
  }
}
