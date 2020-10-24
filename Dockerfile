ARG ALPINE_VERSION="3.12"

FROM alpine:${ALPINE_VERSION}

ARG PG_MAJOR="13.0"
ARG PG_VERSION="13.0"
ARG GOSU_VERSION="1.12"
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
		org.label-schema.name="Minimal PostgreSQL image based on Alpine Linux" \
		org.label-schema.description="Minimal PostgreSQL image based on Alpine Linux" \
		org.label-schema.url="https://github.com/onjin/docker-alpine-postgres" \
		org.label-schema.vcs-ref=$VCS_REF \
		org.label-schema.vcs-url="https://github.com/onjin/docker-alpine-postgres" \
		org.label-schema.vendor="Marek Wywiał" \
		org.label-schema.version=$PG_VERSION \
		org.label-schema.schema-version="1.0"


ENV PATH /usr/lib/postgresql/${PG_MAJOR}/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

ENV LANG en_US.utf8
RUN set -eux; \
	addgroup -g 70 -S postgres; \
	adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres; \
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql

# echo "$PG_SHA256 *postgresql.tar.bz2" | sha256sum -c -; \
RUN set -eux; \
    \
    wget -O postgresql.tar.bz2 https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 ; \
	mkdir -p /usr/src/postgresql; \
	tar \
		--extract \
		--file postgresql.tar.bz2 \
		--directory /usr/src/postgresql \
		--strip-components 1 \
	; \
	rm postgresql.tar.bz2; \
	\
    apk add --no-cache --virtual .build-deps \
		bison \
		coreutils \
		dpkg-dev dpkg \
		flex \
		gcc \
#		krb5-dev \
		libc-dev \
		libedit-dev \
		libxml2-dev \
		libxslt-dev \
		linux-headers \
		llvm10-dev clang g++ \
		make \
#		openldap-dev \
		openssl-dev \
# configure: error: prove not found
		perl-utils \
# configure: error: Perl module IPC::Run is required to run TAP tests
		perl-ipc-run \
#		perl-dev \
#		python-dev \
#		python3-dev \
#		tcl-dev \
		util-linux-dev \
		zlib-dev \
        icu-dev \
    ;\
    \
    mkdir -p /docker-entrypoint-initdb.d ; \
    cd /usr/src/postgresql ; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--enable-integer-datetimes \
		--enable-thread-safety \
		--enable-tap-tests \
		--disable-rpath \
		--with-uuid=e2fs \
		--with-gnu-ld \
		--with-system-tzdata=/usr/share/zoneinfo \
		--prefix=/usr/local \
		--with-includes=/usr/local/include \
		--with-libraries=/usr/local/lib \
		--with-openssl  \
		--with-libxml \
		--with-libxslt \
		--with-icu \
		--with-llvm\
		;\
	make world ; \
	make install-world ; \
	make -C contrib install ;\
    cd /usr/src/postgresql/contrib ;\
	make ;\
	make install \
	; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .postgresql-rundeps \
		$runDeps \
		bash \
		tzdata \
	;\
    apk del --no-network .build-deps; \
	cd /; \
	rm -rf \
		/usr/src/postgresql \
		/usr/local/share/doc \
		/usr/local/share/man \
	; \
	\
	postgres --version \
	; \
	apk add gnupg ; \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 ; \
    gpg --list-keys --fingerprint --with-colons | sed -E -n -e 's/^fpr:::::::::([0-9A-F]+):$/\1:6:/p' | gpg --import-ownertrust ; \
    wget -O /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 ; \
    wget -O /usr/local/bin/gosu.asc https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc ; \
    gpg --verify /usr/local/bin/gosu.asc ; \
    rm /usr/local/bin/gosu.asc ; \
    chmod +x /usr/local/bin/gosu 


VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGINT

EXPOSE 5432
CMD ["postgres"]

#vim: set ft=dockerfile:
