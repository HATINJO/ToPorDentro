# ---------------------------------------------------
# Etapa 1: Compilação da aplicação Flutter Web
# ---------------------------------------------------
FROM ghcr.io/cirrusci/flutter:stable AS build-env

WORKDIR /app

# Copia os arquivos do projeto para o contêiner
COPY . .

# Baixa as dependências e compila para a Web em modo de produção
RUN flutter pub get
RUN flutter build web --release

# ---------------------------------------------------
# Etapa 2: Servidor Nginx para rodar o app levemente
# ---------------------------------------------------
FROM nginx:alpine

# Copia os arquivos compilados da etapa anterior para a pasta do Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expõe a porta padrão do servidor Nginx
EXPOSE 80