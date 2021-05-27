/*
Basato su Random Walker Kaleidoscope di Jacob Joaquin.
https://www.openprocessing.org/sketch/135789 
Interazione audio di Wouter Jongeneel e Ties Luiten.
http://p-p-plus.tumblr.com/
http://www.tiesluiten.com/
*/
 
// Utilizza la libreria Minim
import processing.pdf.*; 
import ddf.minim.*; 
Minim minim;
AudioPlayer in;


// Imposta la variabile dell'ampiezza corrente del suono, si aggiunge all'array ampBuffer [] per poter calcolare il valore medio, definito in ampAvg. 
// La dimensione dell'array definita in float[n] influenza il modo in cui il caleidoscopio reagisce ai cambiamenti di ampiezza nell'audio
float amp = 0; 
float ampAvg = 0;   
float ampBuffer [] = new float[10]; 

PImage V_1; // * Modificare con il nome con cui si desidera esportare i frames *

int maxImages = 10; // Array di immagini totali
int imageIndex = 0; // Immagine iniziale

PImage[] images = new PImage[maxImages]; // Array di immagini 

// I phase increments vengono utilizzati per ottenere il movimento avanti e indietro, e sono casuali
// La prima è per i colori, la seconda per il posizionamento del vettore
float phasorInc = 1.0 / 500.0;
float phasorInc2 = 1.0 / 90000.0;
 
// nReflections imposta la quantità di riflessi nel caleidoscopio
int nReflections = 10;

// nAngles imposta la quantità di direzioni possibili verso cui il vettore può crescere
int nAngles = 3;

// nPointsPerFrame imposta la quantità di nuovi punti da calcolare e disegnare per ogni nuovo frame
// L'aumento dei punti crea immagini più piene, ma ne riduce la qualità 
// Segue frameRate() impostato in setup()
int nPointsPerFrame = 300;

// Definisce i limiti della figura, è impostato all'inizio di setup() in modo che corrisponda all'altezza dello sketch 
// Utilizzato alla fine di draw() a creare un ellissi 
// Mantenere la scena delimitata all'interno di un cerchio è necessario perchè se un punto colpisce il bordo viene reindirizzato verso il centro con un offset casuale.
float rad = 540;

// Active è usato in draw() per verificare se è presente o meno la figura sullo sketch una volta lanciato
int active = 0;

Walker w;
Phasor p;
Phasor p2;
float[] angles;

// Definisce il numero di palette colore, mentre i colori veri e propri sono impostati in setup()
// In questo caso particolare i colori non hanno rilevanza in quanto servono solo a creare variazioni nelle figure
// Alla fine di draw() tutto lo sketch viene sottoposto al filtro (GRAY)
Palette palette;
Palette palette2;
Palette palette3;
Palette palette4;
Palette palette5;

// colorParam indica il numero corrispondente palette che si sta utilizzando.
int colorParam = 1;

// Counter incrementa con random(0,100) alla fine di draw()
// Quando counter>2222, colorParam cambia utilizzando int(random (1,6)) risultando nel cambio della palette utilizzata
int counter = 0;


PVector getVCoordinates(PVector v, float d, float a) {
  // Determina il movimento in crescita
  return new PVector(v.x + d * cos(a), v.y + d * sin(a));
}

// Atan2 gestisce la selezione del quadrante
float getAngleFromCenter(PVector v) {
  return atan2(v.y - height / 2, v.x - width / 2);
}

class Phasor {
  float inc;
  float phase;

  Phasor(float inc) {
    this.inc = inc;
  }

  void update() {
    phase += inc;

    // Phase da 1 a -1 e viceversa 
    while (abs(phase)>=1) {
      inc=inc*-1;
      phase += inc;
    }
  }
}

class Walker {
  PVector v;

  Walker(float x, float y) {
    v = new PVector(x, y);
  }

  // "gauss" indica la randomicità  
  void update() {
    float gauss = p2.phase * random(2, 4);
    // Determina raggio e angolo
    v = getVCoordinates(v, gauss, angles[int(random(angles.length))]);

    // Utilizza rad per creare l'ellissi che "contiene" la scena 
    float offset = rad*0.75; 
    if ((dist(v.x, v.y, width / 2, height / 2))>rad) {
      v.x = width/2+random(0, offset);
      v.y = height/2+random(0, offset);
    }

    float a = getAngleFromCenter(v);
    float d = dist(v.x, v.y, width / 2, height / 2);
    PVector center = new PVector(width / 2, height / 2);
    noStroke();

   // I colori delle palette si stratificano grazie ad una bassa opacità
    if (colorParam == 1) {
      fill(palette.getNorm(abs(p.phase)), map(d, 0, width, 666*amp, 66));
    } else if (colorParam == 2) {
      fill(palette2.getNorm(abs(p.phase)), map(d, 0, width, 666*amp, 66));
    } else if (colorParam == 3) {
      fill(palette3.getNorm(abs(p.phase)), map(d, 0, width, 666*amp, 66));
    } else if (colorParam == 4) {
      fill(palette4.getNorm(abs(p.phase)), map(d, 0, width, 666*amp, 66));
    } else {
      fill(palette5.getNorm(abs(p.phase)), map(d, 0, width, 666*amp, 66));
    }
    // Utilizza gauss per variare lo spessore
    gauss = max(0.5, abs(gauss) / 2);
    for (int i = 0; i < nReflections; i++) {
      float thisAngle = a + (TWO_PI / (float) nReflections) * i;

      PVector thisV = getVCoordinates(center, d, thisAngle);
      ellipse(thisV.x, thisV.y, gauss, gauss);
      // Riflette il punto
      thisV = getVCoordinates(center, d, PI - thisAngle);
      ellipse(thisV.x, thisV.y, gauss, gauss);
    }
  }
}

// Imposta i colori
class Palette {
  ArrayList<Integer> colors;
  Palette() {
    colors = new ArrayList<Integer>();
  }
  void add(color c) {
    colors.add(c);
  }
  color getNorm(float p) {
    int index = (int) (p * colors.size());
    color c1 = colors.get(index);
    color c2 = colors.get((index + 1) % colors.size());
    // con volume alto o molto alto, aggiunge accenti arancioni e rossi, visibili in caso non si applichi il filtro (GRAY) 
    if (amp>ampAvg*3.5) {
      color cr = color(225, 0, 38);
      color cb = color(0, 0, 0);
      float rand = random(0, 1); 
      return lerpColor(cr, cb, rand);
    } else if (amp>ampAvg*3) {
      color co = color(225, 128, 0);
      color cb = color(0, 0, 0);
      float rand = random(0, 1); 
      return lerpColor(co, cb, rand);
    } else {
      return lerpColor(c1, c2, p * colors.size() - index);
    }
  }
}

void setup() {
  size(500, 500);
  // Il framerate può essere impostato a 30 per ottenere la performance migliore, altrimenti è autimaticamente impostato a 55
  // In questo caso è impostato a 10 per rallentare l'animazione
  frameRate(10);
  // Imposta il colore di background
  background(0); 

  // Fa corrispondere l'ellissi che delimita la figura con l'altezza dello sketch
  rad = height/2;

  // Crea l'insieme di angoli possibili, 2*Pi/nAngles 
  angles = new float[nAngles];
  for (int i = 0; i < angles.length; i++) {
    angles[i] = ((float) i / (float) nAngles) * TWO_PI;
  }

  // Imposta le coordinate di partenza del Walker
  w = new Walker(width / 2, height / 2);

  p = new Phasor(phasorInc);
  p2 = new Phasor(phasorInc2);


  // Palette 1:  
  palette = new Palette();
  palette.add(color(4, 7, 28));
  palette.add(color(9, 62, 112));
  palette.add(color(136, 135, 217));
  palette.add(color(199, 156, 0));
  palette.add(color(255, 246, 79));

  // Palette 2:
  palette2 = new Palette();
  palette2.add(color(11, 17, 13));
  palette2.add(color(44, 77, 86));
  palette2.add(color(195, 170, 114));
  palette2.add(color(220, 118, 18));
  palette2.add(color(189, 50, 0));

  // Palette 3:
  palette3 = new Palette();
  palette3.add(color(146, 179, 38));
  palette3.add(color(254, 234, 114));
  palette3.add(color(37, 148, 132));
  palette3.add(color(217, 255, 171));
  palette3.add(color(246, 189, 76));
  palette3.add(color(24, 63, 140));

  // Palette 4:
  palette4 = new Palette();
  palette4.add(color(255, 136, 231));
  palette4.add(color(255, 245, 193));
  palette4.add(color(252, 143, 110));
  palette4.add(color(122, 11, 18));
  palette4.add(color(123, 54, 98));

  // Palette 5:
  palette5 = new Palette();
  palette5.add(color(79, 156, 122));
  palette5.add(color(137, 119, 193));
  palette5.add(color(255, 255, 118));
  palette5.add(color(244, 244, 244));
  palette5.add(color(255, 40, 70));

  // Crea un nuovo audio object 
  minim = new Minim(this);
  
  // Definisce l'imput dell'audio
  in = minim.loadFile("V_1.mp3");// * Modificare con il nome della traccia audio desiderata *
  in.play();
}

void draw() {

  // Ottiene la massima ampiezza dal buffer
  for (int i = 0; i < in.bufferSize() - 1; i++) {
    if ( abs(in.mix.get(i)) > amp ) {
      amp = abs(in.mix.get(i));
    }
  }

  // Determina l'ampiezza media dell'imput audio
  // Questa è un'indicazione migliore dei cambiamenti nella musica rispetto ad una soglia fissa
 ampAvg = amp/ampBuffer.length;
  for (int j=ampBuffer.length-1; j>0; j--) {
    ampBuffer[j]=ampBuffer[j-1];
    ampAvg += (ampBuffer[j]/ampBuffer.length);
  }
  ampBuffer[0]=amp;


  // Disegna se il ritmo cambia
  if (amp>1.00*ampAvg || (active == 1 && random(1, 10)>2)) {
    active = 1; 
    int lr = int(random(1, 2));
    for (int l=0; l<lr; l++) {
      for (int i = 0; i < nPointsPerFrame; i++) {
        p.update();
        p2.update();
        w.update();
      }
    }
  }

  // Rallenta leggermente il tempo di reazione
  else if (random(1, 10)>0) {
    fill(0); 
    ellipse(width/2, height/2, rad*2, rad*2); 
    w.v.x=width/2+random(-rad*amp*5, rad*amp*5);
    w.v.y=height/2+random(-rad*amp*5, rad*amp*5);
    active = 0;
  } else {
    active=0;
  }

  // Per ottenere un bordo circolare utilizzare un tratto sottile in strokeWeight
  noFill();
  stroke(0);
  strokeWeight(40);
  ellipse(width/2, height/2, rad*2, rad*2);
  amp=0;

  // Utilizzare counter per il cambio colore
  counter+= int(random(0, 100));
  ampAvg=0;

  // Permette il salvataggio progressivo delle immagini senza che vengano sovrascritte
  imageIndex = (imageIndex + 1);
  
  // Applica a tutto lo sketch il filtro in scala di grigio
  filter(GRAY); // * Modificare inserendo il filtro desiderato. Libreria filtri: www.processing.org/reference/filter_ *
  
  // Determina gli intervalli in cui vengono esportati i frames
  if (frameCount % 60 == 0) // * Modificare la percentuale con  l'intervallo desiderato *
  
  // Permette di salvare nella cartella output, rinominando i file correttamente
   saveFrame("V_1/V_1" + imageIndex + ".jpg"); // * Modificare inserendo il nome della cartella di destinazione e il nome con cui verranno salvati i vari frames *
  
}
