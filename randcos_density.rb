def randcos(factor:, intervals:)
  min = 0 # Lowest value of domain
  # max = 2 * Math::PI # Highest value of domain
  max = 1.0 # Highest value of domain
  # bound = 64 / (99 * Math::PI) # Upper bound of PDF value
  # Rocco: Not sure why upper bound is set to the above. It works nicely with just "1"
  bound = 1.0

  loop do # Do the following until a value is returned
    # Choose an X inside the desired sampling domain.
    x = rand(min..max)
    # Choose a Y between 0 and the maximum PDF value.
    y = rand(0..bound)
    # Calculate PDF
    # pdf = (((3 + (Math.cos(x))**2)**2) * (1 / (99 * Math::PI / 4)))
    pdf = (1 + ((factor - 1)*(1 - Math.cos(2*Math::PI*intervals*x))/2))/(factor)
    # Does (x,y) fall in the PDF?
    if y < pdf
      # Yes, so return x
      return x
    end
    # No, so loop
  end
end

# Minified
# def randcos(factor:, intervals:)
#   loop do
#     x = rand
#     pdf = (1 + ((factor - 1)*(1 - Math.cos(2*Math::PI*intervals*x))/2))/(factor)
#     break x if rand < pdf
#   end
# end

# Factor is how much more likely the high values are than the low values
# Intervals are how many "peaks" there are.
# 1 interval will create a bell curve
# puts randcos(factor: 5, intervals: 3)
