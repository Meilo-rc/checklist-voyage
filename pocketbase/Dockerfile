FROM alpine:3.20

ARG POCKETBASE_VERSION=0.22.25

RUN apk add --no-cache ca-certificates sqlite unzip wget \
    && mkdir -p /pb/pb_data /pb/pb_hooks /pb/pb_migrations \
    && wget -q "https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip" -O /tmp/pocketbase.zip \
    && unzip -q /tmp/pocketbase.zip -d /pb \
    && rm /tmp/pocketbase.zip \
    && chmod 0755 /pb/pocketbase

COPY pocketbase/pb_hooks/cv1_sync.pb.js /pb/pb_hooks/cv1_sync.pb.js
COPY pocketbase/pb_hooks/cv1_documents.pb.js /pb/pb_hooks/cv1_documents.pb.js
COPY pocketbase/pb_hooks/cv1_links.pb.js /pb/pb_hooks/cv1_links.pb.js
COPY pocketbase/pb_migrations/2026081701_cv1_library_sync.js /pb/pb_migrations/2026081701_cv1_library_sync.js
COPY pocketbase/pb_migrations/2026082001_cv1_shared_documents.js /pb/pb_migrations/2026082001_cv1_shared_documents.js

EXPOSE 8090

CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090", "--dir=/pb/pb_data", "--hooksDir=/pb/pb_hooks", "--migrationsDir=/pb/pb_migrations"]
