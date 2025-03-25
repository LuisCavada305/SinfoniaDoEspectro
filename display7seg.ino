long num[] = {1,0,2,4};
long leitura;
long velocidade;
String leituraSerial;


// MAPA de teste para display de 7 segementos
// 0b000000-11 0b1010-11-00 == 0x03 0xac
// 0b000000-00 0b1010-00-00 == 0x00 0xa0
// 0b000000-10 0b1100-11-00 == 0x02 0xcc
// 0b000000-10 0b1110-10-00 == 0x02 0xe8
// 0b000000-01 0b1110-00-00 == 0x01 0xe0
// 0b000000-11 0b0110-10-00 == 0x03 0x68
// 0b000000-11 0b0110-11-00 == 0x03 0x6c
// 0b000000-10 0b1010-00-00 == 0x02 0xa0
// 0b000000-11 0b1110-11-00 == 0x03 0xec
// 0b000000-11 0b1110-10-00 == 0x03 0xe8

int leds_portb [] = {0x03, 0x00, 0x02, 0x02, 0x01, 0x03, 0x03, 0x02, 0x03, 0x03};
int leds_portd [] = {0xac, 0xa0, 0xcc, 0xe8, 0xe0, 0x68, 0x6c, 0xa0, 0xec, 0xe8};

int enable [] = {0x38, 0x34, 0x2c, 0x1c};

void setup() {
  DDRB = DDRB | 0x3F;
  DDRD = 0xFF;
  Serial.begin(9600);
  pinMode(A0, INPUT);
}

void loop() {
  velocidade = analogRead(A0);
  if (Serial.available() > 0) {
    // lê do buffer o dado recebido:
    leituraSerial = Serial.readString();
    num[0] = (leituraSerial[0]-48);
    num[1] = (leituraSerial[1]-48);
    num[2] = (leituraSerial[2]-48);
    num[3] = (leituraSerial[3]-48);
  }
  else{
    for(int j = 0; j < 3; j ++){
      PORTB = enable[j] | leds_portb[num[2-j]];
      PORTD = leds_portd[num[2-j]];
      // for(int i =0; i < 4; i++){
      //   digitalWrite(pinsE[i],enable[j][i]);
      //   digitalWrite(pinsL[i],leds[j][i]);
      // }
      // for(int i = 4; i < 8; i++){
      //   digitalWrite(pinsL[i],leds[j][i]);
      // }
      delay(1+velocidade*200/1023); 
    }
  }
}