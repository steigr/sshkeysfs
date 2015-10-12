from alpine
run apk add --update ruby fuse ruby-dev fuse-dev gcc libc-dev make linux-headers openssh openssl \
 && gem install --no-ri --no-rdoc rfusefs \
 && apk del make gcc libc-dev fuse-dev ruby-dev linux-headers
entrypoint ["rpssh"]
add rpssh /usr/bin/rpssh
add sshkeysfs /usr/bin/sshkeysfs
run chmod +x /usr/bin/rpssh /usr/bin/sshkeysfs
