FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

# 1000 is the image's built-in "node" user; numeric so Kubernetes runAsNonRoot can verify it
USER 1000

EXPOSE 3000

CMD ["npm", "start"]
