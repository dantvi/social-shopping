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

## 7) Create the frontend page for collections
```bash
docker compose run --rm wpcli bash -lc "
  wp post create --post_type=page --post_title='Create Collection' \
    --post_status=publish --post_content='[ss_create_collection]'
"
```

## 8) Add a few products

Use WooCommerce → Products → Add New (need at least two products to create a collection).

## Test

Visit `/create-collection` to submit a collection (need ≥ 2 products).

Visit `/collections` to see the archive.
Try filters/sort/search:

- `?ccat=demo` (category filter by slug)
- `?sort=alpha` (A–Z) / `?sort=newest` (default)
- `?s=kit` (search in titles)

Open any single collection and click `Add all to cart` → you should be redirected to the cart with all simple, purchasable, in-stock products added. Unavailable/other types are skipped with a notice.

## Open
- Site: http://localhost:8084
- Admin: http://localhost:8084/wp-admin (user: daniel / pass: notSecureChangeMe)
- phpMyAdmin: http://localhost:8085 (user: root / pass: notSecureChangeMe)

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
