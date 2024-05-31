# Allow parsing:
#   stringified hash-rockets
#   non-string keys
#   Ruby symbols (both key and val)
#   Date/DateTime objects
#   nil
class JSON
end

# Monkey patch `method_missing` for dot syntax
class Hash
end
