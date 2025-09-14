# Social Shopping

## Requirements
- Docker Desktop
- Git
- Windows users: run commands in **Git Bash** (or WSL)

## 1) Clone & enter
```bash
git clone https://github.com/dantvi/social-shopping.git
cd social-shopping
```

## 2) Environment
```bash
# create .env if missing and pin project name
cp -n .env.example .env
grep -q '^COMPOSE_PROJECT_NAME=' .env || echo 'COMPOSE_PROJECT_NAME=social-shopping' >> .env
```

## 3) (Optional) Classroom repos
```bash
bash scripts/bootstrap.sh
```

## 4) Start Docker
```bash
docker compose up -d --build
```

## 5) Install WordPress (one command)
```bash
docker compose run --rm wpcli bash -lc '
  [ -d wp-admin ] || wp core download --path=/var/www/html --skip-content;
  wp config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --skip-check --force;
  wp core install --url="http://localhost:8084" --title="FSU24D Social Shopping" --admin_user="daniel" --admin_password="notSecureChangeMe" --admin_email="you@example.com" --skip-email;
  wp plugin install woocommerce --activate;
'
```

## 6) Activate theme & plugin
```bash
docker compose run --rm wpcli bash -lc "
  wp theme activate fsu24d-social-shopping-tema-dantvi;
  wp plugin activate fsu24d-social-shopping-plugin-dantvi;
  wp rewrite flush --hard
"
```

(Optional) Configure GTM  
Go to **Settings → Social Shopping** in WP Admin and enter your GTM container ID  
(see plugin README for full GTM → GA4 wiring instructions).

## 7) Create the frontend page for collections
```bash
docker compose run --rm wpcli bash -lc "
  wp post create --post_type=page --post_title='Create Collection' \
    --post_status=publish --post_content='[ss_create_collection]'
"
```

## 8) Add a few products

Use WooCommerce → Products → Add New (need at least two products to create a collection).

## 9) Configure Stripe (Test Mode)

1. Go to **WooCommerce → Settings → Payments → Stripe**  
2. Click **Manage** and enable **Test mode**  
3. Paste your **Test Publishable key** and **Test Secret key** from the Stripe dashboard  
4. Save changes

Test card for checkout:  
`4242 4242 4242 4242` (any future expiry date, any CVC, any postal code)

When you place a test order, WooCommerce should mark it as **Processing** under **WooCommerce → Orders**.

## Test

When you buy a collection, the collection's creator should automatically receive a unique 10% single-use coupon (see plugin README for details).

> **Note:** Coupon delivery relies on WordPress sending email.  
> In a local dev environment, use a mail catcher (e.g. MailHog) or verify the coupon manually under **WooCommerce → Marketing → Coupons**.

Visit `/create-collection` to submit a collection (need ≥ 2 products).

Visit `/collections` to see the archive.
Try filters/sort/search:

- `?ccat=demo` (category filter by slug)
- `?sort=alpha` (A–Z) / `?sort=newest` (default)
- `?s=kit` (search in titles)

You can also view all collections authored by a specific user:

- `/author/{username}/?post_type=collection`

Open any single collection and click `Add all to cart` → you should be redirected to the cart with all simple, purchasable, in-stock products added. Unavailable/other types are skipped with a notice.

### End-to-End Sanity Check

1. Create a collection with ≥ 2 published products at `/create-collection`
2. Use **Add all to cart** on the single collection page
3. Go through checkout and pay with Stripe test card (`4242 4242 4242 4242`)
4. Verify order appears under **WooCommerce → Orders** with status **Processing**
5. Verify that a reward coupon is issued:
   - Go to **WooCommerce → Marketing → Coupons** and confirm that a new 10% single-use coupon has been created for the collection creator.
   - (Optional) Check the plugin README for full details on coupon behavior and email delivery.

## Open
- Site: http://localhost:8084
- Admin: http://localhost:8084/wp-admin (user: daniel / pass: notSecureChangeMe)
- phpMyAdmin: http://localhost:8085 (user: root / pass: notSecureChangeMe)

## Known Limitations

- Variable, grouped, and external products are skipped by "Add all to cart"
- Only published products are saved to collections (draft/trashed are ignored)
- A collection must always contain at least 2 valid products after validation

## Troubleshooting

### Port in use (8084/8085):
```bash
docker compose down
docker compose up -d --build
```

### Pretty permalinks 404: 
Admin → Settings → Permalinks → choose Post name → Save.

### Parent theme missing:
```bash
docker compose run --rm wpcli bash -lc "wp theme install twentytwentyfive"
```

### Stop everything:
```bash
docker compose down -v
```

## Documentation

**Plugin:** `wp-content/plugins/fsu24d-social-shopping-plugin-dantvi/README.md`  
Covers CPT/taxonomy, admin UI, shortcode, archive URL params (ccat, sort, s), and "Add all to cart" (behavior + hooks).

**Theme:** `wp-content/themes/fsu24d-social-shopping-tema-dantvi/README.md`  
Covers archive filter/sort/search UI and single template notes.

**GTM/GA4:** See plugin README section **"GTM → GA4 wiring"** for triggers, variables, and tag setup.
