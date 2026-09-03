(function () {
  const script = document.currentScript;
  const preferenceKey = "home-language";
  const currentLanguage = script.dataset.currentLanguage;
  const autoRedirect = script.dataset.autoRedirect === "true";
  const urls = {
    en: script.dataset.englishUrl,
    zh: script.dataset.chineseUrl,
  };

  let preferredLanguage;
  try {
    preferredLanguage = window.localStorage.getItem(preferenceKey);
  } catch (_) {
    preferredLanguage = null;
  }

  const browserLanguage = (navigator.languages && navigator.languages[0]) || navigator.language || "en";
  const detectedLanguage = /^zh(?:-|$)/i.test(browserLanguage) ? "zh" : "en";
  const hasPreference = preferredLanguage === "en" || preferredLanguage === "zh";
  const targetLanguage = hasPreference ? preferredLanguage : currentLanguage === "en" ? detectedLanguage : currentLanguage;

  if (autoRedirect && targetLanguage !== currentLanguage) {
    const currentUrl = new URL(window.location.href);
    const targetUrl = new URL(urls[targetLanguage], window.location.origin);
    targetUrl.search = currentUrl.search;
    targetUrl.hash = currentUrl.hash;
    window.location.replace(targetUrl.href);
    return;
  }

  document.addEventListener("click", function (event) {
    const link = event.target.closest("[data-language-switch]");
    if (!link) return;

    try {
      window.localStorage.setItem(preferenceKey, link.dataset.languageSwitch);
    } catch (_) {
      // The link still works when storage is unavailable.
    }
  });
})();
