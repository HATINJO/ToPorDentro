# ==========================================
# Estágio 1: Build da aplicação Flutter Web
# ==========================================
FROM debian:bookworm-slim AS build-stage

# Instala dependências básicas do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Resolve o erro de permissões do Render:
# Subtitui o 'tar' por um script que força a opção '--no-same-owner'
RUN mv /usr/bin/tar /usr/bin/tar-real && \
    echo '#!/bin/sh' > /usr/bin/tar && \
    echo 'exec /usr/bin/tar-real --no-same-owner --no-same-permissions "$@"' >> /usr/bin/tar && \
    chmod +x /usr/bin/tar

# Baixa o Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /sdks/flutter
ENV PATH="/sdks/flutter/bin:${PATH}"

WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Compila o projeto para Web
RUN flutter pub get
RUN flutter build web --release

# ==========================================
# Estágio 2: Servidor Web de Produção (NGINX)
# ==========================================
FROM nginx:alpine AS production-stage

COPY --from=build-stage /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]