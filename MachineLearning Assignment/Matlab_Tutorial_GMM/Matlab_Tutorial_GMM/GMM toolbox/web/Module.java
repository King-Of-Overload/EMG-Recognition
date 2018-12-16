import java.awt.*;
import java.io.*;

abstract class Module {
  int xsiz, ysiz;
  double weight;
  double[] probs;

  public Module(int xSiz, int ySiz, double w) {
    xsiz = xSiz;
    ysiz = ySiz;
    weight = w;
    randomKernel(w);
  }

  public void setweight(double w) {
	weight = w;
  }

  abstract void randomKernel(double w);
  

  abstract void paint(Graphics g, Database db);
  

  abstract double density(int x, int y);
  

  public double[] calcp(Database db) {
    int j, np;
    
    np = db.nPoints();
    probs = new double[np];
    for(j = 0; j < np; j++) probs[j] = density(db.xVal(j), db.yVal(j));
    return probs;
  }

  public void EMprob(double[] px, Database db) {
    int np;
    np = db.nPoints();
    weight = 0;
    for(int j = 0; j < np; j++) {
      probs[j] /= px[j];
      weight += probs[j];
    }
    weight /= np;
  }  

  abstract void EMpar(Database db, double prior);
}

/*
class Gaussian extends Module {
  double kmx, kmy, ksx, ksy;
  final int mins = 5;

    public  Gaussian(int xSize, int ySize, double w) {
      super(xSize, ySize, w);
    }

  public void randomKernel(double w) {
    weight = w;
    kmx = xsiz * Math.random();
    kmy = ysiz * Math.random();
    ksx = xsiz / 4 + mins;
    ksy = ysiz / 4 + mins;
  }

  public double[] getPar() {
    double pars[];
    pars = new double[5];
    pars[0] = weight;
    pars[1] = kmx;
    pars[2] = kmy;
    pars[3] = ksx;
    pars[4] = ksy;
    return pars;
  }

  public void paint(Graphics g, Database db) {
    int j;
    g.setColor(Color.red);
    g.drawString(weight + "", (int) kmx, (int) kmy);
    g.setColor(Color.blue);
    for(j = 1; j < 4; j++) {
      g.drawArc((int)(kmx-j * ksx), (int)(kmy-j * ksy), 
          (int)(j * ksx * 2), (int)(j * ksy * 2), 0, 360);
    }
  }

  public double density(int x, int y) {
    double tmpx, tmpy;
    tmpx = (x - kmx) / ksx;
    tmpy = (y - kmy) / ksy;
    return weight / ksx / ksy / 6.28319 *
      Math.exp(-(tmpx * tmpx + tmpy * tmpy) / 2);
  }

  public void EMpar(Database db, double prior) {
    int j, np;
    double x, y, tmp, tmpx, tmpy, tmpsx, tmpsy;

    np = db.nPoints();
    tmpsx = tmpsy = kmx = kmy = 0;
    for(j = 0; j < np; j++) {
      x = db.xVal(j);
      y = db.yVal(j);
      kmx += probs[j] * x;
      kmy += probs[j] * y;
      tmpsx += probs[j] * x * x;
      tmpsy += probs[j] * y * y;
    }
    tmp = np * weight;
    kmx /= tmp;
    kmy /= tmp;
    ksx = Math.sqrt(tmpsx / tmp - kmx * kmx);
    ksy = Math.sqrt(tmpsy / tmp - kmy * kmy);
    if(ksx < mins) ksx = mins;
    if(ksy < mins) ksy = mins;
    weight = 0.9 * weight + 0.1 * prior;
  }
}

class Line extends Module {
  double a;
  double b;
  double s;
  int mins = 1;

  public Line(int xSiz, int ySiz, double w) {
    super(xSiz, ySiz, w);
  }

  public void randomKernel(double w) {
    double x1, x2, y1, y2;
    weight = w;
    x1 = xsiz * Math.random();
    x2 = xsiz * Math.random();
    y1 = ysiz * Math.random();
    y2 = ysiz * Math.random();
    a = (y2 - y1) / (x2 - x1);
    b = y1 - (y2 - y1) * x1 / (x2 - x1);
    s = ysiz / 3;
  }

  public void paint(Graphics g, Database db) {
    g.setColor(Color.red);
    g.drawString(weight + "", 0, (int) b);
    g.setColor(Color.yellow);
    for(int j = -1; j <= 1; j++) {
	g.drawLine(0, (int) (b + s * j), (int) xsiz, (int) (xsiz * a + b + s * j));
    }
    g.setColor(Color.blue);
    g.drawLine(0, (int) b, (int) xsiz, (int) (xsiz * a + b));
  }

  public double density(int x, int y) {
    double tmp;
    tmp = (y - a * x - b) / s;
    return weight / s / Math.sqrt(6.28319) *
             Math.exp(- tmp * tmp / 2);
  }

  public void EMpar(Database db, double prior) {
    int j, np;
    double x, y, tmp, tmpx, X0, X1, X2, Y1, XY;

    np = db.nPoints();
    X2 = X1 = X0 = XY = Y1 = 0;
    for(j = 0; j < np; j++) {
      x = db.xVal(j);
      y = db.yVal(j);
      X2 += probs[j] * x * x;
      X1 += probs[j] * x;
      X0 += probs[j];
      XY += probs[j] * x * y;
      Y1 += probs[j] * y;
    }
    tmp = X2 * X0 - X1 * X1;
    a = (X0 * XY - X1 * Y1) / tmp;
    b = (X2 * Y1 - X1 * XY) / tmp;
    tmp = 0;
    for(j = 0; j < np; j++) {
      x = db.xVal(j);
      y = db.yVal(j);
      tmpx = y - a * x - b;
      tmp += probs[j] * tmpx * tmpx;
    }
    s = Math.sqrt(tmp / np / weight);
    if(s < mins) s = mins;
    weight = 0.9 * weight + 0.1 * prior;
  }
}
*/

class CurvedGaussian extends Module {
  double kmx, kmy, ksx, ksy, ksxy;
  final int mins = 5;
  boolean plotcircle = true;

    public  CurvedGaussian(int xSize, int ySize, double w) {
      super(xSize, ySize, w);
    }

  public void randomKernel(double w) {
    weight = w;
    kmx = xsiz * Math.random();
    kmy = ysiz * Math.random();
    ksx = xsiz / 4 + mins;
    ksy = ysiz / 4 + mins;
    ksxy = 0;
  }

  public void setplotline() {
    plotcircle = false;
  }

  public double[] getPar() {
    double pars[];
    pars = new double[6];
    pars[0] = weight;
    pars[1] = kmx;
    pars[2] = kmy;
    pars[3] = ksx;
    pars[4] = ksy;
    pars[5] = ksxy;
    return pars;
  }

  public void paint(Graphics g, Database db) {
    int j;
    double theta, u1x, u1y, u2x, u2y, r1, r2, tmp, varx, vary;

    if(Math.abs(ksxy) <= 1e-4) {
      if(ksx > ksy) {
        u1x = u2y = 1;
        u1y = u2x = 0;
        r1 = ksx;
        r2 = ksy;
      } else {
        u1x = u2y = 0;
        u1y = u2x = 1;
        r1 = ksy;
        r2 = ksx;
      }
    } else {
      varx = ksx * ksx;
      vary = ksy * ksy;
      // eigen value
      tmp = varx - vary;
      tmp = Math.sqrt(tmp * tmp + 4 * ksxy * ksxy);
      r1 = Math.sqrt((varx + vary + tmp) / 2);
      r2 = Math.sqrt((varx + vary - tmp) / 2);

      // eigen vectors
      u1x = r1 * r1 - vary;
      tmp = Math.sqrt(u1x * u1x + ksxy * ksxy);
      u1x /= tmp;
      u1y = ksxy / tmp;

      u2x = r2 * r2 - vary;
      tmp = Math.sqrt(u2x * u2x + ksxy * ksxy);
      u2x /= tmp;
      u2y = ksxy / tmp;
    }    
    g.setColor(Color.red);
    g.drawString(weight + "", (int) kmx, (int) kmy);
    g.setColor(Color.blue);
    if(plotcircle) {
      for(j = 1; j < 4; j++) {
        drawCurvedOval(g, u1x, u1y, u2x, u2y, r1 * j, r2 * j);
      }
    } else {
      g.drawLine((int)(kmx + 3 * r1 * u1x), (int)(kmy + 3 * r1 * u1y),
               (int)(kmx - 3 * r1 * u1x), (int)(kmy - 3 * r1 * u1y));
    }
  }

  public void drawCurvedOval(Graphics g, 
      double x1, double y1, double x2, double y2, double r1, double r2) {
    int fx, fy, tx, ty;
    double w1, w2;

    fx = (int) (kmx + r1 * x1);
    fy = (int) (kmy + r1 * y1);
    for(double th = 0.1; th < 6.4; th += 0.1) {
      w1 = Math.cos(th);
      w2 = Math.sin(th);
      tx = (int) (kmx + r1 * x1 * w1 + r2 * x2 * w2);
      ty = (int) (kmy + r1 * y1 * w1 + r2 * y2 * w2);
      g.drawLine(fx, fy, tx, ty);
      fx = tx;
      fy = ty;
    }
  }

  public double density(int x, int y) {
    double tmpx, tmpy, tmpxy, det, varx, vary;
    varx = ksx * ksx;
    vary = ksy * ksy;
    det = varx * vary - ksxy * ksxy;
    tmpx = (x - kmx) * (x - kmx);
    tmpy = (y - kmy) * (y - kmy);
    tmpxy = (x - kmx) * (y - kmy);
    return weight / Math.sqrt(det) / 6.28319 *
      Math.exp(-(tmpx * vary + tmpy * varx - 2 * tmpxy * ksxy) / det / 2);
  }

  public void EMpar(Database db, double prior) {
    int j, np;
    double x, y, tmp, tmpx, tmpy, tmpsx, tmpsy, tmpsxy;

    np = db.nPoints();
    tmpsx = tmpsy = tmpsxy = kmx = kmy = 0;
    for(j = 0; j < np; j++) {
      x = db.xVal(j);
      y = db.yVal(j);
      kmx += probs[j] * x;
      kmy += probs[j] * y;
      tmpsx += probs[j] * x * x;
      tmpsy += probs[j] * y * y;
      tmpsxy += probs[j] * x * y;
    }
    tmp = np * weight;
    kmx /= tmp;
    kmy /= tmp;
    ksx = Math.sqrt(tmpsx / tmp - kmx * kmx);
    ksy = Math.sqrt(tmpsy / tmp - kmy * kmy);
    ksxy = tmpsxy / tmp - kmx * kmy;
    if(ksx < mins) ksx = mins;
    if(ksy < mins) ksy = mins;
    weight = 0.9 * weight + 0.1 * prior;
  }
}

class Uniform extends Module {

    public  Uniform(int xSize, int ySize, double w) {
	super(xSize, ySize, w);
    }

    void randomKernel(double w)  {
      weight = w;      
    }

    void paint(Graphics g, Database db)  {
    }

    double density(int x, int y)  {
      return weight / xsiz / ysiz;
    }

    void EMpar(Database db, double prior)  {
    }
}

/*
class ScaleShift extends Module {
  double kmx, kmy, ksx, ksy;
  double[] sweight, skmx, skmy, sksx, sksy;
  int nsk;
  final int nskmax = 5;
  final int mins = 5;
 
  public ScaleShift(int xSize, int ySize, double w) {
    super(xSize, ySize, w);
    sweight = new double[nskmax];
    skmx = new double[nskmax];
    skmy = new double[nskmax];
    sksx = new double[nskmax];
    sksy = new double[nskmax];
    nsk = 0;
  }

  public void setnum(int n) {
    if(n < nskmax) nsk = n; else nsk = nskmax;
  }

  public void setpar(int i, double mx, double my, double sx, double sy) {
    if(i < nsk) {
      skmx[i] = mx;
      skmy[i] = my;
      sksx[i] = sx;
      sksy[i] = sy;
    }
  }
    
  public void randomKernel(double w) {
    weight = w;
    kmx = xsiz * Math.random();
    kmy = ysiz * Math.random();
    ksx = 1;
    ksy = 1;
  }

  public void paint(Graphics g, Database db) {
    int j;
    g.setColor(Color.blue);
    for(j = 0; j < nsx; j++) {
      g.drawArc((int)(kmx+skmx[j]-sksx[j]), (int)(kmy+skmy[j]-sksy[j]),
        (int)(sksx[j] * 2), (int)(sksy[j] * 2), 0, 360);
    }
  }

  public double density(int x, int y) {
    int j;
    for(j = 0; j < nsx; j++) {
//
//
//
    }
  }
  
  public void EMprob(double[] px, Database db) {
//    int np;
//    np = db.nPoints();
//    weight = 0;
//    for(int j = 0; j < np; j++) {
//      probs[j] /= px[j];
//      weight += probs[j];
//    }
//    weight /= np;
  }  

  public void EMpar(Database db, double prior) {
//
//
//
  }
}
*/
