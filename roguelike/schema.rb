require 'pry-rails'
require 'sqlite3'
require './monkey_patches.rb'

class Schema

  # attr_accessor :name, :weight, :icon, :color, :stack_size, :x, :y, :depth, :auto_pickup, :description, :usable_after_death
  BASE_ITEM_TABLE = {
    name: 'TEXT',
    weight: 'REAL',
    icon: 'TEXT',
    color: 'TEXT',
    stack_size: 'INTEGER',
    x: 'INTEGER',
    y: 'INTEGER',
    depth: 'INTEGER',
    auto_pickup: 'TEXT',
    description: 'TEXT',
    usable_after_death: 'TEXT'
  }

  # attr_accessor :range, :destroy_on_collision_with, :on_hit_effect, :on_hit_damage, :collided_action, :projectile_speed, :is_thrown, :ammo_type, :shoot_damage
  PROJECTILE_TABLE = {
    range: 'INTEGER',
    destroy_on_collision_with: 'TEXT',
    on_hit_effect: 'TEXT',
    on_hit_damage: 'INTEGER',
    collided_action: 'TEXT',
    projectile_speed: 'INTEGER',
    is_thrown: 'TEXT',
    ammo_type: 'TEXT',
    shoot_damage: 'INTEGER'
  }

  # attr_accessor :mana_cost, :is_projectile, :non_projectile_script, :type
  SPELL_TABLE = {
    mana_cost: 'INTEGER',
    is_projectile: 'TEXT',
    non_projectile_script: 'TEXT',
    type: 'TEXT'
  }

# attr_accessor :equipment_slot, :is_equipped, :bonus_strength, :bonus_defense, :bonus_accuracy, :bonus_speed, :bonus_health, :bonus_mana, :bonus_energy, :bonus_self_regen, :bonus_magic_power
  EQUIPPABLE_TABLE = {
    equipment_slot: 'TEXT',
    is_equipped: 'TEXT',
    bonus_strength: 'INTEGER',
    bonus_defense: 'INTEGER',
    bonus_accuracy: 'INTEGER',
    bonus_speed: 'INTEGER',
    bonus_health: 'INTEGER',
    bonus_mana: 'INTEGER',
    bonus_energy: 'INTEGER',
    bonus_self_regen: 'INTEGER',
    bonus_magic_power: 'INTEGER'
  }

  # attr_accessor :restore_energy, :restore_mana, :restore_health, :usage_verb, :execution_script
  CONSUMABLE_TABLE = {
    restore_energy: 'INTEGER',
    restore_mana: 'INTEGER',
    restore_health: 'INTEGER',
    usage_verb: 'TEXT',
    execution_script: 'TEXT'
  }

  def self.reset
    if File.file?('test.db')
      File.delete("test.db")
    end
    $sqldb = SQLite3::Database.new "test.db"
    $sqldb.results_as_hash = true
    $sqldb.execute "CREATE TABLE constants(item_ids INTEGER)"
    $sqldb.execute "INSERT INTO constants(item_ids) VALUES (?)", 1

    # Need the Player Schema
    StaticItem.build_table(BASE_ITEM_TABLE.merge({usage_script: 'TEXT'}))
    SpellBook.build_table(BASE_ITEM_TABLE.merge({element: 'TEXT', castable_spells: 'TEXT'}))
    Spell.build_table(BASE_ITEM_TABLE.merge_many(PROJECTILE_TABLE, SPELL_TABLE))
    RangedWeapon.build_table(BASE_ITEM_TABLE.merge_many(PROJECTILE_TABLE, EQUIPPABLE_TABLE))
    MagicWeapon.build_table(BASE_ITEM_TABLE.merge({range: 'INTEGER', type: 'TEXT', mana_usage: 'INTEGER'}))
    MeleeWeapon.build_table(BASE_ITEM_TABLE.merge(EQUIPPABLE_TABLE))
    LightSource.build_table(BASE_ITEM_TABLE.merge_many(EQUIPPABLE_TABLE, {range: 'INTEGER', duration: 'INTEGER', is_lighting: 'TEXT'}))
    Equipment.build_table(BASE_ITEM_TABLE.merge_many(EQUIPPABLE_TABLE, {contains: 'TEXT', size: 'INTEGER'}))
    Consumable.build_table(BASE_ITEM_TABLE.merge(CONSUMABLE_TABLE))
  end

  def self.load
    $sqldb = SQLite3::Database.new "test.db"
    $sqldb.results_as_hash = true
  end

  def self.get_next_id(table)
    next_id = $sqldb.get_first_row("SELECT #{table}_ids FROM constants")["#{table}_ids"]
    $sqldb.execute "UPDATE constants SET #{table}_ids = ?", next_id + 1
    next_id
  end

end

class BaseObject

  def initialize(attrs)
    to_set = symbolify_keys(attrs).filter(attributes)
    to_set.each do |key, value|
      value = true if value.is_a?(String) && value == 'true'
      value = false if value.is_a?(String) && value == 'false'
      instance_variable_set("@#{key}", value)
    end
  end

  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def self.build_table(rows)
    attribute_string = rows.to_a.map {|row_name, row_type| "#{row_name.to_s} #{row_type}"}.join(', ')
    $sqldb.execute "CREATE TABLE #{class_name}(id INTEGER PRIMARY KEY UNIQUE NOT NULL, #{attribute_string})"
  end

  def self.all
    objs = $sqldb.execute "SELECT * FROM #{class_name}"
    objs.map { |obj| new(obj) }
  end

  def self.count
    $sqldb.get_first_row("SELECT count(id) FROM #{class_name}").first.last
  end

  def self.find(id)
    q = $sqldb.get_first_row( "SELECT * FROM #{class_name} WHERE id = ?", id )
    attrs = symbolify_keys(q)
    obj = new(attrs)
    obj.id ? obj : nil
  end

  def save
    attributes_to_set = {}
    attributes.each do |attr_key|
      val = self.method(attr_key).call
      attributes_to_set[attr_key] = val
    end
    if self.id
      update(attributes_to_set)
    else
      attributes_to_set[:id] = Schema.get_next_id('item')
      attributes_to_set = stringify_booleans(attributes_to_set)
      $sqldb.execute "INSERT INTO #{class_name}(#{attributes_to_set.keys.join(', ')}) VALUES (#{attributes_to_set.count.times.map{'?'}.join(', ')})", attributes_to_set.values
      q = $sqldb.get_first_row "SELECT id FROM item ORDER BY id DESC"
      self.class.find(q['id'])
    end
  end

  def update(attributes_to_update)
    return false unless self.id || attributes_to_update[:id]
    pairs = stringify_keys(attributes_to_update)
    pairs = stringify_booleans(pairs)
    $sqldb.execute "UPDATE #{class_name} SET #{pairs.keys.map{|k|"#{k} = ?"}.join(', ')} WHERE id = ?", pairs.values + [self.id]
    self.class.find(self.id)
  end

  def destroy
    $sqldb.execute "DELETE FROM #{class_name} WHERE id = ?", self.id
    true
  end

  def self.create(attrs)
    obj = new(attrs)
    obj.save
  end

  private

  def class_name
    self.class.class_name
  end

  def self.class_name
    @class_name ||= self.to_s.downcase
  end

  def symbolify_keys(hash); self.class.symbolify_keys(hash); end
  def self.symbolify_keys(hash)
    return {} unless hash
    new_hash = {}
    hash.each { |key, value| new_hash[key.to_s.to_sym] = value }
    new_hash
  end

  def stringify_keys(hash); self.class.stringify_keys(hash); end
  def self.stringify_keys(hash)
    return {} unless hash
    new_hash = {}
    hash.each { |key, value| new_hash[key.to_s] = value }
    new_hash
  end

  def stringify_booleans(hash); self.class.stringify_booleans(hash); end
  def self.stringify_booleans(hash)
    return {} unless hash
    new_hash = {}
    hash.each do |key, value|
      val = case value
      when true then 'true'
      when false then 'false'
      else value
      end
      new_hash[key] = val
    end
    new_hash
  end

end
