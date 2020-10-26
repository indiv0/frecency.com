+++
title = "New Website"
date = 2020-05-30
+++

I've decided to setup a new personal website, after leaving my previous one
unmaintained for a few years.

For now, the website will be set up with a bare minimum of effort so
that I can focus on writing and other projects.

The website will be a static website hosted in an S3 bucket.

I'll also set up email for the web site.

## Email

I already had a Fastmail account (an amazing service, by the way), but I wanted
to hook up my new domain to it to receive email addressed to that domain.

First, I went to Cloudflare where I added my website (`frecency.dev`) to my list
of domains. I had to remove all the existing DNS records that Cloudflare tried
to port over because they pointed at my registrar's parking domain and
placeholder MX records.

Per Cloudflare's instructions, I configured to domain via my registrar's
settings page to point at Cloudflare's
nameservers:

- `brad.ns.cloudflare.com`
- `olga.ns.cloudflare.com`

On Cloudflare, I configured the domain as follows:
1. changed the encryption mode to `Flexible`, because I'd be hosting the
   website on S3, which doesn't secure the endpoint with TLS;
2. set `Always Use HTTPS` to `On` (under `SSL/TLS > Edge Certificates`);
3. set `Minimum TLS Version` to `TLS 1.2` (under `SSL/TLS > Edge Certificates`);
4. choose `Enable HSTS` (under `SSL/TLS > Edge Certificates`), with `Max Age
   Header (max-age)` set to `12 months`, `Apply HSTS policy to subdomains` set
   to `On`, and `No-Sniff Header` set to `On`.
5. set `Auto Minify` to enabled for JS/CSS/HTML (under `Speed > Optimization`);
6. set `HTTP/3 (with QUIC)` to `On` (under `Network`);
7. set `0-RTT Connection Resumption` to `On` (under `Network`);
8. set `WebSockets` to `Off` (under `Network`);

Then, I went to Fastmail to configure the domain:
1. went to the `Settings` page of my Fastmail account;
2. went to the `Domains` section;
3. entered my domain (`frecency.dev`);
4. chose `Yes` when asked <q>Do you own frecency.dev?</q>;
5. chose `Express setup` with my email username as `molly`, and configured all
   other mail sent to that domain to be `sent to me`.

To finalize the configuration, I added the following MX records in Cloudflare:

| Name | Mail server                    | Priority |
| ---- | ------------------------------ | -------- |
| @    | in1-smtp.messagingengine.com   | 10       |
| @    | in2-smtp.messagingengine.com   | 20       |

Then I added the following DKIM records to sign the domain (with `Proxy status`
set of `DNS only`):

| Type  | Name             | Target                                        |
| ----- | ---------------- | --------------------------------------------- |
| CNAME | `fm1._domainkey` | `fm1.frecency.dev.dkim.fmhosted.com`          |
| CNAME | `fm2._domainkey` | `fm2.frecency.dev.dkim.fmhosted.com`          |
| CNAME | `fm3._domainkey` | `fm3.frecency.dev.dkim.fmhosted.com`          |

I also added one TXT record to configure SPF:

| Type  | Name             | Content                                       |
| ----- | ---------------- | --------------------------------------------- |
| TXT   | `@`              | `v=spf1 include:spf.messagingengine.com ?all` |

Once Fastmail reported that the MX, DKIM, and SPF were configured correctly, I
sent myself a test email, which arrived successfully.

## S3 Static Website

First, I went to the S3 page of my AWS console, and chose to create a new bucket
with the default settings except the following:

- Bucket name: `blog.frecency.dev`
- Region: `US East (Ohio)`

I then selected the newly created bucket, went to `Properties`, selected `Static
website hosting`, and chose `Use this bucket to host a website`. I selected
`index.html` as the `Index document` and chose `Save`.

Next, I needed to make the bucket publically accessible. To do so, I had to
select the bucket and go to `Permissions`, choose `Edit`, unselect `Block all
public access`, choose `Save`, type `Confirm`, and choose `Confirm`.

Then, I had to go to `Bucket Policy`, and add the following policy to allow
public access to every object in the bucket:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::blog.frecency.dev/*"
            ]
        }
    ]
}
```

To ensure that access to the website worked, I created an example `index.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>frecency.dev</title>
</head>
<body>
  <p>Hello, world!</p>
</body>
</html>
```

Then I uploaded my website to the bucket with the AWS cli (`aws-cli` package on
Arch Linux):

```sh
$ aws cp index.html s3://blog.frecency.dev/index.html
```

Visiting
`http://blog.frecency.dev.s3-website.us-east-2.amazonaws.com/index.html`, I
could see my index page, so all that was left was to configure Cloudflare to
point at the S3 bucket.

## Cloudflare

In Cloudflare, I added the following DNS records:

| Type  | Name | Target                                               | Proxy status |
| ----- | ---- | ---------------------------------------------------- | ------------ |
| CNAME | @    | blog.frecency.dev.s3-website.us-east-2.amazonaws.com | Proxied      |
| CNAME | www  | blog.frecency.dev.s3-website.us-east-2.amazonaws.com | Proxied      |
| CNAME | blog | blog.frecency.dev.s3-website.us-east-2.amazonaws.com | Proxied      |

I also wanted frecency.dev and www.frecency.dev to redirect to
`blog.frecency.dev` so under `Page Rules` I added the following two rules:

| Match URL          | Rule           | Status Code              | Destination URL                |
| ------------------ | -------------- | ------------------------ | ------------------------------ |
| frecency.dev/*     | Forwarding URL | 301 - Permanent Redirect | `https://blog.frecency.dev/$1` |
| www.frecency.dev/* | Forwarding URL | 301 - Permanent Redirect | `https://blog.frecency.dev/$1` |

With the above rules in place, all of the following URLs now redirect to
[https://blog.frecency.dev](https://blog.frecency.dev):

- http://frecency.dev
- https://frecency.dev
- http://www.frecency.dev
- https://www.frecency.dev
- http://blog.frecency.dev

Because Cloudflare doesn't cache HTML pages by default, an extra request is made
to S3 on every pageview. To avoid this, I added one last `Page Rule`:

| Match URL           | Rule           | Level                    |
| ------------------- | -------------- | ------------------------ |
| blog.frecency.dev/* | Cache Level    | Cache Everything         |

To enhance security on the website, I setup a Cloudflare Worker to rewrite
security headers on every HTML response:
1. Go to `Workers` in Cloudflare.
2. Enter a domain for your Worker to live on (I chose `frecency.workers.dev`).
3. Select your Workers plan (I went with the `Free` tier).
4. Choose `Create a Worker`.

Enter the code for a worker which rewrites headers on responses with
`Content-Type: text/html`:

```js
const securityHeaders = {
  "content-security-policy": "default-src 'none'",
  "feature-policy": "accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'none'; background-fetch 'none'; background-sync 'none'; battery 'none'; bluetooth 'none'; camera 'none'; clipboard 'none'; device-info 'none'; display-capture 'none'; document-domain 'none'; encrypted-media 'none'; execution-while-not-rendered 'none'; execution-while-out-of-viewport 'none'; fullscreen 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; midi 'none'; navigation-override 'none'; nfc 'none'; notifications 'none'; payment 'none'; persistent-storage 'none'; picture-in-picture 'none'; publickey-credentials-get 'none'; push 'none'; speaker 'none'; sync-xhr 'none'; usb 'none'; wake-lock 'none'; xr-spatial-tracking 'none'",
  "referrer-policy": "no-referrer",
  "x-content-type-options": "nosniff",
  "x-frame-options": "DENY",
}

const removeHeaders = [
  "server",
  "x-amz-id-2",
  "x-amz-request-id"
]

addEventListener('fetch', event => {
  event.respondWith(addHeaders(event.request))
})

/**
 * Fetch and add security headers for a given request object.
 * @param {Request} request
 */
async function addHeaders(request) {
  console.log('Got request', request)
  const response = await fetch(request)
  console.log('Got response', response)

  if (response.headers.has("Content-Type") && !response.headers.get("Content-Type").includes("text/html")) {
    console.log('Returning response', response)
    return response
  }

  let newHeaders = new Headers(response.headers)

  Object.keys(securityHeaders).map(function(name, index) {
    console.log('Setting header', name, securityHeaders[name])
    newHeaders.set(name, securityHeaders[name]);
  })

  removeHeaders.forEach(function(name) {
    console.log('Deleting header', name, newHeaders[name])
    newHeaders.delete(name)
  })

  const newResponse = new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: newHeaders,
  })
  console.log('Returning response', response)
  return newResponse
}
```

After defining the Worker, choose `Save and Deploy` to deploy the Worker to
Cloudflare's network. I named my worker `security-headers`.

Then, under the `Workers` page for your domain add the following route:

| Route              | Worker           |
| ------------------ | ---------------- |
| `*.frecency.dev/*` | security-headers |

For further security, you can limit the `Bucket Policy` for the S3 bucket to
only allow access from [Cloudflare servers](https://www.cloudflare.com/ips/).
This should ensure that all traffic MUST route through Cloudflare's CDN:

```js
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::blog.frecency.dev/*"
            ],
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "173.245.48.0/20",
                        "103.21.244.0/22",
                        "103.22.200.0/22",
                        "103.31.4.0/22",
                        "141.101.64.0/18",
                        "108.162.192.0/18",
                        "190.93.240.0/20",
                        "188.114.96.0/20",
                        "197.234.240.0/22",
                        "198.41.128.0/17",
                        "162.158.0.0/15",
                        "104.16.0.0/12",
                        "172.64.0.0/13",
                        "131.0.72.0/22",
                        "2400:cb00::/32",
                        "2606:4700::/32",
                        "2803:f800::/32",
                        "2405:b500::/32",
                        "2405:8100::/32",
                        "2a06:98c0::/29",
                        "2c0f:f248::/32"
                    ]
                }
            }
        }
    ]
}
```

## Static Website Generation

Now that I had a platform for hosting a static website, I had to create one. I
wanted to be able to render Markdown to HTML and serve those files from S3, so I
needed a static website generator. I decided to use
[Zola](https://www.getzola.org), which is available as `zola-bin` via the AUR on
Arch Linux.

Having installed Zola, I initialized the directory structure with `zola init
site`. I chose to enable syntax highlighting and search indexing, but disabled
Sass compilation. Then, from the `site` directory I built a local preview of the
website:

```sh
$ zola serve
```

With the website available at `http://127.0.0.1:1111`, I could make
modifications to the site, re-build it, and rapidly iterate.

I added `templates/base.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>frecency</title>
</head>
<body>
  {% block content %}{% endblock %}
</body>
</html>
```

And `templates/index.html`:

```html
{% extends "base.html" %}

{% block content %}
<p>Hello, world!</p>
{% endblock content %}
```

This was sufficient to get an empty webpage to render.
