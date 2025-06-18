# Stage 1: Build stage
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

# Salin kode aplikasi
COPY . .

# Stage 2: Production stage (menggunakan base image yang lebih kecil)
FROM node:18-alpine

WORKDIR /app

# Salin hanya yang dibutuhkan dari build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/app.js ./
COPY --from=build /app/package.json ./

EXPOSE 3000
CMD ["npm", "start"]