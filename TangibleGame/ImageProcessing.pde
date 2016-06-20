import processing.video.*;
import java.util.*;

class ImageProcessing extends PApplet {


  PVector rot = new PVector(0, 0, 0);
  PImage img;
  PImage houghAccumulator;
  PImage sobelImage;
  PImage convolutedImage;
  ArrayList<PVector> vectors = new ArrayList();
  PImage result ;
  float threshold = 128;
  HScrollbar thresholdBar;
  HScrollbar hueUpperBound;
  HScrollbar hueLowerBound;
  float IMG_SIZE;
  float lower;
  float upper;
  ArrayList<Integer> bestCandidates = new ArrayList();
  QuadGraph graph = new QuadGraph();
  TwoDThreeD proj;

  void settings() {
    size(640, 480);
  }
  
  void setup() {     
    proj = new TwoDThreeD(640, 480);
    result = createImage(640, 480, RGB);
    IMG_SIZE = 640*480;
  }

  void draw() {

    cam.read();
    if (pause) {
      cam.pause();
    } else {
      cam.play();

      cam.loadPixels();

      img = cam.get();
      result.loadPixels();
      colorThreshold(img, 100, 138);
      result.updatePixels();

      binaryThreshold(result, 38, 137);
      saturationThreshold(result, 116, 263);

      convolutedImage = convolute(result);
      sobelImage = sobel(convolutedImage);
      image(img, 0, 0);
      hough(sobelImage, 4);
      getRotation();
    }
  }  



  void saturationThreshold(PImage img, float lower, float upper) {
    loadPixels();
    if (lower > upper) {
      float temp = lower;
      lower = upper;
      upper = temp;
    }
    for (int i = 0; i < IMG_SIZE; i++) {
      if (saturation(img.pixels[i]) >= lower && saturation(img.pixels[i]) <= upper) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }

    updatePixels();
  }
  void binaryThreshold(PImage img, float lower, float upper) {
    loadPixels();
    if (lower > upper) {
      float temp = lower;
      lower = upper;
      upper = temp;
    }
    for (int i = 0; i < IMG_SIZE; i++) {
      if (brightness(img.pixels[i]) >= lower && brightness(img.pixels[i]) <= upper) {
        result.pixels[i] = color(img.pixels[i]);
      } else {
        result.pixels[i] = color(0);
      }
    }

    updatePixels();
  }

  void invertBinaryThreshold(PImage img, float thresh) {
    loadPixels();
    for (int i = 0; i < IMG_SIZE; i++) {
      if (brightness(img.pixels[i]) <= thresh) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }
    updatePixels();
  }

  void hueMap(PImage img) {
    loadPixels();
    for (int i = 0; i < IMG_SIZE; i++) {
      result.pixels[i] = color(hue(img.pixels[i]));
    }
    updatePixels();
  }

  void colorThreshold(PImage img, float lower, float upper) {

    for (int i = 1; i < IMG_SIZE; i++) {
      if (hue(img.pixels[i]) >= lower && hue(img.pixels[i]) <= upper) {
        result.pixels[i] = color(img.pixels[i]);
      } else {
        result.pixels[i] = color(0);
      }
    }
  }

  PImage convolute(PImage img) {
    float[][] kernel = { { 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};
    float weight = 99.f;
    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);
    // kernel size N = 3
    //
    // for each (x,y) pixel in the image:
    // - multiply intensities for pixels in the range
    // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
    // corresponding weights in the kernel matrix
    // - sum all these intensities and divide it by the weight
    // - set result.pixels[y * img.width + x] to this value

    for (int i = 0; i < IMG_SIZE; i++) {
      result.pixels[i] = color(0);
    }



    for (int i = 1; i < img.width -1; i++) {
      for (int j = 1; j < img.height-1; j++) {
        float sum = 0;
        for (int k = i-1; k <= i+1; k++) {
          for (int l = j-1; l <= j+1; l++) {
            sum += brightness(img.pixels[l * img.width + k]) * kernel[k-i+1][l-j+1];
          }
        }

        result.pixels[j * img.width + i] = color(sum/weight);
      }
    }
    return result;
  }

  PImage sobel(PImage img) {
    float[][] hKernel = { { 0, 1, 0 }, 
      { 0, 0, 0 }, 
      { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 }, 
      { 1, 0, -1 }, 
      { 0, 0, 0 } };
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < IMG_SIZE; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];
    // *************************************
    // Implement here the double convolution
    // *************************************
    float weight = 1.f;

    for (int i = 1; i < img.width -1; i++) {
      for (int j = 1; j < img.height-1; j++) {
        float sum_h = 0;
        float sum_v = 0;
        float sum = 0;
        for (int k = i-1; k <= i+1; k++) {
          for (int l = j-1; l <= j+1; l++) {
            sum_h += brightness(img.pixels[l * img.width + k]) * hKernel[k-i+1][l-j+1];
            sum_v += brightness(img.pixels[l * img.width + k]) * vKernel[k-i+1][l-j+1];
          }
        }
        sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        if (sum > max) {
          max = sum;
        }
        buffer[j * img.width + i] = sum;
      }
    }

    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
          result.pixels[y * img.width + x] = color(255);
        } else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
    return result;
  }

  ArrayList<PVector> hough(PImage edgeImg, int nLines) {
    vectors.clear();
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;

    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }

    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator with something like: r += (rDim - 1) / 2

          for (float p = 0; p < phiDim; p++) {
            float r = x * tabCos[(int)p] + y * tabSin[(int) p];
            r = r/discretizationStepsR + (rDim - 1)/2; 
            int index  = round((p+1)*(rDim+2) + r+1);
            accumulator[index] += 1;
          }
        }
      }
    }

    bestCandidates.clear();
    // size of the region we search for a local maximum
    int neighbourhood = 30;
    // only search around lines with more that this amount of votes
    // (to be adapted to your image)
    int minVotes = 200;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          // iterate over the neighbourhood
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
              if (accR+dR < 0 || accR+dR >= rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
            }
            if (!bestCandidate) break;
          }
          if (bestCandidate) {
            // the current idx *is* a local maximum
            bestCandidates.add(idx);
          }
        }
      }
    }


    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    int bestCandidatesSize = bestCandidates.size();
    for (int i = 0; i < nLines && i < bestCandidatesSize; i++) {
      int idx = bestCandidates.get(i);

      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;

      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      
      vectors.add(new PVector(r, phi));
    }
    return vectors;
  }
  ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to ’intersections’
        float d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
        float x = (line2.x*sin(line1.y) - line1.x * sin(line2.y))/d;
        float y = (-line2.x*cos(line1.y) + line1.x*cos(line2.y))/d;
        intersections.add(new PVector(x, y));

        // draw the intersection
        fill(255, 128, 0);
        ellipse(x, y, 10, 10);
      }
    }
    return intersections;
  }
  PVector intersection(PVector line1, PVector line2) {

    double sin_t1 = Math.sin(line1.y);
    double sin_t2 = Math.sin(line2.y);
    double cos_t1 = Math.cos(line1.y);
    double cos_t2 = Math.cos(line2.y);
    float r1 = line1.x;
    float r2 = line2.x;

    double denom = cos_t2 * sin_t1 - cos_t1 * sin_t2;

    int x = (int) ((r2 * sin_t1 - r1 * sin_t2) / denom);
    int y = (int) ((-r2 * cos_t1 + r1 * cos_t2) / denom);
    return new PVector(x, y);
  }

  PVector getRotation() {
    graph.build(vectors, 640, 480);
    graph.findCycles();

    for (int[] quad : graph.cycles) {

      PVector l1 = vectors.get(quad[0]);
      PVector l2 = vectors.get(quad[1]);
      PVector l3 = vectors.get(quad[2]);
      PVector l4 = vectors.get(quad[3]);

      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      float maxArea = proj.boardSize*proj.boardSize+200.f;
      if (graph.isConvex(c12, c23, c34, c41) && graph.nonFlatQuad(c12, c23, c34, c41) && graph.validArea(c12, c23, c34, c41, maxArea, 0)) {
        List<PVector> sortedCorners = graph.sortCorners(Arrays.asList(c12, c23, c34, c41));
        rot = proj.get3DRotations(sortedCorners);
      }
    }

    return rot;
  }
}