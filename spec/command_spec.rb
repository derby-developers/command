require 'spec_helper'

describe Command do
  it 'has a version number' do
    expect(Command::VERSION).not_to be nil
  end

  let(:command_class) do
    Class.new do
      extend Command

      def initialize(dependency)
        @dependency = dependency
      end

      def do_the_damn_thing
        @dependency.do_something
      end
    end
  end

  let(:dependency) { double("dependency") }

  it "exposes instance methods as class methods" do
    expect(dependency).to receive(:do_something)
    command_class.do_the_damn_thing(dependency)
  end

  it "doesn't add methods that don't exist" do
    expect { command_class.this_is_not_a_method }.to raise_error(NoMethodError)
  end

  it "respects respond_to?" do
    expect(command_class.respond_to?(:do_the_damn_thing)).to eq(true)
    expect(command_class.respond_to?(:this_is_not_a_method)).to eq(false)
  end

  context "interface injection" do
    let(:command_class) do
      Class.new do
        extend Command

        def do_the_damn_thing(dependency)
          dependency.do_something
        end
      end
    end

    let(:dependency) { double("dependency") }

    it "exposes instance methods as class methods" do
      expect(dependency).to receive(:do_something)
      command_class.do_the_damn_thing(dependency)
    end
  end

  context "mixed constructor/interface injection" do
    let(:command_class) do
      Class.new do
        extend Command
        attr_reader :dependency_1

        def initialize(dependency_1)
          @dependency_1 = dependency_1
        end

        def do_the_damn_thing(dependency_2)
          dependency_1.do_something
          dependency_2.do_something_else
        end
      end
    end

    let(:dependency_1) { double("dependency_1") }
    let(:dependency_2) { double("dependency_2") }

    it "merges both types of dependencies" do
      expect(dependency_1).to receive(:do_something)
      expect(dependency_2).to receive(:do_something_else)

      command_class.do_the_damn_thing(dependency_1, dependency_2)
    end
  end

  context "with a block" do
    let(:command_class) do
      Class.new do
        extend Command

        def do_the_damn_thing(&block)
          yield
        end
      end
    end

    it "forwards the block to the interface" do
      block_was_called = false
      command_class.do_the_damn_thing { block_was_called = true }

      expect(block_was_called).to eq(true)
    end
  end
end
