#!/bin/bash
# Quick test build for ATS server

set -e

echo "🐳 Testing ATS server Docker build..."

# Build just the ATS server image
echo "Building ATS server image..."
docker build -f Dockerfile.ats-server -t ats-server-test .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    echo "📋 Image info:"
    docker images | grep ats-server-test
    
    echo ""
    echo "🔍 Testing image startup..."
    
    # Test if the image can start (don't run the server, just check the image)
    docker run --rm ats-server-test ls -la /app/ats-server/
    
    echo ""
    echo "🎮 ATS server files:"
    docker run --rm ats-server-test find /app/ats-server -name "*amtrucks*" -o -name "*server*" | head -10
    
    echo ""
    echo "✅ Image test completed successfully!"
    echo ""
    echo "🚀 To run the server:"
    echo "docker run -d --name ats-server -p 27015:27015/tcp -p 27015:27015/udp ats-server-test"
    
else
    echo "❌ Build failed!"
    exit 1
fi
