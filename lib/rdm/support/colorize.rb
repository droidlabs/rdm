module Rdm
  module Support
    # http://stackoverflow.com/questions/1489183/colorized-ruby-output
    module Colorize
      class << self
        def black(msg);          "\e[30m#{msg}\e[0m"       end
        def red(msg);            "\e[31m#{msg}\e[0m"       end
        def green(msg);          "\e[32m#{msg}\e[0m"       end
        def brown(msg);          "\e[33m#{msg}\e[0m"       end
        def blue(msg);           "\e[34m#{msg}\e[0m"       end
        def magenta(msg);        "\e[35m#{msg}\e[0m"       end
        def cyan(msg);           "\e[36m#{msg}\e[0m"       end
        def gray(msg);           "\e[37m#{msg}\e[0m"       end

        def bg_black(msg);       "\e[40m#{msg}\e[0m"       end
        def bg_red(msg);         "\e[41m#{msg}\e[0m"       end
        def bg_green(msg);       "\e[42m#{msg}\e[0m"       end
        def bg_brown(msg);       "\e[43m#{msg}\e[0m"       end
        def bg_blue(msg);        "\e[44m#{msg}\e[0m"       end
        def bg_magenta(msg);     "\e[45m#{msg}\e[0m"       end
        def bg_cyan(msg);        "\e[46m#{msg}\e[0m"       end
        def bg_gray(msg);        "\e[47m#{msg}\e[0m"       end

        def bold(msg);           "\e[1m#{msg}\e[22m"       end
        def italic(msg);         "\e[3m#{msg}\e[23m"       end
        def underline(msg);      "\e[4m#{msg}\e[24m"       end
        def blink(msg);          "\e[5m#{msg}\e[25m"       end
        def reverse_color(msg);  "\e[7m#{msg}\e[27m"       end

        def no_colors(msg);       msg.gsub(/\e\[\d+m/, "") end
      end
    end
  end
end
