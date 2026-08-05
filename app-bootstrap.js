document.addEventListener("focusout", () => {
  setTimeout(flushPendingRemoteVoyage, 120);
});

document.addEventListener("click", event => {
  if (!event.target.closest(".page-add-menu") && !event.target.closest(".page-add-button")) {
    closeVoyageAddMenu();
  }
  const menu = event.target.closest(".voyage-menu");
  if (!menu) {
    closeOpenMenus();
    return;
  }
  closeOpenMenus(menu);
});

window.addEventListener("online", () => {
  syncAllVoyages({ immediate: true });
  syncAllQuickLists({ immediate: true });
});

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./service-worker.js").catch(error => {
      console.warn("Service worker indisponible", error);
    });
  });
}

loadLocal();
dedupeQuickLists();
saveLocal();
render();
handleJoinLink();
loadSharedSettings();
subscribeToCurrentVoyage();






