var canvasElement = document.querySelector("#myCanvas");
var context = canvasElement.getContext("2d");

function a() { document.querySelector("[name=a]").value }
function b() { document.querySelector("[name=b]").value }
function c() { document.querySelector("[name=c]").value }
function dA() { document.querySelector("[name=A]").value }
function dB() { document.querySelector("[name=B]").value }
function dC() { document.querySelector("[name=C]").value }

function countInputs() {
  var count = 0

  if (a().length > 0) { count += 1 }
  if (b().length > 0) { count += 1 }
  if (c().length > 0) { count += 1 }
  if (dA().length > 0) { count += 1 }
  if (dB().length > 0) { count += 1 }
  if (dC().length > 0) { count += 1 }

  return count
}

document.querySelectorAll("input").forEach(function(ele) {
  ele.addEventListener("blur", function(evt) {
    if (countInputs() > 3) {
      console.log("Error: Must have exactly 3 inputs");
    } else {

    }
    console.log();
    // debugger

    if (this.className.indexOf("angle") > -1) {
      this.value
    } else if (this.className.indexOf("angle") > -1) {
      this.value
    }
  })
})


// the triangle
context.beginPath();
context.moveTo(100, 100);
context.lineTo(100, 300);
context.lineTo(300, 300);
context.closePath();

// the outline
context.lineWidth = 10;
context.strokeStyle = '#666666';
context.stroke();
