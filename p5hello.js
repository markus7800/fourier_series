hello = [
  [-0.5164459406969, -2.421448382170074],
  [-0.47119241956112523, -2.359702434817609],
  [0.6524695901927227, -3.5464498167365184],
  [-0.18276579744721036, -5.3563741242061855],
  [-1.6310621707600936, -5.594131864912485],
  [-2.483338065966408, -4.454865680075322],
  [-1.5732189067952869, -3.4246984440491657],
  [0.3654450854771345, -6.032059755083917],
  [4.24868501831455, -5.49591475909866],
  [-4.616768294807817, -11.585571829108595],
  [-8.132326445933796, -12.823370502197312],
  [-8.63563053708637, -4.884770994178848],
  [-0.3298572309852989, -10.427716431641814],
  [-3.3498411987009806, -24.41411945424079],
  [1.8147168883937868, -51.871635626161506],
  [163.76934808208685, -171.52487403718212],
  [7.990928087101194, 52.929163010494825],
  [8.442140459940521, 25.061556084533677],
  [3.04780080168796, 23.314795627591025],
  [6.923565281946439, 11.971135878278396],
  [-3.1735098283633594, -2.2297452629993595],
  [0.8322120565960185, 2.0869067269042],
  [-0.8217801385463607, 23.020961483155265],
  [-7.663902565262232, -2.617578449955215],
  [-4.947366745956932, 5.656168990842779],
  [-3.128731481739635, 3.4785349459033084],
  [-2.103785866649537, 4.380907702506595],
  [-0.22886536730526447, 3.7014567871963937],
  [-0.61862815936055, 3.6742232267659207],
  [-0.022664132466055777, 2.3015394256852644],
  [0.7592187122453598, 2.503039295381204]
];

class Point {
  constructor(x,y) {
    this.x = x
    this.y = y
  }
}

function circle_point(t, d, z) {
  a = cos(d*t) * z.x - sin(d*t) * z.y
  b = cos(d*t) * z.y + sin(d*t) * z.x
  return new Point(a, b)
}

function plus(a, b) {
  return new Point(a.x+b.x, a.y+b.y)
}

function get_trace_point(hello, t) {
  depth = 15
  n0 = depth + 1
  p = hello[n0-1]

  for (d = 1; d <= depth; d++) {
    n = n0 + d - 1
    cp = circle_point(t, d, hello[n])
    oldp = p
    p = plus(p, cp)

    n = n0 - d - 1
    cp = circle_point(-t, d, hello[n])
    oldp = p
    p = plus(p, cp)

  }

  return p
}

function setup() {
  for (i = 0; i < hello.length; i++) {
    hello[i] = new Point(hello[i][0], hello[i][1])
  }

  t = 0
  circle_stroke = 2
  circle_color = color(0, 155, 250)
  point_color = color(227, 111, 71)
  point_color = color(0, 0, 0)
  point_stroke = 3

  trace = []
  full_trace = []

  tt = 0.15
  while (tt < 2*PI-0.1) {
    pp = get_trace_point(hello, tt)
    tt = tt + 0.005
    full_trace.push(pp)
  }

  y_off = -50
  createCanvas(370, 250)

}

function draw() {
  background(255);
  noFill();

  strokeWeight(3)
  stroke(200, 200, 200)
  for (i=0; i<full_trace.length-1; i++) {
    z1 = full_trace[i]
    z2 = full_trace[i+1]
    line(z1.x, -z1.y + y_off, z2.x, -z2.y + y_off)
  }

  depth = 15
  n0 = depth + 1
  p = hello[n0-1]

  stroke(point_color)
  strokeWeight(point_stroke)
  point(p.x, -p.y + y_off)

  for (d = 1; d <= depth; d++) {
    n = n0 + d - 1
    cp = circle_point(t, d, hello[n])
    oldp = p
    p = plus(p, cp)

    r = sqrt((oldp.x - p.x) * (oldp.x - p.x) + (oldp.y - p.y) * (oldp.y - p.y))

    stroke(circle_color)
    strokeWeight(circle_stroke)
    circle(oldp.x, -oldp.y+ y_off, r*2)

    stroke(point_color)
    strokeWeight(point_stroke)
    circle(p.x, -p.y + y_off, 1)


    n = n0 - d - 1
    cp = circle_point(-t, d, hello[n])
    oldp = p
    p = plus(p, cp)

    r = sqrt((oldp.x - p.x) * (oldp.x - p.x) + (oldp.y - p.y) * (oldp.y - p.y))

    stroke(circle_color)
    strokeWeight(circle_stroke)
    circle(oldp.x, -oldp.y + y_off, r*2)

    stroke(point_color)
    strokeWeight(point_stroke)
    circle(p.x, -p.y + y_off, 1)
  }

  if (0.15 < t && t < 2 * PI - 0.1) {
    trace.push(p)
  }

  stroke(0,0,0)
  strokeWeight(3)
  for (i=0; i<trace.length-1; i++) {
    z1 = trace[i]
    z2 = trace[i+1]
    line(z1.x, -z1.y + y_off, z2.x, -z2.y + y_off)
  }

  t = t + 0.005

  if (t > 2 * PI) {
    t = 0
    trace = []
  }

}
