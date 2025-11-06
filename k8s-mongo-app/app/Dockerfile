FROM node:18-alpine

WORKDIR /app
COPY . .
RUN npm install express mongoose

EXPOSE 8080
CMD ["node", "server.js"]