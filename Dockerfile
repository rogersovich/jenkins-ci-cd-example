# Gunakan Node.js image resmi sebagai base image.
# node:18-alpine adalah versi Node.js 18 yang berbasis Alpine Linux, sangat ringan.
FROM node:18-alpine

# Set direktori kerja di dalam container.
# Semua perintah COPY dan RUN selanjutnya akan dieksekusi di direktori ini.
WORKDIR /app

# Salin file package.json dan package-lock.json ke direktori kerja.
# Ini dilakukan secara terpisah untuk memanfaatkan caching layer Docker.
# Jika hanya file-file ini yang berubah, langkah npm install tidak perlu diulang.
COPY package*.json ./

# Jalankan npm install untuk menginstal dependensi produksi.
# --production memastikan hanya dependensi yang diperlukan untuk runtime yang diinstal.
RUN npm install --production

# Salin sisa kode aplikasi Anda ke direktori kerja.
# Perintah ini dijalankan setelah dependensi terinstal.
COPY . .

# Beri tahu Docker bahwa container akan mendengarkan di port 3000 pada runtime.
# Ini hanyalah deklarasi, bukan memublikasikan port secara otomatis.
EXPOSE 3000

# Perintah default yang akan dijalankan saat container dimulai.
# Dalam kasus ini, menjalankan script 'start' yang didefinisikan di package.json Anda.
CMD ["npm", "start"]