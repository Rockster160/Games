import Char from "./char.js"

export default class Chief extends Char {
  constructor(env) {
    super()
    this.env = env

    this.sprite = env.physics.add.sprite(100, 450, "slime")
    this.sprite.setScale(2, 2)
    // this.sprite.setCollideWorldBounds(true)

    env.anims.create({
      key: "down",
      frames: env.anims.generateFrameNumbers("slime", { start: 0, end: 3 }),
      frameRate: 10,
      repeat: -1
    })

    env.anims.create({
      key: "right",
      frames: env.anims.generateFrameNumbers("slime", { start: 4, end: 7 }),
      frameRate: 10,
      repeat: -1
    })

    env.anims.create({
      key: "up",
      frames: env.anims.generateFrameNumbers("slime", { start: 8, end: 11 }),
      frameRate: 10,
      repeat: -1
    })

    env.anims.create({
      key: "left",
      frames: env.anims.generateFrameNumbers("slime", { start: 12, end: 15 }),
      frameRate: 10,
      repeat: -1
    })

    env.anims.create({
      key: "stand",
      frames: [ { key: "slime", frame: 4 } ],
      frameRate: 20
    })
  }

  // Class method
  // static tick() {
  // }

  motion(cursors) {
    var up = cursors.up.isDown
    var right = cursors.right.isDown
    var down = cursors.down.isDown
    var left = cursors.left.isDown

    var directionY, directionX, spriteDirection
    directionY = (up && !down) ? "up" : (down && !up) ? "down" : undefined
    directionX = (left && !right) ? "left" : (right && !left) ? "right" : undefined
    spriteDirection = directionX || directionY

    if (spriteDirection) {
      this.sprite.anims.play(spriteDirection, true)
    } else {
      this.sprite.anims.stop(null)
    }

    if (directionY == "up") { this.sprite.setVelocityY(-160) }
    if (directionY == "down") { this.sprite.setVelocityY(160) }
    if (directionY == undefined) { this.sprite.setVelocityY(0) }

    if (directionX == "left") { this.sprite.setVelocityX(-160) }
    if (directionX == "right") { this.sprite.setVelocityX(160) }
    if (directionX == undefined) { this.sprite.setVelocityX(0) }
  }

  tick(cursors) {
    this.motion(cursors)
  }
}
