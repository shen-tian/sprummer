import me.lsdo.processing.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import java.util.Random;

Minim minim;
AudioSource in;

BeatDetect beat;
FFT fft;
float[] fftFilter;
float[] onsetBars;

CanvasSketch simple;

Random random;

void setup()
{
    size(300, 300);
    simple = new CanvasSketch(this, new Dome(6), new OPC());

    minim = new Minim(this); 
    in = minim.getLineIn();

    beat = new BeatDetect();
    beat.detectMode(BeatDetect.FREQ_ENERGY);
    beat.setSensitivity(150);
    
    onsetBars = new float[beat.dectectSize()];
    
    fft = new FFT(in.bufferSize(), in.sampleRate());
    fftFilter = new float[fft.specSize()];
    
    random = new Random();
    
    rings = new ArrayList<Float>();

    colorMode(HSB, 100);
}

float decay = .97;
int bands = 30;

float rotOffset;

ArrayList<Float> rings;

void draw()
{
    long t = millis();
    background(0);
    
    fft.forward(in.mix);
    beat.detect(in.mix);

    for (int i = 0; i < fft.specSize (); i++) {
        fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
    }
    
    if (beat.isOnset(0))
    {
        rotOffset += PI / 12;
    }
    if (rotOffset > 2 * PI)
        rotOffset -= (2 * PI);

    translate(width/2, height/2);
    rotate(2 * PI * ((t / 30 % 1000)/1000f) + rotOffset);
    
    for (int i = 0; i < bands; i ++)
    {
        fill(i * 100. / bands, 80, 50);
        stroke(0);
        int samples = fft.specSize() / bands;
        float total = 0;
        for (int j =0; j < samples; j++)
            total += fftFilter[fft.specSize() * i / bands + j];

        int bandHeight = (int)(total / samples * 100);
        float slice = PI/bands;
        
        //arc(0, 0, bandHeight, bandHeight, (i * slice) - PI/2, (i * slice) - PI/2 + slice);
    }
    float totalLevel = 0;
    for (int i = 0; i < fft.specSize(); i++)
        totalLevel += fftFilter[i];
        
    float approxLevel = max(totalLevel/700., 1);
    
    
    int onsetCount = 0;
    int oBands = beat.dectectSize() - 3;
    
    for (int i = 0; i < oBands; i++)
    {
        float hue = i * 1. / oBands;
        fill(30 + hue * 60, 60, approxLevel * 100);
        stroke(0);

        onsetBars[i] = (beat.isOnset(i)) ? 250 + approxLevel * 50 : decay * onsetBars[i];
        
        if (beat.isOnset(i))
            onsetCount++;
            
        float slice = PI/oBands;
        
        float startAngle = i * slice;
        float endAngle = (i + 1) * slice;
        
        arc(0, 0, onsetBars[i], onsetBars[i], - PI/2 + startAngle, - PI/2 + endAngle);
        arc(0, 0, onsetBars[i], onsetBars[i], - PI/2 - endAngle, - PI/2 - startAngle);
    }
    
    if (beat.isRange(0, 10, 3))
    {
        rings.add(new Float(10));
    }
    
    fill(#000000);
    
    ellipse(0, 0, 50, 50);
        
    noFill();
    strokeWeight(10);
    for (int i = 0; i < rings.size(); i++)
    {
        float radius = rings.get(i);
        rings.set(i, new Float(radius + 4));
        
        stroke(#000000, 75);
        ellipse(0, 0, radius, radius);
        
        if (radius > width)
            rings.remove(i);
        
    }
    
    strokeWeight(0);
    
        fill(#FF0000);
    
    simple.draw();
}


