FROM dart:stable AS build

# Download npm to work with prisma within the build phase involving Dart
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
    apt-get install -y nodejs

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .

# Expose DATABASE_URL as build-time env variable for prisma
ARG DATABASE_URL

# Generate prisma-related files
RUN npm install prisma
RUN npx prisma generate

# Generate other Dart classes
RUN dart pub run build_runner build --delete-conflicting-outputs

COPY . .

# Generate executable
RUN dart pub get --offline
RUN dart compile exe bin/link_tailor.dart -o bin/server

# Configure runtime for prisma
RUN FILES="libz.so libgcc_s.so libssl.so libcrypto.so"; \
    for file in $FILES; do \
    so="$(find / -name "${file}*" -print -quit)"; \
    dir="$(dirname "$so")"; \
    mkdir -p "/runtime${dir}"; \
    cp "$so" "/runtime$so"; \
    echo "Copied $so to /runtime${so}"; \
    done

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/prisma-query-engine /app/bin/

ENV HOST = "localhost"
ENV LINK_TAILOR_RUN_MODE = "prod"
ENV PORT = 8080
ENV DATABASE_URL = ""

CMD ["/app/bin/server"]
