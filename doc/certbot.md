## Commands

```
# Generate a wildcard certificate for sub domains and main domain
sudo certbot certonly --manual -d "*.example.com" -d example.com --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory

# Generate a wildcare certificate only for a sub domain
sudo certbot certonly --manual -d foo.example.com --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```
