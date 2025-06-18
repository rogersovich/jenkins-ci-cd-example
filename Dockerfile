# Stage 1: Build stage
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev # Hanya instal dependensi produksi
# Jika Anda memiliki build step (misalnya, transpiling TypeScript, bundling React/Vue app):
# RUN npm run build

# Salin kode aplikasi
COPY . .

# Stage 2: Production stage (menggunakan base image yang lebih kecil)
FROM node:18-alpine # Bisa juga pakai node:18-slim-alpine atau distroless jika sangat ekstrem

WORKDIR /app

# Salin hanya yang dibutuhkan dari build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/app.js ./ # Salin app.js atau file hasil build Anda
COPY --from=build /app/package.json ./ # package.json untuk script start

EXPOSE 3000
CMD ["npm", "start"]