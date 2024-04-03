#!/usr/bin/python3
"""script that generates a .tgz archive from the contents of the web_static"""

from fabric.api import local, task, env, run, settings, put
import os
from datetime import datetime
env.hosts = ['35.153.79.242', '52.201.164.137']

@task
def do_pack():
    """archive web_static"""
    try:
        f_current_time = datetime.now().strftime('%Y%m%d%H%M%S')
        file_name = f'web_static_{f_current_time}.tgz'
        print(f"Packing web_static to versions/{file_name}")
        local("mkdir -p versions")
        local(f"tar -cvzf versions/{file_name} web_static")
        return f"versions/{file_name}"
    except Exception as e:
        return None


@task
def do_deploy(archive_path):
    """deploy web_static to servers"""

    if not os.path.exists(archive_path):
        return False
    try:
        for host in env.hosts:
            env.host_string = host
            filename = archive_path.split('/')[-1]
            filename = filename.split('.')[0]
            put(archive_path, '/tmp/')
            run(f'mkdir -p /data/web_static/releases/{filename}/')
            run(f'tar -xzf /tmp/{filename}.tgz -C \
                /data/web_static/releases/{filename}/')
            run(f'rm /tmp/{filename}.tgz')
            run(f'mv /data/web_static/releases/{filename}/web_static/* \
                /data/web_static/releases/{filename}/')
            run(
                f'rm -rf /data/web_static/releases/{filename}/web_static')
            run(f'rm -rf /data/web_static/current')
            run(f'ln -s /data/web_static/releases/{filename}/ \
                /data/web_static/current')
            print('New version deployed!')

        return True
    except Exception as e:
        return False


@task
def deploy():
    """full deployment"""
    try:
        path = do_pack()
        if path is None:
            return False
        return do_deploy(path)
    except Exception as e:
        return False

@task
def do_clean(number=0):
    """clean up old versions"""
    try:
        number = int(number)
        if number < 0:
            return False
        if number == 0 or number == 1:
            number = 1
        local(f'cd versions; ls -t | tail -n +{number} | xargs rm -rf --')
        for host in env.hosts:
            env.host_string = host
            run(f'cd /data/web_static/releases; ls -t | tail -n +{number} | xargs rm -rf --')
        return True
    except Exception as e:
        return False
