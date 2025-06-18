# Gunakan base image Node.js LTS
FROM node:18-alpine

# Setel direktori kerja di dalam container
WORKDIR /app

# Salin package.json dan package-lock.json (jika ada)
# Ini dilakukan terpisah agar layer ini di-cache jika dependensi tidak berubah
COPY package*.json ./

# Instal dependensi
RUN npm install

# Salin sisa kode aplikasi Anda
COPY . .

# Expose port yang digunakan aplikasi Express di dalam container
EXPOSE 3000

# Perintah untuk menjalankan aplikasi ketika container dimulai
CMD ["npm", "start"]