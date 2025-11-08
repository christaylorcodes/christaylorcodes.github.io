---
description: Commit and push changes to dev branch
---

Commit and push current changes to the dev branch for CI/CD verification.

1. Verify you're on the dev branch:
   ```bash
   git branch --show-current
   ```

2. Check current status:
   ```bash
   git status
   ```

3. Stage all changes:
   ```bash
   git add .
   ```

4. Commit with a descriptive message (ask user for commit message if not provided):
   ```bash
   git commit -m "User's commit message"
   ```

5. Push to origin dev:
   ```bash
   git push origin dev
   ```

6. Show the CI workflow link:
   ```
   View workflow: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
   ```

Remind the user that:
- The dev workflow will run quality checks (markdown linting, HTML validation, Lighthouse CI)
- Changes are NOT deployed to production
- Use `/prod` to promote to production after CI passes
