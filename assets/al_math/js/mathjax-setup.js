window.MathJax = {
  tex: {
    tags: "ams",
    inlineMath: [["$", "$"], ["\\(", "\\)"]],
    macros: {},
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
