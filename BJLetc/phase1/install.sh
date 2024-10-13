tar -xf linunistring-1.2.tar.xz
cd libunistring-1.2
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-1.2 &&
make
make install
cd ..
rm -r libunistring-1.2
tar -xf libidn2-2.3.7.tar.gz
cd libidn2-2.3.7
./configure --prefix=/usr --disable-static &&
make
make install
cd ..
rm -r libidn2-2.3.7
tar -xf libpsl-0.21.5.tar.gz
cd libpsl-0.21.5
mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release &&

ninja
ninja install
cd ..
rm -r libpsl-0.21.5
tar -xf libtasn1-4.19.0.tar.gz
cd libtasn1-4.19.0
./configure --prefix=/usr --disable-static &&
make
make install
cd ..
rm -r libtasn1-4.19.0
tar -xf p11-kit-0.25.5.tar.xz
cd p11-kit-0.25.5
sed '20,$ d' -i trust/trust-extract-compat &&

cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF
mkdir p11-build &&
cd    p11-build &&

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D trust_paths=/etc/pki/anchors &&
ninja
ninja install &&
ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
        /usr/bin/update-ca-certificates

cd ..
rm -r p11-kit-0.25.5.tar.xz
tar -xf make-ca-1.14.tar.gz
cd make-ca-1.14
make install &&
install -vdm755 /etc/ssl/local
/usr/sbin/make-ca -g
systemctl enable update-pki.timer
cd ..
rm -r make-ca-1.14
tar -xf wget-1.24.5.tar.gz
cd wget-1.24.5
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
make
make install
cd ..
rm -r wget-1.24.5
echo Phase 01 Done.