function main() {
  "use strict";

  window.addEventListener("load", function() {
    var allLinks = document.querySelectorAll("a");
    openInNewTab(allLinks);

    var mutationObserver = new MutationObserver(function() {
      allLinks = document.querySelectorAll("a");
      openInNewTab(allLinks);
    });

    var html = document.querySelector("html");
    mutationObserver.observe(html, { childList: true, subtree: true });
  });

  function openInNewTab(links) {
    for (var i = 0; i < links.length; i++) {
      var a = links[i];
      if (a.hostname !== location.hostname) {
        a.rel = "noopener noreferrer";
        a.target = "_blank";
      }
    }
  }
}

main();
