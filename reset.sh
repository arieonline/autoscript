rm -rf .git

git init
git add .
git commit -m "pertamax"

git remote add origin git@github.com:arieonline/autoscript.git
git push -u --force origin master

