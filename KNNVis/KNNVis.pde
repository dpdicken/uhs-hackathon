Point[] values;
Point queryPoint;
Phase currentPhase;
NearestNeighbor[] neighbors;
int height = 600, width = 600, pad = 100, currentIndex = 0, k = 5, delayLen = 0;

void setup() {
   size(600, 600); 
   background(200);
   readData();
   currentPhase = Phase.INIT;
}

void draw() {
  switch (currentPhase) {
   case INIT:
     initGraph();
     currentPhase = Phase.INPUT_WAIT;
     break;
   case START:
     initGraph();
     currentIndex = 0;
     neighbors = new NearestNeighbor[k];
     currentPhase = Phase.SELECT_QUERY;
     break;
   case SELECT_QUERY:
     drawQuery();
     delayLen = 750;
     currentPhase = Phase.HIGHLIGHT_QUERY;
     break;
   case HIGHLIGHT_QUERY:
     highlightPoint(queryPoint.x, queryPoint.y);
     currentPhase = Phase.UNHIGHLIGHT_QUERY;
     break;
   case UNHIGHLIGHT_QUERY:
     unhighlight();
     currentPhase = Phase.SELECT_NEIGHBOR;
     break;
   case SELECT_NEIGHBOR:
     if (currentIndex >= values.length) {
         currentPhase = Phase.REPORT_CLOSEST_NEIGHBORS;
         delayLen = 750;
         break;
     }
     
     Point toCheck = values[currentIndex];
     highlightPoint(toCheck.x, toCheck.y);
     if (delayLen > 50) {
       delayLen -= 50; 
     } else if (delayLen > 0) {
       delayLen = delayLen - 5 < 0 ? 0 : delayLen - 5; 
     }
     currentPhase = Phase.DRAW_LINE;
     break;
   case DRAW_LINE:
     unhighlight();
     drawLine(queryPoint, values[currentIndex]);
     currentPhase = Phase.CALCULATE_DISTANCE;
     break;
   case CALCULATE_DISTANCE:
     toCheck = values[currentIndex];
     float distance = sqrt(sq(toCheck.x - queryPoint.x) + sq(toCheck.y - queryPoint.y));
     text("Distance between points: " + distance, 50, 25);
     updateNeighbors(toCheck, distance);
     currentPhase = Phase.CLEAR_DISTANCE;
     break;
   case CLEAR_DISTANCE:
     unhighlight();
     currentIndex++;
     currentPhase = Phase.SELECT_NEIGHBOR;
     break;
   case REPORT_CLOSEST_NEIGHBORS:
     int orange = 0, blue = 0;
     String report = "The closest neighbors were: ";
     for (int i = 0; i < neighbors.length; i++) {
       if (i != 0) report += ", ";
       report += "(" + neighbors[i].point.x + "," + neighbors[i].point.y + ")";
       highlightPoint(neighbors[i].point.x, neighbors[i].point.y);
       if (neighbors[i].point.label.equals("O")) {
         orange++; 
       } else {
         blue++; 
       }
     }
     report += "\n\tThe consensus from " + k + " samples is that our query point is: " + (orange > blue ? "orange" : "blue");
     text(report, 50, 25);
     
     delayLen = 0;
     currentPhase = Phase.INPUT_WAIT;
     break;
   default:
     break;
  }
  
  if (currentPhase == Phase.INPUT_WAIT && mousePressed && mouseInBounds()) {
    queryPoint = new Point(mouseX - (pad/2), (height - (pad/2)) - mouseY, "unknown");
    currentPhase = Phase.START;
  }
  delay(delayLen);
}

boolean mouseInBounds() {
    if (mouseX > (pad/2) && mouseX < (width - (pad/2))
      && mouseY > (pad/2) && mouseY < (height - (pad/2))) {
        return true;
    }
      return false;
}

void updateNeighbors(Point p, float d) {
  for (int i = 0; i < neighbors.length; i++) {
     if (neighbors[i] == null) {
       neighbors[i] = new NearestNeighbor(p, d);
       return;
     }
  }
  
  int maxIndex = -1;
  float maxVal = 0;
  for (int i = 0; i < neighbors.length; i++) {
     if (neighbors[i].distance > maxVal) {
       maxVal = neighbors[i].distance;
       maxIndex = i;
     }
  }
  
  if (d < maxVal) {
     neighbors[maxIndex] = new NearestNeighbor(p, d); 
  }
}

void drawLine(Point p1, Point p2) {
  color prev = g.strokeColor;
  stroke(color(255, 0, 0));
  line(p1.x + (pad/2), (height - (pad/2)) - p1.y, p2.x + (pad/2), (height - (pad/2)) - p2.y);
  stroke(prev);
}

void unhighlight() {
  clear();
  background(200);
  drawAxis();
  drawValues();
  drawQuery();
}

void highlightPoint(int x, int y) {
  color prev = g.fillColor;
  color prevStrokeColor = g.strokeColor;
  float prevStrokeWeight = g.strokeWeight;
  
  noFill();
  stroke(color(255, 0, 0));
  strokeWeight(5);
  
  ellipse(x + (pad/2), (height - (pad/2)) - y, 30, 30);
  
  fill(prev);
  stroke(prevStrokeColor);
  strokeWeight(prevStrokeWeight);
}

void drawQuery() {
  color prev = g.fillColor;
  fill(color(0, 255, 0));
  ellipse(queryPoint.x + (pad/2), (height - (pad/2)) - queryPoint.y, 10, 10); 
  fill(prev);
}

void initGraph() {
  clear();
  background(200);
  drawAxis();
  drawValues();
}

void drawValues() {
  color prev = g.fillColor;
  for (int i = 0; i < values.length; i++) {
    Point p = values[i];
    
    if (p.label.equals("O")) {
      fill(color(203, 102, 0));
    } else {
      fill(color(89, 63, 255));
    }
    
    ellipse(p.x + (pad/2), (height - (pad/2)) - p.y, 10, 10); 
  }
  fill(prev);
}

void drawAxis() {
  color prev = g.fillColor;
  fill(color(0, 0, 0));
  
  // draw Y axis
  line((pad/2), (pad/2), (pad/2), height - (pad/2));
  text("y", (pad/2), (pad/2) - 15);
  for (int i = 0; i < 10; i++) {
    int y = height - (pad/2) - (i+1)*((height - pad)/10);
    line((pad/2) - 3, y, (pad/2) + 3, y);
    text((i+1)*((height - pad)/10), ((pad/2) - 28), y + 5);
  }
  
  // draw X axis
  line((pad/2), height - (pad/2), width - (pad/2), height - (pad/2));
  text("x", width - (pad/2) + 15, height - (pad/2));
  for (int i = 0; i < 10; i++) {
    int x = 0 + (pad/2) + (i+1)*((width - pad)/10);
    line(x, height - (pad/2) - 3, x, height - (pad/2) + 3);
    text((i+1)*((width - pad)/10), x - 10, height - (pad/2) + 15);
  } 
  fill(prev);
}

void readData() {
  // TODO read from actual file
  int range = height - pad;
  int valueSize = 500;
  values = new Point[valueSize];
  for (int i = 0; i < valueSize; i++) {
    int x = (int)random(range);
    int y = (int)random(range);
    String label = ((x + y) / 2) > 250 ? "O" : "B";
    Point current = new Point(x, y, label);
    values[i] = current;
  }
}
