require "trailblazer/skill"
require "uber/delegates"

# Dependency ("skill") management for Operation.
# Op::[]
# Op::[]=
# Writing, even with an existing name, will never mutate a container.
# Op#[]
# Op#[]=
# Op.(params, { "constructor" => competences })
class Trailblazer::Operation
  module Skill
    # The class-level skill container: Operation::[], ::[]=.
    module Accessors
      # :private:
      def skills
        @skills ||= {}
      end

      extend Uber::Delegates
      delegates :skills, :[], :[]=
    end

    # Overrides Operation::call, creates the Skill hash and passes it to :call.
    module Call
      def call(options={}, *dependencies)
        super Trailblazer::Skill.new(options, *dependencies, self.skills)
        # DISCUSS: should this be: Trailblazer::Skill.new(runtime_options: [options, *dependencies], compiletime_options: [self.skills])
      end
      alias :_call :call

      # It really sucks that Ruby doesn't have method overloading where we could simply have
      # two different implementations of ::call.
      # FIXME: that shouldn't be here in this namespace.
      module Positional
        def call(params={}, options={}, *dependencies)
          attrs = params.key?("params") ? params["params"] : params
          super(options.merge("params" => attrs), *dependencies)
        end
      end
    end

  end
end
