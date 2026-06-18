# Tiny image: alpine node, no deps to install.
FROM node:20-alpine

WORKDIR /app
COPY app/package.json ./
COPY app/server.js ./

ENV PORT=3000
EXPOSE 3000

# Run as non-root.
USER node

CMD ["node", "server.js"]
