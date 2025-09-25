#!/bin/bash

# Resume Build & Deploy Script
# Generates PDF from markdown and updates the GitHub repository

set -e  # Exit on any error

echo "🚀 Starting resume build process..."

# Configuration
RESUME_SOURCE="resume.md"
RESUME_PDF="resume.pdf"
README_FILE="README.md"
BACKUP_DIR="backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
REPO_NAME="$(basename "$(pwd)")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

print_success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# ASCII Art Banner
echo -e "${PURPLE}"
cat << "BANNER"
██████╗ ███████╗███████╗██╗   ██╗███╗   ███╗███████╗
██╔══██╗██╔════╝██╔════╝██║   ██║████╗ ████║██╔════╝
██████╔╝█████╗  ███████╗██║   ██║██╔████╔██║█████╗  
██╔══██╗██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  
██║  ██║███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗
╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                      
    ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗ 
    ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
    ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
    ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
    ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
    ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
BANNER
echo -e "${NC}"

# Check if required files exist
print_step "Checking required files..."
if [ ! -f "$RESUME_SOURCE" ]; then
    print_error "Resume source file '$RESUME_SOURCE' not found!"
    echo "Please create $RESUME_SOURCE with your resume content."
    exit 1
fi

# Create directory structure
print_step "Setting up directory structure..."
mkdir -p "$BACKUP_DIR" assets/projects templates scripts

# Backup existing files
if [ -f "$RESUME_PDF" ]; then
    print_status "Backing up existing PDF..."
    cp "$RESUME_PDF" "$BACKUP_DIR/resume_backup_$DATE.pdf"
fi

if [ -f "$README_FILE" ]; then
    print_status "Backing up existing README..."
    cp "$README_FILE" "$BACKUP_DIR/README_backup_$DATE.md"
fi

# Check dependencies
print_step "Checking dependencies..."
MISSING_DEPS=()

if ! command -v pandoc &> /dev/null; then
    MISSING_DEPS+=("pandoc")
fi

if ! command -v pdflatex &> /dev/null && ! command -v xelatex &> /dev/null; then
    MISSING_DEPS+=("texlive-latex-recommended")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    print_error "Missing dependencies: ${MISSING_DEPS[*]}"
    echo ""
    echo "To install on Ubuntu/Debian:"
    echo "sudo apt update && sudo apt install pandoc texlive-latex-recommended texlive-fonts-recommended texlive-fonts-extra"
    echo ""
    echo "To install on macOS:"
    echo "brew install pandoc"
    echo "brew install --cask mactex"
    exit 1
fi

print_success "All dependencies found!"

# Generate PDF from markdown
print_header "Generating PDF resume..."

# Enhanced PDF generation with better styling
if pandoc "$RESUME_SOURCE" \
    --pdf-engine=xelatex \
    --variable geometry:margin=0.8in \
    --variable fontsize=11pt \
    --variable documentclass=article \
    --variable fontfamily=lmodern \
    --variable colorlinks=true \
    --variable linkcolor=blue \
    --variable urlcolor=blue \
    --variable toccolor=blue \
    --highlight-style=tango \
    --standalone \
    -o "$RESUME_PDF"; then
    print_success "PDF generated successfully: $RESUME_PDF"
    
    # Get file size
    PDF_SIZE=$(du -h "$RESUME_PDF" | cut -f1)
    print_status "PDF size: $PDF_SIZE"
else
    print_error "Failed to generate PDF"
    echo "Common issues:"
    echo "1. Check if all LaTeX packages are installed"
    echo "2. Verify markdown syntax in $RESUME_SOURCE"
    echo "3. Ensure no special characters are causing issues"
    exit 1
fi

# Update README with timestamp
print_header "Updating README.md with current timestamp..."
if [ -f "$README_FILE" ]; then
    # Update the timestamp in README
    CURRENT_DATE=$(date +"%B %d, %Y at %I:%M %p")
    sed -i.bak "s/\*Last updated: .*\*/\*Last updated: $CURRENT_DATE\*/" "$README_FILE"
    print_status "README.md timestamp updated"
else
    print_warning "README.md not found. Please ensure you have the README template."
fi

# Generate .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    print_step "Creating .gitignore..."
    cat > .gitignore << 'GITIGNORE_EOF'
# Backup files
backups/
*.bak
*.tmp

# LaTeX auxiliary files
*.aux
*.log
*.out
*.toc
*.fdb_latexmk
*.fls
*.synctex.gz

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Personal notes
notes/
drafts/
GITIGNORE_EOF
    print_success ".gitignore created"
fi

# Validate generated files
print_step "Validating generated files..."
if [ -f "$RESUME_PDF" ] && [ -s "$RESUME_PDF" ]; then
    print_success "PDF validation: ✅ File exists and is not empty"
else
    print_error "PDF validation: ❌ File missing or empty"
    exit 1
fi

# Optional: Git operations
if git rev-parse --git-dir > /dev/null 2>&1; then
    print_header "Git repository detected"
    
    # Check if there are changes to commit
    if ! git diff --quiet || ! git diff --cached --quiet; then
        read -p "📝 Do you want to commit and push changes to Git? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_header "Committing changes to Git..."
            
            # Add files
            git add "$RESUME_PDF" "$README_FILE" "$RESUME_SOURCE" .gitignore
            
            # Commit with detailed message
            COMMIT_MSG="📄 Update resume - $(date '+%Y-%m-%d %H:%M')

- Updated resume content
- Generated new PDF (${PDF_SIZE})
- Refreshed README timestamp
- Build completed successfully"
            
            if git commit -m "$COMMIT_MSG"; then
                print_success "Changes committed successfully"
                
                # Push if remote exists
                if git remote get-url origin > /dev/null 2>&1; then
                    read -p "🚀 Push to remote repository? (y/n): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        print_header "Pushing to remote..."
                        BRANCH=$(git rev-parse --abbrev-ref HEAD)
                        if git push origin "$BRANCH"; then
                            print_success "Successfully pushed to remote repository"
                            
                            # Get remote URL for display
                            REMOTE_URL=$(git remote get-url origin)
                            if [[ $REMOTE_URL == *"github.com"* ]]; then
                                GITHUB_URL=${REMOTE_URL/.git/}
                                GITHUB_URL=${GITHUB_URL/git@github.com:/https://github.com/}
                                echo "🌐 View your profile at: $GITHUB_URL"
                            fi
                        else
                            print_warning "Failed to push to remote. Check your permissions or network connection."
                        fi
                    fi
                else
                    print_warning "No remote repository configured."
                    echo "To add a remote repository:"
                    echo "git remote add origin https://github.com/yourusername/$REPO_NAME.git"
                fi
            else
                print_warning "Nothing to commit (no changes detected)"
            fi
        fi
    else
        print_status "No changes detected in Git repository"
    fi
else
    print_header "Initializing Git repository..."
    read -p "🔧 Initialize Git repository? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        git branch -M main
        git add .
        git commit -m "🎉 Initial resume repository setup

- Added resume.md source file
- Generated initial PDF
- Created README.md with GitHub profile
- Set up build automation
- Configured .gitignore"
        
        print_success "Git repository initialized with initial commit"
        echo ""
        echo "To connect to GitHub:"
        echo "1. Create a new repository at https://github.com/new"
        echo "2. Name it '$REPO_NAME' (or your GitHub username for profile README)"
        echo "3. Run: git remote add origin https://github.com/yourusername/$REPO_NAME.git"
        echo "4. Run: git push -u origin main"
    fi
fi

# Performance and file info
print_header "Build Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 Resume Source:  $RESUME_SOURCE"
echo "📋 PDF Resume:     $RESUME_PDF ($PDF_SIZE)"
echo "📖 GitHub README:  $README_FILE"
echo "💾 Backups:        $BACKUP_DIR/"
echo "🕒 Build Time:     $(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Quick file validation
print_step "File validation summary:"
[ -f "$RESUME_SOURCE" ] && echo "✅ resume.md exists" || echo "❌ resume.md missing"
[ -f "$README_FILE" ] && echo "✅ README.md exists" || echo "❌ README.md missing"
[ -f "$RESUME_PDF" ] && echo "✅ resume.pdf exists" || echo "❌ resume.pdf missing"
[ -f ".gitignore" ] && echo "✅ .gitignore exists" || echo "❌ .gitignore missing"

# Optional: Open files for preview
if command -v xdg-open &> /dev/null; then
    echo ""
    read -p "👀 Open PDF for preview? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open "$RESUME_PDF" &
    fi
elif command -v open &> /dev/null; then
    echo ""
    read -p "👀 Open PDF for preview? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$RESUME_PDF"
    fi
fi

print_success "✅ Resume build process completed successfully!"

# Display next steps
echo ""
print_header "🎯 Next Steps:"
echo "1. 📝 Customize your information in $RESUME_SOURCE"
echo "2. 🎨 Update GitHub username in $README_FILE"
echo "3. 📸 Add a profile photo to assets/"
echo "4. 🔗 Update all placeholder links and URLs"
echo "5. 🌟 Push to GitHub and set up as profile README"
echo "6. 📤 Use $RESUME_PDF for job applications"
echo ""
echo "📚 Pro Tips:"
echo "• Run ./build.sh anytime you update your resume"
echo "• Keep your LinkedIn and GitHub profiles in sync"
echo "• Add actual project repositories to showcase your work"
echo "• Consider setting up GitHub Actions for automatic builds"
echo ""
print_header "🌐 GitHub Profile Setup:"
if [[ "$REPO_NAME" != *"$USER"* ]] && [[ "$REPO_NAME" != "resume"* ]]; then
    echo "💡 For a GitHub profile README, rename this repo to match your username"
    echo "   Repository name should be: yourusername/yourusername"
fi
echo "🔗 Profile URL will be: https://github.com/yourusername"
echo "📄 Direct PDF link: https://github.com/yourusername/$REPO_NAME/raw/main/resume.pdf"

echo ""
echo -e "${PURPLE}Happy job hunting! 🚀${NC}"