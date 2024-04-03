# Prepare your web servers

file{"/data/web_static/releases/test/index.html":
ensure  => "file",
content => "hello world",
owner   => "ubuntu",
group   => "ubuntu",
require => File["/data/web_static/releases/test"],}

file{"/data/web_static/releases/test":
ensure  => "directory",
owner   => "ubuntu",
group   => "ubuntu",
require => File["/data/web_static/releases"],}

file{"/data/web_static":
ensure  => "directory",
owner   => "ubuntu",
group   => "ubuntu",
require => File["/data"],}

file{"/data/web_static/releases":
ensure  => "directory",
owner   => "ubuntu",
group   => "ubuntu",
require => File["/data/web_static"],}

file{"/data/web_static/shared":
ensure  => "directory",
owner   => "ubuntu",
group   => "ubuntu",
require => File["/data/web_static"],}

file{"/data/web_static/current":
ensure  => "link",
owner   => "ubuntu",
group   => "ubuntu",
target  => "/data/web_static/releases/test",
require => File["/data/web_static"],}


file{"/data":
ensure => "directory",
owner  => "ubuntu",
group  => "ubuntu",}

file{"/etc/nginx/sites-available/default":
  ensure  => "file",
  content => "server {
    listen 80;
    listen [::]:80 default_server;
    server_name mohamed;
    location /hbnb_static {
        alias /data/web_static/current/;
    }
}",
  require => Package['nginx'],
  notify  => Service['nginx'],
  replace => 'true',
}

#install nginx
package{ 'nginx':
  ensure => 'installed',
}

service{ 'nginx':
  ensure => 'running',
  enable => 'true',
}
