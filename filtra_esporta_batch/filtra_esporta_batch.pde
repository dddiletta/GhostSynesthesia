PImage V_1_; // * Modificare inserendo il nome delle immagini da processare - il numero progressivo *

// Array di immagini totali
int maxImages = 91; // * Modificare inserendo il numero totale di immagini presenti nella cartella data *
int imageIndex = 0; // immagine iniziale

PImage[] images = new PImage[maxImages]; // Array di immagini 

void setup() {
 size(500, 500);
 V_1_ = loadImage ("data/V_1_0.jpg"); // * Modificare inserendo il nome delle immagini da processare *
 for (int i = 0; i < images.length; i ++ ) {
 
  // upload delle immagini, dove i è il numero progressivo
  images[i] = loadImage ("V_1_" + i + ".jpg"); // * Modificare inserendo il nome delle immagini da processare *
  }
}

void draw() {
  for(PImage photo: images) {
    photo.loadPixels(); 
    photo.updatePixels();    
    image(photo, 0, 0);
    
    // Permette il salvataggio progressivo delle immagini senza che vengano sovrascritte
    imageIndex = (imageIndex + 1);
    
    // Applica a tutto lo sketch il filtro inverti
    filter(INVERT); // * Modificare inserendo il filtro desiderato. Libreria filtri: www.processing.org/reference/filter_ *
   
    // Permette di salvare nella cartella output, rinominando i file correttamente
    saveFrame("output/V_1_BW_" + imageIndex + ".jpg"); // * Modificare inserendo il nome della cartella di destinazione e il nome con cui verranno salvate le immagini processate *
    
    // Scrive quando il processo di esportazione è terminato
    println("FINE:)");
    exit();
  }
}
