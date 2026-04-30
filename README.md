# TheJonathanGuy.com — static bio

Personal site for Brandon B. Jonathan Guy. Plain HTML/CSS, no build step. Ready for Cloudflare Pages.

## Files

```
/
├── index.html       Home — bio + links to companies
├── about.html       Longer personal bio + career sketch
├── contact.html     Email / phone / LinkedIn / company links
├── 404.html
├── style.css
├── favicon.svg
├── robots.txt
├── sitemap.xml
├── llms.txt         Short LLM index
├── llms-full.txt    Long LLM index
├── _redirects       Cloudflare Pages redirect rules
└── _headers         Cloudflare Pages cache + security headers
```

## Deploy on Cloudflare Pages

1. Push this folder to a new GitHub repo (e.g. `johnnyguy9/thejonathanguy-site`).
2. In Cloudflare Pages, "Create a project" → "Connect to Git" → pick the repo.
3. Build settings: **Framework preset: None**, **Build command: (blank)**, **Build output directory: `/`**.
4. Deploy. Add custom domain `thejonathanguy.com` after the first build succeeds.

## To replace the photo placeholder

Drop a JPG named `hero.jpg` (1600×900) into the repo root and replace the `<div class="img-placeholder">` block in `index.html` with:

```html
<img src="/hero.jpg" alt="Jonathan Guy in Canyon Lake, Texas" width="1600" height="900" loading="lazy" />
```

## To edit copy

Just edit the relevant `.html` file. Push to GitHub. Cloudflare Pages auto-rebuilds.
