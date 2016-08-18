#include <Adafruit_NeoPixel.h>
// https://www.youtube.com/watch?v=g0pSfyXOXj8

#ifdef __AVR__
  #include <avr/power.h>
#endif

const int neoPixelPin = 8;
const int greenPin = 9;
const int yellowPin = 10;
const int redPin = 11;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(1,neoPixelPin,NEO_RGB);

int boardPin = 13;

void setup() {
  #if defined (__AVR_ATtiny85__)
    if (F_CPU == 16000000) clock_prescale_set(clock_div_1);
  #endif
  Serial.begin(9600);

  pinMode(boardPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(yellowPin, OUTPUT);
  pinMode(redPin, OUTPUT);

  // Initialize NeoPixel
  strip.begin();
  strip.setPixelColor(0, 0, 0, 0);
  strip.show();
}

void loop() {
  // Have the arduino wait to receive input
  // strip.setPixelColor(NeoPixel#,Red,Green,Blue)
  // Range is from 0-255
  while(Serial.available() == 0);

  // Read the input (ascii)
  //int val = Serial.read() - '0';
  int val = Serial.read();

  switch (val){
    case 'f':
      Serial.println("Lync Status: Free");
      strip.setPixelColor(0,0,255,0);
      strip.show();
      delay(100);
      digitalWrite(greenPin, HIGH);
      digitalWrite(yellowPin, LOW);
      digitalWrite(redPin, LOW);
      break;
    case 'a':
      Serial.println("Lync Status: Away");
      strip.setPixelColor(0,180,250,0);
      strip.show();
      delay(100);
      digitalWrite(greenPin, LOW);
      digitalWrite(yellowPin, HIGH);
      digitalWrite(redPin, LOW);
      break;
    case 'b':
      Serial.println("Lync Status: Busy");
      strip.setPixelColor(0,255,0,0);
      strip.show();
      delay(100);
      digitalWrite(greenPin, LOW);
      digitalWrite(yellowPin, LOW);
      digitalWrite(redPin, HIGH);
      break;
    case 'd':
      Serial.println("Lync Status: Do Not Disturb");
      strip.setPixelColor(0,153,0,0);
      strip.show();
      delay(100);
      digitalWrite(greenPin, LOW);
      digitalWrite(yellowPin, LOW);
      digitalWrite(redPin, HIGH);
      break;
    case 'o':
      Serial.println("Lync Status: Offline");
      strip.setPixelColor(0,0,0,0);
      strip.show();
      delay(100);
      digitalWrite(greenPin, LOW);
      digitalWrite(yellowPin, LOW);
      digitalWrite(redPin, LOW);
      break;
    case 'r':
      Serial.println("Lync Status: Be Right Back");
      strip.setPixelColor(0,128,255,0);
      strip.show();
      delay(100);
      digitalWrite(greenPin, HIGH);
      digitalWrite(yellowPin, HIGH);
      digitalWrite(redPin, LOW);
      break;
    case 'i':
      Serial.println("Lync Status: Busy Idle");
      strip.setPixelColor(0,255,153,51);
      strip.show();
      delay(100);
      digitalWrite(greenPin, LOW);
      digitalWrite(yellowPin, HIGH);
      digitalWrite(redPin, HIGH);
      break;
    case '1':
      Serial.println("Board Led is On");
      digitalWrite(boardPin, HIGH);
      break;
    case '0':
      Serial.println("Board Led is Off");
      digitalWrite(boardPin, LOW);
      break;
    default:
      Serial.print("Invalid Entry!  You entered: ");
      Serial.println(val);
  }

/*
  // get neopixel values
  int red = 0;
  int blue = 0;
  int green = 0;
  red, green, blue = strip.getPixelColor(0);
  Serial.print("Red: ");
  Serial.print(red);
  Serial.print(" Green: ");
  Serial.print(green);
  Serial.print(" Blue: ");
  Serial.println(blue);
 */
  
  strip.show();
  Serial.flush();

}
