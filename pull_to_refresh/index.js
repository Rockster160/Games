// Initialize variables
var startY = 0;
var isDragging = false;
var topOffset = 0;

// Add touchstart event listener to container
document.getElementById('container').addEventListener('touchstart', function(e) {
  // If container is already scrolled to the top, store the starting Y position of the touch
  if (this.scrollTop === 0) {
    startY = e.touches[0].screenY;
    isDragging = true;
  }
});

// Add touchmove event listener to container
document.getElementById('container').addEventListener('touchmove', function(e) {
  // If user is dragging and hasn't dragged past the top of the container
  if (isDragging && e.touches[0].screenY > startY) {
    // Prevent the browser from scrolling
    e.preventDefault();
    // Calculate how far the user has dragged
    var dragDistance = e.touches[0].screenY - startY;
    // Move the container down by the distance dragged
    this.style.transform = 'translate3d(0, ' + (dragDistance - topOffset) + 'px, 0)';
  }
});

// Add touchend event listener to container
document.getElementById('container').addEventListener('touchend', function(e) {
  // If user has dragged more than 100px, refresh the page
  if (isDragging && e.changedTouches[0].screenY > startY + 100) {
    location.reload();
  } else {
    // Otherwise, animate the container back to its starting position
    this.style.transition = 'transform 0.3s';
    this.style.transform = 'translate3d(0, ' + -topOffset + 'px, 0)';
    // Reset variables
    startY = 0;
    isDragging = false;
    topOffset = 0;
    // Add transitionend event listener to container
    this.addEventListener('transitionend', function() {
      // Remove the transition once it has ended
      this.style.transition = '';
    }, {once: true});
  }
});

// Add resize event listener to window
window.addEventListener('resize', function() {
  // Update the top offset when the window is resized
  topOffset = document.getElementById('content').offsetTop;
});
