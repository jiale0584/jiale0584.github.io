# frozen_string_literal: true

require "fileutils"
require "json"

Jekyll::Hooks.register :posts, :post_render do |post|
  next unless post.output_ext == ".html"

  language_value = post.data["language"] || post.data["lang"]
  language = ["zh", "zh-CN"].include?(language_value) ? "zh" : "en"
  post.output.sub!(
    '<article class="post-content">',
    %(<article class="post-content" lang="#{language}">)
  )

  stylesheet = "#{post.site.baseurl}/assets/css/article-content.css"
  post.output.sub!(
    "</head>",
    %(<link rel="stylesheet" href="#{stylesheet}">\n</head>)
  )

  script = "#{post.site.baseurl}/assets/js/article-toc.js"
  post.output.sub!(
    "</body>",
    %(<script src="#{script}"></script>\n</body>)
  )
end

Jekyll::Hooks.register :site, :post_write do |site|
  destination = site.in_dest_dir("assets", "al_math", "js", "mathjax-setup.js")
  FileUtils.mkdir_p(File.dirname(destination))
  macros = JSON.generate(site.config.fetch("math_macros", {}))
  File.write(
    destination,
    <<~JAVASCRIPT
      window.MathJax = {
        tex: {
          tags: "ams",
          inlineMath: [["$", "$"], ["\\\\(", "\\\\)"]],
          macros: #{macros},
        },
        options: {
          renderActions: {
            addCss: [200, function () {
              const style = document.createElement("style");
              style.innerHTML = ".mjx-container { color: inherit; }";
              document.head.appendChild(style);
            }, ""],
          },
        },
      };
    JAVASCRIPT
  )
end
