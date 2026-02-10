re-implement git hub repo clone feature:
use:- "gh api user --jq .login" to fetch user name of github acc and then store it in $me for eg 
install fzf by using "winget install junegunn.fzf" as a dependencie along side with github-cli

and mkdir and $HOME\Documents\github-repo and then run this to fetch git and downlaod all selected repo to " $HOME\Documents\github-repo " downlaod it

gh repo list YOUR_USERNAME --limit 200 `
  --json nameWithOwner `
  --jq '.[].nameWithOwner' |
fzf -m |
ForEach-Object {
    git clone "https://github.com/$_.git"
}

------------------------------------------------
previous version bug fix:
	1. before runnig : "starship preset gruvbox-rainbow -o '$HOME\.config\starship.toml" mkdir .config 
	2. for first step in user is alredy in admin poweshell open or force it to run in non-admin terminal 
