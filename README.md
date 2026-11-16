# purr

## needs

| what | for |
|---|---|
| git | repos, pushes, clones |
| gawk | the web pages |
| nginx | the web side |
| fcgiwrap | runs `web.sh` for nginx |
| openssh | pushes over ssh |
| make | installing |
| systemd | the fcgiwrap socket |

## install

run everything below as root, from inside the cloned purr folder:

```sh
git clone https://github.com/cqley/purr
cd purr
```

### 1. config

set `HOST` in `config.mk`. set `WWW` to the user nginx's workers run as, this shows it:

```sh
ps -o user= -C nginx
```

### 2. users

`git` owns the repos, `gitweb` reads them for the web.

```sh
useradd -r -U -m -d /var/lib/git -s /bin/sh git
usermod -p '*' git
chmod 750 /var/lib/git
useradd -r -g git -M -s /usr/sbin/nologin gitweb
```

### 3. scripts and units

```sh
make install
systemctl daemon-reload
systemctl enable --now purr.socket
```

### 4. nginx

`make` writes `purr.conf`. put it where nginx reads site configs, or `include` it in the http block of `nginx.conf`.

```sh
make
nginx -t && systemctl reload nginx
certbot --nginx -d git.example.org
```

### 5. people

one line per key in a file called `users`, owner first:

```
alice ssh-ed25519 AAAA... alice@laptop
alice ssh-ed25519 AAAA... alice@phone
bob ssh-ed25519 AAAA... bob
```

then run this, and again after every change:

```sh
make keys
```

## use

```
ssh git@git.example.org                    help
git push git@git.example.org:thing main    makes the repo if it is missing, private
ssh git@git.example.org public thing       show it on the web
ssh git@git.example.org private thing      hide it again
ssh git@git.example.org desc thing words   set the description
ssh git@git.example.org ls                 your repos
ssh git@git.example.org rm thing           delete it
git clone https://git.example.org/alice/thing.git
```

everyone can push only to their own repos and read their own plus all public ones.

## update

```sh
git pull && make install
```

## how

- repos live in `/var/lib/git/<owner>/<repo>.git`. a repo is public when `git-daemon-export-ok` is in it, the same file git itself checks.
- `ssh.sh` is the forced command on every key in `/var/lib/git/.ssh/authorized_keys`. it only runs git's own pack commands and the few above.
- `web.sh` runs through fcgiwrap as `gitweb`, which can read but not write. private and missing repos are both a 404. clones go to `git http-backend`, pushes over https are refused.
