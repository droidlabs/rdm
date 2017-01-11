module Rdm
  module Gen
    module Concerns
      module TemplateHandling
        # depends on target_path, templates_path methods in the including class!

        module ClassMethods
          def disable_logger!
            @logger_disabled = true
          end

          def enable_logger!
            @logger_disabled = false
          end

          def should_log?
            !@logger_disabled
          end
        end

        def self.included(base)
          base.instance_eval do
            include Rdm::Support::Colorize
            extend ClassMethods
          end
        end

        private

        def log(msg)
          puts(msg) if self.class.should_log?
        end

        def warning(msg)
          log brown(msg)
        end

        def info(msg)
          log green(msg)
        end

        def info_created(file)
          info("Generated: #{file}")
        end

        def warning_exists(file)
          warning("File #{file} already exists, skipping...")
        end

        def ensure_file(path_array, content = '')
          filename = File.join(*path_array)
          FileUtils.mkdir_p(File.dirname(filename))
          return warning_exists(filename) if File.exist?(filename)
          File.write(filename, content)
          info_created(filename)
        end

        def copy_template(filepath, target_name = nil)
          from          = filepath
          target_name ||= filepath
          to            = File.join(target_path, target_name)
          return warning_exists(to) if File.exist?(to)
          FileUtils.mkdir_p(File.dirname(to))
          # copy_entry(src, dest, preserve = false, dereference_root = false, remove_destination = false)
          FileUtils.copy_entry(from, to, true, false, true)
          info_created(relative_path(to))
        end

        def template_content(file, locals = {})
          template_path    = templates_path.join(file)
          template_content = File.read(template_path)
          Rdm::Support::Render.render(template_content, locals)
        end

        def relative_path(file)
          file.gsub(current_dir + "/", "")
        end
      end
    end
  end
end
