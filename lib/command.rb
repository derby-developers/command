require "command/version"

module Command
  def method_missing(method_name, *arguments, &block)
    return super unless instance_methods.include?(method_name)

    initialize_method = instance_method(:initialize)

    keyword_arguments = initialize_method.parameters.any? { |type, name| type == :key }
    optional_arguments = initialize_method.parameters.any? { |type, name| type == :opt }

    complex_arguments = keyword_arguments || optional_arguments

    constructor_arity = initialize_method.arity
    constructor_arity = arguments.length if complex_arguments

    interface_arity = arguments.length - constructor_arity

    constructor_arguments = arguments.first(constructor_arity)
    interface_arguments = arguments.last(interface_arity)

    new(*constructor_arguments).send(method_name, *interface_arguments, &block)
  end

  def respond_to?(method_name, include_private = false)
    return super unless instance_methods.include?(method_name)
    true
  end
end
