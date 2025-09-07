#!/bin/bash

# Resume Content Validation Script
# Checks for common issues in resume content

echo "🔍 Validating resume content..."

RESUME_FILE="resume.md"
ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNINGS++))
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if resume file exists
if [ ! -f "$RESUME_FILE" ]; then
    print_error "Resume file '$RESUME_FILE' not found"
    exit 1
fi

# Check for placeholder text
echo "Checking for placeholder content..."
PLACEHOLDERS=(
    "\[Your"
    "your.email@example.com"
    "yourusername"
    "yourwebsite.com"
    "Company Name"
    "Start Date"
    "End Date"
)

for placeholder in "${PLACEHOLDERS[@]}"; do
    if grep -q "$placeholder" "$RESUME_FILE"; then
        print_warning "Found placeholder text: $placeholder"
    fi
done

# Check for required sections
echo "Checking for required sections..."
REQUIRED_SECTIONS=(
    "Professional Summary"
    "Technical Skills"
    "Professional Experience"
    "Education"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "## $section" "$RESUME_FILE"; then
        print_success "Found section: $section"
    else
        print_error "Missing required section: $section"
    fi
done

# Check for email format
echo "Validating email format..."
if grep -E "^📧 [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" "$RESUME_FILE" > /dev/null; then
    print_success "Email format looks good"
else
    print_warning "Email format might need attention"
fi

# Check for markdown syntax issues
echo "Checking markdown syntax..."
if command -v markdownlint &> /dev/null; then
    markdownlint "$RESUME_FILE" || print_warning "Markdown syntax issues detected"
else
    print_warning "markdownlint not installed - skipping syntax check"
fi

# Summary
echo ""
echo "═══════════════════════════════════════"
echo "Validation Summary:"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    print_success "Validation passed! 🎉"
    exit 0
else
    print_error "Validation failed with $ERRORS errors"
    exit 1
fi