# Base image
FROM node:18-alpine AS testing

# Working directory
WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy application files
COPY . .

# Run automated tests
RUN npm test


# Production stage
FROM node:18-alpine AS production

WORKDIR /usr/src/app

COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev && npm cache clean --force

# Copy application source
COPY --from=testing /usr/src/app/app.js ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /usr/src/app

USER nodejs

EXPOSE 3000

CMD ["npm", "start"]
