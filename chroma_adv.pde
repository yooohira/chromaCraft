
import processing.core.PImage;
displayClass display;


PImage cimg; //カラー画像
PImage fimg; //フレーム画像
PImage comimg; //合成画像

boolean colorImageLoaded = false; //カラー画像は読み込まれたか？
boolean frameImageLoaded = false; //フレーム画像は読み込まれたか？
boolean RGBOutput = false; //代表色の決定

int newSize1=300;
int newSize2=400;
int newW, newH;

int scene=1;
int flag=0;


void setup() {
  size(800, 600);
  surface.setResizable( true );
  background(255);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);

  display = new displayClass();
}

void draw() {
  textSize(20);
  background(153, 181, 200);
  stroke(255);

  if (scene==1) {    //合成前画面
    display.scene1();

    if (colorImageLoaded) {
      // 画像がロードされたらカラーパレットを作成
      createColorPalette(cimg);
      image(cimg, 220, 250);
    }
    if (frameImageLoaded) {
      image(fimg, 580, 250);
    }

    if (colorImageLoaded && frameImageLoaded) {
      flag=2;
    }
  }


  if (scene==2) {    //合成結果画面
    display.scene2();
    if (comimg != null) {
      image(comimg, 400, 250);
    }
  }
}



void mousePressed() {

  if (scene==1) {

    if (dist(220, 450, mouseX, mouseY)<=50) {
      selectInput("Select aimage:", "colorImageSelected");
    }

    if (dist(580, 450, mouseX, mouseY)<=50) {
      selectInput("Select an image:", "frameImageSelected");
    }

    if (350<mouseX && mouseX<450 && 520<mouseY && mouseY<550) {
      if (colorImageLoaded && frameImageLoaded) {
        background(255);
        // カラーパレット適用後の画像を生成

        comimg=fimg.copy();

        HashMap<Integer, Integer> colorCounts = getColorCounts(cimg); // カラーカウントを取得
        ArrayList<Integer> colorPalette = getTopColors(colorCounts, 5); // カラーパレットを取得

        applyColorPalette(comimg, colorPalette);


        float aspect=float(fimg.width)/float(fimg.height);

        if (aspect>(1.0)) {
          newW=newSize2;
          newH=int(newSize2/aspect);
        } else {
          newH=newSize2;
          newW=int(newSize2*aspect);
        }
        comimg.resize(newW, newH);

        scene=2;
      } else {
        flag=1;
      }
    }
  }

  if (scene==2) {
    if (695<mouseX && mouseX<765 && 530<mouseY && mouseY<570) {
      scene=1;
    }
    if (360<mouseX && mouseX<440 && 490<mouseY && mouseY<520) {
      selectOutput("保存場所を選んでください:", "saveImage");
    }
  }
}


void colorImageSelected(File selection) {
  if (selection == null) {
    println("No file selected");
  } else {
    cimg = loadImage(selection.getAbsolutePath());

    float aspect=float(cimg.width)/float(cimg.height);
    if (aspect>(1.0)) {
      newW=newSize1;
      newH=int(newSize1/aspect);
    } else {
      newH=newSize1;
      newW=int(newSize1*aspect);
    }
    cimg.resize(newW, newH);
    colorImageLoaded = true;
  }
}


void frameImageSelected(File selection) {
  if (selection == null) {
    println("No file selected");
  } else {
    fimg = loadImage(selection.getAbsolutePath());

    float aspect=float(fimg.width)/float(fimg.height);
    if (aspect>(1.0)) {
      newW=newSize1;
      newH=int(newSize1/aspect);
    } else {
      newH=newSize1;
      newW=int(newSize1*aspect);
    }
    fimg.resize(newW, newH);
    frameImageLoaded = true;
  }
}

void saveImage(File selectedFile) {
  if (selectedFile != null) {
    comimg.save(selectedFile.getAbsolutePath());
    println("image saved:"+selectedFile.getAbsolutePath());
  } else {
    println("canceled");
  }
}


///////////////////////////////////////////////////////////////////////////////




HashMap<Integer, Integer> getColorCounts (PImage img)
{
  // 色情報をカウントするためのHashMap
  HashMap<Integer, Integer> colorCounts = new HashMap<Integer, Integer>();
  if (img != null) { // 画像が読み込まれているか確認

    // 画像内の全ピクセルを走査
    img.loadPixels();

    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        int pixelColor = img.get(x, y);

        // カウントを更新
        if (colorCounts.containsKey(pixelColor)) {
          colorCounts.put(pixelColor, colorCounts.get(pixelColor) + 1);
        } else {
          colorCounts.put(pixelColor, 1);
        }
      }
    }
  } else {
    println("Image is not loaded yet.");
  }
  return colorCounts;
}


void createColorPalette(PImage img) {

  // 色情報をカウントするためのHashMap
  HashMap<Integer, Integer> colorCounts = new HashMap<Integer, Integer>();
  if (img != null) { // 画像が読み込まれているか確認

    // 画像内の全ピクセルを走査
    img.loadPixels();

    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        int pixelColor = img.get(x, y);

        // カウントを更新
        if (colorCounts.containsKey(pixelColor)) {
          colorCounts.put(pixelColor, colorCounts.get(pixelColor) + 1);
        } else {
          colorCounts.put(pixelColor, 1);
        }
      }
    }
    // カウントが最も多い色を上から5個選び、それを代表的な色として表示
    ArrayList<Integer> topColors = getTopColors(colorCounts, 5);

    if (!RGBOutput) {
      // 代表的な色のRGB情報を標準出力
      for (int colorKey : topColors) {
        int r = (colorKey >> 16) & 0xFF;
        int g = (colorKey >> 8) & 0xFF;
        int b = colorKey & 0xFF;
        println("R: " + r + ", G: " + g + ", B: " + b);
      }
      RGBOutput = true;
    }
  }
}




ArrayList<Integer> getTopColors(HashMap<Integer, Integer> colorCounts, int numColors) {
  ArrayList<Integer> topColors = new ArrayList<Integer>();

  for (int i = 0; i < numColors; i++) {
    int maxCount = 0;
    int dominantColor = color(0);

    for (Integer colorKey : colorCounts.keySet()) {
      int count = colorCounts.get(colorKey);
      int distance = calculateColorDistance(colorKey, topColors);
      int threshold = 6600;

      if (count > maxCount && distance > threshold && !topColors.contains(colorKey)) {
        maxCount = count;
        dominantColor = colorKey;
      }
    }

    topColors.add(dominantColor);
  }

  return topColors;
}



int calculateColorDistance(int c1, ArrayList<Integer> selectedColors) {
  int r1 = (c1 >> 16) & 0xFF;
  int g1 = (c1 >> 8) & 0xFF;
  int b1 = c1 & 0xFF;

  int minDistance = Integer.MAX_VALUE;

  for (int c2 : selectedColors) {
    int r2 = (c2 >> 16) & 0xFF;
    int g2 = (c2 >> 8) & 0xFF;
    int b2 = c2 & 0xFF;

    int diffR = r2 - r1;
    int diffG = g2 - g1;
    int diffB = b2 - b1;

    int distance = diffR*diffR + diffG*diffG + diffB*diffB; // 類似色が選ばれないための閾値

    if (distance < minDistance) {
      minDistance = distance;
    }
  }

  return minDistance;
}

//////////////////////////////////////////////////////////////////////////////////

void applyColorPalette(PImage img, ArrayList<Integer> colorPalette) {
  colorMode(HSB); // HSBカラーを用いる
  img.loadPixels();

  for (int i = 0; i < img.pixels.length; i++) {
    int pixelColor = img.pixels[i];
    int closestColor = findClosestColor(pixelColor, colorPalette);  //ピクセルの色をパレットの中で一番近い色に置き換える
    float h1 = hue(img.pixels[i]);
    float s1 = saturation(img.pixels[i]); // 彩度
    float b1 = brightness(img.pixels[i]); // 明度
    float h2 = hue(closestColor);
    float s2 = saturation(closestColor); // 彩度
    float b2 = brightness(closestColor); // 明度

    float newH = h2;
    float newS = (3*s1+s2)/4.00;
    float newB = (2*b1+b2)/3.00;
    img.pixels[i] = color(newH, newS, newB);
  }

  img.updatePixels();
}

int findClosestColor(int pixelColor, ArrayList<Integer> colorPalette) {
  //ArrayList<Integer> topColors = new ArrayList<Integer>();
  int r1 = (pixelColor >> 16) & 0xFF;
  int g1 = (pixelColor >> 8) & 0xFF;
  int b1 = pixelColor & 0xFF;

  int closestColor = colorPalette.get(0);
  int minDistance = Integer.MAX_VALUE;

  for (int c2 : colorPalette) {
    int r2 = (c2 >> 16) & 0xFF;
    int g2 = (c2 >> 8) & 0xFF;
    int b2 = c2 & 0xFF;

    int diffR = r2 - r1;
    int diffG = g2 - g1;
    int diffB = b2 - b1;

    int distance = diffR*diffR + diffG*diffG + diffB*diffB; // 類似色が選ばれないための閾値

    if (distance < minDistance) {
      minDistance = distance;
      closestColor = c2;
    }
  }

  return closestColor;
}

class displayClass {

  void scene1() {
    noFill();
    rect(60, 90, 320, 320);
    rect(420, 90, 320, 320);


    noStroke();
    if (dist(220, 450, mouseX, mouseY)<=25) {
      fill(202, 187, 148);
    } else {
      fill(236, 221, 185);
    }
    circle(220, 450, 50);

    if (dist(580, 450, mouseX, mouseY)<=25) {
      fill(202, 187, 148);
    } else {
      fill(236, 221, 185);
    }
    circle(580, 450, 50);

    if (350<mouseX && mouseX<450 && 520<mouseY && mouseY<550) {
      fill(255);
      textSize(25);
      stroke(255);
      line(450, 520, 458, 498);
      line(461, 522, 478, 503);
      line(468, 529, 491, 518);
    } else {
      textSize(23);
      fill(255, 255, 255, 200);
    }
    text("composite!", 400, 535);

    if (flag==1) {
      fill(200, 90, 90);
      textSize(15);
      text("Please choose a photo.", 400, 560);
    }
    textSize(20);
    fill(255);
    text("Choose a photo to process!", 580, 250);
    text("Choose a nice color photo!", 220, 250);
  }

  void scene2() {
    colorMode(RGB, 255, 255, 255);
    noFill();
    stroke(255);
    rect(190, 40, 420, 420);
    if (695<mouseX && mouseX<765 && 530<mouseY && mouseY<570) {
      fill(255);
      textSize(25);
    } else {
      fill(255, 255, 255, 200);
      textSize(23);
    }
    text("back→", 730, 550);


    if (360<mouseX && mouseX<440 && 490<mouseY && mouseY<520) {
      fill(255);
      textSize(27);
      stroke(255);
      line(420, 490, 425, 473);
      line(431, 492, 446, 476);
      line(438, 499, 456, 491);
    } else {
      fill(255, 255, 255, 200);
      textSize(25);
    }
    //rect(360,490,80,30);
    text("save", 400, 500);
  }
}
