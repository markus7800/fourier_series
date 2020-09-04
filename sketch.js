function setup() {
  canvas = createCanvas(400, 400);
  background(220)
  // slider = createSlider(0, 100, 10, 1)
  button = createButton('Save curve!')
  button.mousePressed(write_to_file)
}

arr = []
isDrawing = false
finishedDrawing = false

function draw() {
  if (mouseIsPressed) {
    if ((0 <= mouseX && mouseX <= canvas.width) && (0 <= mouseY && mouseY <= canvas.height)) {

      if (finishedDrawing) {
        // reset
        background(220)
        finishedDrawing = false
        arr = []
      }
      isDrawing = true

      fill(0)
      ellipse(mouseX, mouseY, 8, 8);
      append(arr, [mouseX, mouseY])
    }
  } else {
    if (isDrawing) {
      finishedDrawing = true
      isDrawing = false
    }
  }

  // let val = slider.value()
  // text("depth = " + val, 10, canvas.height - 10)
}

function write_to_file() {
  var csv = 'x y\n'
  arr.forEach(function(row) {
    csv += row[0] + ' ' + row[1] + '\n'
  })
  var hiddenElement = document.createElement('a');
  hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
  hiddenElement.target = '_blank';
  hiddenElement.download = 'curve.csv';
  hiddenElement.click();
}
