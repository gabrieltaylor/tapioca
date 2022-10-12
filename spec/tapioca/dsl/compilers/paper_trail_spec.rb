# typed: strict
# frozen_string_literal: true

require "spec_helper"

module Tapioca
  module Dsl
    module Compilers
      class PaperTrailSpec < ::DslSpec
        describe "Tapioca::Dsl::Compilers::PaperTrailSpec" do
          describe "initialize" do
            it "gathers no constants if there are no classes using ActiveModel::SecurePassword" do
              assert_empty(gathered_constants)
            end

            it "gathers only ActiveRecord subclasses" do
              add_ruby_file("content.rb", <<~RUBY)
                class Post < ActiveRecord::Base
                end

                class Current
                end
              RUBY

              assert_equal(["Post"], gathered_constants)
            end

            it "rejects abstract ActiveRecord subclasses" do
              add_ruby_file("content.rb", <<~RUBY)
                class Comment < ActiveRecord::Base
                end

                class Post < Comment
                end

                class Current < ActiveRecord::Base
                  self.abstract_class = true
                end
              RUBY

              assert_equal(["Comment", "Post"], gathered_constants)
            end
          end

          describe "decorate" do
            it "generates empty RBI file if there are no calls to has_secure_password" do
              add_ruby_file("user.rb", <<~RUBY)
                class User
                end
              RUBY

              expected = <<~RBI
                # typed: strong
              RBI

              assert_equal(expected, rbi_for(:User))
            end

            it "generates default secure password methods" do
              add_ruby_file("user.rb", <<~RUBY)
                class User
                  has_paper_trail
                end
              RUBY

              expected = template(<<~RBI)
                # typed: strong

                class User
                  sig { returns(T.untyped) }
                  def paper_trail; end
                end
              RBI

              assert_equal(expected, rbi_for(:User))
            end
          end
        end
      end
    end
  end
end
