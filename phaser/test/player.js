import Char from "/char.js"

// class Player extends Char {}
export default class Player extends Char {
  constructor(env) {
    super()
    this.env = env

    this.sprite = env.physics.add.sprite(100, 450, "dude")
    this.sprite.setBounce(0.2)
    this.sprite.setCollideWorldBounds(true)
  }

  // Class method
  // static tick() {
  // }

  motion(cursors) {
    if (cursors.left.isDown) {
      this.sprite.setVelocityX(-160)

      this.sprite.anims.play("left", true)
    } else if (cursors.right.isDown) {
      this.sprite.setVelocityX(160)

      this.sprite.anims.play("right", true)
    } else {
      this.sprite.setVelocityX(0)

      this.sprite.anims.play("turn")
    }

    if (cursors.up.isDown && this.sprite.body.touching.down) {
      this.sprite.setVelocityY(-330)
    }
  }

  tick(cursors) {
    this.motion(cursors)
  }
}
