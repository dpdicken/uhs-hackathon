int width = 500, height = 500, pad = 20,
  endIndex = 0, compareIndex, valueSpan, arrayMax;
int[] values;
Phase currentPhase;
color red = color(255, 0, 0);
color blue = color(0, 0, 255);

void setup() {
  size(500, 500);
  readValues();
  valueSpan = (width - (pad * 2)) / values.length;
  arrayMax = max(absArray(values));
  currentPhase = Phase.DONE;
}

void draw() {
  delay(200);
  
  if (mousePressed && currentPhase == Phase.DONE) {
    currentPhase = Phase.START;
  }
  
  switch (currentPhase) {
    case START:
      drawValues();
      currentPhase = Phase.NEXT_ELEMENT;
      break;
      
    case NEXT_ELEMENT:
      if (endIndex >= values.length) {
        currentPhase = Phase.SORTED;
        break;
      } 
      
      highlightIndex(endIndex, red);
      if (endIndex > 0) {
       compareIndex = endIndex;
       currentPhase = Phase.HIGHLIGHT_COMPARE;
      } else {
       currentPhase = Phase.NO_SWAP;
      }
      break;
      
    case RESET:
      drawValues();
      endIndex++;
      currentPhase = Phase.NEXT_ELEMENT;
      break;
      
    case HIGHLIGHT_COMPARE:
      if (compareIndex > 0) {
          highlightIndex(compareIndex - 1, blue);
          if (values[compareIndex] < values[compareIndex - 1]) {
            currentPhase = Phase.SWAP;
            break;
          }
      }
      currentPhase = Phase.NO_SWAP; 
      break;
      
    case SWAP:
     // TODO draw arrow?
      int temp = values[compareIndex - 1];
      values[compareIndex - 1] = values[compareIndex];
      values[compareIndex] = temp;
      compareIndex--;
      
      drawValues();
      highlightIndex(compareIndex + 1, blue);
      highlightIndex(compareIndex, red);
      
      currentPhase = Phase.UNHIGHLIGHT_COMPARE;
      break;
      
    case UNHIGHLIGHT_COMPARE:
      drawValues();
      highlightIndex(compareIndex, red);
      currentPhase = Phase.HIGHLIGHT_COMPARE;
      break;
    
    case NO_SWAP:
      text("NO SWAP!", (width/2) - 50, 25);
      currentPhase = Phase.RESET;
      break;
      
    case SORTED:
      text("SORTED!", (width/2) - 50, 25);
      currentPhase = Phase.DONE;
      break;
      
    default:
      break;
  }
}

void drawValues() {
  clear();
  for (int i = 0; i < values.length; i++) {
     rect(20 + (i * valueSpan), height / 2,  valueSpan, - scaleVal(values[i]));
  }
}

void highlightIndex(int index, color c) {
  color current = g.fillColor; // gets current fill color
  fill(c);
  rect(20 + (index * valueSpan), height / 2, valueSpan, -scaleVal(values[index]));
  fill(current);
}

int scaleVal(float y) {
  return ((int) ((y / arrayMax) * ((height / 2) - pad)));
}

int[] absArray(int[] array) {
  int[] newArray = new int[array.length];
  
  for (int i = 0; i < array.length; i++) {
     newArray[i] = abs(array[i]); 
  }
  
  return newArray;
}

void readValues() {
 
  values = new int[10];
  for (int i = 0; i < values.length; i++) {
     values[i] = random(2) == 0 ? -(int)random(100) : (int)random(100); 
  }
  
}
