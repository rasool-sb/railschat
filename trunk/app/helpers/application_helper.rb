module ApplicationHelper
  def css_class_name (message)
    return "comment" if message.system?
    return "offreco" if message.offreco?
    return "normal"
  end

  def convert_syntax(text)
    src = h(text)
    "<pre class=\"prettyprint\">#{src}</pre>"
  end

  def auto_link2(text, link = :all, href_options = {}, &block)
    return '' if text.blank?
    case link
      when :all             then auto_link_urls2(auto_link_email_addresses2(text, &block), href_options, &block)
      when :email_addresses then auto_link_email_addresses(text, &block)
      when :urls            then auto_link_urls2(text, href_options, &block)
    end
  end
  
  def auto_img(text, href_options = {})
    return '' if text.blank?
    extra_options = tag_options(href_options.stringify_keys) || ""
    text.gsub(AUTO_IMG_RE) do
      a, b, c, d = $1, $2, $3, $5
      %(#{a}<img src="#{b=="www."?"http://www.":b}#{c}"#{extra_options} />#{d})
    end
  end
  
  def auto_link_and_img(text, link = :all, href_options = {})
    auto_img(auto_link2(h(text), link, href_options))
  end
  
  def simple_format2(text, link = :all, href_options = {})
    simple_format(auto_link_and_img(text, link, href_options))
  end
  
  private
  AUTO_LINK_RE_LOCAL = /
                        (                       # leading text
                          <\w+.*?>|             #   leading HTML tag, or
                          [^=!:'"\/]|           #   leading punctuation, or
                          ^                     #   beginning of line
                        )?
                        (
                          (?:http[s]?:\/\/)|    # protocol spec, or
                          (?:www\.)             # www.*
                        )
                        (
                          ([\w]+:?[=?&\/.-]?)*    # url segment
                           \w+[\/]?(?:[\*\?]?[^#\s]*)?  # url tail
                          (?:\#\w*)?            # trailing anchor
                        )
                        ([[:punct:]]+|\s+|<|$)    # trailing text

                       /nx unless const_defined?(:AUTO_LINK_RE_LOCAL)

  def auto_link_urls2(text, href_options = {})
    extra_options = tag_options(href_options.stringify_keys) || ""
    text.gsub(AUTO_LINK_RE_LOCAL) do
      all, a, b, c, d = $&, $1, $2, $3, $5
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        text = b + c
        text = yield(text) if block_given?
        %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{extra_options}>#{text}</a>#{d})
      end
    end
  end

  def auto_link_email_addresses2(text)
    text.gsub(/([\w\.!#\$%\-+.]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+)/) do
      text = $1
      text = yield(text) if block_given?
      %{<a href="mailto:#{$1}">#{text}</a>}
    end
  end
  
  AUTO_IMG_RE = %r{
                    (                        # leading text
                      <\w+.*?>|              # leading HTML tag, or
                      [^=!:'"/]|             # leading punctuation, or 
                      ^                      # beginning of line
                    )
                    (
                      (?:https?://)|         # protocol spec, or
                      (?:www\.)              # www.*
                    ) 
                    (
                      [-\w]+                 # subdomain or domain
                      (?:\.[-\w]+)*          # remaining subdomains or domain
                      (?::\d+)?              # port
                      (?:/(?:[~\w%.;-]+)?)*  # path
                      (?:\.(jpe?g|gif|png))  # extension
                      (?:\?[\w%&=.;-]+)?     # query string
                    )
                    ([[:punct:]]|\s|<|$)     # trailing text
                  }x unless const_defined?(:AUTO_IMG_RE)
end
