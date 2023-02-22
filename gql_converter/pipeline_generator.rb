class PipelineGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  attr_accessor :namespacing_pascal,
    :namespacing_levels,
    :namespacing_path,
    :resource_snake,
    :resources_snake,
    :resource_pascal,
    :resources_pascal,
    :actions,
    :available_actions

  argument :methods, type: :array, default: [], method: "action1 action2"


  def generate_pipeline
    set_naming
    set_methods

    # add_controller


    # add_route
    add_pipeline
    # add_finder
    # add_serializer
    # add_spec
    # puts template("actions/index", constant: @resource)
  end

  private

  def set_naming
    *namespacing, resource = name.split("::")

    self.namespacing_levels = namespacing
    self.namespacing_pascal = "::#{namespacing.join('::')}"
    self.namespacing_path = namespacing.map(&:snakecase).join("/")

    self.resource_pascal = resource.singularize.camelize
    self.resource_snake = resource.singularize.snakecase

    self.resources_pascal = resource_pascal.pluralize
    self.resources_snake = resource_snake.pluralize
  end

  def set_methods
    self.available_actions = [:index, :show, :create, :update, :destroy]
    self.actions = methods.map { |method_name| method_name.to_sym }

    unknown_actions = actions - available_actions
    return if unknown_actions.none?

    warn "Unknown actions: #{unknown_actions.join(', ')}"
  end

  def naming
    {
      namespacing_pascal: namespacing_pascal,
      namespacing_levels: namespacing_levels,
      namespacing_path:   namespacing_path,
      resource_pascal:    resource_pascal,
      resource_snake:     resource_snake,
      resources_pascal:   resources_pascal,
      resources_snake:    resources_snake,
    }
  end

  def template path, opts={}
    ::SlingshotUtils::Templater.lines_from_template(__dir__, path, naming.merge(opts)) do
      yield if block_given?
    end
  end

  def namespaced_file path, opts={}
    template("files/file") { # Adds frozen string magic comment
      # Base file lines
      template_lines = template(path)

      # Wrap within nested modules
      namespacing_levels.reverse.each do |level|
        template_lines = template("files/module", name: level) { template_lines }
      end

      template_lines
    }
  end

  def add_route
    puts "\e[33m[LOGIT]#add_route\e[0m"
  end

  def add_controller
    controller_filepath = Rails.root.join(
      "app/controllers",
      namespacing_path,
      "#{resources_snake}_controller.rb"
    )

    controller = ::SlingshotUtils::Templater.find_or_create(controller_filepath) do |new_file|
      template_lines = namespaced_file("files/controller")

      new_file.write(template_lines)
    end

    announce_file controller

    actions.reverse.each do |action|
      next if controller.includes?("def #{action}")

      arg_string = case action
      when :index then "(index_params, current_user)"
      when :show then "(params[:id], current_user)"
      when :create then "(#{resource_snake}_params, current_user)"
      when :update then "(params[:id], #{resource_snake}_params, current_user)"
      when :destroy then "(params[:id], current_user)"
      else
        "(params, current_user)"
      end

      action_lines = template(
        "components/controller_action",
        action: action,
        args: arg_string,
      )

      controller.insert(action_lines + ["\n"], after_text: "BaseController")
    end
  end

  def add_pipeline
  end

  def add_finder
  end

  def add_serializer
  end

  def add_spec
  end

  def warn msg
    puts "\e[31m      [PipelineGenerator] #{msg}\e[0m"
  end

  def announce_file templater
    action = case templater.status
    when :created then "\e[32m[created]\e[0m"
    when :existing then "\e[33m[existing]\e[0m"
    end

    puts "      #{action} #{templater.filepath}"
  end
end
