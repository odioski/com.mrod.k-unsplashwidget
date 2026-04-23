#!/usr/bin/env node

const http = require("http");
const https = require("https");
const { URL } = require("url");

const port = Number(process.env.PORT || 8787);
const accessKey = (process.env.UNSPLASH_ACCESS_KEY || "").trim();
const appName = (process.env.UNSPLASH_APP_NAME || "k_splash_backend").trim();

function sendJson(res, statusCode, payload) {
    const body = JSON.stringify(payload);
    res.writeHead(statusCode, {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json; charset=utf-8",
        "Content-Length": Buffer.byteLength(body)
    });
    res.end(body);
}

function requestJson(targetUrl, callback) {
    const request = https.request(targetUrl, {
        headers: {
            "Accept-Version": "v1",
            "Authorization": "Client-ID " + accessKey
        }
    }, function(response) {
        let body = "";

        response.on("data", function(chunk) {
            body += chunk;
        });

        response.on("end", function() {
            callback(null, response.statusCode || 502, body);
        });
    });

    request.on("error", function(error) {
        callback(error);
    });

    request.end();
}

function trackDownload(downloadLocation) {
    if (!downloadLocation) {
        return;
    }

    const request = https.request(downloadLocation, {
        headers: {
            "Accept-Version": "v1",
            "Authorization": "Client-ID " + accessKey
        }
    });

    request.on("error", function() {
        // Tracking is advisory only.
    });

    request.end();
}

function buildRandomPhotoUrl(query) {
    const url = new URL("https://api.unsplash.com/photos/random");

    if (query) {
        url.searchParams.set("query", query);
    }

    url.searchParams.set("orientation", "landscape");
    url.searchParams.set("content_filter", "high");

    return url;
}

const server = http.createServer(function(req, res) {
    if (req.method === "OPTIONS") {
        res.writeHead(204, {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        });
        res.end();
        return;
    }

    if (!accessKey) {
        sendJson(res, 500, {
            errors: ["UNSPLASH_ACCESS_KEY is not configured"]
        });
        return;
    }

    const requestUrl = new URL(req.url, "http://127.0.0.1:" + port);

    if (req.method !== "GET" || requestUrl.pathname !== "/api/random-photo") {
        sendJson(res, 404, {
            errors: ["Not found"]
        });
        return;
    }

    const unsplashUrl = buildRandomPhotoUrl((requestUrl.searchParams.get("query") || "").trim());
    unsplashUrl.searchParams.set("utm_source", appName);
    unsplashUrl.searchParams.set("utm_medium", "referral");

    requestJson(unsplashUrl, function(error, statusCode, body) {
        if (error) {
            sendJson(res, 502, {
                errors: [error.message]
            });
            return;
        }

        if (statusCode !== 200) {
            res.writeHead(statusCode, {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json; charset=utf-8"
            });
            res.end(body);
            return;
        }

        try {
            const photo = JSON.parse(body);
            const resolvedPhoto = Array.isArray(photo) ? photo[0] : photo;

            if (resolvedPhoto && resolvedPhoto.links && resolvedPhoto.links.download_location) {
                trackDownload(resolvedPhoto.links.download_location);
            }

            sendJson(res, 200, resolvedPhoto);
        } catch (parseError) {
            sendJson(res, 502, {
                errors: ["Invalid JSON returned by Unsplash", parseError.message]
            });
        }
    });
});

server.listen(port, function() {
    console.log("K-Splash backend listening on http://0.0.0.0:" + port + "/api/random-photo");
});
