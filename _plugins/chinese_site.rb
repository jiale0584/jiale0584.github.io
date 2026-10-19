# frozen_string_literal: true

require "cgi"

# Keep historical Chinese home/about URLs as aliases of the single-language pages.
# Sharing source at generation time prevents the compatibility pages from drifting.
module ChineseSite
  class LegacyPages < Jekyll::Generator
    priority :low

    def generate(site)
      { "/zh/" => "/", "/zh/about/" => "/about/" }.each do |old_url, current_url|
        original = site.pages.find { |page| page.url == current_url }
        legacy = site.pages.find { |page| page.url == old_url }
        next unless original && legacy

        legacy.content = original.content
        legacy.data["canonical_path"] = current_url
      end
    end
  end

  module_function

  def route(site, path)
    "#{site.config['baseurl'].to_s.sub(%r{/$}, '')}#{path}"
  end

  def render(page)
    return unless page.output.include?("</head>")

    page.output.sub!(%r{(<html\b[^>]*\blang=")[^"]*"}, '\1zh-CN"')
    if (canonical = page.data["canonical_path"])
      url = CGI.escapeHTML("#{page.site.config['url'].to_s.sub(%r{/$}, '')}#{route(page.site, canonical)}")
      page.output.sub!(%r{(<link\b[^>]*rel="canonical"[^>]*href=")[^"]*"}, "\\1#{url}\"")
    end

    if page.url == "/"
      navbar = page.output.index('<nav id="navbar"')
      container = page.output.index('<div class="container">', navbar) if navbar
      if container
        title = CGI.escapeHTML(page.site.config["title"].to_s)
        brand = %(<a class="navbar-brand title font-weight-lighter" href="#{route(page.site, '/')}">#{title}</a>)
        page.output.insert(page.output.index(">", container) + 1, brand)
      end
    end

    page.output.gsub!('content="jiale "', 'content="jiale"')
    page.output.gsub!(%r{© Copyright (\d{4})\s+jiale\s+\.\s*}, '© Copyright \1 jiale.')
  end
end

Jekyll::Hooks.register :pages, :post_render, &ChineseSite.method(:render)
Jekyll::Hooks.register :documents, :post_render, &ChineseSite.method(:render)
