# lwsrbrts modernised version README
This is my modernised version of a wonderful piece of work done by [EvilVir](https://github.com/EvilVir/) for nginx and webdav with his [Nginx-Autoindex](https://github.com/EvilVir/Nginx-Autoindex)

I've added some of the features he was going to add but seemingly didn't get to, including:
- Delete (Files & Folders)
- Move (Files & Folders)
- Rename (Files & Folder)
- Copy (Files)
- New Folder


To utilise these features, you'll need to enable the supported WebDAV methods with this modification to the appropriate `default.conf` file. There's a larger example of where this goes below!

```
dav_methods PUT DELETE MKCOL COPY MOVE;
```

![](https://github.com/lwsrbrts/Nginx-Autoindex/raw/master/p3.jpg)

While doing so, I've also added nicer looking modal boxes instead of using confirm and prompt JS functions. This is provided by using SweetAlert 2.1. Note that even though the solution is described as having no dependencies, it does rely on fontawesome for the icons and (now at least) SweetAlert.

![](https://github.com/lwsrbrts/Nginx-Autoindex/raw/master/p4.jpg)

I've also tidied up a few bugs relating to how folder links worked in breadcrumbs, previously relying on redirects which isn't something that reverse-proxied nginx servers handle well, often resulting in mixed content warnings and the need to turn absolute redirects in nginx off with:

```
absolute_redirect off;
```
For what it's worth, this was the config I added to my nginx file for an unmodified nginx container. The container uses volume mounts to pass through the nginx `default.conf` and `autoindex.xslt` from the host - as well as `autoindex.xslt` of course

```
location /downloads {
    alias /mnt/downloads;
    absolute_redirect off; # required to prevent 301 redirects to absolute urls that set http
    try_files $uri $uri/ =404;

    location ~* . {
        expires off;
        log_not_found on;
    }

    autoindex on;
    autoindex_format xml;
    xslt_stylesheet /opt/autoindex.xslt;
    autoindex_exact_size off;
    autoindex_localtime off;
    charset utf-8;

    client_body_temp_path /tmp/;
    dav_methods PUT DELETE MKCOL COPY MOVE;
    add_header X-Options "WebDav";
    create_full_put_path on;
    dav_access user:rw group:rw all:r;
    client_max_body_size 1000M;

    access_log /var/log/nginx/webdav_access.log;
}
```

Note that I did say this was using an unmodified nginx container (literally `nginx:latest`) but volume mounting `nginx.conf`, `default.conf` and, obviously, `autoindex.xslt` files to it.

The only modification I added to `nginx.conf` was to add this line to enable the XSLT module:

```
load_module modules/ngx_http_xslt_filter_module.so;
```

In terms of how this works with a container, clearly the container needs to be able to access the locations defined in the `default.conf` as the nginx user with rights to do the actions you expect WebDAV to do. To allow this, you would need to create folders _on the host_ which you will pass through to the container as volume mounts. These folders will need to be `chown`ed _on the host_ to the ID of the user in the container, which is `101`.

If you are using a remote file share, such as an SMB share, you can create a docker volume which defines the UID and GID of the nginx user (101) as part of the volume's creation. For example:

```
docker volume create --driver local --opt type=cifs --opt device=//<server>/<share> --opt o='username=<theuser>,password=<thepassword>,vers=3.0,uid=101,gid=101,dir_mode=0775,file_mode=0775' downloads
```

## ⚠️⚠️ Warning ⚠️⚠️
I modified the XSLT code to stop the browser downloading any file _name_ that is clicked. This wasn't a feature I wanted on my implementation. There is a download button instead but this won't show if your location doesn't support WebDAV. You'll need to right-click, Save As... instead.

# End lwsrbrts modernised version README...

# Nginx Autoindex
HTML5 replacement for default Nginx Autoindex directory browser. Zero dependencies other then few standard Nginx modules, no backend scripts nor apps. Supports file uploading via WebDav and HTML5 + AJAX drag and drop!

**Modern, clean look with breadcrumbs.**

![](https://github.com/lwsrbrts/Nginx-Autoindex/raw/master/p1.jpg)

**Upload multiple files without any backend, just WebDav & AJAX.**

![pic2](https://github.com/EvilVir/Nginx-Autoindex/raw/master/p2.jpg)

## Required Nginx modules
1. Ensure that you have [ngx_http_xslt_module](http://nginx.org/en/docs/http/ngx_http_xslt_module.html) (it can be also called ngx_http_xslt_filter_module, that's ok).
1. If you want to use upload functionality, you'll also need [ngx_http_dav_module](https://nginx.org/en/docs/http/ngx_http_dav_module.html).

Both are included in most of standard distributions out of the box, but you might need to initialize one or both of them by using `load_module` directive in main `nginx.conf` file (place it outside any server, location or http block):

```
load_module "/etc/nginx/modules/ngx_http_xslt_filter_module.so";
```

## Instalation
1. Place `autoindex.xslt` file somewhere on your web server, it doesn't need to be in any www root directory, can be placed anywhere from where nginx daemon can read (in this documentation we assume that file is placed under `/srv/autoindex.xslt`).
1. Configure location as follows:

```
    location / {
        root /srv/www/dropzone; # Change root to whatever you want
        autoindex on;
        autoindex_format xml;
        autoindex_exact_size off;
        autoindex_localtime off;

        xslt_stylesheet /srv/autoindex.xslt;
    }
```
3. Restart Nginx.

And that's it! You have now modern web directory browser enabled.

### Enabling uploads
For uploads to work you need to enable WebDav on the location, let's extend our example from above:

```
    location / {
        root /srv/www/dropzone; # Change root to whatever you want
        autoindex on;
        autoindex_format xml;
        autoindex_exact_size off;
        autoindex_localtime off;

        xslt_stylesheet /srv/autoindex.xslt;

	client_body_temp_path /srv/temp; # Set to path where WebDav will save temporary files
	dav_methods PUT DELETE;
	add_header X-Options "WebDav"; # Important!
        create_full_put_path on;
        dav_access group:rw all:r;
	client_max_body_size 1000M; # Change this as you need
    }
```

And now just navigate to the location and drag-and-drop a file into browser's window. This feature should work in any modern web browser _(sorry IE fans)_.

## Advanced configuration (you can stop with config above if you want)

### Hardening uploads
Of course allowing anybody to upload any file to your server isn't the best idea in the world, so you might want to think about adding at least [HTTP Basic Auth](https://en.wikipedia.org/wiki/.htpasswd):

```
    location / {
        root /srv/www/dropzone; # Change root to whatever you want
        autoindex on;
        autoindex_format xml;
        autoindex_exact_size off;
        autoindex_localtime off;

        xslt_stylesheet /srv/autoindex.xslt;

	client_body_temp_path /srv/temp; # Set to path where WebDav will save temporary files
	dav_methods PUT DELETE;
	add_header X-Options "WebDav"; # Important!
        create_full_put_path on;
        dav_access group:rw all:r;
	client_max_body_size 1000M; # Change this as you need

        auth_basic "Please authenticate yourself";
        auth_basic_user_file /srv/.htpasswd; # Set to path where you keep your .htpasswd file
    }
```

### Even fancier configuration
This is advanced configuration, that allows you to mix password secured and public folders. Only password secured folders will support uploads.

```
server {
    listen 80; # You might want to add SSL here :)

    server_name "your_servername.com"; # Configure this

    location ~* /(?<subpath>[^/]*)/?(?<file>.*)$ {
	set $htaccess_user_file /srv/www/dropzone/$subpath/.htpasswd; # Set first part of the path to your root directory, leave `/$subpath/.htpasswd;` part

	if (!-f $htaccess_user_file) {
		return 599;
	}

	auth_basic "Please authenticate yourself";
	auth_basic_user_file $htaccess_user_file;

	client_body_temp_path /srv/temp;
	dav_methods PUT DELETE;
	add_header X-Options "WebDav"; # Important!
	create_full_put_path on;
	dav_access group:rw all:r;
	client_max_body_size 1000M; # Change this as you need

	root /srv/www/dropzone; # Change root to whatever you want
	autoindex on;
	autoindex_format xml;
	autoindex_exact_size off;
	autoindex_localtime off;

	xslt_stylesheet /srv/autoindex.xslt;
    }

    error_page 599 = @nosec;

    location @nosec {
        root /srv/www/dropzone; # Set to same root as location above
        autoindex on;
        autoindex_format xml;
        autoindex_exact_size off;
        autoindex_localtime off;

        xslt_stylesheet /srv/autoindex.xslt;
    }
}
```

What this configuration does is it looks for `.htpasswd` file in the first subfolder of the request path and if it finds it, then the password is required and WebDav enabled. If there is no `.htpasswd` file in first subfolder, then fallback to `@nosec` location is made and this one doesn't have WebDav (so no uploads) but still is nicely styled.

Note that only first subfolder is checked and then whole path upwards is secured. Placing `.htpassword` in any other sub-subfolder will not work as expected.

```
\
|- My Folder 1
    |- File1.txt
    |- File2.txt
    |- Sub Folder 1
        |- File3.txt
|        
|- My Secret Folder 1
    |- .htpasswd
    |- Presentation1.ppt
    |- My Secret Folder 2
        |- Presentation2.ppt
|
|- My Folder 3
    |- Music1.mp3
    |- Sub Folder 2
        |- .htpasswd
        |- Unsecured.mp3
```

In example above `My Folder 1` is standard folder with public access (no `.htpasswd` anywhere in the path). 

`My Secret Folder 1` has `.htpasswd` inside so access to this location will require authentication, as well as access to `My Secret Folder 2` and anything inside it.

`My Folder 3` is again standard folder with public access. There is `.htpasswd` in `Sub Folder 2` but it isn't used so access to `Unsecured.mp3` is still public.

## Development

```sh
docker-compose up
# Site is available at http://localhost:8080
```

## Future plans
1. Implement more WebDav options (COPY, DELETE, MOVE, MKCOL) and interface for them
2. Include more layouts and styles and separate them from main xlst file

## Credits

Based on [ngx-superbindex](https://github.com/gibatronic/ngx-superbindex) by [Gibran Malheiros](https://github.com/gibatronic).
