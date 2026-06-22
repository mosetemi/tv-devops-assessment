# Build stage
# Installs dependencies and builds the application
FROM node:lts-alpine AS build
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm ci
COPY src ./src
COPY tsconfig.json ./

RUN echo "Files available inside Docker:"
RUN find . -maxdepth 4 -type f | sort

RUN npm run build

# Prod stage
# Uses the build stage to create a smaller image with only the production dependencies and the built application
FROM node:lts-alpine AS production
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev --silent
COPY --from=build /usr/src/app/dist ./dist

# Expose the port the app runs on
EXPOSE 3000
RUN chown -R node /usr/src/app
USER node
CMD ["node", "dist/server.js"]
