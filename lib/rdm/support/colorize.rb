module Rdm
  module Support
    # http://stackoverflow.com/questions/1489183/colorized-ruby-output
    module Colorize
      module ClassMethods
        def black(msg)
          color_wrap(msg, 30)
        end

        def red(msg)
          color_wrap(msg, 31)
        end

        def green(msg)
          color_wrap(msg, 32)
        end

        def brown(msg)
          color_wrap(msg, 33)
        end

        def blue(msg)
          color_wrap(msg, 34)
        end

        def magenta(msg)
          color_wrap(msg, 35)
        end

        def cyan(msg)
          color_wrap(msg, 36)
        end

        def gray(msg)
          color_wrap(msg, 37)
        end

        def bg_black(msg)
          color_wrap(msg, 40)
        end

        def bg_red(msg)
          color_wrap(msg, 41)
        end

        def bg_green(msg)
          color_wrap(msg, 42)
        end

        def bg_brown(msg)
          color_wrap(msg, 43)
        end

        def bg_blue(msg)
          color_wrap(msg, 44)
        end

        def bg_magenta(msg)
          color_wrap(msg, 45)
        end

        def bg_cyan(msg)
          color_wrap(msg, 46)
        end

        def bg_gray(msg)
          color_wrap(msg, 47)
        end

        def bold(msg)
          color_wrap(msg, 1, 22)
        end

        def italic(msg)
          color_wrap(msg, 3, 23)
        end

        def underline(msg)
          color_wrap(msg, 4, 24)
        end

        def blink(msg)
          color_wrap(msg, 5, 25)
        end

        def reverse_color(msg)
          color_wrap(msg, 7, 27)
        end

        def color_wrap(msg, from, to = 0)
          "\e[#{from}m#{msg}\e[#{to}m"
        end

        def no_colors(msg)
          msg.gsub(/\e\[\d+m/, '')
        end
      end

      extend ClassMethods

      def self.included(base)
        base.include(ClassMethods)
      end
    end
  end
end
