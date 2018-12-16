import java.applet.Applet;
import java.awt.*;
import java.lang.*;
import java.io.*;

public class MixtureEM extends Applet {
  ControlPanel cPanel;
  PlotCanvas pCanvas;
  CurvedGaussMixture CGMix;
  GaussLineMixture GLMix;
  Database DB;
  final int xSize = 600;
  final int ySize = 300;

  public void init() {
    setLayout(new BorderLayout());
    DB = new Database(xSize, ySize, Color.black);
    CGMix = new CurvedGaussMixture(xSize, ySize, DB);
    GLMix = new GaussLineMixture(xSize, ySize, DB);
    pCanvas = new PlotCanvas(CGMix,
                             GLMix,
                             DB, xSize, ySize);
    cPanel = new ControlPanel(pCanvas,
                              CGMix,
                              GLMix,
                              DB);
    add("Center", pCanvas);
    add("South", cPanel);
  }
}

class ControlPanel extends Panel implements Runnable {
  Choice nKernels;
  Choice selectmix;
  Choice EMswitch;
  PlotCanvas pcanvas;
  CurvedGaussMixture cgmix;
  GaussLineMixture glmix;
  int select;
  Database db;
  double[] ws, ws2;
  Thread th;
  boolean runMode = false;

  public ControlPanel (PlotCanvas pC,
                       CurvedGaussMixture CGMix,
                       GaussLineMixture GLMix,
                       Database DB) {
    cgmix = CGMix;
    glmix = GLMix;
    db = DB;
    pcanvas = pC;
    pcanvas.connectControlPanel(this);
    ws = new double[6];
    ws2 = new double[6];
    ws[0] = 0.1;
    ws2[0] = 10;
    for(int i = 1; i < 6; i++) ws[i] = ws2[i] = 1;

    setLayout(new FlowLayout());
    setselect(3);
    selectmix = new Choice();
  selectmix.addItem("GaussMix");
  selectmix.addItem("LineMix");
    add(selectmix);

    add(new Button("RandomPts"));
    add(new Button("ClearPts"));
    add(new Button("InitKernels"));

    nKernels = new Choice();
    nKernels.addItem("1");
    nKernels.addItem("2");
    nKernels.addItem("3");
    nKernels.addItem("4");
    nKernels.addItem("5");
    add(nKernels);

    EMswitch = new Choice();
    EMswitch.addItem("EM Stop");
    EMswitch.addItem("EM Run");
    EMswitch.addItem("EM 1 Step");
    add(EMswitch);
  }

  public void start() {
    if(th == null) {
      th = new Thread(this);
    }
    th.start();
  }

  public void stop() {
    if((th != null) && (th.isAlive())) {
      th.stop();
    }
    th = null;
  }

  public void run() {
    while(th != null) {
      try {
        for(int i = 0; i < 5; i++) {
            EM();
        }
        pcanvas.repaint();
        Thread.sleep(200);
      } catch(InterruptedException e) {
      }
    }
  }

  private void EM() {
    if(select == 3) {
      cgmix.EM(ws);
    } else if(select == 4) {
      glmix.EM(ws);
    }
  }

  public void dbpush(int x, int y) {
    if(th != null) {
      stop();
      db.push(x, y);
      start();
    } else {
      db.push(x, y);
    }
  }

  public boolean action(Event e, Object arg) {
    String ch;
    int nK;
    boolean thflag;

    ch = (String) arg;
    thflag = (th != null);
    if(e.target instanceof Choice) {
      if("GaussMix".equals(ch)) {
        setselect(3);
        cgmix.randomKernels(ws2);
      } else if("LineMix".equals(ch)) {
        setselect(4);
        glmix.randomKernels(ws2);
      } else if("EM Stop".equals(ch)) {
        stop();
      } else if("EM Run".equals(ch)) {
        stop();
        start();
      } else if("EM 1 Step".equals(ch)) {
        stop();
        EM();
      } else {
	stop();
        nK = Integer.parseInt((String) arg);
        cgmix.setnk(nK + 1, ws);
        glmix.setnk(nK + 1, ws);
	if(thflag) start();
      }
      pcanvas.repaint();
      return true;
    } else if(e.target instanceof Button) {
      stop();
      if("ClearPts".equals(ch)) {
        db.clearPoints();
      } else if("RandomPts".equals(ch)) {
        db.randomPoints(10);
      } else if("InitKernels".equals(ch)) {
        cgmix.randomKernels(ws);
        glmix.randomKernels(ws);
      }
      pcanvas.repaint();
      if(thflag) start();
      return true;
    }
    return false;
  }

    public void setselect(int sel) {
	select = sel;
	pcanvas.setselect(sel);
    }
}

class PlotCanvas extends Canvas {
  ControlPanel cp;
  Database db;
  CurvedGaussMixture cgmix;
  GaussLineMixture glmix;
  int select;
  int xsiz, ysiz;

  public PlotCanvas(CurvedGaussMixture CGMix,
                    GaussLineMixture GLMix,
                    Database DB, int xSize, int ySize) {
    cgmix = CGMix;
    glmix = GLMix;
    db = DB;
    setBackground(Color.green);
    xsiz = xSize;
    ysiz = ySize;
    resize(xSize, ySize);
  }

  public void connectControlPanel(ControlPanel cPanel) {
    cp = cPanel;
  }

  public void paint(Graphics g) {
    g.clearRect(0, 0, xsiz, ysiz);
    db.paint(g);
    if(select == 3) {
      cgmix.paint(g);
    } else if(select == 4) {
      glmix.paint(g);
    }
  }


  public void setselect(int sel) {
    select = sel;
  }

  public boolean handleEvent(Event e) {
    switch(e.id) {
      case Event.MOUSE_DOWN:
        cp.dbpush(e.x, e.y);
        repaint();
      case Event.MOUSE_DRAG:
        cp.dbpush(e.x, e.y);
        repaint();
    }
    return true;
  }
}

class CurvedGaussMixture extends Mixture {
  final int kmax = 10;

  public CurvedGaussMixture(int xSize, int ySize, Database DB) {
    super(xSize, ySize, DB);
    initKernel(new Uniform(xsiz, ysiz, 0.0), typeuniform, 0);
    for(int i = 1; i < kmax; i++) {
      initKernel(new CurvedGaussian(xsiz, ysiz, 0.0), typecurvedgauss, i);
    }
    setnk(2);
  }
}

class GaussLineMixture extends Mixture {
  final int kmax = 10;

  public GaussLineMixture(int xSize, int ySize, Database DB) {
    super(xSize, ySize, DB);
    CurvedGaussian cgmix;
    initKernel(new Uniform(xsiz, ysiz, 0.0), typeuniform, 0);
    for(int i = 1; i < kmax; i++) {
      cgmix = new CurvedGaussian(xsiz, ysiz, 0.0);
      cgmix.setplotline();
      initKernel(cgmix, typecurvedgauss, i);
    }
    setnk(2);
  }
}



