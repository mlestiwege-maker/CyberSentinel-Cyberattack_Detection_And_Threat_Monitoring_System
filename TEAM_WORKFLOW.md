# CyberSentinel — Team Development Workflow

## 📋 Purpose
This document outlines the Git workflow for all team members contributing to the CyberSentinel project. Following this workflow ensures code quality, team collaboration, and prevents accidental conflicts or broken commits to production.

---

## 🚫 GOLDEN RULE
**❌ NEVER push directly to `main`**
**✅ ALL changes must go through Pull Requests (PRs)**

---

## 📖 Contributor Workflow

### Step 1: Create a Feature Branch
```bash
git checkout -b feature-name
```
**Branch naming conventions:**
- `feature/new-dashboard` — New feature
- `fix/login-bug` — Bug fix  
- `docs/readme-update` — Documentation
- `refactor/code-cleanup` — Code refactoring
- `test/add-unit-tests` — Tests

### Step 2: Make Your Changes
Edit files, test locally, ensure the app builds and runs without errors.

### Step 3: Commit with Descriptive Messages
```bash
git add .
git commit -m "type: short description"
```
**Commit message format:**
- `feat: add voice command support`
- `fix: resolve dashboard overflow`
- `docs: update README with setup instructions`
- `refactor: simplify incident logic`
- `test: add integration tests for SMS feature`

### Step 4: Push to Your Branch
```bash
git push origin feature-name
```

### Step 5: Open a Pull Request on GitHub
1. **Go to your repository** → **Pull requests** tab
2. **Click "New pull request"** or look for the "Compare & pull request" button
3. **Set base branch to `main`**
4. **Add title and description** explaining what your changes do
5. **Click "Create pull request"**

### Step 6: Code Review
- Your code will be automatically reviewed by Copilot
- Team lead will review your PR
- Address any comments or requested changes
- Push fixes to the same branch (they'll auto-update the PR)

### Step 7: Merge to Main
Once approved:
1. **Click "Merge pull request"** on GitHub
2. **Confirm merge**
3. **Delete the branch** (cleanup)

### Step 8: Sync Locally
```bash
git checkout main
git pull origin main
```

---

## 🔧 Quick Command Reference

**Create and work on a feature:**
```bash
git checkout -b feature/your-feature
# ... make changes ...
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature
```

**After PR is merged:**
```bash
git checkout main
git pull origin main
git branch -d feature/your-feature  # Delete local branch
```

**Update your branch with latest main (if main has new commits):**
```bash
git fetch origin
git rebase origin/main
git push origin feature/your-feature --force-with-lease
```

---

## ✅ Checklist Before Creating a PR

- [ ] Code builds without errors (`flutter run -d linux`)
- [ ] Code is properly formatted
- [ ] Meaningful commit messages
- [ ] Related files changed (no unrelated changes)
- [ ] No sensitive data (API keys, passwords) committed
- [ ] Tested on your machine
- [ ] PR description explains *what* and *why*

---

## 🚑 Emergency: Undo a Local Commit (Not Yet Pushed)

```bash
git reset HEAD~1
# Your changes are still there, but the commit is undone
```

---

## 🚫 If You Accidentally Push to Main

Let the team lead know immediately. They can revert using:
```bash
git revert <commit-hash>
git push origin main
```

---

## 📞 Questions?
If unsure about anything, **ask the team lead before pushing**. It's better to ask than to break the workflow!

---

## 🔒 Branch Protection Rules (Enforced on `main`)

The following rules are enabled for the `main` branch:
- ✅ Require a pull request before merging
- ✅ Require at least 1 approval before merge
- ✅ No direct pushes allowed to main

**What this means:**
- Even if you're the project lead, you must use PRs
- Every merged change is tracked and reviewable
- No accidental commits to production

---

## 📊 Example PR Timeline

```
1. You create feature/dashboard-cards branch
              ↓
2. You push commits to feature/dashboard-cards
              ↓
3. You open PR: "feat: add dashboard cards"
              ↓
4. Copilot + Team Lead review
              ↓
5. You address feedback (push fixes to same branch)
              ↓
6. PR gets approved
              ↓
7. Team Lead clicks "Merge pull request"
              ↓
8. Branch auto-deleted on GitHub
              ↓
9. You sync locally: git checkout main && git pull
              ↓
✅ Done! Your changes are now in production
```

---

## 🎓 Learning Resources
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Git Branching Model](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Last Updated:** May 4, 2026  
**Owner:** Project Lead (mlestiwege-maker)  
**Status:** Active & Enforced ✅
