#!/bin/bash

# Resume Deployment Script
# Automates the process of deploying resume to multiple platforms

echo "🚀 Resume Deployment Assistant"

# Build the resume first
echo "Building resume..."
./build.sh

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Cannot proceed with deployment."
    exit 1
fi

echo ""
echo "📋 Deployment Options:"
echo "1. 📧 Email resume to specific address"
echo "2. 🌐 Upload to website/portfolio"
echo "3. 💼 Copy to job application folder"
echo "4. 📱 Generate QR code for easy sharing"
echo "5. 📊 Generate resume statistics"

read -p "Select an option (1-5): " choice

case $choice in
    1)
        read -p "Enter email address: " email
        if command -v mutt &> /dev/null; then
            echo "Sending resume via email..."
            echo "Please find my resume attached." | mutt -s "Resume - [Your Name]" -a resume.pdf -- "$email"
            echo "✅ Resume sent to $email"
        else
            echo "📧 Email client not configured. Resume saved as resume.pdf for manual sending."
        fi
        ;;
    2)
        echo "🌐 Website deployment would go here"
        echo "Add your specific deployment commands (rsync, scp, etc.)"
        ;;
    3)
        APPLICATIONS_DIR="$HOME/job-applications"
        mkdir -p "$APPLICATIONS_DIR"
        DATE=$(date +"%Y-%m-%d")
        cp resume.pdf "$APPLICATIONS_DIR/resume_$DATE.pdf"
        echo "✅ Resume copied to $APPLICATIONS_DIR/resume_$DATE.pdf"
        ;;
    4)
        if command -v qrencode &> /dev/null; then
            # Generate QR code pointing to GitHub resume
            echo "📱 Generating QR code..."
            qrencode -t PNG -o resume_qr.png "https://github.com/yourusername/yourusername/raw/main/resume.pdf"
            echo "✅ QR code saved as resume_qr.png"
        else
            echo "⚠️  qrencode not installed. Install with: sudo apt install qrencode"
        fi
        ;;
    5)
        echo "📊 Resume Statistics:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        wc -l resume.md | awk '{print "Lines: " $1}'
        wc -w resume.md | awk '{print "Words: " $1}'
        wc -c resume.md | awk '{print "Characters: " $1}'
        if [ -f resume.pdf ]; then
            ls -lh resume.pdf | awk '{print "PDF Size: " $5}'
        fi
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ;;
    *)
        echo "Invalid option selected."
        ;;
esac

echo "✅ Deployment assistant completed!"