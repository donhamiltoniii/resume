# Resume Repository Setup Instructions

## Quick Start

1. **Clone or download this repository**
2. **Install dependencies:**
   ```bash
   sudo apt install pandoc texlive-latex-recommended texlive-fonts-recommended
   ```
3. **Make scripts executable:**
   ```bash
   chmod +x build.sh scripts/*.sh
   ```
4. **Customize your content:**
   - Edit `resume.md` with your information
   - Update `README.md` with your GitHub username
   - Replace placeholder links and email addresses

5. **Build your resume:**
   ```bash
   ./build.sh
   ```

## GitHub Profile Setup

For a GitHub profile README (special repository):
1. Create a repository named exactly your GitHub username
2. Upload these files to that repository
3. Your README.md will display on your GitHub profile

## File Structure

```
repository/
├── resume.md           # Your resume content (EDIT THIS)
├── README.md          # GitHub profile display (EDIT THIS)
├── resume.pdf         # Generated PDF
├── build.sh           # Main build script
├── .gitignore         # Git ignore rules
├── README_template.md # Optional template
├── scripts/
│   ├── validate.sh    # Content validation
│   └── deploy.sh      # Deployment helper
├── assets/            # Images and media
├── templates/         # Custom templates
└── backups/          # Automatic backups
```

## Customization

1. **Personal Information:** Update all placeholders in `resume.md`
2. **GitHub Stats:** Replace "yourusername" with your actual GitHub username
3. **Colors:** Modify badge colors and themes in README.md
4. **Sections:** Add/remove sections as needed
5. **Projects:** Add your actual project repositories

## Build Process

The build script:
1. ✅ Validates dependencies
2. 📄 Generates PDF from markdown
3. 🔄 Updates README timestamp
4. 💾 Creates backups
5. 📝 Commits to Git (optional)
6. 🚀 Pushes to remote (optional)

## Pro Tips

- Run `./scripts/validate.sh` to check for common issues
- Use `./scripts/deploy.sh` for deployment options
- Keep LinkedIn and resume content synchronized
- Update regularly and track with Git
- Use semantic commit messages

## Troubleshooting

**PDF Generation Issues:**
- Ensure LaTeX packages are installed
- Check for special characters in markdown
- Verify pandoc installation

**GitHub Issues:**
- Check repository name matches username for profile README
- Ensure all links are updated with correct username
- Verify image URLs are accessible

**Build Script Issues:**
- Make sure script is executable: `chmod +x build.sh`
- Check file permissions
- Verify all dependencies are installed

## Support

This setup demonstrates:
- ✅ Version control proficiency
- ✅ Automation and scripting
- ✅ Documentation skills
- ✅ Modern development practices
- ✅ Technical communication

Happy job hunting! 🚀