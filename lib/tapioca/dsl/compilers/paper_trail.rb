# typed: strict
# frozen_string_literal: true

begin
  require "paper_trail"
rescue LoadError
  return
end

module Tapioca
  module Dsl
    module Compilers
      # `Tapioca::Dsl::Compilers::Papertrail` decorates RBI files for all
      # classes that use [`PaperTrail`](https://github.com/paper-trail-gem/paper_trail).
      #
      # For example, with the following class:
      #
      # ~~~rb
      # class User
      #   has_paper_trail
      # end
      # ~~~
      #
      # this compiler will produce an RBI file with the following content:
      # ~~~rbi
      # # typed: true
      #
      # class User
      #   sig { returns(T.untyped) }
      #   def paper_trail; end
      # end
      # ~~~
      class PaperTrail < Compiler
        extend T::Sig

        ConstantType = type_member { { fixed: T.all(Class, ::PaperTrail::Model::ClassMethods) } }

        sig { override.void }
        def decorate
          instance_methods_modules = [::PaperTrail::Model::InstanceMethods]

          methods = instance_methods_modules.flat_map { |mod| mod.instance_methods(false) }
          return if methods.empty?
          return unless methods.any? { |method| constant.method_defined?(method) }

          root.create_path(constant) do |klass|
            methods.each do |method|
              create_method_from_def(klass, constant.instance_method(method))
            end
          end
        end

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            descendants_of(::ActiveRecord::Base).reject(&:abstract_class?)
          end
        end
      end
    end
  end
end
