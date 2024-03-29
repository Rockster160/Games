import Chief from "/char/chief.js"

var config = {
  type: Phaser.AUTO,
  width: 800,
  height: 600,
  physics: {
    default: "arcade",
    arcade: {
      fps: 60,
      gravity: { y: 0 }
    }
  },
  scene: {
    preload: preload,
    create: create,
    update: update
  }
}

var game = new Phaser.Game(config)
var chief
// var player, platforms, stars, scoreText, bombs, gameOver
// var score = 0

function preload() {
  this.load.spritesheet("slime", "assets/slime/Slime_Medium_Blue.png", { frameWidth: 32, frameHeight: 32 })
//   this.load.image("sky", "assets/sky.png")
//   this.load.image("ground", "assets/platform.png")
//   this.load.image("star", "assets/star.png")
//   this.load.image("bomb", "assets/bomb.png")
//   this.load.spritesheet("dude", "assets/dude.png", { frameWidth: 32, frameHeight: 48 })
}

function create() {
  chief = new Chief(this)
//   this.add.image(0, 0, "sky").setOrigin(0, 0)
//   scoreText = this.add.text(16, 16, "Score: 0", { fontSize: "32px", fill: "#000" })
//
//   platforms = this.physics.add.staticGroup()
//
//   platforms.create(400, 568, "ground").setScale(2).refreshBody()
//
//   platforms.create(600, 400, "ground")
//   platforms.create(50, 250, "ground")
//   platforms.create(750, 220, "ground")
//
//   player = new Player(this)
//
//
//
//   stars = this.physics.add.group({
//     key: "star",
//     repeat: 11,
//     setXY: { x: 12, y: 0, stepX: 70 }
//   })
//
//   stars.children.iterate(function (child) {
//     child.setBounceY(Phaser.Math.FloatBetween(0.4, 0.8))
//   })
//
//   bombs = this.physics.add.group()
//
//   this.physics.add.collider(bombs, platforms)
//   this.physics.add.collider(stars, platforms)
//
//   this.physics.add.collider(player.sprite, bombs, hitBomb, null, this)
//   this.physics.add.collider(player.sprite, platforms)
//
//   this.physics.add.overlap(player.sprite, stars, collectStar, null, this)
}
//
function update() {
  var cursors = this.input.keyboard.createCursorKeys()
  chief.tick(cursors)
}
//
// function collectStar(player, star) {
//   star.disableBody(true, true)
//   score += 10
//   scoreText.setText("Score: " + score)
//
//   if (stars.countActive(true) === 0) {
//     stars.children.iterate(function (child) {
//       child.enableBody(true, child.x, 0, true, true)
//     })
//
//     var x = (player.x < 400) ? Phaser.Math.Between(400, 800) : Phaser.Math.Between(0, 400)
//
//     var bomb = bombs.create(x, 16, "bomb")
//     bomb.setBounce(1)
//     bomb.setCollideWorldBounds(true)
//     bomb.setVelocity(Phaser.Math.Between(-200, 200), 20)
//   }
// }
//
// function hitBomb(player, bombs) {
//   this.physics.pause()
//   player.setTint(0xff0000)
//   player.anims.play("turn")
//   gameOver = true
// }
