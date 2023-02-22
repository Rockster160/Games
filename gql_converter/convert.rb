require "pry-rails"
require "fileutils"
require "active_support/core_ext/string/inflections"

class String
  def snakecase
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .gsub(/\s/, "_")
      .gsub(/__+/, "_")
      .downcase
  end

  def presence
    strip.length == 0 ? nil : self
  end
end

class Filer
  attr_accessor :filepath, :lines

  def self.find(text, folder)
    filepath = Dir.glob("#{folder}/**/*.rb").find do |f|
      File.read(f).include?(text)
    end

    new(filepath)
  end

  def self.find_or_create(filepath)
    return new(filepath) if File.exists?(filepath)

    path, _, filename = filepath.rpartition("/")

    # Create nested directories
    FileUtils::mkdir_p(path)
    # Create empty file
    File.open(filepath, "w")
    file = new(filepath)
    yield(file) if block_given?
    file
  end

  def initialize(filepath)
    @filepath = filepath
    puts filepath
    @lines = File.read(filepath).split("\n")
  end

  def search_idx(text, after: -1)
    found_idx = lines[(after+1)..-1].index { |l| l.match?(text) }
    raise "Not found: #{text} after: #{after}" if found_idx == 0

    (after + 1) + found_idx
  end

  def includes?(text)
    lines.join("").match?(text)
  end

  def write(newlines)
    File.write(@filepath, newlines.join("\n") + "\n")
    @lines = File.read(@filepath).split("\n")

    self
  end

  def insert(newlines, after_line: nil, after_text: nil, indent: true)
    return insert_after_text(newlines, after_text: after_text, indent: indent) unless after_text.nil?
    return insert_after_line(newlines, after_line: after_line, indent: indent) unless after_line.nil?

    raise "Where to insert?"
  end

  def insert_after_line(newlines, after_line: -1, indent: true)
    newlines = [newlines] if newlines.is_a?(String)
    prev_line_indent = lines[after_line][/^\s*/]
    new_indent = indent ? "  #{prev_line_indent}" : prev_line_indent

    new_file = lines.dup.tap { |changed_lines|
      new_text = newlines.map { |l| "#{new_indent}#{l}".presence }.join("\n")
      changed_lines[after_line] += "\n#{new_text}"
    }

    write(new_file)
  end

  def insert_after_text(newlines, after_text: nil, indent: true)
    after_idx = search_idx(after_text)

    insert_after_line(newlines, after_line: after_idx, indent: indent)
  end
end

class Templater
  def self.from_template(template, opts)
    text = File.read("/Users/rocco/code/games/gql_converter/templates/#{template}_template.txt")

    opts.each do |opt_key, opt_val|
      text.gsub!("{{#{opt_key.to_s}}}", opt_val.to_s)
    end

    text.split("\n")
  end
end

class GQLConvert
  def initialize(endpoint, opts={})
    @endpoint = endpoint
    @method = (opts[:method] || "GET").to_s.upcase
    @action = (opts[:action] || :show).to_sym
    @strong_params = opts[:strong_params] || []
    @serialized_params = opts[:serialized_params] || [:id]

    snake = @endpoint.snakecase
    @resource = (opts[:resource] || snake).to_s.singularize
    @plural_resource = (opts[:plural_resource] || @resource).to_s.pluralize

    @constant = (opts[:constant] || @resource).to_s.camelcase
    @plural_constant = (opts[:plural_constant] || @plural_resource).to_s.camelcase

    find_gql_endpoint
    add_route
    add_serializer
    add_controller
    add_pipeline
    add_spec
  end

  def find_gql_endpoint
    gql = Filer.find("field :#{@endpoint}", "#{$root}/app/graphql")

    field_idx = gql.search_idx("field :#{@endpoint}")
    resolve_idx = gql.search_idx("resolve", after: field_idx)
    resolve_indent = gql.lines[resolve_idx][/^\s*/].length
    end_resolve_idx = gql.search_idx(/^\s{#{resolve_indent}}\S/, after: resolve_idx)

    @block = gql.lines[resolve_idx..end_resolve_idx]
    # Add deprecation warning
    deprecation_lines = Templater.from_template(
      :deprecation,
      action: @action,
      plural_resource: @plural_resource,
    )

    gql.insert(deprecation_lines, after_line: resolve_idx)
  end

  def add_route
    # -- -- If already there, add
    routes = Filer.new("#{$root}/config/routes.rb")
    # TODO: Append to array if actions already exist
    new_route = "resources :#{@plural_resource}, only: [:#{@action}]"

    routes.insert(new_route, after_text: "namespace :web do")
  end

  def add_serializer
    serializer_file = "#{$root}/app/serializers/web/#{@resource}_serializer.rb"

    serializer = Filer.find_or_create(serializer_file) do |file|
      template_lines = Templater.from_template(
        :serializer,
        constant_name: @constant
      )

      file.write(template_lines)
      next if @serialized_params.empty?

      file.insert(@serialized_params.map { |param| ":#{param}," }, after_text: "attributes")
    end
  end

  def add_controller
    controller_file = "#{$root}/app/controllers/web/#{@plural_resource}_controller.rb"
    controller = Filer.find_or_create(controller_file) do |file|
      template_lines = Templater.from_template(
        :controller,
        plural_constant: @plural_constant,
        resource: @resource
      )

      file.write(template_lines)
      next if @strong_params.empty?

      file.insert(@strong_params.map { |param| ":#{param}," }, after_text: "permit")
    end

    return if controller.includes?("def #{@action}")

    args = case @action
    when :index then "(params, current_user)"
    when :show then "(params[:id], current_user)"
    when :create then "(#{@resource}_params, current_user)"
    when :update then "(params[:id], #{@resource}_params, current_user)"
    when :destroy then "(params[:id], current_user)"
    end

    action_lines = Templater.from_template(
      :controller_action,
      action: @action,
      constant: @constant,
      args: args,
    )

    controller.insert(action_lines + ["\n"], after_text: "BaseController")
  end

  def add_pipeline
    pipeline_file = "#{$root}/app/pipelines/web/#{@resource}_pipeline.rb"
    pipeline = Filer.find_or_create(pipeline_file) do |file|
      template_lines = Templater.from_template(
        :pipeline,
        constant: @constant,
      )

      file.write(template_lines)
    end

    return if pipeline.includes?("def #{@action}")

    action_lines = Templater.from_template(
      "pipeline_#{@action}",
      plural_resource: @plural_resource,
      resource: @resource,
      constant: @constant,
    )

    pipeline.insert(["\n"] + action_lines, after_text: "module_function", indent: false)
    pipeline.insert(@block.map { |l| "# #{l}" }, after_text: "def #{@action}")
  end

  def add_spec
    pipeline_file = "#{$root}/spec/requests/web/#{@plural_resource}/#{@action}_spec.rb"
    pipeline = Filer.find_or_create(pipeline_file) do |file|
      template_lines = Templater.from_template(
        "spec_#{@action}",
        plural_resource: @plural_resource,
        resource: @resource,
        constant: @constant,
      )

      file.write(template_lines)
    end
  end
end

$root = "/Users/rocco/code/slingshot"
GQLConvert.new(
  "addFacebookAccountToCompany",
  method:            :patch,
  action:            :update,
  strong_params:     [:company_id, :login_credentials],
  serialized_params: [:id, :name, :status],
  resource:          :facebook_account,
  plural_resource:   nil,
  constant:          nil,
  plural_constant:   nil,
)
