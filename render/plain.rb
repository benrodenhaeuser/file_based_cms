module Redcarpet
  module Render
    class Plain < Base

      def normal_text(text)
        text.strip
      end

      def header(title, level)
        case level
        when 1
          "<p># #{title}</p>"
        end
      end

      def double_emphasis(text)
        "\\fB#{text}\\fP"
      end

      def emphasis(text)
        "\\fI#{text}\\fP"
      end

      def linebreak
        "\n.LP\n"
      end

      def paragraph(text)
        "\n.TP\n#{text}\n"
      end

      def list(content, list_type)
        case list_type
        when :ordered
          "\n\n.nr step 0 1\n#{content}\n"
        when :unordered
          "\n.\n#{content}\n"
        end
      end

      def list_item(content, list_type)
        case list_type
        when :ordered
          ".IP \\n+[step]\n#{content.strip}\n"
        when :unordered
          ".IP \\[bu] 2 \n#{content.strip}\n"
        end
      end
    end
  end
end
