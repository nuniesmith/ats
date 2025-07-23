# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    curl \
    bash \
    git \
    python3 \
    make \
    g++

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy source code
COPY . .

# Create necessary directories
RUN mkdir -p logs data uploads

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of app directory
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start the application
CMD ["npm", "start"]
