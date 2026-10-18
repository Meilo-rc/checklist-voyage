/// <reference path="../pb_data/types.d.ts" />

routerAdd("GET", "/.well-known/assetlinks.json", (context) => {
  return context.json(200, [
    {
      relation: ["delegate_permission/common.handle_all_urls"],
      target: {
        namespace: "android_app",
        package_name: "fr.checklistvoyage.app",
        sha256_cert_fingerprints: [
          "73:ED:A5:1F:F7:11:1F:BB:2D:D7:0A:E0:0D:B7:EB:36:32:24:80:AA:E1:B7:1A:56:09:1D:A2:A8:1D:D8:5D:48",
        ],
      },
    },
  ]);
});

routerAdd("GET", "/join", (context) => {
  const linkTypes = {
    trip: "un voyage",
    "quick-list": "une liste rapide",
  };
  const shareCode = /^[A-Z2-9]{8}$/;
  const page = (title, message, content) => {
    return '<!doctype html><html lang="fr"><head><meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width,initial-scale=1">' +
      '<meta name="robots" content="noindex">' +
      '<title>' + title + '</title><style>' +
      'body{margin:0;background:#f7f7f8;color:#202124;font:16px system-ui,sans-serif}' +
      'main{max-width:32rem;margin:12vh auto;padding:2rem;text-align:center}' +
      'h1{color:#0d4f9c;font-size:1.7rem}.code{font-size:1.15rem}' +
      '.button{display:inline-block;margin-top:1rem;padding:.8rem 1.1rem;border-radius:.7rem;' +
      'background:#0d66d0;color:white;text-decoration:none;font-weight:700}' +
      '</style></head><body><main><h1>' + title + '</h1><p>' + message +
      '</p>' + content + '</main></body></html>';
  };
  const type = String(context.queryParam("type") || "");
  const code = String(context.queryParam("code") || "").trim().toUpperCase();
  const objectLabel = linkTypes[type];
  if (!objectLabel || !shareCode.test(code)) {
    return context.html(400, page(
      "Lien invalide",
      "Ce lien de partage Checklist Voyage est incomplet ou invalide.",
      "",
    ));
  }

  const appUrl = "checklistvoyage://join?type=" + encodeURIComponent(type) +
    "&code=" + encodeURIComponent(code);
  return context.html(200, page(
    "Checklist Voyage",
    "Ce lien permet de rejoindre " + objectLabel + " dans Checklist Voyage.",
    '<p class="code">Code : <strong>' + code + '</strong></p>' +
      '<p><a class="button" href="' + appUrl + '">Ouvrir Checklist Voyage</a></p>',
  ));
});
