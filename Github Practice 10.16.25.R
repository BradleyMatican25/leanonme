# Git Hub Practice
install.packages("gitcreds")
library(gert)
library(gitcreds)
library(credentials)
gitcreds_set()
credentials::set_github_pat()
usethis::git_sitrep()

# this will prompt a popup that asks you to enter your GitHub Personal Access Token.

gert::git_pull() # pull most recent changes from GitHub

gert::git_add(dir(all.files = TRUE)) # select any and all new files created or edited to be 'staged'

# 'staged' files are to be saved anew on GitHub 

gert::git_commit_all("my first commit") # save your record of file edits - called a commit

gert::git_push() # push your commit to GitHub