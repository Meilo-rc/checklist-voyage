const CACHE_NAME = "checklist-voyage-2.56";
const APP_SHELL = [
  "./",
  "./index.html",
  "./styles.css?v=2.56",
  "./app-config.js?v=2.56",
  "./app.js?v=2.56",
  "./app-sync.js?v=2.56",
  "./app-bootstrap.js?v=2.56",
  "./manifest.json?v=2.56",
  "./icon.svg?v=2.56",
  "./icon-192.png?v=2.56",
  "./icon-512.png",
  "./vacances-famille.svg",
  "./vacances.avif",
  "./category-icons/add.svg",
  "./category-icons/add-invoice-stroke-rounded.svg",
  "./category-icons/airpod.svg",
  "./category-icons/baby.svg",
  "./category-icons/bathtub.svg",
  "./category-icons/beach.svg",
  "./category-icons/bed.svg",
  "./category-icons/boat.svg",
  "./category-icons/boy.svg",
  "./category-icons/bus.svg",
  "./category-icons/calendar.svg",
  "./category-icons/camera.svg",
  "./category-icons/car.svg",
  "./category-icons/categorie.svg",
  "./category-icons/child.svg",
  "./category-icons/clothes.svg",
  "./category-icons/cocktail.svg",
  "./category-icons/diaper.svg",
  "./category-icons/document.svg",
  "./category-icons/dress.svg",
  "./category-icons/eyeglass.svg",
  "./category-icons/female.svg",
  "./category-icons/first-aid.svg",
  "./category-icons/gamepad.svg",
  "./category-icons/games.svg",
  "./category-icons/hiking.svg",
  "./category-icons/home.svg",
  "./category-icons/hotel.svg",
  "./category-icons/key.svg",
  "./category-icons/liste.svg",
  "./category-icons/luggage.svg",
  "./category-icons/male.svg",
  "./category-icons/manager.svg",
  "./category-icons/money.svg",
  "./category-icons/music.svg",
  "./category-icons/passport.svg",
  "./category-icons/plane.svg",
  "./category-icons/plug.svg",
  "./category-icons/restaurant.svg",
  "./category-icons/setting.svg",
  "./category-icons/shopping.svg",
  "./category-icons/ski.svg",
  "./category-icons/snow.svg",
  "./category-icons/sport.svg",
  "./category-icons/stretching.svg",
  "./category-icons/suit.svg",
  "./category-icons/suitcase.svg",
  "./category-icons/sun.svg",
  "./category-icons/swimming.svg",
  "./category-icons/tag.svg",
  "./category-icons/tent.svg",
  "./category-icons/toiletries.svg",
  "./category-icons/tools.svg",
  "./category-icons/train.svg",
  "./category-icons/umbrella.svg",
  "./category-icons/video.svg",
  "./category-icons/walking.svg",
  "./category-icons/water.svg",
  "./category-icons/workout.svg",
  "./category-icons/writing.svg"
];

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
    ))
  );
  self.clients.claim();
});

self.addEventListener("fetch", event => {
  if (event.request.method !== "GET") return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) {
    event.respondWith(fetch(event.request));
    return;
  }
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request).catch(() => caches.match("./index.html"))
    );
    return;
  }
  event.respondWith(
    fetch(event.request)
      .then(response => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request).then(cached => cached || caches.match("./index.html")))
  );
});

