# frozen_string_literal: true

require "cgi"

module BilingualSite
  NAVIGATION_START = '<ul class="navbar-nav navbar-menu-list flex-nowrap">'
  SEARCH_MARKER = "<!-- Search -->"

  module_function

  def route(site, path)
    baseurl = site.config["baseurl"].to_s.sub(%r{/$}, "")
    "#{baseurl}/#{path.to_s.sub(%r{^/}, '')}"
  end

  def navigation(page)
    alternates = page.data["language_alternates"]
    alternates = {} unless alternates.is_a?(Hash)
    english_url = route(page.site, alternates["en"] || "/")
    chinese_url = route(page.site, alternates["zh-CN"] || alternates["zh"] || "/zh/")
    current_language = page.data["lang"].to_s.downcase.start_with?("zh") ? "zh" : "en"
    english_active = current_language == "en" ? " active-language" : ""
    chinese_active = current_language == "zh" ? " active-language" : ""
    english_current = current_language == "en" ? ' aria-current="page"' : ""
    chinese_current = current_language == "zh" ? ' aria-current="page"' : ""

    <<~HTML
      <li class="nav-item language-switcher" aria-label="Language">
        <a class="nav-link language-switch-link#{english_active}"#{english_current} href="#{CGI.escapeHTML(english_url)}" lang="en" hreflang="en" data-language-switch="en">EN</a>
        <span class="nav-link language-switcher-separator" aria-hidden="true">/</span>
        <a class="nav-link language-switch-link#{chinese_active}"#{chinese_current} href="#{CGI.escapeHTML(chinese_url)}" lang="zh-CN" hreflang="zh-CN" data-language-switch="zh">中文</a>
      </li>
    HTML
  end

  def script(page)
    current_language = page.data["lang"].to_s.downcase.start_with?("zh") ? "zh" : "en"
    auto_redirect = ["/", "/zh/"].include?(page.url) ? "true" : "false"
    english_url = route(page.site, "/")
    chinese_url = route(page.site, "/zh/")

    <<~HTML
      <script src="#{route(page.site, '/assets/js/home-language.js')}" data-current-language="#{current_language}" data-auto-redirect="#{auto_redirect}" data-english-url="#{english_url}" data-chinese-url="#{chinese_url}"></script>
    HTML
  end

  def styles
    <<~HTML
      <style>
        #navbar .language-switcher { display: flex; align-items: center; }
        #navbar .language-switcher .nav-link { padding-inline: 0.2rem; white-space: nowrap; }
        #navbar .language-switcher .active-language { font-weight: 700; }
        #navbar .language-switcher-separator { opacity: 0.55; }
      </style>
    HTML
  end

  def render(page)
    return unless page.output.include?("</head>")

    inject_alternates(page)
    inject_navigation(page)
    page.output.sub!("</head>", "#{styles}  </head>")
    page.output.sub!("</body>", "#{script(page)}  </body>")
  end

  def inject_alternates(page)
    alternates = page.data["language_alternates"]
    return unless alternates.is_a?(Hash)

    site_url = page.site.config["url"].to_s.sub(%r{/$}, "")
    links = alternates.map do |language, path|
      href = "#{site_url}#{route(page.site, path)}"
      %(    <link rel="alternate" hreflang="#{CGI.escapeHTML(language)}" href="#{CGI.escapeHTML(href)}">)
    end.join("\n")
    page.output.sub!("</head>", "#{links}\n  </head>")
  end

  def inject_navigation(page)
    navigation_start = page.output.index(NAVIGATION_START)
    return unless navigation_start

    search_marker = page.output.index(SEARCH_MARKER, navigation_start)
    navigation_end = page.output.index("</ul>", navigation_start)
    insertion_point = search_marker || navigation_end
    page.output.insert(insertion_point, navigation(page)) if insertion_point
  end
end

Jekyll::Hooks.register :pages, :post_render, &BilingualSite.method(:render)
Jekyll::Hooks.register :documents, :post_render, &BilingualSite.method(:render)
