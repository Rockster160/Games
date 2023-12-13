# require_relative "svg"

def generate_spiral_svg(progress)
  # Define the SVG width and height
  svg_width = 400
  svg_height = 400

  # Calculate the center of the SVG
  center_x = svg_width / 2
  center_y = svg_height / 2

  # Calculate the maximum radius based on the SVG dimensions
  max_radius = [center_x, center_y].min - 10

  # Calculate the number of full revolutions
  revolutions = 10

  # Calculate the total number of rings for the given progress
  total_rings = revolutions * progress

  # Create an SVG document
  svg = "<svg xmlns='http://www.w3.org/2000/svg' width='#{svg_width}' height='#{svg_height}'>"

  # Start the path element for the spiral
  svg += "<path d='M#{center_x},#{center_y} "

  # Generate the spiral path data
  (0..revolutions * 360).step(1).each do |angle|
    radians = angle * Math::PI / 180
    radius = max_radius * (1 - angle.to_f / (revolutions * 360))
    x = center_x + radius * Math.cos(radians)
    y = center_y + radius * Math.sin(radians)
    svg += "L#{x},#{y} "
  end

  # Close the path element
  svg += "' stroke='black' stroke-width='2' fill='none' />"

  # Close the SVG document
  svg += '</svg>'

  return svg
end

# Example usage:
progress = 1.0 # Change the progress as needed (0.0 to 10.0)
svg_content = generate_spiral_svg(0.5)
# puts svg_content

File.open("spiral.svg", "w") { |file| file.write(svg_content) }
`open -a 'Google Chrome' 'spiral.svg' && sleep 5 && rm 'spiral.svg'`
