window.addEventListener("load", () => {
  const tocSidebar = document.querySelector("#toc-sidebar");
  const content = document.querySelector("#markdown-content");
  const headings = content?.querySelectorAll("h1, h2, h3, h4, h5, h6");

  if (!tocSidebar || !content || !headings?.length || !window.tocbot) return;

  const explicitDepth = Number.parseInt(tocSidebar.dataset.tocCollapseDepth || "", 10);
  const collapseMode = (tocSidebar.dataset.tocCollapse || "expanded").toLowerCase();
  const collapseDepth = Number.isNaN(explicitDepth) ? (["auto", "scroll", "true", "collapsed"].includes(collapseMode) ? 3 : 6) : explicitDepth;

  window.tocbot.destroy();
  window.tocbot.init({
    tocSelector: "#toc-sidebar",
    contentSelector: "#markdown-content",
    headingSelector: "h1, h2, h3, h4, h5, h6",
    ignoreSelector: "[data-toc-skip]",
    hasInnerContainers: true,
    collapseDepth,
    orderedList: false,
    activeLinkClass: "is-active-link",
    scrollSmooth: true,
    scrollSmoothOffset: -80,
    headingsOffset: 80,
  });
});
