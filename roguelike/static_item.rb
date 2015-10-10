class StaticItem < BaseObject
  include Item

  attr_accessor :usage_script

  def examine
    $gamemode = 'play'
    eval(usage_script)
  end

  def self.generate
    new({
      name: 'Slime Ball',
      icon: 'i',
      color: :light_green,
      weight: 0.4,
      stack_size: 30,
      usage_script: 'Log.add "You squish the slime in your fingers."; false',
      description: 'A slime ball dropped by a Slime. Can be fed to Slimes to increase their strength and health.'
    })
  end
end
