const int buzzer = 9; //buzzer to arduino pin 9
unsigned int leitura;
unsigned int escala;
unsigned int nota;
bool b0, b1, b2;
int pitches[][7] = {
  {  33,   37,   41,   44,   49,   55,   62},
  {  65,   73,   82,   87,   98,  110,  123},
  { 131,  147,  165,  175,  196,  220,  247},
  { 262,  294,  330,  349,  392,  440,  494},
  { 523,  587,  659,  698,  784,  880,  988},
  {1047, 1175, 1319, 1397, 1568, 1760, 1976},
  {2093, 2349, 2637, 2794, 3136, 3520, 3951},
};

void setup(){
   
  pinMode(buzzer, OUTPUT); // Set buzzer - pin 9 as an output
  pinMode(A0, INPUT);
  pinMode(2, INPUT);
  pinMode(3, INPUT);
  pinMode(4, INPUT);
  Serial.begin(9600);
}

void playTone(int tom){
  tone(buzzer, tom);
}

void   loop(){
  leitura =analogRead(A0); 
  escala = map(leitura, 0, 1023, 0, 6);
  b0=digitalRead(4); 
  b1=digitalRead(3); 
  b2=digitalRead(2); 
  
  nota = 0;
  if(b0 == HIGH){
    nota += 1;
  }

  if(b1 == HIGH){
    nota += 2;
  }

  if(b2 == HIGH){
    nota += 4;
  }

  if (nota == 0){
    noTone(buzzer);
  }
  else{
    playTone(pitches[escala][nota-1]);
  }
  Serial.print("Escala = ");
  Serial.print(escala);
  Serial.print(" |  Nota = ");
  Serial.print(nota);
  Serial.print("\n");
}