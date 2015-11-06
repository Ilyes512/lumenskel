server {
    listen  80;
    server_name {{ nginx.servername }};

    root {{ nginx.docroot }};
    index index.html index.htm index.php app.php app_dev.php;

    access_log {{ nginx.log_folder }}/access.log;
    error_log  {{ nginx.log_folder }}/error.log;

    charset utf-8;

    location / {
        try_files $uri $uri/ /app.php?$query_string /index.php?$query_string;
    }

    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS off;
        fastcgi_param LARA_ENV {{ nginx.env_name }};
    }

    # Deny .htaccess file access
    location ~ /\.ht {
        deny all;
    }

    client_max_body_size {{ php.max_body_size }};
}
